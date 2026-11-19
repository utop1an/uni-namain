"""Freeze complete initial-world compatibility audits and authored controls."""
import argparse
from collections import Counter
from copy import deepcopy
from datetime import datetime, timezone
import json
from pathlib import Path
import subprocess
import sys

from rcnc.aligned_domain import build
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.pddl import parse_sexpr, typed_symbols
from rcnc.world_compatibility import inspect_worlds


def world(source, domain, problem, object_map, root):
    return {'source': source, 'domain': domain.relative_to(root).as_posix(),
        'problem': problem.relative_to(root).as_posix(), 'domain_sha256': digest(domain),
        'problem_sha256': digest(problem), 'object_map': object_map}


def prepare(protocol_path, output):
    require_empty_output(output)
    protocol = json.loads(protocol_path.read_text(encoding='utf-8'))
    source = Path(protocol['source_root'])
    if not all(digest(source / name) == expected for name, expected in protocol['source_file_sha256'].items()):
        raise ValueError('Source file drift')
    output.mkdir(parents=True)
    (output / 'protocol.json').write_bytes(protocol_path.read_bytes())
    native = output / 'native'
    native.mkdir()
    for name in protocol['source_file_sha256']:
        (native / name).write_bytes((source / name).read_bytes())
    cases = []
    for model in protocol['models']:
        original = Path(model['path'])
        if digest(original / 'meta_domain.pddl') != model['domain_sha256'] or digest(original / 'meta_domain.json') != model['metadata_sha256']:
            raise ValueError('Compiled model drift')
        compiled = output / 'models' / model['id']
        compiled.mkdir(parents=True)
        for name in ('meta_domain.pddl', 'meta_domain.json'):
            (compiled / name).write_bytes((original / name).read_bytes())
        meta = json.loads((compiled / 'meta_domain.json').read_text(encoding='utf-8'))
        worlds = []
        for name in meta['sources']:
            domain, problem = native / (name + '_domainfile.pddl'), native / (name + '_problemfile.pddl')
            expression = parse_sexpr(problem.read_text(encoding='utf-8'))
            objects = next((section[1:] for section in expression if isinstance(section, list) and section and section[0] == ':objects'), [])
            mapping = {obj.lower(): 'q__' + name.lower() + '_' + obj.lower() for obj in typed_symbols(objects)}
            worlds.append(world(name, domain, problem, mapping, output))
        cases.append({'id': 'original_worlds__' + model['id'], 'compiled': compiled.relative_to(output).as_posix(),
            'domain_sha256': model['domain_sha256'], 'metadata_sha256': model['metadata_sha256'],
            'worlds': worlds, 'max_atoms': protocol['budget']['max_atoms_per_real_case'], 'expected_status': None})
    fixture = output / 'fixture'
    inputs = fixture / 'inputs'
    inputs.mkdir(parents=True)
    for name in ('A', 'B'):
        (inputs / (name + '_domainfile.pddl')).write_text(f'''(define (domain {name.lower()})
          (:requirements :typing :strips) (:types item)
          (:predicates (r ?x ?y - item) (flag))
          (:action mark :parameters (?x ?y - item) :precondition (and) :effect (r ?x ?y)))''', encoding='utf-8')
    spec = {'version': 1, 'decision_basis': 'authored_assumption',
        'source_sha256': {path.name: digest(path) for path in inputs.glob('*.pddl')},
        'type_groups': [{'members': ['A:item', 'B:item'], 'evidence': 'Authored finite fixture'}],
        'predicate_groups': [{'id': 'r', 'members': [{'predicate': 'A:r', 'order': [0, 1]},
            {'predicate': 'B:r', 'order': [1, 0]}], 'evidence': 'Authored finite direction control'},
            {'id': 'flag', 'members': [{'predicate': 'A:flag', 'order': []},
                {'predicate': 'B:flag', 'order': []}], 'evidence': 'Authored nullary control'}]}
    right, wrong = fixture / 'right', fixture / 'wrong'
    build(inputs, right, spec)
    mutant = deepcopy(spec)
    mutant['predicate_groups'][0]['members'][1]['order'] = [0, 1]
    build(inputs, wrong, mutant)
    problems = {}
    for label, name, objects, initial in [('a', 'A', 'a b', '(r a b)'), ('b', 'B', 'u v', '(r v u)'),
            ('b_opposite', 'B', 'u v', '(r u v)'), ('b_flag', 'B', 'u v', '(r v u) (flag)')]:
        path = fixture / (label + '.pddl')
        path.write_text(f'(define (problem p) (:domain {name.lower()}) (:objects {objects} - item) (:init {initial}) (:goal (flag)))', encoding='utf-8')
        problems[label] = path
    definitions = [('shared_entities_consistent', right, 'b', False, 1000000, 'compatible_initial_projections'),
        ('argument_order_mutant', wrong, 'b', False, 1000000, 'incompatible_initial_projections'),
        ('closed_world_conflict', right, 'b_opposite', False, 1000000, 'incompatible_initial_projections'),
        ('nullary_conflict', right, 'b_flag', False, 1000000, 'incompatible_initial_projections'),
        ('source_private_entities', right, 'b', True, 1000000, 'compatible_initial_projections'),
        ('atom_budget_control', right, 'b', False, 9, 'atom_budget_limit')]
    if [row[0] for row in definitions] != protocol['authored_controls']:
        raise ValueError('Control registry differs from fixed protocol')
    for identifier, compiled, variant, private, maximum, expected in definitions:
        worlds = [world('A', inputs / 'A_domainfile.pddl', problems['a'], {'a': 'q__one', 'b': 'q__two'}, output),
            world('B', inputs / 'B_domainfile.pddl', problems[variant],
                {'u': 'q__three' if private else 'q__one', 'v': 'q__four' if private else 'q__two'}, output)]
        cases.append({'id': identifier, 'compiled': compiled.relative_to(output).as_posix(),
            'domain_sha256': digest(compiled / 'meta_domain.pddl'), 'metadata_sha256': digest(compiled / 'meta_domain.json'),
            'worlds': worlds, 'max_atoms': maximum, 'expected_status': expected})
    implementation = snapshot_implementation(output, [Path(__file__), Path('rcnc/world_compatibility.py'),
        Path('rcnc/aligned_domain.py'), Path('rcnc/domain_union.py'), Path('rcnc/domain_building.py'),
        Path('rcnc/pddl.py'), Path('rcnc/pddl_checks.py')])
    files = [path for path in output.rglob('*') if path.is_file() and 'implementation' not in path.relative_to(output).parts]
    manifest = {'status': 'frozen_before_audit', 'cases': cases, 'case_count': len(cases),
        'input_sha256': {path.relative_to(output).as_posix(): digest(path) for path in files},
        'implementation_sha256': implementation, 'budget': protocol['budget'], 'scope': protocol['scope']}
    save(output / 'manifest.json', manifest)
    return manifest


def worker(root, identifier):
    manifest = json.loads((root / 'manifest.json').read_text(encoding='utf-8'))
    case = next(row for row in manifest['cases'] if row['id'] == identifier)
    worlds = [{**world, 'domain': root / world['domain'], 'problem': root / world['problem']} for world in case['worlds']]
    result = inspect_worlds(root / case['compiled'], worlds, domain_sha256=case['domain_sha256'],
        metadata_sha256=case['metadata_sha256'], max_atoms=case['max_atoms'])
    save(root / 'results' / (identifier + '.json'), result)


def execute(root):
    manifest = json.loads((root / 'manifest.json').read_text(encoding='utf-8'))
    if (root / 'results').exists() or (root / 'report.json').exists():
        raise ValueError('Use a fresh condition, not a silent rerun')
    for name, expected in manifest['input_sha256'].items():
        if digest(root / name) != expected:
            raise ValueError('Frozen input drift')
    for name, expected in manifest['implementation_sha256'].items():
        if digest(Path(name)) != expected:
            raise ValueError('Frozen implementation drift')
    budget = manifest['budget']
    deadline = datetime.fromisoformat(budget['whole_goal_stop_before_utc'].replace('Z', '+00:00'))
    if (deadline - datetime.now(timezone.utc)).total_seconds() < len(manifest['cases']) * budget['wall_seconds_per_case'] + 600:
        raise ValueError('Insufficient time for all registered cases and cleanup')
    (root / 'results').mkdir()
    (root / 'logs').mkdir()
    rows = []
    for case in manifest['cases']:
        with (root / 'logs' / (case['id'] + '.log')).open('w', encoding='utf-8') as log:
            try:
                process = subprocess.run([sys.executable, '-X', 'utf8', '-m', 'scripts.validation.validate_world_compatibility',
                    '--output', str(root), '--worker', case['id']], stdout=log, stderr=subprocess.STDOUT,
                    timeout=budget['wall_seconds_per_case'])
                path = root / 'results' / (case['id'] + '.json')
                result = json.loads(path.read_text(encoding='utf-8')) if process.returncode == 0 and path.exists() else {'status': 'worker_error', 'exit_code': process.returncode}
            except subprocess.TimeoutExpired:
                result = {'status': 'wall_time_limit', 'complete': False, 'compatible': None}
        rows.append({'id': case['id'], **result, 'expected_status': case['expected_status'],
            'control_expected_met': None if case['expected_status'] is None else result['status'] == case['expected_status']})
        save(root / 'progress.json', {'completed': len(rows), 'case_count': len(manifest['cases']), 'rows': rows})
    report = {'status': 'complete', 'case_count': len(rows), 'rows': rows,
        'status_counts': dict(Counter(row['status'] for row in rows)),
        'all_controls_expected': all(row['control_expected_met'] is not False for row in rows),
        'manifest_sha256': digest(root / 'manifest.json'),
        'inputs_unchanged': all(digest(root / name) == expected for name, expected in manifest['input_sha256'].items()),
        'implementation_unchanged': all(digest(Path(name)) == expected for name, expected in manifest['implementation_sha256'].items()),
        'facts_pooled_for_planning': False, 'solver_or_model_calls': 0, 'scope': manifest['scope']}
    save(root / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--protocol', type=Path)
    parser.add_argument('--worker')
    parser.add_argument('--prepare-only', action='store_true')
    parser.add_argument('--execute-frozen', action='store_true')
    args = parser.parse_args()
    if args.worker:
        worker(args.output, args.worker)
    else:
        if args.prepare_only and args.execute_frozen:
            parser.error('Choose preparation or execution')
        result = None if args.execute_frozen else prepare(args.protocol, args.output)
        if not args.prepare_only:
            result = execute(args.output)
        print(json.dumps({key: value for key, value in result.items() if key not in ('cases', 'rows', 'input_sha256', 'implementation_sha256')}, indent=2))

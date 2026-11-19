"""Post-hoc representation diagnosis, kept separate from primary probe outcomes."""
import argparse
from collections import Counter
import copy
import json
from pathlib import Path

from unified_planning.io import PDDLReader, PDDLWriter
from unified_planning.plans import ActionInstance, SequentialPlan
from rcnc.aligned_domain import build
from rcnc.domain_building import require_empty_output, save, snapshot_implementation
from rcnc.narrative_pipeline import map_problem
from rcnc.pddl import parse_domain, parse_sexpr, typed_symbols
from rcnc.validation import validate_artifacts
from rcnc.world_source_selection import select_component
from scripts.experiments.run_downward_reference import run as run_solver, sha


def lookup(table, name):
    return {key.lower(): value for key, value in table.items()}[name.lower()]


def provided_witness(primary, pair, domains, metadata, output):
    source = primary / 'bundle/tasks' / (pair['id'] + '__aligned_selected_sources')
    output.mkdir(parents=True)
    for name in ('domain.pddl', 'problem.pddl'):
        (output / name).write_bytes((source / name).read_bytes())
    reader = PDDLReader()
    problem = reader.parse_problem(str(output / 'domain.pddl'), str(output / 'problem.pddl'))
    instances, provenance = [], []
    for role in ('producer', 'consumer'):
        owner = pair[role]
        name = pair['selected_candidate'][role + '_action']
        source_action = domains[owner].actions[name]
        parameters = typed_symbols(source_action[source_action.index(':parameters') + 1])
        bindings = pair['construction']['bindings'][role]
        if set(parameters) != set(bindings):
            raise ValueError('Constructed witness lacks a declared parameter binding')
        action = problem.action(lookup(metadata['action_maps'][owner], name).lower())
        arguments = [problem.environment.expression_manager.ObjectExp(problem.object('q__' + bindings[variable])) for variable in parameters]
        instances.append(ActionInstance(action, tuple(arguments)))
        provenance.append({'source': owner, 'action': name, 'bindings': bindings, 'formal_order': list(parameters)})
    PDDLWriter(problem).write_plan(SequentialPlan(instances), str(output / 'plan.txt'))
    result = {'origin': 'constructed_generator_schema_instantiation_not_solver_output',
        'validation': validate_artifacts(output), 'length': len(instances), 'schemas': provenance,
        'domain_sha256': sha(output / 'domain.pddl'), 'problem_sha256': sha(output / 'problem.pddl'),
        'scope': 'Downstream reachability witness only. Does not change the primary FD outcome or source-necessity metric.'}
    save(output / 'report.json', result)
    return result


def prepare(protocol_path, output):
    require_empty_output(output)
    protocol = json.loads(protocol_path.read_text(encoding='utf-8'))
    primary = Path(protocol['primary'])
    if sha(primary / 'manifest.json') != protocol['primary_manifest_sha256']:
        raise ValueError('Primary cohort changed')
    original = json.loads((primary / 'manifest.json').read_text(encoding='utf-8'))
    for path, expected in original['input_sha256'].items():
        if sha(primary / path) != expected:
            raise ValueError('Primary frozen artifact drift')
    generation = json.loads((primary / 'generation.json').read_text(encoding='utf-8'))
    pairs = [pair for pair in generation['pairs'] if pair['status'] == 'generated']
    if len(pairs) != 6:
        raise ValueError('Expected the same six constructed primary worlds')
    output.mkdir(parents=True)
    (output / 'protocol.json').write_bytes(protocol_path.read_bytes())
    full = primary / 'models/machine'
    metadata = json.loads((full / 'meta_domain.json').read_text(encoding='utf-8'))
    full_domain = parse_domain(full / 'meta_domain.pddl')
    domains = {path.name.removesuffix('_domainfile.pddl'): parse_domain(path) for path in (primary / 'inputs').glob('*.pddl')}
    models, tasks, witnesses = {}, [], []
    for pair in pairs:
        probe = output / 'probes' / pair['id']
        probe.mkdir(parents=True)
        save(probe / 'query.json', pair['query'])
        witness = provided_witness(primary, pair, domains, metadata, probe / 'provided_witness')
        witnesses.append({'id': pair['id'], **witness})
        problem = parse_sexpr((primary / 'probes' / pair['id'] / 'machine_problem.pddl').read_text(encoding='utf-8'))
        seeds = sorted({atom[0].split(':', 1)[0] for kind in ('positive', 'negative') for atom in pair['query']['goal'].get(kind, [])})
        specification, certificate = select_component(metadata, full_domain, problem, seeds)
        save(probe / 'selection_certificate.json', certificate)
        key = '__'.join(certificate['selected_sources'])
        if key not in models:
            directory = output / 'models' / key
            inputs = directory / 'inputs'
            inputs.mkdir(parents=True)
            for source in certificate['selected_sources']:
                name = source + '_domainfile.pddl'
                (inputs / name).write_bytes((primary / 'inputs' / name).read_bytes())
            save(directory / 'alignment.json', specification)
            for condition in protocol['conditions']:
                variant = copy.deepcopy(specification)
                if condition.startswith('zero_merge'):
                    variant['predicate_groups'] = []
                build(inputs, directory / condition, variant)
            models[key] = specification
        elif models[key] != specification:
            raise ValueError('Same selected source set changed its projected specification')
        for condition in protocol['conditions']:
            model = output / 'models' / key / condition
            mapping = map_problem(pair['query'], model, probe / (condition + '_problem.pddl'))
            save(probe / (condition + '_mapping.json'), mapping)
            task_id = pair['id'] + '__' + condition
            target = output / 'bundle/tasks' / task_id
            target.mkdir(parents=True)
            (target / 'domain.pddl').write_bytes((model / 'meta_domain.pddl').read_bytes())
            (target / 'problem.pddl').write_bytes((probe / (condition + '_problem.pddl')).read_bytes())
            tasks.append({'id': task_id, 'pair_id': pair['id'], 'condition': condition,
                'source': pair['producer'] + '+' + pair['consumer'], 'representation': condition,
                'selected_sources': certificate['selected_sources'], 'model_key': key,
                'domain_sha256': sha(target / 'domain.pddl'), 'problem_sha256': sha(target / 'problem.pddl'),
                'primary_problem_sha256': sha(primary / 'bundle/tasks' / (pair['id'] + '__' + ('zero_merge_same_source_action_sets' if condition.startswith('zero_merge') else 'aligned_selected_sources')) / 'problem.pddl')})
    save(output / 'witnesses.json', {'scope': 'Constructed plans, not planner-found solutions', 'rows': witnesses})
    bundle = output / 'bundle'
    save(bundle / 'manifest.json', {'status': 'frozen_before_search', 'mode': 'matched_source_representations',
        'task_count': len(tasks), 'tasks': tasks, 'scope': 'Post-hoc representation controls on the same six generated worlds'})
    code = [Path(__file__), Path('scripts/experiments/run_downward_reference.py'), *sorted(Path('rcnc').glob('*.py'))]
    implementation = snapshot_implementation(output, code)
    files = [path for path in output.rglob('*') if path.is_file() and 'implementation' not in path.relative_to(output).parts]
    manifest = {'status': 'frozen_before_search', 'task_count': len(tasks), 'tasks': tasks, 'probe_count': len(pairs),
        'input_sha256': {path.relative_to(output).as_posix(): sha(path) for path in files},
        'implementation_sha256': implementation, 'protocol_sha256': sha(output / 'protocol.json'),
        'primary_manifest_sha256': protocol['primary_manifest_sha256'], 'budget': protocol['budget'],
        'scope': 'Post-hoc representation diagnosis; primary cohort and planner outcomes remain unchanged. Provided witnesses are a separate evidence tier.'}
    save(output / 'manifest.json', manifest)
    return manifest


def execute(output):
    manifest = json.loads((output / 'manifest.json').read_text(encoding='utf-8'))
    if (output / 'solver').exists() or (output / 'report.json').exists():
        raise ValueError('Do not rerun a diagnostic condition')
    for path, expected in manifest['input_sha256'].items():
        if sha(output / path) != expected:
            raise ValueError('Diagnostic input drift')
    for path, expected in manifest['implementation_sha256'].items():
        if sha(Path(path)) != expected:
            raise ValueError('Diagnostic implementation drift')
    solver = run_solver(Path('.'), None, output / 'solver', Path('.tmp/fast-downward-26.6'),
                        manifest['budget']['seconds_wall_and_cpu'], manifest['budget']['memory_mb'], task_bundle=output / 'bundle')
    indexed = {row['id']: row for row in solver['rows']}
    rows = [{**task, **indexed[task['id']]} for task in manifest['tasks']]
    witnesses = json.loads((output / 'witnesses.json').read_text(encoding='utf-8'))
    report = {'status': 'complete', 'task_count': len(rows), 'rows': rows,
        'status_counts': dict(Counter(row['status'] for row in rows)),
        'constructed_witness_validation_counts': dict(Counter(row['validation']['status'] for row in witnesses['rows'])),
        'manifest_sha256': sha(output / 'manifest.json'),
        'inputs_unchanged': all(sha(output / path) == expected for path, expected in manifest['input_sha256'].items()),
        'implementation_unchanged': all(sha(Path(path)) == expected for path, expected in manifest['implementation_sha256'].items()),
        'solver_integrity': all(solver[key] for key in ('binary_unchanged', 'runner_unchanged', 'implementation_unchanged', 'validator_unchanged')),
        'scope': manifest['scope']}
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--protocol', type=Path, default=Path('paper/records/protocols/composition_projection_diagnostic_2026_10_23_v1.json'))
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--prepare-only', action='store_true')
    parser.add_argument('--execute-frozen', action='store_true')
    args = parser.parse_args()
    if args.prepare_only and args.execute_frozen:
        parser.error('Choose preparation or execution')
    result = None if args.execute_frozen else prepare(args.protocol, args.output)
    if not args.prepare_only:
        result = execute(args.output)
    print(json.dumps({key: value for key, value in result.items() if key not in ('tasks', 'rows', 'input_sha256', 'implementation_sha256')}, indent=2))

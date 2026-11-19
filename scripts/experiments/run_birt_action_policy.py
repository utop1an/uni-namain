"""Frozen BIRT action-policy contrast using existing model outputs only."""
import argparse
from collections import Counter
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import shutil

from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.namespace_export import fold_symbol_map
from rcnc.pddl import section, serialize
from rcnc.source_action_variants import ast, build_variants, map_world, strict_parse
from scripts.experiments.run_downward_reference import run as run_solver


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def slots(protocol):
    result = []
    for index, source in enumerate(protocol['sources']):
        conditions = protocol['original_conditions']
        for condition in conditions[index:] + conditions[:index]:
            result.append({'id': source + '__' + condition, 'source': source, 'unit': 'original_goal',
                           'case': source, 'condition': condition})
    for index, probe in enumerate(protocol['probes']):
        conditions = protocol['probe_conditions']
        for condition in conditions[index:] + conditions[:index]:
            result.append({'id': probe['id'] + '__' + condition, 'source': 'BIRT', 'unit': 'authored_probe',
                           'case': probe['id'], 'condition': condition})
    if len(result) != protocol['budget']['maximum_solver_calls'] or len({r['id'] for r in result}) != len(result):
        raise ValueError('Registered denominator or unique IDs differs')
    return result


def prepare(protocol_path, output):
    require_empty_output(output)
    protocol = read(protocol_path)
    registry = slots(protocol)
    output.mkdir(parents=True)
    shutil.copyfile(protocol_path, output / 'protocol.json')
    parent = Path(protocol['parent'])
    for name, expected in protocol['parent_sha256'].items():
        if digest(parent / name) != expected: raise ValueError('Historical parent changed: ' + name)
        dest = output / 'parent' / name
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(parent / name, dest)
    for source, expected in protocol['prior_plan_sha256'].items():
        plan = Path(protocol['prior_diagnostic']) / 'solver/tasks' / (source + '__native') / 'plan.txt'
        if digest(plan) != expected: raise ValueError('Historical native plan changed')
        dest = output / 'native_plans' / (source + '.plan')
        dest.parent.mkdir(exist_ok=True)
        shutil.copyfile(plan, dest)
    parent = output / 'parent'
    reference = parent / 'fusion/meta_domain.pddl'
    raw_meta = read(parent / 'fusion/meta_domain.json')
    paths = {s: parent / 'inputs' / (s + '_domainfile.pddl') for s in protocol['sources']}
    models, admissions = {}, {}
    for condition, policy in [('variants_all', 'all'), ('variants_has_only', 'has_only'),
                              ('variants_no_share', 'no_share'), ('variants_without_has', 'without_has')]:
        folder = output / 'models' / condition
        try:
            meta = build_variants(reference, paths, raw_meta, policy, folder)
            models[condition] = (folder / 'planning/domain.pddl', meta)
            admissions[condition] = {'status': 'ready'}
        except Exception as exc:
            admissions[condition] = {'status': 'model_admission_failed', 'error': f'{type(exc).__name__}: {exc}'}
    for removed in protocol['sources']:
        condition = 'variants_remove_' + removed
        if 'variants_all' not in models:
            admissions[condition] = {'status': 'model_admission_failed', 'error': 'Parent variants model unavailable'}
            continue
        domain, meta = models['variants_all']
        meta = copy.deepcopy(meta)
        root = ast(domain)
        owners = meta['action_ownership']
        root = [root[0], *[p for p in root[1:] if p[0] != ':action' or owners[p[1]]['source'] != removed]]
        folder = output / 'models' / condition
        folder.mkdir(parents=True)
        dest = folder / 'domain.pddl'; dest.write_text(serialize(root) + '\n', encoding='utf-8')
        strict_parse(dest)
        meta['action_ownership'] = {a: o for a, o in owners.items() if o['source'] != removed}
        meta['removed_source'] = removed
        meta['action_count'] = len(meta['action_ownership'])
        save(folder / 'metadata.json', meta)
        models[condition] = (dest, meta); admissions[condition] = {'status': 'ready'}
    namespace = read(parent / 'fusion/planning_export/namespace_maps.json')
    rewrite_maps = {}
    for source, path in paths.items():
        original = ast(path)
        rewrite_maps[source] = {'types': {t: namespace['types'].get(t, t) for t in ['object', 'entity', 'item', 'location']},
            'objects': {n: namespace['objects'][t] for n, t in fold_symbol_map(raw_meta['constant_maps'][source]).items()},
            'predicates': {n: namespace['predicates'][t] for n, t in fold_symbol_map(raw_meta['predicate_maps'][source]).items()},
            'actions': {n: namespace['actions'][t] for n, t in fold_symbol_map(raw_meta['action_maps'][source]).items()},
            'domains': {section(original, 'domain')[1]: namespace['domains'][section(ast(reference), 'domain')[1]]}}
    models['rewrite'] = (parent / 'fusion/planning_export/domain.pddl', {'source_maps': rewrite_maps})
    admissions['rewrite'] = {'status': 'ready'}
    if 'variants_all' in models:
        model_header = [p for p in ast(models['variants_all'][0])[1:] if p[0] != ':action']
        if model_header != [p for p in ast(models['rewrite'][0])[1:] if p[0] != ':action']:
            raise ValueError('Action-policy contrast changed vocabulary or object universe')
    probes = {p['id']: p for p in protocol['probes']}
    ready = []
    for slot in registry:
        condition, source = slot['condition'], slot['source']
        directory = output / 'bundle/tasks' / slot['id']
        directory.mkdir(parents=True)
        try:
            original = parent / 'inputs' / (source + '_problemfile.pddl')
            if condition == 'native':
                shutil.copyfile(paths[source], directory / 'domain.pddl')
                shutil.copyfile(original, directory / 'problem.pddl')
                slot['model_key'] = 'native_' + source
            else:
                if admissions[condition]['status'] != 'ready': raise ValueError(admissions[condition]['error'])
                domain, meta = models[condition]
                shutil.copyfile(domain, directory / 'domain.pddl')
                mapping = meta['source_maps'][source]
                extra = []
                if slot['unit'] == 'authored_probe':
                    probe = probes[slot['case']]
                    for vocabulary_source, predicate, arguments in probe['goals']:
                        extra.append([meta['source_maps'][vocabulary_source]['predicates'][predicate],
                                      *[mapping['objects'][a] for a in arguments]])
                map_world(original, mapping, directory / 'problem.pddl', extra,
                          retain_goal=probes[slot['case']]['retain_original_goal'] if extra else True)
                if condition in ('rewrite', 'variants_all') and slot['unit'] == 'original_goal':
                    if ast(directory / 'problem.pddl') != ast(parent / 'fusion/planning_export/problems' / (source + '_problemfile.pddl')):
                        raise ValueError('Original projected world differs from historical pilot')
                slot['model_key'] = condition
            strict_parse(directory / 'domain.pddl')
            parsed = strict_parse(directory / 'domain.pddl', directory / 'problem.pddl')
            from unified_planning.shortcuts import SequentialSimulator
            with SequentialSimulator(parsed) as simulator:
                if simulator.is_goal(simulator.get_initial_state()): raise ValueError('Goal already initially true')
            slot.update(admission_status='ready', domain_sha256=digest(directory / 'domain.pddl'),
                        problem_sha256=digest(directory / 'problem.pddl'))
            ready.append({'id': slot['id'], 'source': source, 'representation': condition,
                          'domain_sha256': slot['domain_sha256'], 'problem_sha256': slot['problem_sha256']})
        except Exception as exc:
            slot.update(admission_status='admission_failed', reason=f'{type(exc).__name__}: {exc}')
    for case in [*protocol['sources'], *probes]:
        pair = [r for r in registry if r['case'] == case and r['condition'] in ('rewrite', 'variants_all')]
        if all(r['admission_status'] == 'ready' for r in pair) and len(pair) == 2:
            if pair[0]['problem_sha256'] != pair[1]['problem_sha256']:
                raise ValueError('Matched action-policy conditions have different problem bytes')
    save(output / 'model_admissions.json', admissions)
    save(output / 'bundle/manifest.json', {'status': 'frozen_before_search', 'mode': 'matched_source_representations',
          'task_count': len(ready), 'tasks': ready})
    code = [Path(__file__), Path('scripts/experiments/run_downward_reference.py'),
            Path('scripts/audit/audit_birt_action_policy.py'), *sorted(Path('rcnc').glob('*.py'))]
    implementation = snapshot_implementation(output, code)
    planner = Path('.tmp/fast-downward-26.6')
    planner_files = [planner / 'fast-downward.py', planner / 'builds/release/bin/downward',
                     *sorted((planner / 'driver').rglob('*.py')), *sorted((planner / 'src/translate').rglob('*.py'))]
    files = [p for p in output.rglob('*') if p.is_file() and 'implementation' not in p.relative_to(output).parts]
    manifest = {'status': 'frozen_before_search', 'frozen_utc': datetime.now(timezone.utc).isoformat(),
        'task_count': len(registry), 'slots': registry, 'model_admissions': admissions,
        'input_sha256': {p.relative_to(output).as_posix(): digest(p) for p in files},
        'implementation_sha256': implementation, 'planner_sha256': {p.as_posix(): digest(p) for p in planner_files},
        'budget': protocol['budget'], 'scope': protocol['outcome_boundary']}
    save(output / 'manifest.json', manifest)
    return manifest


def execute(output):
    manifest = read(output / 'manifest.json')
    if manifest['status'] != 'frozen_before_search' or (output / 'solver').exists() or (output / 'report.json').exists():
        raise ValueError('Only an unexecuted frozen matrix may run')
    for name, expected in manifest['input_sha256'].items():
        if digest(output / name) != expected: raise ValueError('Frozen input changed: ' + name)
    for inventory in ('implementation_sha256', 'planner_sha256'):
        for name, expected in manifest[inventory].items():
            if digest(Path(name)) != expected: raise ValueError('Frozen implementation changed: ' + name)
    ready = [r for r in manifest['slots'] if r['admission_status'] == 'ready']
    actual = {}
    solver = None
    if ready:
        solver = run_solver(Path('.'), None, output / 'solver', Path('.tmp/fast-downward-26.6'),
                            manifest['budget']['seconds_wall_and_cpu'], manifest['budget']['memory_mb'],
                            task_bundle=output / 'bundle')
        actual = {r['id']: r for r in solver['rows']}
    rows = [{**slot, **actual.get(slot['id'], {'status': slot['admission_status']})} for slot in manifest['slots']]
    report = {'status': 'complete', 'task_count': len(rows), 'rows': rows, 'actual_solver_calls': len(actual),
        'manifest_sha256': digest(output / 'manifest.json'), 'status_counts': dict(Counter(r['status'] for r in rows)),
        'by_unit_condition': {unit: {c: dict(Counter(r['status'] for r in rows if r['unit'] == unit and r['condition'] == c))
                             for c in sorted({r['condition'] for r in rows if r['unit'] == unit})}
                             for unit in ('original_goal', 'authored_probe')},
        'inputs_unchanged': all(digest(output / p) == h for p, h in manifest['input_sha256'].items()),
        'implementation_unchanged': all(digest(Path(p)) == h for p, h in manifest['implementation_sha256'].items()),
        'planner_unchanged': all(digest(Path(p)) == h for p, h in manifest['planner_sha256'].items()),
        'solver_integrity': all(solver.get(k) is True for k in ('binary_unchanged', 'runner_unchanged', 'implementation_unchanged', 'validator_unchanged')) if solver else True,
        'model_calls': 0, 'independent_semantic_labels': 0, 'scope': manifest['scope']}
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--protocol', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    choice = parser.add_mutually_exclusive_group(required=True)
    choice.add_argument('--prepare-only', action='store_true')
    choice.add_argument('--execute-frozen', action='store_true')
    args = parser.parse_args()
    if args.prepare_only and args.protocol is None: parser.error('--protocol required for preparation')
    result = prepare(args.protocol, args.output) if args.prepare_only else execute(args.output)
    print(json.dumps({k: v for k, v in result.items() if k in ('status', 'task_count', 'model_admissions', 'actual_solver_calls', 'by_unit_condition')}, indent=2))

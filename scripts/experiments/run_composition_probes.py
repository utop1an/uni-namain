"""Freeze and execute the preregistered model-derived composition cohort."""
import argparse
from collections import Counter
import copy
from datetime import datetime, timezone
import json
from pathlib import Path

from unified_planning.io import PDDLReader
from rcnc.aligned_domain import build
from rcnc.component_selection import restrict
from rcnc.composition_probes import generate, digest
from rcnc.domain_building import require_empty_output, save, snapshot_implementation
from rcnc.narrative_pipeline import map_problem
from rcnc.pddl import parse_domain, write_domain
from scripts.experiments.run_downward_reference import run as run_solver, sha


def retained_domain(model, sources, output):
    metadata = json.loads((model / 'meta_domain.json').read_text(encoding='utf-8'))
    domain = parse_domain(model / 'meta_domain.pddl')
    names = {name for source in sources for name in metadata['action_maps'][source].values()}
    if names - set(domain.actions):
        raise ValueError('Incomplete action ownership')
    domain.actions = {name: action for name, action in domain.actions.items() if name in names}
    write_domain(domain, output)
    return len(domain.actions)


def prepare(protocol_path, output):
    require_empty_output(output)
    protocol = json.loads(protocol_path.read_text(encoding='utf-8'))
    inputs, alignment_path = Path(protocol['source_pool']), Path(protocol['alignment'])
    alignment = json.loads(alignment_path.read_text(encoding='utf-8'))
    if len(alignment['predicate_groups']) != protocol['cohort']['all_existing_groups']:
        raise ValueError('Interface cohort changed')
    output.mkdir(parents=True)
    (output / 'protocol.json').write_bytes(protocol_path.read_bytes())
    save(output / 'alignment.json', alignment)
    snapshot = output / 'inputs'
    snapshot.mkdir()
    for path in sorted(inputs.glob('*_domainfile.pddl')):
        if alignment['source_sha256'].get(path.name) != sha(path):
            raise ValueError('Alignment/source mismatch')
        (snapshot / path.name).write_bytes(path.read_bytes())
    if len(list(snapshot.glob('*.pddl'))) != 15:
        raise ValueError('Expected the fixed15-source development pool')
    models = {}
    for name in ('machine', 'zero_merge'):
        specification = copy.deepcopy(alignment)
        if name == 'zero_merge':
            specification['predicate_groups'] = []
        model = output / 'models' / name
        validation = build(snapshot, model, specification)
        if not validation['valid']:
            raise ValueError('Full-pool model failed structural/parse gate')
        models[name] = model
    domains = {p.name.removesuffix('_domainfile.pddl'): parse_domain(p) for p in sorted(snapshot.glob('*.pddl'))}
    generated = generate(domains, alignment, protocol['cohort']['selection_seed'])
    if len(generated['pairs']) != protocol['cohort']['ordered_source_pair_conditions']:
        raise ValueError('Ordered-pair cohort changed')
    save(output / 'generation.json', generated)
    conditions, solver_tasks, pair_models = [], [], {}
    for pair in generated['pairs']:
        probe = output / 'probes' / pair['id']
        probe.mkdir(parents=True)
        status, reason = pair['status'], None
        domain_paths, problem_paths, action_counts = {}, {}, {}
        certificate = None
        if status == 'generated':
            query = pair['query']
            save(probe / 'query.json', query)
            try:
                for name, model in models.items():
                    mapping = map_problem(query, model, probe / (name + '_problem.pddl'))
                    save(probe / (name + '_mapping.json'), mapping)
                certificate = restrict(query, models['machine'], probe / 'machine_problem.pddl', probe / 'selected_domain.pddl')
                save(probe / 'selection_certificate.json', certificate)
                selected = certificate['selected_sources']
                if not {pair['producer'], pair['consumer']} <= set(selected):
                    raise ValueError('Interface selection lost a declared producer/consumer source')
                key = '__'.join(selected)
                directory = output / 'pair_models' / key
                if key not in pair_models:
                    directory.mkdir(parents=True)
                    (directory / 'machine_selected.pddl').write_bytes((probe / 'selected_domain.pddl').read_bytes())
                    retained_domain(models['zero_merge'], selected, directory / 'zero_selected.pddl')
                    for source in selected:
                        retained_domain(models['machine'], [s for s in selected if s != source],
                                        directory / ('remove_' + source + '.pddl'))
                    pair_models[key] = {'sources': selected, 'probes': []}
                elif (directory / 'machine_selected.pddl').read_bytes() != (probe / 'selected_domain.pddl').read_bytes():
                    raise ValueError('Same selected sources yielded a different parameterized model')
                pair_models[key]['probes'].append(pair['id'])
                domain_paths = {'aligned_selected_sources': directory / 'machine_selected.pddl',
                    'zero_merge_same_source_action_sets': directory / 'zero_selected.pddl',
                    'aligned_remove_producer_actions': directory / ('remove_' + pair['producer'] + '.pddl'),
                    'aligned_remove_consumer_actions': directory / ('remove_' + pair['consumer'] + '.pddl')}
                for condition, path in domain_paths.items():
                    problem_paths[condition] = probe / ('zero_merge_problem.pddl' if condition.startswith('zero_merge') else 'machine_problem.pddl')
                    PDDLReader().parse_problem(str(path), str(problem_paths[condition]))
                    action_counts[condition] = len(parse_domain(path).actions)
                if action_counts['aligned_selected_sources'] != action_counts['zero_merge_same_source_action_sets']:
                    raise ValueError('Zero-merge control changed source action eligibility')
            except Exception as exc:
                status, reason = 'admission_failed', f'{type(exc).__name__}: {exc}'
        for condition in protocol['conditions']:
            task_id = pair['id'] + '__' + condition
            record = {'id': task_id, 'pair_id': pair['id'], 'group': pair['group'],
                'producer': pair['producer'], 'consumer': pair['consumer'], 'condition': condition,
                'admission_status': 'ready' if status == 'generated' else status,
                'reason': reason, 'query_sha256': digest(pair['query']) if pair['query'] is not None else None}
            if status == 'generated':
                target = output / 'bundle/tasks' / task_id
                target.mkdir(parents=True)
                (target / 'domain.pddl').write_bytes(domain_paths[condition].read_bytes())
                (target / 'problem.pddl').write_bytes(problem_paths[condition].read_bytes())
                record.update(domain_sha256=sha(target / 'domain.pddl'), problem_sha256=sha(target / 'problem.pddl'),
                    selected_sources=certificate['selected_sources'], action_count=action_counts[condition],
                    parameterized_model_key='__'.join(certificate['selected_sources']))
                solver_tasks.append({'id': task_id, 'source': pair['producer'] + '+' + pair['consumer'],
                    'representation': condition, 'domain_sha256': record['domain_sha256'],
                    'problem_sha256': record['problem_sha256']})
            conditions.append(record)
    if len(conditions) != protocol['budget']['max_conditions']:
        raise ValueError('Incomplete preregistered condition registry')
    save(output / 'pair_models.json', pair_models)
    bundle = output / 'bundle'
    bundle.mkdir(exist_ok=True)
    save(bundle / 'manifest.json', {'status': 'frozen_before_search', 'mode': 'matched_source_representations',
        'task_count': len(solver_tasks), 'tasks': solver_tasks, 'registered_condition_count': len(conditions),
        'scope': f'Executable subset of the complete{len(conditions)}-condition registry; failed admissions retained separately'})
    code = [Path(__file__), Path('scripts/experiments/run_downward_reference.py'), *sorted(Path('rcnc').glob('*.py'))]
    implementation = snapshot_implementation(output, code)
    files = [path for path in output.rglob('*') if path.is_file() and 'implementation' not in path.relative_to(output).parts]
    manifest = {'status': 'frozen_before_search', 'task_count': len(conditions), 'conditions': conditions,
        'ordered_pair_count': len(generated['pairs']), 'generated_probe_count': sum(pair['status'] == 'generated' for pair in generated['pairs']),
        'admission_counts': dict(Counter(row['admission_status'] for row in conditions)),
        'candidate_count': len(generated['candidates']),
        'candidate_counts': dict(Counter(row['status'] for row in generated['candidates'])),
        'input_sha256': {path.relative_to(output).as_posix(): sha(path) for path in files},
        'implementation_sha256': implementation, 'protocol_sha256': sha(output / 'protocol.json'),
        'budget': protocol['budget'], 'scope': generated['scope'], 'source_problem_facts_imported': False}
    save(output / 'manifest.json', manifest)
    return manifest


def execute(output):
    manifest = json.loads((output / 'manifest.json').read_text(encoding='utf-8'))
    if manifest['status'] != 'frozen_before_search' or (output / 'solver').exists() or (output / 'report.json').exists():
        raise ValueError('Only an unexecuted frozen registry may run')
    for path, expected in manifest['input_sha256'].items():
        if sha(output / path) != expected:
            raise ValueError('Frozen input changed before search')
    for path, expected in manifest['implementation_sha256'].items():
        if sha(Path(path)) != expected:
            raise ValueError('Implementation changed after freeze')
    deadline = datetime.fromisoformat(manifest['budget']['whole_goal_stop_before_utc'].replace('Z', '+00:00'))
    # Reserve the entire registered search budget plus supervision/startup time
    # before admission; never partially execute a late matrix invisibly.
    executable = sum(row['admission_status'] == 'ready' for row in manifest['conditions'])
    if (deadline - datetime.now(timezone.utc)).total_seconds() < executable * (20 + 45) + 600:
        raise ValueError('Not enough overall goal time for the frozen matrix and cleanup')
    solver_report = None
    if executable:
        solver_report = run_solver(Path('.'), None, output / 'solver', Path('.tmp/fast-downward-26.6'),
            manifest['budget']['seconds_per_search_wall_and_cpu'], manifest['budget']['memory_mb'],
            task_bundle=output / 'bundle')
    indexed = {row['id']: row for row in solver_report['rows']} if solver_report else {}
    rows = []
    for condition in manifest['conditions']:
        row = dict(condition)
        if condition['admission_status'] != 'ready':
            row['status'] = condition['admission_status']
        else:
            outcome = indexed[condition['id']]
            row.update(status=outcome['status'], validation=outcome.get('validation'),
                plan_length=outcome.get('plan_length'), elapsed_seconds=outcome['elapsed_seconds'],
                engine_status=outcome.get('engine_status'), exit_code=outcome.get('exit_code'))
        rows.append(row)
    report = {'status': 'complete', 'task_count': len(rows), 'rows': rows,
        'actual_solver_calls': executable, 'manifest_sha256': sha(output / 'manifest.json'),
        'status_counts': dict(Counter(row['status'] for row in rows)),
        'inputs_unchanged': all(sha(output / path) == expected for path, expected in manifest['input_sha256'].items()),
        'implementation_unchanged': all(sha(Path(path)) == expected for path, expected in manifest['implementation_sha256'].items()),
        'solver_integrity': all(solver_report[key] for key in ('binary_unchanged', 'runner_unchanged', 'implementation_unchanged', 'validator_unchanged')) if solver_report else True,
        'scope': manifest['scope']}
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--protocol', type=Path, default=Path('paper/records/protocols/composition_probe_protocol_2026_10_23_v1.json'))
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--prepare-only', action='store_true')
    parser.add_argument('--execute-frozen', action='store_true')
    args = parser.parse_args()
    if args.prepare_only and args.execute_frozen:
        parser.error('Choose preparation or execution')
    result = None if args.execute_frozen else prepare(args.protocol, args.output)
    if not args.prepare_only:
        result = execute(args.output)
    print(json.dumps({key: value for key, value in result.items() if key not in ('conditions', 'rows', 'input_sha256', 'implementation_sha256')}, indent=2))

"""Fresh fixed-model source-world comparison with one failed-construction tier."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path

from rcnc.component_selection import restrict
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.narrative_pipeline import map_problem
from scripts.experiments.run_downward_reference import run as run_solver
from scripts.experiments.run_original_world_pipeline import convert_problem


def prepare(protocol_path, output):
    require_empty_output(output)
    protocol = json.loads(protocol_path.read_text(encoding='utf-8'))
    source = Path(protocol['source_root'])
    if not all(digest(source / name) == expected for name, expected in protocol['source_file_sha256'].items()):
        raise ValueError('Source drift')
    reference = Path(protocol['reference_report'])
    if digest(reference) != protocol['reference_report_sha256']:
        raise ValueError('Reference outcome drift')
    ref = json.loads(reference.read_text(encoding='utf-8'))
    if ref['status'] != 'time_limit' or ref['source_snapshot_unchanged'] is not True or ref['implementation_unchanged'] is not True:
        raise ValueError('Expected the inspected failed fresh-construction condition')
    output.mkdir(parents=True)
    (output / 'protocol.json').write_bytes(protocol_path.read_bytes())
    (output / 'reference_report.json').write_bytes(reference.read_bytes())
    inputs = output / 'inputs'
    inputs.mkdir()
    for name in protocol['source_file_sha256']:
        (inputs / name).write_bytes((source / name).read_bytes())
    models = {}
    for model in protocol['models']:
        origin = Path(model['path'])
        if digest(origin / 'meta_domain.pddl') != model['domain_sha256'] or digest(origin / 'meta_domain.json') != model['metadata_sha256']:
            raise ValueError('Fixed model or metadata drift')
        target = output / 'models' / model['id']
        target.mkdir(parents=True)
        for name in ('meta_domain.pddl', 'meta_domain.json'):
            (target / name).write_bytes((origin / name).read_bytes())
        models[model['id']] = target
    sources = sorted(path.name.removesuffix('_domainfile.pddl') for path in inputs.glob('*_domainfile.pddl'))
    if len(sources) != 15:
        raise ValueError('Expected every original source world')
    conditions, tasks = [], []
    for source_name in sources:
        domain, problem = inputs / (source_name + '_domainfile.pddl'), inputs / (source_name + '_problemfile.pddl')
        query = convert_problem(source_name, domain, problem)
        for condition in protocol['conditions']:
            identifier = source_name + '__' + condition
            row = {'id': identifier, 'source': source_name, 'condition': condition, 'representation': condition,
                'admission_status': 'ready', 'model': None}
            if condition == 'fresh_reference_model_unavailable':
                row.update(admission_status='fresh_reference_construction_time_limit',
                    shared_construction_report_sha256=protocol['reference_report_sha256'])
                conditions.append(row)
                continue
            target = output / 'bundle/tasks' / identifier
            target.mkdir(parents=True)
            save(target / 'query.json', query)
            if condition == 'native_source':
                (target / 'domain.pddl').write_bytes(domain.read_bytes())
                (target / 'problem.pddl').write_bytes(problem.read_bytes())
            else:
                model_id = 'zero_merge' if condition.startswith('zero_merge_') else 'machine'
                compiled = models[model_id]
                row['model'] = model_id
                mapping = map_problem(query, compiled, target / 'problem.pddl')
                save(target / 'query_mapping.json', mapping)
                if condition.endswith('_components'):
                    certificate = restrict({**query, 'selection': 'static_universe_components'}, compiled,
                        target / 'problem.pddl', target / 'domain.pddl')
                    save(target / 'selection_certificate.json', certificate)
                    row['selected_sources'] = certificate['selected_sources']
                else:
                    (target / 'domain.pddl').write_bytes((compiled / 'meta_domain.pddl').read_bytes())
            row.update(domain_sha256=digest(target / 'domain.pddl'), problem_sha256=digest(target / 'problem.pddl'))
            conditions.append(row)
            tasks.append(row)
    if len(conditions) != 90 or len(tasks) != 75 or len({row['id'] for row in conditions}) != 90:
        raise ValueError('Incomplete90-slot/75-search registry')
    save(output / 'bundle/manifest.json', {'status': 'frozen_before_search', 'mode': 'matched_source_representations',
        'tasks': tasks, 'task_count': len(tasks)})
    implementation = snapshot_implementation(output, [Path(__file__), Path('scripts/experiments/run_downward_reference.py'),
        Path('scripts/experiments/run_original_world_pipeline.py'), Path('rcnc/validation.py'),
        Path('rcnc/domain_building.py'), Path('rcnc/component_selection.py'), Path('rcnc/world_source_selection.py'),
        Path('rcnc/narrative_pipeline.py'), Path('rcnc/aligned_domain.py'), Path('rcnc/domain_union.py'),
        Path('rcnc/pddl.py'), Path('rcnc/pddl_checks.py')])
    files = [path for path in output.rglob('*') if path.is_file() and 'implementation' not in path.relative_to(output).parts]
    manifest = {'status': 'frozen_before_search', 'conditions': conditions, 'task_count': len(conditions),
        'actual_solver_calls': len(tasks), 'world_count': 15, 'budget': protocol['budget'],
        'input_sha256': {path.relative_to(output).as_posix(): digest(path) for path in files},
        'implementation_sha256': implementation,
        'scope': protocol['scope'], 'reference_construction_failures': 1,
        'reference_downstream_unavailable_slots': 15}
    save(output / 'manifest.json', manifest)
    return manifest


def execute(output):
    manifest = json.loads((output / 'manifest.json').read_text(encoding='utf-8'))
    if (output / 'solver').exists() or (output / 'report.json').exists():
        raise ValueError('No silent rerun')
    if not all(digest(output / path) == expected for path, expected in manifest['input_sha256'].items()):
        raise ValueError('Frozen input drift')
    if not all(digest(Path(path)) == expected for path, expected in manifest['implementation_sha256'].items()):
        raise ValueError('Frozen implementation drift')
    budget = manifest['budget']
    deadline = datetime.fromisoformat(budget['whole_goal_stop_before_utc'].replace('Z', '+00:00'))
    if (deadline - datetime.now(timezone.utc)).total_seconds() < manifest['actual_solver_calls'] * (budget['seconds_wall_and_cpu'] + 45) + 600:
        raise ValueError('Insufficient time for complete matrix and cleanup')
    solved = run_solver(Path('.'), None, output / 'solver', Path('.tmp/fast-downward-26.6'),
        budget['seconds_wall_and_cpu'], budget['memory_mb'], task_bundle=output / 'bundle')
    indexed = {row['id']: row for row in solved['rows']}
    rows = []
    for condition in manifest['conditions']:
        row = dict(condition)
        if row['admission_status'] != 'ready':
            row['status'] = row['admission_status']
        else:
            outcome = indexed[row['id']]
            row.update(status=outcome['status'], validation=outcome.get('validation'),
                plan_length=outcome.get('plan_length'), elapsed_seconds=outcome['elapsed_seconds'],
                engine_status=outcome.get('engine_status'), exit_code=outcome.get('exit_code'))
        rows.append(row)
    report = {'status': 'complete', 'task_count': len(rows), 'world_count': manifest['world_count'],
        'actual_solver_calls': manifest['actual_solver_calls'], 'rows': rows,
        'status_counts': dict(Counter(row['status'] for row in rows)),
        'by_condition': {condition: dict(Counter(row['status'] for row in rows if row['condition'] == condition))
            for condition in dict.fromkeys(row['condition'] for row in rows)},
        'reference_construction_failures': 1, 'reference_downstream_unavailable_slots': 15,
        'manifest_sha256': digest(output / 'manifest.json'),
        'inputs_unchanged': all(digest(output / path) == expected for path, expected in manifest['input_sha256'].items()),
        'implementation_unchanged': all(digest(Path(path)) == expected for path, expected in manifest['implementation_sha256'].items()),
        'solver_integrity': all(solved[key] for key in ('binary_unchanged', 'runner_unchanged', 'implementation_unchanged', 'validator_unchanged')),
        'scope': manifest['scope']}
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--protocol', type=Path)
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

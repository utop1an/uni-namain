"""Audit matched worlds, whole-source actions and native inverse plan replays."""
import argparse
from collections import Counter
import json
from pathlib import Path

from rcnc.domain_building import archived_implementation, digest, require_empty_output, save, snapshot_implementation
from rcnc.pddl import parse_domain, parse_sexpr
from rcnc.validation import validate_artifacts
from scripts.audit.audit_original_world_pipeline import check_world, native_transport
from scripts.evidence.build_meeting_results import phase


def audit(root, output):
    require_empty_output(output)
    read = lambda path: json.loads(path.read_text(encoding='utf-8'))
    manifest, report = read(root / 'manifest.json'), read(root / 'report.json')
    if report['status'] != 'complete' or report['manifest_sha256'] != digest(root / 'manifest.json'):
        raise ValueError('Complete unchanged comparison required')
    if any(report.get(key) is not True for key in ('inputs_unchanged', 'implementation_unchanged', 'solver_integrity')):
        raise ValueError('Execution integrity failure')
    for path, expected in manifest['input_sha256'].items():
        if digest(root / path) != expected:
            raise ValueError('Frozen input drift')
    for path, expected in manifest['implementation_sha256'].items():
        if digest(archived_implementation(root, path)) != expected:
            raise ValueError('Missing exact archived implementation')
    tasks = {row['id']: row for row in manifest['conditions']}
    rows = {row['id']: row for row in report['rows']}
    if len(tasks) != 90 or len(rows) != 90 or len(manifest['conditions']) != 90 or len(report['rows']) != 90 or set(tasks) != set(rows):
        raise ValueError('Incomplete or duplicate90-slot denominator')
    solver, solver_manifest = read(root / 'solver/report.json'), read(root / 'solver/manifest.json')
    actual = {row['id']: row for row in solver['rows']}
    ready = {identifier for identifier, row in tasks.items() if row['admission_status'] == 'ready'}
    if len(ready) != 75 or set(actual) != ready or len(solver['rows']) != 75:
        raise ValueError('Incorrect75-call execution denominator')
    if solver['manifest_sha256'] != digest(root / 'solver/manifest.json') or solver_manifest['budget'] != {
            'wall_seconds': 20, 'overall_cpu_seconds': 20, 'memory_mb': 4096}:
        raise ValueError('Solver manifest or registered budget mismatch')
    if dict(Counter(row['status'] for row in rows.values())) != report['status_counts']:
        raise ValueError('Summary counts mismatch')
    reference = read(root / 'reference_report.json')
    if reference['status'] != 'time_limit' or manifest['reference_construction_failures'] != 1:
        raise ValueError('Keep the single construction failure separate')
    metadata = {name: read(root / 'models' / name / 'meta_domain.json') for name in ('zero_merge', 'machine')}
    models = {name: parse_domain(root / 'models' / name / 'meta_domain.pddl') for name in metadata}
    domains = {path.name.removesuffix('_domainfile.pddl'): parse_domain(path) for path in (root / 'inputs').glob('*_domainfile.pddl')}
    checked, failures = [], []
    output.mkdir(parents=True)
    for identifier, task in tasks.items():
        row = dict(rows[identifier])
        source = task['source']
        if task['admission_status'] != 'ready':
            if row['status'] != 'fresh_reference_construction_time_limit' or identifier in actual:
                raise ValueError('Unavailable model was promoted to a planning result')
            if digest(root / 'reference_report.json') != row['shared_construction_report_sha256']:
                raise ValueError('Unlinked construction failure')
            row.update(world_checks={'not_run_construction_failure': True}, native_replay={'status': 'not_run_construction_failure'})
            checked.append(row)
            continue
        directory = root / 'solver/tasks' / identifier
        frozen = root / 'bundle/tasks' / identifier
        for name in ('domain', 'problem'):
            if any(digest(path) != task[name + '_sha256'] for path in (directory / (name + '.pddl'), frozen / (name + '.pddl'))):
                raise ValueError('Actual solver task drift')
        if row['status'] != actual[identifier]['status']:
            raise ValueError('Aggregate/solver outcome disagreement')
        row['phase'] = phase(directory)
        row['native_replay'] = {'status': 'no_plan'}
        if task['condition'] == 'native_source':
            row['world_checks'] = {name + '_exact': (directory / (name + '.pddl')).read_bytes() ==
                (root / 'inputs' / (source + suffix)).read_bytes() for name, suffix in (
                    ('domain', '_domainfile.pddl'), ('problem', '_problemfile.pddl'))}
            row['whole_source_actions_preserved'] = True
        else:
            name = task['model']
            mapping = read(frozen / 'query_mapping.json')
            row['world_checks'] = check_world(source,
                parse_sexpr((root / 'inputs' / (source + '_problemfile.pddl')).read_text(encoding='utf-8')),
                domains, metadata[name], parse_sexpr((directory / 'problem.pddl').read_text(encoding='utf-8')), mapping)
            parsed = parse_domain(directory / 'domain.pddl')
            if task['condition'].endswith('_components'):
                certificate = read(frozen / 'selection_certificate.json')
                keep = {target for owner in certificate['selected_sources'] for target in metadata[name]['action_maps'][owner].values()}
                row['whole_source_actions_preserved'] = set(parsed.actions) == keep and all(
                    parsed.actions[action] == models[name].actions[action] for action in keep)
                row['non_action_declarations_preserved'] = all(getattr(parsed, field) == getattr(models[name], field)
                    for field in ('types', 'constants', 'predicates', 'requirements'))
                partner = root / 'bundle/tasks' / (source + '__' + ('zero_merge_all' if name == 'zero_merge' else 'machine_all'))
                row['paired_problem_bytes_equal'] = (directory / 'problem.pddl').read_bytes() == (partner / 'problem.pddl').read_bytes()
            else:
                row['whole_source_actions_preserved'] = (directory / 'domain.pddl').read_bytes() == (root / 'models' / name / 'meta_domain.pddl').read_bytes()
        if row['status'] == 'solved':
            row['fresh_validation'] = validate_artifacts(directory)
            if task['condition'] == 'native_source':
                row['native_replay'] = {'status': 'native_plan_valid' if row['fresh_validation']['status'] == 'VALID' else 'invalid'}
            else:
                view = output / 'views' / identifier / 'planning'
                view.mkdir(parents=True)
                for filename in ('domain.pddl', 'problem.pddl', 'plan.txt'):
                    (view / filename).write_bytes((directory / filename).read_bytes())
                row['native_replay'] = native_transport(source, root / 'inputs', view.parent,
                    metadata[task['model']], read(frozen / 'query_mapping.json'), output / 'native_replays' / identifier)
        flags = [value for key, value in row['world_checks'].items() if type(value) is bool]
        valid = all(flags) and row['whole_source_actions_preserved']
        valid = valid and row.get('non_action_declarations_preserved', True) and row.get('paired_problem_bytes_equal', True)
        if row['status'] == 'solved':
            valid = valid and row['fresh_validation']['status'] == 'VALID' and row['native_replay']['status'] not in ('invalid', 'ERROR')
        if not valid:
            failures.append(identifier)
        checked.append(row)
    implementation = snapshot_implementation(output, [Path(__file__), Path('scripts/audit/audit_original_world_pipeline.py'),
        Path('scripts/evidence/build_meeting_results.py'), Path('rcnc/validation.py'), Path('rcnc/pddl.py'), Path('rcnc/domain_building.py')])
    result = {'status': 'verified_matched_source_worlds' if not failures else 'audited_with_violations',
        'task_count': len(checked), 'world_count': 15, 'actual_solver_calls': 75, 'rows': checked,
        'status_counts': dict(Counter(row['status'] for row in checked)),
        'by_condition': {name: dict(Counter(row['status'] for row in checked if row['condition'] == name))
            for name in dict.fromkeys(row['condition'] for row in checked)},
        'native_replay_counts': dict(Counter(row['native_replay']['status'] for row in checked)),
        'reference_construction_failures': 1, 'reference_downstream_unavailable_slots': 15,
        'audit_failures': failures, 'hashes_unchanged': True,
        'report_sha256': digest(root / 'report.json'), 'manifest_sha256': digest(root / 'manifest.json'),
        'implementation_sha256': implementation, 'scope': manifest['scope']}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = audit(args.root, args.output)
    print(json.dumps({key: value for key, value in result.items() if key not in ('rows', 'implementation_sha256')}, indent=2))

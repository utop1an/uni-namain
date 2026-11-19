"""Check the complete post-hoc registry and independently replay found plans."""
import argparse
from collections import Counter
import json
from pathlib import Path

from rcnc.domain_building import archived_implementation, require_empty_output, save, snapshot_implementation
from rcnc.validation import validate_artifacts
from scripts.experiments.run_downward_reference import sha


def audit(root, output):
    require_empty_output(output)
    read = lambda path: json.loads(path.read_text(encoding='utf-8'))
    manifest, report, protocol = (read(root / name) for name in ('manifest.json', 'report.json', 'protocol.json'))
    if report['status'] != 'complete' or report['manifest_sha256'] != sha(root / 'manifest.json'):
        raise ValueError('Complete unchanged run required')
    if manifest['protocol_sha256'] != sha(root / 'protocol.json') or manifest['budget'] != protocol['budget']:
        raise ValueError('Protocol or budget drift')
    if any(report.get(key) is not True for key in ('inputs_unchanged', 'implementation_unchanged')):
        raise ValueError('Execution integrity failure')
    for path, expected in manifest['implementation_sha256'].items():
        if sha(archived_implementation(root, path)) != expected:
            raise ValueError('Missing exact archived implementation')
    expected = {}
    for cohort in protocol['cohorts']:
        origin = Path(cohort['path'])
        if sha(origin / 'manifest.json') != cohort['manifest_sha256']:
            raise ValueError('Predecessor manifest drift')
        predecessor = read(origin / 'manifest.json')
        for task in predecessor.get('conditions', predecessor.get('tasks')):
            if task['condition'] in cohort['conditions'] and task.get('admission_status', 'ready') == 'ready':
                expected[cohort['name'] + '__' + task['id']] = (origin, task)
    tasks = {row['id']: row for row in manifest['tasks']}
    rows = {row['id']: row for row in report['rows']}
    if len(expected) != 24 or len(tasks) != len(manifest['tasks']) or len(rows) != len(report['rows']) or set(expected) != set(tasks) or set(tasks) != set(rows):
        raise ValueError('Incomplete or duplicate24-slot denominator')
    if report['task_count'] != 24 or dict(Counter(row['status'] for row in rows.values())) != report['status_counts']:
        raise ValueError('Summary denominator mismatch')
    checked, failures = [], []
    for identifier, row in rows.items():
        original, predecessor = expected[identifier]
        source, actual = root / 'tasks' / identifier, root / 'searches' / identifier
        if row['pair_id'] != predecessor['pair_id'] or row['condition'] != predecessor['condition']:
            raise ValueError('Registry identity drift')
        for name in ('domain', 'problem'):
            expected_hash = predecessor[name + '_sha256']
            if any(sha(path) != expected_hash for path in
                (source / (name + '.pddl'), original / 'bundle/tasks' / predecessor['id'] / (name + '.pddl'))):
                raise ValueError('Predecessor exact input changed')
            if tasks[identifier][name + '_sha256'] != expected_hash or row[name + '_sha256'] != expected_hash:
                raise ValueError('Registry input hash mismatch')
            # A process can time out before parsing/copying; preserve that boundary.
            if (actual / (name + '.pddl')).exists() and sha(actual / (name + '.pddl')) != expected_hash:
                raise ValueError('Actual solver input mismatch')
        result = dict(row)
        result['stage_observation'] = ('search_progress_recorded' if (actual / 'progress.json').exists()
            else 'no_search_progress_recorded')
        result['fresh_validation'] = {'status': 'NO_PLAN'}
        if row['status'] == 'solved':
            result['fresh_validation'] = validate_artifacts(actual)
            if result['fresh_validation']['status'] != 'VALID':
                failures.append(identifier)
            if read(actual / 'search.json')['status'] != 'solved':
                raise ValueError('Worker/report disagreement')
        checked.append(result)
    implementation = snapshot_implementation(output, [Path(__file__), Path('rcnc/domain_building.py'), Path('rcnc/validation.py')])
    result = {'status': 'verified_state_projection_diagnostic' if not failures else 'audited_with_violations',
        'task_count': len(checked), 'probe_count': len({row['pair_id'] for row in checked}), 'rows': checked,
        'status_counts': dict(Counter(row['status'] for row in checked)),
        'validation_counts': dict(Counter(row['fresh_validation']['status'] for row in checked)),
        'audit_failures': failures, 'hashes_unchanged': True, 'primary_outcomes_replaced': False,
        'report_sha256': sha(root / 'report.json'), 'manifest_sha256': sha(root / 'manifest.json'),
        'implementation_sha256': implementation, 'scope': manifest['scope']}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    report = audit(args.root, args.output)
    print(json.dumps({k: v for k, v in report.items() if k not in ('rows', 'implementation_sha256')}, indent=2))

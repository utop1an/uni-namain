"""Audit end-to-end solver integration while preserving all six prior limits."""
import argparse
from collections import Counter
import json
from pathlib import Path

from rcnc.domain_building import require_empty_output, save, archived_implementation, planning_domain_path
from rcnc.validation import validate_artifacts
from scripts.experiments.run_downward_reference import sha


def audit(before, after, output):
    require_empty_output(output)
    read = lambda path: json.loads(path.read_text(encoding='utf-8'))
    reports, protocols = [], []
    for root in (before, after):
        protocol, report = read(root / 'frozen_queries.json'), read(root / 'report.json')
        if (report['status'] != 'complete' or report['task_count'] != 6 or len(report['rows']) != 6
                or report['frozen_queries_sha256'] != sha(root / 'frozen_queries.json')):
            raise ValueError('Complete six-condition API run required')
        if not all(report[k] is True for k in ('sources_unchanged', 'implementation_unchanged', 'frozen_queries_unchanged')):
            raise ValueError('Runtime integrity failure')
        for path, digest in protocol['implementation_sha256'].items():
            if sha(archived_implementation(root, path)) != digest:
                raise ValueError('Saved code drift: ' + path)
        for path, digest in protocol['source_sha256'].items():
            if sha(root / 'inputs' / path) != digest:
                raise ValueError('Saved source drift')
        if dict(Counter(r['status'] for r in report['rows'])) != report['status_counts']:
            raise ValueError('Outcome count drift')
        reports.append(report)
        protocols.append(protocol)
    indexes = [{r['id']: r for r in report['rows']} for report in reports]
    tasks = [{t['id']: t for t in protocol['tasks']} for protocol in protocols]
    if any(len(table) != 6 for table in (*indexes, *tasks)) or not all(set(table) == set(tasks[0]) for table in (*indexes, *tasks)):
        raise ValueError('Missing or duplicate API conditions')
    rows = []
    for task_id in tasks[0]:
        query_before, query_after = [dict(table[task_id]['query']) for table in tasks]
        for query in (query_before, query_after):
            query.pop('solver', None)
            query.pop('memory_mb', None)
            query.pop('planner', None)
        if query_before != query_after:
            raise ValueError('Explicit request changed beyond solver configuration')
        left, right = (table[task_id] for table in indexes)
        if any(left[k] != right[k] for k in ('domain_sha256', 'problem_sha256')):
            raise ValueError('Solver comparison changed exported model/world')
        for root, row, task_index in zip((before, after), (left, right), tasks):
            run = root / 'runs' / task_id
            manifest = read(run / 'manifest.json')
            if read(run / 'query.json') != task_index[task_id]['query']:
                raise ValueError('Executed query drift')
            if sha(planning_domain_path(run, manifest)) != row['domain_sha256'] or sha(run / 'mapped_problem.pddl') != row['problem_sha256']:
                raise ValueError('Executed artifact drift')
            result = read(run / 'result.json')
            if result['status'] != row['status'] or row['domain_unchanged'] is not True:
                raise ValueError('Terminal API status mismatch')
            if row['status'] == 'solved' and validate_artifacts(run / 'planning')['status'] != 'VALID':
                raise ValueError('API plan fails independent validation')
        rows.append({'id': task_id, 'before_status': left['status'], 'status': right['status'],
            'plan_length': right['plan_length'], 'domain_sha256': right['domain_sha256'],
            'problem_sha256': right['problem_sha256']})
    result = {'status': 'verified_solver_integration', 'task_count': 6, 'rows': rows,
        'before_counts': reports[0]['status_counts'], 'status_counts': reports[1]['status_counts'],
        'hashes_unchanged': True, 'explicit_worlds_and_domains_identical': True,
        'before_report_sha256': sha(before / 'report.json'), 'after_report_sha256': sha(after / 'report.json'),
        'auditor_sha256': sha(Path(__file__)),
        'budget_boundary': 'Both search limits are 20 seconds. Pyperplan has a process wall limit; FD also has 4096MB/CPU limits and a separate supervisor grace. Not identical memory or supervision policies; no timing significance claim.',
        'scope': 'Six known authored request conditions, API/backend integration evidence only; no independent semantic or narrative evaluation'}
    output.mkdir(parents=True)
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--before', type=Path, required=True)
    parser.add_argument('--after', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    report = audit(args.before, args.after, args.output)
    print(json.dumps({k: v for k, v in report.items() if k != 'rows'}, indent=2))

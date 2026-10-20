"""Compare completed solver runs only after verifying identical exported PDDL."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
from rcnc.validation import validate_artifacts


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def compare(composed, downward, output):
    if output.exists():
        raise ValueError('Use a new report file')
    first, second = read(composed/'report.json'), read(downward/'report.json')
    if first['status'] != 'complete' or second['status'] != 'complete':
        raise ValueError('Both runs must be complete')
    frozen, native = read(composed/'frozen_tasks.json'), read(downward/'manifest.json')
    errors = []
    if sha(composed/'frozen_tasks.json') != first['frozen_tasks_sha256'] or sha(downward/'manifest.json') != second['manifest_sha256']:
        errors.append('manifest_hash_mismatch')
    ids = {task['id'] for task in frozen['tasks']}
    for values in (first['rows'], second['rows'], native['tasks']):
        if len(values) != len(ids) or {row['id'] for row in values} != ids:
            errors.append('condition_denominator_mismatch')
    if errors:
        raise ValueError('; '.join(errors))
    a, b = {r['id']: r for r in first['rows']}, {r['id']: r for r in second['rows']}
    copied = {r['id']: r for r in native['tasks']}
    rows = []
    for task in frozen['tasks']:
        key = task['id']
        original = composed/'runs'/key
        new = downward/'tasks'/key
        source_manifest = read(original/'manifest.json')
        problems = [(original/'union/meta_domain.pddl', new/'domain.pddl', 'domain_sha256'),
                    (original/'mapped_problem.pddl', new/'problem.pddl', 'problem_sha256')]
        failures = []
        for source, target, field in problems:
            if source.read_bytes() != target.read_bytes() or sha(source) != source_manifest[field] or sha(target) != copied[key][field]:
                failures.append('different_or_changed_export:'+field)
        if source_manifest['budget']['seconds'] != native['budget']['wall_seconds']:
            failures.append('different_wall_time_budget')
        row = {k: task[k] for k in ('id', 'world', 'method', 'policy')}
        row.update(pyperplan_status=a[key]['status'], downward_status=b[key]['status'])
        if b[key]['status'] == 'solved':
            row['fresh_validation'] = validate_artifacts(new)
            row['plan_length'] = b[key]['plan_length']
            if row['fresh_validation']['status'] != 'VALID':
                failures.append('fresh_validation_failed')
        elif b[key]['status'] == 'unsolvable' and b[key]['exit_code'] not in (10, 11):
            failures.append('unsupported_unsolvable_classification')
        row['audit_errors'] = failures
        errors.extend(key+':'+e for e in failures)
        rows.append(row)
    result = {'status': 'PASS' if not errors else 'FAIL', 'errors': errors, 'total': len(rows),
        'pyperplan_counts': dict(Counter(r['pyperplan_status'] for r in rows)),
        'downward_counts': dict(Counter(r['downward_status'] for r in rows)),
        'freshly_validated_downward_plans': sum(r.get('fresh_validation', {}).get('status') == 'VALID' for r in rows),
        'rows': rows, 'scope': 'Identical exported problems under two solver configurations',
        'limits': ['Both use 60-second wall budgets in this run; Fast Downward additionally has a 4 GiB limit',
                   'Concurrent workstation workloads; no controlled runtime-speed claim',
                   'Authored development worlds/interfaces; no independent semantic or narrative-quality conclusion'],
        'implementation_sha256': sha(Path(__file__))}
    output.write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--composed', type=Path, required=True)
    parser.add_argument('--downward', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = compare(args.composed, args.downward, args.output)
    print(json.dumps({k: v for k, v in result.items() if k != 'rows'}, indent=2))
    raise SystemExit(0 if result['status'] == 'PASS' else 1)

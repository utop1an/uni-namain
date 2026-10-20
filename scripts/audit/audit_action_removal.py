"""Independently compare action-removal exports and freshly validate plans."""
import argparse
import json
from pathlib import Path

from rcnc.pddl import parse_sexpr
from rcnc.validation import validate_artifacts
from scripts.experiments.run_downward_reference import sha, save


def compare_domain(before, after, removed):
    def split(root):
        actions, other = {}, []
        for entry in root:
            if isinstance(entry, list) and entry and entry[0] == ':action':
                if entry[1] in actions:
                    raise ValueError('Duplicate action name')
                actions[entry[1]] = entry
            else:
                other.append(entry)
        return actions, other
    original, original_other = split(before)
    modified, modified_other = split(after)
    return (set(removed) <= set(original) and original_other == modified_other
            and modified == {k: v for k, v in original.items() if k not in removed})


def audit(bundle, run, origin):
    manifest = json.loads((bundle/'manifest.json').read_text(encoding='utf-8'))
    execution = json.loads((run/'manifest.json').read_text(encoding='utf-8'))
    report = json.loads((run/'report.json').read_text(encoding='utf-8'))
    rows = {r['id']: r for r in report['rows']}
    tasks = {t['id']: t for t in manifest['tasks']}
    if (report['status'] != 'complete' or len(rows) != len(report['rows'])
            or set(rows) != set(tasks) or len(tasks) != manifest['task_count']
            or report['manifest_sha256'] != sha(run/'manifest.json')
            or execution['task_bundle_manifest_sha256'] != sha(bundle/'manifest.json')):
        raise ValueError('Complete unchanged run and task bundle required')
    checks = []
    for key, task in tasks.items():
        original = origin/'runs'/task['origin_id']
        domain, problem = original/'union/meta_domain.pddl', original/'mapped_problem.pddl'
        metadata_path = original/'union/meta_domain.json'
        metadata = json.loads(metadata_path.read_text(encoding='utf-8'))
        removed = set(metadata['action_maps'][task['removed_source']].values()) if task['removed_source'] else set()
        directory = run/'tasks'/key
        checked = {'id': key, 'status': rows[key]['status'],
            'origin_unchanged': sha(domain) == task['origin_domain_sha256'] and sha(metadata_path) == task['origin_metadata_sha256'],
            'problem_identical': problem.read_bytes() == (directory/'problem.pddl').read_bytes(),
            'frozen_inputs_unchanged': all(sha(directory/(name+'.pddl')) == task[name+'_sha256'] for name in ('domain', 'problem')),
            'only_declared_actions_removed': set(task['removed_actions']) == removed and compare_domain(
                parse_sexpr(domain.read_text(encoding='utf-8')),
                parse_sexpr((directory/'domain.pddl').read_text(encoding='utf-8')), removed)}
        if rows[key]['status'] == 'solved':
            checked['fresh_plan_validation'] = validate_artifacts(directory)['status']
        checks.append(checked)
    grouped = {}
    for task in tasks.values():
        grouped.setdefault(task['origin_id'], {})[task['removed_source'] or 'none'] = rows[task['id']]['status']
    required = ('origin_unchanged', 'problem_identical', 'frozen_inputs_unchanged', 'only_declared_actions_removed')
    valid = all(all(row[field] for field in required) and row.get('fresh_plan_validation', 'VALID') == 'VALID' for row in checks)
    return {'status': 'PASS' if valid else 'FAIL', 'task_count': len(tasks), 'checks': checks,
            'condition_results': grouped, 'scope': 'Necessity of source actions for these exact authored tasks only; no narrative-quality inference'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('bundle', 'run', 'origin', 'output'):
        parser.add_argument('--'+name, required=True, type=Path)
    args = parser.parse_args()
    if args.output.exists():
        raise ValueError('Do not overwrite an existing audit')
    result = audit(args.bundle, args.run, args.origin)
    save(args.output, result)
    print(json.dumps({k: v for k, v in result.items() if k != 'checks'}, indent=2))

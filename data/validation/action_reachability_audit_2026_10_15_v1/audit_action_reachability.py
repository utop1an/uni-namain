"""Revalidate invocation probes and project every returned trace onto source atoms."""
import argparse
from collections import Counter
import json
from pathlib import Path

from unified_planning.io import PDDLReader
from unified_planning.shortcuts import PlanValidator
from merge_domains import parse_sexpr
from prepare_action_reachability import audit_instrumentation
from rcnc.trace_audit import compare_states
from run_downward_reference import sha, save


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def run(bundle, solved, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    manifest, report = read(bundle/'manifest.json'), read(solved/'report.json')
    solver_manifest = read(solved/'manifest.json')
    if report['status'] != 'complete' or solver_manifest['task_bundle_manifest_sha256'] != sha(bundle/'manifest.json'):
        raise ValueError('Require complete run of the unchanged frozen bundle')
    by_id = {r['id']: r for r in report['rows']}
    if len(report['rows']) != len(by_id) or len(by_id) != manifest['task_count'] or set(by_id) != {r['id'] for r in manifest['tasks']}:
        raise ValueError('Missing, duplicate or unexpected tasks')
    output.mkdir(parents=True)
    frozen = {str(p): sha(p) for p in [bundle/'manifest.json', solved/'manifest.json', solved/'report.json', Path(__file__), Path('rcnc/trace_audit.py')]}
    rows = []
    for task in manifest['tasks']:
        original, execution = bundle/'tasks'/task['id'], solved/'tasks'/task['id']
        paths = [original/'source_domain.pddl', original/'source_problem.pddl', execution/'domain.pddl', execution/'problem.pddl']
        for path, key in zip(paths, ['source_domain_sha256', 'source_problem_sha256', 'domain_sha256', 'problem_sha256']):
            if sha(path) != task[key]:
                raise ValueError('Input changed: '+str(path))
            frozen[str(path)] = sha(path)
        roots = [parse_sexpr(p.read_text(encoding='utf-8')) for p in paths]
        audit_instrumentation(*roots, task['target_action'])
        result = {'id': task['id'], 'source': task['source'], 'target_action': task['target_action'],
                  'solver_status': by_id[task['id']]['status'], 'instrumentation_audit': True}
        if result['solver_status'] != 'solved':
            result['status'] = 'no_valid_trace'
        else:
            reader = PDDLReader()
            src = reader.parse_problem(str(paths[0]), str(paths[1]))
            dst = reader.parse_problem(str(paths[2]), str(paths[3]))
            plan_path = execution/'plan.txt'
            frozen[str(plan_path)] = sha(plan_path)
            sp, tp = reader.parse_plan(src, str(plan_path)), reader.parse_plan(dst, str(plan_path))
            with PlanValidator(name='sequential_plan_validator') as validator:
                result['instrumented_plan_validation'] = validator.validate(dst, tp).status.name
            result['target_invoked'] = any(a.action.name.lower() == task['target_action'].lower() for a in sp.actions)
            result.update(compare_states(src, dst, sp, tp, {f.name.lower(): f.name.lower() for f in src.fluents},
                                         {o.name.lower(): o.name.lower() for o in src.all_objects}))
            if not result['target_invoked'] or result['instrumented_plan_validation'] != 'VALID':
                result['status'] = 'FAIL'
            result['visited_actions'] = sorted({a.action.name for a in sp.actions})
            result['plan_length'] = len(sp.actions)
        rows.append(result)
        save(output/'progress.json', {'status': 'running', 'completed': len(rows), 'task_count': len(manifest['tasks'])})
    result = {'status': 'complete', 'task_count': len(rows), 'rows': rows,
              'status_counts': dict(Counter(r['status'] for r in rows)),
              'solver_status_counts': dict(Counter(r['solver_status'] for r in rows)),
              'states_compared': sum(r.get('states_compared', 0) for r in rows),
              'truth_comparisons': sum(r.get('truth_comparisons', 0) for r in rows),
              'mismatch_count': sum(r.get('mismatch_count', 0) for r in rows),
              'hashes_unchanged': all(sha(Path(p)) == h for p, h in frozen.items()), 'frozen_sha256': frozen,
              'scope': 'Original-world executable prefixes, not original-goal solutions; observer invocation does not establish conditional-effect branch coverage. Full source-atom comparison excludes only the fresh monitor.'}
    save(output/'report.json', result)
    (output/Path(__file__).name).write_bytes(Path(__file__).read_bytes())
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--bundle', type=Path, required=True)
    parser.add_argument('--solved', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = run(args.bundle, args.solved, args.output)
    print(json.dumps({k: v for k, v in result.items() if k not in ('rows', 'frozen_sha256')}, indent=2))

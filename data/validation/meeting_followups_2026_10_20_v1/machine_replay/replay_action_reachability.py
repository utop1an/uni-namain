"""Replay audited source invocation prefixes in one fixed compiled model."""
import argparse
from collections import Counter
from pathlib import Path

from unified_planning.io import PDDLReader
from unified_planning.plans import ActionInstance, SequentialPlan
from scripts.audit.audit_action_reachability import read
from rcnc.pddl import serialize
from rcnc.trace_audit import compare_states
from scripts.experiments.run_downward_reference import sha, save


def run(bundle, solved, audit, compiled, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    manifest, evidence = read(bundle/'manifest.json'), read(audit/'report.json')
    meta = read(compiled/'meta_domain.json')
    if evidence['status'] != 'complete' or not evidence['hashes_unchanged']:
        raise ValueError('Require complete unchanged instrumentation audit')
    if any(sha(Path(p)) != h for p, h in evidence['frozen_sha256'].items()):
        raise ValueError('Prior audit artifacts changed')
    by_id = {r['id']: r for r in evidence['rows']}
    if len(by_id) != len(evidence['rows']) or set(by_id) != {r['id'] for r in manifest['tasks']}:
        raise ValueError('Full task denominator required')
    frozen = {str(p): sha(p) for p in [bundle/'manifest.json', audit/'report.json',
              compiled/'meta_domain.json', compiled/'meta_domain.pddl', Path(__file__), Path('rcnc/trace_audit.py')]}
    output.mkdir(parents=True)
    rows = []
    cache = {}
    reader = PDDLReader()
    for task in manifest['tasks']:
        source, key = task['source'], task['id']
        row = {'id': key, 'source': source, 'target_action': task['target_action'], 'solver_status': by_id[key]['solver_status']}
        if by_id[key]['status'] != 'PASS':
            row['status'] = 'no_audited_source_trace'
        else:
            original = bundle/'tasks'/key
            for filename, digest in [('source_domain.pddl', 'source_domain_sha256'), ('source_problem.pddl', 'source_problem_sha256')]:
                if sha(original/filename) != task[digest]:
                    raise ValueError('Source artifact changed')
            if source not in cache:
                for suffix, digest in [('domainfile', 'source_domain_sha256'), ('problemfile', 'source_problem_sha256')]:
                    if meta['source_sha256'][source+'_'+suffix+'.pddl'] != task[digest]:
                        raise ValueError('Fixed compiled model has different source inputs')
                problem = compiled/'problems'/(source+'_problemfile.pddl')
                frozen[str(problem)] = sha(problem)
                src = reader.parse_problem(str(original/'source_domain.pddl'), str(original/'source_problem.pddl'))
                dst = reader.parse_problem(str(compiled/'meta_domain.pddl'), str(problem))
                terms = {k.lower(): v.lower() for k, v in meta['constant_maps'][source].items()}
                terms.update({k.lower(): v.lower() for k, v in meta['namespaces'][source].get('objects', {}).items()})
                actions = {k.lower(): v.lower() for k, v in meta['action_maps'][source].items()}
                cache[source] = src, dst, terms, actions
            src, dst, terms, actions = cache[source]
            plan_path = solved/'tasks'/key/'plan.txt'
            frozen[str(plan_path)] = sha(plan_path)
            sp = reader.parse_plan(src, str(plan_path))
            mapped = [[actions[a.action.name.lower()], *[terms[p.object().name.lower()] for p in a.actual_parameters]] for a in sp.actions]
            tp = SequentialPlan([ActionInstance(dst.action(a[0]), tuple(dst.object(x) for x in a[1:])) for a in mapped])
            directory = output/'traces'/key
            directory.mkdir(parents=True)
            (directory/'mapped.plan').write_text('\n'.join(serialize(a) for a in mapped)+'\n', encoding='utf-8')
            row.update(compare_states(src, dst, sp, tp, {k.lower(): v.lower() for k, v in meta['predicate_maps'][source].items()},
                                      terms, {k.lower(): v for k, v in meta.get('predicate_orders', {}).get(source, {}).items()}))
            row['visited_actions'] = sorted({a.action.name for a in sp.actions})
            row['plan_length'] = len(sp.actions)
        rows.append(row)
        save(output/'progress.json', {'status': 'running', 'completed': len(rows), 'task_count': len(manifest['tasks'])})
    result = {'status': 'complete', 'task_count': len(rows), 'rows': rows, 'counts': dict(Counter(r['status'] for r in rows)),
              'states_compared': sum(r.get('states_compared', 0) for r in rows),
              'truth_comparisons': sum(r.get('truth_comparisons', 0) for r in rows),
              'mismatch_count': sum(r.get('mismatch_count', 0) for r in rows),
              'hashes_unchanged': all(sha(Path(p)) == h for p, h in frozen.items()), 'frozen_sha256': frozen,
              'scope': 'Source-local executable prefixes in a fixed compiled model; original goal attainment not required. Full source-atom trace preservation, not exhaustive transition or semantic-interface correctness.'}
    save(output/'report.json', result)
    (output/Path(__file__).name).write_bytes(Path(__file__).read_bytes())
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['bundle', 'solved', 'audit', 'compiled', 'output']:
        parser.add_argument('--'+name, type=Path, required=True)
    args = parser.parse_args()
    result = run(args.bundle, args.solved, args.audit, args.compiled, args.output)
    print({k: v for k, v in result.items() if k not in ('rows', 'frozen_sha256')})

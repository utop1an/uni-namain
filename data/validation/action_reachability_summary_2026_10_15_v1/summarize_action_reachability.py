"""Separate target-task outcomes from action invocation witnessed in any audited prefix."""
import argparse
from collections import Counter
from pathlib import Path

from audit_action_reachability import read
from audit_trace_coverage import features
from merge_domains import parse_domain, parse_sexpr
from rcnc.validation import validate_artifacts
from run_downward_reference import sha, save


def classify(rows, prior_witnesses=None):
    targets = {(r['source'], r['target_action']): r for r in rows}
    if len(targets) != len(rows):
        raise ValueError('Duplicate target actions')
    witnesses = {key: [] for key in targets}
    for key, values in (prior_witnesses or {}).items():
        if key not in witnesses:
            raise ValueError('Unknown prior witnessed action')
        witnesses[key].extend(values)
    for row in rows:
        if row['status'] != 'PASS':
            continue
        if row['target_action'] not in row['visited_actions']:
            raise ValueError('Passing trace did not invoke its target')
        for action in row['visited_actions']:
            key = row['source'], action
            if key not in targets:
                raise ValueError('Unknown visited action')
            witnesses[key].append(row['id'])
    result = []
    for key, row in targets.items():
        observed = witnesses[key]
        solver = row['solver_status']
        conflict = solver == 'unsolvable' and bool(observed)
        status = ('contradictory_evidence' if conflict else 'witnessed_reachable' if observed
                  else 'solver_reported_unreachable' if solver == 'unsolvable' else 'unresolved')
        result.append({'id': row['id'], 'source': key[0], 'target_action': key[1], 'status': status,
                       'target_solver_status': solver, 'target_trace_audit_status': row['status'],
                       'witness_task_ids': observed})
    return result


def run(inputs, bundle, audit, output, prior_coverage=None):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use a fresh output directory')
    manifest, evidence = read(bundle/'manifest.json'), read(audit/'report.json')
    if evidence['status'] != 'complete' or not evidence['hashes_unchanged']:
        raise ValueError('Completed intact trace audit required')
    if any(sha(Path(p)) != h for p, h in evidence['frozen_sha256'].items()):
        raise ValueError('Trace audit evidence changed')
    if evidence['frozen_sha256'].get(str(bundle/'manifest.json')) != sha(bundle/'manifest.json'):
        raise ValueError('Bundle differs from audited bundle')
    actions, frozen = {}, {str(audit/'report.json'): sha(audit/'report.json'), str(bundle/'manifest.json'): sha(bundle/'manifest.json'), str(Path(__file__)): sha(Path(__file__))}
    for path in sorted(inputs.glob('*_domainfile.pddl')):
        source = path.name.removesuffix('_domainfile.pddl')
        problem = inputs/(source+'_problemfile.pddl')
        frozen[str(path)], frozen[str(problem)] = sha(path), sha(problem)
        domain = parse_domain(path, apply_reviewed_semantics=False)
        actions.update({(source, name): features(action) for name, action in domain.actions.items()})
        for task in [t for t in manifest['tasks'] if t['source'] == source]:
            if task['source_domain_sha256'] != sha(path) or task['source_problem_sha256'] != sha(problem):
                raise ValueError('Source differs from frozen task inputs')
    prior_witnesses = {}
    if prior_coverage:
        prior = read(prior_coverage)
        if prior['status'] != 'complete' or not prior['hashes_unchanged']:
            raise ValueError('Completed intact prior coverage required')
        if any(sha(Path(p)) != h for p, h in prior['frozen_sha256'].items()):
            raise ValueError('Prior trace artifact changed')
        frozen[str(prior_coverage)] = sha(prior_coverage)
        def without_goal(root):
            return [x for x in root if not (isinstance(x, list) and x and x[0] == ':goal')]
        for trace in prior['traces']:
            matches = [Path(p) for p in prior['frozen_sha256'] if Path(p).name == 'plan.txt' and Path(p).parent.name == trace['id']]
            if len(matches) != 1:
                raise ValueError('Cannot uniquely locate prior trace')
            directory = matches[0].parent
            source = trace['source']
            if sha(directory/'domain.pddl') != sha(inputs/(source+'_domainfile.pddl')):
                raise ValueError('Prior domain differs from current source')
            a = parse_sexpr((directory/'problem.pddl').read_text(encoding='utf-8'))
            b = parse_sexpr((inputs/(source+'_problemfile.pddl')).read_text(encoding='utf-8'))
            # Probe problem names may differ; all world sections must be identical.
            if without_goal(a[2:]) != without_goal(b[2:]):
                raise ValueError('Prior trace uses a different initial world')
            if validate_artifacts(directory)['status'] != 'VALID':
                raise ValueError('Prior plan failed fresh validation')
            actual = set()
            for line in matches[0].read_text(encoding='utf-8').splitlines():
                line = line.split(';', 1)[0].strip()
                if line:
                    actual.add(source+':'+parse_sexpr(line)[0])
            if actual != set(trace['distinct_actions']):
                raise ValueError('Prior trace action list differs from plan')
            for ref in actual:
                key = tuple(ref.split(':', 1))
                prior_witnesses.setdefault(key, []).append('prior:'+trace['run']+'/'+trace['id'])
        frozen.update(prior['frozen_sha256'])
    rows = classify(evidence['rows'], prior_witnesses)
    if {(r['source'], r['target_action']) for r in rows} != set(actions) or len(rows) != manifest['task_count']:
        raise ValueError('Every source action must have exactly one result')
    witnessed = {(r['source'], r['target_action']) for r in rows if r['status'] == 'witnessed_reachable'}
    feature_names = sorted(set().union(*actions.values()))
    result = {'status': 'complete', 'task_count': len(rows), 'rows': rows,
              'counts': dict(Counter(r['status'] for r in rows)),
              'target_solver_counts': dict(Counter(r['target_solver_status'] for r in rows)),
              'prior_coverage': str(prior_coverage) if prior_coverage else None,
              'prior_witnessed_action_count': len(prior_witnesses),
              'consistent': not any(r['status'] == 'contradictory_evidence' for r in rows),
              'sources': {source: dict(Counter(r['status'] for r in rows if r['source'] == source)) for source in sorted({r['source'] for r in rows})},
              'feature_coverage': {name: {'declared': sum(name in v for v in actions.values()),
                  'witnessed': sum(name in actions[k] for k in witnessed)} for name in feature_names},
              'hashes_unchanged': all(sha(Path(p)) == h for p, h in frozen.items()), 'frozen_sha256': frozen,
              'scope': 'Reachability witnessed in any fully audited original-world prefix; target solver outcomes remain separate. Unsolvability is solver-reported, resource cutoffs unresolved. Schema invocation is not conditional branch coverage.'}
    output.mkdir(parents=True)
    save(output/'report.json', result)
    (output/Path(__file__).name).write_bytes(Path(__file__).read_bytes())
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inputs', type=Path, default=Path('data/narra-domains'))
    for name in ['bundle', 'audit', 'output']:
        parser.add_argument('--'+name, type=Path, required=True)
    parser.add_argument('--prior-coverage', type=Path)
    args = parser.parse_args()
    result = run(args.inputs, args.bundle, args.audit, args.output, args.prior_coverage)
    print({k: v for k, v in result.items() if k not in ('rows', 'frozen_sha256')})

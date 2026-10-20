"""Audit all source-atom truth values along completed auxiliary probe replays."""
import argparse
from collections import Counter
import json
from pathlib import Path

from unified_planning.io import PDDLReader
from scripts.experiments.replay_source_probes import read, sha
from rcnc.trace_audit import compare_states


def run(source_run, replay, output, max_atoms=200000):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    old = read(replay/'report.json')
    if old['status'] != 'complete' or len(old['rows']) != old['probe_count']:
        raise ValueError('Requires completed full-denominator replay')
    if sha(source_run/'report.json') != old['source_report_sha256']:
        raise ValueError('Source report differs from replay evidence')
    output.mkdir(parents=True)
    frozen = {str(p): sha(p) for p in (source_run/'report.json', replay/'report.json')}
    for name in ('scripts/audit/audit_probe_trace_states.py', 'rcnc/trace_audit.py'):
        destination = output/'implementation'/name
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(Path(name).read_bytes())
        frozen[name] = sha(Path(name))
    result = {'status': 'running', 'probe_count': old['probe_count'], 'max_atoms': max_atoms,
        'input_and_implementation_sha256': frozen,
        'scope': 'Every mapped ground source atom along available auxiliary probe traces; no exhaustive state-space or semantic-interface guarantee', 'rows': []}
    reader = PDDLReader()
    for previous in old['rows']:
        row = {'id': previous['id'], 'source': previous['source']}
        if previous['status'] != 'VALID':
            row['status'] = 'no_valid_probe_trace'
        else:
            try:
                source, key = row['source'], row['id']
                a, b = source_run/'tasks'/key, replay/'probes'/key
                artifacts = [a/'domain.pddl', a/'problem.pddl', a/'plan.txt',
                    b/'compiled_view/meta_domain.json', b/'validation/domain.pddl',
                    b/'validation/problem.pddl', b/'validation/plan.txt']
                row['artifact_sha256'] = {str(p): sha(p) for p in artifacts}
                meta = read(b/'compiled_view/meta_domain.json')
                if sha(a/'domain.pddl') != meta['source_sha256'][source+'_domainfile.pddl']:
                    raise ValueError('Source model hash differs')
                if sha(b/'validation/domain.pddl') != old['compiled_domain_sha256']:
                    raise ValueError('Compiled model hash differs')
                if (a/'problem.pddl').read_bytes() != (b/'inputs'/(source+'_problemfile.pddl')).read_bytes():
                    raise ValueError('Source problem differs')
                src = reader.parse_problem(str(a/'domain.pddl'), str(a/'problem.pddl'))
                dst = reader.parse_problem(str(b/'validation/domain.pddl'), str(b/'validation/problem.pddl'))
                sp = reader.parse_plan(src, str(a/'plan.txt'))
                tp = reader.parse_plan(dst, str(b/'validation/plan.txt'))
                terms = {k.lower(): v for k,v in meta['constant_maps'][source].items()}
                terms.update({k.lower(): v for k,v in meta['namespaces'][source].get('objects', {}).items()})
                if len(sp.actions) != len(tp.actions):
                    raise ValueError('Trace lengths differ')
                actions = {k.lower(): v.lower() for k,v in meta['action_maps'][source].items()}
                for left, right in zip(sp.actions, tp.actions):
                    expected = [terms[p.object().name.lower()].lower() for p in left.actual_parameters]
                    observed = [p.object().name.lower() for p in right.actual_parameters]
                    if right.action.name.lower() != actions[left.action.name.lower()] or observed != expected:
                        raise ValueError('Trace is not the recorded action-wise translation')
                row.update(compare_states(src, dst, sp, tp,
                    {k.lower():v for k,v in meta['predicate_maps'][source].items()}, terms,
                    {k.lower():v for k,v in meta.get('predicate_orders', {}).get(source, {}).items()}, max_atoms))
                row['artifacts_unchanged'] = all(sha(Path(p)) == h for p,h in row['artifact_sha256'].items())
                if not row['artifacts_unchanged']:
                    raise ValueError('Trace artifacts changed during audit')
            except Exception as exc:
                row.update(status='ERROR', reason=f'{type(exc).__name__}: {exc}')
        result['rows'].append(row)
        (output/'report.json').write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
        print(json.dumps(row), flush=True)
    result.update(status='complete', hashes_unchanged=all(sha(Path(p)) == h for p,h in frozen.items()),
        counts=dict(Counter(r['status'] for r in result['rows'])),
        truth_comparisons=sum(r.get('truth_comparisons',0) for r in result['rows']),
        states_compared=sum(r.get('states_compared',0) for r in result['rows']))
    (output/'report.json').write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    return result


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source-run', type=Path, required=True)
    p.add_argument('--replay', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--max-atoms', type=int, default=200000)
    a = p.parse_args()
    result = run(a.source_run, a.replay, a.output, a.max_atoms)
    raise SystemExit(not result['hashes_unchanged'] or bool(set(result['counts'])-{'PASS','no_valid_probe_trace'}))

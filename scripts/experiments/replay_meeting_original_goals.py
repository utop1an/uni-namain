"""Replay fresh native original-goal plans in the fixed full machine-interface model."""
import argparse
from collections import Counter
import json
from pathlib import Path

from unified_planning.io import PDDLReader

from rcnc.domain_building import require_empty_output, save
from rcnc.trace_audit import compare_states
from scripts.experiments.run_downward_reference import sha
from scripts.experiments.run_union_regression import translate_plan


def run(matched, output):
    require_empty_output(output)
    report = json.loads((matched / 'report.json').read_text(encoding='utf-8'))
    protocol = json.loads((matched / 'bundle/manifest.json').read_text(encoding='utf-8'))
    if report['status'] != 'complete' or not report['matched_protocol_unchanged']:
        raise ValueError('Complete matched run required')
    rows = {row['id']: row for row in report['rows']}
    if len(rows) != len(report['rows']) or set(rows) != {task['id'] for task in protocol['tasks']}:
        raise ValueError('Original comparison denominator mismatch')
    compiled = matched / 'models/machine_interfaces'
    meta = json.loads((compiled / 'meta_domain.json').read_text(encoding='utf-8'))
    frozen = {str(path): sha(path) for path in (matched / 'report.json', matched / 'bundle/manifest.json',
        compiled / 'meta_domain.pddl', compiled / 'meta_domain.json', Path(__file__),
        Path('rcnc/trace_audit.py'), Path('scripts/experiments/run_union_regression.py'))}
    output.mkdir(parents=True)
    result = {'status': 'running', 'source_count': protocol['source_count'], 'rows': [],
              'scope': 'Fresh native plans for unchanged original goals, mapped to the fixed machine-interface model; not new solver invocations, cross-source semantic labels or narrative quality'}
    for source in sorted({task['source'] for task in protocol['tasks']}):
        original = matched / 'solver/tasks' / (source + '__source_isolated')
        native = rows[source + '__source_isolated']
        row = {'source': source, 'native_status': native['status'],
               'pooled_machine_search_status': rows[source + '__machine_interfaces']['status']}
        if native['status'] != 'solved':
            row['status'] = 'no_native_original_goal_plan'
        else:
            for suffix, name in (('domainfile', 'domain.pddl'), ('problemfile', 'problem.pddl')):
                path = matched / 'inputs' / (source + '_' + suffix + '.pddl')
                if sha(path) != sha(original / name) or meta['source_sha256'][path.name] != sha(path):
                    raise ValueError('Native source input drift')
                frozen[str(path)] = sha(path)
            frozen[str(original / 'plan.txt')] = sha(original / 'plan.txt')
            target = output / 'traces' / source
            mapped = translate_plan(source, matched / 'inputs', compiled, original, target)
            reader = PDDLReader()
            src = reader.parse_problem(str(original / 'domain.pddl'), str(original / 'problem.pddl'))
            dst = reader.parse_problem(str(target / 'domain.pddl'), str(target / 'problem.pddl'))
            source_plan = reader.parse_plan(src, str(original / 'plan.txt'))
            target_plan = reader.parse_plan(dst, str(target / 'plan.txt'))
            terms = {key.lower(): value.lower() for key, value in meta['constant_maps'][source].items()}
            terms.update({key.lower(): value.lower() for key, value in meta['namespaces'][source].get('objects', {}).items()})
            state = compare_states(src, dst, source_plan, target_plan,
                {key.lower(): value.lower() for key, value in meta['predicate_maps'][source].items()},
                terms, {key.lower(): value for key, value in meta.get('predicate_orders', {}).get(source, {}).items()})
            row.update(status='PASS' if mapped['validation']['status'] == 'VALID' and state['status'] == 'PASS' else 'FAIL',
                       mapped_validation=mapped['validation'], plan_length=mapped['length'], state_audit=state)
        result['rows'].append(row)
        save(output / 'report.json', result)
    result.update(status='complete', counts=dict(Counter(r['status'] for r in result['rows'])),
        original_goal_plans=sum(r['native_status'] == 'solved' for r in result['rows']),
        valid_translations=sum(r['status'] == 'PASS' for r in result['rows']),
        states_compared=sum(r.get('state_audit', {}).get('states_compared', 0) for r in result['rows']),
        truth_comparisons=sum(r.get('state_audit', {}).get('truth_comparisons', 0) for r in result['rows']),
        mismatch_count=sum(r.get('state_audit', {}).get('mismatch_count', 0) for r in result['rows']),
        frozen_sha256=frozen, hashes_unchanged=all(sha(Path(path)) == value for path, value in frozen.items()))
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--matched', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps({key: value for key, value in run(args.matched, args.output).items()
                      if key not in ('rows', 'frozen_sha256')}, indent=2))

"""Check exact-input comparisons and complete endpoint differences on real traces."""
import argparse
import json
from pathlib import Path

from unified_planning.engines.compilers.grounder import GrounderHelper
from unified_planning.io import PDDLReader
from unified_planning.shortcuts import SequentialSimulator
from rcnc.validation import validate_artifacts
from scripts.experiments.replay_source_probes import read, sha


def check_endpoint(domain, problem, directory, reported):
    reader = PDDLReader()
    parsed = reader.parse_problem(str(domain), str(problem))
    plan = reader.parse_plan(parsed, str(directory/'plan.txt'))
    # Independently collect every effect target on this executed trajectory.
    # Unlike the generator, this does not project parameters or maintain a
    # current-state positive-atom index, and does not prune effect guards.
    grounder = GrounderHelper(parsed, prune_actions=False)
    targets = set()
    with SequentialSimulator(parsed) as simulator:
        initial = simulator.get_initial_state()
        state = initial
        for step in plan.actions:
            grounded = grounder.ground_action(step.action, step.actual_parameters)
            for effect in grounded.effects:
                for expanded in effect.expand_effect(parsed):
                    targets.add(expanded.fluent)
            state = simulator.apply(state, step.action, step.actual_parameters)
            if state is None:
                raise ValueError('Plan has an inapplicable step')
        actual = {tuple([fact.fluent().name, *[a.object().name for a in fact.args]]):
                  state.get_value(fact).bool_constant_value() for fact in targets
                  if state.get_value(fact) != initial.get_value(fact)}
    observed = {tuple(row['atom']): row['value'] for row in reported['changes']}
    validation = validate_artifacts(directory)
    return {'status': 'PASS' if actual == observed and len(observed) == len(reported['changes'])
            and validation['status'] == 'VALID' else 'FAIL',
            'complete_changes_match': actual == observed, 'targets_checked': len(targets),
            'changed_atoms': len(actual), 'fresh_validation': validation['status']}


def audit(before, after, output):
    if output.exists():
        raise ValueError('Use a fresh report path')
    old, new = read(before/'report.json'), read(after/'report.json')
    frozen_old, frozen_new = read(before/'frozen_tasks.json'), read(after/'frozen_tasks.json')
    if old['status'] != 'complete' or new['status'] != 'complete':
        raise ValueError('Both complete runs are required')
    if frozen_old['tasks'] != frozen_new['tasks'] or frozen_old['source_sha256'] != frozen_new['source_sha256']:
        raise ValueError('Task inputs differ')
    tasks = frozen_new['tasks']
    if len(new['rows']) != len(tasks) or len(old['rows']) != len(tasks):
        raise ValueError('Incomplete denominator')
    result = {'status': 'PASS', 'task_count': len(tasks), 'rows': [],
        'report_sha256': {'before': sha(before/'report.json'), 'after': sha(after/'report.json')},
        'scope': 'Same authored inputs and wall budget; grounding/fluent budgets now count visited candidates/targets; no runtime speedup or narrative-quality claim'}
    for task in tasks:
        a, b = before/'runs'/task['id'], after/'runs'/task['id']
        identical = all((a/name).read_bytes() == (b/name).read_bytes()
                        for name in ('query.json','union/meta_domain.pddl','mapped_problem.pddl'))
        search = read(b/'planning/search.json')
        checks = [check_endpoint(b/'union/meta_domain.pddl',b/'mapped_problem.pddl',
                    b/'planning'/f'outcome_{i:03d}', row) for i,row in enumerate(search['outcomes'])]
        row = {'id':task['id'], 'exact_query_and_pddl_bytes': identical,
               'status': search['status'], 'stop_reason':search['stop_reason'], 'outcomes':checks}
        if not identical or any(c['status'] != 'PASS' for c in checks):
            result['status'] = 'FAIL'
        result['rows'].append(row)
    result['outcomes_revalidated'] = sum(len(r['outcomes']) for r in result['rows'])
    output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    return result


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--before',type=Path,required=True)
    p.add_argument('--after',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a = p.parse_args()
    r = audit(a.before,a.after,a.output)
    print(json.dumps({k:v for k,v in r.items() if k != 'rows'},indent=2))
    raise SystemExit(r['status'] != 'PASS')

"""Freeze one conservative invocation-monitor task for every source action."""
import argparse
import copy
from pathlib import Path

from merge_domains import parse_sexpr, section, serialize
from run_downward_reference import sha, save
from unified_planning.io import PDDLReader

MARKER = 'audit__target_executed'


def instrument(domain, problem, target):
    if MARKER in serialize(domain).lower() or MARKER in serialize(problem).lower():
        raise ValueError('Monitor name collides with source vocabulary')
    edited, query = copy.deepcopy(domain), copy.deepcopy(problem)
    actions = [x for x in edited if isinstance(x, list) and x and x[0] == ':action' and x[1] == target]
    if len(actions) != 1:
        raise ValueError('Target must identify exactly one action')
    action = actions[0]
    index = action.index(':effect') + 1
    # Keep the complete original effect subtree, including quantifier scope.
    action[index] = ['and', action[index], [MARKER]]
    section(edited, ':predicates').append([MARKER])
    goal = section(query, ':goal')
    goal[:] = [':goal', [MARKER]]
    return edited, query


def audit_instrumentation(domain, problem, edited, query, target):
    restored, restored_query = copy.deepcopy(edited), copy.deepcopy(query)
    predicates = section(restored, ':predicates')
    if predicates[-1] != [MARKER]:
        raise ValueError('Missing monitor declaration')
    predicates.pop()
    action = next(x for x in restored if isinstance(x, list) and x and x[0] == ':action' and x[1] == target)
    i = action.index(':effect') + 1
    effect = action[i]
    if len(effect) != 3 or effect[0] != 'and' or effect[2] != [MARKER]:
        raise ValueError('Unexpected monitor effect')
    action[i] = effect[1]
    if section(restored_query, ':goal') != [':goal', [MARKER]]:
        raise ValueError('Unexpected monitor goal')
    section(restored_query, ':goal')[:] = copy.deepcopy(section(problem, ':goal'))
    if restored != domain or restored_query != problem:
        raise ValueError('Original semantics changed beyond invocation monitor')
    return True


def freeze(inputs, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    output.mkdir(parents=True, exist_ok=True)
    rows = []
    for path in sorted(inputs.glob('*_domainfile.pddl')):
        source = path.name.removesuffix('_domainfile.pddl')
        problem_path = inputs/(source+'_problemfile.pddl')
        domain = parse_sexpr(path.read_text(encoding='utf-8'))
        problem = parse_sexpr(problem_path.read_text(encoding='utf-8'))
        names = sorted(x[1] for x in domain if isinstance(x, list) and x and x[0] == ':action')
        if len(names) != len(set(names)):
            raise ValueError('Duplicate source actions')
        for target in names:
            edited, query = instrument(domain, problem, target)
            audit_instrumentation(domain, problem, edited, query, target)
            key = source+'__'+target
            directory = output/'tasks'/key
            directory.mkdir(parents=True)
            (directory/'source_domain.pddl').write_bytes(path.read_bytes())
            (directory/'source_problem.pddl').write_bytes(problem_path.read_bytes())
            for name, root in [('domain', edited), ('problem', query)]:
                (directory/(name+'.pddl')).write_text(serialize(root)+'\n', encoding='utf-8')
            PDDLReader().parse_problem(str(directory/'domain.pddl'), str(directory/'problem.pddl'))
            rows.append({'id': key, 'source': source, 'target_action': target,
                         'domain_sha256': sha(directory/'domain.pddl'), 'problem_sha256': sha(directory/'problem.pddl'),
                         'source_domain_sha256': sha(path), 'source_problem_sha256': sha(problem_path),
                         'instrumentation_audit': True})
    result = {'status': 'frozen_before_search', 'mode': 'source_action_reachability',
              'task_count': len(rows), 'tasks': rows, 'producer_sha256': sha(Path(__file__)),
              'scope': 'All source action schemas; unchanged original initial states. Fresh initially false observer records invocation only, not conditional effect activation. Auxiliary goals are not original-goal solutions.'}
    save(output/'manifest.json', result)
    (output/'producer.py').write_bytes(Path(__file__).read_bytes())
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inputs', type=Path, default=Path('data/narra-domains'))
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = freeze(args.inputs, args.output)
    print({'status': result['status'], 'task_count': result['task_count']})

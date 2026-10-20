"""Bounded reachable-outcome enumeration under an explicitly fixed world.

Candidates use deterministic BFS discovery order. This is an outcome generator,
not narrative ranking or success against independently specified goals.
"""
from collections import deque
import json
from pathlib import Path

from unified_planning.engines.compilers.grounder import GrounderHelper
from unified_planning.io import PDDLReader, PDDLWriter
from unified_planning.plans import ActionInstance, SequentialPlan
from unified_planning.shortcuts import SequentialSimulator

from merge_domains import parse_sexpr, section, serialize
from rcnc.validation import validate_artifacts
from rcnc.grounding import StaticSafeGrounding


def explore(domain, problem_path, output, max_states=5000, max_depth=10,
            max_ground_actions=100000, max_ground_fluents=100000, max_outcomes=3):
    budgets = {'max_states': max_states, 'max_depth': max_depth, 'max_ground_actions': max_ground_actions,
               'max_ground_fluents': max_ground_fluents, 'max_outcomes': max_outcomes}
    for name, value in budgets.items():
        if type(value) is not int or value < (0 if name == 'max_depth' else 1):
            raise ValueError(f'Invalid budget: {name}')
    problem = PDDLReader().parse_problem(str(domain), str(problem_path))
    if any(not fluent.type.is_bool_type() for fluent in problem.fluents):
        raise ValueError('Outcome differences currently support Boolean fluents only')
    output = Path(output)
    output.mkdir(parents=True, exist_ok=True)
    original_root = parse_sexpr(Path(problem_path).read_text(encoding='utf-8'))
    report = {'status': 'running', 'mode': 'initial_only', 'policy': 'first_noninitial_states_in_bfs_order',
              'difference_basis': 'statically_possible_ground_effect_targets',
              'scope': 'Generated reachable outcomes, not success on specified goals or narrative-quality ranking',
              'budget': budgets, 'states': 1, 'ground_candidates': 0, 'outcomes': []}

    def finish(reason):
        report.update(status='outcomes_generated' if report['outcomes'] else 'no_outcomes', stop_reason=reason)
        (output / 'outcomes.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
        return report

    with SequentialSimulator(problem) as simulator:
        start = simulator.get_initial_state()
        parents = {start: None}
        grounder = StaticSafeGrounding(problem)
        simplifier = GrounderHelper(problem, prune_actions=True)
        candidates = []
        targets = set()
        report.update(ground_fluents_tracked=0, expanded_effect_instances=0)
        for action in problem.actions:
            for params in grounder.parameters(action):
                if report['ground_candidates'] >= max_ground_actions:
                    return finish('ground_action_limit')
                report['ground_candidates'] += 1
                grounded = simplifier.ground_action(action, params)
                if grounded is not None:
                    candidates.append((action, params))
                    for effect in grounded.effects:
                        for expanded in effect.expand_effect(problem):
                            report['expanded_effect_instances'] += 1
                            if simplifier.simplifier.simplify(expanded.condition).is_false():
                                continue
                            if expanded.fluent not in targets:
                                if len(targets) >= max_ground_fluents:
                                    return finish('ground_fluent_limit')
                                targets.add(expanded.fluent)
                                report['ground_fluents_tracked'] = len(targets)
        # Every change must be an effect target. Static facts and tuples whose
        # effect guards are statically false cannot differ from the initial
        # state. Dynamic guards remain conservative candidates, including
        # deletion targets and expanded quantified effects.
        fluents = sorted(targets, key=str)
        initial_values = {f: start.get_value(f).bool_constant_value() for f in fluents}
        queue = deque([(start, 0)])
        cutoff = False
        while queue:
            state, depth = queue.popleft()
            if depth >= max_depth:
                cutoff = True
                continue
            for action, params in candidates:
                after = simulator.apply(state, action, params)
                if after is None or after in parents:
                    continue
                if len(parents) >= max_states:
                    return finish('state_limit')
                parents[after] = (state, ActionInstance(action, params))
                report['states'] = len(parents)
                queue.append((after, depth + 1))
                changed = [(f, after.get_value(f).bool_constant_value()) for f in fluents
                           if after.get_value(f).bool_constant_value() != initial_values[f]]
                if not changed:
                    continue
                steps = []
                cursor = after
                while parents[cursor] is not None:
                    cursor, step = parents[cursor]
                    steps.append(step)
                steps.reverse()
                directory = output / f'outcome_{len(report["outcomes"]):03d}'
                directory.mkdir()
                root = json.loads(json.dumps(original_root))
                goal = ['and']
                changes = []
                for fact, value in changed:
                    atom = [fact.fluent().name, *[arg.object().name for arg in fact.args]]
                    goal.append(atom if value else ['not', atom])
                    changes.append({'atom': atom, 'value': value})
                section(root, ':goal')[1] = goal
                (directory / 'domain.pddl').write_bytes(Path(domain).read_bytes())
                (directory / 'problem.pddl').write_text(serialize(root) + '\n', encoding='utf-8')
                PDDLWriter(problem).write_plan(SequentialPlan(steps), str(directory / 'plan.txt'))
                validation = validate_artifacts(directory)
                candidate = {'index': len(report['outcomes']), 'length': len(steps), 'changes': changes,
                             'validation': validation, 'plan': str(SequentialPlan(steps))}
                report['outcomes'].append(candidate)
                if validation['status'] != 'VALID':
                    report['status'] = 'validation_failed'
                    report['stop_reason'] = 'invalid_generated_candidate'
                    return report
                if len(report['outcomes']) >= max_outcomes:
                    return finish('outcome_limit')
    return finish('depth_limit' if cutoff else 'reachable_space_exhausted')

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

from rcnc.pddl import parse_sexpr, section, serialize
from rcnc.validation import validate_artifacts
from rcnc.state_grounding import PositiveStateGrounding


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
    if any(not value.is_false() for value in problem.fluents_defaults.values()):
        raise ValueError('State-projected outcomes require false Boolean defaults')
    output = Path(output)
    output.mkdir(parents=True, exist_ok=True)
    original_root = parse_sexpr(Path(problem_path).read_text(encoding='utf-8'))
    report = {'status': 'running', 'mode': 'initial_only', 'policy': 'first_noninitial_states_in_bfs_order',
              'difference_basis': 'complete_positive_state_symmetric_difference',
              'grounding_basis': 'unique_current_state_projected_bindings',
              'fluent_budget_basis': 'effect_targets_of_visited_applicable_bindings',
              'scope': 'Generated reachable outcomes, not success on specified goals or narrative-quality ranking',
              'budget': budgets, 'states': 1, 'ground_candidates': 0, 'outcomes': []}

    def finish(reason):
        report.update(status='outcomes_generated' if report['outcomes'] else 'no_outcomes', stop_reason=reason)
        (output / 'outcomes.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
        return report

    with SequentialSimulator(problem) as simulator:
        start = simulator.get_initial_state()
        parents = {start: None}
        initial_atoms = frozenset(atom for atom, value in problem.explicit_initial_values.items() if value.is_true())
        simplifier = GrounderHelper(problem, prune_actions=True)
        seen_groundings = set()
        targets = set()
        report.update(ground_fluents_tracked=0, expanded_effect_instances=0, applicability_checks=0)
        queue = deque([(start, 0, initial_atoms)])
        cutoff = False
        while queue:
            state, depth, positive_atoms = queue.popleft()
            if depth >= max_depth:
                cutoff = True
                continue
            projection = PositiveStateGrounding(problem, positive_atoms)
            candidates = ((action, params) for action in problem.actions for params in projection.parameters(action))
            for action, params in candidates:
                key = (action.name, params)
                if key not in seen_groundings:
                    if len(seen_groundings) >= max_ground_actions:
                        return finish('ground_action_limit')
                    seen_groundings.add(key)
                    report['ground_candidates'] = len(seen_groundings)
                report['applicability_checks'] += 1
                grounded = simplifier.ground_action(action, params)
                if grounded is None:
                    continue
                after = simulator.apply(state, action, params)
                if after is None or after in parents:
                    continue
                if len(parents) >= max_states:
                    return finish('state_limit')
                after_atoms = set(positive_atoms)
                for effect in grounded.effects:
                    for expanded in effect.expand_effect(problem):
                        report['expanded_effect_instances'] += 1
                        if simplifier.simplifier.simplify(expanded.condition).is_false():
                            continue
                        fact = expanded.fluent
                        if fact not in targets:
                            if len(targets) >= max_ground_fluents:
                                return finish('ground_fluent_limit')
                            targets.add(fact)
                            report['ground_fluents_tracked'] = len(targets)
                        if after.get_value(fact).bool_constant_value():
                            after_atoms.add(fact)
                        else:
                            after_atoms.discard(fact)
                after_atoms = frozenset(after_atoms)
                parents[after] = (state, ActionInstance(action, params))
                report['states'] = len(parents)
                queue.append((after, depth + 1, after_atoms))
                changed = [(fact, fact in after_atoms)
                           for fact in sorted(initial_atoms ^ after_atoms, key=str)]
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
                    (output / 'outcomes.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
                    return report
                if len(report['outcomes']) >= max_outcomes:
                    return finish('outcome_limit')
    return finish('depth_limit' if cutoff else 'reachable_space_exhausted')

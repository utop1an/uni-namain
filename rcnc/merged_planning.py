"""Bounded reference search directly in an exported parameterized PDDL model.

Static projection and typed Cartesian grounding avoid UP 1.3.0's parameter
pruner, which can remove an object twice. Applicability and effects still use
the unmodified UP simulator; completed plans use the separate plan validator.
"""
from collections import deque

from unified_planning.engines.compilers.grounder import GrounderHelper
from unified_planning.io import PDDLReader
from unified_planning.plans import ActionInstance, SequentialPlan
from unified_planning.shortcuts import SequentialSimulator

from rcnc.validation import prepare_artifacts, write_validated_plan
from rcnc.grounding import StaticSafeGrounding


def solve(domain, problem_path, output, max_states=5000, max_depth=30,
          max_ground_actions=100000):
    for name, value, minimum in [('max_states', max_states, 1),
                                 ('max_depth', max_depth, 0),
                                 ('max_ground_actions', max_ground_actions, 1)]:
        if type(value) is not int or value < minimum:
            raise ValueError(f'Invalid budget: {name}')
    problem = PDDLReader().parse_problem(str(domain), str(problem_path))
    output = prepare_artifacts(domain, problem_path, output)
    stats = {'grounding_policy': 'typed_cartesian_with_static_positive_projection',
             'states': 1, 'ground_candidates': 0}
    with SequentialSimulator(problem) as simulator:
        start = simulator.get_initial_state()
        parents = {start: None}

        def finish(state):
            steps = []
            while parents[state] is not None:
                state, step = parents[state]
                steps.append(step)
            steps.reverse()
            plan = SequentialPlan(steps)
            return {**stats, **write_validated_plan(problem, plan, output)}

        if simulator.is_goal(start):
            return finish(start)
        candidates = []
        grounder = StaticSafeGrounding(problem)
        # Ground individual tuples with ordinary static simplification. This
        # does not invoke the buggy parameter-list pruning routine, and avoids
        # asking the simulator to execute structurally contradictory tuples.
        simplifier = GrounderHelper(problem, prune_actions=True)
        for action in problem.actions:
            for params in grounder.parameters(action):
                if stats['ground_candidates'] >= max_ground_actions:
                    return {**stats, 'status': 'ground_action_limit'}
                stats['ground_candidates'] += 1
                if simplifier.ground_action(action, params) is not None:
                    candidates.append((action, params))
        stats['viable_ground_actions'] = len(candidates)
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
                    return {**stats, 'status': 'state_limit'}
                parents[after] = (state, ActionInstance(action, params))
                stats['states'] = len(parents)
                if simulator.is_goal(after):
                    return finish(after)
                queue.append((after, depth + 1))
        return {**stats, 'status': 'depth_limit' if cutoff else 'unsolvable'}

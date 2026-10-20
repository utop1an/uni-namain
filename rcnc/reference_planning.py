"""Legacy bounded source solver retained for regression comparisons.

The current request pipeline uses merged_planning instead.
"""
from collections import deque

from rcnc.validation import prepare_artifacts, write_validated_plan


def bounded_plan(domain, problem_path, directory, max_states=1000, max_depth=8):
    from unified_planning.io import PDDLReader
    from unified_planning.shortcuts import SequentialSimulator
    from unified_planning.plans import ActionInstance, SequentialPlan
    problem = PDDLReader().parse_problem(str(domain), str(problem_path))
    directory = prepare_artifacts(domain, problem_path, directory)
    with SequentialSimulator(problem) as simulator:
        start = simulator.get_initial_state()
        queue = deque([(start, [])]); visited = {start}; cutoff = False
        while queue:
            state, steps = queue.popleft()
            if simulator.is_goal(state):
                plan = SequentialPlan(steps)
                # Preserve this legacy reference's status convention.
                result = write_validated_plan(problem, plan, directory)
                return {**result, 'status': 'solved', 'states': len(visited)}
            if len(steps) >= max_depth:
                cutoff = True; continue
            for action, params in simulator.get_applicable_actions(state):
                after = simulator.apply(state, action, params)
                if after not in visited:
                    if len(visited) >= max_states:
                        return {'status': 'state_limit'}
                    visited.add(after)
                    queue.append((after, steps+[ActionInstance(action, params)]))
    return {'status': 'depth_limit' if cutoff else 'unsolvable', 'states': len(visited)}


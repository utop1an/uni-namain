"""Bounded goal BFS with complete positive-current-state binding projection."""
from collections import deque
import time

from unified_planning.engines.compilers.grounder import GrounderHelper
from unified_planning.io import PDDLReader
from unified_planning.plans import ActionInstance
from unified_planning.shortcuts import SequentialSimulator

from rcnc.domain_building import save
from rcnc.state_grounding import PositiveStateGrounding, successor_atoms
from rcnc.validation import prepare_artifacts, reconstruct_plan, write_validated_plan


def solve(domain, problem_path, output, max_states=5000, max_depth=30,
          max_ground_actions=100000, max_ground_fluents=100000, inert_parameter_representatives=False,
          correlated_parameter_tuples=False, precondition_witness_representatives=False):
    budgets = {'max_states': max_states, 'max_depth': max_depth,
               'max_ground_actions': max_ground_actions, 'max_ground_fluents': max_ground_fluents}
    for name, value in budgets.items():
        if type(value) is not int or value < (0 if name == 'max_depth' else 1):
            raise ValueError('Invalid budget: ' + name)
    if type(inert_parameter_representatives) is not bool:
        raise ValueError('inert_parameter_representatives must be Boolean')
    if type(correlated_parameter_tuples) is not bool:
        raise ValueError('correlated_parameter_tuples must be Boolean')
    if type(precondition_witness_representatives) is not bool:
        raise ValueError('precondition_witness_representatives must be Boolean')
    budgets['inert_parameter_representatives'] = inert_parameter_representatives
    budgets['correlated_parameter_tuples'] = correlated_parameter_tuples
    budgets['precondition_witness_representatives'] = precondition_witness_representatives
    output = prepare_artifacts(domain, problem_path, output)
    stats = {'grounding_policy': 'positive_current_state_projection_with_full_parameter_bindings',
        'states': 0, 'ground_candidates': 0, 'applicability_checks': 0,
        'candidate_bindings': 0, 'expanded_states': 0,
        'expanded_effect_instances': 0, 'ground_fluents_tracked': 0,
        'budget': budgets, 'scope': 'Explicit-goal bounded BFS, no source problem facts or generator schema hints'}
    last_checkpoint = 0.0
    def progress(stage, force=False):
        nonlocal last_checkpoint
        stats['stage'] = stage
        now = time.monotonic()
        if force or now - last_checkpoint >= 1.0:
            save(output / 'progress.json', {**stats, 'status': 'running'})
            last_checkpoint = now
    def finish(status, **fields):
        result = {**stats, 'status': status, **fields}
        save(output / 'progress.json', result)
        return result
    progress('parsing', force=True)
    problem = PDDLReader().parse_problem(str(domain), str(problem_path))
    progress('checking_model', force=True)
    if any(not fluent.type.is_bool_type() or problem.fluents_defaults.get(fluent) is None
           or not problem.fluents_defaults[fluent].is_false() for fluent in problem.fluents):
        raise ValueError('State projection requires Boolean fluents with false defaults')
    inert_by_action = None
    if inert_parameter_representatives:
        from rcnc.inert_grounding import inert_parameters
        inert_by_action = {action: inert_parameters(problem, action) for action in problem.actions}
        stats['inert_parameter_counts'] = {action.name: len(parameters) for action, parameters in inert_by_action.items()}
        stats['binding_policy'] = 'lexical_representatives_for_inert_parameters_full_arguments_retained'
    effects_by_action = None
    if precondition_witness_representatives:
        from rcnc.witness_grounding import effect_parameters
        effects_by_action = {action:effect_parameters(problem, action) for action in problem.actions}
        stats['precondition_only_parameter_counts'] = {
            action.name:len(action.parameters) - len(parameters) for action,parameters in effects_by_action.items()}
        stats['binding_policy'] = 'one_applicable_full_binding_per_effect_binding_and_current_state'
    progress('initializing_simulator', force=True)
    with SequentialSimulator(problem) as simulator:
        start = simulator.get_initial_state()
        parents = {start: None}
        stats['states'] = 1
        initial_atoms = frozenset(atom for atom, value in problem.explicit_initial_values.items() if value.is_true())
        stats['initial_positive_atoms'] = len(initial_atoms)
        if simulator.is_goal(start):
            validated = write_validated_plan(problem, reconstruct_plan(parents, start), output)
            return finish(validated.pop('status'), **validated)
        simplifier = GrounderHelper(problem, prune_actions=True)
        queue = deque([(start, 0, initial_atoms)])
        grounded_cache, targets = {}, set()
        cutoff = False
        while queue:
            state, depth, positive_atoms = queue.popleft()
            if depth >= max_depth:
                cutoff = True
                continue
            if inert_by_action is None:
                projection = PositiveStateGrounding(problem, positive_atoms)
            else:
                from rcnc.inert_grounding import InertParameterGrounding
                projection = InertParameterGrounding(problem, positive_atoms, inert_by_action)
            for action in problem.actions:
                if effects_by_action is not None:
                    from rcnc.witness_grounding import binding_groups
                    groups = binding_groups(projection, action, effects_by_action[action],
                        correlated=correlated_parameter_tuples, stats=stats,
                        progress=lambda:progress('precondition_witness_binding'))
                elif correlated_parameter_tuples:
                    from rcnc.correlated_grounding import parameters
                    groups = [parameters(projection, action, stats, lambda: progress('positive_tuple_join'))]
                else:
                    groups = [projection.parameters(action)]
                for bindings in groups:
                    for params in bindings:
                        stats['candidate_bindings'] += 1
                        progress('binding_grounding')
                        key = (action.name, params)
                        if key not in grounded_cache:
                            if len(grounded_cache) >= max_ground_actions:
                                return finish('ground_action_limit')
                            grounded_cache[key] = simplifier.ground_action(action, params)
                            stats['ground_candidates'] = len(grounded_cache)
                        grounded = grounded_cache[key]
                        if grounded is None:
                            continue
                        stats['applicability_checks'] += 1
                        progress('simulator_apply')
                        if effects_by_action is not None:
                            stats['public_applicability_checks'] = stats.get('public_applicability_checks', 0) + 1
                            if not simulator.is_applicable(state, action, params):
                                continue
                        after = simulator.apply(state, action, params)
                        if after is None:
                            continue
                        if effects_by_action is not None:
                            stats['witnesses_selected'] = stats.get('witnesses_selected', 0) + 1
                        if after in parents:
                            if effects_by_action is not None: break
                            continue
                        if len(parents) >= max_states:
                            return finish('state_limit')
                        progress('successor_tracking')
                        after_atoms = successor_atoms(problem, grounded, after, positive_atoms,
                            simplifier.simplifier, targets, max_ground_fluents, stats)
                        if after_atoms is None:
                            return finish('ground_fluent_limit')
                        parents[after] = (state, ActionInstance(action, params))
                        stats['states'] = len(parents)
                        if simulator.is_goal(after):
                            plan = reconstruct_plan(parents, after)
                            validated = write_validated_plan(problem, plan, output)
                            return finish(validated.pop('status'), **validated)
                        queue.append((after, depth + 1, after_atoms))
                        if effects_by_action is not None: break
            stats['expanded_states'] += 1
            stats['frontier'] = len(queue)
            progress('state_expanded', force=True)
    return finish('depth_limit' if cutoff else 'unsolvable')

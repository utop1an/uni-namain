"""Public-API source/target prefix comparison; no planner or goal evaluation."""
from unified_planning.model.fluent import get_all_fluent_exp
from unified_planning.shortcuts import SequentialSimulator


def compare_states_public(source, target, source_plan, target_plan, predicates, terms, *, max_atoms=200000):
    if type(max_atoms) is not int or max_atoms < 1:
        raise ValueError('Positive explicit atom budget required')
    if len(source_plan.actions) != len(target_plan.actions):
        raise ValueError('Complete equal-length prefixes required')
    if any(not fluent.type.is_bool_type() for fluent in source.fluents):
        raise ValueError('Only Boolean source fluents supported')
    pairs = []
    objects_by_type = {}
    projection_issue = None
    for fluent in source.fluents:
        try:
            mapped = target.fluent(predicates[fluent.name.lower()].lower())
            if len(mapped.signature) != len(fluent.signature):
                raise ValueError('Predicate arity differs')
        except Exception as exc:
            projection_issue = {'status':'unverified_predicate_projection',
                                'predicate':fluent.name, 'reason':f'{type(exc).__name__}: {exc}'}
            break
        for atom in get_all_fluent_exp(source, fluent):
            if len(pairs) >= max_atoms:
                projection_issue = {'status':'atom_limit', 'atoms_enumerated':len(pairs)}
                break
            try:
                arguments = [target.object(terms[arg.object().name.lower()].lower()) for arg in atom.args]
                for parameter in mapped.signature:
                    if parameter.type not in objects_by_type:
                        objects_by_type[parameter.type] = set(target.objects(parameter.type))
                if any(obj not in objects_by_type[parameter.type] for parameter,obj in zip(mapped.signature,arguments)):
                    raise ValueError('Full source atom exceeds target predicate type domain')
                pairs.append((atom, mapped(*arguments)))
            except Exception as exc:
                projection_issue = {'status':'unverified_predicate_type_projection', 'source_atom':str(atom),
                    'atoms_enumerated':len(pairs), 'reason':f'{type(exc).__name__}: {exc}'}
                break
        if projection_issue is not None: break
    result = {'status':'PASS' if projection_issue is None else projection_issue['status'],
        'complete':False, 'prefix_replay_complete':False, 'states_replayed':0, 'states_compared':0,
        'truth_comparisons':0, 'truth_projection_complete':projection_issue is None,
        'projection_status':'verified_finite_projection' if projection_issue is None else projection_issue['status']}
    if projection_issue is None:
        result.update(source_ground_atoms=len(pairs), mismatch_count=0, first_mismatches=[])
    else:
        # Continue the supplied action prefix independently, but do not compare
        # a truncated atom subset or turn its absence of mismatches into PASS.
        result['projection_issue'] = projection_issue
        pairs = []
    with SequentialSimulator(source) as left, SequentialSimulator(target) as right:
        a, b = left.get_initial_state(), right.get_initial_state()
        for index in range(len(source_plan.actions) + 1):
            if index:
                source_action, target_action = source_plan.actions[index - 1], target_plan.actions[index - 1]
                source_possible = left.is_applicable(a, source_action.action, source_action.actual_parameters)
                target_possible = right.is_applicable(b, target_action.action, target_action.actual_parameters)
                if not source_possible or not target_possible:
                    return {**result, 'status':'FAIL' if source_possible else 'source_prefix_inapplicable',
                        'failure_kind':'applicability_divergence' if source_possible else 'invalid_source_prefix',
                        'inapplicable_step':index, 'source_applicable':source_possible, 'target_applicable':target_possible}
                a = left.apply(a, source_action.action, source_action.actual_parameters)
                b = right.apply(b, target_action.action, target_action.actual_parameters)
                if a is None or b is None:
                    return {**result, 'status':'simulation_error', 'inapplicable_step':index,
                            'reason':'Public applicability succeeded but apply returned no successor'}
            for atom, mapped in pairs:
                x, y = a.get_value(atom).bool_constant_value(), b.get_value(mapped).bool_constant_value()
                result['truth_comparisons'] += 1
                if x != y:
                    result['mismatch_count'] += 1
                    if len(result['first_mismatches']) < 10:
                        result['first_mismatches'].append({'step':index, 'source_atom':str(atom),
                            'mapped_atom':str(mapped), 'source_value':x, 'target_value':y})
            result['states_replayed'] += 1
            if projection_issue is None: result['states_compared'] += 1
    result['prefix_replay_complete'] = True
    result['complete'] = projection_issue is None
    if result.get('mismatch_count',0):
        result.update(status='FAIL', failure_kind='truth_projection_mismatch')
    return result

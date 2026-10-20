"""Compare every ground source atom at each state of an available paired trace."""
from unified_planning.model.fluent import get_all_fluent_exp
from unified_planning.shortcuts import SequentialSimulator


def compare_states(source, target, source_plan, target_plan, predicates, terms,
                   orders=None, max_atoms=200000):
    if type(max_atoms) is not int or max_atoms < 1:
        raise ValueError('max_atoms must be a positive integer')
    if len(source_plan.actions) != len(target_plan.actions):
        raise ValueError('Trace lengths differ')
    if any(not f.type.is_bool_type() for f in source.fluents):
        raise ValueError('Only Boolean source atoms are supported')
    orders = orders or {}
    pairs = []
    for fluent in source.fluents:
        mapped = target.fluent(predicates[fluent.name.lower()].lower())
        order = orders.get(fluent.name.lower(), list(range(len(fluent.signature))))
        if sorted(order) != list(range(len(fluent.signature))):
            raise ValueError('Non-bijective argument map')
        for atom in get_all_fluent_exp(source, fluent):
            if len(pairs) >= max_atoms:
                return {'status': 'atom_limit', 'atoms_enumerated': len(pairs), 'states_compared': 0}
            arguments = [target.object(terms[a.object().name.lower()].lower()) for a in atom.args]
            pairs.append((atom, mapped(*[arguments[i] for i in order])))
    report = {'status': 'PASS', 'source_ground_atoms': len(pairs), 'states_compared': 0,
              'truth_comparisons': 0, 'mismatch_count': 0, 'first_mismatches': []}
    with SequentialSimulator(source) as left, SequentialSimulator(target) as right:
        a, b = left.get_initial_state(), right.get_initial_state()
        for index in range(len(source_plan.actions)+1):
            if index:
                sa, sb = source_plan.actions[index-1], target_plan.actions[index-1]
                a = left.apply(a, sa.action, sa.actual_parameters)
                b = right.apply(b, sb.action, sb.actual_parameters)
                if a is None or b is None:
                    report.update(status='FAIL', inapplicable_step=index,
                                  source_applicable=a is not None, target_applicable=b is not None)
                    return report
            for atom, mapped in pairs:
                x, y = a.get_value(atom).bool_constant_value(), b.get_value(mapped).bool_constant_value()
                report['truth_comparisons'] += 1
                if x != y:
                    report['mismatch_count'] += 1
                    if len(report['first_mismatches']) < 10:
                        report['first_mismatches'].append({'step': index, 'source_atom': str(atom),
                            'mapped_atom': str(mapped), 'source_value': x, 'target_value': y})
            report['states_compared'] += 1
    if report['mismatch_count']:
        report['status'] = 'FAIL'
    return report

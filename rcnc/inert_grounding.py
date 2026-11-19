"""Reachability representatives for parameters absent from changing expressions.

Only unused parameters or parameters used solely in conjunctive immutable
unary membership atoms can collapse. Every emitted binding keeps full arity.
This is not action-instance coverage or an action-role equivalence judgment.
"""
from itertools import product

from rcnc.state_grounding import PositiveStateGrounding


def referenced_parameters(expression):
    pending, result = [expression], set()
    while pending:
        node = pending.pop()
        if node.is_parameter_exp():
            result.add(node.parameter())
        pending.extend(node.args)
    return result


def inert_parameters(problem, action):
    static, relevant = problem.get_static_fluents(), set()
    for effect in action.effects:
        for expression in (effect.fluent, effect.value, effect.condition):
            relevant.update(referenced_parameters(expression))
    pending = list(action.preconditions)
    while pending:
        condition = pending.pop()
        if condition.is_and():
            pending.extend(condition.args)
        elif (condition.is_fluent_exp() and condition.fluent() in static
                and len(condition.args) == 1 and condition.args[0].is_parameter_exp()
                and problem.fluents_defaults.get(condition.fluent()) is not None
                and problem.fluents_defaults[condition.fluent()].is_false()):
            # parameter_domains already intersects exactly these true tuples.
            continue
        else:
            relevant.update(referenced_parameters(condition))
    if getattr(action, 'simulated_effect', None) is not None:
        return frozenset()
    return frozenset(set(action.parameters) - relevant)


class InertParameterGrounding(PositiveStateGrounding):
    def __init__(self, problem, positive_atoms, inert_by_action):
        super().__init__(problem, positive_atoms)
        self.inert_by_action = inert_by_action

    def parameters(self, action):
        choices = self.parameter_domains(action)
        if choices is None:
            return iter(())
        for index, parameter in enumerate(action.parameters):
            if parameter in self.inert_by_action[action] and choices[index]:
                choices[index] = [min(choices[index], key=lambda value: value.object().name.lower())]
        return product(*choices)

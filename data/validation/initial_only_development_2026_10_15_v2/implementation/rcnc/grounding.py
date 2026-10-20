"""Sound static-positive parameter projection without mutating choice lists.

Only conjunctive, static Boolean atoms with false defaults constrain domains.
Tuple correlations and all other conditions remain for the simulator to check.
"""
from itertools import product


class StaticSafeGrounding:
    def __init__(self, problem):
        self.problem = problem
        self.static = problem.get_static_fluents()
        self.true_tuples = {}
        for atom, value in problem.explicit_initial_values.items():
            if atom.fluent() in self.static and value.is_true():
                self.true_tuples.setdefault(atom.fluent(), []).append(atom.args)

    def parameters(self, action):
        em = self.problem.environment.expression_manager
        choices = []
        for parameter in action.parameters:
            if not parameter.type.is_user_type():
                raise ValueError('Reference grounding supports object-valued parameters only')
            choices.append([em.ObjectExp(obj) for obj in self.problem.objects(parameter.type)])
        indexes = {parameter: i for i, parameter in enumerate(action.parameters)}
        pending = list(action.preconditions)
        while pending:
            condition = pending.pop()
            if condition.is_and():
                pending.extend(condition.args)
                continue
            if not condition.is_fluent_exp() or condition.fluent() not in self.static:
                continue
            default = self.problem.fluents_defaults.get(condition.fluent())
            if default is None or not default.is_false():
                continue
            if any(not (arg.is_object_exp() or arg.is_parameter_exp()) for arg in condition.args):
                continue
            tuples = []
            for values in self.true_tuples.get(condition.fluent(), []):
                bindings = {}
                valid = True
                for term, value in zip(condition.args, values):
                    if term.is_object_exp() and term != value:
                        valid = False; break
                    if term.is_parameter_exp():
                        parameter = term.parameter()
                        if parameter in bindings and bindings[parameter] != value:
                            valid = False; break
                        bindings[parameter] = value
                if valid:
                    tuples.append(values)
            for position, term in enumerate(condition.args):
                if term.is_parameter_exp():
                    index = indexes[term.parameter()]
                    allowed = {values[position] for values in tuples}
                    choices[index] = [value for value in choices[index] if value in allowed]
        return product(*choices)

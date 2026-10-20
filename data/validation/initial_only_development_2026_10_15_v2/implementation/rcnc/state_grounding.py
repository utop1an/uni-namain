"""Positive current-state projection; all remaining conditions need simulation."""
from rcnc.grounding import StaticSafeGrounding


class PositiveStateGrounding(StaticSafeGrounding):
    def __init__(self, problem, positive_atoms):
        # The caller supplies the complete true-atom set of a Boolean state
        # with false fluent defaults. Projection never uses negative,
        # disjunctive or quantified conditions as restrictions.
        self.problem = problem
        self.static = set(problem.fluents)
        self.true_tuples = {}
        for atom in positive_atoms:
            self.true_tuples.setdefault(atom.fluent(), []).append(atom.args)

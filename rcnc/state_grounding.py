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


def successor_atoms(problem, grounded, after, positive_atoms, simplifier, targets, max_targets, stats):
    """Track Boolean truth by querying the simulator's evaluated successor.

    Enumerate potential effect targets, including conditional/forall effects;
    never decide their truth independently of the original UP simulator.
    """
    result = set(positive_atoms)
    for effect in grounded.effects:
        for expanded in effect.expand_effect(problem):
            stats['expanded_effect_instances'] += 1
            if simplifier.simplify(expanded.condition).is_false():
                continue
            fact = expanded.fluent
            if fact not in targets:
                if len(targets) >= max_targets:
                    return None
                targets.add(fact)
                stats['ground_fluents_tracked'] = len(targets)
            value = after.get_value(fact)
            if not value.is_bool_constant():
                raise ValueError('State projection supports Boolean effect targets only')
            if value.bool_constant_value():
                result.add(fact)
            else:
                result.discard(fact)
    return frozenset(result)

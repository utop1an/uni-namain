"""Complete-binding groups for state-local precondition witness selection.

Within an action, applicable bindings agreeing on every parameter referenced by
an effect (including its condition/value) have the same successor in a fixed
state. Selecting one witness preserves successor reachability, not all action
instances, source identity traces, story alternatives or quality objectives.
"""
from itertools import product
from types import SimpleNamespace

from rcnc.inert_grounding import referenced_parameters


def effect_parameters(problem, action):
    if problem.quality_metrics or getattr(action, 'simulated_effect', None) is not None:
        return frozenset(action.parameters)
    result = set()
    for effect in action.effects:
        for expression in (effect.fluent, effect.value, effect.condition):
            result.update(referenced_parameters(expression))
    if result - set(action.parameters):
        raise ValueError('Effect refers to a parameter outside the action schema')
    return frozenset(result)


def binding_groups(projection, action, essential, *, correlated=False, stats=None, progress=None):
    """Yield full-binding iterators; callers stop after the first applicable one.

    A group with no applicable binding contributes no transition. No binding is
    accepted from positive projection alone; the original simulator must check.
    """
    choices = projection.parameter_domains(action)
    if choices is None or any(not values for values in choices):
        return
    if set(essential) - set(action.parameters):
        raise ValueError('Unknown essential parameter')
    inert = getattr(projection, 'inert_by_action', None)
    if inert is not None:
        for index, parameter in enumerate(action.parameters):
            # An explicit essential role wins over another optimization's
            # inert classification, including the all-parameter metric fallback.
            if parameter in inert[action] and parameter not in essential:
                choices[index] = [min(choices[index], key=lambda value:value.object().name.lower())]
    fixed_indices = [i for i,p in enumerate(action.parameters) if p in essential]
    free_indices = [i for i,p in enumerate(action.parameters) if p not in essential]

    def candidates(fixed_values):
        restricted = [list(values) for values in choices]
        for index, value in zip(fixed_indices, fixed_values):
            restricted[index] = [value]
        if correlated:
            from rcnc.correlated_grounding import parameters
            bound = SimpleNamespace(problem=projection.problem, static=projection.static,
                true_tuples=projection.true_tuples, parameter_domains=lambda _:restricted)
            yield from parameters(bound, action, stats, progress)
        else:
            for values in product(*[restricted[i] for i in free_indices]):
                result = [None] * len(choices)
                for index, value in zip(fixed_indices, fixed_values): result[index] = value
                for index, value in zip(free_indices, values): result[index] = value
                yield tuple(result)

    for fixed in product(*[choices[i] for i in fixed_indices]):
        if stats is not None:
            stats['witness_effect_groups'] = stats.get('witness_effect_groups', 0) + 1
            if progress is not None and stats['witness_effect_groups'] % 256 == 0: progress()
        yield candidates(fixed)

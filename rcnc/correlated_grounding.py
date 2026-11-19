"""Join conjunctive positive tuples without dropping complete action arguments.

Only the projection's false-default positive relations restrict bindings. Other
conditions still require the original simulator. This is an optional execution
strategy, not an alignment rule, semantic label, or planner novelty claim.
"""
from itertools import product


def parameters(projection, action, stats=None, progress=None):
    choices = projection.parameter_domains(action)
    if choices is None or any(not values for values in choices):
        return
    inert = getattr(projection, 'inert_by_action', None)
    if inert is not None:
        for index, parameter in enumerate(action.parameters):
            if parameter in inert[action]:
                choices[index] = [min(choices[index], key=lambda value: value.object().name.lower())]
    allowed = [set(values) for values in choices]
    indexes = {parameter: index for index, parameter in enumerate(action.parameters)}
    pending = list(action.preconditions)
    relations = []

    def tick(key):
        if stats is not None:
            stats[key] = stats.get(key, 0) + 1
            if progress is not None and stats[key] % 256 == 0:
                progress()

    while pending:
        condition = pending.pop()
        if condition.is_and():
            pending.extend(condition.args)
            continue
        if not condition.is_fluent_exp() or condition.fluent() not in projection.static:
            continue
        default = projection.problem.fluents_defaults.get(condition.fluent())
        if default is None or not default.is_false():
            continue
        if any(not (term.is_object_exp() or term.is_parameter_exp()) for term in condition.args):
            continue
        involved = sorted({indexes[term.parameter()] for term in condition.args if term.is_parameter_exp()})
        # Per-position projection already enforces unary, repeated-variable,
        # constant-only and nullary constraints exactly.
        if len(involved) < 2:
            continue
        records = set()
        for values in projection.true_tuples.get(condition.fluent(), []):
            tick('join_input_tuples')
            binding = {}
            valid = True
            for term, value in zip(condition.args, values):
                if term.is_object_exp():
                    if term != value:
                        valid = False; break
                else:
                    index = indexes[term.parameter()]
                    if value not in allowed[index] or (index in binding and binding[index] != value):
                        valid = False; break
                    binding[index] = value
            if valid:
                records.add(tuple(binding[index] for index in involved))
        if not records:
            return
        ordered = sorted(records, key=lambda values: tuple(value.object().name.lower() for value in values))
        relations.append((involved, ordered))
    relations.sort(key=lambda relation: (len(relation[1]), -len(relation[0]), relation[0]))
    if stats is not None:
        stats['join_relations'] = stats.get('join_relations', 0) + len(relations)
    binding = [None] * len(choices)

    def join(offset):
        if offset == len(relations):
            free = [index for index, value in enumerate(binding) if value is None]
            for values in product(*[choices[index] for index in free]):
                result = list(binding)
                for index, value in zip(free, values):
                    result[index] = value
                yield tuple(result)
            return
        involved, records = relations[offset]
        for values in records:
            tick('join_partial_bindings')
            if any(binding[index] is not None and binding[index] != value for index, value in zip(involved, values)):
                continue
            added = [index for index in involved if binding[index] is None]
            for index, value in zip(involved, values):
                binding[index] = value
            yield from join(offset + 1)
            for index in added:
                binding[index] = None

    yield from join(0)

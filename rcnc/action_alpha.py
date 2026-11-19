"""Bounded, capture-safe structural action-parameter correspondence.

Only total bijections with identical formal type names are considered. Predicate
and constant maps are fixed inputs. A unique structural match is not a judgment
of interface meaning, source-world compatibility or trace validity.
"""
from itertools import permutations

from .pddl import typed_symbols


def bind_full_arguments(arguments, source_to_target_positions, target_arity):
    """Apply a total bijection; never drop or invent an actual argument."""
    n = len(arguments)
    if (target_arity != n or len(source_to_target_positions) != n
            or any(type(i) is not int for i in source_to_target_positions)
            or sorted(source_to_target_positions) != list(range(n))):
        raise ValueError('Complete arity-preserving argument bijection required')
    result = [None] * n
    for source_index, target_index in enumerate(source_to_target_positions):
        result[target_index] = arguments[source_index]
    return result


def _fields(action):
    if len(action[2:]) % 2:
        raise ValueError('Malformed action fields')
    fields = dict(zip(action[2::2], action[3::2]))
    if len(fields) != len(action[2::2]) or set(fields) - {':parameters', ':precondition', ':effect'}:
        raise ValueError('Unsupported or duplicate action fields')
    return fields


def _bindings(tokens):
    result = list(typed_symbols(tokens).items())
    if sum(isinstance(x, str) and x.startswith('?') for x in tokens) != len(result):
        raise ValueError('Malformed or duplicate variable declaration')
    return [(name.lower(), typ.lower()) for name, typ in result]


def _body(fields, formal_positions, predicates=None, constants=None):
    def walk(expr, bound, depth):
        if not isinstance(expr, list) or not expr:
            raise ValueError('Unsupported empty or atomic formula')
        head = expr[0].lower()
        if head in ('forall', 'exists'):
            variables = _bindings(expr[1]); nested = dict(bound)
            nested.update({name: ('bound', depth, i) for i, (name, _) in enumerate(variables)})
            return (head, tuple(t for _, t in variables), walk(expr[2], nested, depth + 1))
        if head in ('and', 'or'):
            children = []
            for child in expr[1:]:
                value = walk(child, bound, depth)
                children.extend(value[1] if value[0] == head else [value])
            ordered = tuple(sorted(children, key=repr))
            return ordered[0] if len(ordered) == 1 else (head, ordered)
        if head in ('not', 'imply', 'when'):
            if len(expr) != (2 if head == 'not' else 3):
                raise ValueError('Malformed logical formula')
            return (head, *[walk(x, bound, depth) for x in expr[1:]])
        terms = []
        for token in expr[1:]:
            if not isinstance(token, str):
                raise ValueError('Nested function terms unsupported')
            term = token.lower()
            if term in bound: value = bound[term]
            elif term in formal_positions: value = ('parameter', formal_positions[term])
            elif term.startswith('?'): raise ValueError('Unbound variable: ' + term)
            elif constants is None: value = ('constant', term)
            elif term in constants: value = ('constant', constants[term])
            else: raise ValueError('Missing fixed constant map: ' + term)
            terms.append(value)
        if head == '=': symbol = '='
        elif predicates is None: symbol = head
        elif head in predicates: symbol = predicates[head]
        else: raise ValueError('Missing fixed predicate map: ' + head)
        return ('atom', symbol, tuple(terms))
    return tuple(walk(fields.get(key, ['and']), {}, 0) for key in (':precondition', ':effect'))


def structural_parameter_map(source, target, predicate_map, constant_map, *, max_arity=6, max_permutations=720):
    if type(max_arity) is not int or max_arity < 0 or type(max_permutations) is not int or max_permutations < 1:
        raise ValueError('Positive explicit structural search budgets required')
    try:
        left, right = _fields(source), _fields(target)
        a, b = _bindings(left.get(':parameters', [])), _bindings(right.get(':parameters', []))
        if len(a) != len(b): return {'status': 'arity_change_not_inferred', 'checked': 0}
        if len(a) > max_arity: return {'status': 'arity_budget_limit', 'checked': 0}
        pred = {k.lower(): v.lower() for k, v in predicate_map.items()}
        const = {k.lower(): v.lower() for k, v in constant_map.items()}
        expected = _body(right, {name: i for i, (name, _) in enumerate(b)})
        checked, matches = 0, []
        for order in permutations(range(len(a))):
            if checked >= max_permutations:
                return {'status': 'permutation_budget_limit', 'checked': checked, 'matches_found': len(matches)}
            checked += 1
            if any(typ != b[order[i]][1] for i, (_, typ) in enumerate(a)): continue
            actual = _body(left, {name: order[i] for i, (name, _) in enumerate(a)}, pred, const)
            if actual == expected:
                matches.append(list(order))
                if len(matches) == 2:
                    return {'status': 'ambiguous_structural_maps', 'checked': checked, 'matches_found_at_least': 2}
        if len(matches) == 1:
            return {'status': 'unique_structural_map', 'checked': checked, 'source_to_target_positions': matches[0]}
        return {'status': 'no_structural_map', 'checked': checked}
    except (ValueError, TypeError, IndexError, AttributeError) as exc:
        return {'status': 'unsupported_structure', 'reason': str(exc)}

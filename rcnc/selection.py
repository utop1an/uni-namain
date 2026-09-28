"""Audited source-pool selection and signed STRIPS goal relevance."""
import copy
from pathlib import Path
from merge_domains import parse_domain, typed_symbols
from rcnc.experiment import unsupported_logic, iter_raw_literals
from rcnc.planning import compatible


def audit_action(domain, action):
    reasons = []
    params = typed_symbols(action[action.index(':parameters')+1]) if ':parameters' in action else {}
    for name, typ in params.items():
        if not name.startswith('?') or typ != 'object' and typ not in domain.types:
            reasons.append(f'invalid_parameter:{name}:{typ}')
    for key in (':precondition', ':effect'):
        if key not in action:
            continue
        expr = action[action.index(key)+1]
        unsupported = unsupported_logic(expr)
        if unsupported:
            reasons.extend('unsupported_logic:'+x for x in unsupported)
            continue
        for pred, args, _ in iter_raw_literals(expr):
            decl = domain.predicates.get(pred)
            if decl is None:
                reasons.append('undeclared_predicate:'+pred)
            elif len(args) != decl.arity:
                reasons.append('wrong_arity:'+pred)
            else:
                for arg, (_, expected) in zip(args, decl.parameters):
                    actual = params.get(arg) if arg.startswith('?') else domain.constants.get(arg)
                    if actual is None:
                        reasons.append('undeclared_symbol:'+arg)
                    elif not compatible(actual, expected, domain.types):
                        reasons.append(f'ill_typed:{pred}:{arg}:{actual}->{expected}')
    return sorted(set(reasons))


def resolve_sources(query, input_dir: Path):
    """No guessing of source constants; absent bindings make actions ineligible."""
    if 'actions' in query or not query.get('sources'):
        raise ValueError('Automatic selection needs sources instead of actions')
    resolved = copy.deepcopy(query)
    selected, excluded = [], []
    used_constants = set()
    declared_constants = set()
    declared_predicates = set()
    for source in sorted(set(query['sources'])):
        if not source or any(x in source for x in '/\\.'):
            raise ValueError('Invalid source identifier')
        domain = parse_domain(input_dir/f'{source}_domainfile.pddl', apply_reviewed_semantics=False)
        declared_constants.update(f'{source}:{c}' for c in domain.constants)
        declared_predicates.update(f'{source}:{p}' for p in domain.predicates)
        for name, action in sorted(domain.actions.items()):
            ref = f'{source}:{name}'
            reasons = audit_action(domain, action)
            constants = set()
            if not reasons:
                for key in (':precondition', ':effect'):
                    if key in action:
                        constants.update(a for _, args, _ in iter_raw_literals(action[action.index(key)+1])
                                         for a in args if not a.startswith('?'))
                for constant in sorted(constants):
                    binding_key = f'{source}:{constant}'
                    if binding_key not in query.get('constant_bindings', {}):
                        reasons.append('missing_constant_binding:'+binding_key)
                    else:
                        obj = query['constant_bindings'][binding_key]
                        if obj not in query['objects'] or not compatible(query['objects'][obj], domain.constants[constant], domain.types):
                            raise ValueError(f'Invalid constant binding: {binding_key} -> {obj}')
                params = typed_symbols(action[action.index(':parameters')+1]) if ':parameters' in action else {}
                for typ in sorted(set(params.values())):
                    if not any(compatible(t,typ,domain.types) for t in query['objects'].values()):
                        reasons.append('no_object_of_type:'+typ)
            if reasons:
                excluded.append({'action': ref, 'reasons': reasons})
            else:
                selected.append(ref)
                used_constants.update(f'{source}:{c}' for c in constants)
    if set(query.get('constant_bindings', {})) - declared_constants:
        raise ValueError('Unknown source constant binding')
    if set(query.get('interfaces', {})) - declared_predicates:
        raise ValueError('Unknown source predicate interface')
    resolved.pop('sources')
    resolved['actions'] = selected
    resolved['constant_bindings'] = {k:v for k,v in query.get('constant_bindings', {}).items() if k in used_constants}
    return resolved, {'source_actions': len(selected)+len(excluded), 'eligible_actions': len(selected),
                      'selected_actions': selected, 'excluded': excluded,
                      'scope': 'Completeness is relative to eligible actions and explicit constant bindings.'}


def relevant_actions(actions, initial, goal, negative_goal):
    """Conservative ground-level closure including delete support for negative facts.

Keep all achievers, even when a required fact is initially true: another action
may threaten it. Static pruning only removes impossible actions. Grounding is
performed before this reduction, so it does not reduce grounding cost.
"""
    dynamic = {f[0] for a in actions for f in a.add | a.delete}
    possible = [a for a in actions if not any(f[0] not in dynamic and f not in initial for f in a.positive)
                and not any(f[0] not in dynamic and f in initial for f in a.negative)]
    positive, negative = set(goal), set(negative_goal)
    selected = set()
    changed = True
    while changed:
        changed = False
        for a in possible:
            if a.name not in selected and (a.add & positive or a.delete & negative):
                selected.add(a.name)
                positive.update(a.positive)
                negative.update(a.negative)
                changed = True
    result = [a for a in possible if a.name in selected]
    return result, {'before':len(actions), 'after_static_pruning':len(possible), 'after_goal_relevance':len(result)}

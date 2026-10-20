"""Conservative source-component selection for membership-compiled worlds.

This restricts a parameterized model before search, never a grounded plan.
An interface cannot transmit a fact between disjoint source universes when
its arity is positive. Nullary interfaces and overlapping universes retain
dependencies. Role-type correspondences do not establish object identity.
"""
import copy
from .domain_catalog import effect_symbols
from .pddl import section


def select_component(metadata, domain, problem, source):
    sources = set(metadata['sources'])
    if source not in sources:
        raise ValueError('Unknown original-world source')
    if metadata.get('method') != 'explicit_predicate_alignment_with_type_membership':
        raise ValueError('Selection requires membership-compiled provenance')
    guards = set(metadata['type_guards'].values())
    for action in domain.actions.values():
        fields = dict(zip(action[2::2], action[3::2]))
        if effect_symbols(fields.get(':effect', ['and']))[0] & guards:
            raise ValueError('Membership guards must remain static')
    facts = section(problem, ':init')
    if facts is None:
        raise ValueError('Explicit initial state required')
    roots = {s: metadata['type_guards'][metadata['namespaces'][s]['types']['object']]
             for s in sources}
    universes = {s: {fact[1] for fact in facts[1:]
                     if isinstance(fact, list) and len(fact) == 2 and fact[0] == root}
                 for s, root in roots.items()}
    for s in sources:
        local_guards = {metadata['type_guards'][typ]
                        for typ in metadata['namespaces'][s]['types'].values()}
        if any(fact[1] not in universes[s] for fact in facts[1:]
               if isinstance(fact, list) and len(fact) == 2 and fact[0] in local_guards):
            raise ValueError('Subtype membership lacks source-root membership')
    # This policy is for an original source goal. A multi-source request needs
    # multiple seed components, rather than silently discarding goal vocabulary.
    if 'predicate_maps' in metadata:
        allowed = set(metadata['predicate_maps'][source].values())
        allowed.update(metadata['type_guards'][t]
                       for t in metadata['namespaces'][source]['types'].values())
        def check_goal(expr):
            head = expr[0]
            if head in ('and', 'or', 'not', 'imply'):
                for child in expr[1:]:
                    check_goal(child)
            elif head in ('forall', 'exists'):
                check_goal(expr[2])
            else:
                if head != '=' and head not in allowed:
                    raise ValueError('Goal is outside the original source component')
                if any(not term.startswith('?') and term not in universes[source] for term in expr[1:]):
                    raise ValueError('Goal contains a foreign object')
        goal = section(problem, ':goal')
        if goal is None:
            raise ValueError('Explicit original source goal required')
        check_goal(goal[1])
    adjacency = {s: set() for s in sources}
    edges = []
    specification = metadata['alignment_specification']
    for group in specification.get('predicate_groups', []):
        members = group['members']
        for i, left in enumerate(members):
            a, predicate = left['predicate'].split(':', 1)
            arity = len(metadata['source_predicate_types'][a][predicate])
            for right in members[i + 1:]:
                b = right['predicate'].split(':', 1)[0]
                overlap = sorted(universes[a] & universes[b])
                active = arity == 0 or bool(overlap)
                if active:
                    adjacency[a].add(b)
                    adjacency[b].add(a)
                edges.append({'group': group['id'], 'sources': [a, b], 'arity': arity,
                              'overlapping_objects': overlap, 'retain_dependency': active,
                              'reason': 'nullary_or_overlapping_universe' if active
                              else 'positive_arity_disjoint_static_source_universes'})
    chosen = {source}
    while True:
        expanded = chosen | set().union(*(adjacency[s] for s in chosen))
        if expanded == chosen:
            break
        chosen = expanded
    projected = copy.deepcopy(specification)
    projected['predicate_groups'] = []
    for group in specification.get('predicate_groups', []):
        members = [m for m in group['members'] if m['predicate'].split(':', 1)[0] in chosen]
        if len(members) >= 2:
            projected['predicate_groups'].append({**group, 'members': members})
    projected['type_groups'] = []
    for group in specification.get('type_groups', []):
        members = [m for m in group['members'] if m.split(':', 1)[0] in chosen]
        if len(members) >= 2:
            projected['type_groups'].append({**group, 'members': members})
    certificate = {'policy': 'static_source_universe_components_v1',
        'source': source, 'selected_sources': sorted(chosen), 'excluded_sources': sorted(sources - chosen),
        'source_universes': {s: sorted(v) for s, v in sorted(universes.items())},
        'interface_edges': edges, 'action_subset_selection': False,
        'scope': 'Requires compiler-enforced source scopes and immutable membership; no semantic interface labels. '
                 'Excluded components cannot read or write retained interface tuples. Foreign independent actions may be removed; '
                 'this is a goal-reachability component reduction, not full-state trace equivalence.'}
    return projected, certificate

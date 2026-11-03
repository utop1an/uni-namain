"""Deterministic, explicitly synthetic composition-probe construction.

These generated worlds exercise fixed model interfaces. They are neither
independent semantic annotations nor inferred initial states for user requests.
"""
import hashlib
import itertools
import json

from .pddl import typed_symbols, is_type_compatible


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(',', ':'), ensure_ascii=False).encode('utf-8')).hexdigest()


def literals(expr):
    if not isinstance(expr, list) or not expr:
        raise ValueError('unsupported_empty_formula')
    head = expr[0]
    if head == 'and':
        return [literal for child in expr[1:] for literal in literals(child)]
    if head == 'not':
        if len(expr) != 2:
            raise ValueError('unsupported_negation')
        child = expr[1]
        if not isinstance(child, list) or not child or child[0] in ('and', 'or', 'not', 'forall', 'exists', 'when', '=', 'imply'):
            raise ValueError('unsupported_non_strips_formula')
        if any(not isinstance(term, str) for term in child):
            raise ValueError('unsupported_non_strips_formula')
        return [(False, child)]
    if head in ('or', 'forall', 'exists', 'when', '=', 'imply', 'increase', 'decrease', 'assign') or any(not isinstance(term, str) for term in expr):
        raise ValueError('unsupported_non_strips_formula')
    return [(True, expr)]


def profile(action):
    fields = dict(zip(action[2::2], action[3::2]))
    if set(fields) - {':parameters', ':precondition', ':effect'}:
        raise ValueError('unsupported_action_field')
    return {'parameters': typed_symbols(fields.get(':parameters', [])),
            'preconditions': literals(fields.get(':precondition', ['and'])),
            'effects': literals(fields.get(':effect', ['and']))}


def canonicalizer(specification):
    aliases = {}
    for group in specification['predicate_groups']:
        for member in group['members']:
            source, predicate = member['predicate'].split(':', 1)
            key = source + ':' + predicate.lower()
            if key in aliases:
                raise ValueError('Multiply assigned interface predicate')
            aliases[key] = ('@' + group['id'], member['order'])
    def canonical(atom):
        source, predicate = atom[0].split(':', 1)
        key = source + ':' + predicate.lower()
        name, order = aliases.get(key, (key, list(range(len(atom) - 1))))
        terms = [term.split(':', 1)[0] + ':' + term.split(':', 1)[1].lower() if ':' in term else term for term in atom[1:]]
        return (name, *[terms[index] for index in order])
    return canonical


def construct(candidate, domains, profiles, specification, members):
    producer, consumer = candidate['producer'], candidate['consumer']
    sources = {'producer': producer, 'consumer': consumer}
    selected = {role: profiles[sources[role]][candidate[role + '_action']] for role in sources}
    effect = selected['producer']['effects'][candidate['producer_literal_index']][1]
    requirement = selected['consumer']['preconditions'][candidate['consumer_literal_index']][1]
    interface = {'producer': effect, 'consumer': requirement}
    keys = [(role, variable) for role, data in selected.items() for variable in data['parameters']]
    parents = {key: key for key in keys}
    def find(key):
        while parents[key] != key:
            key = parents[key]
        return key
    def union(left, right):
        left, right = find(left), find(right)
        parents[max(left, right)] = min(left, right)
    arities = {len(atom) - 1 for atom in interface.values()}
    if len(arities) != 1:
        raise ValueError('interface_arity_mismatch')
    arity = arities.pop()
    orders = {role: members[sources[role]]['order'] for role in sources}
    for role, order in orders.items():
        if len(order) != arity or sorted(order) != list(range(arity)) or any(type(index) is not int for index in order):
            raise ValueError('invalid_interface_permutation')
        if any(not term.startswith('?') for term in interface[role][1:]):
            raise ValueError('constant_interface_term')
        if any((role, term) not in parents for term in interface[role][1:]):
            raise ValueError('unbound_interface_variable')
    for position in range(arity):
        union(('producer', effect[1 + orders['producer'][position]]),
              ('consumer', requirement[1 + orders['consumer'][position]]))
    classes = {}
    for key in keys:
        classes.setdefault(find(key), []).append(key)
    objects, bindings = {}, {role: {} for role in sources}
    for index, root in enumerate(sorted(classes)):
        name = 'r' + str(index)
        memberships = []
        for source in sorted(set(sources.values())):
            requested = sorted({selected[role]['parameters'][variable] for role, variable in classes[root] if sources[role] == source})
            if not requested:
                continue
            compatible = [typ for typ in requested if all(is_type_compatible(typ, other, domains[source].types) for other in requested)]
            if not compatible:
                raise ValueError('incomparable_same_source_types')
            memberships.append(source + ':' + compatible[0])
        objects[name] = memberships
        for role, variable in classes[root]:
            bindings[role][variable] = name
    def ground(role, atom):
        source = sources[role]
        constants = {name.lower() for name in domains[source].constants}
        terms = []
        for term in atom[1:]:
            if term.startswith('?'):
                if term not in bindings[role]:
                    raise ValueError('unbound_action_variable')
                terms.append(bindings[role][term])
            elif term.lower() in constants:
                terms.append(source + ':' + term)
            else:
                raise ValueError('unknown_action_constant')
        return [source + ':' + atom[0], *terms]
    initial, negative = [], []
    for role in ('producer', 'consumer'):
        for index, (positive, atom) in enumerate(selected[role]['preconditions']):
            if role == 'consumer' and index == candidate['consumer_literal_index']:
                continue
            (initial if positive else negative).append(ground(role, atom))
    initial = [list(fact) for fact in dict.fromkeys(tuple(fact) for fact in initial)]
    canonical = canonicalizer(specification)
    positive_state = {canonical(fact) for fact in initial}
    target = ground('producer', effect)
    goal = ground('consumer', selected['consumer']['effects'][candidate['goal_effect_index']][1])
    if canonical(target) in positive_state:
        raise ValueError('target_interface_initially_true')
    if canonical(goal)[0] == canonical(target)[0]:
        raise ValueError('goal_is_interface')
    if canonical(goal) in positive_state:
        raise ValueError('goal_initially_true')
    if any(canonical(fact) in positive_state for fact in negative):
        raise ValueError('negative_precondition_conflict')
    return {'objects': objects, 'initial': initial, 'goal': {'positive': [goal]},
            'state_semantics': 'complete_closed_world'}, {'bindings': bindings, 'shared_interface': target,
                'required_absent_facts': negative}


def generate(domains, specification, seed=20261023):
    profiles, profile_rows = {}, []
    for source, domain in sorted(domains.items()):
        profiles[source] = {}
        for name, action in sorted(domain.actions.items()):
            try:
                profiles[source][name] = profile(action)
                profile_rows.append({'source': source, 'action': name, 'status': 'supported'})
            except ValueError as exc:
                profile_rows.append({'source': source, 'action': name, 'status': 'unsupported_schema', 'reason': str(exc)})
    pairs, candidates = [], []
    for group in sorted(specification['predicate_groups'], key=lambda group: group['id']):
        members = {member['predicate'].split(':', 1)[0]: member for member in group['members']}
        if len(members) != len(group['members']):
            raise ValueError('Probe protocol requires one predicate per source in an interface group')
        for producer, consumer in itertools.permutations(sorted(members), 2):
            pair_id = group['id'] + '__' + producer + '__' + consumer
            pair_candidates = []
            provider_predicate = members[producer]['predicate'].split(':', 1)[1].lower()
            consumer_predicate = members[consumer]['predicate'].split(':', 1)[1].lower()
            for producer_action, consumer_action in itertools.product(sorted(domains[producer].actions), sorted(domains[consumer].actions)):
                descriptor = {'seed': seed, 'group': group['id'], 'producer': producer, 'consumer': consumer,
                    'producer_action': producer_action, 'consumer_action': consumer_action,
                    'producer_literal_index': -1, 'consumer_literal_index': -1, 'goal_effect_index': -1}
                left, right = profiles[producer].get(producer_action), profiles[consumer].get(consumer_action)
                reason = None
                if left is None or right is None:
                    reason = 'unsupported_generator_schema'
                    triples = [(-1, -1, -1)]
                else:
                    effect_indices = [i for i, (positive, atom) in enumerate(left['effects']) if positive and atom[0].lower() == provider_predicate]
                    condition_indices = [i for i, (positive, atom) in enumerate(right['preconditions']) if positive and atom[0].lower() == consumer_predicate]
                    goal_indices = [i for i, (positive, atom) in enumerate(right['effects']) if positive and atom[0].lower() != consumer_predicate]
                    triples = list(itertools.product(effect_indices, condition_indices, goal_indices))
                    if not triples:
                        triples, reason = [(-1, -1, -1)], 'no_eligible_interface_and_goal_occurrences'
                for effect_index, condition_index, goal_index in triples:
                    item = {**descriptor, 'producer_literal_index': effect_index,
                            'consumer_literal_index': condition_index, 'goal_effect_index': goal_index}
                    record = {'pair_id': pair_id, 'candidate': item, 'rank_sha256': digest(item)}
                    query, provenance = None, None
                    try:
                        if reason:
                            raise ValueError(reason)
                        query, provenance = construct(item, domains, profiles, specification, members)
                        record.update(status='supported', query_sha256=digest(query))
                    except ValueError as exc:
                        record.update(status='excluded', reason=str(exc))
                    pair_candidates.append((record, query, provenance))
            pair_candidates.sort(key=lambda item: item[0]['rank_sha256'])
            selected = next((item for item in pair_candidates if item[0]['status'] == 'supported'), None)
            pair = {'id': pair_id, 'group': group['id'], 'producer': producer, 'consumer': consumer,
                    'candidate_count': len(pair_candidates), 'supported_candidate_count': sum(item[0]['status'] == 'supported' for item in pair_candidates)}
            if selected:
                record, query, provenance = selected
                pair.update(status='generated', selected_candidate=record['candidate'],
                    selected_rank_sha256=record['rank_sha256'], query=query, construction=provenance)
            else:
                pair.update(status='no_supported_probe', query=None)
            pairs.append(pair)
            candidates.extend(item[0] for item in pair_candidates)
    return {'pairs': pairs, 'candidates': candidates, 'action_profiles': profile_rows,
            'seed': seed, 'scope': 'Model-derived development mechanisms; no independent semantic labels or narrative-quality evidence'}

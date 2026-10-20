"""Deterministic source-domain selection by conservative predicate dependency.

Argument bindings and polarity are deliberately ignored in relevance analysis.
This over-approximation selects complete domains, not successful action paths;
it makes no minimality, reachability, or semantic-correctness claim.
"""
import copy
import hashlib

from rcnc.pddl import parse_domain, parse_sexpr


def condition_symbols(expr):
    if not isinstance(expr, list) or not expr:
        raise ValueError('Malformed condition in domain catalog')
    head = expr[0]
    if head in ('and', 'or', 'not', 'imply'):
        return set().union(*(condition_symbols(e) for e in expr[1:]))
    if head in ('forall', 'exists'):
        return condition_symbols(expr[2])
    if head == '=':
        return set()
    if any(isinstance(e, list) for e in expr[1:]):
        raise ValueError('Unsupported nested term in domain catalog')
    return {head.lower()}


def effect_symbols(expr):
    head = expr[0]
    if head == 'and':
        effects, requirements = set(), set()
        for child in expr[1:]:
            e, r = effect_symbols(child); effects.update(e); requirements.update(r)
        return effects, requirements
    if head == 'forall':
        return effect_symbols(expr[2])
    if head == 'when':
        effects, requirements = effect_symbols(expr[2])
        return effects, requirements | condition_symbols(expr[1])
    return condition_symbols(expr), set()


def catalog(inputs):
    rows = []
    for path in sorted(inputs.glob('*_domainfile.pddl')):
        root = parse_sexpr(path.read_text(encoding='utf-8'))
        allowed = {'domain', ':requirements', ':types', ':constants', ':predicates', ':action'}
        if any(not isinstance(part, list) or not part or part[0] not in allowed for part in root[1:]):
            raise ValueError(f'Unsupported domain-level section: {path.name}')
        domain = parse_domain(path)
        source = next(iter(domain.sources))
        actions = []
        for name, action in domain.actions.items():
            fields = {action[i]: action[i+1] for i in range(2, len(action), 2)}
            if set(fields) - {':parameters', ':precondition', ':effect'}:
                raise ValueError(f'Unsupported action field: {source}:{name}')
            effects, conditions = effect_symbols(fields.get(':effect', ['and']))
            conditions |= condition_symbols(fields.get(':precondition', ['and']))
            actions.append({'name': name, 'requires': sorted(f'{source}:{p}' for p in conditions),
                            'effects': sorted(f'{source}:{p}' for p in effects)})
        rows.append({'source': source, 'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                     'upstream_learning_provenance': 'not_supplied', 'types': domain.types,
                     'constants': domain.constants,
                     'predicates': {p.name: p.parameters for p in domain.predicates.values()},
                     'actions': actions})
    if not rows:
        raise ValueError('No input domains')
    return {'version': 1, 'sources': rows,
            'scope': 'Structural local-file catalog; upstream learning provenance not inferred'}


def qualified(reference):
    if not isinstance(reference, str) or reference.count(':') != 1:
        raise ValueError(f'Expected source-qualified reference: {reference}')
    source, symbol = reference.split(':')
    return source + ':' + symbol.lower()


def select(query, inventory):
    sources = {r['source']: r for r in inventory['sources']}
    policy = query.get('selection', 'explicit_sources' if 'sources' in query else 'all_domains')
    if policy not in ('all_domains', 'explicit_sources', 'goal_dependencies'):
        raise ValueError('Unknown domain selection policy')
    if 'sources' in query and policy != 'explicit_sources':
        raise ValueError('Explicit sources and automatic selection cannot both be specified')
    reasons = {source: set() for source in sources}
    relevant_actions = set()
    if policy == 'all_domains' or (policy == 'goal_dependencies' and query.get('goal') is None):
        chosen = set(sources)
        reason = 'all_domains_policy' if policy == 'all_domains' else 'initial_only_all_domains_fallback'
        for source in chosen: reasons[source].add(reason)
    elif policy == 'explicit_sources':
        requested = query.get('sources')
        if not isinstance(requested, list) or not requested or any(not isinstance(s, str) for s in requested):
            raise ValueError('sources must be a nonempty list')
        chosen = set(requested)
        if len(chosen) != len(requested) or chosen - set(sources):
            raise ValueError('sources contains duplicate or unknown domains')
        for source in chosen: reasons[source].add('explicit_request')
    else:
        refs = []
        for atom in query['initial'] + query['goal'].get('positive', []) + query['goal'].get('negative', []):
            refs.append(qualified(atom[0]))
            refs.extend(qualified(term) for term in atom[1:] if isinstance(term, str) and ':' in term)
        for value in query.get('objects', {}).values():
            refs.extend(qualified(v) for v in (value if isinstance(value, list) else [value]))
        chosen = {ref.split(':', 1)[0] for ref in refs}
        if chosen - set(sources):
            raise ValueError('Query references an unknown source')
        for source in chosen: reasons[source].add('preserve_query_vocabulary_and_world')
        aliases = {}
        groups = query.get('alignment', {}).get('predicate_groups', [])
        for group in groups:
            for member in group['members']:
                ref = qualified(member['predicate'])
                if ref in aliases:
                    raise ValueError('Multiply assigned predicate in alignment')
                aliases[ref] = '@' + group['id']
        canonical = lambda ref: aliases.get(ref, ref)
        needed = {canonical(qualified(atom[0])) for key in ('positive', 'negative')
                  for atom in query['goal'].get(key, [])}
        changed = True
        while changed:
            before = (len(chosen), len(needed), len(relevant_actions))
            for source, row in sources.items():
                for action in row['actions']:
                    if {canonical(ref) for ref in action['effects']} & needed:
                        chosen.add(source)
                        reasons[source].add('goal_dependency_producer')
                        relevant_actions.add(source + ':' + action['name'])
                        needed.update(canonical(ref) for ref in action['requires'])
            # Keep complete asserted interfaces once one participating source
            # is selected. This may over-select; it never silently truncates a
            # supplied predicate correspondence.
            for group in groups:
                participants = {member['predicate'].split(':', 1)[0] for member in group['members']}
                if participants & chosen:
                    if participants - set(sources):
                        raise ValueError('Alignment references unknown sources')
                    chosen.update(participants)
                    for source in participants: reasons[source].add('complete_alignment_group')
            changed = before != (len(chosen), len(needed), len(relevant_actions))
        if not chosen:
            chosen = set(sources)
            for source in chosen: reasons[source].add('empty_request_vocabulary_all_domains_fallback')
    return {'policy': policy, 'selected': sorted(chosen), 'excluded': sorted(set(sources) - chosen),
            'source_reasons': {s: sorted(reasons[s]) or ['outside_query_and_dependency_closure'] for s in sources},
            'relevant_action_references_for_explanation_only': sorted(relevant_actions),
            'action_subset_selection': False, 'optimal_or_minimal_subset_claim': False,
            'scope': 'Unsigned predicate dependency over-approximation; no reachability or semantic-equivalence claim'}


def project_alignment(specification, selected):
    result = copy.deepcopy(specification)
    retained = []
    omitted = []
    selected = set(selected)
    for group in result.get('predicate_groups', []):
        participants = {m['predicate'].split(':', 1)[0] for m in group['members']}
        if participants <= selected:
            retained.append(group)
        elif participants & selected:
            raise ValueError('Selected sources would truncate an alignment group')
        else:
            omitted.append(group['id'])
    result['predicate_groups'] = retained
    type_groups = []
    for group in result.get('type_groups', []):
        members = [ref for ref in group['members'] if ref.split(':', 1)[0] in selected]
        if len(members) >= 2:
            type_groups.append({**group, 'members': members})
    result['type_groups'] = type_groups
    return result, omitted

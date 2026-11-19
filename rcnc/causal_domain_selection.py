"""Deterministic source-only opportunity ranking, without outcomes or random draws.

Scores describe possible positive producer/consumer interfaces, not semantic
equivalence, reachable chains, or independent labels. Unsupported actions remain
in the domains and are listed outside the scoring fragment.
"""
from collections import Counter
from heapq import nsmallest
from itertools import combinations, permutations, product
from math import comb

from rcnc.composition_probes import literals
from rcnc.glaive_merge import action_fields, candidate_pairs
from rcnc.glaive_intake import ancestors
from rcnc.pddl import typed_symbols


SCORE_FIELDS = ('connected_sources', 'directed_source_edges',
                'producer_consumer_action_pairs', 'lexically_weighted_links')


def profiles_for_selection(sources):
    profiles, excluded = {}, []
    for sid, source in sorted(sources.items()):
        profiles[sid] = {}
        for name, action in sorted(source.domain.actions.items()):
            try:
                fields = action_fields(action)
                pre, eff = literals(fields[':precondition']), literals(fields[':effect'])
                params = typed_symbols(fields[':parameters'])
                if any(atom[0] not in source.domain.predicates for _, atom in pre + eff):
                    raise ValueError('nonordinary_literal')
                if any(term not in params for _, atom in pre + eff for term in atom[1:]):
                    raise ValueError('constant_or_unbound_term_outside_scoring_fragment')
                profiles[sid][name] = {'parameters': params, 'preconditions': pre,
                                      'effects': eff}
            except ValueError as exc:
                excluded.append({'source': sid, 'action': name, 'reason': str(exc)})
    return profiles, excluded


def _type_lineage(source, typ):
    return ancestors(typ, source.type_parents)


def _type_match(left, lt, right, rt):
    # Type names are only a retrieval heuristic. Cross-world identity is still
    # explicit in later authored probes and never supplied by this score.
    if 'object' in (lt, rt):
        return True
    return bool((_type_lineage(left, lt) & _type_lineage(right, rt)) - {'object'})


def _binding_possible(left, right, a, b, effect, requirement):
    if len(effect) != len(requirement):
        return False
    # Bound factorial work and report the cap in the selection protocol.
    arity = len(effect) - 1
    if arity > 6:
        return False
    for order in permutations(range(arity)):
        if all(_type_match(left, a['parameters'][effect[i + 1]],
                           right, b['parameters'][requirement[j + 1]])
               for i, j in enumerate(order)):
            return True
    return False


def _links(left, right, profiles, pn, qn):
    links = []
    for an, a in sorted(profiles[left.id].items()):
        for bn, b in sorted(profiles[right.id].items()):
            # A persisted fact (precondition re-added unchanged) is not a
            # producer. The consumer must also have a new positive consequence.
            adds = [(i, atom) for i, (sign, atom) in enumerate(a['effects'])
                    if sign and atom[0] == pn and (True, atom) not in a['preconditions']
                    and (False, atom) not in a['effects']]
            needs = [(j, atom) for j, (sign, atom) in enumerate(b['preconditions'])
                     if sign and atom[0] == qn]
            if not any(sign and atom[0] != qn and (True, atom) not in b['preconditions']
                       and (False, atom) not in b['effects'] for sign, atom in b['effects']):
                continue
            for (i, eff), (j, pre) in product(adds, needs):
                if _binding_possible(left, right, a, b, eff, pre):
                    links.append({'producer': left.id, 'consumer': right.id,
                        'producer_action': an, 'consumer_action': bn,
                        'producer_literal_index': i, 'consumer_literal_index': j})
    return links


def census_pairs(sources, *, max_predicates=8, max_actions=4):
    """Retrieve causal interfaces before lexical-only candidates, within old caps."""
    profiles, excluded = profiles_for_selection(sources)
    pairs = candidate_pairs([sources[s] for s in sorted(sources)],
                            max_predicates=100000, max_actions=max_actions)
    for pair in pairs:
        left, right = [sources[s] for s in pair['sources']]
        predicates = [c for c in pair['candidates'] if c['kind'] == 'predicate']
        actions = [c for c in pair['candidates'] if c['kind'] == 'action']
        for c in predicates:
            pn, qn = [ref.split(':', 1)[1] for ref in c['references']]
            links = (_links(left, right, profiles, pn, qn) + _links(right, left, profiles, qn, pn)
                     if c['lexical_score'] > 0 else [])
            # No lexical evidence: retain as a fallback candidate, never count
            # arbitrary same-arity pairs as promising causal edges.
            c['potential_links'] = links if c['lexical_score'] > 0 else []
            c['source_pair'] = pair['sources']
        predicates.sort(key=lambda c: (-bool(c['potential_links']),
            -len({(x['producer'], x['consumer'], x['producer_action'], x['consumer_action'])
                  for x in c['potential_links']}), -c['lexical_score'], c['references']))
        actions.sort(key=lambda c: (-c['lexical_score'], c['references']))
        pair['candidates'] = predicates[:max_predicates] + [
            {**c, 'source_pair': pair['sources']} for c in actions]
        retained = pair['candidates']
        links = [x for c in retained for x in c.get('potential_links', [])]
        pair['directed_edges'] = sorted({(x['producer'], x['consumer']) for x in links})
        pair['action_pair_count'] = len({(x['producer'], x['consumer'],
            x['producer_action'], x['consumer_action']) for x in links})
        pair['weighted_links'] = sum(round(1000 * c['lexical_score']) * len(c.get('potential_links', []))
                                     for c in retained)
    return pairs, excluded


def group_score(ids, pairs):
    edges, actions, weight = set(), 0, 0
    for pair in combinations(ids, 2):
        row = pairs[tuple(sorted(pair))]
        edges.update(tuple(x) for x in row['directed_edges'])
        actions += row['action_pair_count']
        weight += row['weighted_links']
    adjacency = {s: set() for s in ids}
    for a, b in edges:
        adjacency[a].add(b)
        adjacency[b].add(a)
    unseen, largest = set(ids), 0
    while unseen:
        todo, component = [min(unseen)], set()
        while todo:
            node = todo.pop()
            if node in component:
                continue
            component.add(node)
            todo.extend(adjacency[node] - component)
        unseen -= component
        largest = max(largest, len(component))
    return (largest if edges else 0, len(edges), actions, weight)


def select_top_groups(source_ids, pair_rows, *, groups_per_size=100, sizes=(2, 3, 4)):
    ids = sorted(source_ids)
    if len(ids) != len(set(ids)) or groups_per_size < 1:
        raise ValueError('Invalid source IDs or group count')
    by_pair = {tuple(p['sources']): p for p in pair_rows}
    groups, coverage = [], []
    for k in sizes:
        if not 2 <= k <= 4 or comb(len(ids), k) < groups_per_size:
            raise ValueError('Insufficient combinations or unsupported size')
        def ranked():
            for members in combinations(ids, k):
                score = group_score(members, by_pair)
                yield tuple(-x for x in score), members
        # Exhaustive enumeration, deterministic lexical tie-break, bounded heap.
        top = nsmallest(groups_per_size, ranked())
        for index, (negative, members) in enumerate(top, 1):
            gid = f'causal_k{k:02d}_{index:03d}'
            anchors = min(combinations(members, 2),
                key=lambda p: (tuple(-x for x in group_score(p, by_pair)), p))
            groups.append({'id': gid, 'size': k, 'selection_rank': index,
                'sources': list(members), 'anchor_sources': list(anchors),
                'chain_id': gid, 'sampling_stratum': 'deterministic_causal_opportunity',
                'semantic_relation_label': None,
                'causal_opportunity': dict(zip(SCORE_FIELDS, (-x for x in negative)))})
        counts = Counter(s for _, members in top for s in members)
        coverage.append({'size': k, 'enumerated_combinations': comb(len(ids), k),
            'selected_groups': len(top), 'source_frequencies': dict(sorted(counts.items())),
            'unique_sources': len(counts), 'independent_groups': False,
            'fully_connected_groups': sum(-score[0] == k for score, _ in top)})
    return groups, coverage

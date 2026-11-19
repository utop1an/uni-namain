"""Outcome-blind random and action-path-based domain group selection.

Paths are retrieval evidence, not executable plans or semantic equivalences.
Every intermediate vertex is the same action schema on both adjacent edges.
"""
from collections import Counter, defaultdict
import hashlib
from itertools import combinations
from math import comb

from rcnc.causal_domain_selection import (
    census_pairs, group_score, profiles_for_selection, _links, _type_match,
)

SIZES = (2, 3, 4, 5)
RANK_FIELDS = ('max_path_sources_desc', 'max_path_count_desc',
               'shortest_max_path_actions_asc', 'directed_source_edges_desc',
               'producer_consumer_action_pairs_desc', 'lexical_weight_desc',
               'source_ids_asc')


class HashRandom:
    """Specified SHA256 counter stream with unbiased rejection sampling."""
    def __init__(self, seed):
        self.seed, self.counter = seed, 0

    def below(self, n):
        if not 0 < n <= 2**256:
            raise ValueError('Invalid draw range')
        ceiling = 2**256 - (2**256 % n)
        while True:
            message = f'{self.seed}\x00{self.counter}'.encode('utf-8')
            self.counter += 1
            value = int.from_bytes(hashlib.sha256(message).digest(), 'big')
            if value < ceiling:
                return value % n


def unrank_combination(ids, k, rank):
    if not 0 <= rank < comb(len(ids), k):
        raise ValueError('Combination rank out of range')
    result, start = [], 0
    for remaining in range(k, 0, -1):
        for index in range(start, len(ids) - remaining + 1):
            block = comb(len(ids) - index - 1, remaining - 1)
            if rank < block:
                result.append(ids[index])
                start = index + 1
                break
            rank -= block
    return tuple(result)


def random_groups(source_ids, k, count, seed):
    ids = sorted(source_ids)
    if len(ids) != len(set(ids)) or k not in SIZES or count < 1:
        raise ValueError('Invalid sampling parameters')
    total = comb(len(ids), k)
    if total < count:
        raise ValueError('Insufficient distinct domain combinations')
    rng, selected = HashRandom(seed), set()
    # Floyd's uniform subset sampling; no features or outcomes are inputs.
    for j in range(total - count, total):
        draw = rng.below(j + 1)
        selected.add(j if draw in selected else draw)
    return [(rank, unrank_combination(ids, k, rank)) for rank in sorted(selected)]


def action_graph(sources, pairs):
    """Retain evidence for every action edge; collapse parallel predicate edges."""
    profiles, excluded = profiles_for_selection(sources)
    evidence = defaultdict(list)
    for pair in pairs:
        for candidate in pair['candidates']:
            for link in candidate.get('potential_links', []):
                a = (link['producer'], link['producer_action'])
                b = (link['consumer'], link['consumer_action'])
                evidence[a, b].append({**link, 'kind': 'cross_source_candidate',
                    'candidate_id': candidate['id'], 'references': candidate['references']})
    for sid, source in sorted(sources.items()):
        for predicate in sorted(source.domain.predicates):
            for link in _links(source, source, profiles, predicate, predicate):
                a, b = (sid, link['producer_action']), (sid, link['consumer_action'])
                if a == b:
                    continue
                pa, pb = profiles[sid][a[1]], profiles[sid][b[1]]
                effect = pa['effects'][link['producer_literal_index']][1]
                pre = pb['preconditions'][link['consumer_literal_index']][1]
                # A source-local predicate has fixed argument roles: no permutation.
                if not all(_type_match(source, pa['parameters'][x], source, pb['parameters'][y])
                           for x, y in zip(effect[1:], pre[1:])):
                    continue
                evidence[a, b].append({**link, 'kind': 'source_local_support',
                                      'references': [sid + ':' + predicate]})
    edges = []
    for index, ((a, b), reasons) in enumerate(sorted(evidence.items()), 1):
        edges.append({'id': f'e{index:06d}', 'from': list(a), 'to': list(b),
                      'evidence': reasons})
    return {'edges': edges, 'excluded_scoring_actions': excluded,
            'supported_actions': {s: sorted(p) for s, p in profiles.items()}}


def path_inventory(graph, *, max_sources=5, max_local_hops=2, max_visits=2_000_000):
    adjacency = defaultdict(list)
    for edge in graph['edges']:
        adjacency[tuple(edge['from'])].append((tuple(edge['to']), edge['id']))
    for value in adjacency.values():
        value.sort()
    records, visits = {}, 0

    def walk(nodes, edge_ids, seen):
        nonlocal visits
        visits += 1
        if visits > max_visits:
            # Never freeze a silently truncated path census.
            raise ValueError('Path enumeration budget exceeded; no complete freeze')
        k = len(seen)
        if k >= 2 and nodes[-1][0] != nodes[-2][0]:
            key = tuple(sorted(seen))
            row = records.setdefault(key, {'count': 0, 'witness': None})
            row['count'] += 1
            witness = {'nodes': [list(n) for n in nodes], 'edge_ids': list(edge_ids)}
            if row['witness'] is None or (len(nodes), witness['nodes']) < (
                    len(row['witness']['nodes']), row['witness']['nodes']):
                row['witness'] = witness
        if k == max_sources:
            return
        for nxt, eid in adjacency.get(nodes[-1], []):
            if nxt in nodes:
                continue
            local = nxt[0] == nodes[-1][0]
            if (not local and nxt[0] in seen) or (local and len(nodes) - k >= max_local_hops):
                continue
            walk(nodes + [nxt], edge_ids + [eid], seen | {nxt[0]})

    for node in sorted(adjacency):
        walk([node], [], {node[0]})
    return {'visited_prefixes': visits, 'complete_within_declared_fragment': True,
            'records': [{'sources': list(ids), **row} for ids, row in sorted(records.items())]}


def describe_group(ids, pair_index, path_index):
    best_size, count, witness = 0, 0, None
    for size in range(len(ids), 1, -1):
        available = [path_index[x] for x in combinations(ids, size) if x in path_index]
        if available:
            best_size = size
            count = sum(x['count'] for x in available)
            witness = min((x['witness'] for x in available),
                          key=lambda x: (len(x['nodes']), x['nodes']))
            break
    score = group_score(ids, pair_index)
    return {'max_path_sources': best_size, 'max_path_count': count,
            'shortest_max_path_actions': len(witness['nodes']) if witness else None,
            'full_k_path_candidate': best_size == len(ids), 'witness': witness,
            'directed_source_edges': score[1], 'producer_consumer_action_pairs': score[2],
            'lexical_weight': score[3]}


def ranking_key(ids, description):
    d = description
    return (-d['max_path_sources'], -d['max_path_count'],
            d['shortest_max_path_actions'] or 10**9, -d['directed_source_edges'],
            -d['producer_consumer_action_pairs'], -d['lexical_weight'], tuple(ids))


def select_comparison(source_ids, pairs, paths, *, cohort, count=50, seed, sizes=SIZES):
    ids = sorted(source_ids)
    if len(ids) != len(set(ids)):
        raise ValueError('Duplicate source IDs')
    pair_index = {tuple(p['sources']): p for p in pairs}
    if set(pair_index) != set(combinations(ids, 2)):
        raise ValueError('Incomplete source-pair census')
    path_index = {tuple(p['sources']): p for p in paths['records']}
    groups, summary = [], []
    for k in sizes:
        if k not in SIZES or count < 1 or comb(len(ids), k) < count:
            raise ValueError('Insufficient distinct domain combinations')
        random = random_groups(ids, k, count, f'{seed}|{cohort}|k={k}')
        full_paths = [key for key in path_index if len(key) == k]
        # Complete k-path groups strictly dominate every partial-path group.
        # This exact pruning avoids enumerating 5.46M irrelevant combinations.
        universe = full_paths if len(full_paths) >= count else combinations(ids, k)
        ranked = sorted(((members, describe_group(members, pair_index, path_index))
                         for members in universe), key=lambda x: ranking_key(*x))[:count]
        for method, chosen in [('random', [(m, describe_group(m, pair_index, path_index), rank)
                                           for rank, m in random]),
                               ('causal_path', [(m, d, None) for m, d in ranked])]:
            rows = []
            for i, (members, desc, combination_rank) in enumerate(chosen, 1):
                gid = f'{cohort}__{method}__k{k:02d}__{i:03d}'
                row = {'id': gid, 'cohort': cohort, 'method': method, 'size': k,
                       'selection_index': i, 'sources': list(members),
                       'combination_rank': combination_rank, 'path_features': desc,
                       'semantic_relation_label': None}
                rows.append(row)
            groups.extend(rows)
            frequencies = Counter(s for g in rows for s in g['sources'])
            summary.append({'cohort': cohort, 'method': method, 'k': k,
                'registered_groups': count, 'distinct_groups': len({tuple(g['sources']) for g in rows}),
                'universe_combinations': comb(len(ids), k),
                'full_k_path_groups_in_universe': len(full_paths),
                'selected_full_k_path_groups': sum(g['path_features']['full_k_path_candidate'] for g in rows),
                'selected_max_path_sources': {str(n): total for n, total in sorted(
                    Counter(g['path_features']['max_path_sources'] for g in rows).items())},
                'source_frequencies': {sid: frequencies[sid] for sid in ids}})
    overlaps = [{'k': k, 'same_group_in_both_methods': len(
        {tuple(g['sources']) for g in groups if g['size'] == k and g['method'] == 'random'} &
        {tuple(g['sources']) for g in groups if g['size'] == k and g['method'] == 'causal_path'})}
        for k in sizes]
    return {'groups': groups, 'cells': summary, 'method_overlap': overlaps}

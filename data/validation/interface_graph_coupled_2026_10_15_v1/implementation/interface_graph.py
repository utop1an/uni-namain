"""Audit joint consistency of pairwise hypotheses; never certify semantics.

All equivalence edges are retained for auditing. An inconsistent connected
component is withheld in full, avoiding an order-dependent greedy repair.
"""
from collections import defaultdict, deque


def audit_graph(edges, exclusions=()):
    adjacency = defaultdict(list)
    sources, arities, seen = {}, {}, set()
    for edge in edges:
        key, left, right = edge['id'], edge['left'], edge['right']
        order = edge['right_from_left']
        if key in seen or left == right:
            raise ValueError('Duplicate edge id or reflexive edge')
        seen.add(key)
        if (not isinstance(order, list) or any(type(x) is not int for x in order)
                or sorted(order) != list(range(len(order)))):
            raise ValueError('Expected an explicit bijective argument map')
        for ref in (left, right):
            if not isinstance(ref, str) or ':' not in ref:
                raise ValueError('Expected source:predicate reference')
            sources[ref] = ref.split(':', 1)[0]
            if ref in arities and arities[ref] != len(order):
                raise ValueError('Inconsistent predicate arity')
            arities[ref] = len(order)
        inverse = [order.index(j) for j in range(len(order))]
        # Canonical slot k is represented at member position order_member[k].
        adjacency[left].append((right, inverse, key))
        adjacency[right].append((left, order, key))
    visited, components = set(), []
    for root in sorted(adjacency):
        if root in visited:
            continue
        positions = {root: list(range(arities[root]))}
        queue, conflicts, edge_ids = deque([root]), [], set()
        while queue:
            left = queue.popleft()
            visited.add(left)
            for right, transform, key in sorted(adjacency[left]):
                edge_ids.add(key)
                proposed = [transform[j] for j in positions[left]]
                if right not in positions:
                    positions[right] = proposed
                    queue.append(right)
                elif positions[right] != proposed:
                    conflicts.append({'kind': 'permutation_cycle', 'edge_id': key,
                                      'member': right, 'existing': positions[right],
                                      'proposed': proposed})
        by_source = defaultdict(list)
        for ref in sorted(positions):
            by_source[sources[ref]].append(ref)
        for source, refs in sorted(by_source.items()):
            if len(refs) > 1:
                conflicts.append({'kind': 'within_source_collapse', 'source': source,
                                  'members': refs})
        for edge in sorted(exclusions, key=lambda e: e['id']):
            if edge['left'] in positions and edge['right'] in positions:
                conflicts.append({'kind': 'non_equivalence_inside_component',
                                  'edge_id': edge['id'], 'label': edge['label']})
        components.append({'root': root, 'members': sorted(positions),
            'canonical_positions': dict(sorted(positions.items())),
            'edge_ids': sorted(edge_ids), 'conflicts': conflicts,
            'status': 'withheld' if conflicts else 'structurally_consistent_unverified'})
    return {'components': components, 'equivalence_edges': len(edges),
            'component_count': len(components),
            'consistent_components': sum(not c['conflicts'] for c in components),
            'withheld_components': sum(bool(c['conflicts']) for c in components),
            'semantic_equivalence_verified': False, 'automatic_alignment_adoption': False,
            'policy': 'Withhold entire inconsistent components; no greedy edge repair; '
                      'same-source predicate collapse forbidden; types not inferred'}

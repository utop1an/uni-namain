import itertools
import unittest

from rcnc.interface_graph import audit_graph


def edge(key, left, right, order):
    return {'id': key, 'left': left, 'right': right, 'right_from_left': order}


class InterfaceGraphTests(unittest.TestCase):
    def test_all_three_slot_triangle_compositions(self):
        permutations = list(itertools.permutations(range(3)))
        for ab, bc, ac in itertools.product(permutations, repeat=3):
            # Independent concrete-value transport, not graph traversal.
            expected = [ab[j] for j in bc]
            result = audit_graph([edge('ab', 'A:p', 'B:q', list(ab)),
                                  edge('bc', 'B:q', 'C:r', list(bc)),
                                  edge('ac', 'A:p', 'C:r', list(ac))])
            self.assertEqual(result['consistent_components'], int(expected == list(ac)))

    def test_non_self_inverse_chain_and_reversed_edges(self):
        edges = [edge('ab', 'A:p', 'B:q', [1, 2, 0]),
                 edge('bc', 'B:q', 'C:r', [2, 0, 1]),
                 edge('ac', 'A:p', 'C:r', [0, 1, 2])]
        result = audit_graph(edges)
        component = result['components'][0]
        self.assertEqual(result['consistent_components'], 1)
        self.assertEqual(component['canonical_positions']['B:q'], [2, 0, 1])
        self.assertEqual(component['canonical_positions']['C:r'], [0, 1, 2])
        reversed_edges = [edge(e['id'], e['right'], e['left'],
                               [e['right_from_left'].index(j) for j in range(3)])
                          for e in reversed(edges)]
        self.assertEqual(result, audit_graph(reversed_edges))
        # Independently reconstruct each predicate's grounded arguments.
        values = ['alice', 'key', 'room']
        actual = {}
        for ref, order in component['canonical_positions'].items():
            actual[ref] = [values[order.index(j)] for j in range(3)]
        for e in edges:
            self.assertEqual(actual[e['right']],
                             [actual[e['left']][j] for j in e['right_from_left']])

    def test_bad_cycle_withholds_whole_component(self):
        result = audit_graph([edge('ab', 'A:p', 'B:q', [1, 0]),
                              edge('bc', 'B:q', 'C:r', [1, 0]),
                              edge('ac', 'A:p', 'C:r', [1, 0])])
        self.assertEqual(result['withheld_components'], 1)
        self.assertEqual(len(result['components'][0]['edge_ids']), 3)
        self.assertTrue(all(c['kind'] == 'permutation_cycle'
                            for c in result['components'][0]['conflicts']))

    def test_source_collapse_and_excluded_pair(self):
        result = audit_graph([edge('ab', 'A:p', 'B:q', [0]),
                              edge('ba', 'B:q', 'A:r', [0])],
                             [{'id': 'negative', 'left': 'A:p', 'right': 'A:r',
                               'label': 'incompatible'}])
        self.assertEqual({c['kind'] for c in result['components'][0]['conflicts']},
                         {'within_source_collapse', 'non_equivalence_inside_component'})

    def test_zero_arity_and_invalid_map(self):
        self.assertEqual(audit_graph([edge('ab', 'A:p', 'B:q', [])])['consistent_components'], 1)
        for order in ([0, 0], [True], [1]):
            with self.assertRaises(ValueError):
                audit_graph([edge('ab', 'A:p', 'B:q', order)])
        self.assertEqual(audit_graph([])['component_count'], 0)


if __name__ == '__main__':
    unittest.main()

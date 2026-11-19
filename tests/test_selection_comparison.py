from itertools import combinations
import json
from pathlib import Path
from types import SimpleNamespace
import tempfile
import unittest

from rcnc.causal_domain_selection import _type_match
from rcnc.glaive_merge import Source
from rcnc.causal_path_selection import (
    action_graph, census_pairs, describe_group, path_inventory, random_groups,
    select_comparison, unrank_combination,
)
from scripts.data.freeze_selection_comparison import copy_checked, source_census
from tests.test_causal_domain_selection import source


def graph(*edges):
    return {'edges': [{'id': str(i), 'from': a, 'to': b}
                      for i, (a, b) in enumerate(edges)]}


def empty_pairs(ids):
    return [{'sources': list(p), 'directed_edges': [], 'action_pair_count': 0,
             'weighted_links': 0} for p in combinations(sorted(ids), 2)]


class SelectionComparisonTests(unittest.TestCase):
    def test_unranking_matches_complete_lexical_universe(self):
        ids = list('abcdefgh')
        for k in (2, 3, 4, 5):
            universe = list(combinations(ids, k))
            self.assertEqual([unrank_combination(ids, k, i) for i in range(len(universe))], universe)

    def test_uniform_draw_is_reproducible_unique_and_order_independent(self):
        ids = [f's{i:02d}' for i in range(12)]
        for k in (2, 3, 4, 5):
            first = random_groups(ids, k, 50, 'fixed')
            self.assertEqual(first, random_groups(ids[::-1], k, 50, 'fixed'))
            self.assertEqual(len({m for _, m in first}), 50)
            self.assertTrue(all(len(set(m)) == k for _, m in first))
        with self.assertRaisesRegex(ValueError, 'Insufficient'):
            random_groups(list('abc'), 2, 50, 'fixed')
        self.assertEqual({m for _, m in random_groups(list('abcd'), 2, 6, 'x')},
                         set(combinations('abcd', 2)))

    def test_domain_connectivity_without_action_continuity_is_not_a_path(self):
        paths = path_inventory(graph((['a', 'produce'], ['b', 'consume']),
                                     (['b', 'unrelated'], ['c', 'finish'])))
        self.assertEqual({tuple(r['sources']) for r in paths['records']}, {('a', 'b'), ('b', 'c')})

    def test_local_support_connects_same_action_chain_and_no_source_revisit(self):
        paths = path_inventory(graph((['a', 'produce'], ['b', 'consume']),
                                     (['b', 'consume'], ['b', 'continue']),
                                     (['b', 'continue'], ['c', 'finish'])))
        abc = next(r for r in paths['records'] if r['sources'] == ['a', 'b', 'c'])
        self.assertEqual(abc['witness']['nodes'],
                         [['a', 'produce'], ['b', 'consume'], ['b', 'continue'], ['c', 'finish']])
        self.assertEqual(len(abc['witness']['edge_ids']), 3)
        without = path_inventory(graph((['a', 'produce'], ['b', 'consume']),
                                       (['b', 'consume'], ['b', 'continue']),
                                       (['b', 'continue'], ['c', 'finish'])), max_local_hops=0)
        self.assertFalse(any(len(r['sources']) == 3 for r in without['records']))
        revisits = path_inventory(graph((['a', 'first'], ['b', 'act']),
                                        (['b', 'act'], ['a', 'second']),
                                        (['a', 'second'], ['c', 'act'])))
        abc = next(r for r in revisits['records'] if r['sources'] == ['a', 'b', 'c'])
        self.assertEqual(abc['count'], 1)
        self.assertEqual(abc['witness']['nodes'], [['b', 'act'], ['a', 'second'], ['c', 'act']])

    def test_prefix_budget_cannot_silently_produce_partial_freeze(self):
        with self.assertRaisesRegex(ValueError, 'budget exceeded'):
            path_inventory(graph((['a', 'x'], ['b', 'y'])), max_visits=1)

    def test_full_path_beats_many_partial_paths_and_partial_rows_stay_in_denominator(self):
        ids = list('abcdef')
        paths = {'records': [
            {'sources': list('abc'), 'count': 1,
             'witness': {'nodes': [[x, 'act'] for x in 'abc'], 'edge_ids': ['1', '2']}},
            {'sources': list('de'), 'count': 1000,
             'witness': {'nodes': [[x, 'act'] for x in 'de'], 'edge_ids': ['3']}}]}
        result = select_comparison(ids, empty_pairs(ids), paths, cohort='fixture', count=5, seed='fixed', sizes=(3,))
        causal = [g for g in result['groups'] if g['method'] == 'causal_path']
        self.assertEqual(causal[0]['sources'], list('abc'))
        self.assertEqual(len(causal), 5)
        self.assertEqual(sum(g['path_features']['full_k_path_candidate'] for g in causal), 1)
        self.assertTrue(all(g['semantic_relation_label'] is None for g in result['groups']))

    def test_random_selection_is_unchanged_by_features(self):
        ids = list('abcdefg')
        pairs = empty_pairs(ids)
        first = select_comparison(ids, pairs, {'records': []}, cohort='f', count=5, seed='f')
        pairs[0].update(directed_edges=[['a', 'b']], action_pair_count=999, weighted_links=999)
        second = select_comparison(ids[::-1], pairs[::-1], {'records': []}, cohort='f', count=5, seed='f')
        pick = lambda result: [g['sources'] for g in result['groups'] if g['method'] == 'random']
        self.assertEqual(pick(first), pick(second))

    def test_k5_chain_is_recognized(self):
        ids = list('abcde')
        paths = path_inventory(graph(*[([a, 'act'], [b, 'act']) for a, b in zip(ids, ids[1:])]))
        index = {tuple(r['sources']): r for r in paths['records']}
        desc = describe_group(tuple(ids), {tuple(p['sources']): p for p in empty_pairs(ids)}, index)
        self.assertTrue(desc['full_k_path_candidate'])
        self.assertEqual(desc['shortest_max_path_actions'], 5)

    def test_secondary_type_parent_supports_retrieval(self):
        a = SimpleNamespace(type_parents={'dual': {'person', 'place'}, 'person': {'object'},
                                        'place': {'object'}, 'object': set()})
        b = SimpleNamespace(type_parents={'place': {'object'}, 'object': set()})
        self.assertTrue(_type_match(a, 'dual', b, 'place'))

    def test_graph_evidence_and_world_independence(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            sources = {'a': source(root, 'a', '(token ?x)', '(ready ?x)'),
                       'b': source(root, 'b', '(ready ?x)', '(done ?x)')}
            pairs, _ = census_pairs(sources)
            before = action_graph(sources, pairs)
            self.assertTrue(any(e['from'] == ['a', 'act'] and e['to'] == ['b', 'act'] for e in before['edges']))
            path = sources['a'].problem_path
            path.write_text(path.read_text(encoding='utf-8').replace('(token p)', '(ready p)'), encoding='utf-8')
            sources['a'] = Source('a', sources['a'].domain_path, path)
            after = action_graph(sources, census_pairs(sources)[0])
            self.assertEqual(before, after)
            persisted_pairs, _ = source_census(sources)
            self.assertEqual(persisted_pairs, json.loads(json.dumps(persisted_pairs)))

    def test_input_copy_checks_hash_and_never_overwrites(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            original, target = root / 'original', root / 'target'
            original.write_bytes(b'original')
            with self.assertRaisesRegex(ValueError, 'Changed input'):
                copy_checked(original, target, 'wrong')
            self.assertFalse(target.exists())
            copy_checked(original, target)
            with self.assertRaisesRegex(ValueError, 'overwrite'):
                copy_checked(original, target)


if __name__ == '__main__':
    unittest.main()

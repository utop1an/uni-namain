from itertools import combinations
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from rcnc.causal_domain_selection import census_pairs, group_score, select_top_groups
from rcnc.glaive_merge import Source
from scripts.experiments import run_causal_multistory as runner


def source(root, sid, pre, effect, typ='person'):
    domain, problem = root / (sid + '.pddl'), root / (sid + '_problem.pddl')
    domain.write_text(f'''(define (domain {sid}) (:requirements :adl)
      (:types person place - object)
      (:predicates (ready ?x - {typ}) (done ?x - {typ}) (token ?x - {typ}))
      (:action act :parameters (?x - {typ}) :precondition {pre} :effect {effect}))''', encoding='utf-8')
    problem.write_text(f'''(define (problem {sid}) (:domain {sid}) (:objects p - {typ})
      (:init (token p)) (:goal (done p)))''', encoding='utf-8')
    return Source(sid, domain, problem)


class CausalSelectionTests(unittest.TestCase):
    def test_producer_consumer_direction_and_type_mismatch(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            sources = {'a': source(root, 'a', '(token ?x)', '(ready ?x)'),
                       'b': source(root, 'b', '(ready ?x)', '(done ?x)'),
                       'c': source(root, 'c', '(ready ?x)', '(done ?x)', 'place')}
            pairs, _ = census_pairs(sources)
            by = {tuple(p['sources']): p for p in pairs}
            self.assertIn(('a', 'b'), by['a', 'b']['directed_edges'])
            self.assertNotIn(('b', 'a'), by['a', 'b']['directed_edges'])
            self.assertEqual(by['a', 'c']['directed_edges'], [])

    def test_readding_required_fact_is_not_a_producer(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            sources = {'a': source(root, 'a', '(ready ?x)', '(ready ?x)'),
                       'b': source(root, 'b', '(ready ?x)', '(done ?x)')}
            pairs, _ = census_pairs(sources)
            self.assertEqual(pairs[0]['action_pair_count'], 0)

    def test_negative_effect_does_not_supply_positive_requirement(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            sources = {'a': source(root, 'a', '(token ?x)', '(not (ready ?x))'),
                       'b': source(root, 'b', '(ready ?x)', '(done ?x)')}
            pairs, _ = census_pairs(sources)
            self.assertEqual(pairs[0]['directed_edges'], [])

    def test_causal_candidate_survives_cap_ahead_of_unused_same_name(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            sources = {'a': source(root, 'a', '(token ?x)', '(ready ?x)'),
                       'b': source(root, 'b', '(ready ?x)', '(done ?x)')}
            pairs, _ = census_pairs(sources, max_predicates=1, max_actions=0)
            self.assertEqual(pairs[0]['candidates'][0]['references'], ['a:ready', 'b:ready'])
            before = pairs
            sources['a'].problem_path.write_text(sources['a'].problem_path.read_text(encoding='utf-8').replace('(done p)', '(ready p)'), encoding='utf-8')
            after, _ = census_pairs(sources, max_predicates=1, max_actions=0)
            self.assertEqual(before, after)

    def test_connected_group_beats_dense_disconnected_pair_and_order_is_stable(self):
        ids = list('abcdef')
        rows = []
        for a, b in combinations(ids, 2):
            active = (a, b) in [('a', 'b'), ('b', 'c'), ('d', 'e')]
            rows.append({'sources': [a, b], 'directed_edges': [[a, b]] if active else [],
                'action_pair_count': (100 if a == 'd' else 1) if active else 0,
                'weighted_links': (100000 if a == 'd' else 1000) if active else 0})
        groups, coverage = select_top_groups(ids, rows, groups_per_size=3)
        triples = [g for g in groups if g['size'] == 3]
        self.assertEqual(triples[0]['sources'], list('abc'))
        again, _ = select_top_groups(ids[::-1], rows[::-1], groups_per_size=3)
        self.assertEqual(groups, again)
        self.assertEqual([c['enumerated_combinations'] for c in coverage], [15, 20, 15])
        self.assertEqual(len({tuple(g['sources']) for g in groups}), 9)
        self.assertTrue(all(g['semantic_relation_label'] is None for g in groups))

    def test_no_lexical_support_does_not_turn_same_arity_into_causal_edge(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            sources = {'a': source(root, 'a', '(token ?x)', '(ready ?x)'),
                       'b': source(root, 'b', '(token ?x)', '(done ?x)')}
            pairs, _ = census_pairs(sources)
            self.assertEqual(pairs[0]['directed_edges'], [])

    def test_multi_repeat_protocol_is_rejected_before_any_model_call(self):
        with patch.object(runner.base, 'verify', return_value={'repeats': [{}, {}]}), \
             patch.object(runner.model_semantics_parallel, 'run') as request:
            with self.assertRaisesRegex(ValueError, 'Exactly one'):
                runner.pipeline(Path('unused'))
            request.assert_not_called()

    def test_stopped_model_stage_never_compiles_or_retries(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / 'protocol.json').write_text('{}', encoding='utf-8')
            with patch.object(runner.base, 'verify', return_value={'repeats': [{}]}), \
                 patch.object(runner.model_semantics_parallel, 'run', return_value={
                     'execution_status': 'stopped', 'stop_reason': 'transport_failure'}) as request, \
                 patch.object(runner.base, 'compile_models') as compile_models, \
                 patch.object(runner, 'evidence_inventory', return_value='verified_snapshot'):
                result = runner.pipeline(root)
                self.assertEqual(result['status'], 'stopped_model_stage_incomplete')
                self.assertEqual(result['completed_repeats'], 0)
                request.assert_called_once()
                compile_models.assert_not_called()
                with self.assertRaisesRegex(ValueError, 'Fresh pipeline'):
                    runner.pipeline(root)


if __name__ == '__main__':
    unittest.main()

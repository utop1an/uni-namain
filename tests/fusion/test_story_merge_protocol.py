import tempfile
import unittest
from pathlib import Path

from rcnc.pddl import parse_domain
from rcnc.story_merge_protocol import census, schema_witness, translate_calls
from rcnc.validation import validate_artifacts


class StoryMergeProtocolTests(unittest.TestCase):
    def test_census_does_not_align_equal_spelled_source_constants(self):
        template = '(define (domain d) (:requirements :strips :typing) (:types entity) (:constants home - entity) (:predicates (at ?x - entity ?y - entity)) (:action move :parameters (?x - entity) :precondition (and) :effect (at ?x home)))'
        with tempfile.TemporaryDirectory() as td:
            path = Path(td) / 'domain.pddl'; path.write_text(template, encoding='utf-8')
            report = census({'A': parse_domain(path), 'B': parse_domain(path)})
            self.assertEqual(1, report['rows'][0]['coarse_count'])
            self.assertEqual([], report['selected'])

    def test_effect_match_does_not_supply_semantic_answer_and_retains_zero_pairs(self):
        template = '(define (domain d) (:requirements :strips :typing) (:types entity) (:predicates (done ?x - entity)) (:action NAME :parameters (?x - entity) :precondition (and) :effect (done ?x)))'
        with tempfile.TemporaryDirectory() as td:
            path = Path(td) / 'domain.pddl'; path.write_text(template.replace('NAME', 'marry'), encoding='utf-8'); a = parse_domain(path)
            path.write_text(template.replace('NAME', 'propose'), encoding='utf-8'); b = parse_domain(path)
            report = census({'A': a, 'B': b})
            self.assertEqual(1, len(report['selected']))
            self.assertNotIn('model_judgment', report['selected'][0])
            b.actions.clear()
            self.assertEqual(0, census({'A': a, 'B': b})['rows'][0]['coarse_count'])

    def test_witness_preserves_types_constants_and_negative_preconditions(self):
        domain = '(define (domain d) (:requirements :strips :typing :negative-preconditions) (:types entity item) (:constants token - item) (:predicates (has ?x - entity ?i - item)) (:action pass :parameters (?x ?y - entity) :precondition (and (has ?x token) (not (has ?y token))) :effect (and (has ?y token) (not (has ?x token)))))'
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); (root / 'domain.pddl').write_text(domain, encoding='utf-8'); d = parse_domain(root / 'domain.pddl')
            query, problem, plan = schema_witness('A', d, 'pass')
            (root / 'problem.pddl').write_text(problem, encoding='utf-8'); (root / 'plan.txt').write_text(plan, encoding='utf-8')
            self.assertIn('A:token', query['initial'][0])
            self.assertEqual('VALID', validate_artifacts(root)['status'])

    def test_plan_transport_uses_parameter_bijection_and_constant_map(self):
        meta = {'constant_maps': {'A': {'token': 's_token'}}, 'action_maps': {'A': {'pass': 'shared'}},
                'action_parameter_maps': {'A': {'pass': [1, 0]}}}
        self.assertEqual([['shared', 's_token', 'o_actor']], translate_calls('A', meta, {'objects': {'actor': 'o_actor'}}, [['pass', 'actor', 'token']]))
        meta['action_parameter_maps']['A']['pass'] = [0, 0]
        with self.assertRaisesRegex(ValueError, 'bijection'):
            translate_calls('A', meta, {'objects': {'actor': 'o_actor'}}, [['pass', 'actor', 'token']])


if __name__ == '__main__': unittest.main()

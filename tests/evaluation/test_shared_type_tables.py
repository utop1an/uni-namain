"""Scientific accounting for the fresh shared-type campaign."""
from pathlib import Path
import tempfile
import unittest
import json

from scripts.experiments.run_shared_type_tables import check, table_metrics
from rcnc.domain_building import digest


class SharedTableAccountingTests(unittest.TestCase):
    def test_official_export_types_admit_foreign_character_but_not_location(self):
        from scripts.experiments.run_shared_type_official_followup import shared_official_types
        from rcnc.native_axiom_replay import replay_native_axioms
        from rcnc.pddl import parse_sexpr
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            meta = {'type_encoding': 'native_shared', 'shared_type_parents': {'character': 'object', 'location': 'object'},
                    'type_maps': {'a': {'object': 'object', 'character': 'character'},
                                  'b': {'object': 'object', 'character': 'character'}}, 'shared_constant_types': {}}
            (root / 'mapping.json').write_text(json.dumps(meta), encoding='utf-8')
            (root / 'problem.pddl').write_text('(define (problem p) (:domain d) (:objects foreign - character room - location) (:init) (:goal (done)))', encoding='utf-8')
            d = parse_sexpr('(define (domain d) (:requirements :adl :typing) (:types) (:predicates (a_type_character ?x - object) (b_type_character ?x - object) (done)) (:action act :parameters (?who - object) :precondition (a_type_character ?who) :effect (done)))')
            p = parse_sexpr('(define (problem p) (:domain d) (:objects foreign room - object) (:init (b_type_character foreign)) (:goal (done)))')
            d, p = shared_official_types(d, p, {'mapping': str(root / 'mapping.json'), 'problem': str(root / 'problem.pddl')})
            plan = parse_sexpr('(define (plan test) (:problem p) (:steps (act foreign)))')
            good = replay_native_axioms(d, p, plan, quantified_action_effects=True)
            self.assertEqual(good['status'], 'replayed')
            self.assertTrue(good['goal'])
            bad = parse_sexpr('(define (plan test) (:problem p) (:steps (act room)))')
            result = replay_native_axioms(d, p, bad, quantified_action_effects=True)
            self.assertNotEqual(result['status'], 'replayed')

    def test_failures_remain_and_ambiguous_chains_are_not_confirmed(self):
        base = {'kind': 'composition', 'cohort': 'story', 'method': 'random',
                'size': 2, 'condition': 'full', 'native_pass': True,
                'dual_pass': True, 'status': 'dual_validated'}
        rows = []
        for status in ('confirmed', 'ambiguous', 'absent'):
            rows.append({**base, 'attribution': {'source_count_profile': {
                'at_least': {'2': {'status': status}}}}})
        rows.append({**base, 'dual_pass': False, 'native_pass': False, 'status': 'world_type_incompatible'})
        result = table_metrics(rows)['table_2'][0]
        self.assertEqual(result['registered'], 4)
        self.assertEqual(result['dual_validated'], 3)
        self.assertEqual(result['C_at_least_2'], {'confirmed': 1, 'ambiguous': 1, 'absent': 1})

    def test_frozen_paths_are_strings_and_changed_inputs_fail_closed(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp) / 'input.txt'
            p.write_text('frozen', encoding='utf-8')
            spec = {'input_sha256': {str(p): digest(p)}}
            check(spec)
            p.write_text('changed', encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'Frozen input changed'):
                check(spec)


if __name__ == '__main__':
    unittest.main()

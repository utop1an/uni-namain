import copy
import json
from pathlib import Path
import tempfile
import unittest

from rcnc.pddl import section
from rcnc.source_action_variants import ast, build_variants, map_world
from scripts.audit.audit_birt_action_policy import check_registry, grounded_trace
from scripts.experiments.run_birt_action_policy import slots


class SourceActionVariantsTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.addCleanup(self.temp.cleanup)
        self.a = self.root / 'A_domainfile.pddl'
        self.b = self.root / 'B_domainfile.pddl'
        self.reference = self.root / 'reference.pddl'
        self.a.write_text('''(define (domain source_a) (:requirements :strips :typing)
          (:types thing - object) (:constants x - thing)
          (:predicates (at ?v - thing) (has ?v - thing) (state ?v - thing))
          (:action make :parameters (?v - thing) :precondition (at ?v)
            :effect (and (has ?v) (not (at ?v)))))''', encoding='utf-8')
        self.b.write_text('''(define (domain source_b) (:requirements :strips :typing)
          (:types thing - object) (:constants y - thing)
          (:predicates (has ?v - thing) (done ?v - thing) (state ?v - thing))
          (:action consume :parameters (?v - thing) :precondition (has ?v) :effect (done ?v)))''', encoding='utf-8')
        self.reference.write_text('''(define (domain merged) (:requirements :strips :typing)
          (:types thing - object) (:constants x y - thing)
          (:predicates (at ?v - thing) (has ?v - thing) (done ?v - thing) (state ?v - thing))
          (:action rewritten :parameters (?v - thing) :precondition (has ?v) :effect (done ?v)))''', encoding='utf-8')
        self.meta = {'predicate_maps': {'A': {p: p for p in ['at', 'has', 'state']},
                                        'B': {p: p for p in ['has', 'done', 'state']}},
                     'constant_maps': {'A': {'x': 'x'}, 'B': {'y': 'y'}}}

    def build(self, policy='all', meta=None):
        return build_variants(self.reference, {'A': self.a, 'B': self.b}, meta or self.meta,
                              policy, self.root / ('out_' + policy))

    def test_complete_actions_inverse_and_delete_effect(self):
        before = self.a.read_bytes(), self.b.read_bytes(), self.reference.read_bytes()
        info = self.build()
        self.assertEqual(info['action_count'], 2)
        self.assertTrue(all(c['roundtrip_equal'] for c in info['action_roundtrips']))
        self.assertEqual(before, (self.a.read_bytes(), self.b.read_bytes(), self.reference.read_bytes()))
        with self.assertRaisesRegex(ValueError, 'empty'):
            self.build()

    def test_interface_ablations_only_split_registered_aliases(self):
        for policy in ('all', 'has_only', 'no_share', 'without_has'):
            info = self.build(policy)
            a, b = [info['source_maps'][s]['predicates'] for s in ['A', 'B']]
            self.assertEqual(a['has'] == b['has'], policy in ('all', 'has_only'))
            self.assertEqual(a['state'] == b['state'], policy in ('all', 'without_has'))
            self.assertEqual(info['action_count'], 2)

    def test_used_signature_mismatch_rejected(self):
        self.reference.write_text(self.reference.read_text(encoding='utf-8').replace('(has ?v - thing)', '(has ?v - object)'), encoding='utf-8')
        with self.assertRaisesRegex(ValueError, 'signature'): self.build()

    def test_unused_signature_mismatch_retained_explicitly(self):
        self.reference.write_text(self.reference.read_text(encoding='utf-8').replace('(state ?v - thing)', '(state ?v - object)'), encoding='utf-8')
        info = self.build()
        self.assertEqual(len(info['predicate_signature_mismatches']), 2)
        self.assertTrue(all(not m['used_in_action'] for m in info['predicate_signature_mismatches']))

    def test_noninjective_mapping_rejected(self):
        meta = copy.deepcopy(self.meta); meta['predicate_maps']['A']['at'] = 'has'
        with self.assertRaisesRegex(ValueError, 'injective'): self.build(meta=meta)

    def test_quantified_action_rejected(self):
        self.a.write_text(self.a.read_text(encoding='utf-8').replace(':precondition (at ?v)', ':precondition (forall (?z - thing) (at ?z))'), encoding='utf-8')
        with self.assertRaisesRegex(ValueError, 'STRIPS'): self.build()

    def test_explicit_initial_required_and_no_facts_added(self):
        info = self.build()
        problem = self.root / 'p.pddl'
        problem.write_text('(define (problem p) (:domain source_a) (:init (at x)) (:goal (has x)))', encoding='utf-8')
        mapped = map_world(problem, info['source_maps']['A'], self.root / 'mapped.pddl')
        self.assertEqual(section(mapped, ':init'), [':init', ['pred__at', 'obj__x']])
        problem.write_text('(define (problem p) (:domain source_a) (:goal (has x)))', encoding='utf-8')
        with self.assertRaisesRegex(ValueError, 'initial'): map_world(problem, info['source_maps']['A'], self.root / 'bad.pddl')

    def test_actual_ground_dependency_and_missing_arguments(self):
        info = self.build()
        run = self.root / 'out_all/planning'
        (run / 'problem.pddl').write_text('(define (problem p) (:domain domain__merged) (:init (pred__at obj__x)) (:goal (pred__done obj__x)))', encoding='utf-8')
        (run / 'plan.txt').write_text('(act__a__make obj__x)\n(act__b__consume obj__x)\n', encoding='utf-8')
        trace = grounded_trace(run, info['action_ownership'])
        self.assertEqual(len(trace['cross_source_dependencies']), 1)
        self.assertEqual(trace['cross_source_dependencies'][0]['producer']['step'], 1)
        (run / 'plan.txt').write_text('(act__a__make)\n', encoding='utf-8')
        with self.assertRaisesRegex(ValueError, 'arguments'): grounded_trace(run, info['action_ownership'])


class ActionPolicyRegistryTests(unittest.TestCase):
    def setUp(self):
        self.protocol = json.loads(Path('paper/records/protocols/birt_action_policy_protocol_2026_10_25_v1.json').read_text(encoding='utf-8'))
        self.rows = [{**r, 'admission_status': 'ready'} for r in slots(self.protocol)]
        self.manifest = {'task_count': 40, 'slots': self.rows}
        self.report = {'task_count': 40, 'rows': [{**r, 'status': 'unsolvable'} for r in self.rows],
                       'actual_solver_calls': 40, 'status_counts': {'unsolvable': 40}}

    def test_complete_registry(self):
        check_registry(self.protocol, self.manifest, self.report)

    def test_lost_row_rejected(self):
        self.report['rows'].pop()
        with self.assertRaisesRegex(ValueError, 'slots'): check_registry(self.protocol, self.manifest, self.report)

    def test_zero_calls_cannot_claim_completed_search(self):
        self.report['actual_solver_calls'] = 0
        with self.assertRaisesRegex(ValueError, 'call'): check_registry(self.protocol, self.manifest, self.report)

    def test_false_summary_rejected(self):
        self.report['status_counts'] = {'solved': 40}
        with self.assertRaisesRegex(ValueError, 'counts'): check_registry(self.protocol, self.manifest, self.report)


if __name__ == '__main__':
    unittest.main()

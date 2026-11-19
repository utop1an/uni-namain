from pathlib import Path
import tempfile
import unittest

from unified_planning.io import PDDLReader
from scripts.experiments.reference_prefix_compare import compare_states_public


SOURCE = '''(define (domain source) (:requirements :strips :typing)
    (:types item) (:constants a - item)
    (:predicates (p ?x - item) (q ?x - item) (never))
    (:action finish :parameters (?x - item) :precondition (p ?x)
        :effect (and (not (p ?x)) (q ?x))))'''
TARGET = '''(define (domain target) (:requirements :strips :typing)
    (:types mapped_u) (:constants z - mapped_u)
    (:predicates (rp ?x - mapped_u) (rq ?x - mapped_u) (rnever) (required))
    (:action mapped :parameters (?x - mapped_u) :precondition (rp ?x)
        :effect (and (not (rp ?x)) (rq ?x))))'''


class ReferencePrefixPublicCompareTests(unittest.TestCase):
    def setUp(self):
        self.root = Path(self.enterContext(tempfile.TemporaryDirectory()))

    def compare(self, source=SOURCE, target=TARGET, source_init='(p a)', target_init='(rp z)',
                objects=None, max_atoms=100):
        files = {'s.pddl':source, 't.pddl':target,
            'sp.pddl':f'(define (problem s) (:domain source) (:init {source_init}) (:goal (never)))',
            'tp.pddl':f'(define (problem t) (:domain target) (:init {target_init}) (:goal (rnever)))',
            's.plan':'(finish a)\n', 't.plan':'(mapped z)\n'}
        for name,text in files.items(): (self.root / name).write_text(text, encoding='utf-8')
        reader = PDDLReader()
        left = reader.parse_problem(str(self.root / 's.pddl'), str(self.root / 'sp.pddl'))
        right = reader.parse_problem(str(self.root / 't.pddl'), str(self.root / 'tp.pddl'))
        a = reader.parse_plan(left, str(self.root / 's.plan')); b = reader.parse_plan(right, str(self.root / 't.plan'))
        return compare_states_public(left, right, a, b, {'p':'rp','q':'rq','never':'rnever'},
                                     objects or {'a':'z'}, max_atoms=max_atoms)

    def test_static_false_target_precondition_is_explicit_applicability_divergence(self):
        target = TARGET.replace(':precondition (rp ?x)', ':precondition (and (rp ?x) (required))')
        result = self.compare(target=target)
        self.assertEqual('FAIL', result['status'])
        self.assertEqual('applicability_divergence', result['failure_kind'])
        self.assertEqual(1, result['inapplicable_step'])
        self.assertTrue(result['source_applicable']); self.assertFalse(result['target_applicable'])
        self.assertEqual(3, result['truth_comparisons'])
        self.assertFalse(result['complete'])

    def test_invalid_source_prefix_is_separate_from_target_semantic_failure(self):
        result = self.compare(source_init='', target_init='')
        self.assertEqual('source_prefix_inapplicable', result['status'])
        self.assertFalse(result['source_applicable']); self.assertFalse(result['target_applicable'])
        self.assertEqual(0, result['mismatch_count'])

    def test_truth_mismatch_and_atom_limit_keep_evidence_completeness_distinct(self):
        result = self.compare(target_init='(rp z) (rq z)')
        self.assertEqual(('FAIL', 1, True), (result['status'], result['mismatch_count'], result['complete']))
        self.assertEqual(6, result['truth_comparisons'])
        limited = self.compare(max_atoms=1)
        self.assertEqual(('atom_limit', 0, False), (limited['status'], limited['truth_comparisons'], limited['complete']))
        with self.assertRaises(ValueError): self.compare(max_atoms=True)

    def test_incomplete_target_type_projection_is_unknown_not_a_truth_counterexample(self):
        source = SOURCE.replace('(:constants a - item)', '(:constants a b - item)')
        target = TARGET.replace('(:types mapped_u)', '(:types mapped_u - object narrow - mapped_u)')
        target = target.replace('(:constants z - mapped_u)', '(:constants z - narrow w - mapped_u)')
        target = target.replace('?x - mapped_u', '?x - narrow')
        result = self.compare(source=source, target=target, objects={'a':'z','b':'w'})
        self.assertEqual('unverified_predicate_type_projection', result['status'])
        self.assertEqual(0, result['truth_comparisons'])
        self.assertFalse(result['complete'])
        self.assertNotIn('mismatch_count', result)
        self.assertTrue(result['prefix_replay_complete'])
        self.assertEqual(2,result['states_replayed'])
        self.assertFalse(result['truth_projection_complete'])

    def test_applicability_divergence_remains_known_when_truth_projection_is_unknown(self):
        source = SOURCE.replace('(:constants a - item)', '(:constants a b - item)')
        target = TARGET.replace('(:types mapped_u)', '(:types mapped_u - object narrow - mapped_u)')
        target = target.replace('(:constants z - mapped_u)', '(:constants z - narrow w - mapped_u)')
        target = target.replace('?x - mapped_u', '?x - narrow')
        target = target.replace(':precondition (rp ?x)', ':precondition (and (rp ?x) (required))')
        result = self.compare(source=source,target=target,objects={'a':'z','b':'w'})
        self.assertEqual('FAIL',result['status'])
        self.assertEqual('applicability_divergence',result['failure_kind'])
        self.assertEqual('unverified_predicate_type_projection',result['projection_status'])
        self.assertFalse(result['truth_projection_complete'])
        self.assertEqual(0,result['truth_comparisons'])
        self.assertTrue(result['source_applicable']); self.assertFalse(result['target_applicable'])


if __name__ == '__main__':
    unittest.main()

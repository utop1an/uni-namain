from pathlib import Path
import tempfile
import unittest

from scripts.audit.audit_glaive_language_traces import compare, executed_projection


def result(literals):
    return {'status': 'trace_complete', 'completed_steps': 0,
            'states': [{'step': 0, 'literals': literals, 'goal': False, 'unexplained_steps': 0, 'orphan_steps': 0}]}


class LanguageTraceTests(unittest.TestCase):
    def test_state_comparison_keeps_intentions_and_rejects_foreign_business_effects(self):
        native = result(['(at alice)', '(intends alice (at alice))'])
        variant = {'predicate_map': {'at': ['s_at', [0]]}, 'terms': {'alice': 's_alice'}, 'auxiliaries': ['s_active']}
        target = result(['(s_at s_alice)', '(intends s_alice (s_at s_alice))', '(s_active)'])
        self.assertEqual(compare(native, target, variant)['status'], 'trace_match')
        target['states'][0]['literals'].append('(other_business foreign)')
        self.assertEqual(compare(native, target, variant)['status'], 'trace_mismatch')
        self.assertTrue(compare(native, target, variant)['checks'][0]['extra'])

    def test_incomplete_native_trace_is_not_promoted_to_preservation(self):
        self.assertEqual(compare({'status': 'wall_time_limit'}, result([]), {})['status'], 'unavailable_complete_trace')

    def test_projection_records_counterfactuals_and_header_change_without_source_mutation(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); original = root / 'reference.pddl'; problem = root / 'problem.pddl'
            original.write_text('(define (plan p) (:problem wrong) (:steps (go A) (non-executed (take A B))))', encoding='utf-8')
            problem.write_text('(define (problem right) (:init) (:goal (done)))', encoding='utf-8')
            data = original.read_bytes()
            record = executed_projection(original, problem, root / 'projection.pddl')
            self.assertEqual(original.read_bytes(), data)
            self.assertEqual(record['executed_steps'], 1)
            self.assertEqual(len(record['excluded_nonexecuted']), 1)
            self.assertEqual(record['original_problem_reference'], [':problem', 'wrong'])
            self.assertEqual(record['projected_problem_reference'], 'right')


if __name__ == '__main__': unittest.main()

import unittest
from scripts.audit.summarize_action_reachability import classify


class ReachabilitySummaryTests(unittest.TestCase):
    def rows(self, status='wall_time_limit'):
        return [{'id': 'a', 'source': 'S', 'target_action': 'a', 'status': 'PASS',
                 'solver_status': 'solved', 'visited_actions': ['a', 'b']},
                {'id': 'b', 'source': 'S', 'target_action': 'b', 'status': 'no_valid_trace', 'solver_status': status}]

    def test_other_prefix_can_witness_timed_out_target(self):
        rows = classify(self.rows())
        self.assertEqual(rows[1]['status'], 'witnessed_reachable')
        self.assertEqual(rows[1]['target_solver_status'], 'wall_time_limit')
        self.assertEqual(rows[1]['witness_task_ids'], ['a'])

    def test_unsolvable_witness_conflict_is_not_hidden(self):
        self.assertEqual(classify(self.rows('unsolvable'))[1]['status'], 'contradictory_evidence')

    def test_failed_audit_cannot_witness_reachability(self):
        rows = self.rows()
        rows[0]['status'] = 'FAIL'
        self.assertTrue(all(r['status'] == 'unresolved' for r in classify(rows)))

    def test_prior_original_world_prefix_keeps_solver_outcome(self):
        rows = self.rows()
        rows[0]['status'] = 'no_valid_trace'
        result = classify(rows, {('S', 'b'): ['prior:original/task']})
        self.assertEqual(result[1]['status'], 'witnessed_reachable')
        self.assertEqual(result[1]['target_solver_status'], 'wall_time_limit')


if __name__ == '__main__':
    unittest.main()

import copy
import unittest
from scripts.audit.audit_composed_development import check_design


class ComposedAuditTests(unittest.TestCase):
    def setup_design(self):
        tasks = []
        for world in ('bridge_needed', 'source_ready_control', 'empty_world_control'):
            for method in ('zero_merge_membership', 'authored_possession_interface'):
                for policy in ('explicit_pair', 'all_domains', 'goal_dependencies'):
                    tasks.append({'id': world+method+policy, 'world': world, 'method': method, 'policy': policy,
                                  'query': {'objects': {}, 'initial': [], 'goal': {'positive': []}, 'seconds': 60, 'solver': 'pyperplan'}})
        return {'tasks': tasks, 'task_count': 18}, {'status': 'complete', 'rows': [{'id': t['id']} for t in tasks]}

    def test_missing_failed_or_duplicate_rows_cannot_shrink_denominator(self):
        manifest, report = self.setup_design()
        self.assertEqual([], check_design(manifest, report))
        report['rows'].pop()
        self.assertIn('result_denominator_mismatch', check_design(manifest, report))
        report['rows'].append(copy.deepcopy(report['rows'][0]))
        self.assertIn('result_denominator_mismatch', check_design(manifest, report))
        report['status'] = 'running'
        self.assertIn('run_not_complete', check_design(manifest, report))

    def test_world_or_budget_changes_are_not_a_matched_comparison(self):
        for field, value in [('initial', [['ready', 'hero']]), ('seconds', 120), ('goal', {'positive': [['other']]})]:
            manifest, report = self.setup_design()
            manifest['tasks'][1]['query'][field] = value
            self.assertIn('unmatched_world_goal_or_budget:bridge_needed', check_design(manifest, report))


if __name__ == '__main__':
    unittest.main()

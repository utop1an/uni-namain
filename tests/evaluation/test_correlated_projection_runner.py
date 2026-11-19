import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from rcnc.domain_building import digest
from scripts.experiments.run_correlated_projection import VARIANTS, execute, expand_tasks


def fixture_tasks():
    conditions = [('full', 'aligned_selected_sources'), ('full', 'zero_merge_same_source_action_sets'),
                  ('recompiled', 'aligned_selected_recompiled'), ('recompiled', 'zero_merge_selected_recompiled')]
    return [{'id': f'p{index}__{condition}', 'pair_id': f'p{index}', 'cohort': cohort, 'condition': condition}
            for index in range(6) for cohort, condition in conditions]


class CorrelatedProjectionRunnerTests(unittest.TestCase):
    def test_complete_pairing_alternates_order_and_rejects_missing_or_duplicate_inputs(self):
        tasks = fixture_tasks(); expanded = expand_tasks(tasks)
        self.assertEqual(48, len(expanded))
        self.assertEqual(48, len({r['id'] for r in expanded}))
        self.assertEqual(list(VARIANTS) + list(VARIANTS[::-1]), [r['variant'] for r in expanded[:4]])
        for task in tasks:
            rows = [r for r in expanded if r['input_id'] == task['id']]
            self.assertEqual({False, True}, {r['correlated_parameter_tuples'] for r in rows})
        with self.assertRaisesRegex(ValueError, 'All24'):
            expand_tasks(tasks[:-1])
        tasks[0]['condition'] = tasks[1]['condition']
        with self.assertRaisesRegex(ValueError, 'four exact'):
            expand_tasks(tasks)

    def test_witness_axis_has_exact_pairs_without_switching_tuple_join(self):
        expanded = expand_tasks(fixture_tasks(), 'precondition_witness_representatives')
        self.assertEqual(48, len(expanded))
        self.assertEqual({'cartesian_projection','precondition_witness'}, {r['variant'] for r in expanded})
        self.assertFalse(any('correlated_parameter_tuples' in r for r in expanded))
        self.assertEqual(24, sum(r['precondition_witness_representatives'] for r in expanded))
        with self.assertRaisesRegex(ValueError, 'Unknown registered'):
            expand_tasks(fixture_tasks(), 'unregistered_pruning')

    def test_late_budget_retains_all48_rows_and_no_search_or_input_drift_acceptance(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); tasks = fixture_tasks()
            for task in tasks:
                directory = root / 'tasks' / task['id']; directory.mkdir(parents=True)
                for name in ('domain', 'problem'):
                    path = directory / (name + '.pddl'); path.write_text('(fixture)', encoding='utf-8')
                    task[name + '_sha256'] = digest(path)
            base_path = root / 'input_registry.json'
            base_path.write_text(json.dumps({'tasks': tasks}), encoding='utf-8')
            protocol = root / 'protocol.json'; protocol.write_text('{}', encoding='utf-8')
            manifest = {'status': 'frozen_before_search', 'input_registry_sha256': digest(base_path),
                'tasks': expand_tasks(tasks), 'task_count': 48, 'protocol_sha256': digest(protocol),
                'implementation_sha256': {}, 'scope': 'authored gate fixture',
                'budget': {'whole_goal_stop_before_utc': '2000-01-01T00:00:00Z', 'wall_seconds_per_process': 20}}
            protocol.write_text(json.dumps({'budget':manifest['budget'], 'scope':manifest['scope'],
                                            'variants':list(VARIANTS)}), encoding='utf-8')
            manifest['protocol_sha256'] = digest(protocol)
            (root / 'manifest.json').write_text(json.dumps(manifest), encoding='utf-8')
            with patch('scripts.experiments.run_correlated_projection.subprocess.run') as run:
                result = execute(root)
            run.assert_not_called()
            self.assertEqual(0, result['actual_search_processes'])
            self.assertEqual({'not_run_due_goal_budget': 48}, result['status_counts'])
            self.assertEqual({'not_run_due_goal_budget': 24}, result['by_variant'][VARIANTS[0]])
            self.assertTrue(result['inputs_unchanged'])
            with self.assertRaisesRegex(ValueError, 'fresh complete'):
                execute(root)

    def test_budget_drift_is_rejected_before_looking_for_or_starting_searches(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            base = root / 'input_registry.json'; base.write_text('{}', encoding='utf-8')
            protocol = {'budget':{'wall_seconds_per_process':20}, 'scope':'fixed', 'variants':list(VARIANTS)}
            (root / 'protocol.json').write_text(json.dumps(protocol), encoding='utf-8')
            manifest = {'status':'frozen_before_search', 'budget':{'wall_seconds_per_process':200}, 'scope':'fixed'}
            (root / 'manifest.json').write_text(json.dumps(manifest), encoding='utf-8')
            with patch('scripts.experiments.run_correlated_projection.subprocess.run') as run:
                with self.assertRaisesRegex(ValueError, 'before search'):
                    execute(root)
            run.assert_not_called()


if __name__ == '__main__':
    unittest.main()

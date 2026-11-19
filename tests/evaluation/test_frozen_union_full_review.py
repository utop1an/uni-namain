import importlib.util
from pathlib import Path
import tempfile
import unittest

PATH = Path(__file__).resolve().parents[2] / 'scripts/audit/finalize_frozen_union_full_evaluation.py'
spec = importlib.util.spec_from_file_location('offline_review', PATH)
review = importlib.util.module_from_spec(spec)
spec.loader.exec_module(review)


class FrozenReviewTests(unittest.TestCase):
    def test_physical_contradiction_not_promoted_to_unknown(self):
        row = {'valid': False, 'native_valid': True, 'replay': {'physical': {'status': 'inapplicable'}}}
        self.assertEqual(review.classify(row), 'physical_violation')
        row['replay']['physical']['status'] = 'unsupported'
        self.assertEqual(review.classify(row), 'native_valid_physical_unknown')

    def test_initially_satisfied_goal_remains_separate(self):
        rows = [{'valid': True, 'native_valid': True, 'replay': {'steps': n, 'physical': {'initial_goal': initial}}}
                for n, initial in ((0, True), (1, False))]
        summary = review.summarize(rows, 3)
        self.assertEqual(summary['not_recorded'], 1)
        self.assertEqual(summary['dual_initial_goal_already_true'], 1)
        self.assertEqual(summary['dual_goal_achieved_from_initial_false'], 1)
        self.assertEqual(summary['dual_zero_steps'], 1)

    def test_all_missing_campaign_keeps_full_pair_denominators(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            groups, cells = [], []
            for pool in ('story', 'human', 'mixed'):
                for k in (2, 3, 4, 5):
                    for method in ('random', 'causal_link'):
                        cells.append({'cohort': pool, 'k': k, 'method': method,
                                      'conditions': {c: {'transport': {}} for c in ('union', 'full')}})
                        for index in range(50):
                            groups.append({'id': f'{pool}_{k}_{method}_{index}', 'cohort': pool, 'size': k,
                                           'method': method, 'sources': [f's{i}' for i in range(k)]})
            review.write(root / 'selected_groups.json', {'groups': groups})
            review.write(root / 'sources.json', {'sources': []})
            review.write(root / 'worlds.json', {'worlds': [{'id': f'w{i}', 'source': f's{i}'} for i in range(5)]})
            review.write(root / 'protocol.json', {})
            review.write(root / 'evaluation/report.json', {'cells': cells, 'experiment_status': 'stopped_error',
                                                          'slot_accounting': {}, 'limits': []})
            review.review(root, root / 'review')
            result = review.read(root / 'review/report.json')
            self.assertEqual(len(result['groups']), 1200)
            self.assertEqual(len(result['selection_method_contrasts']), 12)
            for cell in result['cells']:
                self.assertEqual(cell['paired']['composition']['registered_pairs'], 50)
                self.assertEqual(cell['paired']['anchor']['registered_pairs'], 100)
                self.assertEqual(cell['paired']['transport']['registered_pairs'], 50 * cell['k'])
                self.assertEqual(cell['conditions']['full']['composition']['not_recorded'], 50)
            with self.assertRaisesRegex(ValueError, 'Fresh review'):
                review.review(root, root / 'review')


if __name__ == '__main__':
    unittest.main(verbosity=2)

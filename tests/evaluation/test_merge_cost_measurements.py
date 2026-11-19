import unittest

from scripts.experiments.profile_merge_costs import log_metrics


class MergeCostMeasurementTests(unittest.TestCase):
    def test_missing_phase_measurement_is_not_zero(self):
        result = log_metrics('translator failed before instantiation', 'translation')
        self.assertNotIn('instantiation_wall_seconds', result)
        self.assertIsNone(result['translator_operators'])

    def test_instantiation_is_not_total_translation_or_substep(self):
        text = ('Completing instantiation... [0.000s CPU, 0.001s wall-clock]\n'
                'Instantiating: [0.020s CPU, 0.026s wall-clock]\n'
                'Translator operators: 23\nDone! [0.030s CPU, 0.036s wall-clock]\n')
        result = log_metrics(text, 'translation')
        self.assertEqual(.026, result['instantiation_wall_seconds'])
        self.assertEqual(23, result['translator_operators'])


if __name__ == '__main__':
    unittest.main()

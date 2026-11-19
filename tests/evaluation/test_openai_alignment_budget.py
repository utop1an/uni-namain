"""No network calls: verify spending reservations and accounting boundaries."""
import unittest
from scripts.experiments.run_openai_alignment_round import SpendGuard, usage_cost


class OpenAIAlignmentBudgetTests(unittest.TestCase):
    def test_parallel_reservations_cannot_spend_same_remaining_balance(self):
        guard = SpendGuard(1.0)
        self.assertTrue(guard.reserve(.6))
        self.assertFalse(guard.reserve(.5))
        self.assertTrue(guard.reserve(.4))
        self.assertFalse(guard.reserve(.001))

    def test_settlement_releases_unused_reservation_and_retains_actual_debit(self):
        guard = SpendGuard(1)
        guard.reserve(.8)
        self.assertTrue(guard.settle(.8, .2))
        self.assertTrue(guard.reserve(.7))
        self.assertFalse(guard.reserve(.2))
        self.assertAlmostEqual(guard.snapshot()['accounted_usd'], .2)

    def test_unknown_billing_keeps_full_liability(self):
        guard = SpendGuard(1)
        guard.reserve(.6)
        guard.settle(.6)
        self.assertFalse(guard.reserve(.5))
        self.assertAlmostEqual(guard.snapshot()['accounted_usd'], .6)

    def test_invalid_cap_is_rejected(self):
        for cap in (0, -1, float('nan'), float('inf')):
            with self.assertRaises(ValueError):
                SpendGuard(cap)

    def test_usage_is_separate_from_character_or_output_only_estimates(self):
        self.assertEqual(usage_cost({'usage': {'input_tokens': 1000, 'output_tokens': 2000}}), .022)
        for value in ({}, {'usage': {'input_tokens': -1, 'output_tokens': 1}},
                      {'usage': {'input_tokens': 1, 'output_tokens': '2'}}):
            with self.assertRaises(ValueError):
                usage_cost(value)


if __name__ == '__main__':
    unittest.main()

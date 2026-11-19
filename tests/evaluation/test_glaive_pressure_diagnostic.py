import unittest
from collections import Counter
from scripts.experiments.diagnose_glaive_memory_pressure import key, phase, select


class PressureSelectionTests(unittest.TestCase):
    def test_retains_losses_and_balances_fixed_strata_deterministically(self):
        rows = []
        phases = ('state_space_begin', 'search_setup_begin', 'search_begin', 'result')
        for i, name in enumerate(phases):
            for j in range(12):
                rows.append({'kind': 'anchor' if j % 3 else 'native', 'id': f'{i}-{j}',
                    'condition': 'full' if j % 2 else 'union', 'search': {'phase_events': [{'phase': name}]}})
        losses = {key(rows[i]) for i in (0, 1, 24, 25)}
        selected = select(rows, losses)
        self.assertEqual(len(selected), 32)
        self.assertTrue(losses <= {key(r) for r in selected})
        self.assertEqual(Counter(phase(r) for r in selected), dict.fromkeys(phases, 8))
        self.assertEqual(selected, select(list(reversed(rows)), losses))

    def test_missing_stratum_is_rejected(self):
        with self.assertRaises(ValueError):
            select([], set())


if __name__ == '__main__': unittest.main()

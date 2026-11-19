import tempfile
import unittest
from pathlib import Path

from rcnc.narrative_pipeline import map_problem
from rcnc.merged_planning import solve
from scripts.experiments.run_long_horizon_scaling import build_models, chain_query


class LongHorizonScalingTests(unittest.TestCase):
    def test_all_tokens_need_every_edge_and_controls_break_chain(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            models = build_models(root / 'models', 2)
            query = chain_query(2, 2, 3)
            results = {}
            for name, model in models.items():
                problem = root / (name + '.pddl')
                map_problem(query, model, problem)
                results[name] = solve(model / 'meta_domain.pddl', problem, root / name,
                                      max_depth=8, max_states=100, max_ground_actions=1000)
            self.assertEqual('solved', results['shared']['status'])
            self.assertEqual(6, results['shared']['length'])
            self.assertEqual('unsolvable', results['no_share']['status'])
            self.assertEqual('unsolvable', results['remove_source']['status'])


if __name__ == '__main__':
    unittest.main()

import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class PlanningWorkerTests(unittest.TestCase):
    def test_invalid_budget_is_saved_as_worker_error_with_original_exit_contract(self):
        with tempfile.TemporaryDirectory() as td:
            output = Path(td)/'worker'
            process = subprocess.run([sys.executable, str(ROOT/'run_narrative_pipeline.py'),
                '--worker', '--domain', str(Path(td)/'missing-domain.pddl'),
                '--problem', str(Path(td)/'missing-problem.pddl'), '--output', str(output),
                '--budget', '{"max_states": 0}'], cwd=ROOT, capture_output=True, text=True)
            self.assertEqual(0, process.returncode)
            self.assertEqual('', process.stdout)
            self.assertEqual({'status': 'error', 'reason': 'ValueError: Invalid budget: max_states'},
                             json.loads((output/'search.json').read_text(encoding='utf-8')))
            self.assertIn('ValueError: Invalid budget: max_states', process.stderr)


if __name__ == '__main__':
    unittest.main()

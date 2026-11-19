"""Run directly: isolates the frozen package from live-checkout imports."""
import importlib.util
from pathlib import Path
import tempfile
import unittest
import subprocess
import sys

PATH = Path(__file__).resolve().parents[2] / 'scripts/experiments/run_frozen_union_full_evaluation.py'
if __name__ == '__main__':
    spec = importlib.util.spec_from_file_location('offline_evaluation', PATH)
    runner = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(runner)
    runner.bind()
    from tests.test_revised_multistory import fixture


@unittest.skipUnless(__name__ == '__main__', 'Frozen tests run in an isolated subprocess')
class OfflineEvaluationTests(unittest.TestCase):
    def test_frozen_import_and_offline_guard(self):
        self.assertTrue(Path(runner.C.__file__).is_relative_to(runner.RELEASE / 'code'))
        with self.assertRaisesRegex(RuntimeError, 'Offline'):
            runner.offline_guard('socket.connect', ())

    def test_pairing_keeps_missing_and_native_only(self):
        rows = [{'group': 'a', 'condition': 'union', 'valid': True},
                {'group': 'a', 'condition': 'full', 'native_valid': True},
                {'group': 'b', 'condition': 'full', 'valid': True}]
        result = runner.paired(rows, ('group',), [('a',), ('b',), ('c',)])
        self.assertEqual(result['registered_pairs'], 3)
        self.assertEqual(result['both_dual_validated'], 0)
        self.assertEqual(result['full_only_dual_validated'], 1)
        self.assertIn({'union': 'not_recorded', 'full': 'not_recorded', 'pairs': 1}, result['outcome_matrix'])
        with self.assertRaisesRegex(ValueError, 'Duplicate'):
            runner.paired(rows + [rows[0]], ('group',))

    def test_replay_failure_is_not_a_success(self):
        self.assertEqual(runner.outcome({'search': {'status': 'solved'}, 'replay': {
            'status': 'replayed', 'goal': True, 'physical': {'status': 'inapplicable'}}}), 'physical_violation')
        self.assertEqual(runner.outcome({'search': {'status': 'wall_time_limit'}}), 'wall_time_limit')

    def test_five_source_compile_and_failure_denominators(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs = root / 'inputs'; inputs.mkdir()
            sources, raw = fixture(inputs, 5)
            g = {'id': 'synthetic', 'sources': [s.id for s in sources], 'size': 5,
                 'cohort': 'mixed', 'method': 'causal_link'}
            rows = [{'id': s.id, 'domain': str(s.domain_path), 'representative_problem': str(s.problem_path),
                     'constant_contract': {}, 'consent_policy': None} for s in sources]
            worlds = [{'id': s.id + '_world', 'source': s.id, 'domain': str(s.domain_path),
                       'problem': str(s.problem_path)} for s in sources]
            union = root / 'existing_union'
            meta = runner.C.build(sources, union)
            exports = []
            for w, s in zip(worlds, sources):
                p = union / (s.id + '.pddl')
                terms = runner.C.map_problem(sources, s.id, meta, p)
                exports.append({'world': w['id'], 'source': s.id, 'problem': str(p), 'terms': terms})
            for name, value in [('sources', {'sources': rows}), ('worlds', {'worlds': worlds}),
                                ('protocol', {'budgets': {'group_route_prefixes': 1000}})]:
                runner.write(root / (name + '.json'), value)
            runner.write(root / 'group_inputs/synthetic.json', {'group': g, 'judgments': raw,
                'candidate_statuses': {'checked': len(raw)},
                'union': {'domain': str(union / 'domain.pddl'), 'worlds': exports}})
            result = runner.group_worker(root, 'synthetic')
            self.assertEqual(result['status'], 'compiled')
            self.assertEqual(result['model_counts']['full']['action_count'], 1)
            self.assertEqual(len(result['source_tasks']), 10)
            self.assertEqual(sum(t['search_anchor'] for t in result['source_tasks']), 4)
            self.assertEqual(len(result['composition_tasks']), 2)
            self.assertEqual({t['condition'] for t in result['source_tasks']}, {'union', 'full'})
            fallback = runner.recover_compilation(root, g, {'status': 'worker_wall_time_limit'})
            self.assertEqual(len(fallback['source_tasks']), 10)
            self.assertEqual(fallback['status'], 'compiled')
            self.assertEqual(fallback['construction']['status'], 'unavailable_construction')


@unittest.skipIf(__name__ == '__main__', 'Parent harness only')
class IsolationHarness(unittest.TestCase):
    def test_frozen_evaluation_subprocess(self):
        result = subprocess.run([sys.executable, '-B', '-X', 'utf8', str(Path(__file__).resolve())],
                                cwd=PATH.parents[2], capture_output=True, text=True, timeout=60)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main(verbosity=2)

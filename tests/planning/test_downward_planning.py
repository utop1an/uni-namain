import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from types import SimpleNamespace

from rcnc.downward_planning import solve
from rcnc.narrative_pipeline import run
from rcnc.planning_worker import run_worker


class DownwardPlanningTests(unittest.TestCase):
    def test_exact_artifact_and_terminal_statuses_survive_adapter(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            domain, problem = root / 'selected.pddl', root / 'world.pddl'
            domain.write_text('selected parameterized model', encoding='utf-8')
            problem.write_text('explicit unchanged world', encoding='utf-8')
            for status in ('solved', 'unsolvable', 'wall_time_limit'):
                def reference(inputs, composed, output, planner, seconds, memory_mb, task_bundle):
                    self.assertEqual(20, seconds)
                    self.assertEqual(4096, memory_mb)
                    self.assertEqual(domain.read_bytes(), (task_bundle / 'tasks/query/domain.pddl').read_bytes())
                    directory = output / 'tasks/query'
                    directory.mkdir(parents=True)
                    for name in ('domain.pddl', 'problem.pddl'):
                        (directory / name).write_bytes((task_bundle / 'tasks/query' / name).read_bytes())
                    row = {'id': 'query', 'status': status, 'engine_status': status,
                           'inputs_unchanged': True, 'elapsed_seconds': 1}
                    if status == 'solved':
                        row.update(plan_length=1, validation={'status': 'VALID'})
                        (directory / 'plan.txt').write_text('(fixture)\n', encoding='utf-8')
                    report = {'status': 'complete', 'rows': [row], 'binary_unchanged': True, 'runner_unchanged': True,
                              'implementation_unchanged': True, 'validator_unchanged': True}
                    (output / 'report.json').write_text(json.dumps(report), encoding='utf-8')
                    return report
                with patch('rcnc.downward_planning.run_reference', side_effect=reference):
                    result = solve(domain, problem, root / status, root / 'planner')
                self.assertEqual(status, result['status'])
                self.assertTrue(result['inputs_unchanged'])
                self.assertEqual(problem.read_bytes(), (root / status / 'problem.pddl').read_bytes())
                self.assertEqual(status == 'solved', (root / status / 'plan.txt').exists())

    def test_invalid_budget_is_rejected_before_any_solver_call(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            with patch('rcnc.downward_planning.run_reference', side_effect=AssertionError('No solver')):
                with self.assertRaises(ValueError):
                    solve(root / 'd', root / 'p', root / 'out', root / 'planner', seconds=0)
            self.assertFalse((root / 'out').exists())

    def test_worker_dispatches_exact_resource_configuration(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            args = SimpleNamespace(mode='initial_goal', solver='fast_downward',
                domain=root / 'd', problem=root / 'p', output=root / 'out',
                budget=json.dumps({'planner': str(root / 'planner'), 'seconds': 20, 'memory_mb': 4096}))
            with patch('rcnc.downward_planning.solve', return_value={'status': 'wall_time_limit'}) as backend:
                run_worker(args)
            backend.assert_called_once_with(args.domain, args.problem, args.output,
                planner=str(root / 'planner'), seconds=20, memory_mb=4096)
            self.assertEqual('wall_time_limit', json.loads((args.output / 'search.json').read_text(encoding='utf-8'))['status'])

    def test_request_rejects_solver_budget_misuse_before_planning(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            base = {'initial': [], 'goal': {'positive': [['A:done']]}}
            variants = [{'solver': 'typed_cartesian', 'memory_mb': 4096},
                        {'solver': 'pyperplan', 'planner': 'irrelevant'},
                        {'solver': 'fast_downward', 'seconds': 0.5},
                        {'solver': 'fast_downward', 'memory_mb': True},
                        {'solver': 'fast_downward', 'planner': str(root / 'missing')}]
            for index, fields in enumerate(variants):
                result = run({**base, **fields}, root / 'unused_inputs', root / str(index))
                self.assertEqual('rejected', result['status'])
                self.assertFalse(result['planner_called'])

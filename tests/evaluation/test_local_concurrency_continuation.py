import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

PATH = Path(__file__).resolve().parents[2] / 'scripts/experiments/accelerate_frozen_union_full_local.py'
spec = importlib.util.spec_from_file_location('local_acceleration', PATH)
continuation = importlib.util.module_from_spec(spec)
spec.loader.exec_module(continuation)


def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data), encoding='utf-8')


class ConcurrencyContinuationTests(unittest.TestCase):
    def test_recover_drained_success_and_failure_without_retry(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            tasks = [{'id': name, 'status': 'ready', 'kind': 'transport'} for name in ('a','b','c')]
            events = root / 'repeat_01/transport_events.jsonl'; events.parent.mkdir()
            events.write_text(json.dumps({**tasks[0], 'status': 'complete', 'valid': True})+'\n', encoding='utf-8')
            for task in tasks[1:]:
                write(root / 'repeat_01/plan_workers/transport' / task['id'] / 'task.json', task)
            write(root / 'repeat_01/plan_workers/transport/b/worker_result.json', {**tasks[1], 'status':'complete', 'valid':True})
            write(root / 'repeat_01/plan_workers/transport/c/worker_timeout.json', {'status':'worker_wall_time_limit'})
            rows, origins = continuation.collect_retained(root, 'transport', tasks)
            self.assertEqual(set(rows), {'a','b','c'})
            self.assertEqual(origins['b'], 'drained_worker_result_not_yet_collected')
            self.assertFalse(rows['c']['valid'])
            self.assertEqual(rows['c']['search']['status'], 'worker_wall_time_limit')

    def test_started_but_unaccounted_task_blocks_resubmission(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); task={'id':'started', 'status':'ready'}
            write(root / 'repeat_01/plan_workers/transport/started/task.json', task)
            with self.assertRaisesRegex(ValueError, 'never resubmit'):
                continuation.collect_retained(root, 'transport', [task])

    def test_duplicate_and_unregistered_results_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); p=root/'repeat_01/native_events.jsonl'; p.parent.mkdir()
            p.write_text('{"id":"a"}\n{"id":"a"}\n', encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'duplicate'):
                continuation.collect_retained(root, 'native', [{'id':'a'}])


if __name__ == '__main__':
    unittest.main(verbosity=2)

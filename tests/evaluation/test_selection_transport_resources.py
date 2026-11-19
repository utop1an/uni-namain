"""Offline regression checks for resource errors and bounded worker connections."""
import copy
import errno
import json
from pathlib import Path
import tempfile
import threading
import unittest
from concurrent.futures import ThreadPoolExecutor
from unittest.mock import patch

from rcnc import model_semantics_retry as retry
from rcnc.domain_building import save


def buffer_error():
    error = OSError(errno.ENOBUFS, 'simulated socket buffer exhaustion')
    error.winerror = 10055
    return error


class FakeClient:
    def __init__(self, outcomes=None):
        self.outcomes = list(outcomes or [])
        self.calls = []
        self.closes = 0

    def __call__(self, url, request=None, timeout=None):
        self.calls.append((url, request, timeout))
        if url.endswith('/api/tags'):
            return {'models': [{'name': 'fixed', 'digest': 'fixed-hash'}]}
        outcome = self.outcomes.pop(0) if self.outcomes else {}
        if isinstance(outcome, Exception):
            raise outcome
        return outcome

    def close(self):
        self.closes += 1


class ResourceTransportTests(unittest.TestCase):
    def setUp(self):
        self.root = Path(self.enterContext(tempfile.TemporaryDirectory()))
        self.manifest = {'retry_policy': copy.deepcopy(retry.POLICY), 'request_seconds': 240}
        self.stop = threading.Event()
        self.budget = retry.AttemptBudget(200)
        self.waits = []
        network = patch('socket.socket', side_effect=AssertionError('Offline test attempted network access'))
        network.start()
        self.addCleanup(network.stop)
        decode = patch.object(retry, 'decode_payload', side_effect=lambda i,p,s,r:
                              r.update(status='checked', response={'decision': 'different'}))
        decode.start()
        self.addCleanup(decode.stop)

    def perform(self, identity, factory=FakeClient, clients=None, wait=None):
        return retry.perform({'id': identity, 'kind': 'predicate'}, {'frozen': 'request'},
            self.root / identity, self.manifest, 0, 1000, self.budget, self.stop,
            transport_factory=factory, client_pool=clients, clock=lambda: 0,
            wait_for_stop=wait or (lambda seconds: self.waits.append(seconds) or False))

    def test_buffer_errors_use_numeric_codes_and_preserve_legacy_policy(self):
        self.assertTrue(retry.transient(buffer_error()))
        self.assertTrue(retry.transient(OSError(errno.ENOBUFS, 'buffer full')))
        windows_only = OSError('localized message')
        windows_only.winerror = 10055
        self.assertTrue(retry.transient(windows_only))
        denied = OSError(errno.EACCES, 'access denied')
        denied.winerror = 10013
        self.assertFalse(retry.transient(denied))
        self.assertFalse(retry.transient(OSError('10055 in unrelated text')))
        self.assertFalse(retry.transient(ValueError('[WinError 10055] model text')))
        legacy = {k:v for k,v in retry.POLICY.items()
                  if k not in ('retryable_os_errnos', 'retryable_winerrors')}
        self.assertFalse(retry.transient(buffer_error(), legacy))

    def test_failure_closes_before_backoff_then_reuses_healthy_worker_connection(self):
        created = []
        def factory():
            client = FakeClient([buffer_error()] if not created else [])
            created.append(client)
            return client
        def backoff(seconds):
            self.assertEqual(created[-1].closes, 1)
            self.waits.append(seconds)
            return False
        with retry.WorkerClients(factory) as clients:
            first = self.perform('first', clients=clients, wait=backoff)
            second = self.perform('second', clients=clients)
            self.assertEqual([first['status'], second['status']], ['checked', 'checked'])
            self.assertEqual(len(created), 2)
            self.assertEqual([len(c.calls) for c in created], [1, 2])
            self.assertEqual(created[1].closes, 0)
            self.assertNotIn('transport_error', first)
            self.assertEqual(first['attempt_history'][0]['transport_error']['winerror'], 10055)
            self.assertEqual(self.waits, [30])
            requests = [json.loads(p.read_text(encoding='utf-8'))['request']
                        for p in sorted((self.root / 'first').glob('attempt_*/attempt.json'))]
            self.assertEqual(requests, [{'frozen': 'request'}] * 2)
        self.assertEqual([c.closes for c in created], [1, 1])

    def test_exhausted_buffer_error_is_retained_and_next_candidate_runs(self):
        created = []
        def factory():
            client = FakeClient([buffer_error()] if len(created) < 3 else [])
            created.append(client)
            return client
        with retry.WorkerClients(factory) as clients:
            failed = self.perform('failed', clients=clients)
            self.assertEqual(failed['status'], 'request_failed')
            self.assertEqual(failed['total_attempts_including_parent'], 3)
            self.assertEqual([r['transport_error']['winerror'] for r in failed['attempt_history']], [10055]*3)
            self.assertFalse(self.stop.is_set())
            self.assertNotIn('fatal_transport_failure', failed)
            self.assertEqual(self.waits, [30, 60])
            self.assertEqual(self.perform('next', clients=clients)['status'], 'checked')
        self.assertEqual([c.closes for c in created], [1]*4)
        self.assertEqual((self.budget.calls, self.budget.retries), (4, 2))

    def test_factory_failure_is_recorded_and_bounded(self):
        def factory():
            raise buffer_error()
        row = self.perform('factory', factory=factory)
        self.assertEqual(row['status'], 'request_failed')
        self.assertEqual(len(row['attempt_history']), 3)
        self.assertEqual(self.waits, [30, 60])
        self.assertEqual(len(list((self.root / 'factory').glob('attempt_*/result.json'))), 3)
        self.assertFalse(self.stop.is_set())

    def test_operator_stop_during_backoff_prevents_next_attempt(self):
        created = []
        def factory():
            client = FakeClient([buffer_error()])
            created.append(client)
            return client
        def stop_during_wait(seconds):
            self.stop.set()
            return True
        with retry.WorkerClients(factory) as clients:
            row = self.perform('stopped', clients=clients, wait=stop_during_wait)
        self.assertEqual(row['reason'], 'dispatch_stopped')
        self.assertEqual(row['new_attempts'], 1)
        self.assertEqual(len(created), 1)
        self.assertEqual(created[0].closes, 1)

    def test_workers_never_share_clients_and_close_on_exception(self):
        created = []
        barrier = threading.Barrier(4)
        def factory():
            client = FakeClient()
            created.append(client)
            return client
        with self.assertRaisesRegex(RuntimeError, 'worker failure'):
            with retry.WorkerClients(factory) as clients, ThreadPoolExecutor(max_workers=4) as pool:
                def worker(index):
                    first = clients.get()
                    barrier.wait(timeout=5)
                    self.assertIs(first, clients.get())
                    if index == 0:
                        raise RuntimeError('worker failure')
                    return first
                futures = [pool.submit(worker, i) for i in range(4)]
                for future in futures:
                    future.result()
        self.assertEqual(len(created), 4)
        self.assertEqual(len({id(c) for c in created}), 4)
        self.assertEqual([c.closes for c in created], [1]*4)

    def stage(self):
        items = [{'id': str(i), 'kind': 'predicate'} for i in range(20)]
        rows = [{**i, 'status': 'not_requested', 'request_attempted': False,
                 'reason': 'stop_after_transport_failure'} for i in items]
        save(self.root / 'parent.json', {'rows': rows, 'requests_attempted': 0, 'elapsed_seconds': 0})
        save(self.root / 'packet.json', {'items': items})
        save(self.root / 'requests.json', {i['id']: {'frozen': i['id']} for i in items})
        save(self.root / 'manifest.json', {**self.manifest, 'frozen_sha256': {},
            'implementation_sha256': {}, 'parent_report': str(self.root / 'parent.json'),
            'pending_candidates': len(items), 'total_seconds': 100, 'workers': 2,
            'model': 'fixed', 'model_digest': 'fixed-hash'})

    def test_stage_uses_bounded_worker_clients_for_many_candidates(self):
        self.stage()
        created = []
        def factory():
            client = FakeClient()
            created.append(client)
            return client
        with patch('rcnc.model_semantics.to_group', side_effect=lambda i,r:r):
            report = retry.run(self.root, transport_factory=factory)
        self.assertEqual(report['status_counts'], {'checked': 20})
        self.assertEqual(report['new_requests_attempted'], 20)
        self.assertEqual(report['new_retry_attempts'], 0)
        self.assertEqual(report['execution_status'], 'complete')
        self.assertLessEqual(len(created), 3)  # Two workers plus the preflight client.
        self.assertEqual([c.closes for c in created], [1]*len(created))
        self.assertEqual(sum(len(c.calls) for c in created), 21)

    def test_preflight_factory_failure_keeps_full_denominator_without_dispatch(self):
        self.stage()
        def factory():
            raise buffer_error()
        with patch('rcnc.model_semantics.to_group', side_effect=lambda i,r:r):
            report = retry.run(self.root, transport_factory=factory)
        self.assertEqual(report['execution_status'], 'stopped')
        self.assertEqual(report['status_counts'], {'not_requested': 20})
        self.assertEqual(report['new_requests_attempted'], 0)
        self.assertFalse((self.root / 'responses').exists())


if __name__ == '__main__':
    unittest.main()

from concurrent.futures import ThreadPoolExecutor
from contextlib import redirect_stdout
import io
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

import requests

from scripts.audit.audit_llm_attempts import audit
from scripts.experiments.run_fusion_reference import freeze, run as fresh_run
from unidomain.attempt_ledger import AttemptLedger
from unidomain.cli import main
from unidomain.models import OllamaClient


SCHEMA = {'type': 'object'}


def response(content='{"accepted": true}', **counts):
    return SimpleNamespace(status_code=200, raise_for_status=lambda: None,
                           json=lambda: {'message': {'content': content}, **counts})


class AttemptLedgerTests(unittest.TestCase):
    def client(self, root, retries=2):
        return OllamaClient(base_url='http://offline.invalid', model='fixture',
                            cache_dir=root/'cache', max_retries=retries,
                            attempt_ledger=root/'attempts.jsonl')

    def test_invalid_content_retry_counts_both_attempts_without_changing_legacy_counter(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); client = self.client(root)
            with patch('unidomain.models.requests.post', side_effect=[
                    response('broken', prompt_eval_count=7, eval_count=3),
                    response(prompt_eval_count=11, eval_count=5)]) as post:
                result = client.call('fixed', 'private prompt', SCHEMA, lambda _: None)
            self.assertTrue(result['accepted'])
            self.assertEqual(2, post.call_count)
            self.assertEqual(1, client.network_calls)
            report = audit(root/'attempts.jsonl')
            self.assertEqual('verified_recorded_attempts', report['status'])
            self.assertEqual({'invalid_content_json': 1, 'decoded_json': 1}, report['outcome_counts'])
            self.assertEqual(18, report['returned_token_counts']['prompt_eval_count']['observed_total'])
            self.assertNotIn('private prompt', (root/'attempts.jsonl').read_text(encoding='utf-8'))
            self.assertNotIn('accepted', (root/'attempts.jsonl').read_text(encoding='utf-8'))

    def test_transport_http_and_envelope_errors_do_not_acquire_new_retries(self):
        cases = [
            (requests.Timeout('offline'), 'http_request_error'),
            (SimpleNamespace(status_code=503,
                raise_for_status=lambda: (_ for _ in ()).throw(requests.HTTPError('offline'))), 'http_status_error'),
            (SimpleNamespace(status_code=200, raise_for_status=lambda: None,
                json=lambda: json.loads('broken')), 'response_json_error'),
        ]
        for value, outcome in cases:
            with self.subTest(outcome=outcome), tempfile.TemporaryDirectory() as temp:
                root = Path(temp); client = self.client(root)
                kwargs = {'side_effect': value} if isinstance(value, Exception) else {'return_value': value}
                with patch('unidomain.models.requests.post', **kwargs) as post:
                    with self.assertRaises(Exception):
                        client.call('fixed', 'prompt', SCHEMA, lambda _: None)
                self.assertEqual(1, post.call_count)
                self.assertEqual(0, client.network_calls)
                report = audit(root/'attempts.jsonl')
                self.assertEqual({outcome: 1}, report['outcome_counts'])
                self.assertEqual(1, report['returned_token_counts']['eval_count']['unknown_finished_attempts'])

    def test_cached_validation_retries_are_not_extra_http_attempts(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); client = self.client(root)
            def reject(_):
                raise ValueError('Reject structurally decoded fixture')
            with patch('unidomain.models.requests.post', return_value=response()) as post:
                with self.assertRaisesRegex(ValueError, 'failed validation'):
                    client.call('fixed', 'prompt', SCHEMA, reject)
            self.assertEqual(1, post.call_count)
            self.assertEqual(1, client.cache_hits)
            self.assertEqual({'decoded_json': 1}, audit(root/'attempts.jsonl')['outcome_counts'])

    def test_missing_or_malformed_returned_counts_stay_unknown(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); client = self.client(root)
            with patch('unidomain.models.requests.post', return_value=response(
                    prompt_eval_count=True, eval_count=-1, total_duration='unknown')):
                client.call('fixed', 'prompt', SCHEMA, lambda _: None)
            report = audit(root/'attempts.jsonl')
            self.assertEqual('verified_recorded_attempts', report['status'])
            for counts in report['returned_token_counts'].values():
                self.assertEqual(0, counts['observed_total'])
                self.assertEqual(1, counts['unknown_finished_attempts'])

    def test_existing_or_cache_shaped_ledger_is_rejected_before_http(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.client(root)
            with patch('unidomain.models.requests.post') as post:
                with self.assertRaises(FileExistsError):
                    self.client(root)
                with self.assertRaisesRegex(ValueError, '.jsonl'):
                    AttemptLedger(root/'cache/collision.json', 'fixture')
            post.assert_not_called()

    def test_intent_write_failure_prevents_dispatch_and_finish_failure_stays_unknown(self):
        for phase in ('intent', 'finish'):
            with self.subTest(phase=phase), tempfile.TemporaryDirectory() as temp:
                root = Path(temp); client = self.client(root)
                original = client.attempt_ledger.append
                def append(row):
                    if row['event'] == ('dispatch_intent' if phase == 'intent' else 'attempt_finished'):
                        raise OSError('Authored ledger write failure')
                    original(row)
                with patch.object(client.attempt_ledger, 'append', side_effect=append), \
                     patch('unidomain.models.requests.post', return_value=response()) as post:
                    with self.assertRaises(OSError):
                        client.call('fixed', 'prompt', SCHEMA, lambda _: None)
                self.assertEqual(0 if phase == 'intent' else 1, post.call_count)
                report = audit(root/'attempts.jsonl')
                self.assertEqual(0 if phase == 'intent' else 1, report['unresolved_intents'])
                self.assertEqual([], list((root/'cache').glob('*.json')))

    def test_concurrent_attempts_have_unique_paired_records(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); client = self.client(root)
            with patch('unidomain.models.requests.post', return_value=response()), \
                 ThreadPoolExecutor(max_workers=4) as pool:
                results = list(pool.map(lambda index: client.call('fixed', str(index), SCHEMA, lambda _: None), range(4)))
            self.assertEqual(4, len(results))
            report = audit(root/'attempts.jsonl')
            self.assertEqual('verified_recorded_attempts', report['status'])
            self.assertEqual(4, report['finished_attempts'])
            self.assertEqual(4, report['dispatch_intents'])

    def test_auditor_retains_partial_or_unmatched_records_and_rejects_bad_pairing(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); client = self.client(root)
            with patch('unidomain.models.requests.post', return_value=response()):
                client.call('fixed', 'prompt', SCHEMA, lambda _: None)
            lines = (root/'attempts.jsonl').read_bytes().splitlines(keepends=True)
            controls = [
                (b''.join(lines[:2]), 'incomplete_observation'),
                (b''.join(lines) + b'{"event":', 'incomplete_observation'),
                (b''.join(lines) + lines[-1], 'invalid_ledger'),
                (lines[0] + lines[2] + lines[1], 'invalid_ledger'),
                (b'broken\n' + b''.join(lines[1:]), 'invalid_ledger'),
            ]
            for index, (raw, status) in enumerate(controls):
                path = root/f'control{index}.jsonl'; path.write_bytes(raw)
                self.assertEqual(status, audit(path)['status'])

    def test_cli_explicitly_passes_ledger_path_without_constructing_real_models(self):
        runtime = SimpleNamespace(llm=SimpleNamespace(network_calls=0))
        merged = SimpleNamespace(sources=[], predicates=[], actions=[])
        with patch('sys.argv', ['fusion', '--attempt-ledger', 'fresh.jsonl']), \
             patch('unidomain.cli.FusionRuntime', return_value=runtime) as constructor, \
             patch('unidomain.cli.run', return_value=merged), redirect_stdout(io.StringIO()):
            main()
        self.assertEqual(Path('fresh.jsonl'), constructor.call_args.kwargs['attempt_ledger'])

    def test_fresh_registration_and_command_only_enable_recording_explicitly(self):
        for enabled in (False, True):
            with self.subTest(enabled=enabled), tempfile.TemporaryDirectory() as temp:
                root = Path(temp); inputs = root/'inputs'; inputs.mkdir()
                (inputs/'A_domainfile.pddl').write_text('(define (domain fixture) (:predicates (p)))', encoding='utf-8')
                output = root/'run'
                def worker(command, **kwargs):
                    (output/'fusion').mkdir()
                    (output/'fusion/validation.json').write_text('{"valid": true}', encoding='utf-8')
                    self.assertEqual(enabled, '--attempt-ledger' in command)
                    return SimpleNamespace(returncode=0)
                tags = io.BytesIO(b'{"models":[{"name":"fixture","digest":"offline-fixture"}]}')
                with patch('scripts.experiments.run_fusion_reference.urllib.request.urlopen', return_value=tags), \
                     patch('scripts.experiments.run_fusion_reference.subprocess.run', side_effect=worker):
                    result = fresh_run(inputs, output, 1, 1, 'fixture', record_http_attempts=enabled)
                manifest = json.loads((output/'manifest.json').read_text(encoding='utf-8'))
                self.assertEqual('http_attempts.jsonl' if enabled else None, manifest['http_attempt_ledger'])
                self.assertEqual('complete', result['status'])
                if enabled:
                    self.assertFalse(result['http_attempt_ledger']['exists'])
                with self.assertRaisesRegex(ValueError, 'explicit boolean'):
                    freeze(inputs, root/'invalid', 1, 1, 'fixture', record_http_attempts='yes')


if __name__ == '__main__':
    unittest.main()

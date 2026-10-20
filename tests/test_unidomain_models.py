from contextlib import redirect_stdout
import io
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

from unidomain.cli import main
from unidomain.models import OllamaClient


class ModelAdapterTests(unittest.TestCase):
    # Captured from the pre-split implementation with the same fixed request.
    cache_name = 'ad6eb4ec53802fc32cb739f736faf962671843bc4b50ecce38a02433a24b0cd3.json'
    schema = {'type': 'object', 'properties': {'accepted': {'type': 'boolean'}}}

    def client(self, directory, retries=5):
        return OllamaClient(base_url='http://offline.invalid/', model='fixed-model',
                            cache_dir=directory, max_retries=retries)

    def test_historical_wrapped_and_bare_caches_are_reused_without_network(self):
        for cached in [{'accepted': True}, {'response': {'accepted': True}}]:
            with self.subTest(cached=cached), tempfile.TemporaryDirectory() as td:
                directory = Path(td)
                (directory/self.cache_name).write_text(json.dumps(cached), encoding='utf-8')
                client = self.client(directory)
                with patch('unidomain.models.requests.post', side_effect=AssertionError('Network')):
                    result = client.call('fixed-task', 'fixed prompt', self.schema, lambda data: None)
                self.assertEqual({'accepted': True}, result)
                self.assertEqual(0, client.network_calls)
                self.assertEqual(1, client.cache_hits)

    def test_invalid_json_retains_retry_limit_and_counter_behavior(self):
        response = SimpleNamespace(raise_for_status=lambda: None,
                                   json=lambda: {'message': {'content': 'invalid-json'}})
        with tempfile.TemporaryDirectory() as td:
            client = self.client(Path(td), retries=2)
            with patch('unidomain.models.requests.post', return_value=response) as post:
                with self.assertRaisesRegex(ValueError, 'Ollama returned invalid JSON'):
                    client.call('fixed-task', 'fixed prompt', self.schema, lambda data: None)
            self.assertEqual(2, post.call_count)
            self.assertEqual(0, client.network_calls)
            self.assertEqual([], list(Path(td).glob('*.json')))

    def test_schema_rejection_retries_the_cached_response(self):
        response = SimpleNamespace(raise_for_status=lambda: None,
                                   json=lambda: {'message': {'content': '{"accepted": false}'}})
        def reject(data):
            raise ValueError('Rejected response')
        with tempfile.TemporaryDirectory() as td:
            client = self.client(Path(td), retries=2)
            with patch('unidomain.models.requests.post', return_value=response) as post:
                with self.assertRaisesRegex(ValueError, 'Ollama output failed validation'):
                    client.call('fixed-task', 'fixed prompt', self.schema, reject)
            self.assertEqual(1, post.call_count)
            self.assertEqual(1, client.network_calls)
            self.assertEqual(1, client.cache_hits)

    def test_cli_help_does_not_construct_model_runtime(self):
        with patch('sys.argv', ['unidomain_ollama_fusion.py', '--help']), \
             patch('unidomain.cli.FusionRuntime') as runtime, redirect_stdout(io.StringIO()):
            with self.assertRaises(SystemExit) as exit_result:
                main()
        self.assertEqual(0, exit_result.exception.code)
        runtime.assert_not_called()


if __name__ == '__main__':
    unittest.main()

import io
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

from scripts.experiments.run_fusion_reference import freeze as freeze_fresh
from scripts.experiments.run_fusion_continuation import freeze, run


class FusionContinuationTests(unittest.TestCase):
    def setUp(self):
        self.root = Path(self.enterContext(tempfile.TemporaryDirectory()))
        self.inputs = self.root / 'inputs'
        self.inputs.mkdir()
        (self.inputs / 'A_domainfile.pddl').write_text('(define (domain a))', encoding='utf-8')
        self.predecessor = self.root / 'fresh'
        self.manifest = freeze_fresh(self.inputs, self.predecessor, 10, 1, 'gemma3:4b')
        self.manifest.update(status='time_limit', model_digest='local-fixture')
        self.write_manifest()
        (self.predecessor / 'report.json').write_text(json.dumps({'status': 'time_limit',
            'source_snapshot_unchanged': True, 'implementation_unchanged': True, 'elapsed_seconds': 10.1}), encoding='utf-8')
        (self.predecessor / 'command.json').write_text(json.dumps({'environment_overrides':
            {'HF_HUB_OFFLINE': '1', 'TRANSFORMERS_OFFLINE': '1'}}), encoding='utf-8')
        cached = self.predecessor / 'cache/ollama/fixture.json'
        cached.parent.mkdir(parents=True)
        cached.write_text('{"response": {"fixture": true}}', encoding='utf-8')

    def write_manifest(self):
        (self.predecessor / 'manifest.json').write_text(json.dumps(self.manifest), encoding='utf-8')

    def test_imported_cache_has_separate_budget_and_does_not_change_predecessor(self):
        original = (self.predecessor / 'report.json').read_bytes()
        output = self.root / 'extended'
        manifest = freeze(self.predecessor, output, 20)
        self.assertEqual('cache_continuation_extended_budget', manifest['condition'])
        self.assertEqual(30, manifest['cumulative_registered_worker_budget_seconds'])
        self.assertEqual(1, manifest['imported_response_count'])
        self.assertEqual((self.predecessor / 'cache/ollama/fixture.json').read_bytes(),
                         (output / 'cache/ollama/fixture.json').read_bytes())
        self.assertEqual(original, (self.predecessor / 'report.json').read_bytes())
        with self.assertRaisesRegex(ValueError, 'fresh empty'):
            freeze(self.predecessor, output, 20)

    def test_active_complete_or_error_predecessor_is_not_restarted(self):
        for status in ('running', 'complete', 'worker_error'):
            self.manifest['status'] = status
            self.write_manifest()
            output = self.root / status
            with self.assertRaisesRegex(ValueError, 'terminal fresh time limit'):
                freeze(self.predecessor, output, 20)
            self.assertFalse(output.exists())

    def test_attempt_recorded_predecessor_is_not_silently_downgraded(self):
        self.manifest['http_attempt_ledger'] = 'http_attempts.jsonl'
        self.write_manifest()
        output = self.root / 'unsupported_accounting_continuation'
        with self.assertRaisesRegex(ValueError, 'continuation accounting protocol'):
            freeze(self.predecessor, output, 20)
        self.assertFalse(output.exists())

    def test_model_digest_drift_prevents_worker_start_and_timeout_is_not_completion(self):
        def tags(digest):
            return io.BytesIO(json.dumps({'models': [{'name': 'gemma3:4b', 'digest': digest}]}).encode())
        with patch('scripts.experiments.run_fusion_continuation.urllib.request.urlopen', return_value=tags('changed')), \
             patch('scripts.experiments.run_fusion_continuation.subprocess.run', side_effect=AssertionError('No worker')):
            report = run(self.predecessor, self.root / 'drift', 1)
        self.assertEqual('error', report['status'])
        self.assertIn('digest changed', report['error'])
        with patch('scripts.experiments.run_fusion_continuation.urllib.request.urlopen', return_value=tags('local-fixture')), \
             patch('scripts.experiments.run_fusion_continuation.subprocess.run', side_effect=subprocess.TimeoutExpired('fixture', 1)):
            report = run(self.predecessor, self.root / 'timeout', 1)
        self.assertEqual('time_limit', report['status'])
        self.assertEqual('cache_continuation_extended_budget', report['condition'])
        self.assertTrue(report['integrity_checks_passed'])
        self.assertEqual(11, report['cumulative_registered_worker_budget_seconds'])

    def test_expired_overall_deadline_and_changed_inputs_are_rejected(self):
        with self.assertRaisesRegex(ValueError, 'No continuation budget'):
            freeze(self.predecessor, self.root / 'expired', 20, '2000-01-01T00:00:00Z')
        (self.predecessor / 'inputs/A_domainfile.pddl').write_text('(changed)', encoding='utf-8')
        with self.assertRaisesRegex(ValueError, 'input drift'):
            freeze(self.predecessor, self.root / 'changed', 20)

    def test_continuation_preserves_registered_namespace_export_policy(self):
        self.manifest['namespace_policy'] = 'category_qualified'
        self.write_manifest()
        manifest = freeze(self.predecessor, self.root / 'qualified', 20)
        self.assertEqual('category_qualified', manifest['namespace_policy'])

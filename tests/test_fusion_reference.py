import io
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

from scripts.experiments.run_fusion_reference import freeze, run


class FusionReferenceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.inputs = self.root/'inputs'
        self.inputs.mkdir()
        (self.inputs/'A_domainfile.pddl').write_text('(define (domain a))')

    def test_freeze_keeps_source_bytes_and_refuses_overwrite(self):
        manifest = freeze(self.inputs, self.root/'frozen', 10, 1, 'gemma3:4b')
        self.assertEqual(1, manifest['source_count'])
        self.assertEqual((self.inputs/'A_domainfile.pddl').read_bytes(), (self.root/'frozen/inputs/A_domainfile.pddl').read_bytes())
        self.assertIn('unidomain_ollama_fusion.py', manifest['implementation_sha256'])
        for relative in ['unidomain/models.py', 'unidomain/fusion.py',
                         'unidomain/pipeline.py', 'unidomain/cli.py']:
            self.assertIn(relative, manifest['implementation_sha256'])
            self.assertEqual(Path(relative).read_bytes(),
                             (self.root/'frozen/implementation'/relative).read_bytes())
        with self.assertRaisesRegex(ValueError, 'fresh'):
            freeze(self.inputs, self.root/'frozen', 10, 1, 'gemma3:4b')

    def test_timeout_is_not_completion_and_remote_model_is_not_run(self):
        local = io.BytesIO(json.dumps({'models': [{'name': 'gemma3:4b', 'digest': 'local'}]}).encode())
        with patch('scripts.experiments.run_fusion_reference.urllib.request.urlopen', return_value=local), \
             patch('scripts.experiments.run_fusion_reference.subprocess.run', side_effect=subprocess.TimeoutExpired('test', 1)):
            report = run(self.inputs, self.root/'timeout', 1)
        self.assertEqual('time_limit', report['status'])
        self.assertTrue(report['source_snapshot_unchanged'])
        self.assertTrue(report['implementation_unchanged'])
        remote = io.BytesIO(json.dumps({'models': [{'name': 'gemma3:4b', 'remote_host': 'example'}]}).encode())
        with patch('scripts.experiments.run_fusion_reference.urllib.request.urlopen', return_value=remote), \
             patch('scripts.experiments.run_fusion_reference.subprocess.run', side_effect=AssertionError('Must not start cloud model')):
            report = run(self.inputs, self.root/'remote', 1)
        self.assertEqual('error', report['status'])
        self.assertIn('local model', report['error'])


if __name__ == '__main__':
    unittest.main()

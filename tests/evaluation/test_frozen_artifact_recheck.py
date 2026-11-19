import json
from pathlib import Path
import tempfile
import unittest

from rcnc.domain_building import digest
from scripts.evidence.recheck_frozen_artifacts import recheck


class FrozenArtifactRecheckTests(unittest.TestCase):
    def fixture(self, parent):
        root = parent / 'run'; root.mkdir()
        (root / 'model.pddl').write_text('frozen-model', encoding='utf-8')
        code = root / 'implementation/rcnc/fixture.py'; code.parent.mkdir(parents=True)
        code.write_text('archived-version', encoding='utf-8')
        manifest = {'input_sha256': {'model.pddl': digest(root / 'model.pddl')},
                    'implementation_sha256': {'rcnc/fixture.py': digest(code)}}
        self.save_manifest(root, manifest)
        protocol = parent / 'protocol.json'
        protocol.write_text(json.dumps({'roots': [str(root)]}), encoding='utf-8')
        return root, protocol, manifest

    def save_manifest(self, root, manifest):
        (root / 'manifest.json').write_text(json.dumps(manifest), encoding='utf-8')
        (root / 'report.json').write_text(json.dumps({'status': 'complete',
            'manifest_sha256': digest(root / 'manifest.json')}), encoding='utf-8')

    def test_input_drift_is_detected_even_when_parent_report_bytes_are_unchanged(self):
        with tempfile.TemporaryDirectory() as temp:
            parent = Path(temp); root, protocol, _ = self.fixture(parent)
            report_hash = digest(root / 'report.json')
            self.assertEqual('verified_frozen_artifacts', recheck(protocol, parent / 'before')['status'])
            (root / 'model.pddl').write_text('changed-model', encoding='utf-8')
            result = recheck(protocol, parent / 'after')
            self.assertEqual(report_hash, digest(root / 'report.json'))
            self.assertEqual('audited_with_integrity_failures', result['status'])
            self.assertEqual('mismatch', result['rows'][0]['failures'][0]['status'])

    def test_missing_archive_and_escaping_input_never_fall_back_to_current_files(self):
        with tempfile.TemporaryDirectory() as temp:
            parent = Path(temp); root, protocol, manifest = self.fixture(parent)
            (root / 'implementation/rcnc/fixture.py').unlink()
            missing = recheck(protocol, parent / 'missing')
            self.assertEqual('audited_with_integrity_failures', missing['status'])
            outside = parent / 'outside.pddl'; outside.write_text('outside', encoding='utf-8')
            manifest['input_sha256'] = {'../outside.pddl': digest(outside)}
            self.save_manifest(root, manifest)
            escaped = recheck(protocol, parent / 'escaped')
            self.assertTrue(any('escapes' in item.get('reason', '') for item in escaped['rows'][0]['failures']))


if __name__ == '__main__':
    unittest.main()

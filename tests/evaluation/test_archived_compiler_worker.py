import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from scripts.experiments.archived_compiler_worker import COMPILER_MODULES


class ArchivedCompilerWorkerTests(unittest.TestCase):
    def fixture(self, root):
        code = root / 'code'; (code / 'rcnc').mkdir(parents=True)
        for name in COMPILER_MODULES:
            (code / name).write_text('# archived fixture\n', encoding='utf-8')
        (code / 'rcnc/pddl.py').write_text("MARKER = 'archived-version'\n", encoding='utf-8')
        (code / 'rcnc/aligned_domain.py').write_text('''from rcnc.pddl import MARKER
import json
def build(inputs, output, specification):
    output.mkdir()
    (output/'meta_domain.pddl').write_text(MARKER,encoding='utf-8')
    (output/'meta_domain.json').write_text(json.dumps(specification),encoding='utf-8')
    return {'valid': True}
''', encoding='utf-8')
        alignment = root / 'alignment.json'; alignment.write_text('{}', encoding='utf-8')
        inputs = root / 'inputs'; inputs.mkdir()
        digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
        job = {'code': str(code), 'inputs': str(inputs), 'alignment': str(alignment),
            'output': str(root / 'compiled'), 'report': str(root / 'report.json'),
            'compiler_sha256': {n: digest(code / n) for n in COMPILER_MODULES},
            'input_sha256': {str(p.resolve()): digest(p) for p in [alignment, *sorted((code / 'rcnc').glob('*.py'))]}}
        return job

    def run_worker(self, root, job):
        path = root / 'job.json'; path.write_text(json.dumps(job), encoding='utf-8')
        return subprocess.run([sys.executable, '-I', '-X', 'utf8',
            str(Path('scripts/experiments/archived_compiler_worker.py').resolve()), '--job', str(path)],
            capture_output=True, encoding='utf-8', timeout=20)

    def test_isolated_child_loads_only_the_archived_package_even_inside_current_repo(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); job = self.fixture(root)
            completed = self.run_worker(root, job)
            self.assertEqual(0, completed.returncode, completed.stderr)
            self.assertEqual('archived-version', (root / 'compiled/meta_domain.pddl').read_text(encoding='utf-8'))
            report = json.loads((root / 'report.json').read_text(encoding='utf-8'))
            self.assertEqual(5, len(report['loaded_modules']))
            self.assertTrue(all(Path(v['file']).is_relative_to(root / 'code') for v in report['loaded_modules'].values()))

    def test_mismatched_code_digest_is_rejected_before_import_side_effects(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); job = self.fixture(root)
            path = root / 'code/rcnc/pddl.py'; marker = root / 'imported_tampered_code'
            path.write_text(f'from pathlib import Path\nPath({str(marker)!r}).write_text("bad")\n', encoding='utf-8')
            job['input_sha256'][str(path.resolve())] = hashlib.sha256(path.read_bytes()).hexdigest()
            completed = self.run_worker(root, job)
            self.assertNotEqual(0, completed.returncode)
            self.assertIn('before importing code', completed.stderr)
            self.assertFalse(marker.exists())
            self.assertFalse((root / 'compiled').exists())

    def test_missing_archived_dependency_does_not_fall_back_to_current_source(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); job = self.fixture(root)
            (root / 'code/rcnc/pddl.py').unlink()
            self.assertNotEqual(0, self.run_worker(root, job).returncode)
            self.assertFalse((root / 'compiled').exists())


if __name__ == '__main__':
    unittest.main()

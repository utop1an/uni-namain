import json,tempfile,unittest
import hashlib
from pathlib import Path
from unittest.mock import patch
from archive.rcnc.protocol import freeze_bundle,verify_bundle,contained,implementation_path

class ProtocolTests(unittest.TestCase):
    def test_moved_structural_checker_keeps_old_lock_and_rejects_content_drift(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            source = root/'rcnc/pddl_checks.py'
            source.parent.mkdir()
            source.write_text('# frozen checker\n', encoding='utf-8')
            (root/'rcnc/entrypoints-relocation.json').write_text(json.dumps({'files': [
                {'original_path': 'pddl_checks.py', 'current_path': 'rcnc/pddl_checks.py'}
            ]}), encoding='utf-8')
            bundle = root/'bundle'
            bundle.mkdir()
            (bundle/'manifest.json').write_text('{"tasks": []}', encoding='utf-8')
            frozen = bundle/'freeze.json'
            frozen.write_text(json.dumps({'bundle_files': {}, 'source_files': {},
                'implementation_files': {'pddl_checks.py': hashlib.sha256(source.read_bytes()).hexdigest()}}), encoding='utf-8')
            original_lock = frozen.read_bytes()
            with patch('archive.rcnc.protocol.ROOT', root):
                self.assertEqual(source, implementation_path('pddl_checks.py'))
                verify_bundle(bundle)
                source.write_text('# changed checker\n', encoding='utf-8')
                with self.assertRaisesRegex(ValueError, 'Frozen input changed'):
                    verify_bundle(bundle)
            self.assertEqual(original_lock, frozen.read_bytes())

    def test_archived_package_paths_resolve_without_rewriting_inventory(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            source = root/'archive/rcnc/old.py'
            source.parent.mkdir(parents=True)
            source.write_text('# original bytes\n', encoding='utf-8')
            inventory = root/'archive/rcnc/package-relocation.json'
            inventory.write_text(json.dumps({'files': [
                {'original_path': 'rcnc/old.py', 'archive_path': 'archive/rcnc/old.py'}
            ]}), encoding='utf-8')
            original = inventory.read_bytes()
            with patch('archive.rcnc.protocol.ROOT', root):
                self.assertEqual(source, implementation_path('rcnc/old.py'))
            self.assertEqual(original, inventory.read_bytes())

    def bundle(self,root):
        for name,value in [('registry.json',{'version':1}),('task.json',{'initial':[]}),('manifest.json',{'tasks':['task.json']})]:
            (root/name).write_text(json.dumps(value))
        freeze_bundle(root,{'tasks':['task.json']})

    def test_unchanged_bundle_verifies(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);self.bundle(root)
            self.assertEqual(['task.json'],verify_bundle(root)[0]['tasks'])

    def test_annotation_or_task_change_rejected(self):
        for name in ('registry.json','task.json'):
            with tempfile.TemporaryDirectory() as td:
                root=Path(td);self.bundle(root);(root/name).write_text('{}')
                with self.assertRaisesRegex(ValueError,'Frozen input changed'):verify_bundle(root)

    def test_refreeze_and_path_escape_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);self.bundle(root)
            with self.assertRaisesRegex(ValueError,'Already frozen'):freeze_bundle(root,{'tasks':['task.json']})
            with self.assertRaisesRegex(ValueError,'escapes'):contained(root,'../outside.json')

    def test_relocated_implementation_keeps_lock_and_still_rejects_drift(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            folder = root/'bundle'
            folder.mkdir()
            (folder/'manifest.json').write_text('{"tasks": []}', encoding='utf-8')
            source = root/'scripts/experiments/old_tool.py'
            source.parent.mkdir(parents=True)
            source.write_text('# frozen implementation\n', encoding='utf-8')
            (root/'scripts/relocation.json').write_text(json.dumps({'files': [
                {'original_path': 'old_tool.py', 'current_path': 'scripts/experiments/old_tool.py'}
            ]}), encoding='utf-8')
            lock = {'bundle_files': {}, 'source_files': {}, 'implementation_files': {
                'old_tool.py': hashlib.sha256(source.read_bytes()).hexdigest()}}
            frozen = folder/'freeze.json'
            frozen.write_text(json.dumps(lock), encoding='utf-8')
            original_lock = frozen.read_bytes()
            with patch('archive.rcnc.protocol.ROOT', root):
                self.assertEqual(lock, verify_bundle(folder)[1])
                source.write_text('# changed implementation\n', encoding='utf-8')
                with self.assertRaisesRegex(ValueError, 'Frozen input changed'):
                    verify_bundle(folder)
                # An inventory path cannot escape the repository either.
                (root/'scripts/relocation.json').write_text(json.dumps({'files': [
                    {'original_path': 'old_tool.py', 'current_path': '../outside.py'}
                ]}), encoding='utf-8')
                with self.assertRaisesRegex(ValueError, 'escapes'):
                    verify_bundle(folder)
            self.assertEqual(original_lock, frozen.read_bytes())

if __name__=='__main__':unittest.main()

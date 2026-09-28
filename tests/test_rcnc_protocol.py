import json,tempfile,unittest
from pathlib import Path
from rcnc.protocol import freeze_bundle,verify_bundle,contained

class ProtocolTests(unittest.TestCase):
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

if __name__=='__main__':unittest.main()

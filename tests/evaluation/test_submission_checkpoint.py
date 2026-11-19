import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import contextlib
import io

from rcnc.domain_building import digest
from scripts.evidence.check_submission_checkpoint import check_test_receipt, code_fingerprint, check_snapshot, main


class SubmissionCheckpointTests(unittest.TestCase):
    def test_command_exit_code_does_not_hide_an_inconsistent_checkpoint(self):
        flags=[part for key in ('index','snapshot','test-checkpoint','table-manifest','table-snapshot','output')
               for part in ('--'+key,'unused')]
        for status,code in (('checkpoint_inconsistent',1),('verified_checkpoint_consistency',0)):
            with patch('scripts.evidence.check_submission_checkpoint.verify',return_value={'status':status}), contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(code,main(flags))

    def test_current_code_changes_and_added_files_invalidate_old_test_receipt(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);(root/'rcnc').mkdir();source=root/'rcnc/a.py';source.write_text('x=1\n')
            log=root/'test.log';log.write_text('Ran 7 tests in 0.123s\n\nOK\n',encoding='utf-8')
            receipt={'status':'passed','all_tests_passed':True,'code_unchanged_during_suite':True,
                'code_sha256':code_fingerprint(root),'log':'test.log','log_sha256':digest(log),
                'tests':7,'elapsed_seconds':0.123}
            self.assertEqual(7,check_test_receipt(root,receipt)['tests'])
            source.write_text('x=2\n')
            with self.assertRaisesRegex(ValueError,'Current code differs'):check_test_receipt(root,receipt)
            source.write_text('x=1\n');(root/'rcnc/new.py').write_text('pass\n')
            with self.assertRaisesRegex(ValueError,'Current code differs'):check_test_receipt(root,receipt)

    def test_receipt_cannot_change_count_even_when_log_pin_is_updated(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);log=root/'test.log';log.write_text('Ran 7 tests in 0.123s\nOK\n')
            receipt={'status':'passed','all_tests_passed':True,'code_unchanged_during_suite':True,
                'code_sha256':{},'log':'test.log','log_sha256':digest(log),'tests':8,'elapsed_seconds':0.123}
            with self.assertRaisesRegex(ValueError,'count or duration'):check_test_receipt(root,receipt)

    def test_snapshot_does_not_promote_a_shared_failure_to_success(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);report=root/'report.json';report.write_text(json.dumps({'status':'worker_error','success':False}))
            index=root/'index.json';entry={'path':str(report),'sha256':digest(report),
                'terminal_status':'worker_error','scope':'One shared construction failure','metrics':['success']}
            index.write_text(json.dumps({'reports':{'reference':entry}}))
            snapshot=root/'snapshot.json';value={'path':str(report),'sha256':digest(report),
                'scope':entry['scope'],'metrics':{'success':False}}
            obj={'status':'verified_snapshot','index_sha256':digest(index),'results':{'reference':value}}
            snapshot.write_text(json.dumps(obj))
            self.assertEqual(1,check_snapshot(index,snapshot)['verified_reports'])
            obj['results']['reference']['metrics']['success']=True;snapshot.write_text(json.dumps(obj))
            with self.assertRaisesRegex(ValueError,'metric or provenance'):check_snapshot(index,snapshot)


if __name__=='__main__':
    unittest.main()

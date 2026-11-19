import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from rcnc import model_semantics as serial
from rcnc.model_semantics_parallel import run
from rcnc.parallel_progress_io import durable_progress
from rcnc.domain_building import save
from scripts.experiments.resume_revised_parallel_io import recover_results
from tests.test_revised_multistory_parallel import prepared
from tests.test_model_semantics import answer


class ProgressIOTests(unittest.TestCase):
    def test_brief_reader_lock_retries_only_metadata(self):
        with tempfile.TemporaryDirectory() as td:
            path=Path(td)/'progress.json';path.write_text('{}',encoding='utf-8')
            original=Path.replace;calls=[]
            def locked_once(source,target):
                calls.append(str(target))
                if len(calls)==1:raise PermissionError('reader blocks replace')
                return original(source,target)
            with patch.object(Path,'replace',locked_once):
                result=durable_progress(path,{'completed':8},retry_delays=(0,))
            self.assertEqual(result,path);self.assertEqual(len(calls),2)
            self.assertEqual(json.loads(path.read_text(encoding='utf-8')),{'completed':8})

    def test_persistent_reader_lock_saves_new_snapshot_without_aborting(self):
        with tempfile.TemporaryDirectory() as td:
            path=Path(td)/'progress.json';path.write_text('{"completed":1}',encoding='utf-8')
            with patch.object(Path,'replace',side_effect=PermissionError('locked')):
                result=durable_progress(path,{'completed':9},retry_delays=())
            self.assertNotEqual(result,path)
            self.assertEqual(json.loads(result.read_text(encoding='utf-8'))['completed'],9)
            self.assertEqual(json.loads(path.read_text(encoding='utf-8'))['completed'],1)

    def test_unrelated_io_error_is_not_suppressed(self):
        with tempfile.TemporaryDirectory() as td:
            with patch.object(Path,'replace',side_effect=OSError('disk failure')):
                with self.assertRaises(OSError):durable_progress(Path(td)/'progress.json',{},retry_delays=())

    def test_scheduler_finishes_and_does_not_retry_model_under_permanent_progress_lock(self):
        with tempfile.TemporaryDirectory() as td:
            output=prepared(Path(td),2);manifest=json.loads((output/'manifest.json').read_text(encoding='utf-8'))
            manifest.pop('parallel_pilot');save(output/'manifest.json',manifest);seen=[]
            class Transport:
                def __call__(self,url,payload=None,timeout=15):
                    if payload is None:return {'models':[{'name':'gemma3:4b','digest':'fixed'}]}
                    item=json.loads(payload['messages'][0]['content'][len(serial.PROMPT)+1:]);seen.append(item['id'])
                    return {'done':True,'message':{'content':json.dumps(answer(item))}}
                def close(self):pass
            with patch.object(Path,'replace',side_effect=PermissionError('locked')), \
                 patch('rcnc.model_semantics_parallel.atomic_save',side_effect=lambda p,v:durable_progress(p,v,retry_delays=())):
                report=run(output,transport_factory=Transport)
            self.assertEqual(report['execution_status'],'complete');self.assertEqual(len(seen),2)
            self.assertEqual(len(set(seen)),2);self.assertEqual(report['status_counts'],{'checked':2})
            rows=recover_results(output)
            self.assertEqual([r['id'] for r in rows],list(json.loads((output/'requests.json').read_text(encoding='utf-8'))))
            self.assertEqual(sum(r['request_attempted'] for r in rows),2)

    def test_missing_worker_result_fails_closed_without_retry(self):
        with tempfile.TemporaryDirectory() as td:
            output=prepared(Path(td),2);requests=json.loads((output/'requests.json').read_text(encoding='utf-8'))
            key=next(iter(requests));folder=output/'responses'/key;folder.mkdir(parents=True)
            save(folder/'attempt.json',{'id':key,'request':requests[key]})
            with self.assertRaises(FileNotFoundError):recover_results(output)


if __name__=='__main__':unittest.main()

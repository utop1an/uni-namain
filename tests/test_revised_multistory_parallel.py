import copy
import json
from pathlib import Path
import tempfile
import threading
import time
import unittest

from rcnc.domain_building import save
from rcnc import model_semantics as serial
from rcnc.model_semantics_parallel import run
from scripts.experiments.run_revised_multistory_parallel import recover_partial
from tests.test_conditional_merge import fixture
from tests.test_model_semantics import answer


def prepared(root,n=12):
    inputs,_,_=fixture(root)
    pairs=[{'id':f'candidate_{i:03d}','kind':'predicate','references':['A:at','B:located']} for i in range(n)]
    output=root/'stage'
    manifest=serial.prepare(inputs,pairs,output,model_digest='fixed')
    manifest.update(workers=10,parallel_pilot={'candidate_count':10,'serial_seconds_per_candidate':1,
                                              'minimum_observed_speedup':1.5})
    save(output/'manifest.json',manifest)
    return output


class ParallelTests(unittest.TestCase):
    def test_ten_simultaneous_requests_unchanged_payloads_and_pilot_boundary(self):
        with tempfile.TemporaryDirectory() as td:
            output=prepared(Path(td));requests=json.loads((output/'requests.json').read_text(encoding='utf-8'))
            barrier=threading.Barrier(10);lock=threading.Lock();seen=[];closed=[]
            testcase=self
            class Transport:
                def __call__(self,url,payload=None,timeout=15):
                    if payload is None:return {'models':[{'name':'gemma3:4b','digest':'fixed'}]}
                    item=json.loads(payload['messages'][0]['content'][len(serial.PROMPT)+1:])
                    testcase.assertEqual(payload,requests[item['id']])
                    with lock:
                        testcase.assertNotIn(item['id'],seen);seen.append(item['id'])
                    if int(item['id'].split('_')[-1])<10:barrier.wait(timeout=5)
                    else:testcase.assertTrue((output/'pilot_report.json').exists())
                    time.sleep(.02)
                    if item['id']=='candidate_001':return {'done':True,'done_reason':'length','message':{'content':'{}'}}
                    return {'done':True,'done_reason':'stop','message':{'content':json.dumps(answer(item))}}
                def close(self):closed.append(self)
            result=run(output,transport_factory=Transport)
            self.assertEqual(result['execution_status'],'complete')
            self.assertEqual(result['requests_attempted'],12)
            self.assertEqual(result['peak_client_inflight'],10)
            self.assertEqual(result['status_counts'],{'checked':11,'invalid':1})
            self.assertEqual(result['pilot']['status'],'passed')
            self.assertEqual(len(set(seen)),12)
            self.assertEqual([r['id'] for r in result['rows']],list(requests))
            self.assertEqual(len(list(output.glob('responses/*/attempt.json'))),12)
            self.assertEqual(len(list(output.glob('responses/*/result.json'))),12)
            self.assertGreaterEqual(len(closed),2)

    def test_transport_failure_drains_inflight_without_retry_or_next_batch(self):
        with tempfile.TemporaryDirectory() as td:
            output=prepared(Path(td),25);barrier=threading.Barrier(10);seen=[];lock=threading.Lock()
            class Transport:
                def __call__(self,url,payload=None,timeout=15):
                    if payload is None:return {'models':[{'name':'gemma3:4b','digest':'fixed'}]}
                    item=json.loads(payload['messages'][0]['content'][len(serial.PROMPT)+1:])
                    with lock:seen.append(item['id'])
                    barrier.wait(timeout=5)
                    if item['id']=='candidate_000':raise OSError('Ollama HTTP 429: concurrency limit')
                    time.sleep(.05)
                    return {'done':True,'message':{'content':json.dumps(answer(item))}}
                def close(self):pass
            result=run(output,transport_factory=Transport)
            self.assertEqual(len(seen),10);self.assertEqual(len(set(seen)),10)
            self.assertEqual(result['execution_status'],'stopped')
            self.assertEqual(result['status_counts'],{'request_failed':1,'checked':9,'not_requested':15})
            self.assertEqual(result['pilot']['status'],'failed')
            self.assertEqual(len(result['rows']),25)

    def test_changed_request_is_rejected_before_network(self):
        with tempfile.TemporaryDirectory() as td:
            output=prepared(Path(td));(output/'requests.json').write_text('{}',encoding='utf-8')
            def forbidden():self.fail('Network client created for modified request')
            with self.assertRaises(ValueError):run(output,transport_factory=forbidden)

    def test_operator_stop_does_not_dispatch(self):
        with tempfile.TemporaryDirectory() as td:
            output=prepared(Path(td));(output/'STOP_REQUESTED').write_text('stop',encoding='utf-8')
            testcase=self
            class Transport:
                def __call__(self,url,payload=None,timeout=15):
                    if payload is not None:testcase.fail('Request dispatched after stop')
                    return {'models':[{'name':'gemma3:4b','digest':'fixed'}]}
                def close(self):pass
            result=run(output,transport_factory=Transport)
            self.assertEqual(result['requests_attempted'],0)
            self.assertEqual(result['status_counts'],{'not_requested':12})


class HandoffRecoveryTests(unittest.TestCase):
    def test_preserves_rows_recovers_complete_raw_and_never_retries_unknown(self):
        with tempfile.TemporaryDirectory() as td:
            output=prepared(Path(td),4);items=json.loads((output/'packet.json').read_text(encoding='utf-8'))['items']
            persisted={'id':items[0]['id'],'kind':'predicate','request_attempted':True,
                       'status':'checked','response':answer(items[0])}
            save(output/'progress.json',{'rows':[persisted]})
            for item in items[:3]:(output/'responses'/item['id']).mkdir(parents=True)
            save(output/'responses'/items[1]['id']/'raw.json',{'done':True,'message':{'content':json.dumps(answer(items[1]))}})
            rows,recovery=recover_partial(output)
            self.assertEqual(rows[0],persisted)
            self.assertEqual([r['status'] for r in rows],['checked','checked','request_failed','not_requested'])
            self.assertTrue(rows[2]['request_attempted']);self.assertFalse(rows[3]['request_attempted'])
            self.assertEqual(recovery['interrupted_unknown_ids'],[items[2]['id']])
            self.assertEqual(recovery['recovered_raw_rows'],[items[1]['id']])

    def test_nonprefix_progress_is_not_silently_reordered(self):
        with tempfile.TemporaryDirectory() as td:
            output=prepared(Path(td),2);(output/'responses').mkdir()
            save(output/'progress.json',{'rows':[{'id':'candidate_001'}]})
            with self.assertRaises(ValueError):recover_partial(output)


if __name__=='__main__':unittest.main()

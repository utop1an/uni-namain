import copy
import json
from pathlib import Path
import tempfile
import threading
import unittest
from concurrent.futures import ThreadPoolExecutor
from unittest.mock import patch

from rcnc import model_semantics_retry as retry
from rcnc.domain_building import digest, save
from scripts.experiments import continue_selection_comparison as campaign


class RetryTests(unittest.TestCase):
    def perform(self, outcomes, prior=0, maximum_retries=200, decode=None, deadline=1000):
        calls = []; waits = []
        class Client:
            def __call__(self, url, request=None, timeout=None):
                calls.append((url, request, timeout))
                value = outcomes.pop(0)
                if isinstance(value, Exception): raise value
                return value
            def close(self): pass
        with tempfile.TemporaryDirectory() as td:
            folder = Path(td) / 'responses'
            manifest = {'retry_policy': copy.deepcopy(retry.POLICY), 'request_seconds': 240,
                        'schema_policy': 'compact_kind_specific'}
            decode = decode or (lambda i,p,s,r: r.update(status='checked', response={'decision': 'different'}))
            with patch.object(retry, 'decode_payload', side_effect=decode):
                row = retry.perform({'id': 'x', 'kind': 'predicate'}, {'frozen': 'request'}, folder,
                    manifest, prior, deadline, retry.AttemptBudget(maximum_retries), threading.Event(),
                    transport_factory=Client, clock=lambda: 0, wait_for_stop=lambda d: waits.append(d) or False)
            attempts = [json.loads(f.read_text(encoding='utf-8')) for f in sorted(folder.glob('attempt_*/attempt.json'))]
            results = [json.loads(f.read_text(encoding='utf-8')) for f in sorted(folder.glob('attempt_*/result.json'))]
            return row, calls, waits, attempts, results

    def test_502_then_success_preserves_both_attempts(self):
        row,calls,waits,attempts,results = self.perform([OSError('Ollama HTTP 502: server'), {'done': True}])
        self.assertEqual(row['status'], 'checked')
        self.assertEqual(len(calls), 2); self.assertEqual(waits, [30])
        self.assertEqual([a['attempt_number_including_parent'] for a in attempts], [1,2])
        self.assertEqual([r['status'] for r in results], ['request_failed','checked'])
        self.assertEqual(attempts[0]['request'], attempts[1]['request'])
        self.assertNotIn('reason', row)

    def test_parent_failure_consumes_first_attempt(self):
        row,calls,waits,attempts,_ = self.perform([OSError('Ollama HTTP 503: busy')]*2, prior=1)
        self.assertEqual(len(calls), 2); self.assertEqual(waits, [30,60])
        self.assertEqual(row['total_attempts_including_parent'], 3)
        self.assertEqual([a['attempt_number_including_parent'] for a in attempts], [2,3])
        self.assertEqual(row['status'], 'request_failed')
        self.assertNotIn('fatal_transport_failure', row)

    def test_temporary_failure_is_bounded_to_three(self):
        row,calls,_,_,_ = self.perform([TimeoutError('timed out')]*3)
        self.assertEqual(len(calls), 3)
        self.assertEqual(row['status'], 'request_failed')

    def test_invalid_output_is_final_even_after_temporary_error(self):
        def invalid(*args): raise ValueError('Bad role map')
        row,calls,_,_,_ = self.perform([OSError('Ollama HTTP 502: server'), {}], decode=invalid)
        self.assertEqual(row['status'], 'invalid'); self.assertEqual(len(calls), 2)
        self.assertEqual(row['reason'], 'Bad role map')

    def test_permanent_http_error_does_not_retry(self):
        row,calls,waits,_,_ = self.perform([OSError('Ollama HTTP 401: unauthorized')])
        self.assertEqual(len(calls), 1); self.assertEqual(waits, [])
        self.assertTrue(row['fatal_transport_failure'])

    def test_global_retry_cap_stops_before_another_call(self):
        row,calls,_,_,_ = self.perform([OSError('Ollama HTTP 502: server')], maximum_retries=0)
        self.assertEqual(len(calls), 1); self.assertEqual(row['reason'], 'retry_budget_exhausted')

    def test_active_time_budget_prevents_late_retry(self):
        row,calls,waits,_,_ = self.perform([OSError('Ollama HTTP 502: server')], deadline=20)
        self.assertEqual(len(calls), 1); self.assertEqual(waits, [])
        self.assertEqual(row['reason'], 'total_budget_exhausted')

    def test_parallel_global_retry_claims_cannot_overspend(self):
        budget = retry.AttemptBudget(7)
        with ThreadPoolExecutor(max_workers=8) as pool:
            claims = list(pool.map(budget.claim, [2]*30))
        self.assertEqual(sum(claims), 7); self.assertEqual(budget.calls, 7)

    def test_retry_classification_is_narrow(self):
        for code in (408,429,500,502,503,504): self.assertTrue(retry.transient(OSError(f'Ollama HTTP {code}: x')))
        for code in (400,401,403,404,413): self.assertFalse(retry.transient(OSError(f'Ollama HTTP {code}: x')))
        self.assertFalse(retry.transient(ValueError('502 in model text')))
        self.assertFalse(retry.transient(OSError('unknown permanent failure')))


class ContinuationTests(unittest.TestCase):
    def fixtures(self):
        items = [{'id':str(i),'kind':'predicate'} for i in range(4)]
        rows = [{**items[0],'status':'checked','request_attempted':True,'response':{'decision':'different'}},
                {**items[1],'status':'invalid','request_attempted':True,'reason':'invalid original'},
                {**items[2],'status':'request_failed','request_attempted':True,'reason':'Ollama HTTP 502: server'},
                {**items[3],'status':'not_requested','request_attempted':False,'reason':'stop_after_transport_failure'}]
        return items, rows

    def test_retain_checked_and_invalid_without_cherry_picking(self):
        items,rows = self.fixtures(); before=copy.deepcopy(rows)
        retained,pending,previous = retry.partition(items,rows)
        self.assertEqual(list(retained), ['0','1']); self.assertEqual(pending, items[2:])
        self.assertEqual(previous, {'2':1,'3':0}); self.assertEqual(rows,before)
        retained['1']['reason']='changed'; self.assertEqual(rows,before)

    def test_changed_order_and_permanent_failure_rejected(self):
        items,rows = self.fixtures()
        with self.assertRaises(ValueError): retry.partition(items,list(reversed(rows)))
        rows[2]['reason']='Ollama HTTP 403: blocked'
        with self.assertRaises(ValueError): retry.partition(items,rows)

    def test_stage_reuses_outputs_and_keeps_exhausted_failure(self):
        items,rows = self.fixtures()
        class Client:
            def __call__(self,*a,**k): return {'models':[{'name':'fixed','digest':'fixed-hash'}]}
            def close(self): pass
        def perform(item,*a,**k):
            budget=a[5]; budget.claim(2 if item['id']=='2' else 1)
            return {**item,'status':'request_failed' if item['id']=='2' else 'invalid','request_attempted':True,'new_attempts':1}
        with tempfile.TemporaryDirectory() as td:
            root=Path(td); parent=root/'parent.json'
            save(parent,{'rows':rows,'requests_attempted':3,'elapsed_seconds':10})
            save(root/'packet.json',{'items':items}); save(root/'requests.json',{i['id']:{} for i in items})
            save(root/'manifest.json',{'frozen_sha256':{str(parent):digest(parent)},'implementation_sha256':{},
                'parent_report':str(parent),'pending_candidates':2,'total_seconds':100,'retry_policy':retry.POLICY,
                'model':'fixed','model_digest':'fixed-hash','workers':2})
            with patch.object(retry,'perform',side_effect=perform), patch('rcnc.model_semantics.to_group',side_effect=lambda i,r:r):
                result=retry.run(root,transport_factory=Client)
            self.assertEqual(result['execution_status'],'complete')
            self.assertEqual(result['rows'][:2],rows[:2]); self.assertEqual(result['retained_parent_outputs'],2)
            self.assertEqual(result['requests_attempted'],5); self.assertEqual(result['new_retry_attempts'],1)
            self.assertEqual(result['status_counts'],{'checked':1,'invalid':2,'request_failed':1})
            with self.assertRaises(ValueError): retry.run(root,transport_factory=Client)

    def test_pipeline_fatal_stop_evaluates_without_planning(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td); save(root/'protocol.json',{})
            with patch.object(campaign.base,'verify',return_value={'condition':campaign.CONDITION,'continuation':{'parent':'old'}}), \
                 patch.object(campaign.retry,'run',return_value={'execution_status':'stopped','stop_reason':'permanent','status_counts':{}}), \
                 patch.object(campaign.base,'compile_all') as compile_mock, patch.object(campaign.base,'execute_all') as execute_mock, \
                 patch.object(campaign.base,'evaluation',return_value={'status':'complete_evaluation'}) as eval_mock:
                result=campaign.pipeline(root)
            compile_mock.assert_not_called(); execute_mock.assert_not_called(); eval_mock.assert_called_once()
            self.assertEqual(result['stage'],'terminal'); self.assertFalse(result['original_fresh_round_completed'])

    def test_guard_rejects_compiler_changes_but_allows_evaluation_metadata(self):
        with tempfile.TemporaryDirectory() as td:
            a=Path(td)/'a.py'; b=Path(td)/'b.py'
            a.write_text('def compiler(): return 1\ndef evaluation(): return 1\n',encoding='utf-8')
            b.write_text('def compiler(): return 1\ndef evaluation(): return 2\n',encoding='utf-8')
            self.assertTrue(campaign.only_evaluation_changed(a,b))
            b.write_text('def compiler(): return 2\ndef evaluation(): return 2\n',encoding='utf-8')
            self.assertFalse(campaign.only_evaluation_changed(a,b))


if __name__ == '__main__': unittest.main()

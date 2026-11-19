import copy
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock, patch

from scripts.experiments.continue_revised_multistory import LocalConnection, combine_rows, pending_items, reassemble, pipeline


class ContinuationAccountingTests(unittest.TestCase):
    def setUp(self):
        self.items=[{'id':str(i),'kind':'predicate'} for i in range(4)]
        self.rows=[{**self.items[0],'status':'checked','request_attempted':True,'response':{'decision':'different'}},
                   {**self.items[1],'status':'invalid','request_attempted':True,'reason':'bad citation'},
                   {**self.items[2],'status':'request_failed','request_attempted':True,'reason':'socket error'},
                   {**self.items[3],'status':'not_requested','request_attempted':False,'reason':'stop_after_transport_failure'}]

    def test_only_never_sent_candidate_is_dispatched(self):
        self.assertEqual(pending_items(self.items,self.rows),[self.items[3]])

    def test_invalid_and_failed_rows_are_preserved_without_retry(self):
        before=copy.deepcopy(self.rows)
        fresh=[{**self.items[3],'status':'invalid','request_attempted':True,'reason':'truncated'}]
        combined=combine_rows(self.items,self.rows,fresh)
        self.assertEqual(combined[:3],self.rows[:3])
        self.assertEqual(combined[3],fresh[0])
        self.assertEqual(self.rows,before)
        self.assertEqual(len(combined),len(self.items))

    def test_missing_extra_reordered_or_duplicate_rows_fail_closed(self):
        for bad in [self.rows[:-1],self.rows+[self.rows[0]],list(reversed(self.rows))]:
            with self.assertRaises(ValueError):pending_items(self.items,bad)
        with self.assertRaises(ValueError):pending_items([self.items[0]]*4,self.rows)
        for bad in [[],[self.rows[0]],[self.rows[3],self.rows[3]]]:
            with self.assertRaises(ValueError):combine_rows(self.items,self.rows,bad)

    def test_budget_or_context_exclusions_are_not_silently_retried(self):
        for reason in ['total_budget_exhausted','context_size_limit']:
            self.rows[-1]['reason']=reason
            with self.assertRaises(ValueError):pending_items(self.items,self.rows)

    def test_changed_source_kind_is_rejected(self):
        self.rows[-1]['kind']='action'
        with self.assertRaises(ValueError):pending_items(self.items,self.rows)


class LocalConnectionTests(unittest.TestCase):
    def connection(self):
        response=Mock(status=200)
        response.read.return_value=b'{"done":true}'
        connection=Mock()
        connection.getresponse.return_value=response
        return connection

    def test_reuses_one_connection_preserves_payload_and_updates_timeout(self):
        connection=self.connection()
        with patch('scripts.experiments.continue_revised_multistory.http.client.HTTPConnection',return_value=connection) as factory:
            client=LocalConnection();payload={'model':'glm-5.3:cloud','options':{'seed':7},'messages':[{'content':'same frozen input'}]}
            before=copy.deepcopy(payload)
            client('http://127.0.0.1:11434/api/tags',timeout=10)
            client('http://127.0.0.1:11434/api/chat',payload,timeout=240)
            self.assertEqual(factory.call_count,1)
            self.assertEqual(connection.request.call_args.kwargs['body'],json.dumps(payload).encode('utf-8'))
            self.assertEqual(payload,before)
            connection.sock.settimeout.assert_called_with(240)
            client.close();connection.close.assert_called_once()

    def test_network_failure_does_not_repeat_post(self):
        connection=self.connection();connection.getresponse.side_effect=OSError('buffer exhausted')
        with patch('scripts.experiments.continue_revised_multistory.http.client.HTTPConnection',return_value=connection):
            client=LocalConnection()
            with self.assertRaises(OSError):client('http://127.0.0.1:11434/api/chat',{'model':'x'})
            self.assertEqual(connection.request.call_count,1)
            self.assertIsNone(client.connection)

    def test_http_failure_is_transport_failure_not_invalid_answer(self):
        connection=self.connection();connection.getresponse.return_value.status=503
        with patch('scripts.experiments.continue_revised_multistory.http.client.HTTPConnection',return_value=connection):
            with self.assertRaises(OSError):LocalConnection()('http://127.0.0.1:11434/api/chat',{})
            self.assertEqual(connection.request.call_count,1)

    def test_unregistered_destination_is_blocked_before_connection(self):
        with patch('scripts.experiments.continue_revised_multistory.http.client.HTTPConnection') as factory:
            for url in ['https://ollama.com/api/chat','http://127.0.0.1:11434/api/pull','http://localhost:11434/api/chat']:
                with self.assertRaises(ValueError):LocalConnection()(url,{})
            factory.assert_not_called()


class ReassemblyTests(unittest.TestCase):
    def test_new_transport_failure_stops_before_compilation_and_later_repeats(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);(root/'protocol.json').write_text('{}',encoding='utf-8')
            protocol={'condition':'explicit_continuation','model':'fixed','repeats':[
                {'id':f'repeat_0{i}','path':str(root/f'repeat_0{i}'),'model_stage':str(root/f'repeat_0{i}'/'judgments'),
                 'condition':'continuation' if i==1 else 'fresh','new_request_limit':1} for i in (1,2)]}
            failed={'status_counts':{'request_failed':1},'rows':[{'id':'x','status':'request_failed'}]}
            client=Mock(side_effect=[{'version':'test'},{'models':[{'name':'fixed'}]}])
            with patch('scripts.experiments.continue_revised_multistory.base.verify',return_value=protocol), \
                 patch('scripts.experiments.continue_revised_multistory.LocalConnection',return_value=client), \
                 patch('scripts.experiments.continue_revised_multistory.model_semantics.run',return_value=failed) as runner, \
                 patch('scripts.experiments.continue_revised_multistory.base.compile_models') as compiler, \
                 patch('scripts.experiments.continue_revised_multistory.base.execute') as executor:
                result=pipeline(root)
            self.assertEqual(result['status'],'stopped_model_stage_incomplete')
            self.assertEqual(runner.call_count,1)
            compiler.assert_not_called();executor.assert_not_called()
            self.assertEqual(json.loads((root/'report.json').read_text(encoding='utf-8'))['completed_repeats'],0)

    def test_real_model_group_conversion_preserves_failed_row_and_denominators(self):
        from rcnc.domain_building import save
        from rcnc.model_semantics import context
        from tests.test_conditional_merge import fixture
        from tests.test_model_semantics import answer
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);inputs,_,_=fixture(root)
            sides=[context(inputs,r,'predicate') for r in ['A:at','B:located']]
            items=[{'id':str(i),'kind':'predicate','sides':sides} for i in range(3)]
            old_rows=[{'id':'0','kind':'predicate','status':'checked','request_attempted':True,'response':answer(items[0])},
                      {'id':'1','kind':'predicate','status':'request_failed','request_attempted':True,'reason':'network'},
                      {'id':'2','kind':'predicate','status':'not_requested','request_attempted':False,'reason':'stop_after_transport_failure'}]
            new_rows=[{'id':'2','kind':'predicate','status':'checked','request_attempted':True,'response':answer(items[2])}]
            parent=root/'parent';old_folder=parent/'repeat_01/judgments';old_folder.mkdir(parents=True)
            old={'requests_attempted':2,'elapsed_seconds':10,'rows':old_rows,'inputs_unchanged':True,'implementation_unchanged':True}
            save(old_folder/'report.json',old)
            original_bytes=(old_folder/'report.json').read_bytes()
            run=root/'new';repeat=run/'repeat_01';aggregate=repeat/'judgments';aggregate.mkdir(parents=True)
            save(aggregate/'packet.json',{'items':items})
            suffix={'requests_attempted':1,'elapsed_seconds':5,'rows':new_rows,'inputs_unchanged':True,'implementation_unchanged':True}
            (repeat/'remaining_judgments').mkdir();save(repeat/'remaining_judgments/report.json',suffix)
            with patch('scripts.experiments.continue_revised_multistory.base.verify',return_value={'parent':str(parent)}):
                result=reassemble(run,repeat,suffix)
            self.assertEqual(result['condition'],'interrupted_cache_continuation')
            self.assertEqual(result['requests_attempted'],3)
            self.assertEqual(result['requests_attempted_new'],1)
            self.assertEqual(result['status_counts'],{'checked':2,'request_failed':1})
            groups=json.loads((aggregate/'groups.json').read_text(encoding='utf-8'))['groups']
            self.assertEqual(groups[1]['model_judgment']['decision'],'uncertain')
            self.assertEqual(groups[0]['model_judgment']['decision'],'compatible')
            self.assertEqual((old_folder/'report.json').read_bytes(),original_bytes)
            provenance=json.loads((aggregate/'row_provenance.json').read_text(encoding='utf-8'))['rows']
            self.assertEqual([r['origin'] for r in provenance],['parent','parent','new'])
            self.assertIsNone(provenance[1]['raw_path'])


if __name__=='__main__':unittest.main()

from pathlib import Path
import tempfile
import unittest
import json

from scripts.audit.partial_revised_multistory import group_coverage,audit_response
from rcnc.model_semantics import context
from tests.test_conditional_merge import fixture
from tests.test_model_semantics import answer


class PartialAuditTests(unittest.TestCase):
    def test_pending_edge_keeps_multisource_group_incomplete(self):
        groups=[{'id':'pair','size':2,'sources':['A','B']},{'id':'triple','size':3,'sources':['A','B','C']}]
        items=[{'id':'ab','source_pair':['B','A']},{'id':'ac','source_pair':['A','C']}]
        rows=[{'id':'ab','status':'invalid'},{'id':'ac','status':'not_requested'}]
        result=group_coverage(groups,items,rows)
        self.assertTrue(result[0]['all_registered_candidates_terminal'])
        self.assertFalse(result[1]['all_registered_candidates_terminal'])
        self.assertEqual(result[1]['pending_candidates'],1)

    def test_zero_candidate_group_is_explicitly_distinguished(self):
        result=group_coverage([{'id':'empty','size':2,'sources':['A','Z']}],[],[])[0]
        self.assertTrue(result['all_registered_candidates_terminal'])
        self.assertFalse(result['has_registered_candidates'])

    def test_recheck_detects_changed_normalized_response(self):
        with tempfile.TemporaryDirectory() as td:
            inputs,_,_=fixture(Path(td))
            item={'id':'pair','kind':'predicate','sides':[context(inputs,r,'predicate') for r in ['A:at','B:located']]}
            response=answer(item);payload={'done':True,'message':{'content':json.dumps(response)}}
            row={'status':'checked','response':response}
            self.assertTrue(audit_response(item,row,payload,'free_fields')['status_match'])
            row={'status':'checked','response':{**response,'confidence':.5}}
            self.assertFalse(audit_response(item,row,payload,'free_fields')['status_match'])

    def test_truncated_answer_remains_invalid(self):
        item={'id':'bad','kind':'predicate'}
        row={'status':'invalid','reason':'Incomplete or truncated generation'}
        result=audit_response(item,row,{'done':True,'done_reason':'length'},'compact_kind_specific')
        self.assertTrue(result['status_match']);self.assertEqual(result['recomputed_status'],'invalid')


if __name__=='__main__':unittest.main()

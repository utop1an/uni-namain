import json
from pathlib import Path
import tempfile
import unittest

from rcnc.model_semantics import prepare, run
from rcnc.model_semantics_contract import include_output_contract
from tests.test_conditional_merge import fixture
from tests.test_model_semantics_facets import response


class ExplicitContractTests(unittest.TestCase):
    def test_schema_is_visible_and_actual_response_is_preserved(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);inputs,_,_=fixture(root)
            pairs=[dict(id='location',kind='predicate',references=['A:at','B:located'])]
            prepare(inputs,pairs,root/'model',model_digest='fixed',schema_policy='semantic_facets')
            before=(root/'model/requests.json').read_bytes()
            manifest=include_output_contract(root/'model')
            self.assertEqual(before,(root/'model/requests_before_contract.json').read_bytes())
            self.assertTrue(manifest['output_contract_in_prompt'])
            def transport(url,payload=None,timeout=None):
                if payload is None:return {'models':[{'name':'gemma3:4b','digest':'fixed'}]}
                prompt=payload['messages'][0]['content']
                self.assertIn('Required output JSON schema',prompt)
                self.assertIn('"difference_kind"',prompt)
                return {'done':True,'done_reason':'stop','message':{'content':json.dumps(response(json.loads(prompt.splitlines()[-1])))}}
            result=run(root/'model',transport=transport)
            self.assertEqual({'checked':1},result['status_counts'])
            with self.assertRaises(ValueError):include_output_contract(root/'model')

    def test_tampering_is_rejected_before_contract_finalization(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);inputs,_,_=fixture(root)
            prepare(inputs,[dict(id='location',kind='predicate',references=['A:at','B:located'])],root/'model',model_digest='fixed')
            (root/'model/requests.json').write_text('{}')
            with self.assertRaises(ValueError):include_output_contract(root/'model')


if __name__=='__main__':unittest.main()

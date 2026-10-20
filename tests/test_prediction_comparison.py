import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from scripts.annotation.compare_annotation_predictions import compare
from rcnc.interface_annotation import save
from scripts.annotation.run_annotation_predictions import run


class PredictionComparisonTests(unittest.TestCase):
    def test_isolates_schema_and_rejects_option_drift(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp)
            item={'id':'fixture','sides':[{'parameters':[['?x','person']],
                'action_contexts':[{'ref':str(side),'text':'(p ?x)',
                    'occurrences':[{'literal':'(p ?x)'}]}]} for side in range(2)]}
            save(root/'packet.json',{'items':[item]})
            response={'candidate_id':'fixture','label':'incompatible','right_from_left':[0],
                'rationale':'Synthetic comparison test, not a semantic judgment',
                'evidence':[{'side':side,'ref':str(side),'quote':'(p ?x)'} for side in range(2)]}
            for policy in ('free_fields','coupled_fields'):
                if policy=='coupled_fields':
                    response['right_from_left']=None
                raw={'done':True,'done_reason':'stop','message':{'content':json.dumps(response)}}
                with patch('scripts.annotation.run_annotation_predictions.request_json',side_effect=[{'models':[{'name':'gemma3:4b','digest':'fixture'}]},raw]):
                    run(root/'packet.json',root/policy,schema_policy=policy)
            result=compare(root/'free_fields',root/'coupled_fields',root/'comparison.json')
            self.assertEqual({'invalid -> checked':1},result['status_transitions'])
            self.assertEqual(0,result['independent_semantically_verified'])
            self.assertEqual('schema_intervention',result['comparison_kind'])
            path=root/'coupled_fields/manifest.json'
            manifest=json.loads(path.read_text(encoding='utf-8'))
            manifest['options']['seed']+=1
            save(path,manifest)
            with self.assertRaisesRegex(ValueError,'Unmatched protocol field: options'):
                compare(root/'free_fields',root/'coupled_fields',root/'drift.json')


if __name__ == '__main__':
    unittest.main()

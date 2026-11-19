import json
import copy
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from scripts.annotation.compare_annotation_predictions import compare
from rcnc.interface_annotation import save
from scripts.annotation.run_annotation_predictions import run


class PredictionComparisonTests(unittest.TestCase):
    def test_budget_cutoffs_remain_in_denominator_without_false_request_equality(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            item = {'id': 'first', 'sides': [{'parameters': [], 'action_contexts': []} for _ in range(2)]}
            second = copy.deepcopy(item)
            second['id'] = 'second'
            save(root / 'packet.json', {'items': [item, second]})
            for policy, duration in [('free_fields', 5), ('coupled_fields', 1)]:
                now = [0.0]
                def request(url, payload=None, timeout=240):
                    if url.endswith('/tags'):
                        return {'models': [{'name': 'gemma3:4b', 'digest': 'fixture'}]}
                    context = json.loads(payload['messages'][1]['content'])
                    now[0] += duration
                    response = {'candidate_id': context['id'], 'label': 'uncertain',
                        'right_from_left': None, 'rationale': 'Synthetic budget test only', 'evidence': []}
                    return {'done': True, 'done_reason': 'stop', 'message': {'content': json.dumps(response)}}
                with patch('scripts.annotation.run_annotation_predictions.time.perf_counter', side_effect=lambda: now[0]), \
                     patch('scripts.annotation.run_annotation_predictions.request_json', side_effect=request):
                    run(root / 'packet.json', root / policy, schema_policy=policy, total_seconds=5)
            result = compare(root / 'free_fields', root / 'coupled_fields', root / 'comparison.json')
            self.assertEqual(2, result['total'])
            self.assertEqual(1, result['matched_attempted_candidates'])
            self.assertEqual(1, result['request_comparison_unavailable'])
            self.assertEqual(1, result['before_counts']['budget_exhausted'])
            self.assertIsNone(result['rows'][1]['request_equal_except_schema'])
            manifest = json.loads((root / 'coupled_fields/manifest.json').read_text(encoding='utf-8'))
            manifest['total_budget_seconds'] = 6
            save(root / 'coupled_fields/manifest.json', manifest)
            with self.assertRaisesRegex(ValueError, 'total_budget_seconds'):
                compare(root / 'free_fields', root / 'coupled_fields', root / 'changed.json')

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

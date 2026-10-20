import copy
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from rcnc.interface_annotation import digest, save
from scripts.annotation.run_annotation_predictions import check_response, run


class AnnotationPredictionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.item = {'id': 'pair_fixture', 'sides': [
            {'parameters': [['?x', 'person']], 'action_contexts': [
                {'ref': source+':action:act', 'text': '(:action act :effect (ready ?x))',
                 'occurrences': [{'literal': '(ready ?x)', 'path': [3]}]}]} for source in ('A', 'B')]}
        self.packet = {'items': [self.item]}
        save(self.root/'packet.json', self.packet)
        self.response = {'candidate_id': self.item['id'], 'label': 'equivalent',
            'right_from_left': [0], 'rationale': 'Synthetic test only', 'evidence': [
                {'side': side, 'ref': source+':action:act', 'quote': '(ready ?x)'} for side, source in enumerate(('A', 'B'))]}

    def test_wrong_candidate_and_non_occurrence_citations_rejected(self):
        self.assertEqual([], check_response(self.packet, self.item, self.response))
        bad = copy.deepcopy(self.response); bad['candidate_id'] = 'other'
        self.assertEqual(['wrong_candidate'], check_response(self.packet, self.item, bad))
        bad = copy.deepcopy(self.response); bad['evidence'][0]['quote'] = ':action act'
        self.assertIn('evidence_missing_candidate_occurrence', check_response(self.packet, self.item, bad))

    def test_local_mock_and_offline_replay_keep_machine_provenance(self):
        self.response['rationale'] = 'Synthetic Unicode replay: 中文 “quoted” relation → role.'
        raw = {'done': True, 'done_reason': 'stop', 'message': {'content': json.dumps(self.response)}}
        with patch('scripts.annotation.run_annotation_predictions.request_json', side_effect=[{'models': [{'name': 'gemma3:4b', 'digest': 'local'}]}, raw]):
            result = run(self.root/'packet.json', self.root/'live')
        self.assertEqual('complete', result['status'])
        self.assertEqual({'checked': 1}, result['counts'])
        self.assertEqual(0, result['independent_semantically_verified'])
        with patch('scripts.annotation.run_annotation_predictions.request_json', side_effect=AssertionError('Replay called network')):
            replay = run(self.root/'packet.json', self.root/'replay', replay=self.root/'live')
        self.assertEqual(result['rows'], replay['rows'])
        changed = copy.deepcopy(self.packet); changed['items'][0]['new_context'] = 'drift'
        save(self.root/'changed.json', changed)
        drift = run(self.root/'changed.json', self.root/'drift', replay=self.root/'live')
        self.assertEqual('failed', drift['status'])
        self.assertIn('mismatch', drift['error'])

    def test_remote_model_and_truncated_output_are_not_accepted(self):
        with patch('scripts.annotation.run_annotation_predictions.request_json', return_value={'models': [{'name': 'gemma3:4b', 'remote_host': 'example'}]}):
            result = run(self.root/'packet.json', self.root/'remote')
        self.assertEqual('failed', result['status'])
        with patch('scripts.annotation.run_annotation_predictions.request_json', side_effect=[{'models': [{'name': 'gemma3:4b', 'digest': 'local'}]},
                {'done': True, 'done_reason': 'length', 'message': {'content': json.dumps(self.response)}}]):
            result = run(self.root/'packet.json', self.root/'truncated')
        self.assertEqual({'failed': 1}, result['counts'])
        self.assertEqual(0, result['independent_semantically_verified'])


if __name__ == '__main__':
    unittest.main()

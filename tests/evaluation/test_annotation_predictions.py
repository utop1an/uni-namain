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
        self.root = Path(self.enterContext(tempfile.TemporaryDirectory()))
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
        replay_manifest = json.loads((self.root / 'replay/manifest.json').read_text(encoding='utf-8'))
        self.assertEqual('local', replay_manifest['model_digest'])
        self.assertEqual('offline_replay', replay_manifest['execution_kind'])
        self.assertEqual(0, replay['requests_attempted'])
        self.assertFalse(replay['all_candidates_requested'])
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

    def test_total_budget_preserves_unrequested_rows_and_replay_without_network(self):
        second = copy.deepcopy(self.item)
        second['id'] = 'pair_after_deadline'
        packet = {'items': [self.item, second]}
        save(self.root / 'two.json', packet)
        now = [0.0]
        timeouts = []
        def request(url, payload=None, timeout=240):
            if url.endswith('/tags'):
                return {'models': [{'name': 'gemma3:4b', 'digest': 'fixture'}]}
            timeouts.append(timeout)
            now[0] = 5.0
            return {'done': True, 'done_reason': 'stop', 'message': {'content': json.dumps(self.response)}}
        with patch('scripts.annotation.run_annotation_predictions.time.perf_counter', side_effect=lambda: now[0]), \
             patch('scripts.annotation.run_annotation_predictions.request_json', side_effect=request):
            result = run(self.root / 'two.json', self.root / 'budget', total_seconds=5)
        self.assertEqual({'checked': 1, 'budget_exhausted': 1}, result['counts'])
        self.assertEqual(2, result['total'])
        self.assertEqual(1, result['requests_attempted'])
        self.assertEqual([5], timeouts)
        self.assertFalse(result['all_candidates_requested'])
        self.assertFalse((self.root / 'budget/pair_after_deadline/request.json').exists())
        with patch('scripts.annotation.run_annotation_predictions.request_json', side_effect=AssertionError('Network forbidden')):
            replay = run(self.root / 'two.json', self.root / 'budget_replay', replay=self.root / 'budget')
        self.assertEqual(result['rows'], replay['rows'])
        self.assertEqual(1, replay['budget_exhausted_count'])

    def test_invalid_budget_rejected_before_creating_output(self):
        for index, value in enumerate((0, -1, float('nan'), float('inf'), True)):
            output = self.root / str(index)
            with self.assertRaisesRegex(ValueError, 'finite and positive'):
                run(self.root / 'packet.json', output, total_seconds=value)
            self.assertFalse(output.exists())


if __name__ == '__main__':
    unittest.main()

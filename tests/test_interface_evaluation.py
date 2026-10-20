import copy
import unittest

from rcnc.interface_annotation import digest
from rcnc.interface_evaluation import evaluate


class InterfaceEvaluationTests(unittest.TestCase):
    def setUp(self):
        self.packet = {'items': [{'id': str(i), 'sides': [
            {'parameters': ['x', 'y'], 'action_contexts': [
                {'ref': 'act', 'text': '(p x y)', 'occurrences': [{'literal': '(p x y)'}]}]}
            for _ in range(2)]} for i in range(3)]}
        rows = [{'candidate_id': str(i), 'status': 'completed', 'label': 'equivalent',
                 'right_from_left': [0, 1], 'rationale': 'Synthetic control', 'date': '2026-10-19',
                 'evidence': [{'side': side, 'ref': 'act', 'quote': '(p x y)'} for side in (0, 1)]}
                for i in range(3)]
        self.annotations = [{'packet_sha256': digest(self.packet), 'annotator_id': who,
                             'independent_of_model_and_solver_outcomes': True,
                             'rows': copy.deepcopy(rows)} for who in ('a', 'b')]
        self.predictions = {'status': 'complete', 'total': 3, 'rows': [
            {'candidate_id': str(i), 'status': 'checked', 'response': copy.deepcopy(row)}
            for i, row in enumerate(rows)]}

    def score(self):
        return evaluate(self.packet, self.annotations, self.predictions, digest(self.packet))

    def test_failed_output_and_wrong_permutation_remain_in_denominator(self):
        self.predictions['rows'][1] = {'candidate_id': '1', 'status': 'failed'}
        self.predictions['rows'][2]['response'].update(label='permuted_equivalent', right_from_left=[1, 0])
        result = self.score()
        self.assertEqual(3, result['counts']['scored'])
        self.assertEqual(1 / 3, result['metrics']['exact_merge_recall'])
        self.assertEqual(2 / 3, result['metrics']['merge_recall'])
        self.assertEqual(.5, result['metrics']['permutation_accuracy'])

    def test_disagreement_uncertainty_missing_and_no_fake_gold(self):
        self.annotations[1]['rows'][0].update(label='incompatible', right_from_left=None)
        for a in self.annotations:
            a['rows'][1].update(label='uncertain', right_from_left=None)
        self.annotations[1]['rows'].pop()
        result = self.score()
        self.assertEqual('no_definite_consensus', result['status'])
        self.assertIsNone(result['metrics']['label_accuracy'])
        self.assertEqual(1, result['counts']['reference_disagreement'])
        self.assertEqual(1, result['counts']['reference_missing'])
        self.assertEqual(1, result['counts']['reference_uncertain'])
        self.assertEqual('needs_valid_independent_annotations',
                         evaluate(self.packet, [], self.predictions, digest(self.packet))['status'])

    def test_incomplete_duplicate_invalid_checked_and_packet_drift_rejected(self):
        original = copy.deepcopy(self.predictions)
        for rows in (original['rows'][:-1], original['rows'] + original['rows'][:1]):
            self.predictions['rows'] = rows
            with self.assertRaises(ValueError):
                self.score()
        self.predictions = original
        self.predictions['rows'][0]['response']['right_from_left'] = [0, 0]
        with self.assertRaises(ValueError):
            self.score()
        with self.assertRaises(ValueError):
            evaluate(self.packet, self.annotations, original, 'stale')

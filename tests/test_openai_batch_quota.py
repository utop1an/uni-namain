import unittest
from scripts.experiments.accelerate_openai_alignment_batch_quota import (
    count_payload, quota_rejected_without_execution, token_room)


class QuotaTests(unittest.TestCase):
    def test_only_zero_execution_token_admission_rejection_can_be_bypassed(self):
        batch = {'status': 'failed', 'errors': {'data': [{'code': 'token_limit_exceeded'}]},
            'in_progress_at': None, 'request_counts': {'total': 0, 'completed': 0, 'failed': 0},
            'usage': {'input_tokens': 0, 'output_tokens': 0}}
        self.assertTrue(quota_rejected_without_execution(batch))
        batch['in_progress_at'] = 123
        self.assertFalse(quota_rejected_without_execution(batch))
        batch['in_progress_at'] = None
        batch['usage']['input_tokens'] = 1
        self.assertFalse(quota_rejected_without_execution(batch))

    def test_other_provider_failures_cannot_be_ignored(self):
        self.assertFalse(quota_rejected_without_execution({'status': 'completed'}))
        self.assertFalse(quota_rejected_without_execution({'status': 'failed',
            'errors': {'data': [{'code': 'invalid_request'}]}}))

    def test_all_nonterminal_tokens_and_new_tokens_fit_with_headroom(self):
        self.assertTrue(token_room([180000]*6, 180000))
        self.assertFalse(token_room([180000]*7, 180000))
        self.assertTrue(token_room([180000]*6, 202500))
        self.assertFalse(token_room([180000]*6, 202501))

    def test_unknown_or_negative_counts_fail_closed(self):
        for bad in (None, -1, 1.0):
            with self.assertRaises(ValueError):
                token_room([bad], 100)

    def test_counter_keeps_every_input_affecting_field(self):
        body = {'model': 'gpt-6.1-sol', 'input': [{'role': 'user', 'content': 'frozen'}],
                'reasoning': {'effort': 'medium'}, 'text': {'format': {'type': 'json_schema'}},
                'max_output_tokens': 4096, 'store': False}
        counted = count_payload(body)
        self.assertEqual(set(counted), {'model', 'input', 'reasoning', 'text'})
        self.assertEqual(counted['text'], body['text'])
        self.assertEqual(body['max_output_tokens'], 4096)


if __name__ == '__main__':
    unittest.main()

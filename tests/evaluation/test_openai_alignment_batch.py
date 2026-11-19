"""Batch boundaries: cost commitments, immutable input order and reconciliation."""
import unittest
from scripts.experiments.run_openai_alignment_batch import Ledger, NANO, partition, reconcile, usage_nano


def result(cid, text='{}'):
    return {'custom_id': cid, 'error': None, 'response': {'status_code': 200, 'body': {
        'status': 'completed', 'model': 'gpt-6.1-sol',
        'usage': {'input_tokens': 100, 'output_tokens': 50},
        'output': [{'type': 'message', 'content': [{'type': 'output_text', 'text': text}]}]}}}


class BatchTests(unittest.TestCase):
    def test_shards_cover_every_request_once_in_original_order(self):
        requests = list(range(17044))
        shards = partition(requests)
        self.assertEqual(len(shards[0]), 32)
        self.assertTrue(all(len(s) <= 128 for s in shards[1:]))
        self.assertEqual([r for shard in shards for r in shard], requests)

    def test_all_active_batches_count_toward_cap_before_completion(self):
        ledger = Ledger(200*NANO)
        self.assertTrue(ledger.reserve('a', 120*NANO))
        self.assertFalse(ledger.reserve('b', 90*NANO))
        self.assertTrue(ledger.reserve('b', 80*NANO))
        ledger.settle('a', 20*NANO)
        self.assertTrue(ledger.reserve('c', 100*NANO))
        self.assertFalse(ledger.reserve('d', 1))

    def test_unknown_billing_does_not_release_unspent_assumption(self):
        ledger = Ledger(200*NANO)
        ledger.reserve('a', 170*NANO)
        ledger.settle('a', None)
        self.assertFalse(ledger.reserve('b', 31*NANO))
        self.assertEqual(ledger.snapshot()['settled_conservative_usd'], 170)

    def test_duplicate_reservation_and_exceeded_ceiling_fail_closed(self):
        ledger = Ledger(200*NANO)
        ledger.reserve('a', 20*NANO)
        with self.assertRaises(ValueError):
            ledger.reserve('a', 20*NANO)
        with self.assertRaises(ValueError):
            ledger.settle('a', 21*NANO)

    def test_unordered_results_are_matched_by_custom_id(self):
        shard = {'request_ids': ['a', 'b']}
        batch = {'id': 'batch_fixture', 'status': 'completed'}
        items = {i: {'id': i, 'kind': 'predicate'} for i in ('a', 'b')}
        rows, debit, fatal = reconcile(shard, batch, [result('b'), result('a')], items,
            lambda i, v: {'decision': 'different'}, lambda i, v: None)
        self.assertEqual([r['id'] for r in rows], ['a', 'b'])
        self.assertTrue(all(r['status'] == 'checked' for r in rows))
        self.assertEqual(debit, 2*usage_nano({'input_tokens': 100, 'output_tokens': 50}))
        self.assertEqual(fatal, [])

    def test_duplicate_remote_rows_do_not_silently_replace_results(self):
        with self.assertRaises(ValueError):
            reconcile({'request_ids': ['a']}, {'id': 'x', 'status': 'completed'},
                [result('a'), result('a')], {}, None, None)

    def test_expired_missing_rows_and_unknown_bill_are_preserved(self):
        rows, debit, fatal = reconcile({'request_ids': ['a']}, {'id': 'x', 'status': 'expired'}, [],
                                      {'a': {'kind': 'predicate'}}, None, None)
        self.assertEqual(rows[0]['status'], 'batch_result_missing')
        self.assertIsNone(debit)
        self.assertIn('batch_terminal_expired', fatal)
        self.assertIn('unknown_batch_billing', fatal)

    def test_request_failure_is_not_semantic_rejection(self):
        rows, debit, fatal = reconcile({'request_ids': ['a']}, {'id': 'x', 'status': 'completed'},
            [{'custom_id': 'a', 'response': None, 'error': {'code': 'rate_limit_exceeded'}}],
            {'a': {'kind': 'predicate'}}, None, None)
        self.assertEqual(rows[0]['status'], 'request_failed')
        self.assertNotIn('response', rows[0])
        self.assertIn('batch_request_failed', fatal)


if __name__ == '__main__':
    unittest.main()

"""No-duplicate handoff, inherited liabilities and provider admission gates."""
import copy
import unittest
from scripts.experiments.accelerate_openai_alignment_batch import (
    admission_ready, check_shards, match_inventory, restore_ledger)
from scripts.experiments.run_openai_alignment_batch import NANO


def fixtures():
    shards = [{'id': sid, 'request_ids': [cid], 'requests': 1,
               'reserved_max_cost_nano_usd': cost*NANO}
              for sid, cid, cost in [('s0', 'a', 100), ('s1', 'b', 80), ('s2', 'c', 50)]]
    local = {'s0': {'input_file_id': 'f0', 'batch_id': 'b0'},
             's1': {'input_file_id': 'f1', 'batch_id': 'b1'}}
    remote = [{'id': 'b0', 'input_file_id': 'f0', 'status': 'completed',
               'metadata': {'campaign': 'parent', 'shard': 's0'}},
              {'id': 'b1', 'input_file_id': 'f1', 'status': 'in_progress',
               'metadata': {'campaign': 'parent', 'shard': 's1'}}]
    reconciled = {'s0': {'rows': [{'id': 'a', 'batch_id': 'b0', 'status': 'checked'}],
                         'accounted_nano_usd': 60*NANO, 'stop_reasons': []}}
    return shards, local, remote, reconciled


class AccelerationTests(unittest.TestCase):
    def test_completed_and_inflight_are_adopted_not_queued_again(self):
        shards, local, remote, _ = fixtures()
        matched = match_inventory(shards, local, remote, 'parent')
        self.assertEqual([s['id'] for s in shards if s['id'] not in matched], ['s2'])

    def test_ack_lost_can_be_adopted_by_exact_input_file_identity(self):
        shards, local, remote, _ = fixtures()
        local['s1']['batch_id'] = None
        self.assertEqual(match_inventory(shards, local, remote, 'parent')['s1']['id'], 'b1')

    def test_unresolved_intent_is_not_mistaken_for_unsent(self):
        shards, local, remote, _ = fixtures()
        with self.assertRaisesRegex(ValueError, 'Unresolved'):
            match_inventory(shards, local, remote[:1], 'parent')

    def test_duplicate_cloud_job_blocks_takeover(self):
        shards, local, remote, _ = fixtures()
        other = copy.deepcopy(remote[1]); other['id'] = 'b2'
        with self.assertRaisesRegex(ValueError, 'duplicate'):
            match_inventory(shards, local, remote+[other], 'parent')

    def test_mismatched_cloud_upload_blocks_takeover(self):
        shards, local, remote, _ = fixtures()
        remote[1]['input_file_id'] = 'wrong'
        with self.assertRaisesRegex(ValueError, 'input file'):
            match_inventory(shards, local, remote, 'parent')

    def test_duplicate_custom_id_across_shards_fails_before_submission(self):
        shards, _, _, _ = fixtures()
        shards[2]['request_ids'] = ['a']
        with self.assertRaises(ValueError):
            check_shards(shards)

    def test_parent_spend_and_all_inflight_reservations_share_one_cap(self):
        shards, local, remote, reconciled = fixtures()
        matched = match_inventory(shards, local, remote, 'parent')
        ledger, results, stop = restore_ledger(shards, matched, reconciled)
        self.assertEqual(ledger.spent, 60*NANO)
        self.assertEqual(ledger.reserved, {'s1': 80*NANO})
        self.assertTrue(ledger.reserve('s2', 50*NANO))
        self.assertFalse(ledger.reserve('s3', 11*NANO))
        self.assertEqual(list(results), ['a']); self.assertEqual(stop, [])

    def test_unknown_historical_billing_keeps_full_liability_and_stops(self):
        shards, local, remote, reconciled = fixtures()
        reconciled['s0']['accounted_nano_usd'] = None
        ledger, _, stop = restore_ledger(shards, match_inventory(shards, local, remote, 'parent'), reconciled)
        self.assertEqual(ledger.spent, 100*NANO)
        self.assertFalse(ledger.reserve('s2', 21*NANO))
        self.assertIn('unknown_inherited_billing', stop)

    def test_historical_cost_or_result_identity_cannot_be_forged(self):
        shards, local, remote, reconciled = fixtures()
        matched = match_inventory(shards, local, remote, 'parent')
        reconciled['s0']['rows'][0]['batch_id'] = 'wrong'
        with self.assertRaisesRegex(ValueError, 'identity'):
            restore_ledger(shards, matched, reconciled)

    def test_quota_admission_waits_for_validation_and_stops_on_failure(self):
        active = {'s1': {'status': 'validating', 'poll_errors': 0}}
        self.assertFalse(admission_ready(active, 16, []))
        active['s1']['status'] = 'in_progress'
        self.assertTrue(admission_ready(active, 16, []))
        self.assertFalse(admission_ready(active, 1, []))
        self.assertFalse(admission_ready(active, 16, ['quota_rejected']))
        active['s1']['poll_errors'] = 1
        self.assertFalse(admission_ready(active, 16, []))


if __name__ == '__main__':
    unittest.main()

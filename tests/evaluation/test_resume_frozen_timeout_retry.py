import copy
import unittest

from archive.scripts.experiments.resume_frozen_timeout_retry import combine_rows, partition_jobs


class ResumeFrozenRetryTests(unittest.TestCase):
    def setUp(self):
        self.jobs = [{'stage': 'anchor', 'id': x, 'reason': 'search_timeout'} for x in ('a', 'b', 'c')]
        self.retained = {'anchor': [{'id': 'b', 'valid': False, 'search': {'status': 'wall_time_limit'}}]}
        self.pending = [dict(self.jobs[0]), dict(self.jobs[2])]

    def test_pending_is_exact_ordered_complement(self):
        complete, pending = partition_jobs(self.jobs, self.retained, self.pending)
        self.assertEqual(set(complete), {('anchor', 'b')})
        self.assertEqual([j['id'] for j in pending], ['a', 'c'])
        for wrong in (self.pending[::-1], self.pending[:1], self.pending + [self.jobs[1]], self.pending * 2):
            with self.subTest(wrong=wrong), self.assertRaises(ValueError):
                partition_jobs(self.jobs, self.retained, wrong)

    def test_duplicate_or_unknown_completed_receipt_rejected(self):
        for rows in ([{'id': 'b'}, {'id': 'b'}], [{'id': 'unknown'}]):
            with self.subTest(rows=rows), self.assertRaises(ValueError):
                partition_jobs(self.jobs, {'anchor': rows}, self.pending)

    def test_duplicate_registration_and_changed_reason_rejected(self):
        with self.assertRaises(ValueError):
            partition_jobs(self.jobs * 2, self.retained, self.pending)
        changed = copy.deepcopy(self.pending)
        changed[0]['reason'] = 'replay_timeout'
        with self.assertRaises(ValueError):
            partition_jobs(self.jobs, self.retained, changed)

    def test_completed_failure_retained_verbatim_not_best_of_two(self):
        original = {'anchor': [{'id': 'b', 'valid': True}]}
        retry = self.retained['anchor'][0]
        output = combine_rows(original, {('anchor', 'b'): retry}, {('anchor', 'b')}, 'parent')
        self.assertEqual(output['anchor'], [retry])
        self.assertFalse(output['anchor'][0]['valid'])
        self.assertTrue(original['anchor'][0]['valid'])

    def test_missing_retry_and_nonselected_rows_remain_distinct(self):
        original = {'anchor': [{'id': 'a', 'valid': False}, {'id': 'untouched', 'valid': True}]}
        output = combine_rows(original, {}, {('anchor', 'a')}, 'parent')['anchor']
        self.assertEqual(len(output), 2)
        self.assertEqual(output[0]['execution_provenance']['retry_status'], 'not_completed')
        self.assertEqual(output[1]['execution_provenance']['retry_status'], 'not_selected_non_timeout')
        self.assertTrue(output[1]['valid'])

    def test_unknown_result_duplicate_parent_and_wrong_identity_rejected(self):
        for parents, results, keys in [
            ({'anchor': [{'id': 'a'}]}, {('anchor', 'x'): {'id': 'x'}}, {('anchor', 'a')}),
            ({'anchor': [{'id': 'a'}, {'id': 'a'}]}, {}, {('anchor', 'a')}),
            ({'anchor': [{'id': 'a'}]}, {('anchor', 'a'): {'id': 'b'}}, {('anchor', 'a')}),
        ]:
            with self.subTest(results=results), self.assertRaises(ValueError):
                combine_rows(parents, results, keys, 'parent')


if __name__ == '__main__':
    unittest.main()

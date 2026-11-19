import unittest
from scripts.experiments.run_glaive_capped_continuation import merge_initial


class CappedContinuationTests(unittest.TestCase):
    def task(self, kind, identifier, **extra):
        return dict(kind=kind, id=identifier, domain='d', problem='p', condition='full', **extra)

    def test_preserves_checkpoint_rows_and_all_unavailable_slots(self):
        a, b, c = self.task('anchor', 'a'), self.task('anchor', 'b'), self.task('anchor', 'c', status='missing_world')
        retained = dict(a, valid=True, search={'status': 'solved', 'seconds': .2})
        new = dict(b, valid=False, search={'status': 'wall_time_limit'})
        rows = merge_initial([a, b, c], [retained], [new])
        self.assertEqual(rows[:2], [retained, new])
        self.assertEqual(rows[2]['search'], {'status': 'missing_world', 'search_calls': 0})

    def test_same_id_in_different_stages_is_distinct(self):
        a, b = self.task('anchor', 'same'), self.task('transport', 'same')
        self.assertEqual(len(merge_initial([a, b], [a], [b])), 2)

    def test_does_not_replace_completed_rows(self):
        a = self.task('anchor', 'a')
        with self.assertRaises(ValueError):
            merge_initial([a], [a], [a])

    def test_rejects_missing_ready_rows(self):
        with self.assertRaises(ValueError):
            merge_initial([self.task('anchor', 'a')], [], [])

    def test_rejects_unregistered_or_changed_inputs(self):
        a = self.task('anchor', 'a')
        for bad in (self.task('anchor', 'b'), dict(a, domain='changed')):
            with self.assertRaises(ValueError):
                merge_initial([a], [], [bad])


if __name__ == '__main__':
    unittest.main()

import unittest
from pathlib import Path
from scripts.experiments import run_glaive_timeout_pairs as runner
from scripts.audit.summarize_glaive_timeout_pairs import intervals, last_phase, paired_intervals


class TimeoutPairTests(unittest.TestCase):
    def fixture(self):
        selected = []
        registered = {}
        for kind, n in runner.EXPECTED.items():
            for i in range(n):
                task = {'kind': kind, 'id': str(i), 'domain': 'd', 'problem': 'p', 'status': 'ready'}
                case = {**task, 'historical': {**task, 'plan': 'old-plan'},
                        'last_phase': 'init', 'mode': 'replay' if kind == 'transport' else 'search'}
                selected.append(case)
                registered[runner.key(task)] = task
        return {'selected': selected}, registered

    def test_shared_ids_across_stages_preserve_full_denominator(self):
        selection, registered = self.fixture()
        rows = runner.select_tasks(selection, registered)
        self.assertEqual(len(rows), 355)
        self.assertEqual(len({runner.key(r['task']) for r in rows}), 355)

    def test_duplicate_stage_id_is_rejected(self):
        selection, registered = self.fixture()
        selection['selected'][0] = selection['selected'][1]
        with self.assertRaisesRegex(ValueError, 'Duplicate'):
            runner.select_tasks(selection, registered)

    def test_changed_initial_problem_rejected(self):
        selection, registered = self.fixture()
        selection['selected'][0]['historical']['problem'] = 'changed'
        with self.assertRaisesRegex(ValueError, 'Changed task input'):
            runner.select_tasks(selection, registered)

    def test_hash_order_independent_of_input_order(self):
        selection, registered = self.fixture()
        before = runner.select_tasks(selection, registered)
        selection['selected'].reverse()
        self.assertEqual(before, runner.select_tasks(selection, registered))
        self.assertEqual({tuple(r['arm_order']) for r in before}, {('before', 'after'), ('after', 'before')})

    def test_transport_uses_exact_saved_plan_and_no_search(self):
        pair = {'task': {'kind': 'transport', 'id': 'shared'}, 'historical': {'plan': 'frozen'}, 'mode': 'replay'}
        job = runner.make_job(Path('root'), pair, 'after')
        self.assertEqual(job['replay_plan'], 'frozen')
        self.assertEqual(job['retained_search']['search_calls'], 0)
        self.assertEqual(job['seconds'], 60)
        pair['mode'] = 'search'
        self.assertNotIn('replay_plan', runner.make_job(Path('root'), pair, 'before'))

    def test_no_solution_is_not_success_and_timeout_time_is_retained(self):
        rows = [{'kind': 'anchor', 'search': {'status': 'wall_time_limit', 'seconds': 60}},
                {'kind': 'composition', 'search': {'status': 'no_solution_returned', 'seconds': 4,
                   'phase_events': [{'phase': 'search_begin', 'elapsed_seconds': 3}]}},
                {'kind': 'transport', 'replay': {'status': 'replayed', 'seconds': 2,
                   'phase_events': [{'phase': 'replay_axioms_end', 'elapsed_seconds': 1}]},
                 'native_valid': True, 'valid': False}]
        result = runner.summarize(rows)
        self.assertEqual(result['cases'], 3)
        self.assertEqual(result['dual_valid'], 0)
        self.assertEqual(result['native_valid'], 1)
        self.assertEqual(result['initialization_completed'], 2)
        self.assertEqual(result['invocation_seconds_including_timeouts'], 66)
        self.assertEqual(result['search_timeouts'], 1)

    def test_missing_timing_is_unknown_not_zero(self):
        result = runner.summarize([{'kind': 'native'}, {'kind': 'native', 'search': {'seconds': 60}}])
        self.assertEqual(result['primary_measured_calls'], 1)
        self.assertEqual(result['primary_median_seconds_including_timeouts'], 60)

    def test_lost_positive_not_hidden_by_new_positive(self):
        rows = [{'kind': 'anchor', 'id': 'a', 'historical': {'kind': 'anchor'},
                 'before': {'kind': 'anchor', 'valid': True}, 'after': {'kind': 'anchor', 'valid': False}},
                {'kind': 'anchor', 'id': 'b', 'historical': {'kind': 'anchor'},
                 'before': {'kind': 'anchor', 'valid': False}, 'after': {'kind': 'anchor', 'valid': True}}]
        result = runner.compare(rows)['all']['paired']
        self.assertEqual(result['gained_dual_valid'], 1)
        self.assertEqual(result['lost_dual_valid'], 1)


class TimeoutSummaryTests(unittest.TestCase):
    def test_unfinished_initialization_is_censored(self):
        rows = [{'after': {'search': {'phase_events': [{'phase': 'search_setup_begin', 'elapsed_seconds': 1}]}}},
                {'after': {'search': {'phase_events': [{'phase': 'search_setup_begin', 'elapsed_seconds': 2},
                                                      {'phase': 'search_setup_end', 'elapsed_seconds': 5}]}}}]
        result = intervals(rows, 'after')['search_setup']
        self.assertEqual(result['started_intervals'], 2)
        self.assertEqual(result['completed_intervals'], 1)
        self.assertEqual(result['unfinished_intervals'], 1)
        self.assertEqual(result['median_completed_seconds'], 3)

    def test_search_and_replay_phase_clocks_are_separate(self):
        rows = [{'after': {part: {'phase_events': [{'phase': 'parse_begin', 'elapsed_seconds': start},
                                                 {'phase': 'parse_end', 'elapsed_seconds': end}]}
                           for part, start, end in [('search', 2, 4), ('replay', 1, 6)]}}]
        result = intervals(rows, 'after')['parse']
        self.assertEqual(result['completed_intervals'], 2)
        self.assertEqual(result['total_completed_seconds'], 7)
        self.assertEqual(result['median_completed_seconds'], 3.5)

    def test_transport_last_phase_uses_replay(self):
        row = {'kind': 'transport', 'search': {'phase_events': [{'phase': 'irrelevant'}]},
               'replay': {'phase_events': [{'phase': 'replay_axioms_begin'}]}}
        self.assertEqual(last_phase(row), 'replay_axioms_begin')
        self.assertEqual(last_phase({'kind': 'native'}), 'unrecorded')

    def test_phase_comparison_uses_same_completed_tasks(self):
        def events(start, end=None):
            result = [{'phase': 'search_setup_begin', 'elapsed_seconds': start}]
            if end is not None:
                result.append({'phase': 'search_setup_end', 'elapsed_seconds': end})
            return {'search': {'phase_events': result}}
        rows = [{'before': events(1, 4), 'after': events(5, 6)},
                {'before': events(2), 'after': events(2, 4)},
                {'before': {}, 'after': events(0, 7)}]
        result = paired_intervals(rows)['search/search_setup']
        self.assertEqual(result['matched_completed_pairs'], 1)
        self.assertEqual(result['median_before_seconds_matched'], 3)
        self.assertEqual(result['median_after_seconds_matched'], 1)
        self.assertEqual(result['before_unfinished_after_completed'], 1)
        self.assertEqual(result['before_not_started_after_completed'], 1)

    def test_new_replay_is_not_paired_with_old_search(self):
        phase = {'phase_events': [{'phase': 'parse_begin', 'elapsed_seconds': 0},
                                 {'phase': 'parse_end', 'elapsed_seconds': 1}]}
        result = paired_intervals([{'before': {'search': phase}, 'after': {'replay': phase}}])
        self.assertEqual(result['replay/parse']['matched_completed_pairs'], 0)
        self.assertEqual(result['replay/parse']['before_not_started_after_completed'], 1)


if __name__ == '__main__':
    unittest.main()

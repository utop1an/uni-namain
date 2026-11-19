import unittest
from scripts.experiments import run_optimized_frozen_evaluation as runner
from scripts.audit import compare_optimized_frozen_evaluation as comparison


class FrozenOptimizedRunnerTests(unittest.TestCase):
    def test_eligibility_retains_non_timeout_failures_and_unknowns(self):
        for status in ('no_solution_returned','native_parse_error','memory_limit',
                       'unavailable_valid_reference','runtime_error'):
            self.assertIsNone(runner.retry_reason({'search':{'status':status}}))
        self.assertEqual(runner.retry_reason({'search':{'status':'wall_time_limit'}}),'search_timeout')

    def test_solved_search_replay_timeout_does_not_authorize_research(self):
        row={'search':{'status':'solved'},'plan':'frozen-plan.pddl','replay':{'status':'wall_time_limit'}}
        self.assertEqual(runner.retry_reason(row),'replay_timeout')
        row['replay']={'status':'unsupported'}
        self.assertIsNone(runner.retry_reason(row))

    def test_worker_cap_after_plan_is_replay_only(self):
        self.assertEqual(runner.retry_reason({'status':'worker_wall_time_limit','plan':'p'}),'replay_timeout')
        self.assertEqual(runner.retry_reason({'status':'worker_wall_time_limit'}),'search_timeout')

    def test_offline_hook_blocks_requests_before_connection(self):
        for event in ('socket.connect','socket.connect_ex','socket.getaddrinfo','urllib.Request'):
            with self.assertRaisesRegex(RuntimeError,'forbids'):runner.offline_guard(event,())
        runner.offline_guard('open',())

    def test_native_criterion_requires_goal_and_full_intentional_explanation(self):
        self.assertTrue(runner.native_ok({'status':'replayed','goal':True,'unexplained_steps':0}))
        for row in ({'status':'replayed','goal':True},{'status':'replayed','goal':False,'unexplained_steps':0},
                    {'status':'replayed','goal':True,'unexplained_steps':1}):
            self.assertFalse(runner.native_ok(row))

    def test_complete_registered_denominators(self):
        self.assertEqual(sum(runner.EXPECTED.values()),28684)
        self.assertEqual(runner.EXPECTED['composition'],1200*2)

    def test_physical_contradiction_cannot_be_downgraded_to_unknown(self):
        row={'native_valid':True,'valid':False,'replay':{'physical':{'status':'inapplicable'}}}
        self.assertEqual(comparison.classify(row),'physical_violation')
        row['replay']['physical']['status']='unsupported'
        self.assertEqual(comparison.classify(row),'native_valid_physical_unknown')

    def test_retry_time_counts_only_new_calls(self):
        before=[{'id':'one','search':{'status':'solved','seconds':3},'replay':{'status':'wall_time_limit','seconds':15}}]
        after=[{'id':'one','search':before[0]['search'],'replay':{'status':'replayed','seconds':2}}]
        added=comparison.timing(comparison.retry_increment(before,after))
        self.assertEqual(added['search']['measured_calls'],0)
        self.assertEqual(added['replay']['total_seconds'],2)
        self.assertEqual(comparison.retry_increment(before,before),[])

    def test_native_linux_kill_after_is_a_timeout(self):
        for code,elapsed in [(124,15),(137,17),(-9,17.01),(-9,62.01)]:
            limit=60 if elapsed>60 else 15
            self.assertTrue(runner.timeout_exit(code,elapsed,limit))
        self.assertFalse(runner.timeout_exit(-9,4,15))
        self.assertFalse(runner.timeout_exit(1,17,15))

    def test_incomplete_and_invalid_replay_have_explicit_outcomes(self):
        self.assertEqual(comparison.classify({'search':{'status':'solved'}}),'replay_not_recorded')
        self.assertEqual(comparison.classify({'replay':{'status':'replayed','goal':True,'unexplained_steps':1}}),'intentional_or_goal_violation')

    def test_unfinished_phase_is_censored_not_zero(self):
        rows=[{'search':{'phase_events':[{'phase':'state_space_begin','elapsed_seconds':1.0}]}},
              {'search':{'phase_events':[{'phase':'state_space_begin','elapsed_seconds':2.0},{'phase':'state_space_end','elapsed_seconds':5.0}]}}]
        value=comparison.measured_phases(rows)['search']['state_space']
        self.assertEqual(value['completed_intervals'],1)
        self.assertEqual(value['median_seconds'],3.0)

    def test_same_identifier_in_different_stages_never_crosses_results(self):
        anchor={'id':'shared','kind':'anchor','search':{'status':'wall_time_limit'}}
        transport={'id':'shared','kind':'transport','search':{'status':'not_a_search'},'replay':{'status':'wall_time_limit'}}
        retried_anchor={**anchor,'search':{'status':'no_solution_returned'}}
        retried_transport={**transport,'replay':{'status':'replayed'}}
        initial={'anchor':[anchor],'transport':[transport]}
        both=runner.merge_retry_results(initial,[retried_anchor,retried_transport])
        self.assertEqual(both,{'anchor':[retried_anchor],'transport':[retried_transport]})
        anchor_only=runner.merge_retry_results(initial,[retried_anchor])
        self.assertEqual(anchor_only['transport'],[transport])

    def test_duplicate_or_unregistered_retry_identity_is_rejected(self):
        row={'id':'same','kind':'anchor','search':{'status':'wall_time_limit'}}
        initial={'anchor':[row]}
        with self.assertRaisesRegex(ValueError,'duplicate'):
            runner.merge_retry_results(initial,[row,row])
        with self.assertRaisesRegex(ValueError,'Unregistered'):
            runner.merge_retry_results(initial,[{**row,'kind':'transport'}])
        with self.assertRaisesRegex(ValueError,'non-timeout'):
            runner.merge_retry_results({'anchor':[{**row,'search':{'status':'solved'}}]},[row])


if __name__=='__main__':unittest.main()

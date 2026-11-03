import unittest

from scripts.experiments.run_revised_multistory import replay_evidence,valid


class MultistoryRunnerEvidenceTests(unittest.TestCase):
    def test_both_validators_required(self):
        r={'status':'replayed','goal':True,'unexplained_steps':0,'physical':{'status':'replayed','goal':True}}
        self.assertTrue(valid(r));self.assertEqual(replay_evidence(r),'valid')
        self.assertFalse(valid({k:v for k,v in r.items() if k!='physical'}))

    def test_timeout_is_unknown_even_if_physical_plan_passes(self):
        r={'status':'wall_time_limit','physical':{'status':'replayed','goal':True}}
        self.assertEqual(replay_evidence(r),'unknown')

    def test_unsupported_validator_is_not_a_success(self):
        r={'status':'replayed','goal':True,'unexplained_steps':0,'physical':{'status':'unsupported'}}
        self.assertFalse(valid(r));self.assertEqual(replay_evidence(r),'unknown')

    def test_inapplicable_step_is_an_observed_violation(self):
        r={'status':'runtime_error','physical':{'status':'inapplicable','step':1}}
        self.assertEqual(replay_evidence(r),'physical_violation')

    def test_failed_goal_is_an_observed_violation(self):
        self.assertEqual(replay_evidence({'physical':{'status':'replayed','goal':False}}),'physical_violation')

    def test_unexplained_actions_fail_intention_gate(self):
        r={'status':'replayed','goal':True,'unexplained_steps':1,'physical':{'status':'replayed','goal':True}}
        self.assertEqual(replay_evidence(r),'intentional_or_goal_violation')


if __name__=='__main__':unittest.main()

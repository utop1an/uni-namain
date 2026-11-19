from pathlib import Path
import tempfile
import unittest

from rcnc.revised_probe_validation import changes, replay_physical
from rcnc.revised_followup import branch_specs, write_native_fixture
from tests.test_glaive_merge import fixture


class RevisedPhysicalReplayTests(unittest.TestCase):
    def test_positive_transition_and_negative_precondition(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);sources,_=fixture(root);s=sources[1]
            for spec in branch_specs(s,'travel'):
                p=root/(spec['id']+'.pddl');plan=root/(spec['id']+'_plan.pddl')
                write_native_fixture(s,spec,p,plan)
                result=replay_physical(s.domain_path,p,plan)
                if spec['expected']=='applicable':
                    self.assertEqual(result['status'],'replayed');self.assertFalse(result['initial_goal']);self.assertTrue(result['goal'])
                    self.assertTrue(result['applied'][0]['deleted']);self.assertTrue(result['applied'][0]['added'])
                else:self.assertEqual(result['status'],'inapplicable')

    def test_conditional_effects_use_pre_state(self):
        add,delete=changes(['and',['not',['p']],['when',['p'],['q']]],{('p',)})
        self.assertEqual(add,{('q',)});self.assertEqual(delete,{('p',)})

    def test_wrong_binding_and_wrong_problem_fail_closed(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);sources,_=fixture(root);s=sources[0];spec=branch_specs(s,'travel')[0]
            p,plan=root/'p.pddl',root/'plan.pddl';write_native_fixture(s,spec,p,plan)
            original=plan.read_text();plan.write_text(original.replace('probe_v0','unknown_object'))
            with self.assertRaisesRegex(ValueError,'Ill-typed'):replay_physical(s.domain_path,p,plan)
            plan.write_text(original.replace(':problem left_witness_positive',':problem wrong'))
            with self.assertRaisesRegex(ValueError,'problem mismatch'):replay_physical(s.domain_path,p,plan)


if __name__=='__main__':unittest.main()

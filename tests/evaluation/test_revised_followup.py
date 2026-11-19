from pathlib import Path
import tempfile
import unittest

from rcnc.glaive_merge import build
from rcnc.pddl import parse_sexpr, section, serialize
from rcnc.revised_followup import authored_problem, branch_specs, composition_scenarios, truth
from scripts.experiments.run_revised_followup import classify_replay
from tests.test_glaive_merge import fixture


class RevisedFollowupTests(unittest.TestCase):
    def test_positive_and_each_precondition_negative_are_distinguished(self):
        with tempfile.TemporaryDirectory() as td:
            sources,_=fixture(Path(td));specs=branch_specs(sources[1],'travel')
            self.assertEqual(len(specs),3)
            for spec in specs:
                actual=truth(spec['precondition'],{tuple(a) for a in spec['facts']})
                self.assertEqual(actual,spec['expected']=='applicable')
            self.assertFalse(truth(specs[0]['goal'],{tuple(a) for a in specs[0]['facts']}))
            self.assertTrue(specs[0]['intentions'])

    def test_equality_mutation_uses_explicit_compatible_identity(self):
        with tempfile.TemporaryDirectory() as td:
            sources,_=fixture(Path(td));s=sources[0];action=s.domain.actions['travel']
            action[action.index(':precondition')+1]=['and',['not',['=','?from','?to']],['at','?who','?from']]
            specs=branch_specs(s,'travel');negative=specs[1]
            self.assertEqual(negative['call'][2],negative['call'][3])
            self.assertFalse(truth(negative['precondition'],{tuple(a) for a in negative['facts']}))

    def test_explicit_world_never_copies_source_initial_facts(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);sources,groups=fixture(root);meta=build(sources,root/'merged',groups=groups,merge_actions=True)
            world={'id':'authored','objects':{'actor':{'left':'person','right':'person'},'origin':{'left':'place','right':'place'},'dest':{'left':'place','right':'place'}},
                   'facts':[['left',['at','actor','origin']]],'goal':[['right',['located','actor','dest']]],
                   'intentions':[['actor','right',['located','actor','dest']]]}
            receipt=authored_problem(sources,meta,world,root/'problem.pddl')
            expression=parse_sexpr((root/'problem.pddl').read_text());initial=section(expression,':init')
            self.assertIn(['shared_predicate','actor','origin'],initial)
            self.assertNotIn('alice',serialize(expression))
            self.assertNotIn('ready',serialize(expression))
            self.assertEqual(receipt['source_problem_facts_copied'],0)
            missing=dict(world);del missing['facts']
            with self.assertRaisesRegex(ValueError,'needs_initial_state'):
                authored_problem(sources,meta,missing,root/'bad.pddl')

    def test_source_and_identity_controls_do_not_change_domains(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);sources,groups=fixture(root);meta=build(sources,root/'merged',groups=groups,merge_actions=True)
            world={'id':'authored','objects':{'actor':{'left':'person','right':'person'},'dest':{'left':'place','right':'place'}},
                   'facts':[],'goal':[['right',['located','actor','dest']]],'intentions':[]}
            receipt=authored_problem(sources,meta,world,root/'control.pddl',active_sources=['left'],separate_identity=True)
            initial=section(parse_sexpr((root/'control.pddl').read_text()),':init')
            self.assertIn(['left_active'],initial);self.assertNotIn(['right_active'],initial)
            self.assertNotEqual(receipt['object_maps']['left']['actor'],receipt['object_maps']['right']['actor'])
            self.assertIn(['left_type_person','left_entity_actor'],initial)
            self.assertNotIn(['right_type_person','left_entity_actor'],initial)

    def test_timeout_and_parser_error_are_not_negative_test_success(self):
        log='java.lang.IllegalArgumentException: Inapplicable step 0'
        self.assertEqual(classify_replay({'status':'runtime_error','returncode':1},log,'inapplicable'),'pass_expected_rejection')
        for status in ('wall_time_limit','native_parse_error','replayed'):
            self.assertEqual(classify_replay({'status':status,'returncode':1},log,'inapplicable'),'fail')
        self.assertEqual(classify_replay({'status':'replayed','goal':True,'unexplained_steps':0,'steps':1},'','applicable'),'pass')
        self.assertEqual(classify_replay({'status':'replayed','goal':True,'unexplained_steps':1,'steps':1},'','applicable'),'fail')

    def test_two_authored_families_keep_four_explicit_worlds(self):
        worlds=composition_scenarios()
        self.assertEqual(len(worlds),4)
        self.assertEqual({x['family'] for x in worlds},{'play_then_sleep','transfer_clean_wear'})
        for world in worlds:
            self.assertIn(world['size'],(1,3));self.assertIn('facts',world)
            self.assertTrue(world['goal']);self.assertTrue(world['intentions'])


if __name__=='__main__':unittest.main()

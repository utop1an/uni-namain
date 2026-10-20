import json
from pathlib import Path
import tempfile
import unittest
from rcnc.pddl import parse_domain, write_domain
from scripts.experiments.prepare_snow_roles_case import prepare as prepare_short
from scripts.experiments.prepare_snow_long_case import prepare as prepare_long, SOURCE_BACKBONE
from scripts.audit.audit_snow_long_case import replay


class LongSnowCaseTests(unittest.TestCase):
    def test_material_dependencies_and_irrelevant_padding_are_distinguished(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp);inputs=root/'inputs';inputs.mkdir()
            selected={s:{n for source,n in SOURCE_BACKBONE if source==s} for s in ('HANS_NP','JACK_NP','SNOW')}
            # A small fixture retains source vocabulary/types/constants while
            # limiting the fixture's actions to the four source backbone types.
            for source,names in selected.items():
                domain=parse_domain(Path('data/narra-domains')/(source+'_domainfile.pddl'))
                domain.actions={n:a for n,a in domain.actions.items() if n in names}
                write_domain(domain,inputs/(source+'_domainfile.pddl'))
                (inputs/(source+'_problemfile.pddl')).write_bytes((Path('data/narra-domains')/(source+'_problemfile.pddl')).read_bytes())
            short=root/'short';prepare_short(inputs,short)
            long=root/'long';manifest=prepare_long(short,long)
            self.assertEqual(23,manifest['task_count'])
            self.assertFalse((long/'solver').exists())
            task=long/'bundle/tasks/role_safe'
            meta=json.loads((task/'source_mapping.json').read_text())
            def src(s,n,*args):
                return '('+' '.join([meta['action_maps'][s][n],*args])+')'
            lines=['(scene__enter_hut q__rescuer q__companion q__outside q__hut)',
                src('HANS_NP','collect_treasure','q__companion','q__rescuer','q__comb','q__gem','q__hut'),
                '(scene__take_axe q__jack q__axe q__workshop)',
                '(scene__approach_beanstalk q__jack q__axe q__workshop d001__c_beanstalk)',
                '(scene__hand_comb_to_witch q__rescuer q__snow_white q__comb q__hut)',
                src('SNOW','stepmother_makes_poisonous_comb_and_visits_cottage','q__snow_white','q__comb','q__hut'),
                '(scene__take_comb_back q__rescuer q__snow_white q__comb q__hut)',
                '(scene__begin_descent q__snow_white q__rescuer q__comb q__hut d001__c_beanstalk)',
                src('JACK_NP','cut_beanstalk','q__snow_white','q__jack','q__axe'),
                '(scene__reach_fallen q__rescuer q__snow_white q__comb q__hut d001__c_cottage)',
                '(scene__apply_comb q__rescuer q__snow_white q__comb d001__c_cottage)',
                src('SNOW','dwarfs_remove_comb_rescue_snow_white','q__snow_white','q__rescuer','q__comb')]
            (task/'plan.txt').write_text('\n'.join(lines)+'\n')
            checked=replay(task,task,True)
            self.assertTrue(checked['goal_reached'])
            self.assertFalse(checked['violations'])
            self.assertEqual((4,8),(checked['source_step_count'],checked['new_scenario_step_count']))
            self.assertTrue(checked['all_steps_deletion_necessary'])
            self.assertEqual(12,len(checked['deletion_replays']))
            self.assertTrue(any(e['producer_step']==3 and e['consumer_step']==4 for e in checked['causal_edges']))
            # An idempotent extra action must be diagnosed as padding even
            # though independent plan validation still accepts the goal plan.
            domain=parse_domain(task/'domain.pddl')
            domain.actions['padding']=[':action','padding',':parameters',['?x','-','object'],
                ':precondition',['case_role_snow_white','?x'],':effect',['case_role_snow_white','?x']]
            write_domain(domain,task/'domain.pddl')
            registry=json.loads((task/'action_registry.json').read_text())
            registry['padding']={'kind':'new_scenario_rule','source':'SCENE','original_action':'padding'}
            (task/'action_registry.json').write_text(json.dumps(registry))
            (task/'plan.txt').write_text('\n'.join(lines+['(padding q__snow_white)'])+'\n')
            padded=replay(task,task,True)
            self.assertEqual('VALID',padded['validation']['status'])
            self.assertFalse(padded['all_steps_deletion_necessary'])
            self.assertEqual('redundant_step',padded['deletion_replays'][-1]['outcome'])

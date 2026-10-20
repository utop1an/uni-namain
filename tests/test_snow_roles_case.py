import json
from pathlib import Path
import tempfile
import unittest
from rcnc.pddl import parse_domain
from scripts.experiments.prepare_snow_roles_case import prepare
from scripts.audit.audit_snow_roles_case import replay


class SnowRoleCaseTests(unittest.TestCase):
    def test_role_identity_life_adapter_and_malformed_actor_are_distinguished(self):
        with tempfile.TemporaryDirectory() as tmp:
            output = Path(tmp) / 'case'
            manifest = prepare(Path('data/narra-domains'), output)
            self.assertEqual('frozen_before_search', manifest['status'])
            self.assertFalse((output / 'solver').exists())
            contract = json.loads((output / 'scenario_contract.json').read_text())
            main = output / 'bundle/tasks/role_safe'
            meta = json.loads((main / 'source_mapping.json').read_text())
            domain = parse_domain(main / 'domain.pddl')
            self.assertEqual(sum(len(t) for t in meta['action_maps'].values()), len(domain.actions))
            self.assertEqual(1, len({meta['predicate_maps'][s]['dead'] for s in ('SNOW', 'HANS_NP', 'JACK_NP')}))
            def instance(source, name, *args):
                return '(' + ' '.join([meta['action_maps'][source][name], *['q__' + a for a in args]]) + ')'
            lines = [instance('HANS_NP', 'collect_treasure', 'companion', 'rescuer', 'comb', 'gem', 'hut'),
                instance('SNOW', 'stepmother_makes_poisonous_comb_and_visits_cottage', 'snow_white', 'comb', 'hut'),
                instance('JACK_NP', 'cut_beanstalk', 'snow_white', 'jack', 'axe'),
                instance('SNOW', 'dwarfs_remove_comb_rescue_snow_white', 'snow_white', 'rescuer', 'comb')]
            (main / 'plan.txt').write_text('\n'.join(lines) + '\n')
            audited = replay(main, contract)
            self.assertEqual('VALID', audited['validation']['status'])
            self.assertTrue(audited['goal_reached'])
            self.assertFalse(audited['life_identity_violations'])
            self.assertTrue(audited['role_checks_pass'])
            self.assertFalse(audited['states'][3]['facts']['alive(snow_white)'])
            self.assertTrue(audited['states'][3]['facts']['dead(snow_white)'])
            unsafe = output / 'bundle/tasks/without_life_adapter'
            (unsafe / 'plan.txt').write_text('\n'.join(lines) + '\n')
            audit_unsafe = replay(unsafe, contract)
            self.assertEqual('VALID', audit_unsafe['validation']['status'])
            self.assertTrue(audit_unsafe['life_identity_violations'])
            # Companion is a legal SNOW entity, but is not the cast witch.
            altered = list(lines)
            altered[1] = altered[1].replace('q__snow_white', 'q__companion')
            (main / 'plan.txt').write_text('\n'.join(altered) + '\n')
            with self.assertRaisesRegex(ValueError, 'Inapplicable'):
                replay(main, contract)

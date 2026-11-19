import copy
import json
from pathlib import Path
import shutil
import tempfile
import unittest

from rcnc.conditional_merge import build, canonical_action, certify_replacement, fields, symbol_digest
from rcnc.domain_building import digest, save
from rcnc.narrative_pipeline import map_problem
from rcnc.pddl import parse_domain, parse_sexpr, serialize, typed_symbols, write_domain
from scripts.audit.audit_transport_merge import adapt_witness, transport
from scripts.experiments.prepare_casefold_followup import casefold_ast
from scripts.experiments.run_conditional_merge import remove_source
from scripts.experiments.run_transport_merge import SOURCES, witness, write_native_query


class TransportMergeTests(unittest.TestCase):
    def setUp(self):
        self.root = Path(self.enterContext(tempfile.TemporaryDirectory()))
        inputs = self.root / 'inputs'
        inputs.mkdir()
        paths = [Path('data/external/action_merge_candidates_2026_10_28_v1/logistics98/domain.pddl'),
                 Path('data/external/prospective_sources_2026_10_26_v1/ipc/files/driverlog/domain.pddl')]
        for source, path in zip(SOURCES, paths):
            (inputs / (source + '_domainfile.pddl')).write_text(serialize(casefold_ast(parse_sexpr(path.read_text(encoding='utf-8')))), encoding='utf-8')
        domains = {s: parse_domain(inputs / (s + '_domainfile.pddl')) for s in SOURCES}
        spec = {'version': 1, 'decision_basis': 'authored_assumption',
                'source_sha256': {p.name: digest(p) for p in inputs.iterdir()},
                'type_groups': [{'members': [s + ':object' for s in SOURCES], 'evidence': 'Test root object correspondence'}],
                'predicate_candidates': [], 'action_candidates': []}
        for kind, names in [('predicate', ['at', 'in']), ('action', ['load-truck', 'unload-truck'])]:
            for name in names:
                group = {'id': name.replace('-', '_'), 'evidence': 'Authored test fixture, not model evidence', 'members': []}
                for s in SOURCES:
                    value = domains[s].predicates[name] if kind == 'predicate' else domains[s].actions[name]
                    arity = 2 if kind == 'predicate' else 3
                    group['members'].append({kind: s + ':' + name, 'order': list(range(arity)),
                        'semantics': {'concept': name, 'scope': 'transport', 'roles': [f'role{i}' for i in range(arity)],
                                      'description': 'Authored test meaning', 'evidence': 'Test fixture',
                                      'confidence': 1.0, 'symbol_sha256': symbol_digest(value)}})
                spec[kind + '_candidates'].append(group)
        self.model = self.root / 'model'
        build(inputs, self.model, spec)
        self.meta = json.loads((self.model / 'meta_domain.json').read_text(encoding='utf-8'))
        self.directories = {}
        for source in SOURCES:
            query, plan = witness(source)
            native, target = self.root / source / 'native', self.root / source / 'target'
            native.mkdir(parents=True)
            target.mkdir()
            shutil.copyfile(inputs / (source + '_domainfile.pddl'), native / 'domain.pddl')
            write_native_query(query, native / 'domain.pddl', native / 'problem.pddl')
            (native / 'plan.txt').write_text('\n'.join('(' + ' '.join(a) + ')' for a in plan), encoding='utf-8')
            shutil.copyfile(self.model / 'meta_domain.pddl', target / 'domain.pddl')
            mapping = map_problem(query, self.model, target / 'problem.pddl')
            adapted = self.root / source / 'adapted'
            diagnostic = adapt_witness(native, adapted)
            self.assertEqual('ERROR', diagnostic['strict_default']['status'])
            self.assertEqual('VALID', diagnostic['adapted_validation']['status'])
            self.assertTrue(diagnostic['roundtrip_exact'])
            mapping['objects'] = {diagnostic['object_renaming'][k]: v for k, v in mapping['objects'].items()}
            self.directories[source] = (adapted, target, mapping)

    def replay(self, source, model=None):
        native, target, mapping = self.directories[source]
        return transport(source, native, target, model or self.model, mapping, self.root / ('replay_' + source))

    def test_both_original_branches_transport_through_shared_actions(self):
        for source in SOURCES:
            result = self.replay(source)
            self.assertEqual('PASS', result['status'])
            self.assertEqual({'load-truck': 1, 'unload-truck': 1}, result['merged_source_calls'])
            self.assertGreater(result['truth_checks'], 0)
        self.assertNotEqual(self.meta['action_maps']['LOG98']['drive-truck'], self.meta['action_maps']['DLOG']['drive-truck'])

    def test_false_source_facts_detect_extra_effect_even_when_goal_survives(self):
        _, target, _ = self.directories['LOG98']
        domain = parse_domain(target / 'domain.pddl')
        action = domain.actions[self.meta['action_maps']['LOG98']['load-truck']]
        parameter = next(iter(typed_symbols(fields(action)[':parameters'])))
        fields(action)[':effect'].append([self.meta['predicate_maps']['LOG98']['city'], parameter])
        write_domain(domain, target / 'domain.pddl')
        with self.assertRaisesRegex(ValueError, 'Complete source truth differs'):
            self.replay('LOG98')

    def test_removing_origin_does_not_leave_its_shared_branch_usable(self):
        _, target, _ = self.directories['DLOG']
        domain = remove_source(parse_domain(target / 'domain.pddl'), self.meta, 'DLOG')
        write_domain(domain, target / 'domain.pddl')
        from unified_planning.io import PDDLReader
        from unified_planning.shortcuts import SequentialSimulator
        problem = PDDLReader().parse_problem(str(target / 'domain.pddl'), str(target / 'problem.pddl'))
        action = problem.action(self.meta['action_maps']['DLOG']['load-truck'])
        with SequentialSimulator(problem) as simulator:
            self.assertFalse(simulator.is_applicable(simulator.get_initial_state(), action,
                [problem.object('q__' + n) for n in ('parcel', 'truck', 'a')]))

    def test_effect_certificate_alone_does_not_distinguish_city_and_driver(self):
        domain = parse_domain(self.model / 'meta_domain.pddl')
        actions = [canonical_action(domain.actions[self.meta['action_maps'][s]['drive-truck']], [0, 1, 2, 3]) for s in SOURCES]
        candidate = copy.deepcopy(actions[0])
        candidate[candidate.index(':precondition') + 1] = ['or', *[fields(a)[':precondition'] for a in actions]]
        self.assertEqual('accepted', certify_replacement(actions, candidate)['status'])

    def test_incomplete_parameter_map_rejected(self):
        changed = self.root / 'bad_model'
        changed.mkdir()
        meta = copy.deepcopy(self.meta)
        meta['action_parameter_maps']['LOG98']['load-truck'] = [0, 1, 1]
        save(changed / 'meta_domain.json', meta)
        with self.assertRaisesRegex(ValueError, 'Incomplete action parameter bijection'):
            self.replay('LOG98', changed)


if __name__ == '__main__':
    unittest.main()

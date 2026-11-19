import copy
import json
from pathlib import Path
import tempfile
import unittest

from rcnc.conditional_merge import (build, certify_replacement, fields,
                                    semantic_gate, symbol_digest)
from rcnc.domain_building import digest
from rcnc.merged_planning import solve
from rcnc.narrative_pipeline import run
from rcnc.pddl import parse_domain, parse_sexpr
from scripts.experiments.run_union_regression import translate_plan


def card(value, concept, roles):
    return {'concept': concept, 'scope': 'physical_location', 'roles': roles,
            'description': 'Authored test meaning', 'evidence': 'Fixture definition',
            'symbol_sha256': symbol_digest(value), 'confidence': 1.0}


def fixture(root):
    inputs = root / 'inputs'; inputs.mkdir()
    # B has reversed formal argument order and an extra eligibility condition.
    for source, predicate, name, params, pre, effect in [
        ('A', 'at', 'walk', '?x ?from ?to', '(at ?x ?from)', '(and (not (at ?x ?from)) (at ?x ?to))'),
        ('B', 'located', 'travel', '?to ?x ?from', '(and (located ?x ?from) (ready ?x))',
         '(and (located ?x ?to) (not (located ?x ?from)))')]:
        (inputs / f'{source}_domainfile.pddl').write_text(f'''(define (domain {source})
          (:requirements :strips :typing) (:types thing - object)
          (:predicates ({predicate} ?x ?l - thing) (ready ?x - thing))
          (:action {name} :parameters ({params} - thing) :precondition {pre} :effect {effect}))''', encoding='utf-8')
        (inputs / f'{source}_problemfile.pddl').write_text(f'''(define (problem p) (:domain {source})
          (:objects actor home dest - thing) (:init ({predicate} actor home) (ready actor))
          (:goal ({predicate} actor dest)))''', encoding='utf-8')
    domains = {s: parse_domain(inputs / f'{s}_domainfile.pddl') for s in ('A', 'B')}
    spec = {'version': 1, 'decision_basis': 'authored_assumption',
            'source_sha256': {p.name: digest(p) for p in inputs.glob('*_domainfile.pddl')},
            'type_groups': [{'members': ['A:thing', 'B:thing'], 'evidence': 'Authored fixture types'}],
            'predicate_candidates': [{'id': 'location', 'evidence': 'Authored equivalent location', 'members': [
                {'predicate': f'{s}:{p}', 'order': [0, 1], 'semantics': card(domains[s].predicates[p], 'location', ['actor', 'place'])}
                for s, p in [('A', 'at'), ('B', 'located')]]}],
            'action_candidates': [{'id': 'travel', 'members': [
                {'action': 'A:walk', 'order': [0, 1, 2], 'semantics': card(domains['A'].actions['walk'], 'relocate', ['actor', 'origin', 'destination'])},
                {'action': 'B:travel', 'order': [1, 2, 0], 'semantics': card(domains['B'].actions['travel'], 'relocate', ['destination', 'actor', 'origin'])}]}]}
    return inputs, spec, domains


class ConditionalMergeTests(unittest.TestCase):
    def test_actual_many_to_one_and_permuted_native_plans(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, spec, _ = fixture(root)
            result = build(inputs, root / 'merged', spec)
            self.assertEqual(1, result['merged_action_groups'])
            domain = parse_domain(root / 'merged/meta_domain.pddl')
            self.assertEqual(1, len(domain.actions))
            meta = json.loads((root / 'merged/meta_domain.json').read_text())
            self.assertEqual([2, 0, 1], meta['action_parameter_maps']['B']['travel'])
            self.assertEqual(2, len(meta['action_origins']['shared__a_travel']))
            for source in ('A', 'B'):
                native = solve(inputs / f'{source}_domainfile.pddl', inputs / f'{source}_problemfile.pddl', root / source)
                self.assertEqual('solved', native['status'])
                translated = translate_plan(source, inputs, root / 'merged', root / source, root / f'{source}_replay')
                self.assertEqual('VALID', translated['validation']['status'])

    def test_semantics_rejects_identical_effects_with_different_meaning(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, spec, _ = fixture(root)
            spec['action_candidates'][0]['members'][1]['semantics']['concept'] = 'lend'
            result = build(inputs, root / 'merged', spec)
            self.assertEqual(0, result['merged_action_groups'])
            row = result['decisions'][-1]
            self.assertEqual('rejected', row['status'])
            self.assertEqual('not_checked', row['formal']['status'])
            bypass = build(inputs, root / 'ablation', spec, semantic_mode='off_diagnostic')
            self.assertEqual(1, bypass['merged_action_groups'])

    def test_unknown_stale_sense_and_missing_type_map_do_not_merge(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, spec, domains = fixture(root)
            group = spec['predicate_candidates'][0]
            for value in (None, {}, {'confidence': float('nan')}):
                changed = copy.deepcopy(group); changed['members'][0]['semantics'] = value
                self.assertEqual('unknown', semantic_gate(changed, 'predicate', domains, .9)['status'])
            changed = copy.deepcopy(group); changed['members'][0]['semantics']['symbol_sha256'] = 'stale'
            self.assertEqual('unknown', semantic_gate(changed, 'predicate', domains, .9)['status'])
            spec['type_groups'] = []
            result = build(inputs, root / 'merged', spec)
            self.assertEqual(0, result['merged_predicate_groups'])
            self.assertEqual(0, result['merged_action_groups'])

    def test_source_guards_not_orphaned_or_dropped(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, spec, _ = fixture(root)
            build(inputs, root / 'merged', spec)
            domain = parse_domain(root / 'merged/meta_domain.pddl')
            pre = fields(domain.actions['shared__a_travel'])[':precondition']
            self.assertEqual('or', pre[0])
            self.assertIn('d000', str(pre[1])); self.assertIn('d001', str(pre[2]))
            self.assertIn('ready', str(pre[2]))

    def test_foreign_branch_cannot_bypass_source_membership(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, spec, _ = fixture(root)
            query = {'conditional_merge': spec,
                     'objects': {o: ['B:thing'] for o in ('actor', 'home', 'dest')},
                     'initial': [['B:located', 'actor', 'home']],
                     'goal': {'positive': [['B:located', 'actor', 'dest']]}}
            self.assertEqual('unsolvable', run(query, inputs, root / 'run')['status'])

    def test_removal_control_keeps_other_origin_branch(self):
        from scripts.experiments.run_conditional_merge import remove_source
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, spec, _ = fixture(root)
            build(inputs, root / 'merged', spec)
            meta = json.loads((root / 'merged/meta_domain.json').read_text())
            domain = parse_domain(root / 'merged/meta_domain.pddl')
            removed = remove_source(domain, meta, 'A')
            self.assertEqual(1, len(removed.actions))
            pre = fields(removed.actions['shared__a_travel'])[':precondition']
            self.assertNotIn('d000', str(pre)); self.assertIn('d001', str(pre))
            self.assertIn('ready', str(pre))

    def test_joint_predicate_injectivity_rejects_overlapping_group(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, spec, _ = fixture(root)
            second = copy.deepcopy(spec['predicate_candidates'][0]); second['id'] = 'again'
            spec['predicate_candidates'].append(second)
            result = build(inputs, root / 'merged', spec)
            self.assertEqual(1, result['merged_predicate_groups'])
            self.assertEqual('rejected', result['decisions'][1]['status'])

    def test_pipeline_and_explicit_initial_contract(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, spec, _ = fixture(root)
            query = {'conditional_merge': spec, 'objects': {o: ['A:thing', 'B:thing'] for o in ('actor', 'home', 'dest')},
                     'initial': [['A:at', 'actor', 'home']], 'goal': {'positive': [['B:located', 'actor', 'dest']]}}
            self.assertEqual('solved', run(query, inputs, root / 'run')['status'])
            del query['initial']
            self.assertEqual('needs_initial_state', run(query, inputs, root / 'missing')['status'])

    def test_strengthened_precondition_and_delete_changes_rejected(self):
        old = parse_sexpr('(:action a :parameters (?x - object) :precondition (at ?x) :effect (has ?x))')
        new = copy.deepcopy(old); new[5] = ['and', ['at', '?x'], ['has', '?x']]
        result = certify_replacement([old], new)
        self.assertEqual('strengthened_applicability', result['reason'])
        self.assertEqual([['at', '?x']], result['propositional_counterexample'])
        new = copy.deepcopy(old); new[7] = ['and', ['has', '?x'], ['not', ['at', '?x']]]
        self.assertEqual('different_add_delete_effects', certify_replacement([old], new)['reason'])

    def test_unknown_quantifiers_budget_and_repeated_argument_validity(self):
        old = parse_sexpr('(:action a :parameters (?x ?y - object) :precondition (p ?x) :effect (and (p ?y) (not (p ?x))))')
        new = copy.deepcopy(old); new[5] = ['and', ['p', '?x'], ['q', '?y']]
        self.assertEqual('unknown', certify_replacement([old], new, max_atoms=0)['status'])
        self.assertEqual('accepted', certify_replacement([old], old)['status'])
        new[7] = ['when', ['p', '?x'], ['p', '?y']]
        self.assertEqual('unknown', certify_replacement([old], new)['status'])


if __name__ == '__main__':
    unittest.main()

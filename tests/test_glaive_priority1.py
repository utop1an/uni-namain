import copy
from pathlib import Path
import tempfile
import unittest

from rcnc.conditional_merge import symbol_digest
from rcnc.glaive_intake import ancestors, consent_adaptation, type_graph
from rcnc.glaive_merge import Source, action_fields, build, map_problem
from rcnc.pddl import parse_domain, parse_sexpr, section
from tests.test_glaive_merge import fixture


class PriorityOneTests(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name)

    def files(self, roles=':agents (?giver) :consent (?giver ?receiver)', types='character', extra=''):
        domain = self.root / 'd.pddl'; problem = self.root / 'p.pddl'
        domain.write_text(f'''(define (domain d) (:requirements :adl :intentionality)
          (:types {types}) (:predicates (has ?who - character))
          (:action give :parameters (?giver ?receiver - character) {roles}
            :precondition (has ?giver) :effect (and (not (has ?giver)) (has ?receiver))))''', encoding='utf-8')
        problem.write_text(f'''(define (problem p) (:domain d) (:objects alice bob - character)
          (:init (has alice) (intends alice (has bob)) {extra}) (:goal (has bob)))''', encoding='utf-8')
        return domain, problem

    def test_reflexive_edges_preserve_membership_and_multiple_parents(self):
        base = type_graph(parse_sexpr('(define (domain d) (:types knight - human knight - noble human noble item))'))
        redundant = type_graph(parse_sexpr('(define (domain d) (:types knight - knight knight - human knight - noble human noble - object item - item object))'))
        for typ in base:
            self.assertEqual(ancestors(typ, base), ancestors(typ, redundant))
        self.assertNotIn('item', ancestors('knight', redundant))
        self.assertEqual(redundant['object'], set())

    def test_real_cycles_and_parent_of_root_stay_rejected(self):
        for types in ['a - a a - b b - a', 'a - b b - c c - a', 'object - a']:
            with self.subTest(types=types), self.assertRaises(ValueError):
                type_graph(parse_sexpr(f'(define (domain d) (:types {types}))'))

    def test_normalized_membership_and_provenance_without_editing_files(self):
        d, p = self.files(roles=':agents (?giver)', types='character - character object')
        original = (d.read_bytes(), p.read_bytes())
        s = Source('s', d, p)
        m = build([s], self.root / 'out')
        map_problem([s], s.id, m, self.root / 'out/p.pddl')
        init = section(parse_sexpr((self.root / 'out/p.pddl').read_text(encoding='utf-8')), ':init')
        self.assertIn(['s_type_character', 's_o_alice'], init)
        self.assertIn(['s_type_object', 's_o_bob'], init)
        self.assertEqual(s.normalization['type_self_inheritance']['declarations'], ['character', 'object'])
        self.assertEqual(original, (d.read_bytes(), p.read_bytes()))

    def test_consent_requires_explicit_dialect_policy(self):
        d, p = self.files()
        with self.assertRaisesRegex(ValueError, 'Explicit consent'): Source('s', d, p)
        with self.assertRaisesRegex(ValueError, 'Unknown consent'): Source('s', d, p, consent_policy='ignore')

    def test_all_actor_and_consent_roles_export_without_invented_intentions(self):
        d, p = self.files()
        original = (d.read_bytes(), p.read_bytes())
        s = Source('s', d, p, consent_policy='require_intentional_agents')
        m = build([s], self.root / 'out'); map_problem([s], s.id, m, self.root / 'out/p.pddl')
        fields = action_fields(parse_domain(self.root / 'out/domain.pddl').actions['s_a_give'])
        self.assertEqual(fields[':agents'], ['?giver', '?receiver'])
        init = section(parse_sexpr((self.root / 'out/p.pddl').read_text(encoding='utf-8')), ':init')
        intentions = [x for x in init[1:] if x[0] == 'intends']
        self.assertEqual(intentions, [['intends', 's_o_alice', ['s_p_has', 's_o_bob']]])
        self.assertEqual(m['normalization']['s']['action_consent'][0]['consent'], ['?giver', '?receiver'])
        self.assertEqual(original, (d.read_bytes(), p.read_bytes()))

    def test_consent_only_and_empty_consent_do_not_drop_existing_actor(self):
        for roles, expected in [(':consent (?receiver)', ['?receiver']),
                                (':agents (?giver) :consent ()', ['?giver']),
                                (':agents (?giver) :consent (?receiver)', ['?giver', '?receiver'])]:
            with self.subTest(roles=roles):
                d, p = self.files(roles=roles)
                s = Source('s', d, p, consent_policy='require_intentional_agents')
                self.assertEqual(action_fields(s.domain.actions['give'])[':agents'], expected)

    def test_invalid_or_unbound_consent_roles_rejected(self):
        for roles in [':consent ?receiver', ':consent ((has ?receiver))', ':consent (?receiver ?receiver)',
                      ':consent (?receiver) :consent (?giver)', ':consent (?ghost)', ':consent (ghost)']:
            with self.subTest(roles=roles):
                d, p = self.files(roles=roles)
                with self.assertRaises(ValueError): Source('s', d, p, consent_policy='require_intentional_agents')

    def test_adaptation_leaves_preconditions_effects_and_input_tree_unchanged(self):
        d, _ = self.files()
        root = parse_sexpr(d.read_text(encoding='utf-8')); before = copy.deepcopy(root)
        adapted, receipt = consent_adaptation(root, 'require_intentional_agents')
        old = next(x for x in root if isinstance(x, list) and x[0] == ':action')
        new = next(x for x in adapted if isinstance(x, list) and x[0] == ':action')
        for key in (':parameters', ':precondition', ':effect'):
            self.assertEqual(old[old.index(key)+1], new[new.index(key)+1])
        self.assertEqual(root, before)
        self.assertEqual(len(receipt), 1)

    def test_consent_role_difference_prevents_action_fusion(self):
        sources, groups = fixture(self.root)
        s = sources[1]
        s.domain_path.write_text(s.domain_path.read_text(encoding='utf-8').replace(':agents (?who)', ':agents (?who) :consent (?to)'), encoding='utf-8')
        sources[1] = Source(s.id, s.domain_path, s.problem_path, consent_policy='require_intentional_agents')
        groups[1]['members'][1]['semantics']['symbol_sha256'] = symbol_digest(sources[1].domain.actions['travel'])
        result = build(sources, self.root / 'out', groups=groups, merge_actions=True)
        self.assertEqual(result['action_count'], 2)
        self.assertEqual(result['decisions'][-1]['reason'], 'Different consenting agent roles')


if __name__ == '__main__': unittest.main()

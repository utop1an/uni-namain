from pathlib import Path
import tempfile
import unittest

from rcnc.glaive_intake import constant_contract
from rcnc.glaive_merge import Source, build, map_problem, translate_plan, action_fields
from rcnc.pddl import parse_domain, parse_sexpr, section, typed_symbols


class GlaiveIntakeTests(unittest.TestCase):
    def setUp(self):
        self.root = Path(self.enterContext(tempfile.TemporaryDirectory()))

    def files(self, domain, problem, suffix=''):
        d, p = self.root / ('domain' + suffix + '.pddl'), self.root / ('problem' + suffix + '.pddl')
        d.write_text(domain, encoding='utf-8')
        p.write_text(problem, encoding='utf-8')
        return d, p

    def test_casefold_requirements_initial_state_and_plan_use_one_identity(self):
        d, p = self.files('''(DEFINE (DOMAIN D) (:types Person)
          (:predicates (At ?X - Person) (Done ?X - Person))
          (:action GO :parameters (?WHO - Person) :precondition (At ?who)
           :effect (AND (NOT (AT ?WHO)) (Done ?who)) :agents (?Who)))''',
          '''(define (problem P) (:DOMAIN d) (:requirements :negative-preconditions)
          (:objects ALICE - PERSON) (:INIT (AT alice) (intends Alice (done ALICE)))
          (:goal (AND (DONE Alice))))''')
        original = (d.read_bytes(), p.read_bytes())
        s = Source('s', d, p)
        m = build([s], self.root / 'out')
        terms = map_problem([s], 's', m, self.root / 'out/problem.pddl')
        self.assertEqual(s.objects, {'alice': 'person'})
        self.assertIn(':negative-preconditions', parse_domain(self.root / 'out/domain.pddl').requirements)
        goal = section(parse_sexpr((self.root / 'out/problem.pddl').read_text(encoding='utf-8')), ':goal')
        self.assertEqual(goal, [':goal', ['s_p_done', 's_o_alice']])
        plan = self.root / 'plan.pddl'
        plan.write_text('(define (plan P) (:steps (GO ALICE)))', encoding='utf-8')
        translate_plan('s', m, terms, plan, self.root / 'mapped.pddl')
        self.assertIn('(s_a_go s_o_alice)', (self.root / 'mapped.pddl').read_text(encoding='utf-8'))
        self.assertEqual(original, (d.read_bytes(), p.read_bytes()))
        self.assertEqual(m['normalization']['s']['problem_spelling'][':INIT'], ':init')

    def test_both_type_branches_reach_objects_without_admitting_siblings(self):
        d, p = self.files('''(define (domain d)
          (:types knight - canmarry knight - noble noble - human mage - human)
          (:predicates (done))
          (:action marry :parameters (?x - canmarry ?y - human) :effect (done)))''',
          '''(define (problem p) (:objects alice - knight bob - mage)
          (:init) (:goal (done)))''')
        s = Source('s', d, p)
        m = build([s], self.root / 'out')
        map_problem([s], 's', m, self.root / 'out/problem.pddl')
        initial = section(parse_sexpr((self.root / 'out/problem.pddl').read_text(encoding='utf-8')), ':init')
        self.assertIn(['s_type_canmarry', 's_o_alice'], initial)
        self.assertIn(['s_type_human', 's_o_alice'], initial)
        self.assertIn(['s_type_human', 's_o_bob'], initial)
        self.assertNotIn(['s_type_canmarry', 's_o_bob'], initial)
        emitted = parse_domain(self.root / 'out/domain.pddl')
        self.assertIn('s_type_canmarry', emitted.predicates)
        self.assertIn(['s_type_canmarry', '?x'], action_fields(emitted.actions['s_a_marry'])[':precondition'])
        self.assertEqual(s.type_parents['knight'], {'canmarry', 'noble'})

    def test_type_cycle_on_either_branch_is_rejected(self):
        d, p = self.files('''(define (domain d) (:types a - object a - b b - a)
          (:predicates (done)))''', '(define (problem p) (:init) (:goal (done)))')
        with self.assertRaisesRegex(ValueError, 'Cyclic'):
            Source('s', d, p)

    def constant_files(self):
        d, p = self.files('''(define (domain d) (:types place)
          (:predicates (at ?x - place))
          (:action arrive :parameters () :effect (at theCity)))''',
          '''(define (problem p) (:objects THECITY elsewhere - place)
          (:init) (:goal (at THECITY)))''')
        p2 = self.root / 'p2.pddl'
        p2.write_text('''(define (problem p2) (:objects thecity another - place)
          (:init (at another)) (:goal (at theCity)))''', encoding='utf-8')
        return d, p, p2

    def test_constant_contract_is_reusable_and_does_not_pool_objects_or_facts(self):
        d, p, p2 = self.constant_files()
        contract = constant_contract(d, [p, p2])
        self.assertEqual(contract, {'thecity': 'place'})
        sources = [Source('s', d, q, constant_contract=contract) for q in (p, p2)]
        for i, s in enumerate(sources):
            out = self.root / str(i)
            m = build([s], out)
            map_problem([s], 's', m, out / 'problem.pddl')
            emitted = parse_domain(out / 'domain.pddl')
            self.assertEqual(emitted.constants, {'s_o_thecity': 'object'})
            self.assertEqual(action_fields(emitted.actions['s_a_arrive'])[':effect'], ['s_p_at', 's_o_thecity'])
            problem = parse_sexpr((out / 'problem.pddl').read_text(encoding='utf-8'))
            self.assertNotIn('s_o_thecity', typed_symbols(section(problem, ':objects')[1:]))
            self.assertIn(['s_type_place', 's_o_thecity'], section(problem, ':init'))
        self.assertEqual((self.root / '0/domain.pddl').read_bytes(), (self.root / '1/domain.pddl').read_bytes())
        self.assertNotIn('another', (self.root / '0/problem.pddl').read_text(encoding='utf-8'))
        self.assertNotIn('elsewhere', (self.root / '1/problem.pddl').read_text(encoding='utf-8'))
        with self.assertRaisesRegex(ValueError, 'Unbound action term'):
            Source('s', d, p)

    def test_constant_contract_rejects_missing_conflicting_and_unused_symbols(self):
        d, p, p2 = self.constant_files()
        for objects in ('another - place', 'thecity - object'):
            p2.write_text(f'(define (problem p2) (:objects {objects}) (:init) (:goal (at thecity)))', encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'No consistent constant declaration'):
                constant_contract(d, [p, p2])
        with self.assertRaisesRegex(ValueError, 'disagrees'):
            Source('s', d, p, constant_contract={'thecity': 'object'})
        with self.assertRaisesRegex(ValueError, 'referenced undeclared constant'):
            Source('s', d, p, constant_contract={'elsewhere': 'place'})

    def test_source_constant_names_stay_separate_in_union(self):
        d, p, p2 = self.constant_files()
        c = constant_contract(d, [p, p2])
        sources = [Source(sid, d, p, constant_contract=c) for sid in ('left', 'right')]
        m = build(sources, self.root / 'out')
        self.assertEqual(set(parse_domain(self.root / 'out/domain.pddl').constants),
                         {'left_o_thecity', 'right_o_thecity'})
        map_problem(sources, 'left', m, self.root / 'out/problem.pddl')
        initial = section(parse_sexpr((self.root / 'out/problem.pddl').read_text(encoding='utf-8')), ':init')
        self.assertIn(['left_active'], initial)
        self.assertNotIn(['right_active'], initial)

    def test_casefold_conflicting_declarations_and_unbound_variables_rejected(self):
        for pred, objects, effect, message in [
            ('(at ?x - place) (AT ?y ?z - place)', 'x - place', '(at ?x)', 'Predicate overload arity mismatch'),
            ('(at ?x - place)', 'X - place x - object', '(at ?x)', 'Conflicting'),
            ('(at ?x - place)', 'x - place', '(at ?unknown)', 'Unbound action term'),
        ]:
            with self.subTest(message=message):
                d, p = self.files(f'''(define (domain d) (:types place) (:predicates {pred})
                  (:action a :parameters (?x - place) :effect {effect}))''',
                  f'(define (problem p) (:objects {objects}) (:init) (:goal (at x)))')
                with self.assertRaisesRegex(ValueError, message):
                    Source('s', d, p)

    def test_missing_initial_and_unsupported_structures_still_rejected(self):
        d, p = self.files('''(define (domain d) (:predicates (done)))''',
                          '(define (problem p) (:goal (done)))')
        with self.assertRaisesRegex(ValueError, 'needs_initial_state'):
            Source('s', d, p)
        p.write_text('(define (problem p) (:init) (:goal (believes a (done))))', encoding='utf-8')
        with self.assertRaisesRegex(ValueError, 'Belief'):
            Source('s', d, p)

    def test_existing_glaive_same_arity_type_overloads_are_retained(self):
        d, p = self.files('''(define (domain d) (:types person place)
          (:predicates (at ?p - person) (at ?l - place))
          (:action a :parameters (?p - person) :effect (at ?p)))''',
          '(define (problem p) (:objects alice - person) (:init) (:goal (at alice)))')
        s = Source('s', d, p)
        m = build([s], self.root / 'out')
        self.assertEqual(len(m['normalization']['s']['predicate_signatures']['at']), 2)
        self.assertIn(['s_type_person', '?p'],
                      action_fields(parse_domain(self.root / 'out/domain.pddl').actions['s_a_a'])[':precondition'])


if __name__ == '__main__':
    unittest.main()

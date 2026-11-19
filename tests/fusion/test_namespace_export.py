from itertools import product
from pathlib import Path
import tempfile
import unittest

from unified_planning.environment import get_environment
from unified_planning.io import PDDLReader

from rcnc.namespace_export import name_maps, inverse_maps, transform, fold_symbol_map
from rcnc.pddl import parse_sexpr, serialize
from scripts.audit.export_namespace_diagnostic import candidate_path


DOMAIN = '''(define (domain base) (:requirements :strips :typing)
    (:types location) (:constants actor - location)
    (:predicates (location ?x - location) (done ?x - location))
    (:action location :parameters (?x - location) :precondition (location ?x)
        :effect (and (not (location ?x)) (done ?x))))'''
PROBLEM = '''(define (problem p) (:domain base) (:init (location actor)) (:goal (done actor)))'''


class NamespaceExportTests(unittest.TestCase):
    def test_parser_symbol_case_is_normalized_without_overwriting_conflicting_maps(self):
        self.assertEqual({'acorn':'obj__acorn'},fold_symbol_map({'Acorn':'obj__Acorn'}))
        self.assertEqual({'a':'x'},fold_symbol_map({'A':'X','a':'x'}))
        with self.assertRaisesRegex(ValueError,'Conflicting'):
            fold_symbol_map({'A':'X','a':'Y'})

    def test_protocol_input_paths_cannot_escape_or_replace_source_files(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            for name in ('../source.pddl', str(root / 'source.pddl')):
                with self.assertRaises(ValueError):
                    candidate_path(root, name)
            self.assertEqual(root / 'fusion/domain.pddl', candidate_path(root, 'fusion/domain.pddl'))

    def test_round_trip_keeps_quantified_variables_parameter_order_and_problem_objects(self):
        domain = parse_sexpr(DOMAIN.replace('(location ?x)\n        :effect', '(forall (?y - location) (location ?y))\n        :effect'))
        problem = parse_sexpr(PROBLEM.replace('(:init', '(:objects extra - location) (:init'))
        maps = name_maps(domain, [problem]); reverse = inverse_maps(maps)
        self.assertEqual(domain, transform(transform(domain, maps), reverse))
        self.assertEqual(problem, transform(transform(problem, maps, problem=True), reverse, problem=True))
        action = next(p for p in transform(domain, maps)[1:] if p[0] == ':action')
        self.assertEqual(['?x', '-', 'type__location'], action[action.index(':parameters') + 1])

    def test_all_finite_valuations_match_applicability_and_successor_after_export(self):
        global_policy = get_environment().error_used_name
        with tempfile.TemporaryDirectory() as temp:
            # Use ordinary names for simulation: UP's grounding helper creates
            # actions in its global environment. Collision-policy parsing is
            # checked separately; no global policy is changed for this audit.
            ordinary = '''(define (domain base) (:requirements :strips :typing)
                (:types place) (:constants actor - place)
                (:predicates (at ?x - place) (done ?x - place))
                (:action visit :parameters (?x - place) :precondition (at ?x)
                    :effect (and (not (at ?x)) (done ?x))))'''
            ordinary_world = '(define (problem p) (:domain base) (:init (at actor)) (:goal (done actor)))'
            root = Path(temp); raw = parse_sexpr(ordinary); world = parse_sexpr(ordinary_world)
            maps = name_maps(raw, [world])
            for name, text in (('source.pddl', ordinary), ('source_problem.pddl', ordinary_world),
                ('target.pddl', serialize(transform(raw, maps))),
                ('target_problem.pddl', serialize(transform(world, maps, problem=True)))):
                (root / name).write_text(text, encoding='utf-8')
            original = PDDLReader().parse_problem(str(root / 'source.pddl'), str(root / 'source_problem.pddl'))
            adapted = PDDLReader().parse_problem(str(root / 'target.pddl'), str(root / 'target_problem.pddl'))
            for values in product((False, True), repeat=2):
                left, right = original.clone(), adapted.clone()
                def atom(problem, predicate, obj):
                    em = problem.environment.expression_manager
                    return em.FluentExp(problem.fluent(predicate), (em.ObjectExp(problem.object(obj)),))
                for predicate, truth in zip(('at', 'done'), values):
                    left.set_initial_value(atom(left, predicate, 'actor'), truth)
                    right.set_initial_value(atom(right, maps['predicates'][predicate], 'obj__actor'), truth)
                with left.environment.factory.SequentialSimulator(problem=left) as a, right.environment.factory.SequentialSimulator(problem=right) as b:
                    x, y = a.get_initial_state(), b.get_initial_state()
                    args_left, args_right = (left.object('actor'),), (right.object('obj__actor'),)
                    possible = a.is_applicable(x, left.action('visit'), args_left)
                    self.assertEqual(possible, b.is_applicable(y, right.action('act__visit'), args_right))
                    if possible:
                        x = a.apply(x, left.action('visit'), args_left)
                        y = b.apply(y, right.action('act__visit'), args_right)
                        for predicate in ('at', 'done'):
                            self.assertEqual(x.get_value(atom(left, predicate, 'actor')).bool_constant_value(),
                                y.get_value(atom(right, maps['predicates'][predicate], 'obj__actor')).bool_constant_value())
        self.assertEqual(global_policy, get_environment().error_used_name)

    def test_unsupported_sections_and_noninjective_maps_are_rejected(self):
        raw = parse_sexpr(DOMAIN); world = parse_sexpr(PROBLEM); maps = name_maps(raw, [world])
        with self.assertRaisesRegex(ValueError, 'Unsupported PDDL section'):
            transform(raw + [[':functions', ['numeric']]], maps)
        with self.assertRaisesRegex(ValueError, 'Non-injective'):
            inverse_maps({'predicates': {'p': 'same', 'q': 'same'}})

    def test_quantified_conditional_effects_and_shadowing_preserve_all_full_bindings(self):
        domain = '''(define (domain quantified) (:requirements :adl :typing)
            (:types alpha_place) (:constants a - alpha_place)
            (:predicates (present ?x - alpha_place) (done ?x - alpha_place))
            (:action finish :parameters (?x - alpha_place ?target - alpha_place)
                :precondition (exists (?x - alpha_place) (present ?x))
                :effect (and (forall (?y - alpha_place) (when (present ?y) (not (present ?y)))) (done ?target))))'''
        world = '''(define (problem q) (:domain quantified) (:objects b - alpha_place)
            (:init) (:goal (and (done a) (not (present b)))))'''
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); raw, problem_ast = parse_sexpr(domain), parse_sexpr(world)
            maps = name_maps(raw, [problem_ast]); reverse = inverse_maps(maps)
            for name, text in (('source.pddl', domain), ('source_problem.pddl', world),
                ('target.pddl', serialize(transform(raw, maps))),
                ('target_problem.pddl', serialize(transform(problem_ast, maps, problem=True)))):
                (root / name).write_text(text, encoding='utf-8')
            self.assertEqual(raw, transform(transform(raw, maps), reverse))
            original = PDDLReader().parse_problem(str(root / 'source.pddl'), str(root / 'source_problem.pddl'))
            adapted = PDDLReader().parse_problem(str(root / 'target.pddl'), str(root / 'target_problem.pddl'))
            self.assertEqual(['x', 'target'], [p.name for p in adapted.action('act__finish').parameters])
            atoms = [(p, obj) for p in ('present', 'done') for obj in ('a', 'b')]
            applicability_checks, transitions = 0, 0
            def expression(problem, pred, obj):
                em = problem.environment.expression_manager
                return em.FluentExp(problem.fluent(pred), (em.ObjectExp(problem.object(obj)),))
            for values in product((False, True), repeat=4):
                left, right = original.clone(), adapted.clone()
                for (pred, obj), truth in zip(atoms, values):
                    left.set_initial_value(expression(left, pred, obj), truth)
                    right.set_initial_value(expression(right, maps['predicates'][pred], maps['objects'][obj]), truth)
                with left.environment.factory.SequentialSimulator(problem=left) as a, right.environment.factory.SequentialSimulator(problem=right) as b:
                    x, y = a.get_initial_state(), b.get_initial_state()
                    self.assertEqual(a.is_goal(x), b.is_goal(y))
                    for names in product(('a', 'b'), repeat=2):
                        args = tuple(left.object(n) for n in names)
                        mapped = tuple(right.object(maps['objects'][n]) for n in names)
                        possible = a.is_applicable(x, left.action('finish'), args)
                        self.assertEqual(possible, b.is_applicable(y, right.action('act__finish'), mapped))
                        applicability_checks += 1
                        if possible:
                            after = a.apply(x, left.action('finish'), args)
                            mapped_after = b.apply(y, right.action('act__finish'), mapped)
                            for pred, obj in atoms:
                                self.assertEqual(after.get_value(expression(left, pred, obj)).bool_constant_value(),
                                    mapped_after.get_value(expression(right, maps['predicates'][pred], maps['objects'][obj])).bool_constant_value())
                            transitions += 1
            self.assertEqual(64, applicability_checks)
            self.assertEqual(48, transitions)


if __name__ == '__main__':
    unittest.main()

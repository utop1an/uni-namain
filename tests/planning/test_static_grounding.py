from itertools import product
from pathlib import Path
import tempfile
import unittest

from unified_planning.io import PDDLReader
from unified_planning.shortcuts import SequentialSimulator

from rcnc.grounding import StaticSafeGrounding
from rcnc.state_grounding import PositiveStateGrounding


class StaticGroundingTests(unittest.TestCase):
    def test_false_ground_and_nullary_conjuncts_prune_all_bindings_without_dropping_arguments(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / 'domain.pddl').write_text('''(define (domain flags) (:requirements :strips :typing)
                (:types item) (:constants a b - item)
                (:predicates (enabled) (never) (at ?x - item) (done))
                (:action flip :parameters () :precondition (and) :effect (enabled))
                (:action go :parameters (?unused - item) :precondition (enabled) :effect (done))
                (:action ground :parameters (?unused - item) :precondition (at a) :effect (done))
                (:action impossible :parameters (?unused - item) :precondition (never) :effect (done)))''', encoding='utf-8')
            (root / 'problem.pddl').write_text('(define (problem p) (:domain flags) (:init) (:goal (done)))', encoding='utf-8')
            problem = PDDLReader().parse_problem(str(root / 'domain.pddl'), str(root / 'problem.pddl'))
            self.assertEqual([], list(StaticSafeGrounding(problem).parameters(problem.action('ground'))))
            self.assertEqual([], list(StaticSafeGrounding(problem).parameters(problem.action('impossible'))))
            # enabled is dynamic: initial falsity is not a static proof.
            self.assertEqual(2, len(list(StaticSafeGrounding(problem).parameters(problem.action('go')))))
            self.assertEqual([], list(PositiveStateGrounding(problem, []).parameters(problem.action('go'))))
            enabled = problem.fluent('enabled')()
            choices = list(PositiveStateGrounding(problem, [enabled]).parameters(problem.action('go')))
            self.assertEqual(2, len(choices))
            self.assertTrue(all(len(args) == 1 for args in choices))

    def test_projection_preserves_all_applicable_instances_before_and_after_dynamic_change(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / 'domain.pddl').write_text('''(define (domain projection)
              (:requirements :strips :typing :negative-preconditions)
              (:types person - object) (:constants a b c - person)
              (:predicates (edge ?x ?y - person) (allowed ?x - person) (on ?x - person) (done))
              (:action toggle :parameters (?x - person) :precondition (not (on ?x)) :effect (on ?x))
              (:action act :parameters (?x ?y - person)
               :precondition (and (edge ?x ?y) (allowed ?x) (on ?x)) :effect (done))
              (:action diagonal :parameters (?x - person) :precondition (edge ?x ?x) :effect (done)))''')
            (root / 'problem.pddl').write_text('''(define (problem p) (:domain projection)
              (:init (edge a b) (edge b a) (allowed a)) (:goal (done)))''')
            problem = PDDLReader().parse_problem(str(root / 'domain.pddl'), str(root / 'problem.pddl'))
            em = problem.environment.expression_manager
            grounder = StaticSafeGrounding(problem)
            with SequentialSimulator(problem) as simulator:
                first = simulator.get_initial_state()
                second = simulator.apply(first, problem.action('toggle'), [em.ObjectExp(problem.object('a'))])
                for state in (first, second):
                    for action in problem.actions:
                        all_bindings = product(*[[em.ObjectExp(obj) for obj in problem.objects(param.type)] for param in action.parameters])
                        expected = {tuple(params) for params in all_bindings if simulator.is_applicable(state, action, params)}
                        actual = {tuple(params) for params in grounder.parameters(action) if simulator.is_applicable(state, action, params)}
                        self.assertEqual(expected, actual, action.name)


if __name__ == '__main__':
    unittest.main()

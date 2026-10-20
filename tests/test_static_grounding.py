from itertools import product
from pathlib import Path
import tempfile
import unittest

from unified_planning.io import PDDLReader
from unified_planning.shortcuts import SequentialSimulator

from rcnc.grounding import StaticSafeGrounding


class StaticGroundingTests(unittest.TestCase):
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

from itertools import product
from pathlib import Path
import tempfile
import unittest

from unified_planning.io import PDDLReader
from unified_planning.shortcuts import SequentialSimulator

from rcnc.inert_grounding import InertParameterGrounding, inert_parameters
from rcnc.state_grounding import PositiveStateGrounding


class InertGroundingTests(unittest.TestCase):
    def test_static_guards_collapse_but_dynamic_disjunctive_and_effect_roles_remain(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / 'd.pddl').write_text('''(define (domain inert) (:requirements :typing :adl)
              (:types item) (:constants a b c - item)
              (:predicates (member ?x - item) (active ?x - item) (done ?x - item))
              (:action finish :parameters (?unused ?guard ?dynamic ?target - item)
                :precondition (and (member ?guard) (active ?dynamic)) :effect (done ?target))
              (:action change :parameters (?x - item) :precondition (and) :effect (active ?x))
              (:action disj :parameters (?x - item) :precondition (or (member ?x) (active a)) :effect (done a))
              (:action conditional :parameters (?x - item) :precondition (and)
                :effect (when (member ?x) (done a))))''', encoding='utf-8')
            (root / 'p.pddl').write_text('''(define (problem p) (:domain inert)
              (:init (member b) (member c) (active a) (active b)) (:goal (done a)))''', encoding='utf-8')
            problem = PDDLReader().parse_problem(str(root / 'd.pddl'), str(root / 'p.pddl'))
            inert = {action: inert_parameters(problem, action) for action in problem.actions}
            self.assertEqual({'unused', 'guard'}, {p.name for p in inert[problem.action('finish')]})
            self.assertFalse(inert[problem.action('disj')])
            self.assertFalse(inert[problem.action('conditional')])
            positive = frozenset(atom for atom, value in problem.explicit_initial_values.items() if value.is_true())
            full = PositiveStateGrounding(problem, positive)
            reduced = InertParameterGrounding(problem, positive, inert)
            action = problem.action('finish')
            self.assertEqual(36, len(list(full.parameters(action))))
            bindings = list(reduced.parameters(action))
            self.assertEqual(6, len(bindings))
            self.assertTrue(all(len(args) == 4 and args[0].object().name == 'a' and args[1].object().name == 'b' for args in bindings))
            with SequentialSimulator(problem) as simulator:
                state = simulator.get_initial_state()
                left = {simulator.apply(state, action, args) for args in full.parameters(action)}
                right = {simulator.apply(state, action, args) for args in bindings}
                self.assertEqual(left, right)


if __name__ == '__main__':
    unittest.main()

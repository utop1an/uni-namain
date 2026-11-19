from itertools import product
from pathlib import Path
import tempfile
import unittest

from unified_planning.io import PDDLReader
from unified_planning.shortcuts import SequentialSimulator

from rcnc.correlated_grounding import parameters
from rcnc.state_grounding import PositiveStateGrounding
from rcnc.state_projected_planning import solve


DOMAIN = '''(define (domain chain) (:requirements :typing :adl)
    (:types item) (:constants a b c d - item)
    (:predicates (edge ?x ?y - item) (blocked ?x - item) (done ?x - item))
    (:action finish :parameters (?x ?y ?z ?unused - item)
        :precondition (and (edge ?x ?y) (edge ?y ?z) (not (blocked ?z)))
        :effect (done ?z))
    (:action repeat :parameters (?x ?y ?unused - item)
        :precondition (and (edge ?x ?x) (edge ?x ?y) (edge ?y c))
        :effect (done ?y))
    (:action fallback :parameters (?x ?y - item)
        :precondition (or (blocked ?x) (not (edge ?x ?y)))
        :effect (done ?y)))'''
PROBLEM = '''(define (problem p) (:domain chain)
    (:init (edge a b) (edge b c) (edge c d)) (:goal (done c)))'''


class CorrelatedGroundingTests(unittest.TestCase):
    def setUp(self):
        self.root = Path(self.enterContext(tempfile.TemporaryDirectory()))
        self.domain, self.world = self.root / 'domain.pddl', self.root / 'problem.pddl'
        self.domain.write_text(DOMAIN, encoding='utf-8')
        self.world.write_text(PROBLEM, encoding='utf-8')

    def test_sparse_path_correlations_and_unused_arguments_are_preserved(self):
        problem = PDDLReader().parse_problem(str(self.domain), str(self.world))
        positive = frozenset(atom for atom, value in problem.explicit_initial_values.items() if value.is_true())
        projection = PositiveStateGrounding(problem, positive)
        action = problem.action('finish')
        before, after = list(projection.parameters(action)), list(parameters(projection, action))
        self.assertEqual(72, len(before))
        self.assertEqual(8, len(after))
        self.assertEqual(8, len(set(after)))
        names = {tuple(value.object().name for value in args) for args in after}
        self.assertEqual({(x,y,z,u) for x,y,z in (('a','b','c'), ('b','c','d')) for u in ('a','b','c','d')}, names)
        with SequentialSimulator(problem) as simulator:
            state = simulator.get_initial_state()
            em = problem.environment.expression_manager
            for action in problem.actions:
                full = product(*[[em.ObjectExp(obj) for obj in problem.objects(p.type)] for p in action.parameters])
                expected = {args for args in full if simulator.is_applicable(state, action, args)}
                actual = {args for args in parameters(projection, action) if simulator.is_applicable(state, action, args)}
                self.assertEqual(expected, actual, action.name)

    def test_joint_and_repeated_variable_constraints_agree_with_cartesian_after_state_change(self):
        self.world.write_text(PROBLEM.replace('(edge c d)', '(edge c d) (edge b b) (blocked d)'), encoding='utf-8')
        problem = PDDLReader().parse_problem(str(self.domain), str(self.world))
        positive = frozenset(atom for atom, value in problem.explicit_initial_values.items() if value.is_true())
        projection = PositiveStateGrounding(problem, positive)
        with SequentialSimulator(problem) as simulator:
            state = simulator.get_initial_state()
            for action in problem.actions:
                candidates = list(parameters(projection, action))
                self.assertEqual(len(candidates), len(set(candidates)))
                expected = {args for args in projection.parameters(action) if simulator.is_applicable(state, action, args)}
                self.assertEqual(expected, {args for args in candidates if simulator.is_applicable(state, action, args)})
                if action.name == 'repeat':
                    self.assertTrue(candidates)
                    self.assertTrue(all(args[0].object().name == 'b' for args in candidates))

    def test_end_to_end_search_keeps_default_and_validates_complete_opt_in_plan(self):
        original = solve(self.domain, self.world, self.root / 'original')
        joined = solve(self.domain, self.world, self.root / 'joined', correlated_parameter_tuples=True)
        self.assertEqual(('solved', 'VALID'), (joined['status'], joined['validation']['status']))
        self.assertEqual(original['length'], joined['length'])
        self.assertLess(joined['candidate_bindings'], original['candidate_bindings'])
        self.assertTrue(joined['budget']['correlated_parameter_tuples'])
        self.assertFalse(original['budget']['correlated_parameter_tuples'])
        line = (self.root / 'joined/plan.txt').read_text(encoding='utf-8').splitlines()[0]
        self.assertEqual(5, len(line.split()))
        with self.assertRaisesRegex(ValueError, 'must be Boolean'):
            solve(self.domain, self.world, self.root / 'invalid', correlated_parameter_tuples=1)


if __name__ == '__main__':
    unittest.main()

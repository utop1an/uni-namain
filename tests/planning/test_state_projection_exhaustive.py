from itertools import product
from pathlib import Path
import tempfile
import unittest

from unified_planning.engines.compilers.grounder import GrounderHelper
from unified_planning.io import PDDLReader
from unified_planning.shortcuts import SequentialSimulator

from rcnc.state_grounding import PositiveStateGrounding, successor_atoms
from rcnc.inert_grounding import InertParameterGrounding, inert_parameters
from rcnc.correlated_grounding import parameters as joined_parameters
from rcnc.witness_grounding import binding_groups, effect_parameters


class StateProjectionExhaustiveTests(unittest.TestCase):
    def test_every_boolean_valuation_matches_cartesian_applicability_and_successor_truth(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            domain = root / 'domain.pddl'
            domain.write_text('''(define (domain projection) (:requirements :typing :adl)
              (:types item) (:constants a b - item)
              (:predicates (flag) (on ?x - item) (edge ?x ?y - item))
              (:action positive :parameters (?x ?y ?unused - item)
                :precondition (and (flag) (on ?x) (edge ?x ?y))
                :effect (and (not (on ?x)) (when (on ?y) (on ?unused))))
              (:action other :parameters (?x - item)
                :precondition (or (not (on ?x)) (edge ?x ?x))
                :effect (forall (?y - item) (when (edge ?x ?y) (on ?y))))
              (:action ground :parameters (?unused - item)
                :precondition (edge a a) :effect (not (flag))))''', encoding='utf-8')
            atoms = ['(flag)', '(on a)', '(on b)', '(edge a a)', '(edge a b)', '(edge b a)', '(edge b b)']
            comparisons = 0
            for index, bits in enumerate(product((False, True), repeat=len(atoms))):
                problem_path = root / 'problem.pddl'
                initial = ' '.join(atom for atom, bit in zip(atoms, bits) if bit)
                problem_path.write_text(f'(define (problem p) (:domain projection) (:init {initial}) (:goal (flag)))', encoding='utf-8')
                problem = PDDLReader().parse_problem(str(domain), str(problem_path))
                em = problem.environment.expression_manager
                positive = frozenset(atom for atom, value in problem.explicit_initial_values.items() if value.is_true())
                all_atoms = [problem.fluent('flag')()] + [problem.fluent('on')(obj) for obj in problem.all_objects]
                all_atoms += [problem.fluent('edge')(a, b) for a in problem.all_objects for b in problem.all_objects]
                grounder = GrounderHelper(problem, prune_actions=True)
                inert = {action: inert_parameters(problem, action) for action in problem.actions}
                with SequentialSimulator(problem) as simulator:
                    state = simulator.get_initial_state()
                    for action in problem.actions:
                        choices = [[em.ObjectExp(obj) for obj in problem.objects(p.type)] for p in action.parameters]
                        cartesian = {args for args in product(*choices) if simulator.is_applicable(state, action, args)}
                        projected = {args for args in PositiveStateGrounding(problem, positive).parameters(action)
                            if simulator.is_applicable(state, action, args)}
                        self.assertEqual(cartesian, projected, (index, action.name))
                        joined = list(joined_parameters(PositiveStateGrounding(problem, positive), action))
                        self.assertEqual(len(joined), len(set(joined)), (index, action.name))
                        joined_applicable = {args for args in joined if simulator.is_applicable(state, action, args)}
                        self.assertEqual(cartesian, joined_applicable, (index, action.name))
                        self.assertTrue(all(len(args) == len(action.parameters) for args in joined))
                        representatives = list(InertParameterGrounding(problem, positive, inert).parameters(action))
                        self.assertTrue(all(len(args) == len(action.parameters) for args in representatives))
                        complete_successors = {simulator.apply(state, action, args) for args in cartesian}
                        representative_successors = {simulator.apply(state, action, args) for args in representatives
                            if simulator.is_applicable(state, action, args)}
                        self.assertEqual(complete_successors, representative_successors, (index, action.name))
                        joined_representatives = joined_parameters(InertParameterGrounding(problem, positive, inert), action)
                        self.assertEqual(complete_successors,
                            {simulator.apply(state, action, args) for args in joined_representatives
                             if simulator.is_applicable(state, action, args)}, (index, action.name))
                        for correlated in (False, True):
                            witnesses = []
                            for group in binding_groups(PositiveStateGrounding(problem, positive), action,
                                    effect_parameters(problem, action), correlated=correlated):
                                chosen = next((args for args in group if simulator.is_applicable(state, action, args)), None)
                                if chosen is not None:
                                    self.assertEqual(len(action.parameters), len(chosen))
                                    witnesses.append(chosen)
                            self.assertEqual(complete_successors,
                                {simulator.apply(state, action, args) for args in witnesses}, (index, action.name, correlated))
                        for args in projected:
                            after = simulator.apply(state, action, args)
                            stats = {'expanded_effect_instances': 0}
                            actual = successor_atoms(problem, grounder.ground_action(action, args), after,
                                positive, grounder.simplifier, set(), 100, stats)
                            expected = frozenset(atom for atom in all_atoms if after.get_value(atom).is_true())
                            self.assertEqual(expected, actual, (index, action.name, args))
                            comparisons += 1
            self.assertGreater(comparisons, 100)


if __name__ == '__main__':
    unittest.main()

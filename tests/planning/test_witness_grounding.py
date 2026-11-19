from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest

from unified_planning.io import PDDLReader
from unified_planning.model.metrics import MinimizeSequentialPlanLength

from rcnc.state_projected_planning import solve
from rcnc.witness_grounding import binding_groups, effect_parameters
from rcnc.inert_grounding import InertParameterGrounding, inert_parameters
from rcnc.state_grounding import PositiveStateGrounding
from unified_planning.shortcuts import SequentialSimulator


DOMAIN = '''(define (domain witnesses) (:requirements :typing :adl)
    (:types item) (:constants a b - item)
    (:predicates (allowed ?x ?w - item) (blocked ?w - item) (done ?x - item) (enabled ?w - item) (never))
    (:action finish :parameters (?x ?w ?unused - item)
        :precondition (and (allowed ?x ?w) (not (blocked ?w))) :effect (done ?x))
    (:action toggle :parameters (?w - item) :precondition (blocked ?w) :effect (not (blocked ?w)))
    (:action conditional :parameters (?x ?w ?unused - item)
        :precondition (allowed ?x ?w) :effect (when (enabled ?w) (done ?x))))'''
PROBLEM = '''(define (problem q) (:domain witnesses)
    (:init (allowed a a) (allowed a b) (blocked a) (enabled b)) (:goal (done a)))'''


class WitnessGroundingTests(unittest.TestCase):
    def setUp(self):
        self.root = Path(self.enterContext(tempfile.TemporaryDirectory()))
        self.domain, self.world = self.root / 'domain.pddl', self.root / 'problem.pddl'
        self.domain.write_text(DOMAIN, encoding='utf-8'); self.world.write_text(PROBLEM, encoding='utf-8')

    def test_first_inapplicable_binding_cannot_prevent_later_complete_witness(self):
        for index, flags in enumerate(({}, {'correlated_parameter_tuples':True}, {'inert_parameter_representatives':True})):
            result = solve(self.domain, self.world, self.root / str(index),
                precondition_witness_representatives=True, **flags)
            self.assertEqual(('solved', 1, 'VALID'), (result['status'], result['length'], result['validation']['status']))
            line = (self.root / str(index) / 'plan.txt').read_text(encoding='utf-8').splitlines()[0]
            self.assertEqual('(finish a b a)', line.strip())
            self.assertEqual(2, result['precondition_only_parameter_counts']['finish'])
            self.assertGreaterEqual(result['public_applicability_checks'], 2)
        original = solve(self.domain, self.world, self.root / 'default')
        self.assertFalse(original['budget']['precondition_witness_representatives'])
        with self.assertRaisesRegex(ValueError, 'must be Boolean'):
            solve(self.domain, self.world, self.root / 'bad', precondition_witness_representatives=1)

    def test_effect_conditions_are_essential_and_metrics_or_external_effects_fall_back(self):
        problem = PDDLReader().parse_problem(str(self.domain), str(self.world))
        action = problem.action('conditional')
        self.assertEqual({'x','w'}, {p.name for p in effect_parameters(problem, action)})
        problem.add_quality_metric(MinimizeSequentialPlanLength())
        self.assertEqual(set(action.parameters), set(effect_parameters(problem, action)))
        external = SimpleNamespace(parameters=action.parameters, simulated_effect=object())
        self.assertEqual(set(action.parameters), set(effect_parameters(SimpleNamespace(quality_metrics=[]), external)))

    def test_metric_fallback_is_not_undone_by_inert_or_join_combination(self):
        problem = PDDLReader().parse_problem(str(self.domain), str(self.world))
        problem.add_quality_metric(MinimizeSequentialPlanLength())
        action = problem.action('finish')
        positive = frozenset(atom for atom,value in problem.explicit_initial_values.items() if value.is_true())
        inert = {item:inert_parameters(problem,item) for item in problem.actions}
        self.assertIn(action.parameter('unused'), inert[action])
        projection = InertParameterGrounding(problem,positive,inert)
        full = PositiveStateGrounding(problem,positive)
        # Any quality metric deliberately makes every parameter essential.
        # Another enabled optimization must not silently reverse that fallback.
        with SequentialSimulator(problem) as simulator:
            state = simulator.get_initial_state()
            expected = {args for args in full.parameters(action) if simulator.is_applicable(state,action,args)}
            self.assertEqual(2,len(expected))
            for correlated in (False,True):
                groups = binding_groups(projection,action,effect_parameters(problem,action),correlated=correlated)
                actual = {args for group in groups for args in group if simulator.is_applicable(state,action,args)}
                self.assertEqual(expected,actual)

    def test_conditional_effect_witnesses_cannot_fold_their_guard_parameter(self):
        # First applicable conditional binding has a false guard. Keeping only
        # its effect target would lose the later guarded transition.
        self.domain.write_text(DOMAIN.replace('(done ?x))\n    (:action toggle', '(never))\n    (:action toggle'), encoding='utf-8')
        result = solve(self.domain, self.world, self.root / 'conditional', precondition_witness_representatives=True)
        self.assertEqual(('solved','VALID'), (result['status'], result['validation']['status']))
        line = (self.root / 'conditional/plan.txt').read_text(encoding='utf-8').splitlines()[0]
        self.assertIn('conditional a b', line)

    def test_same_state_successors_and_no_effects_do_not_invent_unsolvability(self):
        domain = '''(define (domain idle) (:requirements :typing :strips) (:types item)
            (:constants a b - item) (:predicates (ready ?x - item) (done))
            (:action wait :parameters (?w - item) :precondition (ready ?w) :effect (and)))'''
        world = '(define (problem p) (:domain idle) (:init (ready a) (ready b)) (:goal (done)))'
        self.domain.write_text(domain, encoding='utf-8'); self.world.write_text(world, encoding='utf-8')
        result = solve(self.domain, self.world, self.root / 'idle', precondition_witness_representatives=True)
        self.assertEqual('unsolvable', result['status'])
        self.assertEqual(1, result['states'])
        self.assertEqual(1, result['witnesses_selected'])


if __name__ == '__main__':
    unittest.main()

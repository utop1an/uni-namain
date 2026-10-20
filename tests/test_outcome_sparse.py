import tempfile
from pathlib import Path
import unittest

from unified_planning.io import PDDLReader
from unified_planning.model.fluent import get_all_fluent_exp
from unified_planning.shortcuts import SequentialSimulator

from rcnc.outcome_planning import explore


class SparseOutcomeTests(unittest.TestCase):
    def test_sparse_changes_equal_full_enumeration_with_forall_deletion_and_foreign_facts(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            domain, problem = root/'domain.pddl', root/'problem.pddl'
            domain.write_text('''(define (domain t) (:requirements :adl :typing)
              (:types person - object) (:constants a b c - person)
              (:predicates (owned ?x - person) (ready ?x - person) (done ?x - person)
               (unused ?a ?b ?c ?d ?e ?f ?g - person))
              (:action advance :parameters (?p - person)
               :precondition (and (owned ?p) (ready ?p))
               :effect (and (not (ready ?p))
                 (forall (?q - person) (when (owned ?q) (done ?q))))))''')
            problem.write_text('''(define (problem p) (:domain t)
              (:init (owned a) (owned b) (ready a) (done c)) (:goal (and)))''')
            result = explore(domain, problem, root/'out', max_ground_fluents=4)
            self.assertEqual('outcomes_generated', result['status'])
            self.assertEqual(3, result['ground_fluents_tracked'])
            reader = PDDLReader()
            parsed = reader.parse_problem(str(domain), str(problem))
            for index, outcome in enumerate(result['outcomes']):
                plan = reader.parse_plan(parsed, str(root/'out'/f'outcome_{index:03d}'/'plan.txt'))
                with SequentialSimulator(parsed) as simulator:
                    initial = simulator.get_initial_state()
                    state = initial
                    for step in plan.actions:
                        state = simulator.apply(state, step.action, step.actual_parameters)
                    expected = {}
                    for fluent in parsed.fluents:
                        for fact in get_all_fluent_exp(parsed, fluent):
                            if state.get_value(fact) != initial.get_value(fact):
                                key = (fact.fluent().name, *[arg.object().name for arg in fact.args])
                                expected[key] = state.get_value(fact).bool_constant_value()
                    observed = {tuple(change['atom']): change['value'] for change in outcome['changes']}
                    self.assertEqual(expected, observed)
                    self.assertFalse(observed[('ready', 'a')])
                    self.assertNotIn(('done', 'c'), observed)
                    self.assertEqual('VALID', outcome['validation']['status'])

    def test_dynamic_guard_is_not_pruned_and_fluent_budget_is_hard(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            domain, problem = root/'domain.pddl', root/'problem.pddl'
            domain.write_text('''(define (domain t) (:requirements :adl)
              (:predicates (flag) (done))
              (:action fire :parameters () :effect (when (flag) (done)))
              (:action arm :parameters () :effect (flag)))''')
            problem.write_text('(define (problem p) (:domain t) (:init) (:goal (and)))')
            result = explore(domain, problem, root/'normal', max_ground_fluents=2)
            self.assertTrue(any({'atom': ['done'], 'value': True} in row['changes'] for row in result['outcomes']))
            limited = explore(domain, problem, root/'limited', max_ground_fluents=1)
            self.assertEqual('ground_fluent_limit', limited['stop_reason'])
            self.assertEqual(1, len(limited['outcomes']))
            self.assertEqual('VALID', limited['outcomes'][0]['validation']['status'])


if __name__ == '__main__':
    unittest.main()

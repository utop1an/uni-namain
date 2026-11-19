import tempfile
from pathlib import Path
import unittest

from scripts.audit.diagnose_source_support import diagnose


class SourceSupportTests(unittest.TestCase):
    def case(self, initial, goal, actions):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        root = Path(temp.name)
        domain = root/'T_domainfile.pddl'
        problem = root/'T_problemfile.pddl'
        domain.write_text('''(define (domain t) (:requirements :adl :typing)
            (:types person - object) (:predicates (p) (q) (r) (ready ?x - person)) '''+actions+')')
        problem.write_text('(define (problem t) (:domain t) (:init '+initial+') (:goal '+goal+'))')
        return diagnose(domain, problem)

    def test_unseeded_cycle_is_a_certificate_but_seed_removes_it(self):
        actions = '''(:action pq :parameters () :precondition (p) :effect (q))
                     (:action qp :parameters () :precondition (q) :effect (p))'''
        missing = self.case('', '(p)', actions)
        self.assertEqual('predicate_relaxation_proves_unreachable', missing['status'])
        self.assertEqual(['(p)'], missing['unreachable_goal_atoms'])
        self.assertEqual('not_proved_unreachable', self.case('(q)', '(p)', actions)['status'])

    def test_relaxation_never_requires_negative_or_universal_conditions(self):
        for condition in ('(not (p))', '(forall (?x - person) (ready ?x))'):
            actions = f'(:action a :parameters () :precondition {condition} :effect (q))'
            # In particular, universal truth over an empty type cannot require
            # a reachable ready instance. Dropping it avoids an unsound proof.
            self.assertEqual('not_proved_unreachable', self.case('', '(q)', actions)['status'])

    def test_disjunction_and_conditional_effects_are_overapproximated(self):
        actions = '(:action a :parameters () :precondition (or (p) (r)) :effect (when (p) (q)))'
        self.assertEqual('not_proved_unreachable', self.case('(r)', '(q)', actions)['status'])
        self.assertEqual('not_proved_unreachable', self.case('', '(or (p) (not (q)))', '')['status'])

    def test_unsupported_numeric_comparison_cannot_be_a_certificate(self):
        actions = '(:action a :parameters () :precondition (> 1 0) :effect (p))'
        with self.assertRaises(ValueError):
            self.case('', '(p)', actions)


if __name__ == '__main__':
    unittest.main()

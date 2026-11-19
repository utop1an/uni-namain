import importlib.util
from pathlib import Path
import tempfile
import unittest


@unittest.skipUnless(importlib.util.find_spec('up_pyperplan'), 'optional Pyperplan dependencies not installed')
class HeuristicPlanningTests(unittest.TestCase):
    def test_compiled_quantifiers_negation_and_conditionals_lift_to_valid_source_plan(self):
        from rcnc.heuristic_planning import solve
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            domain = root / 'domain.pddl'
            problem = root / 'problem.pddl'
            domain.write_text('''(define (domain compound)
              (:requirements :strips :typing :negative-preconditions :existential-preconditions :conditional-effects)
              (:types person - object) (:constants good bad - person)
              (:predicates (ready ?p - person) (done ?p - person))
              (:action finish :parameters (?p - person)
               :precondition (and (exists (?q - person) (ready ?q)) (not (done ?p)))
               :effect (when (ready ?p) (done ?p))))''')
            problem.write_text('''(define (problem p) (:domain compound)
              (:init (ready good)) (:goal (done good)))''')
            result = solve(domain, problem, root / 'out')
            self.assertEqual('solved', result['status'])
            self.assertEqual('VALID', result['validation']['status'])
            self.assertEqual(1, result['length'])
            self.assertIn('finish(good)', result['plan'])
            self.assertEqual(4, len(result['compilations']))


if __name__ == '__main__':
    unittest.main()

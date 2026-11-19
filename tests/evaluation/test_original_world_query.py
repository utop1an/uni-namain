from pathlib import Path
import tempfile
import unittest

from scripts.experiments.run_original_world_pipeline import convert_problem


class OriginalWorldQueryTests(unittest.TestCase):
    def fixture(self, root, text):
        domain = root / 'A_domainfile.pddl'
        problem = root / 'A_problemfile.pddl'
        domain.write_text('''(define (domain a) (:requirements :strips :typing)
            (:types person - object) (:constants King - person)
            (:predicates (ready ?p - person) (done ?p - person)))''', encoding='utf-8')
        problem.write_text(text, encoding='utf-8')
        return domain, problem

    def test_exact_facts_and_positive_negative_goals_with_explicit_objects(self):
        with tempfile.TemporaryDirectory() as td:
            domain, problem = self.fixture(Path(td), '''(define (problem p) (:domain a)
                (:objects Guest - person) (:init (ready King) (ready Guest))
                (:goal (and (done King) (not (done Guest)))))''')
            original = problem.read_bytes()
            query = convert_problem('A', domain, problem)
            self.assertEqual({'guest': 'A:person'}, query['objects'])
            self.assertEqual([['A:ready', 'A:King'], ['A:ready', 'guest']], query['initial'])
            self.assertEqual({'positive': [['A:done', 'A:King']], 'negative': [['A:done', 'guest']]}, query['goal'])
            self.assertEqual(original, problem.read_bytes())

    def test_missing_initial_and_unsupported_goal_or_initial_are_not_repaired(self):
        cases = ['(define (problem p) (:domain a) (:goal (done King)))',
                 '(define (problem p) (:domain a) (:init) (:goal (forall (?x - person) (done ?x))))',
                 '(define (problem p) (:domain a) (:init (not (ready King))) (:goal (done King)))']
        for text in cases:
            with self.subTest(text=text), tempfile.TemporaryDirectory() as td:
                domain, problem = self.fixture(Path(td), text)
                with self.assertRaises(ValueError):
                    convert_problem('A', domain, problem)

    def test_case_insensitive_object_constant_collision_is_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            domain, problem = self.fixture(Path(td), '''(define (problem p) (:domain a)
                (:objects king - person) (:init) (:goal (done king)))''')
            with self.assertRaisesRegex(ValueError, 'collide'):
                convert_problem('A', domain, problem)

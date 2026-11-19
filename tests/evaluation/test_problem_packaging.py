import unittest

from rcnc.pddl import parse_sexpr, section
from scripts.data.package_external_problem import package


class ProblemPackagingTests(unittest.TestCase):
    def test_only_headers_change(self):
        domain = parse_sexpr('(define (domain d) (:requirements :strips :typing) (:predicates (p ?x)))')
        problem = parse_sexpr('(define (problem p) (:requirements :strips) (:objects a) (:init (p a)) (:goal (not (p a))))')
        result, audit = package(domain, problem)
        self.assertTrue(audit['domain_header_added'])
        self.assertEqual(section(result, ':domain'), [':domain', 'd'])
        for key in (':objects', ':init', ':goal'):
            self.assertEqual(section(result, key), section(problem, key))
        self.assertEqual(package(domain, result)[0], result)

    def test_conflicts_and_undeclared_requirements_rejected(self):
        domain = parse_sexpr('(define (domain d) (:requirements :strips) (:predicates (p)))')
        for part in ('(:domain other)', '(:requirements :fluents)', '(:objects a a)'):
            with self.subTest(part=part), self.assertRaises(ValueError):
                package(domain, parse_sexpr('(define (problem p) '+part+' (:init) (:goal (p)))'))


if __name__ == '__main__':
    unittest.main()

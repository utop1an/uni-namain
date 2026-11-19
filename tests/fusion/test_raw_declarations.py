from pathlib import Path
import tempfile
import unittest

from rcnc.domain_union import build
from rcnc.domain_building import check_raw_declarations
from rcnc.pddl import parse_sexpr


class RawDeclarationTests(unittest.TestCase):
    def test_duplicate_actions_cannot_be_silently_overwritten(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            inputs = root/'inputs'
            inputs.mkdir()
            (inputs/'A_domainfile.pddl').write_text('(define (domain d) (:predicates (p) (q)) '
                '(:action a :parameters () :effect (p)) (:action a :parameters () :effect (q)))')
            with self.assertRaisesRegex(ValueError, 'duplicate action'):
                build(inputs, root/'compiled')
            self.assertFalse((root/'compiled/meta_domain.pddl').exists())

    def test_raw_duplicate_declarations_and_malformed_types(self):
        fragments = ['(:predicates (p) (p))', '(:predicates (P) (p))',
                     '(:types t t)', '(:constants c c - object)',
                     '(:objects c C - object)', '(:predicates (p ?x ?x))',
                     '(:init) (:init)', '(:types - object)',
                     '(:action a :parameters (?x ?x) :effect (and))',
                     '(:action a :parameters () :precondition (forall (?x ?x) (p ?x)))']
        for fragment in fragments:
            with self.subTest(fragment=fragment), self.assertRaises(ValueError):
                check_raw_declarations(parse_sexpr('(define (domain d) '+fragment+')'), 'fixture')

    def test_separate_scopes_and_shadowing_remain_legal(self):
        check_raw_declarations(parse_sexpr('(define (domain d) (:types t u - object) '
            '(:predicates (p ?x - t) (q ?x - t)) '
            '(:action a :parameters (?x - t) :precondition (forall (?x - t) (p ?x)) '
            ':effect (when (p ?x) (forall (?x - t) (q ?x)))))'), 'fixture')


if __name__ == '__main__':
    unittest.main()

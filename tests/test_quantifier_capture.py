import json
from pathlib import Path
import tempfile
import unittest

from rcnc.aligned_domain import build, freshen_quantifiers
from rcnc.domain_building import digest
from rcnc.pddl import parse_sexpr
from rcnc.validation import validate_artifacts
from scripts.experiments.run_union_regression import translate_plan


class QuantifierCaptureTests(unittest.TestCase):
    def test_parameter_shadowing_and_separate_quantifier_scopes_preserve_source_trace(self):
        cases=[('(?x - item)','(when (p ?x) (forall (?x - item) (q ?x)))','(spread a)'),
               ('()','(when (exists (?x - item) (p ?x)) (forall (?x - item) (q ?x)))','(spread)')]
        for parameters,effect,plan in cases:
            with self.subTest(effect=effect), tempfile.TemporaryDirectory() as temp:
                root=Path(temp);inputs=root/'inputs';inputs.mkdir()
                domain=f'''(define (domain shadow) (:requirements :adl :typing) (:types item)
                 (:constants a b - item) (:predicates (p ?x - item) (q ?x - item))
                 (:action spread :parameters {parameters} :precondition (and) :effect {effect}))'''
                problem='(define (problem p) (:domain shadow) (:init (p a)) (:goal (and (q a) (q b))))'
                (inputs/'A_domainfile.pddl').write_text(domain,encoding='utf-8')
                (inputs/'A_problemfile.pddl').write_text(problem,encoding='utf-8')
                original=root/'original';original.mkdir()
                (original/'domain.pddl').write_text(domain,encoding='utf-8')
                (original/'problem.pddl').write_text(problem,encoding='utf-8')
                (original/'plan.txt').write_text(plan+'\n',encoding='utf-8')
                original_validation=validate_artifacts(original)
                self.assertEqual('VALID',original_validation['status'],original_validation)
                spec={'version':1,'decision_basis':'authored_assumption','source_sha256':{'A_domainfile.pddl':digest(inputs/'A_domainfile.pddl')},'type_groups':[],'predicate_groups':[]}
                build(inputs,root/'compiled',spec)
                result=translate_plan('A',inputs,root/'compiled',original,root/'mapped')
                self.assertEqual('VALID',result['validation']['status'])

    def test_fresh_names_avoid_existing_names_and_respect_case_insensitive_binding(self):
        expression=parse_sexpr('(when (p ?x) (forall (?X - item) (and (q ?x) (r ?BOUND_SCOPE_0))))')
        renamed=freshen_quantifiers(expression,['?x','?BOUND_SCOPE_0'])
        self.assertEqual(['p','?x'],renamed[1])
        self.assertEqual('?bound_scope_1',renamed[2][1][0])
        self.assertEqual(['q','?bound_scope_1'],renamed[2][2][1])
        self.assertEqual(['r','?BOUND_SCOPE_0'],renamed[2][2][2])
        nested=freshen_quantifiers(parse_sexpr('(forall (?x - item) (when (p ?x) (forall (?x - item) (q ?x))))'))
        self.assertEqual(['p','?bound_scope_0'],nested[2][1])
        self.assertEqual(['q','?bound_scope_1'],nested[2][2][2])


if __name__=='__main__':
    unittest.main()

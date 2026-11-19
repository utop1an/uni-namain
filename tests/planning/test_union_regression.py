import json
from pathlib import Path
import tempfile
import unittest

from rcnc.domain_union import build
from scripts.audit.audit_union_preservation import audit
from scripts.experiments.run_union_regression import run, translate_plan
from rcnc.reference_planning import bounded_plan


class UnionRegressionTests(unittest.TestCase):
    def test_universal_object_scope_does_not_expand_to_other_sources(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs = root / 'inputs'
            inputs.mkdir()
            for source in ('A', 'B'):
                (inputs / f'{source}_domainfile.pddl').write_text(f'''(define (domain {source})
                  (:requirements :strips :typing :universal-preconditions)
                  (:constants actor - object)
                  (:predicates (ready ?p - object) (done))
                  (:action finish :parameters ()
                   :precondition (forall (?p - object) (ready ?p)) :effect (done)))''')
                (inputs / f'{source}_problemfile.pddl').write_text(f'''(define (problem p)
                  (:domain {source}) (:init (ready actor)) (:goal (done)))''')
            union = root / 'union'
            build(inputs, union)
            original = root / 'original'
            solved = bounded_plan(inputs / 'A_domainfile.pddl', inputs / 'A_problemfile.pddl', original)
            self.assertEqual('VALID', solved['validation']['status'])
            mapped = translate_plan('A', inputs, union, original, root / 'mapped')
            self.assertEqual('VALID', mapped['validation']['status'])

    def inputs(self, root):
        inputs = root / 'inputs'
        inputs.mkdir()
        for source, constant in [('A', 'King'), ('B', 'king')]:
            (inputs / f'{source}_domainfile.pddl').write_text(f'''(define (domain {source})
              (:requirements :strips :typing) (:types person - object)
              (:constants {constant} - person)
              (:predicates (ready ?p - person) (told ?p - person ?q - person))
              (:action tell :parameters (?p - person ?q - person)
               :precondition (ready ?p) :effect (told ?p ?q)))''')
            (inputs / f'{source}_problemfile.pddl').write_text(f'''(define (problem p)
              (:domain {source}) (:objects Friend - person)
              (:init (ready {constant})) (:goal (told {constant} Friend)))''')
        return inputs

    def test_validates_source_constants_and_problem_objects_in_order(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs = self.inputs(root)
            union = root / 'union'
            build(inputs, union)
            for source in ('A', 'B'):
                original = root / source / 'original'
                solved = bounded_plan(inputs / f'{source}_domainfile.pddl',
                                      inputs / f'{source}_problemfile.pddl', original)
                self.assertEqual('VALID', solved['validation']['status'])
                mapped = root / source / 'mapped'
                result = translate_plan(source, inputs, union, original, mapped)
                self.assertEqual('VALID', result['validation']['status'])
                self.assertEqual(1, result['length'])
                # A wrong relation direction must fail independently, not merely
                # pass because the translated plan has the right step count.
                plan = (original / 'plan.txt').read_text()
                (original / 'plan.txt').write_text(plan.replace('king friend', 'friend king'))
                invalid = translate_plan(source, inputs, union, original, root / source / 'wrong')
                self.assertEqual('INVALID', invalid['validation']['status'])

    def test_complete_report_keeps_denominator_and_refuses_overwrite(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs = self.inputs(root)
            (inputs / 'B_problemfile.pddl').unlink()
            result = run(inputs, root / 'out', seconds=30)
            self.assertEqual('complete', result['status'])
            self.assertEqual(2, result['source_count'])
            self.assertEqual({'solved': 1, 'missing_problem': 1}, result['search_counts'])
            self.assertTrue(result['merged_domain_unchanged'])
            self.assertEqual(1, result['preservation_counts']['validated_translated_plan'])
            self.assertEqual(result, json.loads((root / 'out/report.json').read_text()))
            with self.assertRaisesRegex(ValueError, 'empty'):
                run(inputs, root / 'out')

    def test_schema_audit_detects_wrong_effect_direction(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs = self.inputs(root)
            union = root / 'union'
            build(inputs, union)
            self.assertEqual('PASS', audit(inputs, union)['status'])
            domain = union / 'meta_domain.pddl'
            text = domain.read_text()
            self.assertIn('(d000__p_told ?p ?q)', text)
            domain.write_text(text.replace('(d000__p_told ?p ?q)', '(d000__p_told ?q ?p)'))
            report = audit(inputs, union)
            self.assertEqual('FAIL', report['status'])
            self.assertIn('Action expression changed: tell', report['rows'][0]['issues'])

    def test_schema_audit_accepts_grouped_parameter_declarations(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs = self.inputs(root)
            for path in inputs.glob('*_domainfile.pddl'):
                path.write_text(path.read_text().replace('?p - person ?q - person', '?p ?q - person'))
            build(inputs, root / 'union')
            self.assertEqual('PASS', audit(inputs, root / 'union')['status'])


if __name__ == '__main__':
    unittest.main()

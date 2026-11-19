import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from rcnc.pddl import is_type_compatible
from rcnc.validation import prepare_artifacts, write_validated_plan


class PackageBoundaryTests(unittest.TestCase):
    def test_current_pipeline_does_not_load_historical_modules(self):
        code = ('import json, sys; import rcnc.narrative_pipeline; '
                'print(json.dumps([m for m in sys.modules if m in '
                '("merge_domains", "build_narrative_union", "build_aligned_domain", '
                '"rcnc.domain_builder_cli", "pddl_checks", "rcnc.pipeline_cli") '
                'or m == "archive" or m.startswith("archive.")]))')
        result = subprocess.run([sys.executable, '-c', code], capture_output=True,
                                text=True, check=True)
        self.assertEqual([], json.loads(result.stdout))

    def test_type_compatibility_handles_subtypes_unknowns_and_cycles(self):
        types = {'hero': 'person', 'person': 'object', 'a': 'b', 'b': 'a'}
        for actual, expected in [('hero', 'hero'), ('hero', 'person'), ('hero', 'object'),
                                 ('unknown', 'unknown'), ('unknown', 'object'), ('a', 'b')]:
            with self.subTest(actual=actual, expected=expected):
                self.assertTrue(is_type_compatible(actual, expected, types))
        for actual, expected in [('person', 'hero'), ('unknown', 'hero'), ('a', 'person')]:
            with self.subTest(actual=actual, expected=expected):
                self.assertFalse(is_type_compatible(actual, expected, types))

    def test_shared_plan_export_still_rejects_an_invalid_plan(self):
        from unified_planning.io import PDDLReader
        from unified_planning.plans import SequentialPlan

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            domain, problem = root/'domain.pddl', root/'problem.pddl'
            domain.write_text('(define (domain d) (:requirements :strips) '
                              '(:predicates (done)) (:action finish :parameters () '
                              ':precondition (and) :effect (done)))', encoding='utf-8')
            problem.write_text('(define (problem p) (:domain d) (:init) (:goal (done)))',
                               encoding='utf-8')
            model = PDDLReader().parse_problem(str(domain), str(problem))
            output = prepare_artifacts(domain, problem, root/'artifacts')
            result = write_validated_plan(model, SequentialPlan([]), output)
            self.assertEqual('validation_failed', result['status'])
            self.assertEqual('INVALID', result['validation']['status'])
            self.assertEqual(domain.read_bytes(), (output/'domain.pddl').read_bytes())
            self.assertEqual(problem.read_bytes(), (output/'problem.pddl').read_bytes())


if __name__ == '__main__':
    unittest.main()

from pathlib import Path
import tempfile
import unittest

from rcnc.aligned_domain import build
from rcnc.domain_building import digest
from rcnc.narrative_pipeline import map_problem
from scripts.experiments.run_union_regression import translate_plan


class ExplicitPlanTransportTests(unittest.TestCase):
    def test_domain_only_artifact_accepts_explicit_problem_object_map_with_all_arguments(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs, domain_inputs = root / 'inputs', root / 'domain_inputs'
            inputs.mkdir()
            domain_inputs.mkdir()
            domain = '''(define (domain a) (:requirements :typing :strips) (:types item)
              (:constants fixed - item) (:predicates (ready ?x - item) (done ?x - item))
              (:action finish :parameters (?x ?unused - item) :precondition (ready ?x) :effect (done ?x)))'''
            for folder in (inputs, domain_inputs):
                (folder / 'A_domainfile.pddl').write_text(domain, encoding='utf-8')
            (inputs / 'A_problemfile.pddl').write_text('''(define (problem p) (:domain a)
              (:objects hero spare - item) (:init (ready hero)) (:goal (done hero)))''', encoding='utf-8')
            compiled = root / 'compiled'
            build(domain_inputs, compiled, {'version': 1, 'decision_basis': 'authored_assumption',
                'source_sha256': {'A_domainfile.pddl': digest(domain_inputs / 'A_domainfile.pddl')},
                'type_groups': [], 'predicate_groups': []})
            problem = root / 'mapped.pddl'
            query = {'objects': {'hero': 'A:item', 'spare': 'A:item'}, 'initial': [['A:ready', 'hero']],
                'goal': {'positive': [['A:done', 'hero']]}}
            mapping = map_problem(query, compiled, problem)
            original = root / 'original'
            original.mkdir()
            (original / 'plan.txt').write_text('(finish hero spare)\n', encoding='utf-8')
            before = digest(compiled / 'meta_domain.json')
            result = translate_plan('A', inputs, compiled, original, root / 'out',
                problem_path=problem, object_map=mapping['objects'])
            self.assertEqual('VALID', result['validation']['status'])
            self.assertIn('q__hero q__spare', (root / 'out/plan.txt').read_text(encoding='utf-8'))
            self.assertEqual(before, digest(compiled / 'meta_domain.json'))
            with self.assertRaisesRegex(ValueError, 'every declared'):
                translate_plan('A', inputs, compiled, original, root / 'incomplete',
                    problem_path=problem, object_map={'hero': 'q__hero'})


if __name__ == '__main__':
    unittest.main()

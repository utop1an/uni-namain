import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest

from rcnc.namespace_export import export_bundle
from scripts.experiments.run_fusion_reference import freeze
from unidomain.pipeline import run


DOMAIN = '''(define (domain collision) (:requirements :strips :typing)
    (:types location) (:constants actor - location)
    (:predicates (location ?x - location) (done ?x - location))
    (:action visit :parameters (?x - location) :precondition (location ?x)
        :effect (and (not (location ?x)) (done ?x))))'''
PROBLEM = '''(define (problem world) (:domain collision)
    (:init (location actor)) (:goal (done actor)))'''


def runtime():
    return SimpleNamespace(predicate_threshold=0.3, operator_threshold=0.3,
        embedding_model='fixture-no-embedding', llm=SimpleNamespace(model='fixture-no-model',
        network_calls=0, cache_hits=0, total_duration_seconds=0))


class FusionNamespacePolicyTests(unittest.TestCase):
    def test_collision_raw_failure_and_qualified_success_keep_raw_model_and_world(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); inputs = root / 'inputs'; inputs.mkdir()
            (inputs / 'A_domainfile.pddl').write_text(DOMAIN, encoding='utf-8')
            (inputs / 'A_problemfile.pddl').write_text(PROBLEM, encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'strict fusion validation failed'):
                run(inputs, root / 'raw', runtime=runtime(), num_workers=1)
            run(inputs, root / 'qualified', runtime=runtime(), num_workers=1,
                namespace_policy='category_qualified')
            for name in ('meta_domain.pddl', 'problems/A_problemfile.pddl'):
                self.assertEqual((root / 'raw' / name).read_bytes(), (root / 'qualified' / name).read_bytes())
            result = json.loads((root / 'qualified/validation.json').read_text(encoding='utf-8'))
            self.assertTrue(result['valid'])
            self.assertEqual('planning_export/domain.pddl', result['planning_domain'])
            self.assertEqual(['domain_only', 'A_problemfile.pddl'], [r['id'] for r in result['strict_parse_rows']])
            self.assertTrue(result['namespace_export']['all_roundtrips_equal'])
            self.assertEqual(0, result['llm_network_calls'])

    def test_domain_only_is_independently_parsed_and_unknown_policy_rejected_before_output(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); inputs = root / 'inputs'; inputs.mkdir()
            (inputs / 'A_domainfile.pddl').write_text(DOMAIN, encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'strict fusion validation failed'):
                run(inputs, root / 'raw', runtime=runtime(), num_workers=1)
            result = json.loads((root / 'raw/validation.json').read_text(encoding='utf-8'))
            self.assertEqual(0, result['problem_files'])
            self.assertEqual('ERROR', result['strict_parse_rows'][0]['status'])
            run(inputs, root / 'qualified', runtime=runtime(), num_workers=1,
                namespace_policy='category_qualified')
            with self.assertRaisesRegex(ValueError, 'Unknown namespace'):
                run(inputs, root / 'invalid', runtime=runtime(), num_workers=1, namespace_policy='relaxed')
            self.assertFalse((root / 'invalid').exists())

    def test_fresh_manifest_freezes_policy_and_export_dependency_and_no_overwrite(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); inputs = root / 'inputs'; inputs.mkdir()
            domain = inputs / 'A_domainfile.pddl'; domain.write_text(DOMAIN, encoding='utf-8')
            manifest = freeze(inputs, root / 'run', 10, 1, 'gemma3:4b', 'category_qualified')
            self.assertEqual('category_qualified', manifest['namespace_policy'])
            self.assertIn('rcnc/namespace_export.py', manifest['implementation_sha256'])
            export_bundle(domain, [], root / 'export')
            with self.assertRaisesRegex(ValueError, 'fresh empty'):
                export_bundle(domain, [], root / 'export')


if __name__ == '__main__':
    unittest.main()

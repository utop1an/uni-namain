import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

from rcnc.domain_building import check_exported_problem


ROOT = Path(__file__).resolve().parents[1]


class DomainBuildingTests(unittest.TestCase):
    def test_parse_failures_keep_union_and_alignment_policies_separate(self):
        domain, problem = Path('domain.pddl'), Path('problem.pddl')
        with patch('rcnc.domain_building.PDDLReader') as reader:
            reader.return_value.parse_problem.side_effect = ValueError('fixed parse failure')
            row = check_exported_problem(domain, problem, capture_errors=True)
            self.assertEqual({'problem': 'problem.pddl', 'status': 'ERROR',
                              'error': 'fixed parse failure'}, row)
            with self.assertRaisesRegex(ValueError, 'fixed parse failure'):
                check_exported_problem(domain, problem)

    def test_both_root_commands_build_from_explicit_inputs(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs = root/'inputs'
            inputs.mkdir()
            source = inputs/'A_domainfile.pddl'
            source.write_text('''(define (domain a) (:requirements :strips)
              (:predicates (done)) (:action finish :parameters ()
               :precondition (and) :effect (done)))''', encoding='utf-8')
            (inputs/'A_problemfile.pddl').write_text('''(define (problem p)
              (:domain a) (:init) (:goal (done)))''', encoding='utf-8')
            specification = root/'alignment.json'
            specification.write_text(json.dumps({'version': 1,
                'decision_basis': 'authored_assumption', 'type_groups': [],
                'predicate_groups': [], 'source_sha256': {
                    source.name: hashlib.sha256(source.read_bytes()).hexdigest()}}), encoding='utf-8')
            for script, extra in [('build_narrative_union.py', []),
                                  ('build_aligned_domain.py', ['--alignment', str(specification)])]:
                with self.subTest(script=script):
                    output = root/Path(script).stem
                    result = subprocess.run([sys.executable, str(ROOT/script), '--input',
                        str(inputs), '--output', str(output), *extra], cwd=ROOT,
                        capture_output=True, text=True, check=True)
                    self.assertTrue(json.loads(result.stdout)['valid'])
                    self.assertTrue((output/'meta_domain.pddl').exists())
                    info = json.loads((output/'meta_domain.json').read_text(encoding='utf-8'))
                    self.assertIn('domain_building.py', info['implementation_sha256'])


if __name__ == '__main__':
    unittest.main()

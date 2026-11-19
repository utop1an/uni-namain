import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

from rcnc.domain_building import check_exported_problem, snapshot_implementation, archived_implementation, planning_domain_path


ROOT = Path(__file__).resolve().parents[2]


class DomainBuildingTests(unittest.TestCase):
    def domain_only_fixture(self, root):
        inputs=root/'inputs';inputs.mkdir()
        source=inputs/'A_domainfile.pddl'
        source.write_text('''(define (domain a) (:requirements :strips) (:predicates (done))
            (:action finish :parameters () :precondition (and) :effect (done)))''',encoding='utf-8')
        specification={'version':1,'decision_basis':'authored_assumption','predicate_groups':[], 'type_groups':[],
            'source_sha256':{source.name:hashlib.sha256(source.read_bytes()).hexdigest()}}
        return inputs,specification

    def test_domain_only_union_cannot_pass_on_an_empty_problem_list_when_parser_fails(self):
        from rcnc.domain_union import build
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);inputs,_=self.domain_only_fixture(root)
            with patch('rcnc.domain_building.PDDLReader') as reader:
                reader.return_value.parse_problem.side_effect=ValueError('domain-only sentinel')
                result=build(inputs,root/'out')
            self.assertFalse(result['valid'])
            self.assertEqual([],result['problems'])
            self.assertEqual('ERROR',result['domain_parse']['status'])
            self.assertEqual(1,reader.return_value.parse_problem.call_count)

    def test_alignment_checks_the_transformed_domain_after_the_union_check(self):
        from rcnc.aligned_domain import build
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);inputs,specification=self.domain_only_fixture(root)
            with patch('rcnc.domain_building.PDDLReader') as reader:
                reader.return_value.parse_problem.side_effect=[None,ValueError('compiled-domain sentinel')]
                with self.assertRaisesRegex(ValueError,'compiled-domain sentinel'):
                    build(inputs,root/'out',specification)
            self.assertEqual(2,reader.return_value.parse_problem.call_count)
            self.assertFalse((root/'out/validation.json').exists())

    def test_domain_only_alignment_rejects_repeated_effects_before_dictionary_rewrite(self):
        from rcnc.aligned_domain import build
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs = root / 'inputs'; inputs.mkdir()
            (inputs / 'A_domainfile.pddl').write_text('''(define (domain ambiguous)
                (:requirements :strips) (:predicates (p) (q))
                (:action change :parameters () :precondition (and) :effect (p) :effect (q)))''', encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'duplicate fields'):
                build(inputs, root / 'out', {'version': 1, 'decision_basis': 'authored_assumption',
                    'predicate_groups': [], 'type_groups': []})
            self.assertFalse((root / 'out/meta_domain.pddl').exists())

    def test_declared_planning_domain_and_historical_fallback_stay_in_run(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            self.assertEqual(root / 'union/meta_domain.pddl', planning_domain_path(root, {}))
            self.assertEqual(root / 'selected_domain.pddl', planning_domain_path(root, {'planning_domain': 'selected_domain.pddl'}))
            for path in ('../outside.pddl', str(root.resolve() / 'absolute.pddl'), '', None):
                with self.assertRaises(ValueError):
                    planning_domain_path(root, {'planning_domain': path})

    def test_absolute_script_is_copied_under_archive_and_source_is_untouched(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            repo = root / 'repo'
            source = repo / 'scripts/run.py'
            source.parent.mkdir(parents=True)
            source.write_bytes(b'original-script\n')
            output = root / 'frozen'
            hashes = snapshot_implementation(output, [source.resolve()], root=repo)
            self.assertEqual({'scripts/run.py': hashlib.sha256(b'original-script\n').hexdigest()}, hashes)
            archived = output / 'implementation/scripts/run.py'
            self.assertEqual(source.read_bytes(), archived.read_bytes())
            source.write_bytes(b'later-version\n')
            self.assertEqual(archived, archived_implementation(output, str(source.resolve()), root=repo))
            self.assertEqual(b'original-script\n', archived.read_bytes())
            with self.assertRaisesRegex(ValueError, 'overwrite'):
                snapshot_implementation(output, [source], root=repo)

    def test_snapshot_rejects_outside_source_before_writing_and_preserves_postrun_copy(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            repo = root / 'repo'
            repo.mkdir()
            source, outside = repo / 'a.py', root / 'outside.py'
            source.write_bytes(b'a')
            outside.write_bytes(b'b')
            output = root / 'frozen'
            with self.assertRaisesRegex(ValueError, 'outside'):
                snapshot_implementation(output, [source, outside], root=repo)
            self.assertFalse(output.exists())
            postrun = output / 'postrun_implementation_snapshot/a.py'
            postrun.parent.mkdir(parents=True)
            postrun.write_bytes(b'recovered-original')
            self.assertEqual(postrun, archived_implementation(output, str(source), root=repo))
            with self.assertRaisesRegex(ValueError, 'inside'):
                archived_implementation(output, '../outside.py', root=repo)
            with self.assertRaisesRegex(ValueError, 'Missing archived'):
                archived_implementation(root / 'missing_archive', str(source), root=repo)

    def test_parse_failures_keep_union_and_alignment_policies_separate(self):
        domain, problem = Path('domain.pddl'), Path('problem.pddl')
        with patch('rcnc.domain_building.PDDLReader') as reader:
            reader.return_value.parse_problem.side_effect = ValueError('fixed parse failure')
            row = check_exported_problem(domain, problem, capture_errors=True)
            self.assertEqual({'problem': 'problem.pddl', 'status': 'ERROR',
                              'error': 'fixed parse failure'}, row)
            with self.assertRaisesRegex(ValueError, 'fixed parse failure'):
                check_exported_problem(domain, problem)

    def test_both_package_commands_build_from_explicit_inputs(self):
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
            for command, extra in [('build-union', []),
                                   ('build-aligned', ['--alignment', str(specification)])]:
                with self.subTest(command=command):
                    output = root/command
                    result = subprocess.run([sys.executable, '-m', 'rcnc', command, '--input',
                        str(inputs), '--output', str(output), *extra], cwd=ROOT,
                        capture_output=True, text=True, check=True)
                    self.assertTrue(json.loads(result.stdout)['valid'])
                    self.assertTrue((output/'meta_domain.pddl').exists())
                    info = json.loads((output/'meta_domain.json').read_text(encoding='utf-8'))
                    self.assertIn('domain_building.py', info['implementation_sha256'])
                    self.assertEqual(hashlib.sha256((output/'meta_domain.pddl').read_bytes()).hexdigest(),
                                     info['compiled_domain_sha256'])
                    self.assertEqual('pre_search_compiler_export', info['domain_artifact_stage'])


if __name__ == '__main__':
    unittest.main()

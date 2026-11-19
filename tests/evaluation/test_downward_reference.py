import tempfile
import json
from pathlib import Path
import unittest
from unittest.mock import patch

from scripts.experiments.run_downward_reference import exit_status, freeze, linux_path, sha, plan_status
from rcnc.validation import validate_artifacts


class DownwardReferenceTests(unittest.TestCase):
    def test_actual_parser_failure_is_distinct_from_a_definitely_invalid_empty_plan(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            model = '''(define (domain check) (:requirements :strips :typing)
                (:types entity) (:constants actor - entity)
                (:predicates (ready ?x - entity) (done))
                (:action finish :parameters () :precondition (ready actor) :effect (done)))'''
            (root / 'domain.pddl').write_text(model, encoding='utf-8')
            (root / 'problem.pddl').write_text('''(define (problem case) (:domain check)
                (:init (ready actor)) (:goal (done)))''', encoding='utf-8')
            (root / 'plan.txt').write_text('(finish)\n', encoding='utf-8')
            self.assertEqual('solved', plan_status(validate_artifacts(root)))
            (root / 'plan.txt').write_text('; empty candidate\n', encoding='utf-8')
            self.assertEqual('invalid_plan', plan_status(validate_artifacts(root)))
            (root / 'domain.pddl').write_text(model.replace('(ready', '(entity'), encoding='utf-8')
            self.assertEqual('validation_error', plan_status(validate_artifacts(root)))

    def test_validator_error_and_unknown_do_not_establish_plan_invalidity(self):
        self.assertEqual('solved', plan_status({'status': 'VALID'}))
        self.assertEqual('invalid_plan', plan_status({'status': 'INVALID'}))
        for verdict, expected in (('ERROR', 'validation_error'),
                                  ('UNAVAILABLE', 'validation_unavailable'),
                                  ('UNKNOWN', 'validation_unknown'),
                                  ('future_engine_verdict', 'validation_unknown')):
            self.assertEqual(expected, plan_status({'status': verdict}))
        self.assertEqual('validation_unknown', plan_status({}))

    def test_incomplete_bounds_and_limits_are_not_unqualified_unsolvable(self):
        self.assertEqual('unsolvable', exit_status(10))
        self.assertEqual('unsolvable', exit_status(11))
        self.assertEqual('incomplete', exit_status(12))
        self.assertEqual('unsolvable_within_bound', exit_status(13))
        for code in (20, 21, 22, 23, 24, 124, 137):
            self.assertNotEqual('unsolvable', exit_status(code))
        self.assertEqual('plan_found_time_limit', exit_status(2))
        self.assertEqual('unsupported', exit_status(34))

    def test_missing_binary_never_starts_or_labels_a_run(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            with self.assertRaisesRegex(ValueError, 'not built'):
                freeze(root/'input', None, root/'out', root/'planner', 60, 4096)
            self.assertFalse((root/'out').exists())

    def test_composed_freeze_uses_declared_selected_artifact_and_rejects_escape(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            planner = root / 'planner'
            for name, content in [('builds/release/bin/downward', 'fixture'),
                                  ('driver/version.py', "__version__ = '26.6'"),
                                  ('driver/aliases.py', ''), ('driver/returncodes.py', '')]:
                path = planner / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content, encoding='utf-8')
            composed = root / 'composed'
            run = composed / 'runs/case'
            run.mkdir(parents=True)
            (run / 'selected_domain.pddl').write_text('selected-artifact', encoding='utf-8')
            (run / 'problem.pddl').write_text('unused', encoding='utf-8')
            (run / 'mapped_problem.pddl').write_text('explicit-world', encoding='utf-8')
            task = {'id': 'case', 'world': 'explicit', 'method': 'alignment', 'policy': 'static_universe_components'}
            (composed / 'frozen_tasks.json').write_text(json.dumps({'tasks': [task]}), encoding='utf-8')
            (composed / 'report.json').write_text(json.dumps({'status': 'complete',
                'frozen_tasks_sha256': sha(composed / 'frozen_tasks.json')}), encoding='utf-8')
            manifest = {'planning_domain': 'selected_domain.pddl',
                'domain_sha256': sha(run / 'selected_domain.pddl'),
                'problem_sha256': sha(run / 'mapped_problem.pddl')}
            (run / 'manifest.json').write_text(json.dumps(manifest), encoding='utf-8')
            frozen = freeze(root / 'unused', composed, root / 'out', planner, 20, 4096)
            self.assertEqual(manifest['domain_sha256'], frozen['tasks'][0]['domain_sha256'])
            self.assertEqual(b'selected-artifact', (root / 'out/tasks/case/domain.pddl').read_bytes())
            for filename, expected in frozen['implementation_sha256'].items():
                self.assertFalse(Path(filename).is_absolute())
                self.assertEqual(expected, sha(root / 'out/implementation' / filename))
            self.assertIn('rcnc/domain_building.py', frozen['implementation_sha256'])
            manifest['planning_domain'] = '../outside.pddl'
            (run / 'manifest.json').write_text(json.dumps(manifest), encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'inside'):
                freeze(root / 'unused', composed, root / 'escape', planner, 20, 4096)

    @unittest.skipUnless(Path.cwd().drive, 'Windows-to-WSL path contract')
    def test_windows_paths_preserve_spaces_as_a_single_argument(self):
        self.assertEqual('/mnt/c/a path/domain.pddl', linux_path(Path('C:/a path/domain.pddl')))


if __name__ == '__main__':
    unittest.main()

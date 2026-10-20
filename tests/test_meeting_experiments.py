import hashlib
import json
from pathlib import Path
import tempfile
import unittest

from scripts.evidence.build_meeting_results import build as summarize
from scripts.evidence.build_meeting_results import phase
from scripts.experiments.prepare_meeting_selection import closure, prepare
from scripts.experiments.run_downward_reference import freeze as freeze_solver
from scripts.experiments.run_meeting_comparison import freeze
from scripts.experiments.replay_meeting_original_goals import run as replay_original_goals


class MeetingExperimentTests(unittest.TestCase):
    def test_complete_representation_matrix_freezes_before_solver_and_selection_keeps_original_world(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs = root / 'inputs'
            inputs.mkdir()
            domain = inputs / 'A_domainfile.pddl'
            domain.write_text('(define (domain a) (:requirements :strips) (:predicates (done)) '
                              '(:action finish :parameters () :precondition (and) :effect (done)))', encoding='utf-8')
            (inputs / 'A_problemfile.pddl').write_text(
                '(define (problem p) (:domain a) (:init) (:goal (done)))', encoding='utf-8')
            spec = root / 'alignment.json'
            spec.write_text(json.dumps({'version': 1, 'decision_basis': 'machine_hypothesis',
                'source_sha256': {domain.name: hashlib.sha256(domain.read_bytes()).hexdigest()},
                'type_groups': [], 'predicate_groups': []}), encoding='utf-8')
            manifest = freeze(inputs, spec, root / 'matched')
            self.assertEqual('frozen_before_search', manifest['status'])
            self.assertEqual(4, manifest['task_count'])
            self.assertFalse((root / 'matched/solver').exists())
            planner = root / 'planner'
            for name, contents in [('builds/release/bin/downward', 'synthetic binary'),
                ('driver/version.py', "__version__ = '26.6'"), ('driver/returncodes.py', '# fixture'),
                ('driver/aliases.py', '# fixture')]:
                path = planner / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(contents, encoding='utf-8')
            solver = freeze_solver(inputs, None, root / 'solver_freeze', planner, 20, 4096,
                                   task_bundle=root / 'matched/bundle')
            self.assertEqual({'A'}, {t['source'] for t in solver['tasks']})
            self.assertEqual(set(manifest['representations']), {t['representation'] for t in solver['tasks']})
            selected = prepare(root / 'matched', root / 'selected')
            self.assertEqual(1, selected['task_count'])
            self.assertEqual(['A'], selected['tasks'][0]['selected_sources'])
            self.assertIn('Exploratory', selected['scope'])
            original = root / 'matched/solver/tasks/A__source_isolated'
            original.mkdir(parents=True)
            (original / 'domain.pddl').write_bytes(domain.read_bytes())
            (original / 'problem.pddl').write_bytes((inputs / 'A_problemfile.pddl').read_bytes())
            (original / 'plan.txt').write_text('(finish)\n', encoding='utf-8')
            (root / 'matched/report.json').write_text(json.dumps({'status': 'complete',
                'matched_protocol_unchanged': True,
                'rows': [{'id': task['id'], 'status': 'solved' if task['representation'] == 'source_isolated'
                          else 'wall_time_limit'} for task in manifest['tasks']]}), encoding='utf-8')
            replay = replay_original_goals(root / 'matched', root / 'original_replay')
            self.assertEqual(1, replay['original_goal_plans'])
            self.assertEqual(1, replay['valid_translations'])
            self.assertEqual(0, replay['mismatch_count'])
            self.assertTrue(replay['hashes_unchanged'])

    def test_source_interface_closure_is_transitive_and_does_not_add_unconnected_sources(self):
        specification = {'predicate_groups': [
            {'members': [{'predicate': 'A:p'}, {'predicate': 'B:q'}]},
            {'members': [{'predicate': 'B:r'}, {'predicate': 'C:s'}]},
            {'members': [{'predicate': 'D:p'}, {'predicate': 'E:q'}]}]}
        self.assertEqual(['A', 'B', 'C'], closure('A', specification))
        self.assertEqual(['Z'], closure('Z', specification))

    def test_running_experiment_cannot_be_published_as_complete_meeting_results(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            for name, value in [('matched/report.json', {'status': 'running'}),
                                ('matched/solver/manifest.json', {}), ('matched/bundle/manifest.json', {}),
                                ('replay/report.json', {}), ('historical/results.json', {})]:
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(json.dumps(value), encoding='utf-8')
            with self.assertRaises(ValueError):
                summarize(root / 'matched', root / 'replay', root / 'historical', root / 'output')
            self.assertFalse((root / 'output/results.json').exists())

    def test_logged_phase_recognizes_release_search_and_translation_cutoffs(self):
        with tempfile.TemporaryDirectory() as td:
            directory = Path(td)
            log = directory / 'planner.log'
            log.write_text('INFO Running translator.\nINFO Running search (release).', encoding='utf-8')
            self.assertEqual('search', phase(directory))
            log.write_text('INFO Running translator.\nTranslating task...', encoding='utf-8')
            self.assertEqual('translation', phase(directory))

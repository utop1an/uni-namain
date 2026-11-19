import json
from pathlib import Path
import tempfile
import unittest

from scripts.experiments.evaluate_cached_root_worlds import prepare, renamed_world, execute
from scripts.experiments.run_downward_reference import sha
from unittest.mock import patch
from rcnc.pddl import parse_sexpr, section


class CachedRootEvaluationTests(unittest.TestCase):
    def test_world_renaming_rejects_within_source_predicate_and_object_collisions(self):
        source=parse_sexpr('(define (problem w) (:domain old) (:init (p c)) (:goal (q d)))')
        for predicates,constants in (({'p':'r','q':'r'},{'c':'c','d':'d'}),
                                    ({'p':'p','q':'q'},{'c':'x','d':'x'}),
                                    ({'p':'R','q':'r'},{'c':'c','d':'d'})):
            with self.subTest(predicates=predicates,constants=constants):
                with self.assertRaisesRegex(ValueError,'Non-injective'):
                    renamed_world(source,'target',predicates,constants)

    def test_completed_fixture_freezes_exact_world_and_late_budget_runs_no_subset(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); parent = root / 'parent'; inputs = parent / 'inputs'
            inputs.mkdir(parents=True)
            source = inputs / 'A_domainfile.pddl'
            source.write_text('''(define (domain old) (:requirements :strips :typing)
                (:types item) (:constants c - item) (:predicates (p ?x - item))
                (:action finish :parameters (?x - item) :precondition (and) :effect (p ?x)))''', encoding='utf-8')
            problem = inputs / 'A_problemfile.pddl'
            problem.write_text('(define (problem world) (:domain old) (:init) (:goal (p c)))', encoding='utf-8')
            model = parent / 'fusion'; (model / 'problems').mkdir(parents=True)
            (model / 'meta_domain.pddl').write_text(source.read_text(encoding='utf-8').replace('(domain old)', '(domain target)').replace(' c ', ' m ').replace('(p ', '(r '), encoding='utf-8')
            (model / 'meta_domain.json').write_text(json.dumps({'sources': ['A'],
                'predicate_maps': {'A': {'p': 'r'}}, 'constant_maps': {'A': {'c': 'm'}}}), encoding='utf-8')
            (model / 'problems/A_problemfile.pddl').write_text('(define (problem world) (:domain target) (:init) (:goal (r m)))', encoding='utf-8')
            validation = {'valid': True}
            (model / 'validation.json').write_text(json.dumps(validation), encoding='utf-8')
            hashes = {p.name: sha(p) for p in inputs.iterdir()}
            (parent / 'manifest.json').write_text(json.dumps({'status': 'complete', 'source_sha256': hashes}), encoding='utf-8')
            (parent / 'report.json').write_text(json.dumps({'status': 'complete', 'validation': validation,
                **{k: True for k in ('source_snapshot_unchanged', 'implementation_unchanged', 'imported_cache_unchanged',
                                    'predecessor_cache_unchanged', 'predecessor_report_unchanged')}}), encoding='utf-8')
            protocol = root / 'protocol.json'
            protocol.write_text(json.dumps({'parent': str(parent), 'source_sha256': hashes, 'source_count': 1,
                'budget': {'seconds_wall_and_cpu': 20, 'memory_mb': 4096, 'supervisor_grace_seconds_each': 45},
                'deadline': '2000-01-01T00:00:00Z', 'comparison_boundary': 'authored admission fixture'}), encoding='utf-8')
            output = root / 'out'; manifest = prepare(protocol, output)
            self.assertEqual('ready', manifest['slots'][0]['admission_status'])
            self.assertEqual((model / 'problems/A_problemfile.pddl').read_bytes(), (output / 'bundle/tasks/A/problem.pddl').read_bytes())
            with patch('scripts.experiments.evaluate_cached_root_worlds.run_solver') as solver:
                result = execute(output)
            solver.assert_not_called()
            self.assertEqual(0, result['actual_solver_calls'])
            self.assertEqual({'not_run_due_goal_budget': 1}, result['status_counts'])

    def test_active_parent_cannot_prepare_a_comparison_or_write_partial_outputs(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); parent = root / 'parent'; parent.mkdir()
            (parent / 'manifest.json').write_text(json.dumps({'status': 'running'}), encoding='utf-8')
            (parent / 'report.json').write_text(json.dumps({'status': 'starting'}), encoding='utf-8')
            protocol = root / 'protocol.json'
            protocol.write_text(json.dumps({'parent': str(parent)}), encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'intact completed'):
                prepare(protocol, root / 'out')
            self.assertFalse((root / 'out').exists())

    def test_world_check_changes_only_recorded_term_and_predicate_positions(self):
        source = parse_sexpr('''(define (problem p) (:domain old) (:objects extra - entity)
            (:init (p p) (not (absent extra))) (:goal (and (p p) (not (absent extra)))))''')
        result = renamed_world(source, 'new', {'p': 'q', 'absent': 'missing'}, {'p': 'c'})
        self.assertEqual(['problem', 'p'], result[1])
        self.assertEqual(section(source, ':objects'), section(result, ':objects'))
        self.assertEqual([':init', ['q', 'c'], ['not', ['missing', 'extra']]], section(result, ':init'))
        self.assertEqual([':domain', 'old'], section(source, ':domain'))
        no_initial = [part for part in source if not isinstance(part, list) or not part or part[0] != ':init']
        with self.assertRaisesRegex(ValueError, 'initial state'):
            renamed_world(no_initial, 'new', {}, {})


if __name__ == '__main__':
    unittest.main()

import copy
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

from rcnc.narrative_pipeline import run


class NarrativePipelineTests(unittest.TestCase):
    def test_state_projected_goal_backend_retains_explicit_world_and_tracking_budget(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs = self.inputs(root)
            query = {**self.query(), 'solver': 'state_projected', 'max_ground_fluents': 100,
                     'inert_parameter_representatives': True, 'correlated_parameter_tuples': True,
                     'precondition_witness_representatives':True}
            result = run(query, inputs, root / 'out')
            self.assertEqual('solved', result['status'])
            self.assertEqual('VALID', result['search']['validation']['status'])
            self.assertTrue(result['domain_unchanged'])
            self.assertEqual(100, result['search']['budget']['max_ground_fluents'])
            self.assertTrue(result['search']['budget']['inert_parameter_representatives'])
            self.assertTrue(result['search']['budget']['correlated_parameter_tuples'])
            self.assertTrue(result['search']['budget']['precondition_witness_representatives'])
            self.assertFalse(json.loads((root / 'out/query_mapping.json').read_text())['source_problem_facts_imported'])

    def inputs(self, root):
        inputs = root / 'inputs'
        inputs.mkdir()
        for source in ('A', 'B'):
            (inputs / f'{source}_domainfile.pddl').write_text(f'''(define (domain {source})
              (:requirements :strips :typing) (:types person - object)
              (:constants actor - person)
              (:predicates (ready ?p - person) (done ?p - person))
              (:action finish :parameters (?p - person) :precondition (ready ?p)
               :effect (and (done ?p) (not (ready ?p)))))''')
            (inputs / f'{source}_problemfile.pddl').write_text(f'''(define (problem p)
              (:domain {source}) (:init (ready actor)) (:goal (done actor)))''')
        return inputs

    def query(self):
        return {'objects': {'hero': 'A:person'}, 'initial': [['A:ready', 'hero']],
                'goal': {'positive': [['A:done', 'hero']], 'negative': [['A:ready', 'hero']]},
                'seconds': 30}

    def test_domain_and_manifest_exist_before_search_and_plan_validates(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs = self.inputs(root)
            real_run = subprocess.run
            output = root / 'out'
            def checked_run(*args, **kwargs):
                self.assertTrue((output / 'union/meta_domain.pddl').exists())
                manifest = json.loads((output / 'manifest.json').read_text())
                self.assertTrue(manifest['merged_before_planning'])
                for relative in ['rcnc/pipeline_cli.py', 'rcnc/planning_worker.py', 'rcnc/pddl_checks.py']:
                    expected = hashlib.sha256((Path(__file__).resolve().parents[2]/relative).read_bytes()).hexdigest()
                    self.assertEqual(expected, manifest['implementation_sha256'][relative])
                return real_run(*args, **kwargs)
            with patch('rcnc.narrative_pipeline.subprocess.run', side_effect=checked_run):
                result = run(self.query(), inputs, output)
            self.assertEqual('solved', result['status'])
            self.assertEqual('VALID', result['search']['validation']['status'])
            self.assertTrue(result['domain_unchanged'])
            self.assertEqual(['A', 'B'], result['selection']['selected'])
            mapped = json.loads((output / 'query_mapping.json').read_text())
            self.assertFalse(mapped['source_problem_facts_imported'])
            self.assertEqual([['d000__p_ready', 'q__hero']], mapped['initial'])

    def test_goal_only_never_builds_or_plans(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            query = self.query()
            del query['initial']
            with patch('rcnc.narrative_pipeline.build', side_effect=AssertionError('must not build')):
                result = run(query, root / 'absent', root / 'out')
            self.assertEqual('needs_initial_state', result['status'])
            self.assertFalse(result['planner_called'])

    def test_explicit_empty_initial_does_not_import_source_world(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs = self.inputs(root)
            result = run({'initial': [], 'goal': {'positive': [['A:done', 'A:actor']]}}, inputs, root / 'out')
            self.assertEqual('unsolvable', result['status'])
            self.assertTrue(result['planner_called'])

    def test_rejects_foreign_identity_unknown_symbols_and_partial_states(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs = self.inputs(root)
            variants = []
            q = self.query(); q['initial'] = [['A:ready', 'B:actor']]; variants.append(q)
            q = self.query(); q['goal'] = {'positive': [['A:unknown', 'hero']]}; variants.append(q)
            q = self.query(); q['state_semantics'] = 'partial'; variants.append(q)
            q = self.query(); q['sources'] = ['B']; variants.append(q)
            q = self.query(); q['max_states'] = True; variants.append(q)
            q = self.query(); q['correlated_parameter_tuples'] = True; variants.append(q)
            q = self.query(); q.update(solver='state_projected', correlated_parameter_tuples=1); variants.append(q)
            q = self.query(); q['precondition_witness_representatives'] = True; variants.append(q)
            q = self.query(); q.update(solver='state_projected', precondition_witness_representatives=1); variants.append(q)
            for i, query in enumerate(variants):
                with self.subTest(i=i):
                    result = run(query, inputs, root / str(i))
                    self.assertEqual('rejected', result['status'])
                    self.assertFalse(result['planner_called'])

    def test_initial_only_emits_valid_changed_endpoints_without_inventing_facts(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs = self.inputs(root)
            query = self.query()
            del query['goal']
            result = run(query, inputs, root / 'out')
            self.assertEqual('outcomes_generated', result['status'])
            self.assertEqual('reachable_space_exhausted', result['search']['stop_reason'])
            self.assertEqual(1, len(result['search']['outcomes']))
            candidate = result['search']['outcomes'][0]
            self.assertEqual('VALID', candidate['validation']['status'])
            self.assertEqual(1, candidate['length'])
            self.assertEqual({('d000__p_ready', False), ('d000__p_done', True)},
                             {(c['atom'][0], c['value']) for c in candidate['changes']})
            query['initial'] = []
            empty = run(query, inputs, root / 'empty')
            self.assertEqual('no_outcomes', empty['status'])
            self.assertEqual([], empty['search']['outcomes'])


if __name__ == '__main__':
    unittest.main()

import json
import copy
from pathlib import Path
import tempfile
import unittest
from types import SimpleNamespace
from unittest.mock import patch

from rcnc.narrative_pipeline import run
from rcnc.pddl import parse_domain, write_domain
from rcnc.aligned_domain import build
from rcnc.component_selection import restrict
from rcnc.narrative_pipeline import map_problem
from rcnc.domain_building import digest
from tests import test_domain_catalog as fixtures


class ComponentSelectionTests(unittest.TestCase):
    def test_legacy_export_requires_a_pinned_external_registry_hash(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs, query = fixtures.DomainCatalogTests().fixture(root)
            compiled = root / 'compiled'
            build(inputs, compiled, query['alignment'])
            map_problem(query, compiled, root / 'problem.pddl')
            metadata_path = compiled / 'meta_domain.json'
            metadata = json.loads(metadata_path.read_text(encoding='utf-8'))
            metadata.pop('compiled_domain_sha256')
            metadata_path.write_text(json.dumps(metadata), encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'explicit frozen expected'):
                restrict(query, compiled, root / 'problem.pddl', root / 'missing_pin.pddl')
            certificate = restrict(query, compiled, root / 'problem.pddl', root / 'selected.pddl',
                expected_domain_sha256=digest(compiled / 'meta_domain.pddl'))
            self.assertEqual('explicit_external_frozen_registry_hash', certificate['domain_pin_basis'])

    def test_metadata_change_during_search_is_reported_even_when_domain_is_unchanged(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs, query = fixtures.DomainCatalogTests().fixture(root)
            output = root / 'request'
            def worker(command, **kwargs):
                planning = output / 'planning'
                planning.mkdir()
                (planning / 'search.json').write_text(json.dumps({'status': 'unsolvable'}), encoding='utf-8')
                path = output / 'union/meta_domain.json'
                metadata = json.loads(path.read_text(encoding='utf-8'))
                metadata['unexpected_post_export_change'] = True
                path.write_text(json.dumps(metadata), encoding='utf-8')
                return SimpleNamespace(returncode=0)
            with patch('rcnc.narrative_pipeline.subprocess.run', side_effect=worker):
                result = run(query, inputs, output)
            self.assertEqual('artifact_changed', result['status'])
            self.assertTrue(result['domain_unchanged'])
            self.assertFalse(result['provenance_unchanged'])

    def test_added_scene_action_is_rejected_instead_of_silently_discarded(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs, query = fixtures.DomainCatalogTests().fixture(root)
            compiled = root / 'compiled'
            build(inputs, compiled, query['alignment'])
            map_problem(query, compiled, root / 'problem.pddl')
            domain = parse_domain(compiled / 'meta_domain.pddl')
            extra = copy.deepcopy(next(iter(domain.actions.values())))
            extra[1] = 'new_scene_action'
            domain.actions['new_scene_action'] = extra
            write_domain(domain, compiled / 'meta_domain.pddl')
            # Even a matching declared hash cannot bless an unmapped action.
            metadata = json.loads((compiled / 'meta_domain.json').read_text(encoding='utf-8'))
            metadata['compiled_domain_sha256'] = digest(compiled / 'meta_domain.pddl')
            (compiled / 'meta_domain.json').write_text(json.dumps(metadata), encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'source-action provenance'):
                restrict(query, compiled, root / 'problem.pddl', root / 'selected.pddl')
            self.assertFalse((root / 'selected.pddl').exists())

    def test_changed_existing_action_body_is_rejected_by_export_pin(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs, query = fixtures.DomainCatalogTests().fixture(root)
            compiled = root / 'compiled'
            build(inputs, compiled, query['alignment'])
            map_problem(query, compiled, root / 'problem.pddl')
            domain = parse_domain(compiled / 'meta_domain.pddl')
            action = next(iter(domain.actions.values()))
            action[action.index(':precondition') + 1] = ['and']
            write_domain(domain, compiled / 'meta_domain.pddl')
            with self.assertRaisesRegex(ValueError, 'export hash mismatch'):
                restrict(query, compiled, root / 'problem.pddl', root / 'selected.pddl')
            self.assertFalse((root / 'selected.pddl').exists())

    def test_pipeline_retains_world_and_complete_source_actions_for_composed_goal(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs, query = fixtures.DomainCatalogTests().fixture(root)
            query['goal']['positive'].append(['A:unrelated'])
            baseline = run(query, inputs, root / 'all')
            selected = run({**query, 'selection': 'static_universe_components'}, inputs, root / 'selected')
            self.assertEqual('solved', baseline['status'])
            self.assertEqual('solved', selected['status'])
            self.assertEqual(3, selected['search']['length'])
            self.assertEqual('VALID', selected['search']['validation']['status'])
            self.assertEqual((root / 'all/mapped_problem.pddl').read_bytes(),
                             (root / 'selected/mapped_problem.pddl').read_bytes())
            certificate = json.loads((root / 'selected/selection_certificate.json').read_text(encoding='utf-8'))
            self.assertEqual(['A', 'B'], certificate['goal_sources'])
            self.assertEqual(['A', 'B'], certificate['selected_sources'])
            self.assertEqual(['C'], certificate['excluded_sources'])
            self.assertEqual(4, certificate['original_action_count'])
            self.assertEqual(3, certificate['selected_action_count'])
            for field, path in (
                ('compiled_metadata_sha256', 'union/meta_domain.json'),
                ('mapped_problem_sha256', 'mapped_problem.pddl'),
                ('selected_domain_sha256', 'selected_domain.pddl')):
                self.assertEqual(digest(root / 'selected' / path), certificate[field])
            original = parse_domain(root / 'selected/union/meta_domain.pddl')
            reduced = parse_domain(root / 'selected/selected_domain.pddl')
            self.assertEqual(original.predicates, reduced.predicates)
            self.assertEqual(original.constants, reduced.constants)
            self.assertTrue(selected['domain_unchanged'])

    def test_initial_only_missing_alignment_and_empty_goal_rejected_before_search(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs, query = fixtures.DomainCatalogTests().fixture(root)
            initial_only = {k: v for k, v in query.items() if k != 'goal'}
            no_alignment = {k: v for k, v in query.items() if k != 'alignment'}
            for index, variant in enumerate((initial_only, no_alignment, {**query, 'goal': {'positive': []}})):
                result = run({**variant, 'selection': 'static_universe_components'}, inputs, root / str(index))
                self.assertEqual('rejected', result['status'])
                self.assertFalse(result['planner_called'])

    def test_negative_goal_source_is_retained(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs, query = fixtures.DomainCatalogTests().fixture(root)
            query['goal']['negative'] = [['C:irrelevant']]
            result = run({**query, 'selection': 'static_universe_components'}, inputs, root / 'selected')
            self.assertEqual('solved', result['status'])
            self.assertEqual(['A', 'B', 'C'], result['selection']['selected'])
            self.assertEqual(['B', 'C'], result['selection']['goal_sources'])

import copy
import unittest
from types import SimpleNamespace
from rcnc.world_source_selection import select_component


class WorldSelectionTests(unittest.TestCase):
    def fixture(self, arity=1):
        spec = {'predicate_groups': [{'id': 'link', 'members': [
            {'predicate': 'A:p', 'order': list(range(arity))},
            {'predicate': 'B:p', 'order': list(range(arity))}]}], 'type_groups': []}
        meta = {'sources': ['A', 'B'], 'method': 'explicit_predicate_alignment_with_type_membership',
            'type_guards': {'a': 'ga', 'b': 'gb'},
            'namespaces': {'A': {'types': {'object': 'a'}}, 'B': {'types': {'object': 'b'}}},
            'alignment_specification': spec, 'source_predicate_types': {
                'A': {'p': ['a'] * arity}, 'B': {'p': ['b'] * arity}}}
        return meta, SimpleNamespace(actions={}), ['define', [':init', ['ga', 'x'], ['gb', 'y']]]

    def test_disjoint_universes_cut_dependency_without_mutating_original_alignment(self):
        meta, domain, problem = self.fixture()
        before = copy.deepcopy(meta)
        projected, certificate = select_component(meta, domain, problem, 'A')
        self.assertEqual(['A'], certificate['selected_sources'])
        self.assertEqual([], projected['predicate_groups'])
        self.assertFalse(certificate['interface_edges'][0]['retain_dependency'])
        self.assertEqual(meta, before)

    def test_explicit_shared_identity_preserves_foreign_producer(self):
        meta, domain, problem = self.fixture()
        problem[1].append(['gb', 'x'])
        projected, certificate = select_component(meta, domain, problem, 'A')
        self.assertEqual(['A', 'B'], certificate['selected_sources'])
        self.assertEqual(1, len(projected['predicate_groups']))

    def test_nullary_bridge_is_retained_even_with_disjoint_objects(self):
        meta, domain, problem = self.fixture(0)
        _, certificate = select_component(meta, domain, problem, 'A')
        self.assertEqual(['A', 'B'], certificate['selected_sources'])

    def test_membership_modification_is_rejected_including_conditional_effects(self):
        meta, domain, problem = self.fixture()
        domain.actions['mutate'] = [':action', 'mutate', ':parameters', [], ':effect',
                                   ['when', ['p', 'x'], ['ga', 'y']]]
        with self.assertRaisesRegex(ValueError, 'static'):
            select_component(meta, domain, problem, 'A')

    def test_foreign_goal_is_rejected_instead_of_silently_dropped(self):
        meta, domain, problem = self.fixture()
        meta['predicate_maps'] = {'A': {'p': 'pa'}, 'B': {'p': 'pb'}}
        problem.append([':goal', ['pb', 'y']])
        with self.assertRaisesRegex(ValueError, 'outside'):
            select_component(meta, domain, problem, 'A')
        problem[-1] = [':goal', ['pa', 'y']]
        with self.assertRaisesRegex(ValueError, 'foreign object'):
            select_component(meta, domain, problem, 'A')

    def test_subtype_membership_without_root_membership_is_rejected(self):
        meta, domain, problem = self.fixture()
        meta['type_guards']['child'] = 'gc'
        meta['namespaces']['A']['types']['child'] = 'child'
        problem[1].append(['gc', 'y'])
        with self.assertRaisesRegex(ValueError, 'source-root'):
            select_component(meta, domain, problem, 'A')

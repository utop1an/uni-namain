from pathlib import Path
import tempfile
import unittest

from rcnc.composition_probes import generate
from rcnc.pddl import parse_domain


class CompositionProbeTests(unittest.TestCase):
    def fixture(self, root, texts, orders):
        domains = {}
        members = []
        for source, (predicates, actions) in texts.items():
            path = root / (source + '_domainfile.pddl')
            path.write_text(f'''(define (domain {source}) (:requirements :strips :typing)
                (:types red blue - person person - object) (:constants actor - person)
                (:predicates {predicates}) {actions})''', encoding='utf-8')
            domains[source] = parse_domain(path)
            members.append({'predicate': source + ':' + ('signal' if source == 'A' else 'related'), 'order': orders[source]})
        specification = {'predicate_groups': [{'id': 'test_signal', 'members': members}]}
        return domains, specification

    def test_three_cycle_mapping_and_unused_parameters_are_bound_without_fact_inference(self):
        with tempfile.TemporaryDirectory() as td:
            domains, spec = self.fixture(Path(td), {
                'A': ('(signal ?a ?b ?c - person) (ready ?p - person)', '''
                    (:action emit :parameters (?a ?b ?c ?unused - person)
                     :precondition (ready ?a) :effect (signal ?a ?b ?c))'''),
                'B': ('(related ?x ?y ?z - person) (done ?p - person)', '''
                    (:action finish :parameters (?x ?y ?z - person)
                     :precondition (related ?x ?y ?z) :effect (done ?x))''')},
                {'A': [0, 1, 2], 'B': [2, 0, 1]})
            result = generate(domains, spec)
            self.assertEqual(result, generate(domains, spec))
            pair = next(p for p in result['pairs'] if p['producer'] == 'A')
            self.assertEqual('generated', pair['status'])
            bindings = pair['construction']['bindings']
            self.assertEqual(bindings['producer']['?a'], bindings['consumer']['?z'])
            self.assertEqual(bindings['producer']['?b'], bindings['consumer']['?x'])
            self.assertEqual(bindings['producer']['?c'], bindings['consumer']['?y'])
            self.assertEqual(4, len(bindings['producer']))
            self.assertIn(bindings['producer']['?unused'], pair['query']['objects'])
            self.assertEqual([['A:ready', bindings['producer']['?a']]], pair['query']['initial'])
            self.assertEqual([['B:done', bindings['consumer']['?x']]], pair['query']['goal']['positive'])
            reverse = next(p for p in result['pairs'] if p['producer'] == 'B')
            self.assertEqual('no_supported_probe', reverse['status'])

    def test_incomparable_same_source_types_do_not_become_implicit_multiple_memberships(self):
        with tempfile.TemporaryDirectory() as td:
            domains, spec = self.fixture(Path(td), {
                'A': ('(signal ?a ?b - person)', '''(:action emit :parameters (?a - red ?b - blue)
                    :precondition (and) :effect (signal ?a ?b))'''),
                'B': ('(related ?x ?y - person) (done ?p - person)', '''(:action finish :parameters (?x - person)
                    :precondition (related ?x ?x) :effect (done ?x))''')}, {'A': [0, 1], 'B': [0, 1]})
            result = generate(domains, spec)
            self.assertTrue(any(c.get('reason') == 'incomparable_same_source_types' for c in result['candidates']))
            self.assertTrue(all(p['status'] == 'no_supported_probe' for p in result['pairs']))

    def test_trivial_interface_constant_identity_and_unsupported_schema_are_retained_exclusions(self):
        with tempfile.TemporaryDirectory() as td:
            domains, spec = self.fixture(Path(td), {
                'A': ('(signal ?p - person)', '''
                    (:action self :parameters (?x - person) :precondition (signal ?x) :effect (signal ?x))
                    (:action constant :parameters (?x - person) :precondition (and) :effect (signal actor))
                    (:action quantified :parameters () :precondition (and)
                     :effect (forall (?x - person) (signal ?x)))'''),
                'B': ('(related ?p - person) (done ?p - person)', '''
                    (:action finish :parameters (?x - person) :precondition (related ?x) :effect (done ?x))''')},
                {'A': [0], 'B': [0]})
            result = generate(domains, spec)
            reasons = {c.get('reason') for c in result['candidates']}
            self.assertTrue({'target_interface_initially_true', 'constant_interface_term', 'unsupported_generator_schema'} <= reasons)
            self.assertIn('quantified', domains['A'].actions)

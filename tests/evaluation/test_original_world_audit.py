import copy
from pathlib import Path
import tempfile
import unittest

from rcnc.pddl import parse_domain, parse_sexpr
from scripts.audit.audit_original_world_pipeline import check_world


class OriginalWorldAuditTests(unittest.TestCase):
    def fixture(self, root):
        path = root / 'A_domainfile.pddl'
        path.write_text('''(define (domain a) (:types person - object)
            (:constants actor - person) (:predicates (ready ?p - person) (done ?p - person)))''', encoding='utf-8')
        domains = {'A': parse_domain(path)}
        original = parse_sexpr('(define (problem p) (:domain a) (:init (ready actor)) (:goal (done actor)))')
        mapped = parse_sexpr('''(define (problem q) (:domain compiled) (:objects)
            (:init (a_ready a_actor) (guard_person a_actor) (guard_object a_actor))
            (:goal (and (a_done a_actor))))''')
        metadata = {'predicate_maps': {'A': {'ready': 'a_ready', 'done': 'a_done'}},
            'predicate_orders': {'A': {'ready': [0], 'done': [0]}},
            'constant_maps': {'A': {'actor': 'a_actor'}},
            'namespaces': {'A': {'types': {'person': 'a_person', 'object': 'a_object'}}},
            'type_guards': {'a_person': 'guard_person', 'a_object': 'guard_object'}}
        mapping = {'objects': {}, 'initial': [['a_ready', 'a_actor']]}
        return original, domains, metadata, mapped, mapping

    def test_membership_derived_from_source_declarations_and_narrative_injection_detected(self):
        with tempfile.TemporaryDirectory() as td:
            original, domains, metadata, mapped, mapping = self.fixture(Path(td))
            checks = check_world('A', original, domains, metadata, mapped, mapping)
            self.assertTrue(checks['pddl_initial_exactly_narrative_plus_declared_membership'])
            self.assertTrue(checks['original_goal_preserved'])
            corrupted = copy.deepcopy(mapped)
            corrupted[4].append(['a_done', 'a_actor'])
            # Metadata cannot bless a narrative fact as a technical type fact.
            metadata['constant_membership_facts'] = [['a_done', 'a_actor']]
            checks = check_world('A', original, domains, metadata, corrupted, mapping)
            self.assertFalse(checks['pddl_initial_exactly_narrative_plus_declared_membership'])

    def test_goal_polarity_and_foreign_problem_object_are_checked(self):
        with tempfile.TemporaryDirectory() as td:
            original, domains, metadata, mapped, mapping = self.fixture(Path(td))
            mapped[-1] = [':goal', ['not', ['a_done', 'a_actor']]]
            mapped[3] = [':objects', 'foreign', '-', 'object']
            checks = check_world('A', original, domains, metadata, mapped, mapping)
            self.assertFalse(checks['original_goal_preserved'])
            self.assertFalse(checks['original_problem_objects_preserved'])

from pathlib import Path
import tempfile
import unittest

from rcnc.pddl import parse_domain, parse_sexpr
from scripts.audit.audit_composition_probes import necessity, world_checks


class CompositionProbeAuditTests(unittest.TestCase):
    def test_source_use_does_not_replace_removal_controls_or_turn_limits_into_proofs(self):
        self.assertEqual('both_action_sources_necessary', necessity('solved', 'unsolvable', 'unsolvable', 'unsolvable'))
        self.assertEqual('source_removal_still_solved', necessity('solved', 'solved', 'solved', 'unsolvable'))
        self.assertEqual('inconclusive_source_removal', necessity('solved', 'unsolvable', 'wall_time_limit', 'unsolvable'))
        self.assertEqual('aligned_wall_time_limit', necessity('wall_time_limit', 'unsolvable', 'unsolvable', 'unsolvable'))

    def test_explicit_shared_object_membership_is_kept_and_added_narrative_fact_is_detected(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            domains = {}
            for source in ('A', 'B'):
                path = root / (source + '_domainfile.pddl')
                path.write_text(f'''(define (domain {source}) (:types person - object)
                    (:constants actor - person) (:predicates (p ?x - person)))''', encoding='utf-8')
                domains[source] = parse_domain(path)
            metadata = {'constant_maps': {s: {'actor': s.lower() + '_actor'} for s in ('A', 'B')},
                'namespaces': {s: {'types': {'person': s + '_person', 'object': s + '_object'}} for s in ('A', 'B')},
                'type_guards': {s + '_' + t: s.lower() + '_guard_' + t for s in ('A', 'B') for t in ('person', 'object')},
                'predicate_maps': {'A': {'p': 'shared'}, 'B': {'p': 'shared', 'done': 'b_done'}},
                'predicate_orders': {'A': {'p': [0]}, 'B': {'p': [0], 'done': [0]}}}
            query = {'objects': {'hero': ['A:person', 'B:person']}, 'initial': [['A:p', 'hero']],
                     'goal': {'positive': [['B:done', 'hero']]}}
            mapping = {'objects': {'hero': 'q__hero'}, 'initial': [['shared', 'q__hero']]}
            technical = ' '.join(f'({s.lower()}_guard_{t} {obj})' for s in ('A', 'B')
                for obj in (s.lower() + '_actor', 'q__hero') for t in ('person', 'object'))
            mapped = parse_sexpr(f'''(define (problem q) (:domain compiled) (:objects q__hero - object)
                (:init (shared q__hero) {technical}) (:goal (and (b_done q__hero))))''')
            result = world_checks(query, metadata, domains, mapped, mapping)
            self.assertTrue(result['request_objects_preserved'])
            self.assertTrue(result['pddl_initial_exact'])
            self.assertEqual(8, result['technical_fact_count'])
            mapped[4].append(['b_done', 'q__hero'])
            metadata['constant_membership_facts'] = [['b_done', 'q__hero']]
            self.assertFalse(world_checks(query, metadata, domains, mapped, mapping)['pddl_initial_exact'])

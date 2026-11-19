import tempfile
import unittest
from pathlib import Path

from unified_planning.io import PDDLReader
from rcnc.bidirectional_replay import run_pair


class BidirectionalReplayTests(unittest.TestCase):
    def test_case_normalization_matches_pddl_without_changing_positions(self):
        from scripts.experiments.run_bidirectional_scaling import normalize_mapping
        value = normalize_mapping({'objects': {'FoxHole': 'Mapped_FoxHole'}, 'predicates': {'At': 'Where'},
            'orders': {'At': [1, 0]}, 'actions': {'Go': {'target': 'Travel', 'positions': [1, 0]}}})
        self.assertEqual({'foxhole': 'mapped_foxhole'}, value['objects'])
        self.assertEqual({'at': [1, 0]}, value['orders'])
        self.assertEqual({'go': {'target': 'travel', 'positions': [1, 0]}}, value['actions'])

    def test_case_collisions_are_rejected(self):
        from scripts.experiments.run_bidirectional_scaling import normalize_mapping
        with self.assertRaisesRegex(ValueError, 'Conflicting'):
            normalize_mapping({'objects': {'A': 'x', 'a': 'y'}, 'predicates': {}, 'actions': {}})

    def pair(self, target_pre='(ready ?x)', target_effect='(done ?x)', target_init='(ready a)', extra='', positions=None,
             source_pre='(ready ?x)', directions=None):
        domain = '''(define (domain d) (:requirements :strips :typing :negative-preconditions)
        (:types item) (:constants a EXTRA - item) (:predicates (ready ?x - item) (done ?x - item))
        (:action go :parameters (?x - item) :precondition PRE :effect EFFECT))'''
        problem = '(define (problem p) (:domain d) (:init INIT) (:goal (done a)))'
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for label, pre, effect, init, extras in [('s', source_pre, '(done ?x)', '(ready a)', ''),
                                                    ('t', target_pre, target_effect, target_init, extra)]:
                (root / (label + '.pddl')).write_text(domain.replace('EXTRA', extras).replace('PRE', pre).replace('EFFECT', effect), encoding='utf-8')
                (root / (label + 'p.pddl')).write_text(problem.replace('INIT', init), encoding='utf-8')
            reader = PDDLReader()
            source = reader.parse_problem(str(root/'s.pddl'), str(root/'sp.pddl'))
            target = reader.parse_problem(str(root/'t.pddl'), str(root/'tp.pddl'))
            mapping = {'objects': {'a': 'a'}, 'predicates': {'ready': 'ready', 'done': 'done'},
                       'actions': {'go': {'target': 'go', 'positions': positions if positions is not None else [0]}}}
            return run_pair(source, target, mapping, {'seeds': [7], 'max_depth': 4, 'max_atoms': 100,
                'max_states': 20, 'max_candidates': 200, 'seconds': 5,
                **({'directions': directions} if directions is not None else {})})

    def test_forward_only_keeps_forward_failures_and_omits_reverse_slots(self):
        report = self.pair(directions=['forward'], target_pre='(and (ready ?x) (done ?x))')
        self.assertEqual(1, report['task_count'])
        self.assertEqual('forward', report['rows'][0]['direction'])
        self.assertEqual('applicability_mismatch', report['rows'][0]['status'])

    def test_invalid_direction_registration_rejected(self):
        for value in ([], ['forward', 'forward'], ['unknown'], 'forward'):
            with self.subTest(value=value), self.assertRaisesRegex(ValueError, 'directions'):
                self.pair(directions=value)

    def test_equivalent_both_directions_and_truth(self):
        report = self.pair()
        self.assertEqual(['pass_sampled'] * 3, [r['status'] for r in report['rows']])
        self.assertTrue(all(r['goal_reached_source'] for r in report['rows']))
        self.assertTrue(all(r['truth_checks'] == 10 for r in report['rows']))

    def test_stronger_precondition_loses_forward_trace(self):
        report = self.pair(target_pre='(and (ready ?x) (done ?x))')
        self.assertEqual('applicability_mismatch', report['rows'][0]['status'])
        self.assertEqual('no_executable_actions', report['rows'][1]['status'])

    def test_added_delete_effect_detected_even_when_goal_is_met(self):
        report = self.pair(target_effect='(and (done ?x) (not (ready ?x)))')
        self.assertTrue(all(r['status'] == 'truth_mismatch' for r in report['rows']))

    def test_weaker_precondition_detected_by_reverse_generation(self):
        report = self.pair(source_pre='(and (ready ?x) (not (done ?x)))')
        self.assertEqual('pass_sampled', report['rows'][0]['status'])
        self.assertEqual('applicability_mismatch', report['rows'][1]['status'])
        self.assertEqual(2, report['rows'][1]['at_step'])

    def test_foreign_binding_is_separate_scope(self):
        report = self.pair(target_pre='(and)', target_init='(ready a)', extra='b')
        self.assertEqual('pass_sampled', report['rows'][1]['status'])
        self.assertEqual('outside_source_object_universe', report['rows'][2]['status'])

    def test_initial_false_truth_checked(self):
        report = self.pair(target_init='')
        self.assertTrue(all(r['status'] == 'truth_mismatch' for r in report['rows']))

    def test_partial_argument_map_rejected(self):
        with self.assertRaisesRegex(ValueError, 'parameter mapping'):
            self.pair(positions=[])

    def test_three_cycle_parameter_and_predicate_permutations(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            common = '(define (domain d) (:requirements :strips :typing) (:types item) (:constants a b c - item) '
            source_domain = common + '''(:predicates (rel ?x ?y ?z - item) (done ?x ?y ?z - item))
                (:action go :parameters (?x ?y ?z - item) :precondition (rel ?x ?y ?z) :effect (done ?x ?y ?z)))'''
            target_domain = common + '''(:predicates (r ?x ?y ?z - item) (d ?x ?y ?z - item))
                (:action g :parameters (?z ?x ?y - item) :precondition (r ?y ?z ?x) :effect (d ?y ?z ?x)))'''
            for label, domain, initial, goal in [('s', source_domain, '(rel a b c)', '(done a b c)'),
                                                  ('t', target_domain, '(r b c a)', '(d b c a)')]:
                (root / (label + '.pddl')).write_text(domain, encoding='utf-8')
                (root / (label + 'p.pddl')).write_text(f'(define (problem p) (:domain d) (:init {initial}) (:goal {goal}))', encoding='utf-8')
            reader = PDDLReader()
            source = reader.parse_problem(str(root/'s.pddl'), str(root/'sp.pddl'))
            target = reader.parse_problem(str(root/'t.pddl'), str(root/'tp.pddl'))
            mapping = {'objects': {n:n for n in ('a','b','c')}, 'predicates': {'rel':'r', 'done':'d'},
                       'orders': {'rel':[1,2,0], 'done':[1,2,0]}, 'actions': {'go': {'target':'g', 'positions':[2,0,1]}}}
            report = run_pair(source, target, mapping, {'seeds':[7], 'max_depth':2, 'max_atoms':100,
                                                      'max_states':20, 'max_candidates':200, 'seconds':5})
            self.assertEqual(['pass_sampled'] * 3, [r['status'] for r in report['rows']])
            self.assertEqual(['c','a','b'], report['rows'][0]['trace'][0]['transported_arguments'])


if __name__ == '__main__':
    unittest.main()

from pathlib import Path
import tempfile
import unittest

from rcnc.glaive_merge import Source
from rcnc.pddl import serialize
from scripts.audit.eval_revised_composition import causal_trace, group_candidates, profiles_for


class CompositionEvalTests(unittest.TestCase):
    def trace(self, root, producer_effect, consumer_pre, init=(), ambiguous=False):
        d = root / 'domain.pddl'; p = root / 'problem.pddl'; q = root / 'plan.pddl'
        d.write_text(f'''(define (domain test) (:predicates (shared_x) (done) (unrelated))
          (:action a :parameters () :precondition (and) :effect {producer_effect})
          (:action b :parameters () :precondition {consumer_pre} :effect (done)))''', encoding='utf-8')
        p.write_text(serialize(['define', ['problem', 'task'], [':domain', 'test'],
            [':init', *init], [':goal', ['done']]]), encoding='utf-8')
        q.write_text('(define (plan plan) (:problem task) (:steps (a) (b)))', encoding='utf-8')
        mapping = {'action_maps': {'A:first': {'name': 'a'}, 'B:second': {'name': 'b'}}}
        if ambiguous: mapping['action_maps']['B:also_first'] = {'name': 'a'}
        return causal_trace(d, p, q, mapping)

    def test_goal_relevant_cross_source_producer_consumer_is_detected(self):
        with tempfile.TemporaryDirectory() as td:
            r = self.trace(Path(td), '(shared_x)', '(shared_x)')
            self.assertEqual('cross_source_composition', r['status'])
            self.assertEqual(2, r['goal_relevant_source_count'])

    def test_independent_concatenation_is_not_composition(self):
        with tempfile.TemporaryDirectory() as td:
            r = self.trace(Path(td), '(unrelated)', '(and)')
            self.assertEqual('no_goal_relevant_cross_source_link', r['status'])
            self.assertEqual(1, r['goal_relevant_source_count'])

    def test_readding_initial_fact_does_not_manufacture_causal_link(self):
        with tempfile.TemporaryDirectory() as td:
            r = self.trace(Path(td), '(shared_x)', '(shared_x)', [['shared_x']])
            self.assertEqual('no_goal_relevant_cross_source_link', r['status'])

    def test_ambiguous_fused_provenance_is_unknown(self):
        with tempfile.TemporaryDirectory() as td:
            r = self.trace(Path(td), '(shared_x)', '(shared_x)', ambiguous=True)
            self.assertEqual('unknown', r['status'])

    def test_explicit_world_binding_intentions_and_no_source_fact_pooling(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); sources = {}
            for sid, action in [('A', '(:action make :parameters (?x - character) :precondition (ready ?x) :effect (link ?x) :agents (?x))'),
                                ('B', '(:action use :parameters (?y - character) :precondition (link ?y) :effect (done ?y) :agents (?y))')]:
                d = root / (sid + '-d.pddl'); p = root / (sid + '-p.pddl')
                d.write_text(f'(define (domain {sid}) (:requirements :typing :intentionality) (:types character - object) (:predicates (ready ?x - character) (link ?x - character) (done ?x - character) (private ?x - character)) {action})', encoding='utf-8')
                p.write_text(f'(define (problem p) (:domain {sid}) (:objects original - character) (:init (private original)) (:goal (done original)))', encoding='utf-8')
                sources[sid] = Source(sid, d, p)
            profiles, _ = profiles_for(sources)
            g = {'id': 'pair', 'sources': ['A', 'B']}
            alignment = [{'id': 'link', 'members': [{'predicate': sid + ':link', 'order': [0]} for sid in ['A', 'B']]}]
            records = group_candidates(g, alignment, sources, profiles)
            supported = [r for r in records if r['status'] == 'supported']
            self.assertEqual(1, len(supported))
            world = supported[0]['scenario']
            self.assertEqual(0, world['source_problem_facts_copied'])
            self.assertNotIn('private', str(world))
            self.assertEqual(1, len(world['objects']))
            self.assertEqual({'A': 'character', 'B': 'character'}, next(iter(world['objects'].values())))
            self.assertEqual(1, len(world['intentions']))


if __name__ == '__main__': unittest.main()

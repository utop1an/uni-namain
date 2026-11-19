from pathlib import Path
import tempfile
import unittest

from rcnc.causal_attribution_axioms import causal_trace_with_axioms


class ExtendedCausalAttributionTests(unittest.TestCase):
    def trace(self, body, goal, *, initial='(flag)', max_interpretations=4096):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            domain, problem, plan = (root / name for name in ('domain', 'problem', 'plan'))
            domain.write_text('''(define (domain d) (:types item)
                (:predicates (flag) (shared_x ?x - item) (y ?x - item) (z ?x - item)
                             (done) (unrelated))
                (:action start :parameters (?x - item) :precondition (and)
                    :effect (shared_x ?x))
                ''' + body + ')', encoding='utf-8')
            problem.write_text(f'''(define (problem p) (:domain d) (:objects a - item)
                (:init {initial}) (:goal {goal}))''', encoding='utf-8')
            plan.write_text('(define (plan q) (:problem p) (:steps (start a) (finish a)))', encoding='utf-8')
            mapping = {'action_maps': {'first:start': {'name': 'start'},
                                       'second:finish': {'name': 'finish'}}}
            return causal_trace_with_axioms(domain, problem, plan, mapping,
                                            selected_sources=['first', 'second'],
                                            max_interpretations=max_interpretations)

    def test_axiom_chain_and_fired_effect_support_the_goal(self):
        body = '''
            (:axiom :vars (?x - item) :context (shared_x ?x)
                :implies (and (y ?x) (not (shared_x ?x))))
            (:axiom :vars (?x - item) :context (y ?x) :implies (z ?x))
            (:action finish :parameters (?x - item) :precondition (and)
                :effect (and (unrelated) (when (z ?x) (done))))
        '''
        result = self.trace(body, '(done)')
        profile = result['source_count_profile']
        self.assertEqual(profile['at_least']['2']['status'], 'confirmed')
        self.assertEqual(result['physical']['axiom_closure_rounds'], [0, 2, 0])
        witness = profile['witnesses']['2']
        by_index = {node['node']: node['kind'] for node in witness['support']}
        self.assertEqual([by_index[i] for i in witness['path']].count('axiom'), 2)
        self.assertEqual(self.trace(body, '(unrelated)')['source_count_profile']['exact_count'], 1)

    def test_static_disjunct_keeps_independent_and_cross_support_alternatives(self):
        body = '''
            (:action finish :parameters (?x - item) :precondition (and)
                :effect (when (or (flag) (shared_x ?x)) (done)))
        '''
        result = self.trace(body, '(done)')
        self.assertEqual(result['source_count_profile']['at_least']['2']['status'], 'ambiguous')
        capped = self.trace(body, '(done)', max_interpretations=1)
        self.assertEqual((capped['status'], capped['reason']), ('unknown', 'interpretation_limit'))

    def test_inactive_conditional_effect_contributes_no_support(self):
        body = '''
            (:action finish :parameters (?x - item) :precondition (and)
                :effect (and (done) (when (and (not (flag)) (shared_x ?x)) (unrelated))))
        '''
        result = self.trace(body, '(done)')
        self.assertEqual(result['source_count_profile']['exact_count'], 1)

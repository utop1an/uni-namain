import unittest
from rcnc.saved_plan_validation import replay_saved


class Text:
    def __init__(self,text):self.text=text
    def read_text(self,encoding):return self.text


class SavedPlanValidationTests(unittest.TestCase):
    def setUp(self):
        self.domain=Text('(define (domain d) (:predicates (p) (q)) (:action a :parameters () :precondition (not (p)) :effect (q)))')
        self.plan=Text('(define (plan test) (:problem w) (:steps (a)))')

    def test_explicit_false_supports_negative_precondition(self):
        r=replay_saved(self.domain,Text('(define (problem w) (:domain d) (:init (not (p))) (:goal (q)))'),self.plan)
        self.assertEqual(r['status'],'replayed');self.assertTrue(r['goal']);self.assertEqual(r['explicit_negative_initial_facts'],1)

    def test_contradictory_initial_state_is_not_repaired(self):
        with self.assertRaisesRegex(ValueError,'Contradictory'):
            replay_saved(self.domain,Text('(define (problem w) (:init (p) (not (p))) (:goal (q)))'),self.plan)

    def test_axioms_are_unknown_not_goal_failures(self):
        d=Text('(define (domain d) (:axiom :vars () :context (p) :implies (q)))')
        self.assertEqual(replay_saved(d,Text(''),Text(''))['status'],'unsupported')

    def test_modal_negative_initial_state_is_unsupported(self):
        with self.assertRaisesRegex(ValueError,'Unsupported'):
            replay_saved(self.domain,Text('(define (problem w) (:init (not (intends bob (p)))) (:goal (q)))'),self.plan)


class NativeAxiomReplayTests(unittest.TestCase):
    def replay(self, body, initial, goal, steps='', *, quantified_action_effects=False):
        domain = Text('(define (domain d) (:types item) '
                      '(:predicates (active) (p ?x - item) (q ?x - item) (r ?x - item) (done)) '
                      + body + ')')
        problem = Text(f'(define (problem w) (:domain d) (:objects a b - item) '
                       f'(:init {initial}) (:goal {goal}))')
        plan = Text(f'(define (plan example) (:problem w) (:steps {steps}))')
        return replay_saved(domain, problem, plan, native_axioms=True,
                            quantified_action_effects=quantified_action_effects)

    def test_closure_after_action_deletes_and_propagates(self):
        rules = '''
          (:axiom :vars (?x - item) :context (and (active) (p ?x))
             :implies (and (q ?x) (not (p ?x))))
          (:axiom :vars (?x - item) :context (q ?x) :implies (r ?x))
          (:action start :parameters (?x - item) :precondition (active) :effect (p ?x))
          (:action finish :parameters (?x - item) :precondition (and (r ?x) (not (p ?x))) :effect (done))
        '''
        result = self.replay(rules, '(active)', '(done)', '(start a) (finish a)')
        self.assertTrue(result['goal'])
        self.assertEqual(result['axiom_closure_rounds'], [0, 2, 0])
        bad = self.replay(rules, '(active)', '(done)', '(start a) (finish b)')
        self.assertEqual((bad['status'], bad['step']), ('inapplicable', 1))

    def test_quantified_guard_shadowing_and_conditional_physical_effect(self):
        rules = '''
          (:axiom :vars (?x - item)
            :context (and (active) (q ?x) (exists (?x - item) (p ?x))
                          (forall (?y - item) (or (p ?y) (q ?y))))
            :implies (and (intends ?x (done)) (when (q ?x) (r ?x))))
        '''
        result = self.replay(rules, '(active) (p a) (q b)', '(and (r b) (not (r a)))')
        self.assertTrue(result['goal'])
        self.assertEqual(result['axiom_closure_rounds'], [1])
        inactive = self.replay(rules, '(p a) (q b)', '(r b)')
        self.assertFalse(inactive['goal'])
        self.assertEqual(inactive['grounded_physical_axioms'], 0)

    def test_cycle_and_order_dependent_update_are_unsupported(self):
        cycle = '''
          (:axiom :vars (?x - item) :context (not (p ?x)) :implies (p ?x))
          (:axiom :vars (?x - item) :context (p ?x) :implies (not (p ?x)))
        '''
        with self.assertRaisesRegex(ValueError, 'Cyclic'):
            self.replay(cycle, '', '(done)')
        order = '''
          (:axiom :vars (?x - item) :context (active)
            :implies (and (p ?x) (when (p ?x) (q ?x))))
        '''
        with self.assertRaisesRegex(ValueError, 'Order-sensitive'):
            self.replay(order, '(active)', '(done)')

    def test_pddl_derived_does_not_use_native_axiom_semantics(self):
        result = self.replay('(:derived (done) (active))', '(active)', '(done)')
        self.assertEqual(result['status'], 'unsupported')

    def test_quantified_effect_respects_outer_guard_and_inner_binding(self):
        body = '''
          (:axiom :vars (?x - item) :context (and (q ?x) (not (r ?x))) :implies (done))
          (:action clear :parameters (?x - item) :precondition (active)
            :effect (when (p ?x) (forall (?x - item) (when (q ?x) (not (r ?x))))))
        '''
        initial = '(active) (p a) (q b) (r a) (r b)'
        goal = '(and (done) (r a) (not (r b)))'
        result = self.replay(body, initial, goal, '(clear a)', quantified_action_effects=True)
        self.assertTrue(result['goal'])
        self.assertEqual(result['applied'][0]['deleted'], [('r', 'b')])
        self.assertEqual(result['axiom_closure_rounds'], [0, 1])
        false_guard = self.replay(body, initial, goal, '(clear b)', quantified_action_effects=True)
        self.assertFalse(false_guard['goal'])
        self.assertEqual(false_guard['applied'][0]['deleted'], [])

    def test_quantified_effect_respects_declared_types_and_empty_types(self):
        domain = Text('''(define (domain d) (:types item other empty)
          (:constants a - item)
          (:predicates (p ?x - object) (q ?x - object))
          (:action paint :parameters () :precondition (and)
            :effect (and (forall (?x - item) (p ?x)) (forall (?x - empty) (q ?x)))))''')
        problem = Text('''(define (problem w) (:domain d) (:objects b - item c - other)
          (:init) (:goal (and (p a) (p b) (not (p c)) (forall (?x - object) (not (q ?x))))))''')
        plan = Text('(define (plan example) (:problem w) (:steps (paint)))')
        result = replay_saved(domain, problem, plan, quantified_action_effects=True)
        self.assertTrue(result['goal'])
        self.assertEqual(result['applied'][0]['added'], [('p', 'a'), ('p', 'b')])

    def test_order_dependent_guard_is_safe_for_a_redundant_write(self):
        action = '''
          (:action enter :parameters (?x - item) :precondition (active)
            :effect (and (p ?x) (when (p ?x) (q ?x)) (q ?x)))
        '''
        result = self.replay(action, '(active)', '(q a)', '(enter a)', quantified_action_effects=True)
        self.assertTrue(result['goal'])
        self.assertEqual(result['applied'][0]['added'], [('p', 'a'), ('q', 'a')])
        opposite = action.replace('(q ?x)))', '(q ?x) (not (q ?x))))')
        with self.assertRaisesRegex(ValueError, 'Order-sensitive|Conflicting'):
            self.replay(opposite, '(active)', '(q a)', '(enter a)', quantified_action_effects=True)


if __name__=='__main__':unittest.main()

from pathlib import Path
import tempfile
import unittest

from scripts.experiments.run_four_domain_long_case import trace_case, independent_pairs


class LongCaseTraceTests(unittest.TestCase):
    def fixture(self, root, same_object=False):
        domain = root / 'd.pddl'; problem = root / 'p.pddl'; plan = root / 'plan.pddl'
        domain.write_text('''(define (domain d) (:predicates (shared_link) (done) (other))
          (:action a :parameters () :precondition (and) :effect (shared_link))
          (:action b :parameters (?x ?y) :precondition (and (not (= ?x ?y)) (shared_link)) :effect (done))
          (:action c :parameters () :precondition (and) :effect (other)))''', encoding='utf-8')
        problem.write_text('(define (problem p) (:domain d) (:init) (:goal (and (done) (other))))', encoding='utf-8')
        target = 'x' if same_object else 'y'
        plan.write_text(f'(define (plan p) (:steps (a) (b x {target}) (c)))', encoding='utf-8')
        mapping = {'action_maps': {'A:a': {'name': 'a'}, 'B:b': {'name': 'b'}, 'C:c': {'name': 'c'}}}
        return domain, problem, plan, mapping

    def test_static_inequality_keeps_dynamic_cross_source_link(self):
        with tempfile.TemporaryDirectory() as temp:
            d, p, plan, mapping = self.fixture(Path(temp))
            trace = trace_case(d, p, plan, mapping)
            self.assertEqual('cross_source_composition', trace['status'])
            self.assertEqual(3, trace['goal_relevant_source_count'])
            self.assertTrue(trace['all_steps_goal_relevant'])

    def test_false_inequality_is_not_accepted(self):
        with tempfile.TemporaryDirectory() as temp:
            d, p, plan, mapping = self.fixture(Path(temp), same_object=True)
            self.assertEqual('unknown', trace_case(d, p, plan, mapping)['status'])

    def test_independent_branch_has_no_dynamic_interference(self):
        with tempfile.TemporaryDirectory() as temp:
            d, p, plan, mapping = self.fixture(Path(temp))
            trace = trace_case(d, p, plan, mapping)
            pairs = independent_pairs(d, plan, trace)
            self.assertEqual({(0, 2), (1, 2)}, {(r['first'], r['second']) for r in pairs})


if __name__ == '__main__': unittest.main()

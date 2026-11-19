from pathlib import Path
import tempfile
import unittest

from unified_planning.io import PDDLReader

from rcnc.state_projected_planning import solve


class StateProjectedPlanningTests(unittest.TestCase):
    def fixture(self, root):
        domain = root / 'd.pddl'
        problem = root / 'p.pddl'
        domain.write_text('''(define (domain conditional)
          (:requirements :typing :adl) (:types item) (:constants a b - item)
          (:predicates (ready) (impossible) (on ?x - item) (done ?x - item))
          (:action enable :parameters () :precondition (and)
            :effect (and (ready) (forall (?x - item) (on ?x))))
          (:action finish :parameters (?unused ?x - item)
            :precondition (and (ready) (on ?x))
            :effect (and (when (ready) (done ?x)) (not (on ?x)))))''', encoding='utf-8')
        problem.write_text('''(define (problem p) (:domain conditional)
          (:init) (:goal (and (done a) (done b) (not (on a)) (not (on b)))))''', encoding='utf-8')
        return domain, problem

    def test_forall_conditional_delete_and_complete_arguments(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            domain, problem = self.fixture(root)
            result = solve(domain, problem, root / 'out')
            self.assertEqual('solved', result['status'])
            self.assertEqual(3, result['length'])
            self.assertEqual('VALID', result['validation']['status'])
            lines = (root / 'out' / 'plan.txt').read_text(encoding='utf-8').splitlines()
            self.assertTrue(all(len(line.split()) == 3 for line in lines if 'finish' in line))
            self.assertGreater(result['expanded_effect_instances'], 0)
            reduced = solve(domain, problem, root / 'reduced', inert_parameter_representatives=True)
            self.assertEqual(('solved', 3, 'VALID'), (reduced['status'], reduced['length'], reduced['validation']['status']))
            self.assertEqual(1, reduced['inert_parameter_counts']['finish'])
            self.assertLess(reduced['ground_candidates'], result['ground_candidates'])

    def test_initial_goal_writes_valid_empty_plan_before_projection(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            domain, problem = self.fixture(root)
            problem.write_text(problem.read_text(encoding='utf-8').replace(
                '(:init)', '(:init (done a) (done b))'), encoding='utf-8')
            result = solve(domain, problem, root / 'out', max_depth=0,
                           max_states=1, max_ground_actions=1, max_ground_fluents=1)
            self.assertEqual(('solved', 0, 'VALID'),
                             (result['status'], result['length'], result['validation']['status']))
            self.assertEqual(0, result['ground_candidates'])
            self.assertEqual(0, result['expanded_effect_instances'])
            reader = PDDLReader()
            parsed = reader.parse_problem(str(domain), str(problem))
            self.assertEqual([], reader.parse_plan(parsed, str(root / 'out/plan.txt')).actions)

    def test_limits_are_distinct_from_exhaustive_unsolvability(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            domain, problem = self.fixture(root)
            cases = [({'max_depth': 0}, 'depth_limit'),
                     ({'max_states': 1}, 'state_limit'),
                     ({'max_ground_actions': 1}, 'ground_action_limit'),
                     ({'max_ground_fluents': 1}, 'ground_fluent_limit')]
            for i, (budget, status) in enumerate(cases):
                with self.subTest(status=status):
                    self.assertEqual(status, solve(domain, problem, root / str(i), **budget)['status'])
            problem.write_text('''(define (problem p) (:domain conditional)
              (:init) (:goal (impossible)))''', encoding='utf-8')
            self.assertEqual('unsolvable', solve(domain, problem, root / 'unsolvable')['status'])


if __name__ == '__main__':
    unittest.main()

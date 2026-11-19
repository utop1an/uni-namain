from pathlib import Path
import tempfile
import unittest

from unified_planning.io import PDDLReader

from rcnc.merged_planning import solve


class MergedPlanningTests(unittest.TestCase):
    def fixture(self, root, reachable=True):
        domain = root / 'domain.pddl'
        problem = root / 'problem.pddl'
        domain.write_text('''(define (domain duplicate_static)
          (:requirements :strips :typing)
          (:types person - object) (:constants bad good - person)
          (:predicates (allowed ?x - person) (eligible ?x - person) (done))
          (:action act :parameters (?x - person)
           :precondition (and (allowed ?x) (eligible ?x)) :effect (done)))''')
        init = '(allowed good) (eligible good)' if reachable else ''
        problem.write_text(f'''(define (problem p) (:domain duplicate_static)
          (:init {init}) (:goal (done)))''')
        return domain, problem

    def test_duplicate_static_exclusions_do_not_crash(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            domain, problem = self.fixture(root)
            result = solve(domain, problem, root / 'out')
            self.assertEqual('solved', result['status'])
            self.assertEqual('VALID', result['validation']['status'])
            self.assertEqual(1, result['length'])
            self.assertEqual(1, result['ground_candidates'])

    def test_initial_goal_writes_valid_empty_plan_before_search_limits(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            domain, problem = self.fixture(root)
            problem.write_text(problem.read_text(encoding='utf-8').replace(
                '(:init ', '(:init (done) '), encoding='utf-8')
            result = solve(domain, problem, root / 'out', max_depth=0,
                           max_states=1, max_ground_actions=1)
            self.assertEqual(('solved', 0, 'VALID'),
                             (result['status'], result['length'], result['validation']['status']))
            self.assertEqual(0, result['ground_candidates'])
            reader = PDDLReader()
            parsed = reader.parse_problem(str(domain), str(problem))
            self.assertEqual([], reader.parse_plan(parsed, str(root / 'out/plan.txt')).actions)

    def test_unsolvable_is_distinct_from_each_resource_limit(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            domain, problem = self.fixture(root, reachable=False)
            self.assertEqual('unsolvable', solve(domain, problem, root / 'unreachable')['status'])
            domain, problem = self.fixture(root)
            for flag, value, expected in [('max_states', 1, 'state_limit'),
                                           ('max_depth', 0, 'depth_limit')]:
                self.assertEqual(expected, solve(domain, problem, root / flag, **{flag: value})['status'])
            problem.write_text(problem.read_text().replace('(allowed good)', '(allowed good) (allowed bad) (eligible bad)'))
            self.assertEqual('ground_action_limit', solve(domain, problem, root / 'ground_limit', max_ground_actions=1)['status'])


if __name__ == '__main__':
    unittest.main()

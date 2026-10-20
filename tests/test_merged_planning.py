from pathlib import Path
import tempfile
import unittest

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

import unittest

from scripts.audit.eval_revised_composition_expanded import select_cases


class ExpandedCompositionTests(unittest.TestCase):
    def candidate(self, group, rank, goal='done'):
        return {'group': group, 'rank': rank, 'status': 'supported',
            'scenario': {'objects': {'x': {'A': 'object'}}, 'facts': [],
                         'goal': [['A', [goal, 'x']]], 'intentions': []}}

    def test_keeps_every_supported_candidate_not_one_per_group(self):
        rows = [self.candidate('g2', '1' * 64), self.candidate('g2', '2' * 64)]
        cases, worlds = select_cases({'candidates': rows}, [{'id': 'g2', 'size': 2}])
        self.assertEqual(2, len(cases))
        self.assertEqual(2, len({c['case_id'] for c in cases}))
        self.assertEqual(1, len(worlds))

    def test_representative_is_fixed_by_size_not_outcome_or_input_order(self):
        a = self.candidate('g2', 'a' * 64); b = self.candidate('g4', 'b' * 64)
        a['outcome'] = 'failure'; b['outcome'] = 'success'
        groups = [{'id': 'g2', 'size': 2}, {'id': 'g4', 'size': 4}]
        first = select_cases({'candidates': [a, b]}, groups)
        second = select_cases({'candidates': [b, a]}, groups)
        self.assertEqual(first, second)
        self.assertTrue(first[1][0]['representative_case_id'].startswith('g2__'))

    def test_different_explicit_initial_states_are_different_worlds(self):
        a = self.candidate('g2', 'a' * 64); b = self.candidate('g2', 'b' * 64)
        b['scenario']['facts'] = [['A', ['ready', 'x']]]
        _, worlds = select_cases({'candidates': [a, b]}, [{'id': 'g2', 'size': 2}])
        self.assertEqual(2, len(worlds))

    def test_unsupported_rows_are_not_promoted_to_tasks(self):
        row = self.candidate('g2', 'a' * 64); row['status'] = 'excluded'
        cases, worlds = select_cases({'candidates': [row]}, [{'id': 'g2', 'size': 2}])
        self.assertEqual([], cases)
        self.assertEqual([], worlds)


if __name__ == '__main__':
    unittest.main()

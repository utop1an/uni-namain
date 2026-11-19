import unittest
from unified_planning.plans import ActionInstance, SequentialPlan
from unified_planning.shortcuts import BoolType, Fluent, InstantaneousAction, Problem
from rcnc.trace_audit import compare_states


class TraceAuditTests(unittest.TestCase):
    def test_detects_non_goal_effect_and_keeps_atom_limit_distinct(self):
        source = Problem('source')
        p, q = Fluent('p', BoolType()), Fluent('q', BoolType())
        source.add_fluent(p, default_initial_value=False)
        source.add_fluent(q, default_initial_value=False)
        action = InstantaneousAction('go')
        action.add_effect(p, True)
        source.add_action(action)
        source.add_goal(p)
        target = source.clone()
        good = compare_states(source, target, SequentialPlan([ActionInstance(action)]),
            SequentialPlan([ActionInstance(target.action('go'))]), {'p':'p', 'q':'q'}, {})
        self.assertEqual('PASS', good['status'])
        self.assertEqual(4, good['truth_comparisons'])
        target.action('go').add_effect(q, True)
        bad = compare_states(source, target, SequentialPlan([ActionInstance(action)]),
            SequentialPlan([ActionInstance(target.action('go'))]), {'p':'p', 'q':'q'}, {})
        self.assertEqual('FAIL', bad['status'])
        self.assertEqual('q', bad['first_mismatches'][0]['source_atom'])
        limited = compare_states(source, target, SequentialPlan([]), SequentialPlan([]),
            {'p':'p', 'q':'q'}, {}, max_atoms=1)
        self.assertEqual('atom_limit', limited['status'])


if __name__ == '__main__':
    unittest.main()

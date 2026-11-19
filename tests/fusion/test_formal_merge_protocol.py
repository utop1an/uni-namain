import copy
import json
from pathlib import Path
import tempfile
import unittest

from unified_planning.io import PDDLReader
from unified_planning.shortcuts import SequentialSimulator
from rcnc.conditional_merge import build
from rcnc.formal_merge_protocol import candidates, carrier_types, cross_queries
from rcnc.narrative_pipeline import map_problem
from tests.test_conditional_merge import fixture


class FormalMergeProtocolTests(unittest.TestCase):
    def test_candidate_selection_has_no_problem_or_output_dependency_and_keeps_unavailable_pairs(self):
        with tempfile.TemporaryDirectory() as td:
            _, _, domains = fixture(Path(td))
            selected, ledger = candidates(domains, [('A', 'B'), ('A', 'missing')])
            reversed_domains = dict(reversed(list(domains.items())))
            for d in reversed_domains.values():
                d.actions = dict(reversed(list(d.actions.items())))
                d.predicates = dict(reversed(list(d.predicates.items())))
            self.assertEqual((selected, ledger), candidates(reversed_domains, [('A', 'B'), ('A', 'missing')]))
            self.assertEqual('unavailable_source', ledger[1]['status'])
            self.assertEqual([], ledger[1]['selected'])
            changed = copy.deepcopy(domains)
            action = changed['B'].actions['travel']
            action[action.index(':effect') + 1].append(['ready', '?x'])
            self.assertEqual([], [c for c in candidates(changed, [('A', 'B')])[0] if c['kind'] == 'action'])

    def test_common_carrier_does_not_grant_other_source_membership(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, spec, domains = fixture(root)
            spec['type_groups'] = carrier_types(domains)
            build(inputs, root / 'model', spec, merge_actions=False)
            meta = json.loads((root / 'model/meta_domain.json').read_text())
            query = {'objects': {'actor': 'A:thing', 'start': 'A:thing', 'end': 'A:thing'},
                'initial': [['A:at', 'actor', 'start'], ['B:ready', 'actor']],
                'goal': {'positive': [['A:at', 'actor', 'end']]}}
            with self.assertRaisesRegex(ValueError, 'Ill-typed or cross-source'):
                map_problem(query, root / 'model', root / 'invalid_problem.pddl')
            query['initial'] = query['initial'][:1]
            mapped = map_problem(query, root / 'model', root / 'problem.pddl')
            problem = PDDLReader().parse_problem(str(root / 'model/meta_domain.pddl'), str(root / 'problem.pddl'))
            with SequentialSimulator(problem) as sim:
                state = sim.get_initial_state()
                args = [problem.object(mapped['objects'][k]) for k in ('actor', 'start', 'end')]
                guard = meta['type_guards'][meta['namespaces']['B']['types']['thing']]
                self.assertTrue(state.get_value(problem.fluent(guard)(args[0])).is_false())
                self.assertTrue(sim.is_applicable(state, problem.action(meta['action_maps']['A']['walk']), args))
                self.assertFalse(sim.is_applicable(state, problem.action(meta['action_maps']['B']['travel']), [args[2], args[0], args[1]]))

    def test_composed_worlds_are_explicit_and_not_imported_original_worlds(self):
        qs = cross_queries()
        self.assertEqual(4, len(qs))
        for row in qs:
            self.assertTrue(row['query']['initial'])
            self.assertTrue(row['query']['goal']['positive'])
            self.assertTrue(row['assumption'])
            if row['unit'] == 'authored_cross_positive':
                self.assertFalse(any(f[0] == 'rovers:can_traverse' for f in row['query']['initial']))
        self.assertEqual('authored_semantic_risk_control', qs[-1]['unit'])


if __name__ == '__main__': unittest.main()

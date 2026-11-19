import copy
import json
from pathlib import Path
import tempfile
import unittest

from rcnc.conditional_merge import build, fields
from rcnc.model_semantics import prepare, run
from rcnc.pddl import parse_domain
from scripts.experiments.run_role_contract_merge import clearance_variant
from tests.test_conditional_merge import fixture
from tests.test_model_semantics_facets import response


class RoleContractTests(unittest.TestCase):
    def execute_fixture(self, root, change):
        inputs, spec, _ = fixture(root)
        pairs = [{'id': 'location', 'kind': 'predicate', 'references': ['A:at', 'B:located']},
                 {'id': 'travel', 'kind': 'action', 'references': ['A:walk', 'B:travel']}]
        prepare(inputs, pairs, root / 'judgments', model_digest='fixed',
                schema_policy='semantic_facets_optional_roles', num_predict=16384, num_ctx=32768)
        def transport(url, payload=None, timeout=None):
            if payload is None:
                return {'models': [{'name': 'gemma3:4b', 'digest': 'fixed'}]}
            item = json.loads(payload['messages'][0]['content'].splitlines()[-1])
            value = response(item)
            if item['kind'] == 'action':
                value.update(change)
            return {'done': True, 'done_reason': 'stop', 'message': {'content': json.dumps(value)}}
        report = run(root / 'judgments', transport=transport)
        groups = json.loads((root / 'judgments/groups.json').read_text())['groups']
        spec.update(predicate_candidates=groups[:1], action_candidates=groups[1:])
        return report, build(inputs, root / 'compiled', spec)

    def test_rejection_without_invented_roles_keeps_source_actions(self):
        with tempfile.TemporaryDirectory() as td:
            report, compiled = self.execute_fixture(Path(td), {'roles_correspond': False,
                'relation': 'different', 'difference_kind': 'meaning_or_participants',
                'counterexample_found': True, 'canonical_roles': [], 'left_order': [], 'right_order': [],
                'separating_example': 'The final participant denotes a context in one action and an actor in the other.'})
            self.assertEqual({'checked': 2}, report['status_counts'])
            self.assertEqual('different', report['rows'][1]['response']['decision'])
            self.assertEqual(0, compiled['merged_action_groups'])

    def test_empty_roles_cannot_admit_a_compatible_action(self):
        with tempfile.TemporaryDirectory() as td:
            report, compiled = self.execute_fixture(Path(td), {'canonical_roles': [], 'left_order': [], 'right_order': []})
            self.assertEqual('invalid', report['rows'][1]['status'])
            self.assertEqual(0, compiled['merged_action_groups'])

    def test_precondition_difference_still_merges_with_complete_roles(self):
        with tempfile.TemporaryDirectory() as td:
            report, compiled = self.execute_fixture(Path(td), {})
            self.assertEqual('compatible', report['rows'][1]['response']['decision'])
            self.assertEqual(1, compiled['merged_action_groups'])

    def test_clearance_derivative_changes_only_two_preconditions(self):
        base = parse_domain(Path('data/validation/transport_merge_glm_2026_10_28_v1/inputs/DLOG_domainfile.pddl'))
        original = copy.deepcopy(base)
        changed = clearance_variant(base)
        self.assertEqual(original, base)
        self.assertEqual({'loading-cleared', 'unloading-cleared'}, set(changed.predicates) - set(base.predicates))
        for name, action in base.actions.items():
            self.assertEqual(fields(action)[':effect'], fields(changed.actions[name])[':effect'])
            if name not in ('load-truck', 'unload-truck'):
                self.assertEqual(action, changed.actions[name])
            else:
                self.assertEqual(fields(action)[':precondition'], fields(changed.actions[name])[':precondition'][1])


if __name__ == '__main__':
    unittest.main()

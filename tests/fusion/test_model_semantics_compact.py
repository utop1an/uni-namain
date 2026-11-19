import copy
import json
from pathlib import Path
import tempfile
import unittest

from rcnc.conditional_merge import build
from rcnc.model_semantics import context, prepare, run
from rcnc.model_semantics_compact import normalize, schema
from tests.test_conditional_merge import fixture
from tests.test_model_semantics_facets import response as facets


def response(item):
    f = facets(item)
    r = dict(relation=f['relation'], meanings=[f['left_meaning'], f['right_meaning']],
        concept=f['concept'], scope=f['scope'],
        role_map=[{'role': role, 'left': l, 'right': r} for role, l, r in zip(f['canonical_roles'], f['left_order'], f['right_order'])],
        evidence=[f['left_evidence'], f['right_evidence']], confidence=1,
        separating_example='', rationale=f['rationale'])
    if item['kind'] == 'action': r['difference'] = 'preconditions_only'
    return r


class CompactSemanticTests(unittest.TestCase):
    def item(self, root, kind='action'):
        inputs, _, _ = fixture(root)
        refs = ['A:walk', 'B:travel'] if kind == 'action' else ['A:at', 'B:located']
        return {'kind': kind, 'sides': [context(inputs, ref, kind) for ref in refs]}

    def test_missing_duplicate_boolean_and_out_of_range_roles_never_accept(self):
        with tempfile.TemporaryDirectory() as td:
            item = self.item(Path(td))
            base = response(item)
            bad = [[], base['role_map'][:-1]]
            for value in (0, True, 100):
                roles = copy.deepcopy(base['role_map']); roles[-1]['left'] = value; bad.append(roles)
            for roles in bad:
                with self.subTest(roles=roles), self.assertRaises(ValueError):
                    normalize(item, dict(base, role_map=roles))

    def test_semantic_counterexample_vetoes_positive_and_negative_needs_no_map(self):
        with tempfile.TemporaryDirectory() as td:
            item = self.item(Path(td)); r = response(item)
            self.assertEqual('compatible', normalize(item, r)['decision'])
            self.assertEqual('different', normalize(item, dict(r, separating_example='Roles differ.'))['decision'])
            self.assertEqual('different', normalize(item, dict(r, relation='different', difference='meaning_or_participants', role_map=[]))['decision'])
            self.assertEqual('uncertain', normalize(item, dict(r, relation='uncertain', role_map=[]))['decision'])

    def test_predicate_contract_excludes_applicability_and_checks_citation_side(self):
        with tempfile.TemporaryDirectory() as td:
            item = self.item(Path(td), 'predicate'); r = response(item)
            self.assertNotIn('difference', schema(item)['properties'])
            for changed in (dict(r, difference='preconditions_only'), dict(r, evidence=r['evidence'][::-1])):
                with self.assertRaises(ValueError): normalize(item, changed)

    def test_real_merge_and_raw_audit_use_compact_contract(self):
        from scripts.audit.audit_semantic_facets_comparison import verify_model
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, spec, _ = fixture(root)
            pairs = [{'id': 'location', 'kind': 'predicate', 'references': ['A:at', 'B:located']},
                     {'id': 'travel_positive', 'kind': 'action', 'references': ['A:walk', 'B:travel']}]
            prepare(inputs, pairs, root / 'judgments', model_digest='fixed', schema_policy='compact_kind_specific')
            def transport(url, payload=None, timeout=None):
                if payload is None: return {'models': [{'name': 'gemma3:4b', 'digest': 'fixed'}]}
                text = payload['messages'][0]['content']; self.assertNotIn('travel_positive', text)
                item = json.loads(text.splitlines()[-1])
                return {'done': True, 'done_reason': 'stop', 'message': {'content': json.dumps(response(item))}}
            r = run(root / 'judgments', transport=transport)
            self.assertEqual({'checked': 2}, r['status_counts'])
            self.assertEqual(r, verify_model(root))
            groups = json.loads((root / 'judgments/groups.json').read_text())['groups']
            spec.update(predicate_candidates=groups[:1], action_candidates=groups[1:])
            merged = build(inputs, root / 'merged', spec)
            self.assertEqual(1, merged['merged_action_groups'])


if __name__ == '__main__':
    unittest.main()

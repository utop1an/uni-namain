import copy
import json
from pathlib import Path
import tempfile
import unittest

from rcnc.conditional_merge import build
from rcnc.model_semantics import PROMPT, context, prepare, run, to_group, validate
from tests.test_conditional_merge import fixture


def answer(item):
    arity = len(item['sides'][0]['parameters'])
    return {'decision': 'compatible', 'concept': 'relocation' if arity == 3 else 'location',
            'scope': 'physical_location', 'canonical_roles': ['actor', 'origin', 'destination'] if arity == 3 else ['actor', 'place'],
            'orders': [[0, 1, 2], [1, 2, 0]] if arity == 3 else [[0, 1], [0, 1]],
            'descriptions': ['Position of actor or its change', 'Position of actor or its change'],
            'evidence_ids': [s['contexts'][0]['id'] for s in item['sides']],
            'confidence': 1, 'rationale': 'The declared role correspondence matches the location relation.'}


class ModelSemanticsTests(unittest.TestCase):
    def pairs(self):
        return [{'id': 'location', 'kind': 'predicate', 'references': ['A:at', 'B:located']},
                {'id': 'travel', 'kind': 'action', 'references': ['A:walk', 'B:travel']}]

    def test_automatic_response_compiles_many_to_one_without_manual_cards(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, spec, _ = fixture(root)
            prepare(inputs, self.pairs(), root / 'model', model_digest='fixed')
            def transport(url, payload=None, timeout=None):
                if payload is None: return {'models': [{'name': 'gemma3:4b', 'digest': 'fixed'}]}
                item = json.loads(payload['messages'][0]['content'][len(PROMPT)+1:])
                return {'done': True, 'done_reason': 'stop', 'message': {'content': json.dumps(answer(item))}}
            report = run(root / 'model', transport=transport)
            self.assertEqual({'checked': 2}, report['status_counts'])
            groups = json.loads((root / 'model/groups.json').read_text())['groups']
            spec['predicate_candidates'] = [groups[0]]; spec['action_candidates'] = [groups[1]]
            self.assertEqual(1, build(inputs, root / 'merged', spec)['merged_action_groups'])
            with self.assertRaises(ValueError): run(root / 'model', transport=transport)

    def test_invalid_mapping_and_invented_evidence_cannot_be_accepted(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, _, _ = fixture(root)
            item = {'id': 'travel', 'kind': 'action', 'sides': [context(inputs, r, 'action') for r in ['A:walk', 'B:travel']]}
            valid = answer(item)
            for key, value in [('orders', [[0, 0, 2], [0, 1, 2]]), ('evidence_ids', ['fake']), ('confidence', float('nan'))]:
                changed = copy.deepcopy(valid); changed[key] = value
                with self.assertRaises(ValueError): validate(item, changed)
            group = to_group(item, {'status': 'invalid', 'response': valid})
            self.assertEqual('uncertain', group['model_judgment']['decision'])
            self.assertNotIn('semantics', group['members'][0])

    def test_coupled_live_contract_normalizes_two_sides(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, _, _ = fixture(root)
            prepare(inputs, self.pairs(), root / 'model', model_digest='fixed', schema_policy='coupled_fields')
            def transport(url, payload=None, timeout=None):
                if payload is None: return {'models': [{'name': 'gemma3:4b', 'digest': 'fixed'}]}
                item = json.loads(payload['messages'][0]['content'].splitlines()[-1])
                value = answer(item)
                left, right = value.pop('orders'); e1, e2 = value.pop('evidence_ids')
                value.update(left_order=left, right_order=right, left_evidence=e1, right_evidence=e2)
                return {'done': True, 'done_reason': 'stop', 'message': {'content': json.dumps(value)}}
            result = run(root / 'model', transport=transport)
            self.assertEqual({'checked': 2}, result['status_counts'])

    def test_failure_stops_requests_and_preserves_all_rows(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, _, _ = fixture(root)
            prepare(inputs, self.pairs(), root / 'model', model_digest='fixed')
            def transport(url, payload=None, timeout=None):
                if payload is None: return {'models': [{'name': 'gemma3:4b', 'digest': 'fixed'}]}
                raise TimeoutError('bounded request timed out')
            report = run(root / 'model', transport=transport)
            self.assertEqual(2, report['candidate_count']); self.assertEqual(1, report['requests_attempted'])
            self.assertEqual({'request_failed': 1, 'not_requested': 1}, report['status_counts'])

    def test_model_version_mismatch_makes_no_inference_calls(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, _, _ = fixture(root)
            prepare(inputs, self.pairs(), root / 'model', model_digest='fixed')
            report = run(root / 'model', transport=lambda *a, **kw: {'models': []})
            self.assertEqual(0, report['requests_attempted'])
            self.assertEqual({'not_requested': 2}, report['status_counts'])

    def test_changed_requests_fail_before_network(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, _, _ = fixture(root)
            prepare(inputs, self.pairs(), root / 'model', model_digest='fixed')
            (root / 'model/requests.json').write_text('{}')
            with self.assertRaises(ValueError): run(root / 'model', transport=lambda *a, **kw: self.fail('network called'))


if __name__ == '__main__': unittest.main()

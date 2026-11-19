"""Boundary tests for the new campaign adapter; no network or planner calls."""
import itertools
import json
from pathlib import Path
import tempfile
import unittest

from scripts.experiments.frozen_union_full import mixed_size, mixed_unrank, write
from scripts.experiments.prepare_union_full_openai import request_body, decode_response


class FrozenUnionFullTests(unittest.TestCase):
    def test_mixed_unranking_is_bijection_over_conditioned_universe(self):
        human, story = ['h0', 'h1', 'h2'], ['s0', 's1', 's2', 's3']
        # Independent small-universe oracle, including asymmetric compositions.
        unrank = lambda ids, k, rank: list(itertools.combinations(ids, k))[rank]
        for k in (2, 3, 4, 5):
            expected = {m for m in itertools.combinations(human + story, k)
                        if any(s.startswith('h') for s in m) and any(s.startswith('s') for s in m)}
            actual = [mixed_unrank(human, story, k, i, unrank)
                      for i in range(mixed_size(human, story, k))]
            self.assertEqual(set(actual), expected)
            self.assertEqual(len(actual), len(expected))
            with self.assertRaises(ValueError):
                mixed_unrank(human, story, k, len(actual), unrank)

    def test_artifacts_refuse_overwrite(self):
        with tempfile.TemporaryDirectory() as temp:
            p = Path(temp) / 'evidence.json'
            write(p, {'original': 1})
            with self.assertRaises(FileExistsError):
                write(p, {'replacement': 2})
            self.assertEqual(json.loads(p.read_text(encoding='utf-8')), {'original': 1})

    def test_openai_payload_excludes_group_outcomes_and_provider_legacy_fields(self):
        item = {'id': 'private_candidate_id', 'kind': 'predicate', 'sides': [{'reference': 's:p'}],
                'goal': 'private_goal', 'group': 'private_group', 'potential_links': ['rank_hint']}
        body = request_body(item, model='gpt-6.1-sol', reasoning='medium', max_output_tokens=4096,
                            compact_prompt=lambda _: 'instruction', compact_schema=lambda _: {'type': 'object'})
        encoded = json.dumps(body)
        for secret in ('private_candidate_id', 'private_goal', 'private_group', 'rank_hint', 'keep_alive', 'num_predict'):
            self.assertNotIn(secret, encoded)
        self.assertEqual(body['model'], 'gpt-6.1-sol')
        self.assertFalse(body['store'])
        self.assertTrue(body['text']['format']['strict'])

    def test_incomplete_and_refusal_never_reach_semantic_normalizer(self):
        def forbidden(*_):
            self.fail('Invalid transport output must not be normalized')
        for payload in ({'status': 'incomplete', 'output': []},
                        {'status': 'completed', 'output': [{'type': 'message', 'content': [{'type': 'refusal'}]}]},
                        {'status': 'completed', 'output': []}):
            with self.assertRaises(ValueError):
                decode_response(payload, {}, forbidden, forbidden)

    def test_completed_json_uses_original_semantic_validation(self):
        calls = []
        payload = {'status': 'completed', 'output': [{'type': 'reasoning'},
            {'type': 'message', 'content': [{'type': 'output_text', 'text': '{"relation":"different"}'}]}]}
        compact, normalized = decode_response(payload, {'id': 'x'},
            lambda item, row: {'decision': row['relation']}, lambda item, row: calls.append((item, row)))
        self.assertEqual(compact['relation'], 'different')
        self.assertEqual(normalized['decision'], 'different')
        self.assertEqual(len(calls), 1)


if __name__ == '__main__':
    unittest.main()

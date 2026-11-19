import tempfile
from pathlib import Path
import unittest

from rcnc.model_semantics import context, validate
from rcnc.model_semantics_schema import constrained_schema, normalize
from tests.test_conditional_merge import fixture
from tests.test_model_semantics import answer


class CoupledSenseSchemaTests(unittest.TestCase):
    def test_schema_has_one_complete_order_and_citation_per_side(self):
        with tempfile.TemporaryDirectory() as td:
            inputs, _, _ = fixture(Path(td))
            item = {'kind': 'action', 'sides': [context(inputs, r, 'action') for r in ['A:walk', 'B:travel']]}
            positive = constrained_schema(item)['anyOf'][1]['properties']
            self.assertEqual(3, positive['canonical_roles']['minItems'])
            self.assertEqual(3, positive['canonical_roles']['maxItems'])
            self.assertEqual(['A:walk'], positive['left_evidence']['enum'])
            self.assertEqual(['B:travel'], positive['right_evidence']['enum'])
            response = answer(item)
            raw = {k: v for k, v in response.items() if k not in ('orders', 'evidence_ids')}
            raw.update(left_order=response['orders'][0], right_order=response['orders'][1],
                       left_evidence=response['evidence_ids'][0], right_evidence=response['evidence_ids'][1])
            self.assertEqual(response, normalize(raw)); validate(item, normalize(raw))

    def test_missing_context_cannot_offer_compatible_output_branch(self):
        with tempfile.TemporaryDirectory() as td:
            inputs, _, _ = fixture(Path(td))
            item = {'kind': 'action', 'sides': [context(inputs, r, 'action') for r in ['A:walk', 'B:travel']]}
            item['sides'][0]['contexts'] = []
            self.assertEqual(['different', 'uncertain'], constrained_schema(item)['properties']['decision']['enum'])


if __name__ == '__main__': unittest.main()

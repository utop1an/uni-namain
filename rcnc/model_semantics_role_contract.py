"""Explicit abstention/rejection role slots; semantic acceptance stays unchanged."""
import copy
from .model_semantics_facets import PROMPT as BASE_PROMPT, schema as base_schema

PROMPT = BASE_PROMPT + '''
Output contract: a complete participant mapping is required ONLY for a compatible verdict.
If participant roles are incompatible or a complete correspondence is unsupported, do not invent a common role to fill a slot. Set canonical_roles, left_order and right_order to empty arrays and report different or uncertain with the appropriate role/counterexample facets. An empty mapping never authorizes a merge.
Once you identify a specific role conflict, state it briefly and finish the JSON; there is no need to search for a weaker generic role. Keep all explanations concise. All fields and both source citations are still required.'''


def schema(item):
    result = copy.deepcopy(base_schema(item))
    for prefix in ('left', 'right'):
        complete = result['properties'][prefix + '_order']
        result['properties'][prefix + '_order'] = {'anyOf': [complete, {'type': 'array', 'maxItems': 0}]}
    return result

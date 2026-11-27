"""Explicit abstention/rejection role slots; semantic acceptance stays unchanged."""
from prompts import load_prompt

import copy
from .model_semantics_facets import PROMPT as BASE_PROMPT, schema as base_schema

PROMPT = BASE_PROMPT + ('\n' + load_prompt('historical_alignment/optional_roles'))


def schema(item):
    result = copy.deepcopy(base_schema(item))
    for prefix in ('left', 'right'):
        complete = result['properties'][prefix + '_order']
        result['properties'][prefix + '_order'] = {'anyOf': [complete, {'type': 'array', 'maxItems': 0}]}
    return result

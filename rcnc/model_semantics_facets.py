"""Factor semantic identity from applicability and derive a conservative verdict.

These are model assertions, not semantic proofs or independent labels. The
compiler still owns argument binding, source embedding and transition checks.
"""
from prompts import load_prompt

import itertools


PROMPT = load_prompt('historical_alignment/facets')


def schema(item):
    props = {name: {'type': 'string'} for name in
             ('left_meaning', 'right_meaning', 'concept', 'scope', 'separating_example', 'rationale')}
    props['relation'] = {'type': 'string', 'enum':
        ['same_relation', 'different', 'uncertain'] if item['kind'] == 'predicate'
        else ['same_event_variant', 'different', 'uncertain']}
    props['difference_kind'] = {'type': 'string', 'enum': ['none', 'preconditions_only', 'meaning_or_participants', 'unknown']}
    props['roles_correspond'] = {'type': 'boolean'}
    props['counterexample_found'] = {'type': 'boolean'}
    props['canonical_roles'] = {'type': 'array', 'items': {'type': 'string'}}
    props['confidence'] = {'type': 'number', 'minimum': 0, 'maximum': 1}
    for prefix, side in zip(('left', 'right'), item['sides']):
        n = len(side['parameters'])
        props[prefix + '_order'] = {'type': 'array', 'items': {'type': 'integer'}, 'minItems': n, 'maxItems': n}
        if n <= 6:
            props[prefix + '_order']['enum'] = [list(p) for p in itertools.permutations(range(n))]
        ids = [c['id'] for c in side['contexts']]
        props[prefix + '_evidence'] = {'type': 'string', 'enum': ids or ['']}
    return {'type': 'object', 'properties': props, 'additionalProperties': False, 'required': list(props)}


def normalize(item, response):
    if not isinstance(response, dict) or set(response) != set(schema(item)['required']):
        raise ValueError('Incomplete semantic facets')
    for key in ('roles_correspond', 'counterexample_found'):
        if type(response[key]) is not bool: raise ValueError('Semantic facet must be Boolean: ' + key)
    relation, difference = response['relation'], response['difference_kind']
    if relation not in schema(item)['properties']['relation']['enum'] or difference not in schema(item)['properties']['difference_kind']['enum']:
        raise ValueError('Unsupported semantic relation/difference')
    if not isinstance(response['separating_example'], str): raise ValueError('Invalid separating example')
    expected = 'same_relation' if item['kind'] == 'predicate' else 'same_event_variant'
    decision = 'uncertain'
    if (relation == 'different' or difference == 'meaning_or_participants'
            or response['counterexample_found'] or not response['roles_correspond']):
        decision = 'different'
    elif relation == expected and difference in ('none', 'preconditions_only'):
        # A predicate has no applicability branch: this answer is incoherent.
        if item['kind'] == 'action' or difference == 'none': decision = 'compatible'
    return {'decision': decision, 'concept': response['concept'], 'scope': response['scope'],
            'canonical_roles': response['canonical_roles'],
            'orders': [response['left_order'], response['right_order']],
            'descriptions': [response['left_meaning'], response['right_meaning']],
            'evidence_ids': [response['left_evidence'], response['right_evidence']],
            'confidence': response['confidence'],
            'rationale': response['rationale'] + '\nSemantic facets: ' + relation + '; ' + difference
                         + '; counterexample: ' + response['separating_example']}

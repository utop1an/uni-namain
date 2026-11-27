"""Separate compact predicate/event judgments; no generated formal certificates.

One role table replaces three redundant arrays and factorial permutation enums.
The normalizer still requires a complete bijection before accepting a positive.
"""
import math

from prompts import load_prompt

from .conditional_merge import permutation


COMMON = load_prompt('main/compact_common')

PREDICATE_PROMPT = COMMON + '\n' + load_prompt('main/compact_predicate')

ACTION_PROMPT = COMMON + '\n' + load_prompt('main/compact_action')


def prompt(kind):
    return {'predicate': PREDICATE_PROMPT, 'action': ACTION_PROMPT}[kind]


def schema(item):
    positive = 'same_relation' if item['kind'] == 'predicate' else 'same_event_variant'
    n, m = [len(s['parameters']) for s in item['sides']]
    props = {
        'relation': {'type': 'string', 'enum': [positive, 'different', 'uncertain']},
        'meanings': {'type': 'array', 'items': {'type': 'string'}, 'minItems': 2, 'maxItems': 2},
        'concept': {'type': 'string'}, 'scope': {'type': 'string'},
        'role_map': {'type': 'array', 'maxItems': max(n, m), 'items': {
            'type': 'object', 'additionalProperties': False, 'required': ['role', 'left', 'right'],
            'properties': {'role': {'type': 'string'}, 'left': {'type': 'integer', 'minimum': 0},
                           'right': {'type': 'integer', 'minimum': 0}}}},
        'evidence': {'type': 'array', 'items': {'type': 'string'}, 'minItems': 2, 'maxItems': 2},
        'confidence': {'type': 'number', 'minimum': 0, 'maximum': 1},
        'separating_example': {'type': 'string'}, 'rationale': {'type': 'string'}}
    if item['kind'] == 'action':
        props['difference'] = {'type': 'string', 'enum': ['none', 'preconditions_only', 'meaning_or_participants', 'unknown']}
    return {'type': 'object', 'additionalProperties': False, 'properties': props, 'required': list(props)}


def normalize(item, response):
    contract = schema(item)
    if not isinstance(response, dict) or set(response) != set(contract['required']):
        raise ValueError('Incomplete compact judgment')
    if response['relation'] not in contract['properties']['relation']['enum']:
        raise ValueError('Invalid compact relation')
    for k in ('concept', 'scope', 'rationale', 'separating_example'):
        if not isinstance(response[k], str):
            raise ValueError('Expected text: ' + k)
    if not response['rationale'].strip():
        raise ValueError('Missing rationale')
    meanings, evidence = response['meanings'], response['evidence']
    if not isinstance(meanings, list) or len(meanings) != 2 or any(not isinstance(v, str) or not v.strip() for v in meanings):
        raise ValueError('Both meanings required')
    if not isinstance(evidence, list) or len(evidence) != 2:
        raise ValueError('Both source citations required')
    for side, citation in zip(item['sides'], evidence):
        if not isinstance(citation, str) or citation not in {c['id'] for c in side['contexts']}:
            raise ValueError('Citation must belong to its own source side')
    confidence = response['confidence']
    if type(confidence) not in (int, float) or not math.isfinite(confidence) or not 0 <= confidence <= 1:
        raise ValueError('Invalid confidence')
    roles = response['role_map']
    if not isinstance(roles, list):
        raise ValueError('Invalid role table')
    for r in roles:
        if (not isinstance(r, dict) or set(r) != {'role', 'left', 'right'}
                or not isinstance(r['role'], str) or not r['role'].strip()
                or type(r['left']) is not int or type(r['right']) is not int):
            raise ValueError('Malformed role row')
    difference = response.get('difference', 'none')
    if item['kind'] == 'action' and difference not in contract['properties']['difference']['enum']:
        raise ValueError('Invalid action difference')
    decision = 'uncertain'
    if response['relation'] == 'different' or difference == 'meaning_or_participants' or response['separating_example'].strip():
        decision = 'different'
    elif response['relation'] != 'uncertain' and difference in ('none', 'preconditions_only'):
        decision = 'compatible'
    orders = [[r[side] for r in roles] for side in ('left', 'right')]
    names = [r['role'] for r in roles]
    if decision == 'compatible':
        if not response['concept'].strip() or not response['scope'].strip() or len(set(names)) != len(names):
            raise ValueError('Missing specific meaning or duplicate role')
        for side, order in zip(item['sides'], orders):
            if not permutation(order, len(side['parameters'])):
                raise ValueError('Incomplete role bijection')
    return {'decision': decision, 'concept': response['concept'], 'scope': response['scope'],
            'canonical_roles': names, 'orders': orders, 'descriptions': meanings,
            'evidence_ids': evidence, 'confidence': confidence,
            'rationale': response['rationale'] + '\nCompact relation: ' + response['relation']
                         + '; difference: ' + difference + '; counterexample: ' + response['separating_example']}

"""A stricter output contract; constraints do not establish semantic accuracy."""
import copy
import itertools


def constrained_schema(item):
    from .model_semantics import schema
    base = schema(item)
    props = copy.deepcopy(base['properties'])
    del props['orders']; del props['evidence_ids']
    for side_index, side in enumerate(item['sides']):
        prefix = 'left' if side_index == 0 else 'right'
        props[prefix + '_order'] = {'type': 'array', 'items': {'type': 'integer'}}
        ids = [c['id'] for c in side['contexts']]
        props[prefix + '_evidence'] = {'type': 'string', 'enum': ids + ['']}
    base = {'type': 'object', 'additionalProperties': False, 'properties': props, 'required': list(props)}
    negative = copy.deepcopy(base)
    negative['properties']['decision'] = {'type': 'string', 'enum': ['different', 'uncertain']}
    for name in ('canonical_roles', 'left_order', 'right_order'):
        negative['properties'][name].update(minItems=0, maxItems=0)
    n = len(item['sides'][0]['parameters'])
    if (n > 6 or n != len(item['sides'][1]['parameters'])
            or any(not side['contexts'] for side in item['sides'])):
        return negative
    positive = copy.deepcopy(base)
    positive['properties']['decision'] = {'type': 'string', 'enum': ['compatible']}
    positive['properties']['canonical_roles'].update(minItems=n, maxItems=n)
    for i, prefix in enumerate(('left', 'right')):
        positive['properties'][prefix + '_order'] = {'type': 'array', 'enum': [list(p) for p in itertools.permutations(range(n))]}
        positive['properties'][prefix + '_evidence'] = {'type': 'string', 'enum': [c['id'] for c in item['sides'][i]['contexts']]}
    return {'anyOf': [negative, positive]}


def normalize(response):
    if not isinstance(response, dict): raise ValueError('Expected response object')
    result = dict(response)
    result['orders'] = [result.pop('left_order'), result.pop('right_order')]
    result['evidence_ids'] = [v for v in (result.pop('left_evidence'), result.pop('right_evidence')) if v]
    return result

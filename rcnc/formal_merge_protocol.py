"""Deterministic prospective candidate selection and explicit authored probes.

Selection uses source declarations only. Neither goals, model verdicts nor
planner outcomes enter the ranking. Zero opportunities remain in the ledger.
"""
import hashlib
import itertools
import re

from .conditional_merge import effect_literals, fields
from .pddl import typed_symbols


def arity(value, kind):
    return value.arity if kind == 'predicate' else len(typed_symbols(fields(value)[':parameters']))


def effect_shape(action):
    def shape(literal):
        negative = literal[0] == 'not'
        atom = literal[1] if negative else literal
        return ('delete' if negative else 'add', len(atom[1]) - 1)
    return sorted(shape(literal) for literal in effect_literals(fields(action)[':effect']))


def candidates(domains, source_pairs):
    selected, ledger = [], []
    for left, right in source_pairs:
        bundle = left + '__' + right
        if left not in domains or right not in domains:
            ledger.append({'id': bundle, 'status': 'unavailable_source', 'selected': []})
            continue
        row = {'id': bundle, 'status': 'enumerated', 'eligible': {}, 'selected': []}
        for kind, limit in [('predicate', 6), ('action', 2)]:
            a = domains[left].predicates if kind == 'predicate' else domains[left].actions
            b = domains[right].predicates if kind == 'predicate' else domains[right].actions
            pool = []
            for n, m in itertools.product(sorted(a), sorted(b)):
                if arity(a[n], kind) != arity(b[m], kind):
                    continue
                if kind == 'action' and effect_shape(a[n]) != effect_shape(b[m]):
                    continue
                refs = [left + ':' + n, right + ':' + m]
                fingerprint = hashlib.sha256(('|'.join([kind, *refs])).encode()).hexdigest()
                x, y = [set(re.split('[-_]', name.lower())) for name in (n, m)]
                score = len(x & y) / len(x | y)
                pool.append({'id': kind[0] + '_' + fingerprint[:16], 'kind': kind, 'references': refs,
                    'bundle': bundle, 'ranking': {'name_token_jaccard': score, 'tie_sha256': fingerprint}})
            pool.sort(key=lambda c: (-c['ranking']['name_token_jaccard'], c['ranking']['tie_sha256']))
            row['eligible'][kind] = len(pool)
            row[kind + '_pool'] = pool
            chosen = pool[:limit]
            selected.extend(chosen); row['selected'].extend(c['id'] for c in chosen)
        ledger.append(row)
    return selected, ledger


def carrier_types(domains):
    """Common declaration carrier, never an assertion of semantic type equality.

aligned_domain retains separate static source type guards and original
ancestry. This group only permits heterogeneous predicate declarations to be
compared; membership in one source/type never implies another membership.
"""
    members = [s + ':' + t for s, d in sorted(domains.items()) for t in sorted({'object', *d.types})]
    return [{'members': members, 'evidence': 'Explicit common object carrier for declaration compatibility only; all original source/type membership guards and ancestry remain separate. Not semantic type equality.'}]


def cross_queries():
    result = []
    # A deliberately explicit mechanical world: a miniature ball-shaped rover
    # can be carried by a gripper robot, then performs its own soil analysis.
    # This authored membership assumption is not inferred from source problems.
    for count in (1, 2, 4):
        objects = {'start': ['gripper:object', 'rovers:waypoint'], 'hand': 'gripper:object'}
        initial = [['gripper:room', 'start'], ['gripper:gripper', 'hand'],
                   ['gripper:free', 'hand'], ['gripper:at-robby', 'start']]
        goals = []
        for i in range(count):
            rover, store, site = f'payload{i}', f'store{i}', f'site{i}'
            objects.update({rover: ['gripper:object', 'rovers:rover'], store: 'rovers:store',
                            site: ['gripper:object', 'rovers:waypoint']})
            initial += [['gripper:ball', rover], ['gripper:room', site], ['gripper:at', rover, 'start'],
                ['rovers:at', rover, 'start'], ['rovers:available', rover], ['rovers:store_of', store, rover],
                ['rovers:empty', store], ['rovers:equipped_for_soil_analysis', rover], ['rovers:at_soil_sample', site]]
            goals += [['rovers:have_soil_analysis', rover, site], ['gripper:at', rover, site]]
        result.append({'id': f'carry_then_sample_{count}', 'bundle': 'gripper__rovers',
            'unit': 'authored_cross_positive', 'query': {'objects': objects, 'initial': initial, 'goal': {'positive': goals}},
            'assumption': 'Each payload explicitly belongs to both the graspable-ball and rover roles. No can_traverse facts: a rover cannot relocate itself. This is an authored mechanical assumption, not independently labeled realism.'})
    result.append({'id': 'robot_is_not_lift', 'bundle': 'gripper__miconic', 'unit': 'authored_semantic_risk_control',
        'query': {'objects': {'f0': ['gripper:object', 'miconic:object'], 'f1': ['gripper:object', 'miconic:object'], 'visitor': 'miconic:object'},
            'initial': [['gripper:room', 'f0'], ['gripper:room', 'f1'], ['gripper:at-robby', 'f0'],
                ['miconic:floor', 'f0'], ['miconic:floor', 'f1'], ['miconic:passenger', 'visitor'],
                ['miconic:lift-at', 'f0'], ['miconic:origin', 'visitor', 'f1'], ['miconic:destin', 'visitor', 'f0']],
            'goal': {'positive': [['miconic:served', 'visitor']]}},
        'assumption': 'Robot and lift are distinct implicit actors. Robot movement must not move the lift. This authored negative expectation never enters model prompts or compiler acceptance.'})
    return result

"""Source-only opportunity census and explicit development probe construction."""
import hashlib
import itertools

from .conditional_merge import boolean, effect_literals, fields
from .pddl import serialize, typed_symbols


def identifier(kind, refs):
    return kind[0] + '_' + hashlib.sha256('|'.join([kind, *refs]).encode()).hexdigest()[:16]


def normalized_effect(domain, action, order, source):
    f = fields(action); variables = list(typed_symbols(f[':parameters']))
    mapping = {variables[j]: '?v' + str(i) for i, j in enumerate(order)}
    def rewrite(expr):
        if isinstance(expr, list):
            return [expr[0], *[rewrite(x) for x in expr[1:]]]
        if expr in domain.constants:
            return source + ':' + expr
        return mapping.get(expr, expr)
    return effect_literals(rewrite(f[':effect']))


def census(domains):
    actions, action_rows, pair_rows, selected = {}, [], [], []
    for source, domain in sorted(domains.items()):
        for name, action in sorted(domain.actions.items()):
            row = {'id': source + ':' + name, 'source': source, 'status': 'eligible'}
            try:
                f = fields(action); boolean(f[':precondition'])
                literals = effect_literals(f[':effect'])
                parameters = list(typed_symbols(f[':parameters']).items())
                shape = sorted(('delete' if x[0] == 'not' else 'add', len((x[1] if x[0] == 'not' else x)[1]) - 1) for x in literals)
                if len(parameters) > 6:
                    raise ValueError('Permutation census budget: at most six parameters')
                row.update(arity=len(parameters), effect_shape=shape)
                actions[source, name] = (action, parameters, shape)
            except ValueError as exc:
                row.update(status='outside_candidate_fragment', reason=str(exc))
            action_rows.append(row)
    for left, right in itertools.combinations(sorted(domains), 2):
        pool = []
        for (s, n), (a, ps, shape) in actions.items():
            if s != left: continue
            for (t, m), (b, qs, other) in actions.items():
                if t != right or len(ps) != len(qs) or shape != other: continue
                refs = [s + ':' + n, t + ':' + m]
                row = {'id': identifier('action', refs), 'kind': 'action', 'references': refs,
                       'sources': [s, t], 'named_effect_orders': [], 'status': 'coarse_only'}
                le = normalized_effect(domains[s], a, range(len(ps)), s)
                for order in itertools.permutations(range(len(qs))):
                    if [p[1] for p in ps] != [qs[i][1] for i in order]: continue
                    if le == normalized_effect(domains[t], b, order, t):
                        row['named_effect_orders'].append(list(order))
                if row['named_effect_orders']:
                    row['status'] = 'named_effect_candidate'
                    selected.append(row)
                pool.append(row)
        pair_rows.append({'id': left + '__' + right, 'sources': [left, right], 'status': 'enumerated',
                          'coarse_count': len(pool), 'named_effect_count': sum(r['status'] == 'named_effect_candidate' for r in pool), 'candidates': pool})
    return {'status': 'complete', 'source_count': len(domains), 'domain_pairs': len(pair_rows),
            'action_count': len(action_rows), 'predicate_count': sum(len(d.predicates) for d in domains.values()),
            'action_rows': action_rows, 'rows': pair_rows, 'selected': sorted(selected, key=lambda r: r['references']),
            'scope': 'All source pairs retained. Same predicate spelling, type-name-compatible parameter bijections and equal effects only identify structural opportunities, not semantic matches. Different predicate spellings and outside-fragment actions remain unjudged; this is not a semantic recall estimate.'}


def candidates_and_cases(domains, inventory):
    pairs, cases = {}, []
    for action in inventory['selected']:
        refs = action['references']; sources = action['sources']; case = action['id']
        pairs[case] = {k: action[k] for k in ('id', 'kind', 'references')}
        names = set()
        def visit(expr):
            if expr[0] in ('and', 'not'):
                for child in expr[1:]: visit(child)
            else: names.add(expr[0])
        visit(fields(domains[sources[0]].actions[refs[0].split(':')[1]])[':effect'])
        predicates = []
        for name in sorted(names):
            pr = [s + ':' + name for s in sources]; key = identifier('predicate', pr)
            pairs[key] = {'id': key, 'kind': 'predicate', 'references': pr}; predicates.append(key)
        cases.append({'id': case, 'sources': sources, 'predicate_candidates': predicates, 'action_candidates': [case], 'unit': 'effect_matched_action_pair'})
    controls = []
    for refs in [['BIRT:shrunk', 'ACCO:performing_show'], ['ACCO:owned_by', 'BIRT:lantern_carried']]:
        key = identifier('predicate', refs); pairs[key] = {'id': key, 'kind': 'predicate', 'references': refs}; controls.append(key)
    cases.append({'id': 'known_alias_controls', 'sources': ['ACCO', 'BIRT'], 'predicate_candidates': controls,
                  'action_candidates': [], 'unit': 'known_development_negative_control'})
    return sorted(pairs.values(), key=lambda p: (p['kind'], p['id'])), cases


def cross_queries(cases, pairs):
    by_id = {p['id']: p for p in pairs}
    case = next(c['id'] for c in cases if c['action_candidates'] and by_id[c['action_candidates'][0]]['references'] ==
                ['PUSS:give_bag_to_cat', 'REMA_NP:receive_rubies_from_impostor'])
    rows = []
    for size in (1, 4, 16):
        objects = {'donor': ['PUSS:entity', 'REMA_NP:entity']}
        initial = [['REMA_NP:price_of_butter_spoken']]; goals = []
        for i in range(size):
            recipient, gift = 'recipient' + str(i), 'gift' + str(i)
            objects[recipient] = 'REMA_NP:entity'
            objects[gift] = ['PUSS:item', 'REMA_NP:item']
            initial.append(['REMA_NP:at', recipient, 'REMA_NP:market_place'])
            goals.append(['REMA_NP:has', recipient, gift])
        rows.append({'id': 'acquire_then_handoff_' + str(size), 'case': case, 'unit': 'authored_cross_positive',
            'query': {'objects': objects, 'initial': initial, 'goal': {'positive': goals}},
            'scope': 'Authored mechanical family. Only donor has both source memberships; recipients are REMA-only. Source buy_boots can create arbitrary held items in its formula. This underspecification is retained and is not evidence of realistic purchasing or narrative quality.'})
    rows.append({'id': 'show_is_not_shrink', 'case': 'known_alias_controls', 'unit': 'known_semantic_risk',
        'query': {'objects': {'actor': ['ACCO:entity', 'BIRT:entity'], 'token': ['ACCO:item', 'BIRT:item']},
            'initial': [['ACCO:exhibition_ready', 'actor'], ['ACCO:has', 'actor', 'token']],
            'goal': {'positive': [['BIRT:shrunk', 'actor']], 'negative': [['BIRT:pellet_eaten', 'actor']]}},
        'scope': 'Known authored false-alias control; no independent label or new story family.'})
    return rows


def schema_witness(source, domain, action_name):
    """Construct explicit, labeled one-step schema tests; never source problems."""
    f = fields(domain.actions[action_name]); parameters = list(typed_symbols(f[':parameters']).items())
    binding = {v: 'probe_arg' + str(i) for i, (v, _) in enumerate(parameters)}
    objects = {binding[v]: source + ':' + typ for v, typ in parameters}
    def atom(expr):
        if not expr or expr[0] in ('or', 'exists', 'forall', 'when', '=') or any(isinstance(x, list) for x in expr):
            raise ValueError('Witness constructor needs conjunctions of groundable literals')
        return [source + ':' + expr[0], *[binding[x] if x in binding else source + ':' + x for x in expr[1:]]]
    def literals(expr):
        if expr[0] == 'and':
            return [x for e in expr[1:] for x in literals(e)]
        return [(False, atom(expr[1]))] if expr[0] == 'not' else [(True, atom(expr))]
    pre, effects = literals(f[':precondition']), literals(f[':effect'])
    pos, neg = {tuple(a) for v, a in pre if v}, {tuple(a) for v, a in pre if not v}
    if pos & neg: raise ValueError('Conflicting instantiated preconditions')
    query = {'objects': objects, 'initial': [list(a) for a in sorted(pos)],
             'goal': {'positive': [a for v, a in effects if v], 'negative': [a for v, a in effects if not v]}}
    def local(a): return [x.split(':', 1)[-1] for x in a]
    declarations = [x for obj, typ in objects.items() for x in (obj, '-', typ.split(':')[1])]
    problem = ['define', ['problem', 'explicit_schema_witness'], [':domain', domain.name], [':objects', *declarations],
        [':init', *[local(a) for a in query['initial']]], [':goal', ['and', *[local(a) for a in query['goal']['positive']],
            *[['not', local(a)] for a in query['goal']['negative']]]]]
    return query, serialize(problem) + '\n', '(' + ' '.join([action_name, *binding.values()]) + ')\n'


def translate_calls(source, meta, mapping, calls):
    objects = {k.lower(): v.lower() for k, v in {**meta['constant_maps'][source], **mapping['objects']}.items()}
    result = []
    for call in calls:
        name, arguments = call[0].lower(), [objects[x.lower()] for x in call[1:]]
        permutation = meta['action_parameter_maps'][source][name]
        if sorted(permutation) != list(range(len(arguments))): raise ValueError('Incomplete parameter bijection')
        target = [None] * len(arguments)
        for i, j in enumerate(permutation): target[j] = arguments[i]
        result.append([meta['action_maps'][source][name], *target])
    return result

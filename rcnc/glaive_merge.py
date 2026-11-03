"""Pre-search Glaive union/alignment with explicit source memberships.

Intentionality is retained, not projected into classical planning. Axioms,
quantifiers and other unsupported constructs fail closed. Certificates here
cover physical transitions plus equal acting roles; native intentional replay
is a separate empirical check, not an independent semantic label.
"""
from dataclasses import dataclass
import hashlib
import itertools
from pathlib import Path

from .conditional_merge import permutation, symbol_digest
from .domain_building import digest, save
from .pddl import parse_domain, parse_sexpr, section, serialize, typed_symbols


class Unsupported(ValueError):
    pass


def action_fields(action):
    if len(action[2:]) % 2 or len(set(action[2::2])) != len(action[2::2]):
        raise Unsupported('Malformed action fields')
    f = dict(zip(action[2::2], action[3::2]))
    if set(f) - {':parameters', ':precondition', ':effect', ':agents'}:
        raise Unsupported('Unknown action fields')
    return {':parameters': [], ':precondition': ['and'], ':effect': ['and'], ':agents': [], **f}


def visit(expr):
    if isinstance(expr, list):
        yield expr
        for x in expr: yield from visit(x)


@dataclass
class Source:
    id: str
    domain_path: Path
    problem_path: Path

    def __post_init__(self):
        self.domain = parse_domain(self.domain_path)
        self.root = parse_sexpr(self.domain_path.read_text(encoding='utf-8'))
        self.problem = parse_sexpr(self.problem_path.read_text(encoding='utf-8'))
        allowed = {'domain', ':requirements', ':types', ':constants', ':predicates', ':action'}
        if any(x[0] not in allowed for x in self.root[1:] if isinstance(x, list) and x):
            raise Unsupported('Unsupported domain section, including axioms')
        if section(self.problem, ':init') is None:
            raise Unsupported('needs_initial_state')
        if section(self.problem, ':goal') is None:
            raise Unsupported('Missing explicit goal')
        if any(x[0] not in {'problem', ':domain', ':objects', ':init', ':goal'} for x in self.problem[1:]):
            raise Unsupported('Unsupported problem section')
        if any(x and x[0] in {'forall', 'exists', 'delegated', 'increase', 'assign', 'decrease'}
               for root in (self.root, self.problem) for x in visit(root)):
            raise Unsupported('Quantification, delegation or numeric updates unsupported')
        if any(t in {'expression', 'imposable'} for a in self.domain.actions.values()
               for t in typed_symbols(action_fields(a)[':parameters']).values()):
            raise Unsupported('Expression-valued parameters unsupported')
        for a in self.domain.actions.values(): action_fields(a)
        self.objects = typed_symbols((section(self.problem, ':objects') or [':objects'])[1:])
        self.types = set(self.domain.types) | set(self.domain.types.values()) | {'object'}
        self.types |= set(self.domain.constants.values()) | set(self.objects.values())
        self.term_map = {x: self.id + '_o_' + x for x in self.domain.constants}

    def memberships(self, obj, typ):
        out, seen = [], set()
        while typ not in seen:
            seen.add(typ); out.append([self.id + '_type_' + typ, obj])
            if typ == 'object': break
            typ = self.domain.types.get(typ, 'object')
        if typ != 'object': raise Unsupported('Cyclic source type hierarchy')
        return out


def canonical(expr):
    if isinstance(expr, str): return expr
    if expr and expr[0] in {'and', 'or'}:
        return (expr[0], *sorted({canonical(x) for x in expr[1:]}, key=repr))
    return tuple(canonical(x) for x in expr)


def signed_effects(expr):
    if expr and expr[0] == 'and':
        return frozenset().union(*(signed_effects(x) for x in expr[1:]))
    if not expr: raise Unsupported('Empty effect')
    sign, atom = (False, expr[1]) if expr[0] == 'not' and len(expr) == 2 else (True, expr)
    if atom[0] in {'when', 'or', 'intends', '=', 'forall', 'exists'} or any(isinstance(x, list) for x in atom):
        raise Unsupported('Action fusion requires unconditional ordinary add/delete effects')
    return frozenset([(sign, tuple(atom))])


def rename_vars(expr, mapping):
    if isinstance(expr, str): return mapping.get(expr, expr)
    return [rename_vars(x, mapping) for x in expr]


def rewrite(expr, source, predicates, terms):
    if not isinstance(expr, list) or not expr: raise Unsupported('Malformed formula')
    head = expr[0]
    if head in {'and', 'or', 'not', 'imply', 'when'}:
        return [head, *[rewrite(x, source, predicates, terms) for x in expr[1:]]]
    if head == 'intends':
        if len(expr) != 3: raise Unsupported('Malformed intention')
        return ['intends', terms.get(expr[1], expr[1]), rewrite(expr[2], source, predicates, terms)]
    if head == '=': return ['=', *[terms.get(x, x) for x in expr[1:]]]
    if head not in predicates: raise Unsupported('Undeclared predicate: ' + head)
    target, order = predicates[head]
    args = [terms.get(x, x) for x in expr[1:]]
    if len(args) != len(order): raise Unsupported('Predicate arity mismatch')
    return [target, *[args[i] for i in order]]


def conjunction(items):
    if not items: raise Unsupported('A compiled source guard is required')
    return items[0] if len(items) == 1 else ['and', *items]


def accepted(group, kind, sources, threshold):
    judgment = group.get('model_judgment', {})
    if judgment.get('decision') != 'compatible': return False
    cards = []
    for member in group.get('members', []):
        sid, name = member[kind].split(':'); source = sources[sid]
        value = source.domain.predicates[name] if kind == 'predicate' else source.domain.actions[name]
        arity = value.arity if kind == 'predicate' else len(typed_symbols(action_fields(value)[':parameters']))
        sem = member.get('semantics', {})
        if sem.get('symbol_sha256') != symbol_digest(value) or sem.get('confidence', 0) < threshold:
            return False
        if not permutation(member.get('order'), arity): return False
        if not sem.get('evidence') or sem.get('concept') in {None, '', 'state', 'relation', 'action', 'event'}:
            return False
        roles = sem.get('roles', [])
        if len(roles) != arity: return False
        cards.append((sem.get('concept'), sem.get('scope'), [roles[i] for i in member['order']]))
    return len(cards) >= 2 and all(c == cards[0] for c in cards)


def group_kind(group):
    kinds = {k for m in group.get('members', []) for k in ('predicate', 'action') if k in m}
    return next(iter(kinds)) if len(kinds) == 1 else None


def build(sources, output, *, groups=(), merge_actions=False, threshold=.9):
    output = Path(output)
    if output.exists(): raise ValueError('Fresh merged output required')
    sources = {s.id: s for s in sources}
    pmaps = {sid: {name: (sid + '_p_' + name, list(range(p.arity)))
                   for name, p in s.domain.predicates.items()} for sid, s in sources.items()}
    decisions, occupied = [], set()
    for group in groups:
        if group_kind(group) != 'predicate': continue
        row = {'id': group['id'], 'kind': 'predicate', 'status': 'retained_separate'}
        if accepted(group, 'predicate', sources, threshold):
            refs = [m['predicate'] for m in group['members']]
            if len({r.split(':')[0] for r in refs}) != len(refs) or any(r in occupied for r in refs):
                row['reason'] = 'source_injectivity_or_overlapping_group'
            else:
                for member in group['members']:
                    sid, name = member['predicate'].split(':')
                    pmaps[sid][name] = ('shared_' + group['id'], member['order'])
                occupied.update(refs); row['status'] = 'accepted'
        decisions.append(row)
    requirements = {':adl', ':intentionality'}
    constants, preds, actions, amap = {}, {}, {}, {}
    for sid, s in sources.items():
        requirements.update(s.domain.requirements - {':domain-axioms'})
        preds[sid + '_active'] = [sid + '_active']
        for typ in sorted(s.types): preds[sid + '_type_' + typ] = [sid + '_type_' + typ, '?x', '-', 'object']
        for name, p in s.domain.predicates.items():
            target, order = pmaps[sid][name]
            declaration = [target, *[x for i in range(p.arity) for x in ('?v' + str(i), '-', 'object')]]
            if target in preds and preds[target] != declaration: raise Unsupported('Shared arity disagreement')
            preds[target] = declaration
        for c in s.domain.constants: constants[s.term_map[c]] = 'object'
        for name, action in s.domain.actions.items():
            f = action_fields(action); params = typed_symbols(f[':parameters'])
            aname = sid + '_a_' + name
            guards = [[sid + '_active'], *[[sid + '_type_' + typ, var] for var, typ in params.items()]]
            pre = rewrite(f[':precondition'], s, pmaps[sid], s.term_map)
            eff = rewrite(f[':effect'], s, pmaps[sid], s.term_map)
            agents = [s.term_map.get(x, x) for x in f[':agents']]
            actions[aname] = [':action', aname, ':parameters', [x for v in params for x in (v, '-', 'object')],
                              ':precondition', conjunction([*guards, *([] if pre == ['and'] else [pre])])]
            if eff != ['and']: actions[aname] += [':effect', eff]
            if agents: actions[aname] += [':agents', agents]
            amap[sid + ':' + name] = {'name': aname, 'order': list(range(len(params)))}
    fused = set()
    for group in groups:
        if group_kind(group) != 'action' or not merge_actions: continue
        row = {'id': group['id'], 'kind': 'action', 'status': 'retained_separate'}
        try:
            if not accepted(group, 'action', sources, threshold): raise Unsupported('Semantic gate not accepted')
            refs = [m['action'] for m in group['members']]
            if any(r in fused for r in refs): raise Unsupported('Overlapping action group')
            variants = []
            for member in group['members']:
                f = action_fields(actions[amap[member['action']]['name']])
                vs = list(typed_symbols(f[':parameters']))
                mapping = {vs[j]: '?m' + str(i) for i, j in enumerate(member['order'])}
                variants.append({k: rename_vars(v, mapping) for k, v in f.items()})
            if any(signed_effects(v[':effect']) != signed_effects(variants[0][':effect']) for v in variants):
                raise Unsupported('Different mapped signed effects')
            if any(set(v[':agents']) != set(variants[0][':agents']) for v in variants):
                raise Unsupported('Different consenting agent roles')
            name = 'fused_' + group['id']; arity = len(typed_symbols(variants[0][':parameters']))
            actions[name] = [':action', name, ':parameters', [x for i in range(arity) for x in ('?m' + str(i), '-', 'object')],
                             ':precondition', ['or', *[v[':precondition'] for v in variants]]]
            if variants[0][':effect'] != ['and']: actions[name] += [':effect', variants[0][':effect']]
            if variants[0][':agents']: actions[name] += [':agents', variants[0][':agents']]
            for member in group['members']:
                ref = member['action']; del actions[amap[ref]['name']]
                amap[ref] = {'name': name, 'order': member['order']}
            fused.update(refs)
            row.update(status='accepted', certificate='identical_mapped_add_delete_effects_and_agents_guarded_source_branches',
                       scope='Physical fragment and agent identity; intention-validity replay reported separately')
        except (Unsupported, KeyError, ValueError) as exc: row['reason'] = str(exc)
        decisions.append(row)
    model = ['define', ['domain', 'revised_merged'], [':requirements', *sorted(requirements)], [':types'],
             [':constants', *[x for c, typ in constants.items() for x in (c, '-', typ)]],
             [':predicates', *preds.values()], *actions.values()]
    if not constants: model.pop(4)
    output.mkdir(parents=True)
    (output / 'domain.pddl').write_text(serialize(model) + '\n', encoding='utf-8')
    meta = {'source_sha256': {sid: {'domain': digest(s.domain_path), 'problem': digest(s.problem_path)} for sid, s in sources.items()},
            'predicate_maps': pmaps, 'action_maps': amap, 'decisions': decisions,
            'source_action_count': sum(len(s.domain.actions) for s in sources.values()), 'action_count': len(actions),
            'business_predicate_count': len({v[0] for p in pmaps.values() for v in p.values()}),
            'intentionality_retained': True, 'axioms_supported': False,
            'scope': 'Parameterized domain constructed before search. Source worlds mapped separately; no pooled facts.'}
    save(output / 'mapping.json', meta)
    return meta


def map_problem(sources, source_id, meta, path):
    sources = {s.id: s for s in sources}; s = sources[source_id]
    terms = {**s.term_map, **{o: source_id + '_o_' + o for o in s.objects}}
    objects = [x for o in s.objects for x in (terms[o], '-', 'object')]
    init = [[source_id + '_active']]
    for sid, other in sources.items():
        for c, typ in other.domain.constants.items(): init.extend(other.memberships(other.term_map[c], typ))
    for o, typ in s.objects.items(): init.extend(s.memberships(terms[o], typ))
    init += [rewrite(e, s, meta['predicate_maps'][source_id], terms) for e in section(s.problem, ':init')[1:]]
    goal = rewrite(section(s.problem, ':goal')[1], s, meta['predicate_maps'][source_id], terms)
    root = ['define', ['problem', source_id + '_mapped'], [':domain', 'revised_merged'],
            [':objects', *objects], [':init', *init], [':goal', goal]]
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    Path(path).write_text(serialize(root) + '\n', encoding='utf-8')
    return terms


def translate_plan(source, meta, terms, original, output):
    plan = parse_sexpr(Path(original).read_text(encoding='utf-8'))
    steps = section(plan, ':steps')
    if steps is None: raise Unsupported('Missing plan steps')
    def one(call):
        if call[0] == 'non-executed': return ['non-executed', one(call[1])]
        mapping = meta['action_maps'][source + ':' + call[0]]
        args = [terms[x] for x in call[1:]]
        return [mapping['name'], *[args[i] for i in mapping['order']]]
    out = ['define', ['plan', source + '_transport'], [':problem', source + '_mapped'],
           [':steps', *[one(c) for c in steps[1:]]]]
    Path(output).write_text(serialize(out) + '\n', encoding='utf-8')


def candidate_pairs(sources, max_predicates=8, max_actions=4):
    """Source-only coarse candidates; no goal, solution or semantic labels."""
    result = []
    def key(kind, refs): return kind[0] + '_' + hashlib.sha256('|'.join([kind, *refs]).encode()).hexdigest()[:16]
    def words(name): return set(name.replace('_', '-').split('-'))
    for left, right in itertools.combinations(sources, 2):
        pp, aa = [], []
        for n, p in left.domain.predicates.items():
            for m, q in right.domain.predicates.items():
                if p.arity != q.arity: continue
                refs = [left.id + ':' + n, right.id + ':' + m]
                pp.append({'id': key('predicate', refs), 'kind': 'predicate', 'references': refs,
                           'lexical_score': len(words(n) & words(m)) / max(1, len(words(n) | words(m)))})
        for n, a in left.domain.actions.items():
            for m, b in right.domain.actions.items():
                try:
                    fa, fb = action_fields(a), action_fields(b)
                    if len(typed_symbols(fa[':parameters'])) != len(typed_symbols(fb[':parameters'])): continue
                    ea, eb = signed_effects(fa[':effect']), signed_effects(fb[':effect'])
                    shape = lambda e: sorted((v, len(x) - 1) for v, x in e)
                    if shape(ea) != shape(eb): continue
                    if len(fa[':agents']) != len(fb[':agents']): continue
                except Unsupported: continue
                refs = [left.id + ':' + n, right.id + ':' + m]
                aa.append({'id': key('action', refs), 'kind': 'action', 'references': refs,
                           'lexical_score': len(words(n) & words(m)) / max(1, len(words(n) | words(m)))})
        pp.sort(key=lambda x: (-x['lexical_score'], x['id']))
        aa.sort(key=lambda x: (-x['lexical_score'], x['id']))
        result.append({'id': left.id + '__' + right.id, 'sources': [left.id, right.id],
                       'predicate_opportunities': len(pp), 'action_opportunities': len(aa),
                       'candidates': pp[:max_predicates] + aa[:max_actions]})
    return result

"""Pre-search Glaive union/alignment with scoped or shared native types.

Intentionality is retained, not projected into classical planning. Object
quantifiers and native axioms retain source-local scopes in the legacy mode.
An explicit type alignment instead gives native shared parameter, constant and
quantifier types, without object-origin permissions. Certificates here cover
physical transitions plus equal acting roles under their declared scope;
native intentional replay is a separate check, not an independent semantic label.
"""
from dataclasses import dataclass
import hashlib
import itertools
from pathlib import Path

from .conditional_merge import permutation, symbol_digest
from .domain_building import digest, save
from .pddl import parse_domain, parse_sexpr, section, serialize, typed_symbols
from .glaive_intake import (action_terms, ancestors, casefold_tree, check_declarations,
                            declarations, formula_terms, spelling_changes, type_graph,
                            axiom_fields, axiom_terms, quantified_types, feature_inventory,
                            predicate_atom, problem_intentions, typed_entries, consent_adaptation)


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
    constant_contract: dict[str, str] | None = None
    consent_policy: str | None = None

    def __post_init__(self):
        raw_domain = parse_sexpr(self.domain_path.read_text(encoding='utf-8'))
        raw_problem = parse_sexpr(self.problem_path.read_text(encoding='utf-8'))
        self.root, self.problem = casefold_tree(raw_domain), casefold_tree(raw_problem)
        source_features = feature_inventory(self.root, self.problem)
        self.self_type_declarations = [name for name, parent in typed_entries((section(self.root, ':types') or [':types'])[1:]) if name == parent]
        self.root, self.consent_adaptations = consent_adaptation(self.root, self.consent_policy)
        check_declarations(self.root, self.problem)
        self.domain = parse_domain(self.domain_path, root=self.root)
        allowed = {'domain', ':requirements', ':types', ':constants', ':predicates', ':action', ':axiom'}
        if any(x[0] not in allowed for x in self.root[1:] if isinstance(x, list) and x):
            raise Unsupported('Unsupported domain section')
        self.axioms = [x for x in self.root[1:] if isinstance(x, list) and x and x[0] == ':axiom']
        if section(self.problem, ':init') is None:
            raise Unsupported('needs_initial_state')
        if section(self.problem, ':goal') is None:
            raise Unsupported('Missing explicit goal')
        if any(x[0] not in {'problem', ':domain', ':requirements', ':objects', ':init', ':goal', ':intentionality'} for x in self.problem[1:]):
            raise Unsupported('Unsupported problem section')
        self.problem_intentions = problem_intentions(self.problem)
        predicate_names = set(self.domain.predicates)
        binding = section(self.problem, ':domain')
        if binding is not None and binding != [':domain', self.domain.name]:
            raise Unsupported('Problem domain reference does not match source')
        problem_requirements = set((section(self.problem, ':requirements') or [':requirements'])[1:])
        self.domain.requirements.update(problem_requirements)
        if any(x and x[0] in {'believes', 'delegated', 'increase', 'assign', 'decrease'}
               for root in (self.root, self.problem) for x in visit(root)):
            raise Unsupported('Belief, delegation or numeric updates unsupported')
        if any(t in {'expression', 'imposable'} for a in self.domain.actions.values()
               for t in typed_symbols(action_fields(a)[':parameters']).values()):
            raise Unsupported('Expression-valued parameters unsupported')
        for a in self.domain.actions.values(): action_fields(a)
        self.objects = declarations((section(self.problem, ':objects') or [':objects'])[1:], duplicates=True)
        self.type_parents = type_graph(self.root)
        self.types = set(self.type_parents)
        self.promoted_constants = {k.lower(): v.lower() for k, v in (self.constant_contract or {}).items()}
        if len(self.promoted_constants) != len(self.constant_contract or {}):
            raise Unsupported('Conflicting case-folded constant contract')
        domain_terms = {x for a in self.domain.actions.values() for x in action_terms(a, predicate_names=predicate_names) if not x.startswith('?')}
        domain_terms.update(x for a in self.axioms for x in axiom_terms(a, predicate_names=predicate_names) if not x.startswith('?'))
        for name, typ in self.promoted_constants.items():
            if name in self.domain.constants or name not in domain_terms:
                raise Unsupported('Constant contract must complete a referenced undeclared constant: ' + name)
            if self.objects.get(name) != typ:
                raise Unsupported('Constant contract disagrees with explicit problem object: ' + name)
        self.domain.constants.update(self.promoted_constants)
        for name in self.objects.keys() & self.domain.constants.keys():
            if self.objects[name] != self.domain.constants[name]:
                raise Unsupported('Conflicting constant/object type: ' + name)
        used_types = set(self.objects.values()) | set(self.domain.constants.values())
        used_types.update(quantified_types(self.root, predicate_names))
        used_types.update(quantified_types(self.problem, predicate_names))
        if used_types & {'expression', 'imposable'}:
            raise Unsupported('Expression-valued quantification unsupported')
        predicate_signatures = {}
        for pred in section(self.root, ':predicates')[1:]:
            signature = list(declarations(pred[1:]).items())
            predicate_signatures.setdefault(pred[0], []).append(signature)
            used_types.update(t for _, t in signature)
        for action in self.domain.actions.values():
            params = typed_symbols(action_fields(action)[':parameters'])
            used_types.update(params.values())
            for term in action_terms(action, predicate_names=predicate_names):
                if term not in (params if term.startswith('?') else self.domain.constants):
                    raise Unsupported('Unbound action term: ' + term)
        for axiom in self.axioms:
            params = declarations(axiom_fields(axiom)[':vars'])
            if any(not v.startswith('?') for v in params):
                raise Unsupported('Axiom requires variable declarations')
            used_types.update(params.values())
            for term in axiom_terms(axiom, predicate_names=predicate_names):
                if term not in (params if term.startswith('?') else self.domain.constants):
                    raise Unsupported('Unbound axiom term: ' + term)
        for typ in used_types:
            ancestors(typ, self.type_parents)
        for expr in [*section(self.problem, ':init')[1:], *self.problem_intentions, section(self.problem, ':goal')[1]]:
            for term in formula_terms(expr, predicate_names=predicate_names):
                if term not in self.objects and term not in self.domain.constants:
                    raise Unsupported('Undeclared problem object: ' + term)
        self.term_map = {x: self.id + '_o_' + x for x in self.domain.constants}
        self.normalization = {
            'policy': 'glaive_intake_round3_problem_intentions_declared_predicate_roles',
            'features': source_features,
            'domain_spelling': spelling_changes(raw_domain), 'problem_spelling': spelling_changes(raw_problem),
            'problem_requirements': sorted(problem_requirements),
            'problem_intentionality': {'declarations': self.problem_intentions,
                'export': 'Explicit initial intends literals; no inferred goals or actors',
                'scope': 'Dialect interpretation: stock reader ignores this section; not stock-reader behavior equivalence'},
            'reserved_predicate_atoms': sorted(predicate_names & {'exists', 'forall'}),
            'exported_problem_requirements': [':adl', ':intentionality'],
            'domain_reference': 'explicit' if binding is not None else 'caller_supplied_pair',
            'type_parents': {t: sorted(ps) for t, ps in sorted(self.type_parents.items())},
            'predicate_signatures': predicate_signatures,
            'promoted_constants': self.promoted_constants,
            'constant_completion_scope': 'Explicit caller contract; checked against this problem; no initial facts imported',
        }
        if self.self_type_declarations:
            self.normalization['type_self_inheritance'] = {
                'declarations': self.self_type_declarations,
                'policy': 'Omit reflexive graph edges, retain named types and all other parents; object remains universal root.',
                'real_cycles': 'rejected', 'new_types_or_objects_inferred': False}
        if self.consent_adaptations:
            self.normalization['action_consent'] = self.consent_adaptations

    def memberships(self, obj, typ):
        return [[self.id + '_type_' + t, obj] for t in sorted(ancestors(typ, self.type_parents))]


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
    """Capture-avoiding free-variable substitution, including nested binders."""
    def atoms(x):
        if isinstance(x, str): yield x
        else:
            for y in x: yield from atoms(y)
    occupied = set(atoms(expr)) | set(mapping) | set(mapping.values())
    def one(x, env):
        if isinstance(x, str): return env.get(x, x)
        if x and x[0] in ('forall', 'exists'):
            params = declarations(x[1])
            inner = {k: v for k, v in env.items() if k not in params}
            renamed = {}
            for v in params:
                if v in inner.values():
                    i = 0
                    while '?bound' + str(i) in occupied: i += 1
                    renamed[v] = '?bound' + str(i); occupied.add(renamed[v])
            inner.update(renamed)
            return [x[0], [renamed.get(t, t) for t in x[1]], one(x[2], inner)]
        return [one(y, env) for y in x]
    return one(expr, mapping)


def rewrite(expr, source, predicates, terms, *, context='condition', type_maps=None):
    if not isinstance(expr, list) or not expr: raise Unsupported('Malformed formula')
    head = expr[0]
    if predicate_atom(expr, predicates):
        target, order = predicates[head]
        args = [terms.get(x, x) for x in expr[1:]]
        if len(args) != len(order): raise Unsupported('Predicate arity mismatch')
        return [target, *[args[i] for i in order]]
    if head in {'forall', 'exists'}:
        if len(expr) != 3 or source is None: raise Unsupported('Malformed or unscoped quantifier')
        params = declarations(expr[1])
        if not params or any(not v.startswith('?') for v in params):
            raise Unsupported('Quantifier requires bound variables')
        if context == 'effect' and head != 'forall':
            raise Unsupported('Existential effects unsupported')
        guards = [[source.id + '_type_' + typ, v] for v, typ in params.items()]
        for typ in params.values(): ancestors(typ, source.type_parents)
        inner = {k: v for k, v in terms.items() if k not in params}
        body = rewrite(expr[2], source, predicates, inner, context=context, type_maps=type_maps)
        if type_maps is not None:
            return [head, [t for v, typ in params.items() for t in (v, '-', type_maps[source.id][typ])], body]
        if context == 'effect':
            if body[0] == 'when':
                body = ['when', conjunction([*guards, body[1]]), body[2]]
            else:
                body = ['when', conjunction(guards), body]
        elif head == 'forall':
            # This Glaive reader lacks an imply production; use its equivalent
            # Boolean form, including vacuous truth outside the source scope.
            body = ['or', ['not', conjunction(guards)], body]
        else:
            body = conjunction([*guards, body])
        return [head, [t for v in params for t in (v, '-', 'object')], body]
    if head == 'when':
        if len(expr) != 3: raise Unsupported('Malformed conditional effect')
        return ['when', rewrite(expr[1], source, predicates, terms, type_maps=type_maps),
                rewrite(expr[2], source, predicates, terms, context='effect', type_maps=type_maps)]
    if head == 'imply':
        if len(expr) != 3 or context == 'effect': raise Unsupported('Malformed implication or implication effect')
        return ['or', ['not', rewrite(expr[1], source, predicates, terms, type_maps=type_maps)],
                rewrite(expr[2], source, predicates, terms, type_maps=type_maps)]
    if head in {'and', 'or', 'not', 'imply', 'when'}:
        children = [rewrite(x, source, predicates, terms, context=context, type_maps=type_maps) for x in expr[1:]]
        # Glaive requires at least two operands for Boolean junctions.
        # A singleton is identical to its operand, including inside intentions
        # and conditional effects. Keep empty junctions for existing handling.
        if head in {'and', 'or'} and len(children) == 1:
            return children[0]
        return [head, *children]
    if head == 'intends':
        if len(expr) != 3: raise Unsupported('Malformed intention')
        return ['intends', terms.get(expr[1], expr[1]), rewrite(expr[2], source, predicates, terms, type_maps=type_maps)]
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


def build(sources, output, *, groups=(), merge_actions=False, threshold=.9, type_alignment=None):
    output = Path(output)
    if output.exists(): raise ValueError('Fresh merged output required')
    sources = {s.id: s for s in sources}
    native = None
    if type_alignment is not None:
        from .shared_types import SharedTypes
        native = SharedTypes.from_sources(list(sources.values()), type_alignment)
    type_maps = native.maps if native else None
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
    if native:
        requirements.add(':typing')
    constants, preds, actions, amap, axioms, axiom_maps = {}, {}, {}, {}, [], []
    native_signatures = {}
    native_parameter_tautologies = {}
    for sid, s in sources.items():
        # Some upstream models declare this feature without any axioms. Keep
        # their historical export byte-stable; enable it when closure is used.
        requirements.update(s.domain.requirements - {':domain-axioms'})
        if s.axioms: requirements.add(':domain-axioms')
        preds[sid + '_active'] = [sid + '_active']
        if not native:
            for typ in sorted(s.types): preds[sid + '_type_' + typ] = [sid + '_type_' + typ, '?x', '-', 'object']
        for name, p in s.domain.predicates.items():
            target, order = pmaps[sid][name]
            declaration = [target, *[x for i in range(p.arity) for x in ('?v' + str(i), '-', 'object')]]
            if target in preds and preds[target] != declaration: raise Unsupported('Shared arity disagreement')
            preds[target] = declaration
            if native:
                for signature in s.normalization['predicate_signatures'][name]:
                    types = [native.maps[sid][typ] for _, typ in signature]
                    native_signatures.setdefault(target, []).append([types[i] for i in order])
        for c, typ in s.domain.constants.items():
            constants[s.term_map[c]] = native.maps[sid][typ] if native else 'object'
        for name, action in s.domain.actions.items():
            f = action_fields(action); params = typed_symbols(f[':parameters'])
            aname = sid + '_a_' + name
            guards = [[sid + '_active']]
            if not native:
                guards.extend([[sid + '_type_' + typ, var] for var, typ in params.items()])
            pre = rewrite(f[':precondition'], s, pmaps[sid], s.term_map, type_maps=type_maps)
            eff = rewrite(f[':effect'], s, pmaps[sid], s.term_map, context='effect', type_maps=type_maps)
            agents = [s.term_map.get(x, x) for x in f[':agents']]
            if native:
                # Glaive rejects declared but unused parameters. Reflexive
                # equalities retain their binding positions without permissions
                # or any additional applicability restriction.
                names = {value[0] for value in pmaps[sid].values()}
                # Glaive's unused-parameter check ignores the :agents list.
                used = set(formula_terms(pre, predicate_names=names)) | set(formula_terms(eff, predicate_names=names))
                unused = [v for v in params if v not in used]
                guards.extend([['=', v, v] for v in unused])
                if unused:
                    native_parameter_tautologies[aname] = unused
            parameters = native.parameters(sid, params) if native else [x for v in params for x in (v, '-', 'object')]
            actions[aname] = [':action', aname, ':parameters', parameters,
                              ':precondition', conjunction([*guards, *([] if pre == ['and'] else [pre])])]
            if eff != ['and']: actions[aname] += [':effect', eff]
            if agents: actions[aname] += [':agents', agents]
            amap[sid + ':' + name] = {'name': aname, 'order': list(range(len(params)))}
        for index, axiom in enumerate(s.axioms):
            f = axiom_fields(axiom); params = declarations(f[':vars'])
            guards = [[sid + '_active']]
            if not native:
                guards.extend([[sid + '_type_' + typ, v] for v, typ in params.items()])
            pre = rewrite(f[':context'], s, pmaps[sid], s.term_map, type_maps=type_maps)
            eff = rewrite(f[':implies'], s, pmaps[sid], s.term_map, context='effect', type_maps=type_maps)
            axiom_maps.append({'source': sid, 'source_index': index, 'exported_index': len(axioms)})
            parameters = native.parameters(sid, params) if native else [t for v in params for t in (v, '-', 'object')]
            axioms.append([':axiom', ':vars', parameters,
                           ':context', conjunction([*guards, *([] if pre == ['and'] else [pre])]),
                           ':implies', eff])
    if native:
        for target, signatures in native_signatures.items():
            signature = [native.common_parent(column) for column in zip(*signatures)]
            preds[target] = [target, *[x for i, typ in enumerate(signature) for x in ('?v' + str(i), '-', typ)]]
    fused = set()
    for group in groups:
        if group_kind(group) != 'action' or not merge_actions: continue
        row = {'id': group['id'], 'kind': 'action', 'status': 'retained_separate'}
        try:
            if not accepted(group, 'action', sources, threshold): raise Unsupported('Semantic gate not accepted')
            refs = [m['action'] for m in group['members']]
            if any(sources[r.split(':')[0]].axioms for r in refs):
                raise Unsupported('Native axiom source actions retained; fusion certificate not extended')
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
            if native:
                type_signatures = [typed_symbols(v[':parameters']) for v in variants]
                if any(t != type_signatures[0] for t in type_signatures):
                    raise Unsupported('Different shared parameter types; retain separately typed variants')
            name = 'fused_' + group['id']; arity = len(typed_symbols(variants[0][':parameters']))
            parameters = [x for i in range(arity) for x in ('?m' + str(i), '-',
                          type_signatures[0]['?m' + str(i)] if native else 'object')]
            actions[name] = [':action', name, ':parameters', parameters,
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
    model = ['define', ['domain', 'revised_merged'], [':requirements', *sorted(requirements)],
             [':types', *(native.declarations() if native else [])],
             [':constants', *[x for c, typ in constants.items() for x in (c, '-', typ)]],
             [':predicates', *preds.values()], *axioms, *actions.values()]
    if not constants: model.pop(4)
    output.mkdir(parents=True)
    (output / 'domain.pddl').write_text(serialize(model) + '\n', encoding='utf-8')
    meta = {'source_sha256': {sid: {'domain': digest(s.domain_path), 'problem': digest(s.problem_path)} for sid, s in sources.items()},
            'predicate_maps': pmaps, 'action_maps': amap, 'decisions': decisions,
            'constant_maps': {sid: s.term_map for sid, s in sources.items()},
            'normalization': {sid: s.normalization for sid, s in sources.items()},
            'source_action_count': sum(len(s.domain.actions) for s in sources.values()), 'action_count': len(actions),
            'business_predicate_count': len({v[0] for p in pmaps.values() for v in p.values()}),
            'intentionality_retained': True, 'axioms_supported': True,
            'axiom_count': len(axioms), 'axiom_maps': axiom_maps,
            'axiom_scope': 'Native source-scoped closure; action fusion involving axiom sources disabled',
            'scope': 'Parameterized domain constructed before search. Source worlds mapped separately; no pooled facts.'}
    if native:
        meta.update(type_encoding='native_shared', type_maps=native.maps,
                    native_parameter_tautologies=native_parameter_tautologies,
                    shared_type_parents=native.parents, shared_constant_types=constants,
                    type_alignment=type_alignment,
                    axiom_scope='Native shared-type closure; action fusion involving axiom sources disabled',
                    scope='Parameterized shared-type domain constructed before search. Object origins do not restrict action bindings. '
                          'Mapped types govern parameters, constants and quantifiers. This deliberately expands source universes; '
                          'the source-local exact-membership preservation theorem does not apply without its original-world assumptions.')
        meta['compiled_domain_sha256'] = digest(output / 'domain.pddl')
    save(output / 'mapping.json', meta)
    return meta


def map_problem(sources, source_id, meta, path):
    sources = {s.id: s for s in sources}; s = sources[source_id]
    native_maps = meta.get('type_maps') if meta.get('type_encoding') == 'native_shared' else None
    terms = {**s.term_map, **{o: source_id + '_o_' + o for o in s.objects}}
    objects = [x for o, typ in s.objects.items() if o not in s.domain.constants
               for x in (terms[o], '-', native_maps[source_id][typ] if native_maps else 'object')]
    init = [[source_id + '_active']]
    if not native_maps:
        for sid, other in sources.items():
            for c, typ in other.domain.constants.items(): init.extend(other.memberships(other.term_map[c], typ))
        for o, typ in s.objects.items():
            if o not in s.domain.constants: init.extend(s.memberships(terms[o], typ))
    initial = list(section(s.problem, ':init')[1:])
    initial += [e for e in s.problem_intentions if e not in initial]
    init += [rewrite(e, s, meta['predicate_maps'][source_id], terms, type_maps=native_maps) for e in initial]
    goal = rewrite(section(s.problem, ':goal')[1], s, meta['predicate_maps'][source_id], terms, type_maps=native_maps)
    root = ['define', ['problem', source_id + '_mapped'], [':domain', 'revised_merged'],
            [':requirements', ':adl', ':intentionality'],
            [':objects', *objects], [':init', *init], [':goal', goal]]
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    Path(path).write_text(serialize(root) + '\n', encoding='utf-8')
    return terms


def translate_plan(source, meta, terms, original, output):
    plan = casefold_tree(parse_sexpr(Path(original).read_text(encoding='utf-8')))
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

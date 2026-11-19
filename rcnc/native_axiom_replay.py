"""Independent physical replay for finite Glaive state-update axioms.

Native ``:axiom`` rules update ordinary state after initialization and each
action. They are different from PDDL ``:derived`` predicates. Applicable
contexts are selected at the start of each round. A round is accepted only
when its ordinary effects are independent of the order in which they run.
"""

from itertools import product

from .glaive_intake import ancestors, axiom_fields, declarations, type_graph
from .pddl import section


class UnsupportedAxiomReplay(ValueError):
    """A trace whose physical state cannot be certified by this checker."""


def _fields(tree, name):
    return (section(tree, name) or [name])[1:]


def _form(expr):
    if not isinstance(expr, list) or not expr or not isinstance(expr[0], str):
        raise UnsupportedAxiomReplay('Expected a PDDL formula')
    return expr[0], expr[1:]


def _conjuncts(expr):
    if expr[0] == 'and':
        for child in expr[1:]:
            yield from _conjuncts(child)
    else:
        yield expr


def _effect_literals(expr, clauses=(), *, quantified=False):
    head, args = _form(expr)
    if head == 'and':
        for child in args:
            yield from _effect_literals(child, clauses, quantified=quantified)
    elif head == 'when' and len(args) == 2:
        yield from _effect_literals(args[1], (*clauses, ('when', args[0])), quantified=quantified)
    elif head == 'forall' and quantified:
        if len(args) != 2:
            raise UnsupportedAxiomReplay('Malformed quantified action effect')
        params = declarations(args[0])
        if not params or any(not name.startswith('?') for name in params):
            raise UnsupportedAxiomReplay('Malformed quantified effect binder')
        yield from _effect_literals(args[1], (*clauses, ('forall', params)), quantified=quantified)
    else:
        positive = head != 'not'
        if not positive and len(args) != 1:
            raise UnsupportedAxiomReplay('Malformed negative effect')
        yield clauses, positive, expr if positive else args[0]


def _combine(kind, children, *, preserve_supports=False):
    identity = kind == 'and'
    retained = []
    decisive = False
    for child in children:
        if isinstance(child, bool):
            decisive |= child != identity
        else:
            retained.append(child)
    if decisive and preserve_supports and not identity and retained:
        return (kind, True, *retained)
    if decisive:
        return not identity
    if not retained:
        return identity
    return retained[0] if len(retained) == 1 else (kind, *retained)


def _holds(expr, state):
    if isinstance(expr, bool):
        return expr
    head, *args = expr
    if head == 'and':
        return all(_holds(x, state) for x in args)
    if head == 'or':
        return any(_holds(x, state) for x in args)
    if head == 'not':
        return not _holds(args[0], state)
    return expr in state


def _reads(expr):
    if not isinstance(expr, bool):
        if expr[0] in ('and', 'or', 'not'):
            for child in expr[1:]:
                yield from _reads(child)
        else:
            yield expr


def _nonredundant_effects(effects):
    # A guarded write cannot change the final state if the same write is
    # unconditional and there is no possible opposite write in the update.
    # Keep the unconditional write so other guards still see its dependency.
    unconditional = {(positive, atom) for guard, positive, atom in effects if guard is True}
    potential_writes = {(positive, atom) for _, positive, atom in effects}
    return [(guard, positive, atom) for guard, positive, atom in effects
            if guard is True or (positive, atom) not in unconditional
            or (not positive, atom) in potential_writes]


def _update(state, effects, observe=None):
    effects = _nonredundant_effects(effects)
    # A Glaive effect guard can read the state as effects are imposed. Reject
    # rounds where a write could change any guard, including a false guard.
    possible_changes = {atom for _, positive, atom in effects if (atom in state) != positive}
    if possible_changes and any(possible_changes.intersection(_reads(guard)) for guard, _, _ in effects):
        raise UnsupportedAxiomReplay('Order-sensitive conditional effect')
    adds, deletes = set(), set()
    for guard, positive, atom in effects:
        if _holds(guard, state):
            (adds if positive else deletes).add(atom)
    if adds & deletes:
        raise UnsupportedAxiomReplay('Conflicting adds and deletes in one update')
    if observe is not None:
        observe(state, effects, adds, deletes)
    return (state - deletes) | adds, adds, deletes


class _Grounder:
    def __init__(self, domain, problem, *, preserve_supports=False):
        self.preserve_supports = preserve_supports
        self.objects = declarations(_fields(domain, ':constants') + _fields(problem, ':objects'))
        parents = type_graph(domain)
        self.object_types = {obj: ancestors(typ, parents) for obj, typ in self.objects.items()}
        self.by_type = {typ: tuple(obj for obj, types in self.object_types.items() if typ in types)
                        for typ in parents}
        self.predicates = {p[0]: tuple(declarations(p[1:]).values()) for p in _fields(domain, ':predicates')}
        self.remaining = 2_000_000
        self.initial, self.explicit_negative = set(), set()
        if section(problem, ':init') is None:
            raise UnsupportedAxiomReplay('needs_initial_state')
        for fact in _fields(problem, ':init'):
            head, args = _form(fact)
            if head == 'intends':
                continue
            if head == 'not' and len(args) == 1:
                self.explicit_negative.add(self.atom(args[0], {}))
            else:
                self.initial.add(self.atom(fact, {}))
        if self.initial & self.explicit_negative:
            raise UnsupportedAxiomReplay('Contradictory explicit initial facts')

    def atom(self, expr, bindings):
        head, args = _form(expr)
        types = self.predicates.get(head)
        if types is None or len(args) != len(types):
            raise UnsupportedAxiomReplay(f'Undeclared or malformed physical predicate: {head}')
        terms = tuple(self.term(x, bindings) for x in args)
        if any(typ not in self.object_types[obj] for obj, typ in zip(terms, types)):
            raise UnsupportedAxiomReplay(f'Ill-typed predicate arguments: {head}')
        return (head, *terms)

    def term(self, term, bindings):
        if not isinstance(term, str):
            raise UnsupportedAxiomReplay('Non-object term')
        value = bindings.get(term, term)
        if value not in self.objects:
            raise UnsupportedAxiomReplay(f'Unknown object or unbound variable: {term}')
        return value

    def bindings(self, params, domains=None):
        if domains is None:
            domains = [self.by_type[typ] for typ in params.values()]
        for values in product(*domains):
            self.remaining -= 1
            if self.remaining < 0:
                raise UnsupportedAxiomReplay('Grounding work limit')
            yield dict(zip(params, values))

    def condition(self, expr, bindings):
        head, args = _form(expr)
        if head in ('and', 'or'):
            return _combine(head, (self.condition(x, bindings) for x in args),
                            preserve_supports=self.preserve_supports)
        if head == 'not' and len(args) == 1:
            child = self.condition(args[0], bindings)
            return not child if isinstance(child, bool) else ('not', child)
        if head == '=' and len(args) == 2:
            return self.term(args[0], bindings) == self.term(args[1], bindings)
        if head in ('forall', 'exists') and len(args) == 2:
            kind = 'and' if head == 'forall' else 'or'
            return _combine(kind, (self.condition(args[1], bindings | local)
                                   for local in self.bindings(declarations(args[0]))),
                            preserve_supports=self.preserve_supports)
        atom = self.atom(expr, bindings)
        return atom if head in self.written else atom in self.initial

    def effects(self, literals, bindings):
        result = []
        for clauses, positive, expr in literals:
            for scope, guards in self.effect_instances(clauses, bindings):
                guard = _combine('and', guards)
                if expr[0] == 'intends' and len(expr) == 3:
                    # Modal writes do not affect the ordinary state because
                    # physical conditions reject modal reads.
                    self.term(expr[1], scope)
                    continue
                atom = self.atom(expr, scope)
                if guard is not False:
                    result.append((guard, positive, atom))
        return result

    def effect_instances(self, clauses, bindings, guards=()):
        if not clauses:
            yield bindings, guards
            return
        (kind, value), *rest = clauses
        if kind == 'when':
            # Ground a guard before crossing any inner quantifier that can
            # shadow variables in this scope.
            guard = self.condition(value, bindings)
            yield from self.effect_instances(rest, bindings, (*guards, guard))
        else:
            for local in self.bindings(value):
                yield from self.effect_instances(rest, bindings | local, guards)

    def axiom_bindings(self, params, context):
        # Compiler-generated type/source guards are ordinary immutable facts.
        # A required static guard can remove candidates before taking products.
        domains = {name: self.by_type[typ] for name, typ in params.items()}
        if not params:
            raise UnsupportedAxiomReplay('Zero-parameter native axiom outside this fragment')
        for expr in _conjuncts(context):
            head, args = _form(expr)
            if head not in self.predicates or head in self.written:
                continue
            if not args and self.atom(expr, {}) not in self.initial:
                return
            if len(args) == 1 and isinstance(args[0], str) and args[0] in domains:
                var = args[0]
                domains[var] = tuple(obj for obj in domains[var] if (head, obj) in self.initial)
        yield from self.bindings(params, domains.values())

    def inactive_source_guard(self, context):
        return any(len(atom) == 1 and isinstance(atom[0], str) and atom[0].endswith('_active')
                   and atom[0] in self.predicates and atom[0] not in self.written
                   and self.atom(atom, {}) not in self.initial
                   for atom in _conjuncts(context))


def _close(state, rules, observe=None):
    seen = {frozenset(state)}
    for rounds in range(256):
        active = [(context, rule) for context, rule in rules if _holds(context, state)]
        effects = [effect for _, rule in active for effect in rule]
        after, adds, deletes = _update(state, effects)
        if after == state:
            return after, rounds
        if observe is not None:
            retained = set(_nonredundant_effects(effects))
            supported = [(_combine('and', (context, guard)), positive, atom)
                         for context, rule in active for guard, positive, atom in rule
                         if (guard, positive, atom) in retained]
            observe(state, supported, adds, deletes)
        key = frozenset(after)
        if key in seen:
            raise UnsupportedAxiomReplay('Cyclic native axiom updates')
        seen.add(key)
        state = after
    raise UnsupportedAxiomReplay('Native axiom closure round limit')


def replay_native_axioms(domain, problem, plan, *, quantified_action_effects=False,
                         observer=None):
    """Replay the saved action sequence without invoking a planner."""
    problem_name = _fields(problem, 'problem')
    if len(problem_name) != 1 or _fields(plan, ':problem') != problem_name:
        raise UnsupportedAxiomReplay('Plan problem mismatch')
    if section(plan, ':steps') is None or section(problem, ':goal') is None:
        raise UnsupportedAxiomReplay('Missing saved plan steps or goal')
    grounder = _Grounder(domain, problem, preserve_supports=observer is not None)
    actions = {x[1]: dict(zip(x[2::2], x[3::2])) for x in domain
               if isinstance(x, list) and x and x[0] == ':action'}
    axioms = [axiom_fields(x) for x in domain if isinstance(x, list) and x and x[0] == ':axiom']
    calls = []
    for name, *args in _fields(plan, ':steps'):
        if name not in actions:
            raise UnsupportedAxiomReplay(f'Unknown or counterfactual plan step: {name}')
        action = actions[name]
        params = declarations(action[':parameters'])
        if len(args) != len(params) or any(obj not in grounder.by_type[typ]
                                          for obj, typ in zip(args, params.values())):
            raise UnsupportedAxiomReplay(f'Wrong arity or type for action: {name}')
        calls.append((name, action[':precondition'], dict(zip(params, args)),
                      list(_effect_literals(action[':effect'], quantified=quantified_action_effects))))
    templates = [(declarations(a[':vars']), a[':context'], list(_effect_literals(a[':implies'])))
                 for a in axioms]
    writes = [literals for _, _, literals in templates] + [literals for _, _, _, literals in calls]
    grounder.written = {_form(atom)[0] for literals in writes for _, _, atom in literals}

    rules = []
    source_disabled = 0
    for params, context, literals in templates:
        if grounder.inactive_source_guard(context):
            source_disabled += 1
            continue
        for bindings in grounder.axiom_bindings(params, context):
            guard = grounder.condition(context, bindings)
            if guard is not False:
                effects = grounder.effects(literals, bindings)
                if effects:
                    rules.append((guard, effects))
    goal = grounder.condition(_fields(problem, ':goal')[0], {})
    observe_axiom = observer.axiom if observer is not None else None
    state, rounds = _close(grounder.initial, rules, observe_axiom)
    initial_goal = _holds(goal, state)
    closure_rounds, applied = [rounds], []
    for index, (name, precondition, bindings, literals) in enumerate(calls):
        if not _holds(grounder.condition(precondition, bindings), state):
            return {'status': 'inapplicable', 'step': index, 'applied_steps': len(applied),
                    'initial_goal': initial_goal, 'axiom_closure_rounds': closure_rounds}
        observe_action = None
        if observer is not None:
            observer.action(index, name, bindings, state, grounder.condition)
            observe_action = observer.effect
        after, add, delete = _update(state, grounder.effects(literals, bindings), observe_action)
        state, rounds = _close(after, rules, observe_axiom)
        applied.append({'action': name, 'added': sorted(add), 'deleted': sorted(delete)})
        closure_rounds.append(rounds)
    if observer is not None:
        observer.goal(goal, state)
    return {'status': 'replayed', 'steps': len(applied), 'initial_goal': initial_goal,
            'goal': _holds(goal, state), 'applied': applied, 'grounded_physical_axioms': len(rules),
            'axiom_closure_rounds': closure_rounds, 'axiom_templates': len(templates),
            'source_disabled_axiom_templates': source_disabled,
            'explicit_negative_initial_facts': len(grounder.explicit_negative)}

"""Loss-aware syntax intake for the supported Glaive merge fragment.

No file is modified. Constant completion requires a caller-supplied contract;
the helper below derives one only from agreeing explicit object declarations in
every supplied problem, never from initial facts or goals.
"""
from .pddl import parse_sexpr, section


def casefold_tree(tree):
    if isinstance(tree, str):
        return tree.lower()
    return [casefold_tree(x) for x in tree]


def read_tree(path):
    return casefold_tree(parse_sexpr(path.read_text(encoding='utf-8')))


def spelling_changes(tree):
    if isinstance(tree, str):
        return {tree: tree.lower()} if tree != tree.lower() else {}
    result = {}
    for child in tree:
        result.update(spelling_changes(child))
    return result


def typed_entries(tokens):
    """Preserve repeated declarations instead of overwriting their types."""
    pending, entries = [], []
    tokens = list(tokens)
    i = 0
    while i < len(tokens):
        token = tokens[i]
        if not isinstance(token, str):
            raise ValueError('Compound types unsupported')
        if token == '-':
            if not pending or i + 1 == len(tokens) or not isinstance(tokens[i + 1], str) or tokens[i + 1] == '-':
                raise ValueError('Malformed typed declaration')
            entries.extend((name, tokens[i + 1]) for name in pending)
            pending = []
            i += 2
        else:
            pending.append(token)
            i += 1
    entries.extend((name, 'object') for name in pending)
    return entries


def declarations(tokens, *, duplicates=False):
    result = {}
    for name, typ in typed_entries(tokens):
        if name in result and (not duplicates or result[name] != typ):
            raise ValueError('Conflicting or duplicate declaration: ' + name)
        result[name] = typ
    return result


def type_graph(root):
    parents = {'object': set()}
    for name, parent in typed_entries((section(root, ':types') or [':types'])[1:]):
        parents.setdefault(name, set())
        parents.setdefault(parent, set())
        # Subtyping is reflexive. A self edge contributes no new membership;
        # retain the declared type and its other parents, not a graph cycle.
        if name == parent:
            continue
        if name == 'object':
            raise ValueError('Universal object type cannot have a parent')
        parents[name].add(parent)
    # A name appearing only as a parent still denotes a type rooted at object.
    for name, edges in parents.items():
        if name != 'object' and not edges:
            edges.add('object')
    active, complete = set(), set()

    def check(name):
        if name in active:
            raise ValueError('Cyclic source type hierarchy')
        if name in complete:
            return
        active.add(name)
        for parent in parents[name]:
            check(parent)
        active.remove(name)
        complete.add(name)

    for name in parents:
        check(name)
    return parents


def consent_adaptation(root, policy=None):
    """Opt-in dialect interpretation: explicit consenters must be agents.

    The native reader ignores :consent. This is not equivalence to that
    reader: preserve the union of explicit acting and consenting roles,
    without inferring intentions or modifying preconditions/effects.
    """
    if policy not in (None, 'require_intentional_agents'):
        raise ValueError('Unknown consent interpretation policy')
    changes, adapted = [], []
    for action in root:
        if not isinstance(action, list) or not action or action[0] != ':action' or ':consent' not in action[2:]:
            adapted.append(action)
            continue
        if policy is None:
            raise ValueError('Explicit consent interpretation policy required')
        keys = action[2::2]
        if len(action[2:]) % 2 or any(not isinstance(k, str) for k in keys) or len(set(keys)) != len(keys):
            raise ValueError('Malformed action fields')
        fields = dict(zip(keys, action[3::2]))
        actors, consenters = fields.get(':agents', []), fields[':consent']
        for roles in (actors, consenters):
            if not isinstance(roles, list) or any(not isinstance(x, str) for x in roles):
                raise ValueError('Agents and consent require flat term lists')
            if len(set(roles)) != len(roles):
                raise ValueError('Duplicate agent or consent role')
        effective = list(dict.fromkeys([*actors, *consenters]))
        rewritten = action[:2]
        for key, value in fields.items():
            if key == ':consent': continue
            rewritten.extend([key, effective if key == ':agents' else value])
        if ':agents' not in fields: rewritten.extend([':agents', effective])
        adapted.append(rewritten)
        changes.append({'action': action[1], 'agents': actors, 'consent': consenters,
                        'effective_agents': effective, 'policy': policy,
                        'scope': 'Explicit dialect interpretation; native reader ignores consent; not native-reader behavior equivalence.'})
    return adapted, changes


def ancestors(typ, parents):
    if typ not in parents:
        raise ValueError('Undeclared source type: ' + typ)
    found, pending = set(), [typ]
    while pending:
        name = pending.pop()
        if name not in found:
            found.add(name)
            pending.extend(parents[name])
    return found


def predicate_atom(expr, predicate_names):
    """Declared flat predicate calls win over identically named operators.

    Quantifier binders and bodies are lists; an atom such as (exists city)
    remains an ordinary predicate when the domain explicitly declares it.
    """
    return (isinstance(expr, list) and bool(expr) and isinstance(expr[0], str) and expr[0] in predicate_names
            and all(isinstance(x, str) for x in expr[1:]))


def problem_intentions(problem):
    declarations_ = [x for x in problem[1:] if isinstance(x, list) and x and x[0] == ':intentionality']
    if len(declarations_) > 1:
        raise ValueError('Duplicate problem intentionality section')
    intentions = declarations_[0][1:] if declarations_ else []
    for intention in intentions:
        if (not isinstance(intention, list) or len(intention) != 3 or intention[0] != 'intends'
                or not isinstance(intention[1], str) or not isinstance(intention[2], list)):
            raise ValueError('Problem intentionality requires explicit intends declarations')
        if ['not', intention] in (section(problem, ':init') or [':init'])[1:]:
            raise ValueError('Problem intention contradicts explicit initial state')
    return intentions


def formula_terms(expr, bound=frozenset(), *, predicate_names=frozenset()):
    """Free variables and objects, respecting nested quantifier scopes."""
    if not isinstance(expr, list) or not expr:
        raise ValueError('Malformed formula')
    head = expr[0]
    if predicate_atom(expr, predicate_names):
        yield from (x for x in expr[1:] if x not in bound)
    elif head in {'forall', 'exists'}:
        if len(expr) != 3:
            raise ValueError('Malformed quantifier')
        variables = declarations(expr[1])
        if not variables or any(not v.startswith('?') for v in variables):
            raise ValueError('Quantifier requires bound variables')
        yield from formula_terms(expr[2], bound | variables.keys(), predicate_names=predicate_names)
    elif head in {'and', 'or', 'not', 'imply', 'when'}:
        for child in expr[1:]:
            yield from formula_terms(child, bound, predicate_names=predicate_names)
    elif head == 'intends':
        if len(expr) != 3 or not isinstance(expr[1], str):
            raise ValueError('Malformed intention')
        if expr[1] not in bound:
            yield expr[1]
        yield from formula_terms(expr[2], bound, predicate_names=predicate_names)
    else:
        for term in expr[1:]:
            if not isinstance(term, str):
                raise ValueError('Nested terms outside supported fragment')
            if term not in bound:
                yield term


def quantified_types(expr, predicate_names=frozenset()):
    if not isinstance(expr, list) or not expr:
        return set()
    if expr[0] == ':predicates' or predicate_atom(expr, predicate_names):
        return set()
    if expr[0] in ('forall', 'exists'):
        if len(expr) != 3:
            raise ValueError('Malformed quantifier')
        return set(declarations(expr[1]).values()) | quantified_types(expr[2], predicate_names)
    return set().union(*(quantified_types(x, predicate_names) for x in expr if isinstance(x, list)))


def axiom_fields(axiom):
    if len(axiom[1:]) % 2 or len(set(axiom[1::2])) != len(axiom[1::2]):
        raise ValueError('Malformed axiom fields')
    fields = dict(zip(axiom[1::2], axiom[2::2]))
    if set(fields) - {':vars', ':context', ':implies'} or ':implies' not in fields:
        raise ValueError('Unsupported or missing axiom fields')
    return {':vars': [], ':context': ['and'], **fields}


def axiom_terms(axiom, *, predicate_names=frozenset()):
    fields = axiom_fields(axiom)
    for key in (':context', ':implies'):
        yield from formula_terms(fields[key], predicate_names=predicate_names)


def feature_inventory(*roots):
    """Collect language features even when a later admission check fails."""
    from collections import Counter
    counts = Counter()
    special_types = set()
    unknown_fields = set()
    predicate_names = {p[0] for root in roots for p in (section(root, ':predicates') or [':predicates'])[1:]}

    def walk(expr):
        if not isinstance(expr, list) or not expr:
            return
        head = expr[0]
        if head == ':predicates' or predicate_atom(expr, predicate_names):
            return
        if isinstance(head, str) and head in {'forall', 'exists', 'when', 'intends', 'believes',
                                             'delegated', 'increase', 'assign', 'decrease', ':axiom'}:
            counts[head] += 1
        if head == ':action' and ':fail' in expr:
            counts[':fail'] += 1
        if head == ':action' and ':consent' in expr:
            counts[':consent'] += 1
        if head == ':action':
            unknown_fields.update(x for x in expr[2:] if isinstance(x, str) and x.startswith(':')
                                  and x not in {':parameters', ':precondition', ':effect', ':agents', ':consent'})
        for i, token in enumerate(expr[:-1]):
            if token == '-' and isinstance(expr[i + 1], str) and expr[i + 1] in {'expression', 'imposable'}:
                special_types.add(expr[i + 1])
        for child in expr:
            walk(child)
    for root in roots:
        walk(root)
    return {'construct_counts': dict(sorted(counts.items())), 'special_parameter_types': sorted(special_types),
            'unknown_action_fields': sorted(unknown_fields)}


def action_terms(action, *, predicate_names=frozenset()):
    if len(action[2:]) % 2:
        raise ValueError('Malformed action fields')
    fields = dict(zip(action[2::2], action[3::2]))
    for key in (':precondition', ':effect'):
        yield from formula_terms(fields.get(key, ['and']), predicate_names=predicate_names)
    yield from fields.get(':agents', [])
    yield from fields.get(':consent', [])


def constant_contract(domain_path, problem_paths):
    """Propose domain-local constants only when every registered task agrees.

    This is a documented completion of an underspecified source model, not a
    claim that the invalid raw domain had independently established semantics.
    """
    root = read_tree(domain_path)
    predicate_names = {p[0] for p in (section(root, ':predicates') or [':predicates'])[1:]}
    declared = declarations((section(root, ':constants') or [':constants'])[1:], duplicates=True)
    refs = set()
    for action in root[1:]:
        if isinstance(action, list) and action and action[0] == ':action':
            refs.update(x for x in action_terms(action, predicate_names=predicate_names) if not x.startswith('?'))
        elif isinstance(action, list) and action and action[0] == ':axiom':
            refs.update(x for x in axiom_terms(action, predicate_names=predicate_names) if not x.startswith('?'))
    needed = refs - set(declared)
    if not needed:
        return {}
    objects = [declarations((section(read_tree(p), ':objects') or [':objects'])[1:], duplicates=True)
               for p in problem_paths]
    if not objects:
        raise ValueError('Constant completion needs explicit problem declarations')
    result = {}
    for name in sorted(needed):
        types = {o.get(name) for o in objects}
        if None in types or len(types) != 1:
            raise ValueError('No consistent constant declaration across registered problems: ' + name)
        result[name] = types.pop()
    return result


def check_declarations(root, problem):
    """Reject ambiguous case-folded declarations before dictionary parsing."""
    for key in (':constants',):
        declarations((section(root, key) or [key])[1:], duplicates=True)
    declarations((section(problem, ':objects') or [':objects'])[1:], duplicates=True)
    seen = {}
    for pred in (section(root, ':predicates') or [':predicates'])[1:]:
        params = declarations(pred[1:])
        # Glaive source files overload predicate types. The merge encoding uses
        # object-valued predicates and source type guards; arity must agree.
        if pred[0] in seen and seen[pred[0]] != len(params):
            raise ValueError('Predicate overload arity mismatch: ' + pred[0])
        seen[pred[0]] = len(params)
    seen = set()
    for action in root[1:]:
        if isinstance(action, list) and action and action[0] == ':action':
            if action[1] in seen:
                raise ValueError('Duplicate action declaration: ' + action[1])
            seen.add(action[1])
            if ':parameters' in action:
                declarations(action[action.index(':parameters') + 1])

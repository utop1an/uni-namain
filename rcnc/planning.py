"""Small, bounded typed-STRIPS compiler and BFS reference planner.

Interfaces and source constant substitutions are explicit query assumptions.
This validates execution in that model, not the truth of those assumptions.
"""
from __future__ import annotations
import itertools
import json
import re
from collections import deque
from dataclasses import dataclass
from pathlib import Path
from merge_domains import parse_domain, parse_sexpr, serialize, typed_symbols
from rcnc.experiment import unsupported_logic, iter_raw_literals


@dataclass(frozen=True)
class GroundAction:
    name: str
    source: str
    original: str
    binding: dict[str, str]
    positive: frozenset[tuple[str, ...]]
    negative: frozenset[tuple[str, ...]]
    add: frozenset[tuple[str, ...]]
    delete: frozenset[tuple[str, ...]]


def compatible(actual, expected, types):
    seen = set()
    while actual not in seen:
        if actual == expected or expected == 'object':
            return True
        seen.add(actual)
        if actual not in types:
            break
        actual = types[actual]
    return False


def compile_query(query, input_dir):
    from rcnc.constraints import allowed_parameters
    parameter_domains = allowed_parameters(query, input_dir)
    for key, default in [('max_depth', 10), ('max_states', 50000), ('max_ground_actions', 10000)]:
        value = query.get(key, default)
        if type(value) is not int or value < (0 if key == 'max_depth' else 1):
            raise ValueError(f'Invalid budget: {key}')
    if not query.get('actions') or len(set(query['actions'])) != len(query['actions']):
        raise ValueError('Expected unique source action references')
    objects = query['objects']
    if any(not re.fullmatch(r'[a-z][a-z0-9_-]*', name) for name in objects):
        raise ValueError('Object names must be lowercase PDDL identifiers')
    if not objects or any(x.startswith('?') for x in objects):
        raise ValueError('Expected named, typed objects')
    types = {}
    schemas = []
    signatures = {}
    provenance = []
    used_interfaces = set()
    used_bindings = set()
    for ref in query['actions']:
        source, action_name = ref.split(':', 1)
        if not source or any(x in source for x in '/\\.'):
            raise ValueError('Invalid source identifier')
        source_path = input_dir / f'{source}_domainfile.pddl'
        root = parse_sexpr(source_path.read_text(encoding='utf-8'))
        allowed_sections = {'domain', ':requirements', ':types', ':constants', ':predicates', ':action'}
        if any(isinstance(part, list) and part and part[0] not in allowed_sections for part in root[1:]):
            raise ValueError(f'{source}: unsupported domain-level structure')
        domain = parse_domain(source_path, apply_reviewed_semantics=False)
        for name, parent in domain.types.items():
            if name in types and types[name] != parent:
                raise ValueError(f'Conflicting type hierarchy: {name}')
            types[name] = parent
        # Register the complete source vocabulary, including static query facts.
        for pred, declaration in domain.predicates.items():
            key = f'{source}:{pred}'
            entry = query.get('interfaces', {}).get(key)
            target = entry['target'] if entry else source.lower() + '__' + pred.lower()
            if entry:
                if not entry.get('evidence') or not re.fullmatch(r'[a-z][a-z0-9_-]*', target) or '__' in target:
                    raise ValueError(f'Invalid interface: {key}')
                used_interfaces.add(key)
            signature = tuple(t for _,t in declaration.parameters)
            if target in signatures and signatures[target] != signature:
                raise ValueError(f'Incompatible interface signatures: {target}')
            signatures[target] = signature
        raw = domain.actions[action_name]
        params = typed_symbols(raw[raw.index(':parameters') + 1]) if ':parameters' in raw else {}
        expressions = [raw[raw.index(k) + 1] if k in raw else ['and']
                       for k in (':precondition', ':effect')]
        for expr in expressions:
            reasons = unsupported_logic(expr)
            if reasons:
                raise ValueError(f'{ref}: unsupported logic {reasons}')
        literals = [list(iter_raw_literals(expr)) for expr in expressions]
        constants = {a for group in literals for _, args, _ in group for a in args if not a.startswith('?')}
        substitutions = {}
        for constant in sorted(constants):
            key = f'{source}:{constant}'
            if constant not in domain.constants:
                raise ValueError(f'{ref}: undeclared constant {constant}')
            if key not in query.get('constant_bindings', {}):
                raise ValueError(f'Missing explicit constant binding: {key}')
            obj = query['constant_bindings'][key]
            if obj not in objects or not compatible(objects[obj], domain.constants[constant], domain.types):
                raise ValueError(f'Invalid constant binding: {key} -> {obj}')
            substitutions[constant] = obj
            used_bindings.add(key)
        mapped = []
        for group in literals:
            output = []
            for pred, args, negated in group:
                if pred not in domain.predicates:
                    raise ValueError(f'{ref}: undeclared predicate {pred}')
                declaration = domain.predicates[pred]
                if len(args) != declaration.arity:
                    raise ValueError(f'{ref}: wrong arity {pred}')
                for arg, (_, expected) in zip(args, declaration.parameters):
                    actual = params.get(arg) if arg.startswith('?') else domain.constants.get(arg)
                    if actual is None or not compatible(actual, expected, domain.types):
                        raise ValueError(f'{ref}: unbound or ill-typed argument {arg} in {pred}')
                key = f'{source}:{pred}'
                entry = query.get('interfaces', {}).get(key)
                if entry:
                    if not entry.get('evidence'):
                        raise ValueError(f'Interface requires evidence: {key}')
                    target = entry['target']
                    if not re.fullmatch(r'[a-z][a-z0-9_-]*', target) or '__' in target:
                        raise ValueError('Interface target must be a lowercase identifier without reserved __')
                    used_interfaces.add(key)
                else:
                    target = source.lower() + '__' + pred.lower()
                signature = tuple(t for _, t in declaration.parameters)
                if target in signatures and signatures[target] != signature:
                    raise ValueError(f'Incompatible interface signatures: {target}')
                signatures[target] = signature
                output.append((target, tuple(substitutions.get(a, a) for a in args), negated))
            mapped.append(output)
        schemas.append((ref, params, mapped))
        provenance.append({'action': ref, 'constant_bindings': substitutions,
                           'parameter_constraints': query.get('parameter_constraints',{}).get(ref,{}),
                           'allowed_parameter_objects': parameter_domains.get(ref,{})})
    for name, parent in types.items():
        seen = {name}
        while parent != 'object':
            if parent in seen or parent not in types:
                raise ValueError(f'Invalid type hierarchy at {name}')
            seen.add(parent)
            parent = types[parent]
    if any(t != 'object' and t not in types for t in objects.values()):
        raise ValueError('Unknown object type')
    if set(query.get('interfaces', {})) != used_interfaces:
        raise ValueError('Unused interface declarations')
    if set(query.get('constant_bindings', {})) != used_bindings:
        raise ValueError('Unused constant bindings')
    actions = []
    limit = query.get('max_ground_actions', 10000)
    for ref, params, groups in schemas:
        choices = [[o for o, t in objects.items() if compatible(t, expected, types)
                    and o in parameter_domains.get(ref,{}).get(param,objects)]
                   for param,expected in params.items()]
        for values in itertools.product(*choices):
            if len(actions) >= limit:
                raise ValueError('Ground action budget exceeded')
            binding = dict(zip(params, values))
            split = []
            for group in groups:
                pos, neg = set(), set()
                for pred, args, negated in group:
                    fact = (pred, *(binding.get(a, a) for a in args))
                    (neg if negated else pos).add(fact)
                split.extend((frozenset(pos), frozenset(neg)))
            if split[0] & split[1]:
                continue
            actions.append(GroundAction(f'a{len(actions):05d}', ref.split(':')[0], ref, binding, *split))
    def facts(values):
        result = set()
        for value in values:
            fact = tuple(value)
            if not fact or fact[0] not in signatures or len(fact) - 1 != len(signatures[fact[0]]):
                raise ValueError(f'Unknown predicate or arity: {fact}')
            if any(o not in objects or not compatible(objects[o], expected, types)
                   for o, expected in zip(fact[1:], signatures[fact[0]])):
                raise ValueError(f'Unknown or ill-typed object: {fact}')
            result.add(fact)
        return frozenset(result)
    initial = facts(query['initial'])
    goal = facts(query['goal'].get('positive', []))
    negative_goal = facts(query['goal'].get('negative', []))
    if goal & negative_goal:
        raise ValueError('Contradictory goal')
    return actions, initial, goal, negative_goal, types, signatures, provenance


def replay(actions, initial, goal, negative_goal):
    state = initial
    trace = []
    for index, action in enumerate(actions):
        missing = action.positive - state
        forbidden = action.negative & state
        if missing or forbidden:
            return {'valid': False, 'failed_step': index, 'action': action.original,
                    'missing': sorted(missing), 'forbidden': sorted(forbidden), 'trace': trace}
        after = (state - action.delete) | action.add
        trace.append({'step': index, 'action': action.original, 'ground_action': action.name,
                      'binding': action.binding, 'before': sorted(state),
                      'after': sorted(after), 'added': sorted(after - state), 'deleted': sorted(state - after)})
        state = after
    return {'valid': goal <= state and not negative_goal & state,
            'missing_goals': sorted(goal - state), 'forbidden_goals': sorted(negative_goal & state),
            'final_state': sorted(state), 'trace': trace}


def solve(actions, initial, goal, negative_goal, max_depth=10, max_states=50000):
    queue = deque([(initial, [])])
    visited = {initial}
    cutoff = False
    while queue:
        state, plan = queue.popleft()
        if goal <= state and not negative_goal & state:
            return 'solved', plan, len(visited)
        if len(plan) >= max_depth:
            cutoff = True
            continue
        for action in actions:
            if action.positive <= state and not action.negative & state:
                after = (state - action.delete) | action.add
                if after not in visited:
                    if len(visited) >= max_states:
                        return 'state_limit', None, len(visited)
                    visited.add(after)
                    queue.append((after, plan + [action]))
    return ('depth_limit' if cutoff else 'unsolvable'), None, len(visited)


def write_pddl(output, query, actions, initial, goal, negative_goal, types, signatures):
    def conjunction(positive, negative):
        return ['and', *[list(f) for f in sorted(positive)], *[['not', list(f)] for f in sorted(negative)]]
    # Ground operators preserve query-wide constant substitutions and argument types.
    domain = ['define', ['domain', 'rcnc-query'], [':requirements', ':strips', ':typing', ':negative-preconditions'],
              [':types', *[x for t, parent in sorted(types.items()) for x in (t, '-', parent)]],
              [':constants', *[x for o, t in query['objects'].items() for x in (o, '-', t)]],
              [':predicates', *[[p, *[x for i,t in enumerate(ts) for x in (f'?x{i}', '-', t)]] for p,ts in sorted(signatures.items())]]]
    for a in actions:
        domain.append([':action', a.name, ':parameters', [], ':precondition', conjunction(a.positive, a.negative),
                       ':effect', conjunction(a.add, a.delete)])
    problem = ['define', ['problem', 'rcnc-query-problem'], [':domain', 'rcnc-query'],
               [':init', *[list(f) for f in sorted(initial)]], [':goal', conjunction(goal, negative_goal)]]
    (output/'domain.pddl').write_text(serialize(domain)+'\n', encoding='utf-8')
    (output/'problem.pddl').write_text(serialize(problem)+'\n', encoding='utf-8')


def run_query(query, input_dir, output):
    import hashlib
    import time
    start = time.perf_counter()
    output.mkdir(parents=True, exist_ok=True)
    if any(output.iterdir()):
        raise ValueError('Use an empty output directory to avoid mixing run artifacts')
    (output/'query.json').write_text(json.dumps(query, indent=2)+'\n', encoding='utf-8')
    if query.get('initial') is None:
        result={'status':'needs_initial_state','reason':'Please supply an explicit initial state before planning. No initial facts were generated.'}
        (output/'result.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
        return result
    selection = None
    try:
        resolved = query
        if 'sources' in query:
            from rcnc.selection import resolve_sources
            resolved, selection = resolve_sources(query, input_dir)
            (output/'resolved_query.json').write_text(json.dumps(resolved, indent=2)+'\n', encoding='utf-8')
        actions, initial, goal, ng, types, signatures, provenance = compile_query(resolved, input_dir)
        reduction = {'before':len(actions), 'after_goal_relevance':len(actions)}
        if query.get('selection_mode', 'all') == 'goal_relevance':
            from rcnc.selection import relevant_actions
            actions, reduction = relevant_actions(actions, initial, goal, ng)
        elif query.get('selection_mode', 'all') != 'all':
            raise ValueError('Unknown selection_mode')
        write_pddl(output, query, actions, initial, goal, ng, types, signatures)
        status, plan, explored = solve(actions, initial, goal, ng, query.get('max_depth', 10), query.get('max_states', 50000))
        result = {'status': status, 'ground_actions': len(actions), 'states_discovered': explored,
                  'provenance': provenance, 'validation': replay(plan, initial, goal, ng) if plan is not None else None,
                  'sources_used': sorted({a.source for a in plan}) if plan is not None else [],
                  'plan_length': len(plan) if plan is not None else None, 'reduction': reduction}
        (output/'plan.txt').write_text(''.join(f'({a.name})\n' for a in plan or []), encoding='utf-8')
        (output/'ground_actions.json').write_text(json.dumps([{'name': a.name, 'source_action': a.original, 'binding': a.binding} for a in actions], indent=2)+'\n', encoding='utf-8')
        if plan is not None:
            from rcnc.validation import validate_artifacts
            result['external_validation'] = validate_artifacts(output)
            if not result['validation']['valid']:
                result['status'] = 'internal_validation_failed'
            elif result['external_validation']['status'] in {'INVALID', 'ERROR'}:
                result['status'] = 'external_validation_failed'
            elif query.get('require_external_validation') and result['external_validation']['status'] != 'VALID':
                result['status'] = 'external_validation_unavailable'
    except (ValueError, KeyError) as exc:
        result = {'status': 'rejected', 'reason': str(exc)}
    result['selection'] = selection
    import platform
    result['runtime'] = {'python': platform.python_version(), 'platform': platform.platform()}
    result['implementation_sha256'] = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in [Path(__file__), Path(__file__).with_name('experiment.py'), Path(__file__).parents[1]/'merge_domains.py', Path(__file__).with_name('selection.py'), Path(__file__).with_name('validation.py'), Path(__file__).with_name('constraints.py')]}
    result['elapsed_seconds'] = time.perf_counter()-start
    result['query_sha256'] = hashlib.sha256(json.dumps(query, sort_keys=True).encode()).hexdigest()
    result['source_sha256'] = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(input_dir.glob('*_domainfile.pddl'))}
    result['scope'] = 'Explicit-interface typed STRIPS; independent validation status is reported separately. No narrative-quality evidence.'
    (output/'result.json').write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    return result

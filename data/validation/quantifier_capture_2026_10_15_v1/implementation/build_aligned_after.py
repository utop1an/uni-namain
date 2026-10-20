"""Pre-search predicate alignment under explicit, versioned assumptions.

Source types become static membership predicates. Action and quantifier guards
preserve each source universe; explicitly multi-typed request objects can later
participate in more than one source. Constant identities and action variants
remain separate. Structural acceptance is not a semantic-equivalence label.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import re

from build_narrative_union import build as build_union
from merge_domains import (Domain, Predicate, domain_summary, parse_domain,
                           parse_sexpr, section, serialize, typed_symbols,
                           validate_domain, write_domain)
from unified_planning.io import PDDLReader


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8')


def membership_facts(obj, typ, parents, guards):
    facts = []
    seen = set()
    while typ != 'object':
        if typ in seen or typ not in parents or typ not in guards:
            raise ValueError(f'Invalid source type ancestry: {typ}')
        seen.add(typ)
        facts.append([guards[typ], obj])
        typ = parents[typ]
    return facts


def freshen_quantifiers(expr, reserved=()):
    """Alpha-rename bound variables before moving effect conditions inward.

    A conditional outside a forall may refer to an action parameter or outer
    binder with the same spelling as the forall variable. Moving that condition
    under the binder without freshening changes its meaning.
    """
    occupied = {name.lower() for name in reserved}
    def collect(value):
        if isinstance(value, str) and value.startswith('?'):
            occupied.add(value.lower())
        elif isinstance(value, list):
            for child in value:
                collect(child)
    collect(expr)
    counter = 0
    def walk(value, scope):
        nonlocal counter
        if not isinstance(value, list):
            return scope.get(value.lower(), value) if isinstance(value, str) else value
        if value and value[0] in ('forall', 'exists'):
            updated = dict(scope)
            bindings = []
            for variable, typ in typed_symbols(value[1]).items():
                while f'?bound_scope_{counter}' in occupied:
                    counter += 1
                fresh = f'?bound_scope_{counter}'
                counter += 1
                occupied.add(fresh)
                updated[variable.lower()] = fresh
                bindings.extend([fresh, '-', typ])
            return [value[0], bindings, walk(value[2], updated)]
        return [walk(child, scope) for child in value]
    return walk(expr, {})


def build(inputs, output, specification):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    if specification.get('version') != 1 or specification.get('decision_basis') not in ('authored_assumption', 'reviewed_annotation'):
        raise ValueError('Alignment requires version 1 and an explicit decision_basis')
    baseline = output / 'source_union'
    report = build_union(inputs, baseline)
    if not report['valid']:
        raise ValueError('Source union did not parse independently')
    base = parse_domain(baseline / 'meta_domain.pddl', apply_reviewed_semantics=False)
    meta = json.loads((baseline / 'meta_domain.json').read_text(encoding='utf-8'))
    for name, expected in meta['source_sha256'].items():
        if name.endswith('_domainfile.pddl') and specification.get('source_sha256', {}).get(name) != expected:
            raise ValueError(f'Missing or stale source hash: {name}')
    types = {f'{source}:{name}': target for source, namespace in meta['namespaces'].items()
             for name, target in namespace['types'].items()}
    predicates = {f'{source}:{name}': target for source, table in meta['predicate_maps'].items()
                  for name, target in table.items()}
    parent = {target: target for target in types.values()}

    def find(value):
        while parent[value] != value:
            value = parent[value]
        return value

    for group in specification.get('type_groups', []):
        members = group.get('members', [])
        if not group.get('evidence') or len(members) < 2 or len(set(members)) != len(members):
            raise ValueError('Type correspondence requires distinct members and evidence')
        if any(member not in types for member in members):
            raise ValueError('Unknown type in correspondence')
        for member in members[1:]:
            parent[find(types[member])] = find(types[members[0]])
    transforms = {name: (name, list(range(pred.arity))) for name, pred in base.predicates.items()}
    assigned = set()
    identifiers = set()
    for group in specification.get('predicate_groups', []):
        name = group.get('id', '')
        members = group.get('members', [])
        if not re.fullmatch(r'[a-z][a-z0-9_]*', name) or name in identifiers:
            raise ValueError('Predicate group ids must be unique lowercase identifiers')
        identifiers.add(name)
        if not group.get('evidence') or len(members) < 2:
            raise ValueError('Predicate correspondence requires at least two members and evidence')
        source_names = []
        signature = None
        for member in members:
            ref = member.get('predicate')
            if ref not in predicates or ref in assigned:
                raise ValueError(f'Unknown or multiply assigned predicate: {ref}')
            assigned.add(ref)
            source_names.append(ref.split(':', 1)[0])
            pred = base.predicates[predicates[ref]]
            order = member.get('order')
            if not isinstance(order, list) or any(type(i) is not int for i in order) or sorted(order) != list(range(pred.arity)):
                raise ValueError(f'Expected a complete argument permutation: {ref}')
            aligned_types = [find(pred.parameters[i][1]) for i in order]
            if signature is not None and signature != aligned_types:
                raise ValueError(f'Missing explicit role-type correspondence: {ref}')
            signature = aligned_types
            transforms[predicates[ref]] = ('shared__p_' + name, order)
        if len(source_names) != len(set(source_names)):
            raise ValueError('A predicate group cannot collapse two predicates within one source')
    guards = {typ: 'typeguard__' + typ for typ in base.types}

    def typed(tokens):
        return [x for variable in typed_symbols(tokens) for x in (variable, '-', 'object')]

    def variable_guards(tokens):
        return [[guards[typ], variable] for variable, typ in typed_symbols(tokens).items()]

    def atom(expr):
        if not isinstance(expr, list) or not expr:
            raise ValueError('Expected a literal expression')
        if expr[0] == '=':
            return copy.deepcopy(expr)
        target, order = transforms[expr[0]]
        return [target, *[expr[1 + i] for i in order]]

    def condition(expr):
        head = expr[0]
        if head in ('and', 'or', 'not', 'imply'):
            return [head, *[condition(e) for e in expr[1:]]]
        if head in ('forall', 'exists'):
            bindings = variable_guards(expr[1])
            body = condition(expr[2])
            body = ['imply', ['and', *bindings], body] if head == 'forall' else ['and', *bindings, body]
            return [head, typed(expr[1]), body]
        return atom(expr)

    def effect(expr, conditions=()):
        head = expr[0]
        if head == 'and':
            return ['and', *[effect(e, conditions) for e in expr[1:]]]
        if head == 'forall':
            return ['forall', typed(expr[1]), effect(expr[2], (*conditions, *variable_guards(expr[1]))) ]
        if head == 'when':
            return effect(expr[2], (*conditions, condition(expr[1])))
        literal = ['not', atom(expr[1])] if head == 'not' else atom(expr)
        return ['when', ['and', *conditions], literal] if conditions else literal

    merged = Domain('narrative_aligned', base.requirements | {':adl'}, {},
                    {name: 'object' for name in base.constants}, {}, {}, set(meta['sources']))
    for name, pred in base.predicates.items():
        target, order = transforms[name]
        merged.predicates[target] = Predicate(target, [(f'?a{i}', 'object') for i in range(len(order))])
    for guard in guards.values():
        merged.predicates[guard] = Predicate(guard, [('?member', 'object')])
    for name, action in base.actions.items():
        fields = {action[i]: action[i+1] for i in range(2, len(action), 2)}
        if set(fields) - {':parameters', ':precondition', ':effect'}:
            raise ValueError(f'Unsupported action fields: {name}')
        parameters = fields.get(':parameters', [])
        scoped = freshen_quantifiers(['and', fields.get(':precondition', ['and']),
                                    fields.get(':effect', ['and'])], typed_symbols(parameters))
        merged.actions[name] = [':action', name, ':parameters', typed(parameters),
                                ':precondition', ['and', *variable_guards(parameters), condition(scoped[1])],
                                ':effect', effect(scoped[2])]
    merged.predicate_maps = {source: {name: transforms[target][0] for name, target in table.items()}
                             for source, table in meta['predicate_maps'].items()}
    merged.constant_maps = meta['constant_maps']
    merged.action_maps = meta['action_maps']
    errors = validate_domain(merged)
    if errors:
        raise ValueError(f'Compiled domain failed structural checks: {errors}')
    write_domain(merged, output / 'meta_domain.pddl')
    constants_memberships = [fact for name, typ in base.constants.items()
                            for fact in membership_facts(name, typ, base.types, guards)]
    rows = []
    (output / 'problems').mkdir()
    for problem_path in sorted((baseline / 'problems').glob('*.pddl')):
        root = parse_sexpr(problem_path.read_text(encoding='utf-8'))
        section(root, ':domain')[1] = merged.name
        objects = section(root, ':objects')
        memberships = copy.deepcopy(constants_memberships)
        if objects:
            for obj, typ in typed_symbols(objects[1:]).items():
                memberships.extend(membership_facts(obj, typ, base.types, guards))
            objects[1:] = typed(objects[1:])
        initial = section(root, ':init')
        initial[1:] = [condition(e) for e in initial[1:]] + memberships
        goal = section(root, ':goal'); goal[1] = condition(goal[1])
        destination = output / 'problems' / problem_path.name
        destination.write_text(serialize(root) + '\n', encoding='utf-8')
        PDDLReader().parse_problem(str(output / 'meta_domain.pddl'), str(destination))
        rows.append({'problem': destination.name, 'status': 'PARSED'})
    info = domain_summary(merged)
    info.update(method='explicit_predicate_alignment_with_type_membership',
                semantic_status='assumptions_not_independently_verified',
                type_encoding='static_membership', namespaces=meta['namespaces'],
                bound_variable_policy='capture_avoiding_alpha_renaming_before_effect_guard_relocation',
                source_type_parents=base.types, type_guards=guards,
                constant_membership_facts=constants_memberships, source_constant_types=base.constants,
                predicate_orders={source: {name: transforms[target][1] for name, target in table.items()}
                                  for source, table in meta['predicate_maps'].items()},
                source_predicate_types={source: {name: [t for _, t in base.predicates[target].parameters]
                                                for name, target in table.items()} for source, table in meta['predicate_maps'].items()},
                source_sha256=meta['source_sha256'], alignment_specification=specification,
                implementation_sha256={p.name: digest(p) for p in [Path(__file__), Path(__file__).with_name('build_narrative_union.py'),
                                                                   Path(__file__).with_name('merge_domains.py'), Path(__file__).with_name('pddl_checks.py')]})
    save(output / 'meta_domain.json', info)
    save(output / 'alignment_specification.json', specification)
    result = {'valid': True, 'problems': rows, 'counts': info['counts'],
              'scope': 'Structural and independent parsing checks under explicit alignment assumptions; no semantic correctness or narrative-quality claim'}
    save(output / 'validation.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input', type=Path, default=Path('data/narra-domains'))
    parser.add_argument('--alignment', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(build(args.input, args.output, json.loads(args.alignment.read_text(encoding='utf-8'))), indent=2))

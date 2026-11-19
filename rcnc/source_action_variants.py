"""Preserve complete source STRIPS actions under a fixed, explicit vocabulary.

This diagnostic compiler does not establish semantic equivalence of that
vocabulary. Its common type universe is explicit; quantified actions are rejected.
"""
import copy
import json
from collections import defaultdict
from pathlib import Path

from rcnc.domain_building import check_raw_declarations, require_empty_output, save
from rcnc.namespace_export import export_bundle, fold_symbol_map, inverse_maps, transform
from rcnc.pddl import parse_sexpr, section, serialize, typed_symbols


def ast(path):
    return parse_sexpr(Path(path).read_text(encoding='utf-8').lower())


def literals(expression):
    """Return signed atoms; fail closed outside conjunctive Boolean STRIPS."""
    if not isinstance(expression, list) or not expression:
        raise ValueError('Expected a STRIPS formula')
    if expression[0] == 'and':
        return [literal for child in expression[1:] for literal in literals(child)]
    negative = expression[0] == 'not'
    atom = expression[1] if negative and len(expression) == 2 else expression
    reserved = {'and', 'not', 'or', 'forall', 'exists', 'when', 'imply', '=', '>', '<', 'increase', 'assign'}
    if not atom or atom[0] in reserved or any(not isinstance(x, str) for x in atom):
        raise ValueError('Only conjunctive STRIPS literals are supported')
    return [(not negative, tuple(atom))]


def fields(action):
    if (len(action) - 2) % 2:
        raise ValueError('Malformed action')
    result = dict(zip(action[2::2], action[3::2]))
    if set(result) != {':parameters', ':precondition', ':effect'} or len(action) != 8:
        raise ValueError('Exactly parameters/precondition/effect required')
    literals(result[':precondition']); literals(result[':effect'])
    return result


def strict_parse(domain, problem=None):
    from unified_planning.environment import Environment
    from unified_planning.io import PDDLReader
    environment = Environment()
    environment.error_used_name = True
    return PDDLReader(environment=environment).parse_problem(str(domain), str(problem) if problem else None)


def build_variants(reference, source_paths, metadata, policy, output):
    """Build a reusable model before seeing any problem or planner result."""
    output = Path(output)
    require_empty_output(output)
    if policy not in {'all', 'has_only', 'no_share', 'without_has'}:
        raise ValueError('Unknown interface policy')
    base = ast(reference)
    check_raw_declarations(base, 'reference')
    header = ['define', *copy.deepcopy([p for p in base[1:] if p[0] != ':action'])]
    allowed = {'domain', ':requirements', ':types', ':constants', ':predicates', ':action'}
    if any(p[0] not in allowed for p in base[1:]):
        raise ValueError('Unsupported reference section')
    target_name = section(base, 'domain')[1]
    target_types = typed_symbols(section(base, ':types')[1:])
    target_constants = typed_symbols(section(base, ':constants')[1:])
    declarations = {p[0]: p for p in section(header, ':predicates')[1:]}
    aliases = defaultdict(set)
    predicate_maps = {s: fold_symbol_map(metadata['predicate_maps'][s]) for s in source_paths}
    for source, table in predicate_maps.items():
        for name in table.values(): aliases[name].add(source)
    shared = {name for name, owners in aliases.items() if len(owners) > 1}
    maps, ownership, mismatches, checks = {}, {}, [], []
    for source, path in source_paths.items():
        original = ast(path)
        check_raw_declarations(original, source)
        if any(p[0] not in allowed for p in original[1:]):
            raise ValueError('Unsupported source section')
        if set(section(original, ':requirements')[1:]) - {':strips', ':typing', ':negative-preconditions'}:
            raise ValueError('Unsupported source requirements')
        if typed_symbols(section(original, ':types')[1:]) != target_types:
            raise ValueError('Type hierarchies must agree explicitly')
        constants = fold_symbol_map(metadata['constant_maps'][source])
        source_constants = typed_symbols(section(original, ':constants')[1:])
        if set(constants) != set(source_constants) or any(target_constants.get(constants[n]) != t for n, t in source_constants.items()):
            raise ValueError('Incomplete or type-changing constant mapping')
        actions = [p for p in original[1:] if p[0] == ':action']
        used = {atom[0] for action in actions for key in (':precondition', ':effect')
                for _, atom in literals(fields(action)[key])}
        predicates = {p[0]: p for p in section(original, ':predicates')[1:]}
        table = dict(predicate_maps[source])
        if set(table) != set(predicates): raise ValueError('Incomplete predicate mapping')
        for name, declaration in predicates.items():
            target = table[name]
            split = target in shared and (policy == 'no_share' or policy == 'has_only' and target != 'has'
                                          or policy == 'without_has' and target == 'has')
            if split:
                target = 'src__' + source.lower() + '__' + name
                if target in declarations: raise ValueError('Private predicate collision')
                declarations[target] = [target, *copy.deepcopy(declaration[1:])]
                section(header, ':predicates').append(declarations[target])
                table[name] = target
            if target not in declarations: raise ValueError('Unknown mapped predicate')
            old_types = list(typed_symbols(declaration[1:]).values())
            new_types = list(typed_symbols(declarations[target][1:]).values())
            if old_types != new_types:
                mismatch = {'source': source, 'predicate': name, 'target': target,
                            'source_types': old_types, 'target_types': new_types, 'used_in_action': name in used}
                mismatches.append(mismatch)
                if name in used: raise ValueError('Used predicate mapping changes signature: ' + name)
        mapping = {'types': {t: t for t in [*target_types, 'object']}, 'objects': constants,
                   'predicates': table, 'actions': {a[1]: source.lower() + '__' + a[1] for a in actions},
                   'domains': {section(original, 'domain')[1]: target_name}}
        reverse = inverse_maps(mapping)
        maps[source] = mapping
        for action in actions:
            wrapper = ['define', ['domain', section(original, 'domain')[1]], action]
            translated = transform(wrapper, mapping)
            if transform(translated, reverse) != wrapper:
                raise ValueError('Action round trip differs')
            mapped = translated[2]
            header.append(mapped)
            ownership[mapped[1]] = {'source': source, 'source_action': action[1],
                                    'parameter_count': len(typed_symbols(fields(action)[':parameters']))}
            checks.append({'source': source, 'action': action[1], 'roundtrip_equal': True})
    output.mkdir(parents=True, exist_ok=True)
    raw = output / 'raw_domain.pddl'
    raw.write_text(serialize(header) + '\n', encoding='utf-8')
    export = export_bundle(raw, [], output / 'planning')
    strict_parse(output / 'planning/domain.pddl')
    namespace = json.loads((output / 'planning/namespace_maps.json').read_text(encoding='utf-8'))
    qualified = {}
    for source, mapping in maps.items():
        qualified[source] = {category: {old: namespace[category].get(target, target) for old, target in table.items()}
                             for category, table in mapping.items()}
    result = {'status': 'built_source_action_variants', 'policy': policy, 'action_count': len(ownership),
              'shared_reference_predicates': sorted(shared), 'source_maps': qualified,
              'action_ownership': {namespace['actions'][name]: owner for name, owner in ownership.items()},
              'action_roundtrips': checks, 'predicate_signature_mismatches': mismatches,
              'export': export, 'scope': 'Exact mapped source STRIPS action formulas, common explicit type universe; '
              'no full-signature, all-world, independent semantic or narrative preservation claim'}
    save(output / 'metadata.json', result)
    return result


def map_world(original_path, source_map, output, extra_goals=(), retain_goal=True):
    original = ast(original_path)
    if section(original, ':init') is None: raise ValueError('Explicit initial state required')
    # Callers supply all object names explicitly. No initial facts are inferred.
    mapped = transform(original, source_map, problem=True)
    goal = section(mapped, ':goal')
    if goal is None: raise ValueError('Explicit original goal required')
    original_goal = copy.deepcopy(goal[1])
    if extra_goals:
        goal[1] = ['and', *([original_goal] if retain_goal else []), *copy.deepcopy(list(extra_goals))]
    Path(output).write_text(serialize(mapped) + '\n', encoding='utf-8')
    return mapped

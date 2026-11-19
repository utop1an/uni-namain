"""Reversible category-qualified export for Boolean, object-valued PDDL.

An interoperability adapter only. It preserves parameter positions and entire
formula trees; it does not repair model meaning, type membership or source maps.
"""
import copy
import hashlib
import json
from pathlib import Path


def fold_symbol_map(mapping):
    """Match the parser's identifier spelling without choosing conflicts."""
    result = {}
    for original, target in mapping.items():
        key, value = original.lower(), target.lower()
        if key in result and result[key] != value:
            raise ValueError('Conflicting case-insensitive symbol mappings: ' + key)
        result[key] = value
    return result


def declared_names(tokens):
    names, skip = [], False
    for token in tokens:
        if not isinstance(token, str):
            raise ValueError('Only simple typed object declarations supported')
        if skip:
            skip = False
        elif token == '-':
            skip = True
        else:
            names.append(token)
    if skip:
        raise ValueError('Missing declared type')
    return names


def name_maps(domain, problems):
    maps = {key: {} for key in ('types', 'objects', 'predicates', 'actions', 'domains')}
    for part in domain[1:]:
        if part[0] == 'domain': maps['domains'][part[1]] = 'domain__' + part[1]
        elif part[0] == ':types':
            maps['types'].update({n: 'type__' + n for n in declared_names(part[1:]) if n not in ('object', 'number')})
        elif part[0] == ':constants': maps['objects'].update({n: 'obj__' + n for n in declared_names(part[1:])})
        elif part[0] == ':predicates': maps['predicates'].update({p[0]: 'pred__' + p[0] for p in part[1:]})
        elif part[0] == ':action': maps['actions'][part[1]] = 'act__' + part[1]
    for problem in problems:
        for part in problem[1:]:
            if part[0] == ':objects': maps['objects'].update({n: 'obj__' + n for n in declared_names(part[1:])})
    names = [new for table in maps.values() for new in table.values()]
    if len(names) != len(set(names)):
        raise ValueError('Export namespaces are not globally distinct')
    return maps


def inverse_maps(maps):
    result = {}
    for key, table in maps.items():
        if len(set(table.values())) != len(table):
            raise ValueError('Non-injective name map')
        result[key] = {value: name for name, value in table.items()}
    return result


def transform(root, maps, *, problem=False):
    def typed(tokens, category):
        result, is_type = [], False
        for token in tokens:
            if not isinstance(token, str):
                raise ValueError('Unsupported structured type declaration')
            if token == '-':
                result.append(token); is_type = True
            else:
                result.append(maps['types'].get(token, token) if is_type else maps.get(category, {}).get(token, token))
                is_type = False
        if is_type: raise ValueError('Missing declared type')
        return result
    def formula(expr):
        if not isinstance(expr, list) or not expr:
            return copy.deepcopy(expr)
        head = expr[0]
        if head in ('and', 'or', 'not', 'imply', 'when'):
            return [head, *[formula(child) for child in expr[1:]]]
        if head in ('forall', 'exists'):
            return [head, typed(expr[1], 'variables'), formula(expr[2])]
        if head not in maps['predicates'] and head != '=':
            raise ValueError('Unsupported formula symbol: ' + str(head))
        if any(not isinstance(term, str) for term in expr[1:]):
            raise ValueError('Nested function terms are outside Boolean export contract')
        return [maps['predicates'].get(head, head), *[maps['objects'].get(t, t) for t in expr[1:]]]
    result = [root[0]]
    allowed = {'problem', ':domain', ':objects', ':init', ':goal', ':requirements'} if problem else {
        'domain', ':requirements', ':types', ':constants', ':predicates', ':action'}
    for part in root[1:]:
        head = part[0]
        if head not in allowed: raise ValueError('Unsupported PDDL section: ' + str(head))
        if head in ('domain', ':domain'):
            result.append([head, maps['domains'][part[1]]])
        elif head in ('problem', ':requirements'):
            result.append(copy.deepcopy(part))
        elif head in (':types', ':constants', ':objects'):
            result.append([head, *typed(part[1:], 'types' if head == ':types' else 'objects')])
        elif head == ':predicates':
            result.append([head, *[[maps['predicates'][p[0]], *typed(p[1:], 'variables')] for p in part[1:]]])
        elif head == ':action':
            action = [head, maps['actions'][part[1]]]
            if (len(part) - 2) % 2: raise ValueError('Malformed action fields')
            for index in range(2, len(part), 2):
                key, value = part[index:index + 2]
                if key == ':parameters': mapped = typed(value, 'variables')
                elif key in (':precondition', ':effect'): mapped = formula(value)
                else: raise ValueError('Unsupported action field: ' + key)
                action.extend((key, mapped))
            result.append(action)
        else:
            result.append([head, *[formula(expr) for expr in part[1:]]])
    return result


def export_bundle(domain_path, problem_paths, output):
    """Export one fixed model and all explicit worlds with reversible names.

    No parsing policy is relaxed and no facts, formulas or parameters are added.
    Callers must independently parse the exported files before using them.
    """
    from rcnc.pddl import parse_sexpr, serialize

    output = Path(output)
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use a fresh empty namespace export directory')
    paths = list(problem_paths)
    if len({path.name for path in paths}) != len(paths):
        raise ValueError('Duplicate problem filenames')
    domain = parse_sexpr(Path(domain_path).read_text(encoding='utf-8'))
    problems = {path.name: parse_sexpr(path.read_text(encoding='utf-8')) for path in paths}
    maps = name_maps(domain, list(problems.values()))
    reverse = inverse_maps(maps)
    adapted = transform(domain, maps)
    if transform(adapted, reverse) != domain:
        raise ValueError('Domain namespace round trip differs')
    mapped_problems = {}
    for name, original in problems.items():
        mapped = transform(original, maps, problem=True)
        if transform(mapped, reverse, problem=True) != original:
            raise ValueError('Problem namespace round trip differs: ' + name)
        mapped_problems[name] = mapped
    output.mkdir(parents=True, exist_ok=True)
    (output / 'problems').mkdir()
    (output / 'domain.pddl').write_text(serialize(adapted) + '\n', encoding='utf-8')
    for name, mapped in mapped_problems.items():
        (output / 'problems' / name).write_text(serialize(mapped) + '\n', encoding='utf-8')
    for name, value in (('namespace_maps.json', maps), ('inverse_namespace_maps.json', reverse)):
        (output / name).write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8')
    files = [output / 'domain.pddl', *sorted((output / 'problems').iterdir()),
             output / 'namespace_maps.json', output / 'inverse_namespace_maps.json']
    return {'policy': 'category_qualified', 'all_roundtrips_equal': True,
            'problem_count': len(problems),
            'output_sha256': {p.relative_to(output).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest() for p in files},
            'scope': 'Reversible syntax export only; independent strict parsing still required; semantic accuracy not measured'}

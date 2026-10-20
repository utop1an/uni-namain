"""Check complete syntactic source recovery under an injective namespace map.

This proves a representation invariant for the supported union construction,
not semantic correctness of learned source models or arbitrary fusion mappings.
"""
import argparse
import hashlib
import json
from pathlib import Path

from rcnc.pddl import parse_domain, parse_sexpr, section, typed_symbols


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def normalized(value, inverse=None):
    if isinstance(value, list):
        # PDDL allows (?x ?y - t) and (?x - t ?y - t). Compare the
        # declarations, not their incidental grouping in the input text.
        def typed(tokens):
            return [normalized(x, inverse) for name, typ in typed_symbols(tokens).items()
                    for x in (name, '-', typ)]
        if value and value[0] == ':objects':
            return [':objects', *typed(value[1:])]
        if value and value[0] in ('forall', 'exists'):
            return [value[0], typed(value[1]), normalized(value[2], inverse)]
        if value and value[0] == ':action':
            result = [':action', normalized(value[1], inverse)]
            for i in range(2, len(value), 2):
                result.extend([value[i], typed(value[i+1]) if value[i] == ':parameters'
                               else normalized(value[i+1], inverse)])
            return result
        return [normalized(v, inverse) for v in value]
    if isinstance(value, str):
        return (inverse or {}).get(value.lower(), value).lower()
    return value


def audit(inputs, union):
    meta = json.loads((union / 'meta_domain.json').read_text(encoding='utf-8'))
    merged = parse_domain(union / 'meta_domain.pddl')
    rows = []
    all_targets = set()
    global_issues = []
    expected_sources = {p.name.removesuffix('_domainfile.pddl') for p in inputs.glob('*_domainfile.pddl')}
    if set(meta['sources']) != expected_sources:
        global_issues.append('Source pool differs from manifest')
    for source in sorted(expected_sources):
        issues = []
        try:
            path = inputs / f'{source}_domainfile.pddl'
            src = parse_domain(path)
            namespace = meta['namespaces'][source]
            tables = {'types': namespace['types'], 'constants': meta['constant_maps'][source],
                      'predicates': meta['predicate_maps'][source], 'actions': meta['action_maps'][source]}
            inverse = {}
            for category, table in tables.items():
                expected = set(getattr(src, category)) | ({'object'} if category == 'types' else set())
                if set(table) != expected:
                    issues.append(f'{category}: source map coverage differs')
                for original, target in table.items():
                    target = target.lower()
                    if target in all_targets:
                        issues.append(f'Noninjective or cross-source target: {target}')
                    all_targets.add(target)
                    inverse[target] = original.lower()
            root = namespace['types'].get('object')
            if not root or merged.types.get(root) != 'object':
                issues.append('Missing isolated source object root')
            for name, parent in src.types.items():
                target = tables['types'][name]
                if normalized(merged.types.get(target), inverse) != parent.lower():
                    issues.append(f'Type hierarchy changed: {name}')
            for name, typ in src.constants.items():
                if normalized(merged.constants.get(tables['constants'][name]), inverse) != typ.lower():
                    issues.append(f'Constant type changed: {name}')
            for name, pred in src.predicates.items():
                mapped = merged.predicates.get(tables['predicates'][name])
                if mapped is None or normalized([list(p) for p in mapped.parameters], inverse) != normalized([list(p) for p in pred.parameters]):
                    issues.append(f'Predicate signature changed: {name}')
            for name, action in src.actions.items():
                if normalized(merged.actions.get(tables['actions'][name]), inverse) != normalized(action):
                    issues.append(f'Action expression changed: {name}')
            if not src.requirements.issubset(merged.requirements):
                issues.append('Source requirements missing')
            if meta['source_sha256'].get(path.name) != digest(path):
                issues.append('Source domain hash differs')
            problem = inputs / f'{source}_problemfile.pddl'
            problem_status = 'missing_source_problem'
            if problem.exists():
                original = parse_sexpr(problem.read_text(encoding='utf-8'))
                mapped = parse_sexpr((union / 'problems' / problem.name).read_text(encoding='utf-8'))
                objects = namespace.get('objects', {})
                for name, target in objects.items():
                    if target.lower() in inverse:
                        issues.append(f'Object mapping collision: {target}')
                    inverse[target.lower()] = name.lower()
                for key in (':objects', ':init', ':goal'):
                    if normalized(section(original, key)) != normalized(section(mapped, key), inverse):
                        issues.append(f'Problem expression changed: {key}')
                if meta['source_sha256'].get(problem.name) != digest(problem):
                    issues.append('Source problem hash differs')
                problem_status = 'checked'
            rows.append({'source': source, 'actions_checked': len(src.actions),
                         'predicates_checked': len(src.predicates), 'problem': problem_status,
                         'status': 'PASS' if not issues else 'FAIL', 'issues': issues})
        except Exception as exc:
            rows.append({'source': source, 'status': 'ERROR', 'issues': [f'{type(exc).__name__}: {exc}']})
    for category in ('types', 'constants', 'predicates', 'actions'):
        targets = {target.lower() for source in meta['sources'] for target in
                   (meta['namespaces'][source]['types'] if category == 'types' else meta[category[:-1] + '_maps'][source]).values()}
        if targets != {name.lower() for name in getattr(merged, category)}:
            global_issues.append(f'{category}: merged symbols differ from mapped source symbols')
    return {'status': 'PASS' if rows and not global_issues and all(r['status'] == 'PASS' for r in rows) else 'FAIL',
            'scope': 'Complete source schema and problem recovery under injective renaming; not narrative quality, learned-model truth, or arbitrary semantic fusion',
            'merged_domain_sha256': digest(union / 'meta_domain.pddl'),
            'implementation_sha256': {p.name: digest(p) for p in (Path(__file__), (Path(__file__).resolve().parents[2] / 'rcnc/pddl.py'))},
            'global_issues': global_issues, 'rows': rows}


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--input', type=Path, default=Path('data/narra-domains'))
    p.add_argument('--union', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    if a.output.exists():
        raise ValueError('Refusing to overwrite an existing audit')
    result = audit(a.input, a.union)
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result['status'] == 'PASS' else 1)

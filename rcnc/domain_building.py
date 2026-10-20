"""Shared bookkeeping and independent parse checks for domain builders."""
import hashlib
import json

from unified_planning.io import PDDLReader


def require_empty_output(output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8')


def implementation_hashes(paths):
    return {path.name: digest(path) for path in paths}


def check_exported_problem(domain, problem, *, capture_errors=False):
    try:
        PDDLReader().parse_problem(str(domain), str(problem))
    except Exception as exc:
        if not capture_errors:
            raise
        return {'problem': problem.name, 'status': 'ERROR', 'error': str(exc)}
    return {'problem': problem.name, 'status': 'PARSED'}


def check_raw_declarations(root, label):
    """Reject duplicate declarations before dictionary parsing can erase them."""
    def unique(names, kind):
        folded = [name.lower() for name in names]
        if len(folded) != len(set(folded)):
            raise ValueError(f'{label}: duplicate {kind}')
    def typed_names(tokens, kind):
        names, pending, index = [], [], 0
        while index < len(tokens):
            value = tokens[index]
            if not isinstance(value, str):
                raise ValueError(f'{label}: unsupported typed declaration')
            if value == '-':
                if not pending or index+1 >= len(tokens) or not isinstance(tokens[index+1], str) or tokens[index+1] == '-':
                    raise ValueError(f'{label}: malformed typed declaration')
                pending = []
                index += 2
            else:
                names.append(value)
                pending.append(value)
                index += 1
        unique(names, kind)
    if not isinstance(root, list) or not root or root[0] != 'define':
        raise ValueError(f'{label}: expected define expression')
    entries = root[1:]
    if any(not isinstance(p, list) or not p or not isinstance(p[0], str) for p in entries):
        raise ValueError(f'{label}: malformed declaration')
    unique([p[0] for p in entries if p[0] != ':action'], 'section')
    unique([p[1] for p in entries if p[0] == ':action'], 'action')
    def binders(expr):
        if isinstance(expr, list) and expr:
            if expr[0] in ('forall', 'exists'):
                typed_names(expr[1], 'quantified variable')
            for child in expr[1:]:
                binders(child)
    for part in entries:
        if part[0] in (':types', ':constants', ':objects'):
            typed_names(part[1:], part[0])
        elif part[0] == ':predicates':
            if any(not isinstance(p, list) or not p for p in part[1:]):
                raise ValueError(f'{label}: malformed predicate declaration')
            unique([p[0] for p in part[1:]], 'predicate')
            for pred in part[1:]:
                typed_names(pred[1:], 'predicate parameter')
        elif part[0] == ':action':
            if ':parameters' in part:
                typed_names(part[part.index(':parameters')+1], 'action parameter')
        binders(part)


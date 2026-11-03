"""Shared bookkeeping and independent parse checks for domain builders."""
import hashlib
import json
from pathlib import Path

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


def snapshot_implementation(output, paths, root=None):
    """Copy code under repository-relative names, including absolute callers.

    Joining a destination with an absolute source silently discards the
    destination. Normalize and validate every source before writing any copy.
    Hash the exact copied bytes rather than rereading a changing source file.
    """
    root = Path(root or Path.cwd()).resolve()
    copies = {}
    for source in paths:
        source = Path(source)
        source = source.resolve() if source.is_absolute() else (root / source).resolve()
        try:
            relative = source.relative_to(root)
        except ValueError as exc:
            raise ValueError('Implementation source is outside repository root') from exc
        key = relative.as_posix()
        if key in copies:
            raise ValueError('Duplicate implementation source: ' + key)
        destination = output / 'implementation' / relative
        if destination.exists():
            raise ValueError('Refusing to overwrite implementation snapshot: ' + key)
        copies[key] = (destination, source.read_bytes())
    hashes = {}
    for key, (destination, content) in copies.items():
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(content)
        hashes[key] = hashlib.sha256(content).hexdigest()
    return hashes


def archived_implementation(output, reference, *, allow_current=False, root=None):
    """Resolve old absolute manifest keys without escaping the archive folder."""
    root = Path(root or Path.cwd()).resolve()
    relative = Path(reference)
    if relative.is_absolute():
        try:
            relative = relative.resolve().relative_to(root)
        except ValueError as exc:
            raise ValueError('Implementation reference is outside repository root') from exc
    if relative.anchor or '..' in relative.parts:
        raise ValueError('Implementation reference must stay inside repository root')
    for directory in ('implementation', 'postrun_implementation_snapshot'):
        candidate = output / directory / relative
        if candidate.is_file():
            return candidate
    if allow_current:
        return root / relative
    raise ValueError('Missing archived implementation: ' + str(relative))


def planning_domain_path(directory, manifest):
    """Resolve a run's declared model, with the historical union fallback."""
    value = manifest.get('planning_domain', 'union/meta_domain.pddl')
    if not isinstance(value, str) or not value:
        raise ValueError('Planning domain must be a nonempty run-relative path')
    relative = Path(value)
    if relative.anchor or '..' in relative.parts:
        raise ValueError('Planning domain must stay inside its run directory')
    destination = directory / relative
    if not destination.resolve().is_relative_to(directory.resolve()):
        raise ValueError('Planning domain must stay inside its run directory')
    return destination


def check_exported_problem(domain, problem, *, capture_errors=False):
    try:
        PDDLReader().parse_problem(str(domain), str(problem))
    except Exception as exc:
        if not capture_errors:
            raise
        return {'problem': problem.name, 'status': 'ERROR', 'error': str(exc)}
    return {'problem': problem.name, 'status': 'PARSED'}


def check_exported_domain(domain, *, capture_errors=False):
    """Domain-only builds must invoke the independent parser explicitly."""
    try:
        PDDLReader().parse_problem(str(domain))
    except Exception as exc:
        if not capture_errors:
            raise
        return {'domain': domain.name, 'status': 'ERROR', 'error': str(exc)}
    return {'domain': domain.name, 'status': 'PARSED'}


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


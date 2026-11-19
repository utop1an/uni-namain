"""Lossless packaging adapter; never repairs or infers PDDL model content.

Only an explicit Solution/Error delimiter permits material after a model.
Unknown extra roots and ambiguous model definitions remain rejected.
"""
from __future__ import annotations

from pathlib import Path
import re

from rcnc.domain_building import digest, save
from rcnc.pddl import parse_sexpr


def _skip_layout(data: bytes, start: int) -> int:
    while start < len(data):
        if data[start] in b' \t\r\n':
            start += 1
        elif data[start] == ord(';'):
            while start < len(data) and data[start] not in b'\r\n':
                start += 1
        else:
            break
    return start


def _definition(data: bytes, start: int, kind: str) -> int:
    if start >= len(data) or data[start] != ord('('):
        raise ValueError(f'Missing explicit {kind} definition')
    depth, comment = 0, False
    for pos in range(start, len(data)):
        char = data[pos]
        if comment:
            if char in b'\r\n': comment = False
            continue
        if char == ord(';'):
            comment = True
        elif char == ord('('):
            depth += 1
        elif char == ord(')'):
            depth -= 1
            if depth == 0:
                end = pos + 1
                root = parse_sexpr(data[start:end].decode('utf-8'))
                if (not isinstance(root, list) or len(root) < 2 or
                        not isinstance(root[0], str) or root[0].lower() != 'define' or
                        not isinstance(root[1], list) or len(root[1]) != 2 or
                        not isinstance(root[1][0], str) or root[1][0].lower() != kind or
                        not isinstance(root[1][1], str)):
                    raise ValueError(f'Expected exactly one define ({kind} name)')
                return end
    raise ValueError(f'Unclosed {kind} definition')


def split_package(data: bytes, kind: str) -> list[dict]:
    """Return a complete ordered byte partition, without modifying any byte."""
    if kind not in ('domain', 'problem'):
        raise ValueError('Only domain/problem packages are supported')
    data.decode('utf-8')  # Reject invalid input; no lossy decoding.
    start = _skip_layout(data, 0)
    end = _definition(data, start, kind)
    parts = []

    def add(role, begin, finish):
        if begin < finish: parts.append({'role': role, 'start': begin, 'end': finish})

    add('notes', 0, start)
    add(kind, start, end)
    after = _skip_layout(data, end)
    if after == len(data):
        add('notes', end, len(data))
    elif data.startswith(b'<|Solution|>', after):
        plan_start = _skip_layout(data, after + len(b'<|Solution|>'))
        plan_end = _definition(data, plan_start, 'plan')
        if _skip_layout(data, plan_end) != len(data):
            raise ValueError('Unexpected content after the explicit plan')
        add('notes', end, plan_start)
        add('plan', plan_start, plan_end)
        add('notes', plan_end, len(data))
    elif data.startswith(b'<|Error|>', after):
        # Error messages are opaque text, including unmatched parentheses.
        # A second model definition is nevertheless ambiguous and rejected.
        if re.search(rb'\(\s*define\s*\(', data[after:], re.IGNORECASE):
            raise ValueError('Ambiguous definition in error notes')
        add('notes', end, len(data))
    else:
        raise ValueError('Unmarked extra content after the model definition')
    assert b''.join(data[p['start']:p['end']] for p in parts) == data
    return parts


def separate_pair(domain: Path, problem: Path, output: Path) -> dict:
    """Copy originals and save each exact span in a fresh directory."""
    if output.exists(): raise ValueError('Fresh package directory required')
    inputs = {kind: path.read_bytes() for kind, path in [('domain', domain), ('problem', problem)]}
    partitions = {kind: split_package(data, kind) for kind, data in inputs.items()}
    if sum(p['role'] == 'plan' for parts in partitions.values() for p in parts) > 1:
        raise ValueError('Multiple plans in one pair are ambiguous')
    output.mkdir(parents=True)
    sources, files = {}, {}
    for kind, source in [('domain', domain), ('problem', problem)]:
        data = inputs[kind]
        original = output / f'original-{kind}.pddl'
        original.write_bytes(data)
        files[str(original)] = digest(original)
        parts = []
        for index, part in enumerate(partitions[kind]):
            role = part['role']
            name = f'{kind}.notes.{index:03d}.txt' if role == 'notes' else f'{role}.pddl'
            path = output / name
            path.write_bytes(data[part['start']:part['end']])
            files[str(path)] = digest(path)
            parts.append({**part, 'path': str(path), 'sha256': digest(path)})
        sources[kind] = {'path': str(source), 'sha256': digest(source), 'bytes': len(data),
                         'original_copy': str(original), 'parts': parts}
    result = {'status': 'lossless_split', 'sources': sources, 'files': files,
              'effective_domain': str(output / 'domain.pddl'), 'effective_problem': str(output / 'problem.pddl'),
              'plan': str(output / 'plan.pddl') if (output / 'plan.pddl').exists() else None,
              'policy': 'Exact byte spans only; notes and plans excluded from model conversion, initial state and goals.',
              'plan_validation': 'not_performed', 'model_repairs': 0}
    verify_package(result)
    save(output / 'split.json', result)
    return result


def verify_package(package: dict) -> bool:
    for path, sha in package['files'].items():
        if digest(Path(path)) != sha: raise ValueError(f'Package file changed: {path}')
    for kind, source in package['sources'].items():
        raw = Path(source['path']).read_bytes()
        if digest(Path(source['path'])) != source['sha256'] or len(raw) != source['bytes']:
            raise ValueError(f'Original {kind} changed')
        if Path(source['original_copy']).read_bytes() != raw:
            raise ValueError('Original copy differs')
        position, rebuilt = 0, b''
        for part in source['parts']:
            content = Path(part['path']).read_bytes()
            if (part['start'] != position or part['end'] <= position or
                    content != raw[part['start']:part['end']] or digest(Path(part['path'])) != part['sha256']):
                raise ValueError('Invalid lossless partition')
            position = part['end']; rebuilt += content
        if position != len(raw) or rebuilt != raw:
            raise ValueError('Incomplete lossless partition')
        if [{k: p[k] for k in ('role', 'start', 'end')} for p in source['parts']] != split_package(raw, kind):
            raise ValueError('Partition differs from explicit packaging grammar')
        models = [p for p in source['parts'] if p['role'] == kind]
        if len(models) != 1 or models[0]['path'] != package['effective_' + kind]:
            raise ValueError('Effective model does not match extracted span')
    return True

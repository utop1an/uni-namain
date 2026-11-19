"""Post-hoc reversible export diagnostic; never repairs a recorded reference run."""
import argparse
import importlib.metadata
import json
from pathlib import Path

from unified_planning.environment import Environment
from unified_planning.io import PDDLReader
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.namespace_export import name_maps, inverse_maps, transform
from rcnc.pddl import parse_sexpr, serialize


def candidate_path(directory, name):
    relative = Path(name)
    if relative.anchor or '..' in relative.parts:
        raise ValueError('Candidate input must be a run-relative path')
    result = directory / relative
    if not result.resolve().is_relative_to(directory.resolve()):
        raise ValueError('Candidate input must stay inside its run directory')
    return result


def run(protocol_path, output):
    require_empty_output(output)
    protocol = json.loads(protocol_path.read_text(encoding='utf-8'))
    reference = Path(protocol['reference'])
    for name, expected in protocol['input_sha256'].items():
        if digest(candidate_path(reference, name)) != expected: raise ValueError('Registered candidate changed: ' + name)
    terminal = json.loads((reference / 'report.json').read_text(encoding='utf-8'))
    parent = json.loads((reference / 'manifest.json').read_text(encoding='utf-8'))
    validation = json.loads((reference / 'fusion/validation.json').read_text(encoding='utf-8'))
    if (terminal['status'] != 'worker_error' or parent['status'] != 'worker_error'
            or terminal.get('validation', {}).get('valid') is not False or terminal['validation'] != validation):
        raise ValueError('This protocol diagnoses a terminal validation-failed candidate only')
    if terminal.get('integrity_checks_passed') is not True:
        raise ValueError('Parent runtime integrity did not pass')
    output.mkdir(parents=True)
    (output / 'protocol.json').write_bytes(protocol_path.read_bytes())
    for name in protocol['input_sha256']:
        target = candidate_path(output / 'source_snapshot', name); target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(candidate_path(reference, name).read_bytes())
    model = output / 'source_snapshot/fusion'
    raw = parse_sexpr((model / 'meta_domain.pddl').read_text(encoding='utf-8'))
    problems = {p.name: parse_sexpr(p.read_text(encoding='utf-8')) for p in sorted((model / 'problems').glob('*_problemfile.pddl'))}
    if len(problems) != protocol['problem_count']: raise ValueError('Complete problem cohort required')
    implementation = snapshot_implementation(output, [Path(__file__), Path('rcnc/namespace_export.py'),
        Path('rcnc/pddl.py'), Path('rcnc/domain_building.py')])
    save(output / 'manifest.json', {'status': 'frozen_before_name_export',
        'input_sha256': protocol['input_sha256'], 'implementation_sha256': implementation,
        'protocol_sha256': digest(output / 'protocol.json'), 'scope': protocol['scope']})
    maps = name_maps(raw, list(problems.values())); reverse = inverse_maps(maps)
    save(output / 'namespace_maps.json', maps)
    save(output / 'inverse_namespace_maps.json', reverse)
    adapted = transform(raw, maps)
    if transform(adapted, reverse) != raw: raise ValueError('Domain round trip differs')
    (output / 'domain.pddl').write_text(serialize(adapted) + '\n', encoding='utf-8')
    exported = output / 'problems'; exported.mkdir()
    rows = []
    cases = [('domain_only', None)]
    for name, original in problems.items():
        mapped = transform(original, maps, problem=True)
        if transform(mapped, reverse, problem=True) != original: raise ValueError('Problem round trip differs: ' + name)
        path = exported / name; path.write_text(serialize(mapped) + '\n', encoding='utf-8')
        cases.append((name.removesuffix('_problemfile.pddl'), path))
    for identifier, path in cases:
        environment = Environment(); environment.error_used_name = True
        row = {'id': identifier, 'namespace_policy': 'strict_global_name_uniqueness'}
        try:
            parsed = PDDLReader(environment=environment).parse_problem(str(output / 'domain.pddl'), str(path) if path else None)
            row.update(status='PARSED', actions=len(parsed.actions), fluents=len(parsed.fluents))
        except Exception as exc:
            row.update(status='ERROR', reason=f'{type(exc).__name__}: {exc}')
        rows.append(row)
    result = {'status': 'complete', 'task_count': len(rows), 'rows': rows,
        'all_roundtrips_equal': True, 'all_strict_parsed': all(r['status'] == 'PARSED' for r in rows),
        'source_snapshot_unchanged': all(digest(output / 'source_snapshot' / n) == h for n, h in protocol['input_sha256'].items()),
        'original_candidate_unchanged': all(digest(reference / n) == h for n, h in protocol['input_sha256'].items()),
        'implementation_unchanged': all(digest(Path(n)) == h for n, h in implementation.items()),
        'domain_sha256': digest(output / 'domain.pddl'), 'namespace_maps_sha256': digest(output / 'namespace_maps.json'),
        'manifest_sha256': digest(output / 'manifest.json'), 'parser_version': importlib.metadata.version('unified-planning'),
        'model_calls': 0, 'planner_calls': 0, 'scope': protocol['scope']}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--protocol', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps({k: v for k, v in run(args.protocol, args.output).items() if k != 'rows'}, indent=2))

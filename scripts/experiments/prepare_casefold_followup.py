"""Separate case-only adapter diagnostic, preserving the original admission failures."""
import argparse
import json
from pathlib import Path

from unified_planning.io import PDDLReader

from rcnc.aligned_domain import build
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.narrative_pipeline import map_problem
from rcnc.pddl import parse_sexpr, serialize
from rcnc.prospective_evaluation import lexical_alignment
from scripts.experiments.run_original_world_pipeline import convert_problem


def casefold_ast(expr):
    return [casefold_ast(x) for x in expr] if isinstance(expr, list) else expr.lower()


def prepare(protocol_path, snapshot, admission_path, output):
    require_empty_output(output)
    read = lambda p: json.loads(p.read_text(encoding='utf-8'))
    protocol, admission = read(protocol_path), read(admission_path)
    selected = [r for r in admission['rows'] if r.get('original_parser', {}).get('status') == 'parsed_default_policy']
    if ({r['source'] for r in selected} != set(protocol['selected_sources'])
            or len(selected) * len(protocol['conditions']) != protocol['expected_slots']):
        raise ValueError('Unexpected structurally selected followup denominator')
    output.mkdir(parents=True)
    save(output / 'protocol.json', protocol)
    inputs = output / 'domain_inputs'
    inputs.mkdir()
    normalization = []
    for row in selected:
        directory = output / 'native' / row['id']
        directory.mkdir(parents=True)
        for kind in ('domain', 'problem'):
            original = snapshot / row['provider'] / 'files' / row[kind]
            if digest(original) != row[kind + '_sha256']:
                raise ValueError('Original source changed')
            ast = casefold_ast(parse_sexpr(original.read_text(encoding='utf-8')))
            target = directory / (kind + '.pddl')
            target.write_text(serialize(ast) + '\n', encoding='utf-8')
            if parse_sexpr(target.read_text(encoding='utf-8')) != ast:
                raise ValueError('Case-only adapter changed AST')
            normalization.append({'id': row['id'] + '/' + kind, 'original': str(original),
                'original_sha256': digest(original), 'normalized': str(target),
                'normalized_sha256': digest(target), 'casefold_ast_equal': True})
        PDDLReader().parse_problem(str(directory / 'domain.pddl'), str(directory / 'problem.pddl'))
        destination = inputs / (row['source'] + '_domainfile.pddl')
        data = (directory / 'domain.pddl').read_bytes()
        if destination.exists() and destination.read_bytes() != data:
            raise ValueError('Source model differs across problems')
        destination.write_bytes(data)
    save(output / 'normalization.json', {'status': 'verified_case_only', 'rows': normalization,
        'row_count': len(normalization), 'admission_sha256': digest(admission_path),
        'scope': 'Case-insensitive identifier normalization only; no semantic repair.'})
    spec = lexical_alignment(inputs)
    models = {}
    build_error = None
    try:
        for condition in ('zero', 'lexical'):
            model = output / 'models' / condition
            local = {**spec, 'predicate_groups': spec['predicate_groups'] if condition == 'lexical' else []}
            if not build(inputs, model, local)['valid']:
                raise ValueError('Independent model parsing failed')
            models[condition] = model
    except Exception as exc:
        build_error = f'{type(exc).__name__}: {exc}'
        models = {}
    tasks = []
    for candidate in selected:
        source = output / 'native' / candidate['id']
        for condition in protocol['conditions']:
            key = candidate['id'] + '__' + condition
            folder = output / 'bundle/tasks' / key
            folder.mkdir(parents=True)
            row = {'id': key, 'source': candidate['source'], 'family': candidate['family'],
                   'representation': condition, 'problem_id': candidate['id']}
            tasks.append(row)
            try:
                if condition == 'native':
                    for kind in ('domain', 'problem'):
                        (folder / (kind + '.pddl')).write_bytes((source / (kind + '.pddl')).read_bytes())
                else:
                    if condition not in models:
                        raise ValueError('Parent model unavailable: ' + str(build_error))
                    query = convert_problem(candidate['source'], source / 'domain.pddl', source / 'problem.pddl')
                    save(folder / 'query.json', query)
                    model = models[condition]
                    (folder / 'domain.pddl').write_bytes((model / 'meta_domain.pddl').read_bytes())
                    save(folder / 'query_mapping.json', map_problem(query, model, folder / 'problem.pddl'))
                row.update(admission_status='ready', domain_sha256=digest(folder / 'domain.pddl'), problem_sha256=digest(folder / 'problem.pddl'))
            except Exception as exc:
                row.update(admission_status='admission_failed', reason=f'{type(exc).__name__}: {exc}')
    ready = [r for r in tasks if r['admission_status'] == 'ready']
    save(output / 'bundle/manifest.json', {'status': 'frozen_before_search', 'mode': 'matched_source_representations', 'task_count': len(ready), 'tasks': ready})
    implementation = snapshot_implementation(output, [Path(__file__), *Path('rcnc').glob('*.py'),
        Path('scripts/experiments/run_original_world_pipeline.py'), Path('scripts/experiments/run_long_horizon_scaling.py'),
        Path('scripts/experiments/run_downward_reference.py')])
    pins = {str(p): digest(p) for p in output.rglob('*') if p.is_file()}
    manifest = {'status': 'frozen_before_search', 'task_count': len(tasks), 'rows': tasks,
        'input_sha256': pins, 'implementation_sha256': implementation, 'budget': protocol['budget'],
        'build_error': build_error, 'protocol_sha256': digest(protocol_path),
        'scope': protocol['interpretation']}
    save(output / 'manifest.json', manifest)
    return manifest


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    for name in ('protocol', 'snapshot', 'admission', 'output'):
        p.add_argument('--' + name, type=Path, required=True)
    args = p.parse_args()
    result = prepare(args.protocol, args.snapshot, args.admission, args.output)
    print(json.dumps({'status': result['status'], 'task_count': result['task_count'], 'ready': sum(r['admission_status'] == 'ready' for r in result['rows']), 'build_error': result['build_error']}))

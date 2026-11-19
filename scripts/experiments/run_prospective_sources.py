"""Freeze external original-goal controls without changing source models/worlds."""
import argparse
from collections import Counter
import json
from pathlib import Path

from rcnc.aligned_domain import build
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.narrative_pipeline import map_problem
from rcnc.prospective_evaluation import lexical_alignment
from scripts.experiments.run_original_world_pipeline import convert_problem
from scripts.experiments.frozen_solver import execute


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def prepare(protocol_path, snapshot, admission_path, output):
    require_empty_output(output)
    protocol, selection = read(protocol_path), read(snapshot / 'selection.json')
    admission, frozen = read(admission_path), read(snapshot / 'manifest.json')
    if admission['status'] != 'complete' or digest(snapshot / 'manifest.json') != admission['snapshot_manifest_sha256']:
        raise ValueError('Admission/snapshot mismatch')
    candidates = selection['candidates']
    if len(candidates) * len(protocol['original_goal_execution']['conditions']) != protocol['original_goal_execution']['expected_slots']:
        raise ValueError('Protocol slot denominator mismatch')
    files = {(r['provider'], r['path']): r for r in frozen['files']}
    for row in files.values():
        path = snapshot / row['provider'] / 'files' / row['path']
        if digest(path) != row['sha256']:
            raise ValueError('Source snapshot changed')
    output.mkdir(parents=True)
    save(output / 'protocol.json', protocol)
    inputs = output / 'domain_inputs'
    inputs.mkdir()
    admitted = {r['id']: r for r in admission['rows']}
    # Whole selected pool or a visible build failure; never silently drop a source.
    models = {}
    build_error = None
    try:
        if any(admitted[r['id']]['status'] != 'admitted_compatibility_only' for r in candidates):
            raise ValueError('At least one selected source/problem not admitted')
        for row in candidates:
            path = inputs / (row['source'] + '_domainfile.pddl')
            content = (snapshot / row['provider'] / 'files' / row['domain']).read_bytes()
            if path.exists() and path.read_bytes() != content:
                raise ValueError('Conflicting domain bytes for source')
            path.write_bytes(content)
        spec = lexical_alignment(inputs)
        for condition in ('zero', 'lexical'):
            model = output / 'models' / condition
            local = {**spec, 'predicate_groups': spec['predicate_groups'] if condition == 'lexical' else []}
            result = build(inputs, model, local)
            if not result['valid']:
                raise ValueError('Compiled model not independently parsed')
            models[condition] = model
    except Exception as exc:
        build_error = f'{type(exc).__name__}: {exc}'
        models = {}
    tasks = []
    for candidate in candidates:
        domain = snapshot / candidate['provider'] / 'files' / candidate['domain']
        problem = snapshot / candidate['provider'] / 'files' / candidate['problem']
        for condition in protocol['original_goal_execution']['conditions']:
            key = candidate['id'] + '__' + condition
            folder = output / 'bundle/tasks' / key
            folder.mkdir(parents=True)
            row = {'id': key, 'source': candidate['source'], 'family': candidate['family'],
                   'representation': condition, 'problem_id': candidate['id']}
            tasks.append(row)
            try:
                if condition == 'native':
                    # A compiler failure must not masquerade as native failure.
                    original = admitted[candidate['id']].get('original_parser', {})
                    if original.get('status') != 'parsed_default_policy':
                        raise ValueError('Original source did not pass default independent parsing')
                    (folder / 'domain.pddl').write_bytes(domain.read_bytes())
                    (folder / 'problem.pddl').write_bytes(problem.read_bytes())
                else:
                    if condition not in models:
                        raise ValueError('Parent compiled model unavailable: ' + str(build_error))
                    query = convert_problem(candidate['source'], domain, problem)
                    save(folder / 'query.json', query)
                    model = models[condition]
                    (folder / 'domain.pddl').write_bytes((model / 'meta_domain.pddl').read_bytes())
                    save(folder / 'query_mapping.json', map_problem(query, model, folder / 'problem.pddl'))
                row.update(admission_status='ready', domain_sha256=digest(folder / 'domain.pddl'),
                           problem_sha256=digest(folder / 'problem.pddl'))
            except Exception as exc:
                row.update(admission_status='admission_failed', reason=f'{type(exc).__name__}: {exc}')
    ready = [r for r in tasks if r['admission_status'] == 'ready']
    save(output / 'bundle/manifest.json', {'status': 'frozen_before_search',
        'mode': 'matched_source_representations', 'task_count': len(ready), 'tasks': ready})
    code = [Path(__file__), *Path('rcnc').glob('*.py'),
            Path('scripts/experiments/run_original_world_pipeline.py'),
            Path('scripts/experiments/frozen_solver.py'),
            Path('scripts/experiments/run_downward_reference.py')]
    implementation = snapshot_implementation(output, code)
    pins = {str(p): digest(p) for p in output.rglob('*') if p.is_file()}
    manifest = {'status': 'frozen_before_search', 'task_count': len(tasks), 'rows': tasks,
        'input_sha256': pins, 'implementation_sha256': implementation,
        'budget': protocol['original_goal_execution']['budget'], 'build_error': build_error,
        'source_snapshot_sha256': digest(snapshot / 'manifest.json'),
        'admission_report_sha256': digest(admission_path), 'protocol_sha256': digest(protocol_path),
        'scope': 'Prospective external classical original-goal controls; not independent cross-source task or narrative evidence.'}
    save(output / 'manifest.json', manifest)
    return manifest


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--protocol', type=Path)
    p.add_argument('--snapshot', type=Path)
    p.add_argument('--admission', type=Path)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--execute', action='store_true')
    args = p.parse_args()
    result = execute(args.output) if args.execute else prepare(args.protocol, args.snapshot, args.admission, args.output)
    print(json.dumps({'status': result['status'], 'task_count': result['task_count'],
                      'counts': dict(Counter(r.get('status', r.get('admission_status')) for r in result['rows']))}))

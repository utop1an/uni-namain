"""Fresh end-to-end API checks on frozen authored composed-goal requests."""
import argparse
from collections import Counter
import json
from pathlib import Path
import time

from rcnc.domain_building import require_empty_output, save, snapshot_implementation
from rcnc.narrative_pipeline import run as run_query
from scripts.experiments.run_downward_reference import sha


def run(origin, output, solver='pyperplan'):
    if solver not in ('pyperplan', 'fast_downward'):
        raise ValueError('Unknown frozen pipeline solver')
    require_empty_output(output)
    source_manifest = json.loads((origin / 'bundle/manifest.json').read_text(encoding='utf-8'))
    original_tasks = [t for t in source_manifest['tasks'] if t['representation'] == 'all_domains']
    if len(original_tasks) != 6 or len({t['id'] for t in original_tasks}) != 6:
        raise ValueError('Expected all six frozen world/interface conditions')
    output.mkdir(parents=True)
    inputs = output / 'inputs'
    inputs.mkdir()
    for name, digest in source_manifest['source_sha256'].items():
        path = origin / 'inputs' / name
        if sha(path) != digest:
            raise ValueError('Origin source drift')
        (inputs / name).write_bytes(path.read_bytes())
    tasks = []
    for task in original_tasks:
        label = task['world'] + ('__interface' if task['interface'] else '__zero_merge')
        path = origin / 'models' / label / 'query.json'
        if sha(path) != task['query_sha256']:
            raise ValueError('Origin query drift')
        query = json.loads(path.read_text(encoding='utf-8'))
        query.pop('sources', None)
        query.update(selection='static_universe_components', solver=solver, seconds=20)
        if solver == 'fast_downward':
            query['memory_mb'] = 4096
        tasks.append({'id': label, 'world': task['world'], 'interface': task['interface'], 'query': query})
    code = [Path(__file__), Path('rcnc/__main__.py'), Path('scripts/experiments/run_downward_reference.py'),
            *sorted(Path('rcnc').glob('*.py'))]
    implementation = snapshot_implementation(output, code)
    manifest = {'status': 'frozen_before_search', 'task_count': 6, 'tasks': tasks,
        'source_sha256': source_manifest['source_sha256'],
        'origin_manifest_sha256': sha(origin / 'bundle/manifest.json'),
        'implementation_sha256': implementation,
        'budget': {'seconds_per_search': 20, 'workers': 1, **({'memory_mb': 4096} if solver == 'fast_downward' else {})},
        'solver': solver,
        'scope': 'End-to-end API development checks on six previously observed authored conditions; solver=' + solver + '. Not new worlds or a statistical timing comparison'}
    save(output / 'frozen_queries.json', manifest)
    frozen_hash = sha(output / 'frozen_queries.json')
    report = {'status': 'running', 'task_count': 6, 'frozen_queries_sha256': frozen_hash, 'rows': []}
    save(output / 'report.json', report)
    for task in tasks:
        directory = output / 'runs' / task['id']
        start = time.perf_counter()
        result = run_query(task['query'], inputs, directory)
        row = {k: task[k] for k in ('id', 'world', 'interface')}
        row.update(status=result['status'], elapsed_seconds=time.perf_counter() - start,
            planner_called=result['planner_called'], domain_unchanged=result.get('domain_unchanged'),
            plan_length=result.get('search', {}).get('length'),
            validation=result.get('search', {}).get('validation', {}).get('status'),
            reason=result.get('reason'), selected_sources=result.get('selection', {}).get('selected'))
        path = directory / 'manifest.json'
        if path.is_file():
            run_manifest = json.loads(path.read_text(encoding='utf-8'))
            row.update(planning_domain=run_manifest['planning_domain'],
                domain_sha256=run_manifest['domain_sha256'], problem_sha256=run_manifest['problem_sha256'])
        report['rows'].append(row)
        report['status_counts'] = dict(Counter(r['status'] for r in report['rows']))
        save(output / 'report.json', report)
        print(json.dumps(row), flush=True)
    report.update(status='complete', sources_unchanged=all(sha(inputs / p) == h for p, h in manifest['source_sha256'].items()),
        implementation_unchanged=all(sha(Path(p)) == h for p, h in manifest['implementation_sha256'].items()),
        frozen_queries_unchanged=sha(output / 'frozen_queries.json') == frozen_hash, scope=manifest['scope'])
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--origin', type=Path, default=Path('data/validation/composed_selection_2026_10_23_v1'))
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--solver', choices=['pyperplan', 'fast_downward'], default='pyperplan')
    args = parser.parse_args()
    result = run(args.origin, args.output, args.solver)
    print(json.dumps({k: v for k, v in result.items() if k != 'rows'}, indent=2))

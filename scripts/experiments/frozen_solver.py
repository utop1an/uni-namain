"""Execute a frozen admitted task bundle without retries or cache continuation."""
from collections import Counter
import json
from pathlib import Path

from rcnc.domain_building import digest, save


def read(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def execute(output):
    from scripts.experiments.run_downward_reference import run
    manifest = read(output / 'manifest.json')
    if (output / 'solver').exists():
        raise ValueError('Fresh execution only')
    for p, h in {**manifest['input_sha256'], **manifest['implementation_sha256']}.items():
        if digest(Path(p)) != h:
            raise ValueError('Frozen dependency changed: ' + p)
    budget = manifest['budget']
    solver = run(Path('.'), None, output / 'solver', Path('.tmp/fast-downward-26.6'),
                 budget['seconds'], budget['memory_mb'], task_bundle=output / 'bundle')
    indexed = {r['id']: r for r in solver['rows']}
    rows = [{**r, **indexed.get(r['id'], {'status': r['admission_status']})} for r in manifest['rows']]
    report = {'status': 'complete', 'task_count': len(rows), 'actual_solver_calls': len(solver['rows']), 'rows': rows,
        'status_counts': dict(Counter(r['status'] for r in rows)),
        'by_family_condition': {f'{f}/{c}': dict(Counter(r['status'] for r in rows if r['family'] == f and r['representation'] == c))
                               for f, c in sorted({(r['family'], r['representation']) for r in rows})},
        'inputs_unchanged': all(digest(Path(p)) == h for p, h in manifest['input_sha256'].items()),
        'implementation_unchanged': all(digest(Path(p)) == h for p, h in manifest['implementation_sha256'].items()),
        'solver_integrity': all(solver[k] for k in ('binary_unchanged', 'runner_unchanged', 'implementation_unchanged', 'validator_unchanged')),
        'manifest_sha256': digest(output / 'manifest.json')}
    save(output / 'report.json', report)
    return report


"""Pin a prospective public-source split before retrieving any new formulas."""
import argparse
from datetime import datetime, timezone
import hashlib
import itertools
import json
from pathlib import Path
import re
import urllib.request

from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation

SOURCES = ('gripper', 'miconic', 'movie', 'rovers', 'satellite', 'transport-opt11-strips')
COMMIT = 'e21d49c2cb61d147a46c5966f2581bf6fd422b9f'
TREE = Path('data/external/prospective_sources_2026_10_26_v1/ipc/tree.json')


def natural_key(value):
    return [int(x) if x.isdigit() else x for x in re.split(r'(\d+)', value)]


def prepare(output):
    require_empty_output(output)
    tree = json.loads(TREE.read_text(encoding='utf-8'))
    if tree['truncated'] or tree['sha'] != COMMIT:
        raise ValueError('Expected complete pinned commit tree')
    entries = {x['path']: x for x in tree['tree'] if x['type'] == 'blob'}
    files, sources = [], []
    for source in SOURCES:
        domain = source + '/domain.pddl'
        problems = sorted([p for p in entries if p.startswith(source + '/') and p.endswith('.pddl') and p != domain], key=natural_key)
        selected = [problems[i] for i in (0, len(problems) // 2, len(problems) - 1)]
        sources.append({'id': source, 'domain': domain, 'problems': selected, 'available_problems': len(problems),
                        'selection': 'first/middle/last by natural filename order; difficulty not inferred'})
        for p in (domain, *selected):
            files.append({'path': p, 'git_blob_sha1': entries[p]['sha'], 'expected_bytes': entries[p].get('size'),
                          'url': f'https://raw.githubusercontent.com/aibasel/downward-benchmarks/{COMMIT}/{p}'})
    output.mkdir(parents=True)
    protocol = {'status': 'source_selection_frozen_before_download', 'created_utc': datetime.now(timezone.utc).isoformat(),
        'commit': COMMIT, 'tree_sha256': digest(TREE), 'sources': sources, 'files': files,
        'source_pairs': [list(p) for p in itertools.combinations(SOURCES, 2)],
        'source_count': 6, 'source_pair_count': 15, 'original_problem_count': 18,
        'split': 'Prospective new public-source set relative to the current repository intake; not a claim of model-pretraining novelty or independently learned narrative sources.',
        'admission': 'Preserve every selected source and problem. Unsupported syntax, costs or bindings remain unavailable rows. No silent source rewrite or replacement.',
        'planning_conditions': ['native_source', 'no_share', 'predicate_only', 'predicate_and_action'],
        'cross_source_controls': ['remove_each_required_source', 'explicit_shared_objects_initial_state_and_goal'],
        'cost_stages': ['model_judgment', 'domain_construction', 'translation_and_instantiation', 'search'],
        'not_yet_frozen': ['candidate enumeration and bounded selection implementation', 'explicit composed task worlds/goals', 'complete admitted task matrix and execution budget'],
        'execution': 'Intake only: zero model/planner calls. Main experiments require a separate complete execution freeze; do not select successful source pairs after model outcomes.'}
    save(output / 'protocol.json', protocol)
    save(output / 'manifest.json', {'status': 'frozen_before_download', 'protocol_sha256': digest(output / 'protocol.json'),
        'implementation_sha256': snapshot_implementation(output, [Path(__file__)])})
    return {k: protocol[k] for k in ('status', 'source_count', 'source_pair_count', 'original_problem_count')}


def fetch(output):
    manifest = json.loads((output / 'manifest.json').read_text(encoding='utf-8'))
    if digest(output / 'protocol.json') != manifest['protocol_sha256']:
        raise ValueError('Source selection changed')
    for p, h in manifest['implementation_sha256'].items():
        if digest(Path(p)) != h: raise ValueError('Intake implementation changed')
    if (output / 'progress.json').exists(): raise ValueError('Fresh download only; no silent retries')
    protocol = json.loads((output / 'protocol.json').read_text(encoding='utf-8'))
    rows = []
    save(output / 'progress.json', {'status': 'running', 'rows': rows})
    for item in protocol['files']:
        row = {'id': item['path'], 'url': item['url']}
        try:
            with urllib.request.urlopen(item['url'], timeout=30) as response:
                raw = response.read(2_000_001)
            if len(raw) > 2_000_000: raise ValueError('File exceeds declared intake bound')
            blob = hashlib.sha1(f'blob {len(raw)}\0'.encode() + raw).hexdigest()
            if blob != item['git_blob_sha1']: raise ValueError('Git blob hash mismatch')
            path = output / 'files' / item['path']; path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(raw)
            row.update(status='verified', bytes=len(raw), sha256=digest(path), git_blob_sha1=blob)
        except Exception as exc:
            row.update(status='failed', reason=f'{type(exc).__name__}: {exc}')
        rows.append(row)
        save(output / 'progress.json', {'status': 'running', 'rows': rows})
    report = {'status': 'complete', 'file_count': len(rows), 'rows': rows,
        'verified_files': sum(r['status'] == 'verified' for r in rows),
        'failed_files': sum(r['status'] == 'failed' for r in rows),
        'protocol_sha256': digest(output / 'protocol.json'), 'model_calls': 0, 'planner_calls': 0,
        'scope': protocol['execution']}
    save(output / 'report.json', report)
    return {k: v for k, v in report.items() if k != 'rows'}


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('mode', choices=['prepare', 'fetch'])
    p.add_argument('--output', type=Path, required=True)
    args = p.parse_args()
    print(json.dumps((prepare if args.mode == 'prepare' else fetch)(args.output), indent=2))

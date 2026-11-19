"""Separate bounded state-projection searches on all existing generated worlds."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import subprocess
import sys
import time

from rcnc.domain_building import require_empty_output, save, snapshot_implementation
from scripts.experiments.run_downward_reference import sha


def prepare(protocol_path, output):
    require_empty_output(output)
    protocol = json.loads(protocol_path.read_text(encoding='utf-8'))
    output.mkdir(parents=True)
    (output / 'protocol.json').write_bytes(protocol_path.read_bytes())
    tasks = []
    for cohort in protocol['cohorts']:
        origin = Path(cohort['path'])
        if sha(origin / 'manifest.json') != cohort['manifest_sha256']:
            raise ValueError('Predecessor manifest drift')
        manifest = json.loads((origin / 'manifest.json').read_text(encoding='utf-8'))
        registry = manifest.get('conditions', manifest.get('tasks'))
        for task in registry:
            if task['condition'] not in cohort['conditions'] or task.get('admission_status', 'ready') != 'ready':
                continue
            source = origin / 'bundle/tasks' / task['id']
            identifier = cohort['name'] + '__' + task['id']
            target = output / 'tasks' / identifier
            target.mkdir(parents=True)
            for name in ('domain.pddl', 'problem.pddl'):
                if sha(source / name) != task[name.removesuffix('.pddl') + '_sha256']:
                    raise ValueError('Predecessor input drift')
                (target / name).write_bytes((source / name).read_bytes())
            tasks.append({'id': identifier, 'pair_id': task['pair_id'], 'condition': task['condition'],
                'cohort': cohort['name'], 'origin_task': task['id'],
                'domain_sha256': sha(target / 'domain.pddl'), 'problem_sha256': sha(target / 'problem.pddl')})
    if len(tasks) != 24 or len({row['pair_id'] for row in tasks}) != 6:
        raise ValueError('Expected every generated world under all four diagnostic conditions')
    implementation = snapshot_implementation(output, [Path(__file__), Path('rcnc/__main__.py'), *sorted(Path('rcnc').glob('*.py'))])
    manifest = {'status': 'frozen_before_search', 'tasks': tasks, 'task_count': len(tasks),
        'protocol_sha256': sha(output / 'protocol.json'), 'budget': protocol['budget'],
        'implementation_sha256': implementation, 'scope': protocol['scope']}
    save(output / 'manifest.json', manifest)
    return manifest


def execute(output):
    manifest = json.loads((output / 'manifest.json').read_text(encoding='utf-8'))
    if (output / 'report.json').exists() or (output / 'searches').exists():
        raise ValueError('No rerun or silent continuation')
    if sha(output / 'protocol.json') != manifest['protocol_sha256']:
        raise ValueError('Protocol drift')
    if not all(sha(Path(path)) == expected for path, expected in manifest['implementation_sha256'].items()):
        raise ValueError('Implementation drift')
    for task in manifest['tasks']:
        for name in ('domain', 'problem'):
            if sha(output / 'tasks' / task['id'] / (name + '.pddl')) != task[name + '_sha256']:
                raise ValueError('Input drift')
    budget = manifest['budget']
    remaining = (datetime.fromisoformat(budget['whole_goal_stop_before_utc'].replace('Z', '+00:00')) - datetime.now(timezone.utc)).total_seconds()
    if remaining < len(manifest['tasks']) * budget['wall_seconds_per_process'] + 600:
        raise ValueError('Insufficient time for whole registered diagnostic and cleanup')
    rows = []
    for task in manifest['tasks']:
        source = output / 'tasks' / task['id']
        target = output / 'searches' / task['id']
        target.mkdir(parents=True)
        command = [sys.executable, '-X', 'utf8', '-m', 'rcnc', 'plan', '--worker', '--solver', 'state_projected',
            '--domain', str(source / 'domain.pddl'), '--problem', str(source / 'problem.pddl'),
            '--output', str(target), '--budget', json.dumps(budget['search'])]
        started = time.monotonic()
        with (target / 'worker.log').open('w', encoding='utf-8') as log:
            try:
                child = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT,
                    timeout=budget['wall_seconds_per_process'])
                search = json.loads((target / 'search.json').read_text(encoding='utf-8')) if (target / 'search.json').exists() else {'status': 'worker_error'}
                search['worker_exit_code'] = child.returncode
            except subprocess.TimeoutExpired:
                search = {'status': 'time_limit'}
                if (target / 'progress.json').exists():
                    search['last_progress'] = json.loads((target / 'progress.json').read_text(encoding='utf-8'))
        rows.append({**task, **search, 'elapsed_seconds': time.monotonic() - started})
        save(output / 'progress.json', {'completed': len(rows), 'task_count': len(manifest['tasks']), 'rows': rows})
    report = {'status': 'complete', 'task_count': len(rows), 'rows': rows,
        'status_counts': dict(Counter(row['status'] for row in rows)), 'manifest_sha256': sha(output / 'manifest.json'),
        'inputs_unchanged': all(sha(output / 'tasks' / row['id'] / (name + '.pddl')) == row[name + '_sha256'] for row in rows for name in ('domain', 'problem')),
        'implementation_unchanged': all(sha(Path(path)) == expected for path, expected in manifest['implementation_sha256'].items()),
        'scope': manifest['scope']}
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--protocol', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--prepare-only', action='store_true')
    parser.add_argument('--execute-frozen', action='store_true')
    args = parser.parse_args()
    if args.prepare_only and args.execute_frozen:
        parser.error('Choose preparation or execution')
    result = None if args.execute_frozen else prepare(args.protocol, args.output)
    if not args.prepare_only:
        result = execute(args.output)
    print(json.dumps({k: v for k, v in result.items() if k not in ('tasks', 'rows', 'implementation_sha256')}, indent=2))

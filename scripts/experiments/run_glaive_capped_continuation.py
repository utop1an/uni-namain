"""Explicitly registered continuation after the user's concurrency change.

Reuse terminal checkpoint rows verbatim. Run only unfinished initial slots,
then the unchanged, once-only timeout retry policy, inside a private cgroup.
"""
import argparse
from collections import Counter
from datetime import datetime
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
from types import SimpleNamespace

WORKERS = 8
MEMORY_HIGH = 10 * 1024**3
MEMORY_MAX = 12 * 1024**3
SWAP_MAX = 1024**3
SHA = '18fe40166ef5ea3bddd58395f5e8739232a1cf6a1b8ec808a9c1e37fd5a94041'


def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(spec)
    sys.modules[name] = m
    spec.loader.exec_module(m)
    return m


def merge_initial(tasks, retained, fresh):
    registered = {(t['kind'], t['id']): t for t in tasks}
    if len(registered) != len(tasks):
        raise ValueError('Duplicate registered identity')
    combined = {}
    for row in retained+fresh:
        key = (row['kind'], row['id'])
        if key not in registered or key in combined:
            raise ValueError('Duplicate or unregistered continuation result')
        for field in ('domain', 'problem', 'condition', 'mapping', 'source_plan'):
            if field in registered[key] and row.get(field) != registered[key][field]:
                raise ValueError('Continuation changed frozen task input')
        combined[key] = row
    for key, task in registered.items():
        if key not in combined and task.get('status') not in (None, 'ready'):
            combined[key] = {**task, 'valid': False, 'native_valid': False,
                             'search': {'status': task['status'], 'search_calls': 0}}
    if set(combined) != set(registered):
        raise ValueError('Unfinished registered initial slots')
    return sorted(combined.values(), key=lambda r: r['id'])


def prepare(root, previous, controls):
    if root.exists():
        raise ValueError('Fresh versioned continuation required')
    e = load(previous/'executor.py', '_glaive_executor')
    p = e.read(previous/'protocol.json')
    assert e.sha(previous/'protocol.json') == (previous/'PROTOCOL.sha256').read_text().strip()
    assert e.read(previous/'interruption_receipt.json')['status'] == 'interrupted_for_user_concurrency_change'
    control = e.read(controls)
    assert control['status'] == 'passed' and control['workers'] == WORKERS
    assert control['shared_memory_max_bytes'] == MEMORY_MAX and control['jar_sha256'] == SHA
    assert e.sha(p['runtime_jar']) == SHA
    files = dict(p['input_sha256'])
    for path, h in files.items():
        assert e.sha(path) == h, path
    root.mkdir(parents=True)
    for name in ('selected_groups.json', 'sources.json', 'worlds.json', 'baseline_tasks.json',
                 'implementation.py', 'review.py', 'repeat_01/original_tasks.json',
                 'repeat_01/composition_tasks.json', 'repeat_01/compilation_report.json',
                 'repeat_01/compiled_freeze.json', 'repeat_01/references.json'):
        target = root/name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(previous/name, target)
    for src in (previous/'repeat_01/groups').glob('*/compilation.json'):
        target = root/src.relative_to(previous)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, target)
    retained, sources, interrupted = {}, {}, []
    for stage, count in e.EXPECTED.items():
        registry = previous/'registered_jobs'/f'{stage}.json'
        tasks = e.read(registry)['tasks']
        assert len(tasks) == count
        e.write(root/'registered_jobs'/f'{stage}.json', {'tasks': tasks})
        report = previous/'initial15/repeat_01'/f'{stage}_report.json'
        events = previous/'initial15'/f'{stage}_events.jsonl'
        if report.exists():
            retained[stage] = e.read(report)['rows']
            sources[stage] = str(report.resolve())
        elif events.exists():
            # Preserve a possible interrupted last line separately, never accept it.
            retained[stage] = []
            lines = events.read_text(encoding='utf-8').splitlines()
            for i, line in enumerate(lines):
                try:
                    retained[stage].append(json.loads(line))
                except json.JSONDecodeError:
                    if i != len(lines)-1:
                        raise
            sources[stage] = str(events.resolve())
        else:
            retained[stage] = []
        ids = {r['id'] for r in retained[stage]}
        assert len(ids) == len(retained[stage]) and ids <= {t['id'] for t in tasks}
        assert all(r['kind'] == stage for r in retained[stage])
        execution = previous/'initial15/repeat_01/execution'/stage
        if execution.exists():
            for folder in execution.iterdir():
                if folder.is_dir() and folder.name not in ids:
                    interrupted.append({'stage': stage, 'id': folder.name, 'path': str(folder.resolve()),
                        'status': 'interrupted_before_terminal_row', 'retained_as_success': False})
        for path in (registry, report, events):
            if path.exists():
                files[str(path.resolve())] = e.sha(path)
    e.write(root/'checkpoint_rows.json', {'rows_by_stage': retained, 'source_files': sources,
        'interrupted_attempts': interrupted, 'reuse_is_explicit_continuation': True})
    for name in ('protocol.json', 'execution_start.json', 'interruption_receipt.json',
                 'launcher_exit.json', 'kernel_before.json', 'kernel_after.json'):
        files[str((previous/name).resolve())] = e.sha(previous/name)
    files[str(controls.resolve())] = e.sha(controls)
    shutil.copyfile(previous/'executor.py', root/'executor.py')
    shutil.copyfile(previous/'runner.py', root/'supervisor.py')
    shutil.copyfile(__file__, root/'runner.py')
    shutil.copyfile(Path(__file__).with_name('launch_glaive_cgroup.py'), root/'launcher.py')
    (root/'runtime').mkdir()
    shutil.copyfile(e.local(p['runtime_jar']), root/'runtime/glaive-initialization.jar')
    files.update({str(f.resolve()): e.sha(f) for f in root.rglob('*') if f.is_file()})
    budgets = {**p['budgets'], 'planner_workers': WORKERS,
               'shared_memory_high_bytes': MEMORY_HIGH, 'shared_memory_max_bytes': MEMORY_MAX,
               'shared_swap_max_bytes': SWAP_MAX}
    protocol = {**p, 'status': 'frozen_offline_concurrency8_continuation', 'created_utc': e.now(),
        'condition': 'explicit_two_to_eight_worker_continuation_with_shared_memory_cap',
        'checkpoint_root': str(previous.resolve()), 'runtime_jar': str((root/'runtime/glaive-initialization.jar').resolve()),
        'input_sha256': files, 'budgets': budgets,
        'retained_rows': {s: len(rows) for s, rows in retained.items()},
        'interrupted_attempts': interrupted, 'not_original_fresh_budget_completion': True,
        'user_authorization': 'User explicitly permitted switching the remaining work to 8 workers.',
        'policies': p['policies']+[
            'This is an explicitly labeled continuation, not completion of the original fresh two-worker condition.',
            'Retain completed checkpoint rows verbatim. Unfinished initial slots execute in the new output root.',
            'All interrupted invocations remain in the checkpoint; no interrupted result is promoted to success.',
            'Eight workers, unchanged 4096 MB Java heap and 15/60 second call limits. Shared cgroup: high 10 GiB, max 12 GiB, swap max 1 GiB.',
            'Memory pressure throttles the group. Any cgroup resource failure remains unknown and is not retried as a timeout.',
            'Python orchestration has lower OOM priority than Java, so individual resource failures can be recorded.',
            'No LLM calls, no backfill, no input repair, and no hidden retries.']}
    e.write(root/'protocol.json', protocol)
    (root/'PROTOCOL.sha256').write_text(e.sha(root/'protocol.json')+'\n', encoding='utf-8')
    e.progress(root, status='prepared', stage='registered_continuation', retained_rows=protocol['retained_rows'])
    print(json.dumps({'status': 'prepared', 'retained': protocol['retained_rows'],
                      'interrupted_attempts': interrupted, 'workers': WORKERS}), flush=True)


def bind_supervisor(root):
    m = load(root/'supervisor.py', '_capped_supervisor')
    e = m.load(root/'executor.py')
    original = subprocess.Popen

    def java_popen(*args, **kwargs):
        proc = original(*args, **kwargs)
        command = args[0] if args else kwargs.get('args', [])
        if command and command[0] == 'java':
            path = Path('/proc', str(proc.pid), 'oom_score_adj')
            path.write_text('500')
            if path.read_text().strip() != '500':
                proc.kill()
                proc.wait()
                raise RuntimeError('Failed to set Java OOM priority')
        return proc

    m.subprocess = SimpleNamespace(Popen=java_popen, STDOUT=subprocess.STDOUT,
                                   TimeoutExpired=subprocess.TimeoutExpired)
    e.invoke = m.invoke
    return e


def run(root):
    e = bind_supervisor(root)
    isolation = e.isolation()
    p = e.read(root/'protocol.json')
    cgroup = Path(os.environ['GLAIVE_WORKLOAD_CGROUP'])
    limits = {name: (cgroup/name).read_text().strip() for name in ('memory.high', 'memory.max', 'memory.swap.max')}
    assert limits == {'memory.high': str(MEMORY_HIGH), 'memory.max': str(MEMORY_MAX), 'memory.swap.max': str(SWAP_MAX)}
    assert Path('/proc/self/oom_score_adj').read_text().strip() == '-500'
    isolation.update(shared_cgroup=str(cgroup), shared_memory_limits=limits, workers=WORKERS)
    assert e.sha(root/'protocol.json') == (root/'PROTOCOL.sha256').read_text().strip()
    assert e.sha(p['runtime_jar']) == SHA
    assert not (root/'execution_start.json').exists()
    assert all(e.sha(path) == h for path, h in p['input_sha256'].items())
    e.write(root/'execution_start.json', {'started_utc': e.now(), 'isolation': isolation})
    started = time.monotonic()
    checkpoints = e.read(root/'checkpoint_rows.json')['rows_by_stage']
    jar = e.local(p['runtime_jar'])
    timing, initial, alltasks = {}, {}, {}
    for stage, count in e.EXPECTED.items():
        tasks = e.read(root/'registered_jobs'/f'{stage}.json')['tasks']
        alltasks[stage] = {t['id']: t for t in tasks}
        ids = {r['id'] for r in checkpoints[stage]}
        ready = [t for t in tasks if t.get('status') in (None, 'ready') and t['id'] not in ids]
        jobs = [{'root': str(root/'initial15'), 'task': t, 'seconds': 15, 'worker_seconds': 55,
                 'condition': 'explicit_capped_eight_worker_continuation15'} for t in ready]
        fresh, elapsed = e.execute(root/'resumed15', jobs, jar, WORKERS, stage)
        rows = merge_initial(tasks, checkpoints[stage], fresh)
        assert len(rows) == count
        initial[stage] = rows
        timing['resumed15_'+stage] = elapsed
        e.write(root/'initial15/repeat_01'/f'{stage}_report.json', {'status': 'complete_registered_slots', 'registered_slots': count, 'rows': rows})
        events = [r for r in rows if alltasks[stage][r['id']].get('status') in (None, 'ready')]
        with (root/'initial15'/f'{stage}_events.jsonl').open('x', encoding='utf-8') as f:
            for row in events:
                f.write(json.dumps(e.external(row), ensure_ascii=False)+'\n')
    retryjobs, registry = [], {}
    for stage, rows in initial.items():
        registry[stage] = []
        for row in rows:
            reason = e.retry_reason(row)
            if not reason:
                continue
            job = {'root': str(root/'retry60'), 'task': alltasks[stage][row['id']], 'seconds': 60,
                   'worker_seconds': 180, 'condition': 'capped_eight_worker_timeout60_once', 'reason': reason}
            if reason == 'replay_timeout':
                job.update(replay_plan=row['plan'], retained_search=row['search'])
            retryjobs.append(job)
            registry[stage].append(row['id'])
    retryjobs.sort(key=lambda j: e.hashlib.sha256(('optimized-retry-v1/'+j['task']['id']).encode()).hexdigest())
    e.write(root/'retry_registry.json', {'registered': len(retryjobs), 'by_stage': registry, 'jobs': retryjobs})
    retried, elapsed = e.execute(root/'retry60', retryjobs, jar, WORKERS, 'retry')
    timing['retry60'] = elapsed
    for stage, rows in e.merge_retry_results(initial, retried).items():
        e.write(root/'repeat_01'/f'{stage}_report.json', {'status': 'complete_registered_slots', 'registered_slots': len(rows), 'rows': rows})
    assert all(e.sha(path) == h for path, h in p['input_sha256'].items())
    finished = e.now()
    previous = e.local(p['checkpoint_root'])
    old_start = datetime.fromisoformat(e.read(previous/'execution_start.json')['started_utc'])
    old_end = datetime.fromisoformat(e.read(previous/'launcher_exit.json')['finished_utc'])
    new_start = datetime.fromisoformat(e.read(root/'execution_start.json')['started_utc'])
    total = (datetime.fromisoformat(finished)-old_start).total_seconds()
    e.write(root/'timing.json', {'stage_wall_seconds': timing, 'total_wall_seconds': total,
        'resumed_execution_wall_seconds': time.monotonic()-started,
        'prior_segment_wall_seconds': (old_end-old_start).total_seconds(),
        'between_segments_wall_seconds': (new_start-old_end).total_seconds(),
        'wall_time_scope': 'From original two-worker execution start to continuation finish, including the explicit switching/preparation gap.',
        'finished_utc': finished, 'inputs_unchanged': True, 'model_requests': 0,
        'retry_slots': len(retryjobs), 'not_original_fresh_budget_completion': True})
    e.progress(root, status='complete', stage='complete', registered_slots=e.EXPECTED,
               elapsed_seconds=total, inputs_unchanged=True, condition=p['condition'])
    print(json.dumps({'status': 'complete', 'wall_seconds': total, 'retry_slots': len(retryjobs), 'model_requests': 0}), flush=True)


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('mode', choices=['prepare', 'run'])
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--previous', type=Path)
    p.add_argument('--controls', type=Path)
    a = p.parse_args()
    if a.mode == 'prepare':
        prepare(a.output.resolve(), a.previous.resolve(), a.controls.resolve())
    else:
        run(a.output.resolve())

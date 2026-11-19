"""Frozen timeout census and bounded, offline concurrency/GC contrasts."""
import argparse
from collections import Counter, defaultdict
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import threading
import time
from types import SimpleNamespace

STAGES = ('native', 'transport', 'anchor', 'composition')


def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x', encoding='utf-8') as f:
        json.dump(value, f, ensure_ascii=False, indent=2)


def key(row):
    return row['kind'], row['id']


def phase(row):
    events = row.get('search', {}).get('phase_events', [])
    return events[-1]['phase'] if events else 'no_phase'


def order(row):
    return hashlib.sha256(('pressure-v1|'+'|'.join(key(row))).encode()).hexdigest()


def select(rows, losses):
    indexed = {key(row): row for row in rows}
    chosen = {k: indexed[k] for k in losses}
    for target in ('state_space_begin', 'search_setup_begin', 'search_begin', 'result'):
        pool = sorted((r for r in rows if phase(r) == target and key(r) not in chosen), key=order)
        buckets = defaultdict(list)
        for row in pool:
            buckets[(row['kind'], row['condition'])].append(row)
        while sum(phase(r) == target for r in chosen.values()) < 8:
            progress = False
            for bucket in sorted(buckets):
                if buckets[bucket] and sum(phase(r) == target for r in chosen.values()) < 8:
                    row = buckets[bucket].pop(0)
                    chosen[key(row)] = row
                    progress = True
            if not progress:
                raise ValueError('Insufficient frozen stratum')
    assert len(chosen) == 32
    return sorted(chosen.values(), key=lambda r: (key(r) not in losses, order(r)))


def census(root, previous):
    if root.exists():
        raise ValueError('Fresh census required')
    comparison = read(previous/'comparison_v1/report.json')
    losses = {(r['stage'], r['id']) for r in comparison['previously_valid_not_returned'] if r['budget'] == 'final'}
    registry, timeout_rows, files = {}, [], {}
    for stage in STAGES:
        for name in ('repeat_01/'+stage+'_report.json', 'registered_jobs/'+stage+'.json'):
            path = previous/name
            files[str(path.resolve())] = sha(path)
        for task in read(previous/'registered_jobs'/f'{stage}.json')['tasks']:
            registry[key(task)] = task
        timeout_rows += [r for r in read(previous/'repeat_01'/f'{stage}_report.json')['rows']
                         if r.get('search', {}).get('status') == 'wall_time_limit']
    assert len(timeout_rows) == 586 and len(losses) == 4
    sample = select(timeout_rows, losses)
    for name in ('comparison_v1/report.json', 'protocol.json', 'timing.json', 'cgroup_after.json'):
        files[str((previous/name).resolve())] = sha(previous/name)
    tasks = [registry[key(r)] for r in sample]
    for task in tasks:
        for field in ('domain', 'problem', 'mapping', 'source_plan'):
            if task.get(field):
                files[task[field]] = sha(task[field])
    path = previous/'runtime/glaive-initialization.jar'
    files[str(path.resolve())] = sha(path)
    write(root/'selection.json', {'status': 'frozen_timeout_selection', 'parent': str(previous.resolve()),
        'registered_timeouts': 586, 'selected': 32, 'tasks': tasks, 'historical_rows': sample,
        'loss_keys': sorted(losses), 'phase_counts': dict(Counter(phase(r) for r in timeout_rows)),
        'sample_phase_counts': dict(Counter(phase(r) for r in sample)),
        'jar': str(path.resolve()), 'input_sha256': files,
        'scope': 'All four regressions plus eight tasks per terminal-phase stratum. Development subset, not a full denominator improvement claim.',
        'selection': 'Frozen hash ordering, round-robin stage/condition within each phase; no outcome-dependent replacement.',
        'model_requests': 0})
    print(json.dumps({'selected': len(tasks), 'phases': dict(Counter(phase(r) for r in timeout_rows))}), flush=True)


def prepare(root, selection, workers, flags, telemetry_classes, jar=None, selected_all=False, gates=(), memory_high_mb=10240, losses_only=False):
    if root.exists():
        raise ValueError('Fresh condition required')
    s = read(selection)
    previous = Path(s['parent'])
    files = dict(s['input_sha256'])
    for path, digest in files.items():
        assert sha(path) == digest, path
    tasks = s['tasks']
    assert not (selected_all and losses_only)
    if losses_only:
        losses = {tuple(k) for k in s['loss_keys']}
        tasks = [t for t in tasks if key(t) in losses]
        assert len(tasks) == 4
    if selected_all:
        keys = set()
        for stage in STAGES:
            keys.update(key(r) for r in read(previous/'repeat_01'/f'{stage}_report.json')['rows']
                        if r.get('search', {}).get('status') == 'wall_time_limit')
        tasks = [t for stage in STAGES for t in read(previous/'registered_jobs'/f'{stage}.json')['tasks'] if key(t) in keys]
        assert len(tasks) == 586
        for task in tasks:
            for field in ('domain', 'problem', 'mapping', 'source_plan'):
                if task.get(field): files[task[field]] = sha(task[field])
    root.mkdir(parents=True)
    for source, name in ((previous/'executor.py', 'executor.py'), (previous/'supervisor.py', 'supervisor.py'),
                         (Path(__file__), 'runner.py'), (Path(__file__).with_name('launch_glaive_cgroup.py'), 'launcher.py')):
        shutil.copyfile(source, root/name)
    runtime = Path(jar) if jar else Path(s['jar'])
    if jar and not gates:
        raise ValueError('A changed runtime requires a passing regression gate')
    for gate in gates:
        report = read(gate)
        assert report['status'] == 'passed' and report['inputs_unchanged']
        assert sha(runtime) in read(gate.parent/'protocol.json')['input_sha256'].values()
        files[str(gate.resolve())] = sha(gate)
        files[str((gate.parent/'protocol.json').resolve())] = sha(gate.parent/'protocol.json')
    shutil.copyfile(runtime, root/'runtime.jar')
    files[str(runtime.resolve())] = sha(runtime)
    shutil.copytree(telemetry_classes, root/'telemetry_classes')
    files[str(selection.resolve())] = sha(selection)
    for path in root.rglob('*'):
        if path.is_file(): files[str(path.resolve())] = sha(path)
    for path in (Path('data/research_release/narrative_baseline_priority1_2026_11_05_v1/code')).rglob('*.py'):
        files[str(path.resolve())] = sha(path)
    protocol = {'status': 'frozen_before_pressure_contrast', 'tasks': tasks, 'registered': len(tasks),
        'workers': workers, 'jvm_flags': flags, 'seconds': 60, 'worker_seconds': 180,
        'heap_mb': 4096, 'shared_memory_high_bytes': memory_high_mb*1024**2, 'shared_memory_max_bytes': 12*1024**3,
        'shared_swap_max_bytes': 1024**3, 'runtime_jar': str((root/'runtime.jar').resolve()),
        'input_sha256': files, 'selection': str(selection.resolve()), 'losses_only': losses_only, 'gates': [str(g.resolve()) for g in gates], 'model_requests': 0,
        'scope': 'Fresh standalone diagnostic condition. Same frozen tasks and validation; no retries or continuation. One-second stack/heap/GC telemetry and quarter-second cgroup sampling in all arms.'}
    write(root/'protocol.json', protocol)
    (root/'PROTOCOL.sha256').write_text(sha(root/'protocol.json')+'\n', encoding='utf-8')
    print(json.dumps({'prepared': str(root), 'registered': len(tasks), 'workers': workers, 'flags': flags}), flush=True)


def run(root):
    m = load(root/'supervisor.py', '_pressure_supervisor')
    e = m.load(root/'executor.py')
    isolation = e.isolation()
    p = read(root/'protocol.json')
    assert sha(root/'protocol.json') == (root/'PROTOCOL.sha256').read_text().strip()
    assert all(e.sha(path) == digest for path, digest in p['input_sha256'].items())
    group = Path(os.environ['GLAIVE_WORKLOAD_CGROUP'])
    assert int((group/'memory.high').read_text()) == p['shared_memory_high_bytes']
    assert int((group/'memory.max').read_text()) == p['shared_memory_max_bytes']
    original = subprocess.Popen

    def java_popen(command, **kwargs):
        command = list(command)
        if command[0] == 'java':
            output = Path(kwargs['stdout'].name).parent
            cp = command.index('-cp')+1
            command[cp] = str(root/'telemetry_classes')+os.pathsep+command[cp]
            main = command.index('GlaiveOptimized')
            command[main:main+1] = ['GlaiveRuntimeTelemetry', str(output/'telemetry.jsonl')]
            command[1:1] = p['jvm_flags']+['-Xlog:gc*,safepoint:file='+str(output/'gc.log')+':uptime,level,tags']
            e.write(output/'effective_command.json', {'command': command, 'model_requests': 0})
        proc = original(command, **kwargs)
        if command[0] == 'java':
            target = Path('/proc', str(proc.pid), 'oom_score_adj')
            target.write_text('500')
            assert target.read_text().strip() == '500'
        return proc

    m.subprocess = SimpleNamespace(Popen=java_popen, STDOUT=subprocess.STDOUT, TimeoutExpired=subprocess.TimeoutExpired)
    e.invoke = m.invoke
    started = time.monotonic()
    e.write(root/'execution_start.json', {'started_utc': e.now(), 'isolation': isolation, 'private_cgroup': str(group)})
    stop = threading.Event()

    def observe():
        with (root/'pressure.jsonl').open('x', encoding='utf-8') as f:
            while not stop.is_set():
                record = {'seconds': time.monotonic()-started, 'utc': e.now()}
                for name in ('memory.current', 'memory.peak', 'memory.swap.current', 'memory.events', 'memory.pressure', 'cpu.stat'):
                    record[name] = (group/name).read_text().strip()
                processes = []
                for pid in (group/'cgroup.procs').read_text().split():
                    try:
                        path = Path('/proc', pid)
                        if (path/'comm').read_text().strip() != 'java': continue
                        stat = (path/'stat').read_text().rsplit(')', 1)[1].split()
                        processes.append({'pid': int(pid), 'cpu_ticks': int(stat[11])+int(stat[12]), 'rss_pages': int(stat[21])})
                    except (FileNotFoundError, ProcessLookupError): pass
                record['java'] = processes
                f.write(json.dumps(record)+'\n'); f.flush()
                stop.wait(.25)
    observer = threading.Thread(target=observe, daemon=True)
    observer.start()
    try:
        jobs = [{'root': str(root), 'task': t, 'seconds': 60, 'worker_seconds': 180, 'condition': root.name} for t in p['tasks']]
        rows, elapsed = e.execute(root, jobs, root/'runtime.jar', p['workers'], 'diagnostic')
    finally:
        stop.set(); observer.join()
    assert len(rows) == p['registered'] and len({key(r) for r in rows}) == len(rows)
    assert all(e.sha(path) == digest for path, digest in p['input_sha256'].items())
    e.write(root/'report.json', {'status': 'complete_pressure_contrast', 'registered': len(rows), 'rows': rows,
        'workers': p['workers'], 'jvm_flags': p['jvm_flags'], 'seconds': elapsed,
        'inputs_unchanged': True, 'model_requests': 0})
    print(json.dumps({'status': 'complete_pressure_contrast', 'registered': len(rows), 'dual': sum(bool(r.get('valid')) for r in rows),
        'native': sum(bool(r.get('native_valid')) for r in rows), 'seconds': elapsed}), flush=True)


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('mode', choices=['census', 'prepare', 'run'])
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--previous', type=Path)
    p.add_argument('--selection', type=Path)
    p.add_argument('--workers', type=int, choices=[1, 2, 8], default=2)
    p.add_argument('--jvm-flag', action='append', default=[])
    p.add_argument('--telemetry-classes', type=Path)
    p.add_argument('--jar', type=Path)
    p.add_argument('--all-timeouts', action='store_true')
    p.add_argument('--gate', type=Path, action='append', default=[])
    p.add_argument('--memory-high-mb', type=int, choices=[1536, 10240, 12288], default=10240)
    p.add_argument('--losses-only', action='store_true')
    a = p.parse_args()
    if a.mode == 'census': census(a.output.resolve(), a.previous.resolve())
    elif a.mode == 'prepare': prepare(a.output.resolve(), a.selection.resolve(), a.workers, a.jvm_flag, a.telemetry_classes.resolve(), a.jar, a.all_timeouts, a.gate, a.memory_high_mb, a.losses_only)
    else: run(a.output.resolve())

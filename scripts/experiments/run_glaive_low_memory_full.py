"""Offline 1200-group rerun with two workers and explicit process deadlines.

Reuse the frozen orchestrator and validators. Only process supervision and
resource receipts change; model, problem, mapping and reference bytes do not.
"""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import platform
import shutil
import signal
import subprocess
import sys
import threading
import time

E = None
WORKERS = 2
HEAP_MB = 4096
CANDIDATE_SHA = '18fe40166ef5ea3bddd58395f5e8739232a1cf6a1b8ec808a9c1e37fd5a94041'


def load(path):
    global E
    spec = importlib.util.spec_from_file_location('_glaive_executor', path)
    E = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = E
    spec.loader.exec_module(E)
    return E


def memory():
    result = {}
    for line in Path('/proc/meminfo').read_text().splitlines():
        key, value = line.split(':', 1)
        if key in ('MemTotal', 'MemAvailable', 'SwapTotal', 'SwapFree'):
            result[key+'_kb'] = int(value.split()[0])
    return result


def signal_group(proc, sig):
    try:
        os.killpg(proc.pid, sig)
    except ProcessLookupError:
        pass


def supervise(cmd, log_path, seconds, grace=2.0, started=None):
    """A signal exit alone never implies a deadline; retain explicit cause."""
    if os.name == 'nt':
        raise RuntimeError('Linux process groups required')
    stopped = threading.Event()
    sample = {'peak_sampled_rss_kb': 0, 'peak_reported_hwm_kb': 0,
              'minimum_host_available_kb': memory()['MemAvailable_kb'], 'samples': 0}
    start = time.monotonic()
    timeout_triggered = False
    hard_kill = False
    with Path(log_path).open('wb') as stream:
        proc = subprocess.Popen(cmd, stdout=stream, stderr=subprocess.STDOUT, start_new_session=True)
        stat = Path('/proc', str(proc.pid), 'stat').read_text().rsplit(')', 1)[1].split()
        receipt = {'pid': proc.pid, 'start_ticks': stat[19], 'boot_id': Path('/proc/sys/kernel/random/boot_id').read_text().strip()}
        if E is not None:
            E.ACTIVE = proc
        if started is not None:
            started(receipt)

        def observe():
            while not stopped.is_set():
                try:
                    for line in Path('/proc', str(proc.pid), 'status').read_text().splitlines():
                        if line.startswith('VmRSS:'):
                            sample['peak_sampled_rss_kb'] = max(sample['peak_sampled_rss_kb'], int(line.split()[1]))
                        if line.startswith('VmHWM:'):
                            sample['peak_reported_hwm_kb'] = max(sample['peak_reported_hwm_kb'], int(line.split()[1]))
                    sample['minimum_host_available_kb'] = min(sample['minimum_host_available_kb'], memory()['MemAvailable_kb'])
                    sample['samples'] += 1
                except (FileNotFoundError, ProcessLookupError):
                    break
                stopped.wait(.2)

        observer = threading.Thread(target=observe, daemon=True)
        observer.start()
        try:
            try:
                code = proc.wait(timeout=max(.001, seconds-(time.monotonic()-start)))
            except subprocess.TimeoutExpired:
                timeout_triggered = True
                signal_group(proc, signal.SIGTERM)
                try:
                    code = proc.wait(timeout=grace)
                except subprocess.TimeoutExpired:
                    hard_kill = True
                    signal_group(proc, signal.SIGKILL)
                    code = proc.wait()
        finally:
            if proc.poll() is None:
                signal_group(proc, signal.SIGKILL)
                proc.wait()
            stopped.set()
            observer.join(timeout=1)
            if E is not None:
                E.ACTIVE = None
    return {**receipt, **sample, 'seconds': time.monotonic()-start, 'returncode': code,
            'deadline_triggered': timeout_triggered, 'deadline_hard_kill': hard_kill,
            'sampling_interval_seconds': .2, 'memory_after': memory()}


def process_status(receipt, log):
    if receipt['deadline_triggered']:
        return 'wall_time_limit'
    if 'OutOfMemoryError' in log:
        return 'memory_limit'
    if 'ParseException' in log or 'FormatException' in log:
        return 'native_parse_error'
    if receipt['returncode'] < 0 or receipt['returncode'] == 137:
        return 'terminated_by_signal'
    return 'runtime_error'


def invoke(jar, domain, problem, output, *, mode='search', seconds=15, classes=None, plan=None):
    output = E.local(output)
    output.mkdir(parents=True, exist_ok=False)
    inputs = {E.external(E.local(p).resolve()): E.sha(p) for p in (jar, domain, problem)}
    if plan is not None:
        inputs[E.external(E.local(plan).resolve())] = E.sha(plan)
    target = output/'plan.pddl' if mode == 'search' else E.local(plan)
    cmd = ['java', '-Xmx4096m', '-cp', str(E.local(jar)), 'GlaiveOptimized', mode,
           str(E.local(domain)), str(E.local(problem)), str(target), str(seconds)]
    E.write(output/'invocation.json', {'command': cmd, 'mode': mode, 'seconds': seconds,
                                     'input_sha256': inputs, 'memory_mb': HEAP_MB,
                                     'supervisor': 'explicit_python_deadline_with_two_second_cleanup'})
    receipt = supervise(cmd, output/'stdout.txt', seconds,
                        started=lambda r: E.write(output/'process_start.json', {**r, 'started_utc': E.now(), 'memory_before': memory()}))
    E.write(output/'process_exit.json', {**receipt, 'finished_utc': E.now()})
    log = (output/'stdout.txt').read_text(encoding='utf-8', errors='replace')
    events = []
    for line in log.splitlines():
        if line.startswith('{'):
            try:
                events.append(json.loads(line))
            except json.JSONDecodeError:
                pass
    result = {'status': process_status(receipt, log), 'returncode': receipt['returncode'],
              'seconds': receipt['seconds'], 'mode': mode, 'search_calls': int(mode == 'search'),
              'input_sha256': inputs, 'phase_events': events, 'process_receipt': receipt}
    if receipt['returncode'] == 0 and not receipt['deadline_triggered']:
        terminal = [e for e in events if e.get('phase') == 'result']
        if terminal:
            result.update({k: v for k, v in terminal[-1].items() if k not in ('phase', 'elapsed_seconds')})
    if result['status'] == 'solved' and not target.exists():
        raise ValueError('Missing returned plan')
    if any(E.sha(p) != h for p, h in inputs.items()):
        raise ValueError('Invocation changed input')
    E.write(output/'result.json', result)
    return result


def prepare(root, parent, historical, jar, gate, executor, controls, aborted=None):
    e = load(executor)
    if root.exists():
        raise ValueError('Fresh versioned output required')
    if e.sha(jar) != CANDIDATE_SHA:
        raise ValueError('Runtime differs from the previously validated candidate')
    regression = e.read(gate/'report.json')
    assert regression['status'] == 'passed' and regression['passed'] == 8360 and regression['failed'] == 0
    assert e.sha(e.read(gate/'protocol.json')['jar']) == CANDIDATE_SHA
    assert e.read(controls)['status'] == 'passed'
    root.mkdir(parents=True)
    files = {}
    for relative in ('selected_groups.json', 'sources.json', 'worlds.json', 'baseline_tasks.json',
                     'repeat_01/original_tasks.json', 'repeat_01/composition_tasks.json',
                     'repeat_01/compilation_report.json', 'repeat_01/compiled_freeze.json', 'repeat_01/references.json',
                     'implementation.py', 'review.py'):
        dest = root/relative
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(parent/relative, dest)
        files[str((parent/relative).resolve())] = e.sha(parent/relative)
    for path in (parent/'repeat_01/groups').glob('*/compilation.json'):
        dest = root/path.relative_to(parent)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(path, dest)
    for stage, n in e.EXPECTED.items():
        path = parent/'registered_jobs'/(stage+'.json')
        tasks = e.read(path)['tasks']
        assert len(tasks) == len({t['id'] for t in tasks}) == n
        e.write(root/'registered_jobs'/(stage+'.json'), {'tasks': tasks})
        files[str(path.resolve())] = e.sha(path)
        for task in tasks:
            for name in ('domain', 'problem', 'mapping', 'source_plan'):
                if task.get(name) and task[name] not in files:
                    files[task[name]] = e.sha(task[name])
        for base in (parent, historical):
            path = base/'repeat_01'/(stage+'_report.json')
            files[str(path.resolve())] = e.sha(path)
    for path, h in e.read(parent/'repeat_01/compiled_freeze.json')['input_sha256'].items():
        if e.sha(path) != h:
            raise ValueError('Frozen compiled input changed')
        files[path] = h
    for path in (e.local(e.RELEASE)/'code').rglob('*.py'):
        files[str(path.resolve())] = e.sha(path)
    runtime = root/'runtime/glaive-initialization.jar'
    runtime.parent.mkdir()
    shutil.copyfile(jar, runtime)
    shutil.copyfile(executor, root/'executor.py')
    shutil.copyfile(__file__, root/'runner.py')
    for path in (jar, gate/'report.json', gate/'protocol.json', controls, parent/'protocol.json', parent/'timing.json'):
        files[str(path.resolve())] = e.sha(path)
    if aborted is not None:
        assert e.read(aborted/'abort_receipt.json')['status'] == 'aborted_search_initialization_regression'
        accounting = e.read(aborted/'aborted_slot_accounting.json')
        assert accounting['not_a_completed_full_run'] is True
        for path, digest in accounting['input_sha256'].items():
            assert e.sha(path) == digest
            files[path] = digest
        for name in ('abort_receipt.json', 'aborted_slot_accounting.json', 'execution_start.json',
                     'launcher_exit.json', 'kernel_before.json', 'kernel_after.json', 'protocol.json'):
            files[str((aborted/name).resolve())] = e.sha(aborted/name)
    files.update({str(p.resolve()): e.sha(p) for p in root.rglob('*') if p.is_file()})
    protocol = {'status': 'frozen_before_low_memory_full_rerun', 'created_utc': e.now(), 'groups': 1200,
                'condition': 'initialization_optimized_two_workers_fresh15_then_timeout60_once',
                'parent': str(parent.resolve()), 'historical_final': str(historical.resolve()),
                'runtime_jar': str(runtime.resolve()), 'runtime_classes': None, 'regression': str(gate.resolve()),
                'input_sha256': files, 'budgets': {'planner_workers': WORKERS, 'search_seconds': 15,
                    'replay_seconds': 15, 'retry_seconds': 60, 'planning_worker_seconds': 55,
                    'retry_worker_seconds': 180, 'memory_mb_per_worker': HEAP_MB, 'model_requests': 0,
                    'registered_slots': e.EXPECTED},
                'policies': ['All 1200 groups and 28684 registered slots retained; execute every ready slot afresh.',
                             'Models, explicit worlds, goals, mappings, reference choices and validators remain frozen; no backfill.',
                             'Fresh 15 second search/replay attempts, then only explicit deadline timeouts retry once at 60 seconds.',
                             'Replay-only retry retains a solved search and its plan; all other failures and unknowns remain.',
                             'Two concurrent workers, unchanged 4096 MB Java heap; require at least 10 GiB available before execution.',
                             'The supervisor records Java PID, boot identity, actual deadline intervention and sampled RSS/memory.',
                             'Early signal termination is unknown, not automatically a timeout or an authorized retry.',
                             'Loopback-only network namespace, Python network-denial audit and stripped model credentials.',
                             'No new model requests, compilation, input repair or implicit continuation.',
                             'Compare with the corrected prior full run; concurrency differs, so wall-time ratios are descriptive.'],
                'excluded_aborted_conditions': [str(aborted.resolve())] if aborted is not None else [],
                'original_results_preserved': True, 'model_requests': 0}
    e.write(root/'protocol.json', protocol)
    (root/'PROTOCOL.sha256').write_text(e.sha(root/'protocol.json')+'\n', encoding='utf-8')
    e.progress(root, status='prepared', stage='frozen', registered_slots=e.EXPECTED, input_files=len(files))
    print(json.dumps({'status': 'prepared', 'groups': 1200, 'slots': e.EXPECTED, 'workers': WORKERS, 'input_files': len(files), 'model_requests': 0}), flush=True)


def run(root):
    e = load(root/'executor.py')
    p = e.read(root/'protocol.json')
    assert p['budgets']['planner_workers'] == WORKERS
    assert e.sha(p['runtime_jar']) == CANDIDATE_SHA
    if memory()['MemAvailable_kb'] < 10*1024*1024:
        raise RuntimeError('Require 10 GiB available before starting the frozen two-worker run')
    java_pids = []
    for path in Path('/proc').iterdir():
        if path.name.isdigit():
            try:
                if (path/'comm').read_text().strip() == 'java':
                    java_pids.append(int(path.name))
            except FileNotFoundError:
                pass
    if java_pids:
        raise RuntimeError('Other Java workload is running: '+repr(java_pids))
    original_isolation = e.isolation
    def isolated():
        receipt = original_isolation()
        receipt.update(resource_preflight={'memory': memory(), 'other_java_pids': java_pids,
            'boot_id': Path('/proc/sys/kernel/random/boot_id').read_text().strip(),
            'platform': platform.platform(), 'cpus': os.cpu_count(), 'workers': WORKERS, 'heap_mb': HEAP_MB})
        return receipt
    e.isolation = isolated
    e.invoke = invoke
    e.run(root)


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('mode', choices=['prepare', 'run'])
    p.add_argument('--output', type=Path, required=True)
    for name in ('parent', 'historical', 'jar', 'gate', 'executor', 'controls'):
        p.add_argument('--'+name, type=Path)
    p.add_argument('--aborted', type=Path)
    a = p.parse_args()
    if a.mode == 'run':
        run(a.output.resolve())
    else:
        prepare(*[getattr(a, n).resolve() for n in ('output', 'parent', 'historical', 'jar', 'gate', 'executor', 'controls')],
                aborted=a.aborted.resolve() if a.aborted else None)

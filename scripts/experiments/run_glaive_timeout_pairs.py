"""Fresh, offline paired comparison on a frozen pre-initialization timeout set."""
import argparse
from collections import Counter
from concurrent.futures import ProcessPoolExecutor, as_completed
import hashlib
import importlib.util
import json
import os
import platform
from pathlib import Path
import statistics
import sys
import time

E = None
STAGES = ('native', 'transport', 'anchor', 'composition')
EXPECTED = {'native': 6, 'transport': 144, 'anchor': 186, 'composition': 19}


def load(path):
    spec = importlib.util.spec_from_file_location('_glaive_executor', path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def key(row):
    return row['kind'], row['id']


def digest(row):
    return hashlib.sha256(('timeout-pairs-v1|'+'|'.join(key(row))).encode()).hexdigest()


def arm_order(row):
    return ['before', 'after'] if int(digest(row), 16) % 2 == 0 else ['after', 'before']


def select_tasks(selection, registered):
    selected = selection['selected']
    if len(selected) != 355 or Counter(c['kind'] for c in selected) != EXPECTED:
        raise ValueError('Changed frozen timeout denominator')
    if len({key(c) for c in selected}) != len(selected):
        raise ValueError('Duplicate stage identity')
    result = []
    for case in sorted(selected, key=digest):
        task = registered[key(case)]
        if task.get('status') not in (None, 'ready'):
            raise ValueError('Non-ready registered task')
        for name in ('domain', 'problem', 'mapping'):
            if task.get(name) != case['historical'].get(name):
                raise ValueError('Changed task input: '+name)
        result.append({'task': task, 'historical': case['historical'], 'last_phase': case['last_phase'],
                       'arm_order': arm_order(case), 'mode': case['mode']})
    return result


def prepare(root, selection_path, parent, before, after, executor, gates):
    e = load(executor)
    if len(gates) != 4:
        raise ValueError('Require saved-plan, finite, axiom, and negative-control gates')
    selection = e.read(selection_path)
    files = dict(selection['input_sha256'])
    files[str(selection_path)] = e.sha(selection_path)
    registry = {}
    for stage in STAGES:
        path = parent/'registered_jobs'/(stage+'.json')
        files[str(path)] = e.sha(path)
        for task in e.read(path)['tasks']:
            if key(task) in registry:
                raise ValueError('Duplicate registered task')
            registry[key(task)] = task
    pairs = select_tasks(selection, registry)
    if e.sha(before) != e.sha(selection['jar']):
        raise ValueError('Different baseline jar')
    for gate in gates:
        report = e.read(gate)
        if report['status'] != 'passed' or not report['inputs_unchanged']:
            raise ValueError('Regression gate failed: '+str(gate))
        files[str(gate)] = e.sha(gate)
        gate_protocol = gate.parent/'protocol.json'
        gate_inputs = e.read(gate_protocol)['input_sha256']
        if e.sha(after) not in gate_inputs.values():
            raise ValueError('Regression tested another candidate: '+str(gate))
        files[str(gate_protocol)] = e.sha(gate_protocol)
    for path in (e.local(e.RELEASE)/'code').rglob('*.py'):
        files[str(path)] = e.sha(path)
    for pair in pairs:
        for name in ('domain', 'problem', 'mapping'):
            if pair['task'].get(name):
                path = pair['task'][name]
                files[path] = e.sha(path)
        if pair['mode'] == 'replay':
            path = pair['historical']['plan']
            files[path] = e.sha(path)
    for path in (before, after):
        files[str(path)] = e.sha(path)
    for path, expected in files.items():
        if e.sha(path) != expected:
            raise ValueError('Frozen input changed: '+str(path))
    root.mkdir(parents=True, exist_ok=False)
    for source, dest in ((Path(__file__), root/'driver.py'), (executor, root/'executor.py')):
        dest.write_bytes(source.read_bytes())
        files[str(dest)] = e.sha(dest)
    protocol = {'status': 'frozen_before_paired_timeout_run', 'created_utc': e.now(),
                'pairs': pairs, 'registered_pairs': 355, 'by_kind': EXPECTED,
                'jars': {'before': str(before), 'after': str(after)}, 'workers': 8,
                'search_seconds': 60, 'replay_seconds': 60, 'worker_seconds': 180,
                'memory_mb': 4096, 'gates': list(map(str, gates)), 'input_sha256': files,
                'model_requests': 0, 'excluded_already_searching': 346,
                'scope': 'Development comparison on 355 previously selected timeouts, not a full 1200-group rerun.',
                'policies': ['Each pair runs both arms afresh, sequentially, in hash-balanced order; eight pairs in parallel.',
                             'Transport replays the frozen translated plan; other stages search then replay a returned plan.',
                             'No retries, continuation, reference backfill, model requests, input compilation or replacement.',
                             'Timeouts and all failures remain in the denominator; no-solution-returned is not a success.',
                             'Physical and native validation are unchanged frozen validators; no semantic labels are inferred.']}
    e.write(root/'protocol.json', protocol)
    (root/'PROTOCOL.sha256').write_text(e.sha(root/'protocol.json')+'\n', encoding='utf-8')
    print(json.dumps({'registered_pairs': 355, 'by_kind': EXPECTED, 'model_requests': 0}), flush=True)


def initialize(executor, jar):
    global E
    E = load(executor)
    E.initialize(jar)


def make_job(root, pair, arm, seconds=60):
    job = {'root': str(root/arm), 'task': pair['task'], 'seconds': seconds,
           'worker_seconds': 180, 'condition': 'initialization_timeout_pair_'+arm}
    if pair['mode'] == 'replay':
        job.update(replay_plan=pair['historical']['plan'], retained_search={'status': 'not_a_search', 'search_calls': 0})
    return job


def one_pair(args):
    root, pair, jars = args
    result = {'kind': pair['task']['kind'], 'id': pair['task']['id'], 'last_phase': pair['last_phase'],
              'arm_order': pair['arm_order'], 'historical': pair['historical']}
    for arm in pair['arm_order']:
        E.JAR = E.local(jars[arm])
        result[arm] = E.one(make_job(E.local(root), pair, arm))
        E.write(E.local(root)/arm/'completed'/result['kind']/(result['id']+'.json'), result[arm])
    return result


def phase(row, name):
    return any(event.get('phase') == name for part in ('search', 'replay')
               for event in row.get(part, {}).get('phase_events', []))


def summarize(rows):
    invocation_seconds = [r.get(part, {}).get('seconds', 0.0) for r in rows for part in ('search', 'replay')]
    primary = [r.get('replay' if r['kind'] == 'transport' else 'search', {}) for r in rows]
    measured_primary = [r['seconds'] for r in primary if 'seconds' in r]
    return {'cases': len(rows), 'search_started': sum(phase(r, 'search_begin') for r in rows),
            'replay_axioms_completed': sum(phase(r, 'replay_axioms_end') for r in rows),
            'initialization_completed': sum(phase(r, 'replay_axioms_end' if r['kind'] == 'transport' else 'search_begin') for r in rows),
            'search_solved': sum(r.get('search', {}).get('status') == 'solved' for r in rows),
            'dual_valid': sum(bool(r.get('valid')) for r in rows),
            'native_valid': sum(bool(r.get('native_valid')) for r in rows),
            'no_solution_returned': sum(r.get('search', {}).get('status') == 'no_solution_returned' for r in rows),
            'primary_statuses': dict(Counter(r.get('status', 'missing') for r in primary)),
            'worker_statuses': dict(Counter(r.get('status', 'missing') for r in rows)),
            'search_timeouts': sum(r.get('search', {}).get('status') == 'wall_time_limit' for r in rows),
            'replay_timeouts': sum(r.get('replay', {}).get('status') == 'wall_time_limit' for r in rows),
            'invocation_seconds_including_timeouts': sum(invocation_seconds),
            'worker_seconds': sum(r.get('worker_seconds', 0.0) for r in rows),
            'primary_measured_calls': len(measured_primary),
            'primary_median_seconds_including_timeouts': statistics.median(measured_primary) if measured_primary else None}


def compare(rows):
    result = {}
    for stage in ('all',)+STAGES:
        selected = [r for r in rows if stage == 'all' or r['kind'] == stage]
        result[stage] = {arm: summarize([r[arm] for r in selected]) for arm in ('historical', 'before', 'after')}
        before, after = result[stage]['before'], result[stage]['after']
        result[stage]['paired'] = {'gained_dual_valid': sum(not r['before'].get('valid') and bool(r['after'].get('valid')) for r in selected),
                                  'lost_dual_valid': sum(bool(r['before'].get('valid')) and not r['after'].get('valid') for r in selected),
                                  'invocation_seconds_saved': before['invocation_seconds_including_timeouts']-after['invocation_seconds_including_timeouts']}
    return result


def run(root):
    e = load(root/'executor.py')
    isolation = e.isolation()
    p = e.read(root/'protocol.json')
    if e.sha(root/'protocol.json') != (root/'PROTOCOL.sha256').read_text().strip():
        raise ValueError('Protocol changed')
    for path, expected in p['input_sha256'].items():
        if e.sha(path) != expected:
            raise ValueError('Frozen input changed: '+str(path))
    e.write(root/'execution_start.json', {'started_utc': e.now(), 'isolation': isolation,
                                        'platform': platform.platform(), 'logical_cpus': os.cpu_count(),
                                        'meminfo': Path('/proc/meminfo').read_text(),
                                        'cpuinfo': Path('/proc/cpuinfo').read_text()})
    started = time.monotonic()
    rows = []
    with (root/'pair_events.jsonl').open('x', encoding='utf-8') as stream:
        with ProcessPoolExecutor(max_workers=p['workers'], initializer=initialize,
                                 initargs=(str(root/'executor.py'), p['jars']['before'])) as pool:
            jobs = [pool.submit(one_pair, (str(root), pair, p['jars'])) for pair in p['pairs']]
            for future in as_completed(jobs):
                row = future.result()
                rows.append(row)
                stream.write(json.dumps(row, ensure_ascii=False)+'\n')
                stream.flush()
                e.progress(root, status='running', completed_pairs=len(rows), registered_pairs=355,
                           elapsed_seconds=time.monotonic()-started)
                if len(rows) % 10 == 0 or len(rows) == 355:
                    print(json.dumps({'completed_pairs': len(rows), 'registered_pairs': 355,
                                      'seconds': round(time.monotonic()-started, 2)}), flush=True)
    elapsed = time.monotonic()-started
    rows.sort(key=key)
    unchanged = all(e.sha(path) == h for path, h in p['input_sha256'].items())
    complete = len(rows) == 355 and len({key(r) for r in rows}) == 355
    report = {'status': 'complete_paired_timeout_comparison' if complete and unchanged else 'failed',
              'registered_pairs': 355, 'completed_pairs': len(rows), 'wall_seconds_both_arms': elapsed,
              'inputs_unchanged': unchanged, 'model_requests': 0, 'comparison': compare(rows), 'rows': rows,
              'limitations': p['policies']+[p['scope'], 'Summed invocation time includes censored timeouts and additional validation calls after newly solved searches; it is not CPU time.']}
    e.write(root/'report.json', report)
    e.progress(root, status=report['status'], completed_pairs=len(rows), registered_pairs=355, elapsed_seconds=elapsed)
    print(json.dumps({k: v for k, v in report.items() if k not in ('rows', 'limitations')}), flush=True)


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('mode', choices=['prepare', 'run'])
    p.add_argument('--output', type=Path, required=True)
    for name in ('selection', 'parent', 'before', 'after', 'executor'):
        p.add_argument('--'+name, type=Path)
    p.add_argument('--gate', type=Path, action='append', default=[])
    a = p.parse_args()
    if a.mode == 'run':
        run(a.output.resolve())
    else:
        prepare(a.output.resolve(), a.selection.resolve(), a.parent.resolve(), a.before.resolve(),
                a.after.resolve(), a.executor.resolve(), [g.resolve() for g in a.gate])

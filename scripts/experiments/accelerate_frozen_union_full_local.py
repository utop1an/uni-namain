"""Explicit concurrency-8 continuation: retain every started attempt, never retry.

The parent coordinator must be drained and stopped before preparation. All
compiler/model/runtime inputs and per-task limits are inherited unchanged.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
import importlib.util
import json
import os
from pathlib import Path
import shutil
import sys
import time
import traceback

LABELS = ('native', 'transport', 'anchor', 'composition')
R = None


def read(p):
    return json.loads(Path(p).read_text(encoding='utf-8'))


def load(parent):
    global R
    spec = importlib.util.spec_from_file_location('retained_offline_runner', parent / 'implementation.py')
    R = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(R)
    sys.addaudithook(R.offline_guard)
    R.bind()
    return R


def normalize(task, result):
    if result.get('status') == 'complete':
        return result
    return {**task, **result, 'valid': False, 'native_valid': False,
            'search': {'status': result['status'], 'search_calls': None,
                       'attempt_accounting': 'inspect_retained_invocation'}}


def collect_retained(parent, label, tasks):
    registered = {t['id']: t for t in tasks}
    rows, provenance = {}, {}
    events = parent / 'repeat_01' / (label + '_events.jsonl')
    if events.exists():
        content = events.read_bytes()
        lines = content.splitlines() if content.endswith(b'\n') else content.splitlines()[:-1]
        for line in lines:
            row = json.loads(line)
            if row['id'] not in registered or row['id'] in rows:
                raise ValueError('Unexpected or duplicate retained result: ' + row['id'])
            rows[row['id']] = row
            provenance[row['id']] = 'parent_events'
    workers = parent / 'repeat_01/plan_workers' / label
    if workers.exists():
        for directory in workers.iterdir():
            if not directory.is_dir():
                continue
            taskfile = directory / 'task.json'
            if not taskfile.exists():
                raise ValueError('Unaccounted claimed worker directory: ' + str(directory))
            task = read(taskfile); tid = task['id']
            if tid not in registered or task != registered[tid]:
                raise ValueError('Worker task differs from registration')
            if tid in rows:
                continue
            resultfile, timeout = directory / 'worker_result.json', directory / 'worker_timeout.json'
            if resultfile.exists():
                rows[tid] = normalize(task, read(resultfile))
                provenance[tid] = 'drained_worker_result_not_yet_collected'
            elif timeout.exists():
                rows[tid] = normalize(task, read(timeout))
                provenance[tid] = 'retained_worker_timeout'
            else:
                raise ValueError('Started attempt has no terminal receipt; never resubmit: ' + tid)
    return rows, provenance


def prepare(parent, root):
    if root.exists():
        raise ValueError('Fresh continuation directory required')
    if not (parent / 'concurrency8_handoff/drained_and_stopped.json').exists():
        raise ValueError('Parent must be drained and stopped before continuation')
    p = R.verify(parent)
    R.verify_hashes(read(parent / 'repeat_01/compiled_freeze.json')['input_sha256'])
    root.mkdir(parents=True)
    copy_names = ['selected_groups.json', 'sources.json', 'worlds.json', 'baseline_tasks.json',
                  'implementation.py', 'repeat_01/original_tasks.json', 'repeat_01/composition_tasks.json',
                  'repeat_01/compilation_report.json', 'repeat_01/compiled_freeze.json', 'repeat_01/references.json']
    for name in copy_names:
        dest = root / name; dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(parent / name, dest)
    # These small compiler receipts retain formal rejection reasons; model files
    # stay at their immutable parent paths, as recorded in every task.
    for source in (parent / 'repeat_01/groups').glob('*/compilation.json'):
        dest = root / source.relative_to(parent); dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, dest)
    shutil.copyfile(__file__, root / 'acceleration.py')
    review = parent / 'review_registration/implementation.py'
    shutil.copyfile(review, root / 'review.py')
    original = read(root / 'repeat_01/original_tasks.json')['tasks']
    jobs = {'native': read(parent / 'repeat_01/jobs/native.json')['tasks'],
            'transport': read(parent / 'repeat_01/jobs/transport.json')['tasks'],
            'anchor': [{**t, 'kind': 'anchor'} for t in original if t['search_anchor']],
            'composition': [{**t, 'kind': 'composition'} for t in read(root / 'repeat_01/composition_tasks.json')['tasks']]}
    accounting = {}
    for label, tasks in jobs.items():
        if len(tasks) != R.EXPECTED[label] or len({t['id'] for t in tasks}) != len(tasks):
            raise ValueError('Task denominator changed')
        rows, origins = collect_retained(parent, label, tasks)
        R.write(root / 'registered_jobs' / (label + '.json'), {'tasks': tasks})
        R.write(root / 'retained_rows' / (label + '.json'), {'rows': rows, 'origins': origins})
        accounting[label] = {'registered': len(tasks), 'retained': len(rows),
                             'not_started': len(tasks)-len(rows),
                             'drained_results': sum(v == 'drained_worker_result_not_yet_collected' for v in origins.values())}
    hashes = dict(p['input_sha256'])
    hashes.update(read(parent / 'repeat_01/compiled_freeze.json')['input_sha256'])
    historical = [parent / 'protocol.json', parent / 'PROTOCOL.sha256', parent / 'repeat_01/references.json']
    historical += [f for base in ('repeat_01/plan_workers', 'repeat_01/execution', 'repeat_01/references', 'concurrency8_handoff')
                   for f in (parent / base).rglob('*') if f.is_file()]
    historical += [f for label in LABELS for f in (parent / 'repeat_01' / (label+'_events.jsonl'), parent / 'repeat_01' / (label+'_report.json')) if f.exists()]
    historical += [f for f in root.rglob('*') if f.is_file()]
    hashes.update({str(f.resolve()): R.digest(f) for f in historical})
    old_start = (parent / 'repeat_01/jobs/native.json').stat().st_mtime
    p.update(status='frozen_before_remaining_tasks', condition='explicit_concurrency8_continuation_with_retained_concurrency2_results',
             created_utc=R.now(), input_sha256=hashes,
             continuation={'parent': str(parent), 'authorization': 'User: increase local concurrency to 8',
                           'parent_protocol_sha256': R.digest(parent / 'protocol.json'),
                           'accounting': accounting, 'cache_continuation': True,
                           'original_safety_deadline_unix': old_start+p['budgets']['planning_total_seconds'],
                           'new_api_requests': 0, 'retries': 0})
    p['budgets']['planner_workers'] = 8
    p['policies'] += ['Explicit user-authorized concurrency change 2 to 8; not a wholly fresh 8-worker run.',
                      'All parent attempts retained including failures; only never-started tasks are dispatched.',
                      'Search/replay/heap/worker limits and original overall safety deadline unchanged.',
                      'Every result records retained-concurrency2 or new-concurrency8 provenance; timing is not compared as a uniform setting.']
    R.write(root / 'protocol.json', p)
    (root / 'PROTOCOL.sha256').write_text(R.digest(root / 'protocol.json')+'\n', encoding='utf-8')
    R.progress(root, {}, status='prepared', stage='ready_for_concurrency8', planner_workers=8,
               retained_accounting=accounting, new_api_requests=0)
    return accounting


def stage(root, label, state, deadline):
    tasks = read(root / 'registered_jobs' / (label+'.json'))['tasks']
    retained = read(root / 'retained_rows' / (label+'.json'))
    rows = [{**row, 'execution_provenance': {'condition': 'retained_concurrency2',
             'origin': retained['origins'][tid], 'new_attempt': False}}
            for tid, row in retained['rows'].items()]
    pending = [t for t in tasks if t['id'] not in retained['rows']]
    p = read(root / 'protocol.json')
    R.write(root / 'repeat_01/jobs' / (label+'.json'), {'tasks': tasks, 'new_attempt_candidates': len(pending)})
    def one(task):
        if task['status'] != 'ready':
            return {**task, 'valid': False, 'native_valid': False,
                    'search': {'status': task['status'], 'search_calls': 0},
                    'execution_provenance': {'condition': 'new_concurrency8', 'new_attempt': False}}
        remaining = deadline-time.time()
        if remaining <= 0:
            return {**task, 'status': 'not_run_total_budget', 'valid': False, 'native_valid': False,
                    'search': {'status': 'not_run_total_budget', 'search_calls': 0},
                    'execution_provenance': {'condition': 'new_concurrency8', 'new_attempt': False}}
        result = R.call_worker(root, 'plan-worker', task['id'], root / 'repeat_01/plan_workers' / label / task['id'],
                               min(p['budgets']['planning_worker_seconds'], remaining), task=task)
        return {**normalize(task, result), 'execution_provenance': {'condition': 'new_concurrency8', 'new_attempt': True}}
    dual = sum(r.get('valid', False) for r in rows)
    with (root / 'repeat_01' / (label+'_events.jsonl')).open('x', encoding='utf-8') as stream:
        for row in rows:
            stream.write(json.dumps(row, ensure_ascii=False)+'\n')
        stream.flush()
        R.progress(root, state, stage=label, completed_stage_slots=len(rows), registered_stage_slots=len(tasks),
                   retained_stage_slots=len(rows), new_stage_slots=0, planner_workers=8)
        with ThreadPoolExecutor(max_workers=8) as pool:
            futures = [pool.submit(one, t) for t in pending]
            for future in as_completed(futures):
                row = future.result(); rows.append(row); dual += bool(row.get('valid'))
                stream.write(json.dumps(row, ensure_ascii=False)+'\n'); stream.flush()
                R.progress(root, state, stage=label, completed_stage_slots=len(rows), registered_stage_slots=len(tasks),
                           retained_stage_slots=len(retained['rows']), new_stage_slots=len(rows)-len(retained['rows']),
                           stage_dual_validated=dual, planner_workers=8)
    R.write(root / 'repeat_01' / (label+'_report.json'), {'registered_slots': len(tasks), 'rows': sorted(rows,key=lambda r:r['id'])})


def run(root):
    R.write(root / 'execution_started.json', {'created_utc': R.now(), 'pid': os.getpid(), 'planner_workers': 8})
    state = {'status': 'running', 'new_api_requests': 0, 'planner_workers': 8,
             'condition': 'explicit_concurrency8_continuation'}
    terminal = 'complete'
    try:
        p = R.verify(root)
        deadline = p['continuation']['original_safety_deadline_unix']
        for label in LABELS:
            stage(root, label, state, deadline)
    except Exception:
        terminal = 'stopped_error'
        R.write(root / 'terminal_error.json', {'traceback': traceback.format_exc(), 'created_utc': R.now()})
    R.progress(root, state, stage='evaluation', status=terminal)
    evaluation = R.evaluation(root, terminal)
    # The downstream report keeps the revised execution condition explicit.
    spec = importlib.util.spec_from_file_location('frozen_review', root / 'review.py')
    reviewer = importlib.util.module_from_spec(spec); spec.loader.exec_module(reviewer)
    review = reviewer.review(root, root / 'paired_review_v1')
    R.write(root / 'execution_condition.json', {'condition': p['condition'], 'continuation': p['continuation'],
        'note': 'Combined retained 2-worker and new 8-worker outcomes; no uniform-concurrency latency claim.'})
    R.progress(root, state, stage='finished', status=terminal, evaluation=evaluation, review=review)
    return evaluation


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('mode', choices=('prepare','run'))
    parser.add_argument('--parent', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    parent, root = args.parent.resolve(), args.output.resolve()
    load(parent)
    print(json.dumps(prepare(parent,root) if args.mode=='prepare' else run(root),ensure_ascii=False),flush=True)


if __name__ == '__main__':
    main()

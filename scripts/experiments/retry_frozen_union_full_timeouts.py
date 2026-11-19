"""One explicitly authorized 60-second retry of previously timed-out slots.

Reuse the frozen compiler outputs, runtime, validator and original reference
plans. Never infer new jobs from newly solved source baselines. The combined
view is a two-stage continuation, not a fresh uniform-budget experiment.
"""
import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor, wait, FIRST_COMPLETED
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
import traceback

LABELS = ('native', 'transport', 'anchor', 'composition')
R = None


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def load(parent):
    global R
    spec = importlib.util.spec_from_file_location('frozen_retry_parent', parent / 'implementation.py')
    R = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(R)
    sys.addaudithook(R.offline_guard)
    R.bind()


def retry_reason(row):
    search = row.get('search', {}).get('status')
    replay = row.get('replay', {}).get('status')
    if search in ('wall_time_limit', 'worker_wall_time_limit'):
        return 'search_timeout'
    if replay == 'wall_time_limit':
        return 'replay_timeout'
    return None


def normalize(task, result):
    if result.get('status') == 'complete':
        return result
    return {**task, **result, 'valid': False, 'native_valid': False,
            'search': {'status': result.get('status', 'worker_failed_without_result'),
                       'search_calls': None, 'attempt_accounting': 'inspect_saved_invocation'}}


def prepare(parent, root):
    if root.exists():
        raise ValueError('Fresh output directory required')
    if read(parent / 'coordinator.json').get('status') != 'complete':
        raise ValueError('Parent must have completed before selecting retries')
    p = read(parent / 'protocol.json')
    if R.digest(parent / 'protocol.json') != (parent / 'PROTOCOL.sha256').read_text(encoding='utf-8').strip():
        raise ValueError('Parent protocol changed')
    if (p['budgets']['search_seconds'], p['budgets']['replay_seconds']) != (15, 15):
        raise ValueError('Expected original 15-second condition')
    root.mkdir(parents=True)
    state = dict(status='preparing', stage='verify_parent', new_api_requests=0)
    R.progress(root, state)
    hashes = dict(p['input_sha256'])
    hashes.update(read(parent / 'repeat_01/compiled_freeze.json')['input_sha256'])
    review = read(parent / 'paired_review_v1/report.json')
    hashes.update(review['input_sha256'])
    for name, expected in read(parent / 'paired_review_v1/review_freeze.json')['files'].items():
        hashes[str(parent / 'paired_review_v1' / name)] = expected
    for index, (name, expected) in enumerate(hashes.items(), 1):
        if R.digest(name) != expected:
            raise ValueError('Frozen input changed: ' + name)
        if index % 2000 == 0:
            R.progress(root, state, verified_files=index, registered_input_files=len(hashes))
    R.progress(root, state, stage='register_timeout_retries', verified_files=len(hashes))
    copy_names = ('selected_groups.json', 'sources.json', 'worlds.json', 'baseline_tasks.json',
                  'implementation.py', 'review.py', 'repeat_01/original_tasks.json',
                  'repeat_01/composition_tasks.json', 'repeat_01/compilation_report.json',
                  'repeat_01/compiled_freeze.json', 'repeat_01/references.json')
    for name in copy_names:
        dest = root / name
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(parent / name, dest)
    for source in (parent / 'repeat_01/groups').glob('*/compilation.json'):
        dest = root / source.relative_to(parent)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, dest)
    shutil.copyfile(__file__, root / 'retry.py')
    accounting, jobs = {}, []
    for label in LABELS:
        task_path = parent / 'registered_jobs' / (label + '.json')
        row_path = parent / 'repeat_01' / (label + '_report.json')
        tasks = read(task_path)['tasks']
        rows = read(row_path)['rows']
        report_digest = R.digest(row_path)
        task_by_id = {t['id']: t for t in tasks}
        row_by_id = {r['id']: r for r in rows}
        if len(rows) != len(row_by_id) or len(tasks) != len(task_by_id) or set(row_by_id) != set(task_by_id):
            raise ValueError('Parent registration/result identity mismatch: ' + label)
        if len(rows) != R.EXPECTED[label]:
            raise ValueError('Denominator mismatch: ' + label)
        selected = []
        for row in rows:
            reason = retry_reason(row)
            if not reason:
                continue
            task = task_by_id[row['id']]
            if task['status'] != 'ready' or row.get('valid'):
                raise ValueError('Retry selection is not an unsuccessful ready job')
            if reason == 'replay_timeout' and label != 'transport':
                raise ValueError('A search-solved replay timeout requires a replay-only adapter')
            for key in ('domain', 'problem', 'mapping', 'source_plan'):
                if task.get(key):
                    path = Path(task[key]).resolve()
                    current = R.digest(path)
                    if str(path) in hashes and hashes[str(path)] != current:
                        raise ValueError('Registered task input changed: ' + str(path))
                    hashes[str(path)] = current
            for phase in ('search', 'replay'):
                for name, expected in row.get(phase, {}).get('input_sha256', {}).items():
                    if R.digest(name) != expected:
                        raise ValueError('Original invocation input changed: ' + name)
                    hashes[name] = expected
            selected.append(row['id'])
            jobs.append(dict(stage=label, id=row['id'], reason=reason, task=task,
                             parent_report=str(row_path), parent_report_sha256=report_digest))
        accounting[label] = dict(registered=len(rows), retry=len(selected), retained=len(rows)-len(selected),
                                 reasons=dict(Counter(retry_reason(row_by_id[tid]) for tid in selected)))
        R.write(root / 'registered_jobs' / (label + '.json'), {'tasks': tasks})
        R.write(root / 'parent_rows' / (label + '.json'), {'rows': rows})
        R.write(root / 'retry_registry' / (label + '.json'), {'ids': sorted(selected)})
        hashes[str(task_path)] = R.digest(task_path)
        hashes[str(row_path)] = report_digest
    # Only ordering changes; membership and comparison groups stay frozen.
    jobs.sort(key=lambda j: R.C.rank('timeout60-retry-order-v1', j['stage'] + '/' + j['id']))
    expected = {'native': 122, 'transport': 2496, 'anchor': 3347, 'composition': 1344}
    if {k:v['retry'] for k,v in accounting.items()} != expected or len(jobs) != 7309:
        raise ValueError('Timeout registry differs from reviewed parent')
    R.write(root / 'retry_jobs.json', {'jobs': jobs, 'registered_retry_slots': len(jobs)})
    continuation = dict(parent=str(parent), parent_protocol_sha256=R.digest(parent / 'protocol.json'),
                        authorization='User: retry timed-out tasks once with a 60-second limit',
                        accounting=accounting, registered_retry_slots=len(jobs),
                        new_search_slots=4813, replay_only_slots=2496,
                        max_new_search_calls=4813, max_new_replay_calls=7309,
                        references_frozen_to_parent=True, unavailable_reference_backfill=False)
    policy = [
        'Explicit user-authorized one-time timeout retry. No API requests, new alignment or recompilation.',
        'Only original search/replay wall-time limits are eligible. Other failures, unsupported and missing rows retained.',
        'Unchanged frozen domains, problems, mappings, runtime, semantic decisions and validation rules.',
        '60-second search and replay subprocess limits; 180-second worker cap; eight concurrent workers.',
        'All original attempts remain in parent_rows and the immutable parent; each selected slot has at most one new attempt.',
        'Combined outcomes are retained 15-second results plus timeout-selected 60-second retries, not a fresh all-60-second campaign.',
        'Use the new terminal result for each retried slot, not best-of-two selection. No automatic retry or resume.',
        'Original reference plans stay fixed. Newly solved native baselines do not automatically trigger previously unavailable transports.',
        'All registered comparison denominators, Batch missing/excluded candidates and unsupported outcomes retained.',
        'Union/full paired within group/world; random and causal_link are distinct correlated samples.',
        'Diagnostic targets can fall back from selected k to two sources; frozen causal trace remains exploratory.',
        'No independent semantic or narrative-quality labels; native-only validation is not promoted to dual validation.',
        'Newly found plans are replayed with a 60-second limit. Construction limits are unchanged and not retried.',
        'A total safety deadline of seven days applies only to this separately registered local retry condition.'
    ]
    p.update(status='frozen_before_timeout60_retries', created_utc=R.now(),
             condition='retained15_plus_timeout60_retry_once', continuation=continuation,
             policies=policy)
    p['budgets'].update(search_seconds=60, replay_seconds=60, planning_worker_seconds=180,
                        planner_workers=8, planning_total_seconds=604800, attempts_per_slot=1)
    hashes[str(parent / 'protocol.json')] = R.digest(parent / 'protocol.json')
    hashes[str(parent / 'coordinator.json')] = R.digest(parent / 'coordinator.json')
    # Freeze all newly copied registration inputs, excluding mutable progress.
    hashes.update({str(f.resolve()): R.digest(f) for f in root.rglob('*') if f.is_file() and f.name != 'coordinator.json'})
    p['input_sha256'] = hashes
    R.write(root / 'protocol.json', p)
    (root / 'PROTOCOL.sha256').write_text(R.digest(root / 'protocol.json')+'\n', encoding='utf-8')
    R.write(root / 'execution_condition.json', dict(condition=p['condition'], continuation=continuation,
        note='Timeout-selected one-time retries; elapsed budgets and selection differ from a fresh uniform 60-second run.'))
    R.progress(root, state, status='prepared', stage='ready', registered_retry_slots=len(jobs),
               completed_retry_slots=0, planner_workers=8, retry_accounting=accounting)
    return continuation


def provenance(job, prior):
    return dict(condition='timeout60_retry_once', new_attempt=True, retry_number=1,
                parent_report=job['parent_report'], parent_report_sha256=job['parent_report_sha256'],
                parent_row_id=job['id'], retry_reason=job['reason'], search_seconds=60, replay_seconds=60,
                previous_execution_provenance=prior.get('execution_provenance'))


def one(root, job, prior, seconds):
    task = job['task']
    result = R.call_worker(root, 'plan-worker', job['id'],
        root / 'repeat_01/plan_workers' / job['stage'] / job['id'], seconds, task=task)
    result = normalize(task, result)
    result['execution_provenance'] = provenance(job, prior)
    if job['stage'] == 'transport' and result.get('plan'):
        if R.digest(result['plan']) != R.digest(prior['plan']):
            raise ValueError('Transport retry changed the saved mapped plan: ' + job['id'])
    return result


def snapshot_summary(root, parent_rows, results, terminal):
    totals = {}
    for label in LABELS:
        previous = {r['id']: r for r in parent_rows[label]}
        retried = [r for (stage, tid), r in results.items() if stage == label]
        transitions = Counter((R.outcome(previous[r['id']]), R.outcome(r)) for r in retried)
        totals[label] = dict(retried=len(retried), newly_dual_validated=sum(bool(r.get('valid')) for r in retried),
                            retry_outcomes=dict(Counter(R.outcome(r) for r in retried)),
                            transitions=[dict(before=a, after=b, count=n) for (a,b),n in sorted(transitions.items())])
    R.write(root / 'retry_summary.json', dict(status=terminal, created_utc=R.now(),
        condition='retained15_plus_timeout60_retry_once', registered_retry_slots=7309,
        completed_retry_slots=len(results), stages=totals, new_api_requests=0,
        source_reference_backfill=False, historical_results_preserved=True))


def run(root):
    R.write(root / 'execution_started.json', dict(created_utc=R.now(), pid=os.getpid(), planner_workers=8))
    p = read(root / 'protocol.json')
    state = dict(status='running', stage='verify_inputs', condition=p['condition'], new_api_requests=0,
                 registered_retry_slots=7309, completed_retry_slots=0, planner_workers=8, pid=os.getpid())
    R.progress(root, state)
    jobs = read(root / 'retry_jobs.json')['jobs']
    parent_rows = {label:read(root / 'parent_rows' / (label+'.json'))['rows'] for label in LABELS}
    prior = {(label,r['id']):r for label,rows in parent_rows.items() for r in rows}
    results, started = {}, set()
    terminal = 'complete'
    error = None
    try:
        R.verify(root)
        check = subprocess.run(['wsl.exe','--exec','/bin/true'],capture_output=True,timeout=30,
                               creationflags=getattr(subprocess,'CREATE_NO_WINDOW',0))
        R.write(root/'environment_check.json',dict(returncode=check.returncode,created_utc=R.now(),
                                                  new_planner_calls=0,new_api_requests=0))
        if check.returncode != 0:
            raise RuntimeError('WSL environment check failed before dispatch')
        deadline = time.monotonic() + p['budgets']['planning_total_seconds']
        R.progress(root, state, stage='retry_search_and_replay', started_utc=R.now(),
                   completed_by_stage={s:0 for s in LABELS}, newly_dual_validated=0)
        streams = {}
        try:
            for label in LABELS:
                path = root / 'repeat_01' / (label + '_retry_events.jsonl')
                path.parent.mkdir(parents=True, exist_ok=True)
                streams[label] = path.open('x',encoding='utf-8')
            with ThreadPoolExecutor(max_workers=8) as pool:
                iterator, active = iter(jobs), {}
                def dispatch():
                    while len(active) < 8:
                        if time.monotonic() >= deadline:
                            return
                        job = next(iterator, None)
                        if job is None:
                            return
                        key = (job['stage'],job['id'])
                        if key in started:
                            raise ValueError('Duplicate retry dispatch')
                        started.add(key)
                        limit = min(p['budgets']['planning_worker_seconds'], deadline-time.monotonic())
                        future = pool.submit(one, root, job, prior[key], limit)
                        active[future] = job
                dispatch()
                while active:
                    done,_ = wait(active, timeout=10, return_when=FIRST_COMPLETED)
                    for future in done:
                        job = active.pop(future)
                        key = (job['stage'],job['id'])
                        row = future.result()
                        if row['id'] != job['id'] or key in results:
                            raise ValueError('Retry identity mismatch')
                        results[key] = row
                        streams[job['stage']].write(json.dumps(row,ensure_ascii=False)+'\n')
                        streams[job['stage']].flush()
                        if row.get('status') in ('worker_exception','worker_failed_without_result'):
                            raise RuntimeError('Worker infrastructure failure; stop new dispatch: '+job['id'])
                    dispatch()
                    R.progress(root, state, completed_retry_slots=len(results), started_retry_slots=len(started),
                        active_workers=len(active), active_jobs=[j['stage']+'/'+j['id'] for j in active.values()],
                        completed_by_stage=dict(Counter(s for s,t in results)),
                        newly_dual_validated=sum(bool(r.get('valid')) for r in results.values()))
            if len(results) != len(jobs):
                terminal = 'stopped_total_budget'
        finally:
            for stream in streams.values():
                stream.close()
    except Exception:
        terminal = 'stopped_error'
        error = traceback.format_exc()
        R.write(root / 'terminal_error.json',dict(created_utc=R.now(),traceback=error))
    R.progress(root, state, status='finalizing', stage='combine_preserved_and_retried', terminal_status=terminal)
    # Collect terminal worker receipts even if orchestration failed after dispatch.
    jobmap = {(j['stage'],j['id']):j for j in jobs}
    for key in started-results.keys():
        f = root / 'repeat_01/plan_workers' / key[0] / key[1] / 'worker_result.json'
        if f.exists():
            row = normalize(jobmap[key]['task'],read(f))
            row['execution_provenance'] = provenance(jobmap[key],prior[key])
            results[key] = row
    for label in LABELS:
        combined = []
        for row in parent_rows[label]:
            key = (label,row['id'])
            if key in results:
                item = results[key]
            else:
                item = {**row, 'execution_provenance':dict(condition='retained_initial15',new_attempt=False,
                    parent=str(Path(p['continuation']['parent'])/'repeat_01'/(label+'_report.json')),
                    retry_status='not_completed' if key in jobmap else 'not_selected_non_timeout',
                    previous_execution_provenance=row.get('execution_provenance'))}
            combined.append(item)
        if len(combined) != len({r['id'] for r in combined}) or len(combined) != R.EXPECTED[label]:
            raise ValueError('Combined denominator mismatch')
        R.write(root / 'repeat_01' / (label+'_report.json'),dict(registered_slots=len(combined),rows=sorted(combined,key=lambda r:r['id'])))
    snapshot_summary(root,parent_rows,results,terminal)
    R.progress(root,state,stage='evaluation',completed_retry_slots=len(results))
    evaluation = R.evaluation(root, terminal)
    spec = importlib.util.spec_from_file_location('timeout60_review', root/'review.py')
    reviewer = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(reviewer)
    review = reviewer.review(root, root/'paired_review_v1')
    R.write(root/'completion.json',dict(status=terminal,created_utc=R.now(),condition=p['condition'],
        registered_retry_slots=len(jobs),completed_retry_slots=len(results),new_api_requests=0,
        no_duplicate_retry_dispatch=len(started)==len(set(started)),evaluation=evaluation,review=review,error=error))
    R.progress(root,state,status=terminal,stage='finished',evaluation=evaluation,review=review)
    return dict(status=terminal,registered_retry_slots=len(jobs),completed_retry_slots=len(results))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode',choices=('prepare','run'))
    parser.add_argument('--parent',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args = parser.parse_args()
    parent,root = args.parent.resolve(),args.output.resolve()
    load(parent)
    result = prepare(parent,root) if args.mode=='prepare' else run(root)
    print(json.dumps(result,ensure_ascii=False),flush=True)


if __name__ == '__main__':
    main()

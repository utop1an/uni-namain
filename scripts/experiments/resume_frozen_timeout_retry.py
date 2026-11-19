"""Explicit, one-shot continuation of a drained timeout-retry checkpoint.

Only orchestration changes. Frozen workers, tasks, plans, reference selection,
validation and search/replay budgets are reused unchanged. Never infer work
from outcomes or retry an already dispatched slot.
"""
import argparse
from collections import Counter
from concurrent.futures import FIRST_COMPLETED, ThreadPoolExecutor, wait
from datetime import datetime, timedelta, timezone
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import time
import traceback

LABELS = ('native', 'transport', 'anchor', 'composition')
CONDITION = 'retained15_plus_timeout60_retry_once_with_pause_continuation'
T = R = None


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8-sig'))


def load(source):
    global T, R
    spec = importlib.util.spec_from_file_location('frozen_timeout_retry', source / 'retry.py')
    T = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(T)
    T.load(source)
    R = T.R


def partition_jobs(jobs, retained, pending_ids):
    """Require an exact ordered partition; unknown, duplicate or skipped IDs fail."""
    jobmap = {(j['stage'], j['id']): j for j in jobs}
    if len(jobmap) != len(jobs):
        raise ValueError('Duplicate registered retry identity')
    completed = {}
    for stage, rows in retained.items():
        for row in rows:
            key = (stage, row['id'])
            if key in completed or key not in jobmap:
                raise ValueError('Duplicate or unregistered completed retry')
            completed[key] = row
    expected = [j for j in jobs if (j['stage'], j['id']) not in completed]
    projection = [{'stage': j['stage'], 'id': j['id'], 'reason': j['reason']} for j in expected]
    if projection != pending_ids:
        raise ValueError('Pending registry is not the exact ordered complement')
    return completed, expected


def combine_rows(parent_rows, results, retry_keys, parent):
    """Use each terminal retry verbatim, including failures; keep every base slot."""
    prior_keys = {(s, r['id']) for s, rows in parent_rows.items() for r in rows}
    if sum(map(len, parent_rows.values())) != len(prior_keys):
        raise ValueError('Duplicate original evaluation identity')
    if not set(results) <= retry_keys <= prior_keys:
        raise ValueError('Retry/result identity outside original registration')
    combined = {}
    for stage, rows in parent_rows.items():
        output = []
        for row in rows:
            key = (stage, row['id'])
            if key in results:
                if results[key]['id'] != row['id']:
                    raise ValueError('Result identity mismatch')
                output.append(results[key])
            else:
                output.append({**row, 'execution_provenance': {
                    'condition': 'retained_initial15', 'new_attempt': False,
                    'parent': str(Path(parent) / 'repeat_01' / (stage + '_report.json')),
                    'retry_status': 'not_completed' if key in retry_keys else 'not_selected_non_timeout',
                    'previous_execution_provenance': row.get('execution_provenance')}})
        combined[stage] = sorted(output, key=lambda r: r['id'])
    return combined


def prepare(source, checkpoint, root):
    if root.exists():
        raise ValueError('Fresh continuation output required')
    state = read(source / 'coordinator.json')
    finish = read(checkpoint / 'pause_complete.json')
    saved = read(checkpoint / 'checkpoint.json')
    if state['status'] != 'paused' or finish['status'] != 'paused_ready_for_explicit_resume':
        raise ValueError('Source is not a completed, drained pause')
    if finish['active_workers'] != 0 or not finish['all_inflight_saved']:
        raise ValueError('Cannot resume while prior workers are unresolved')
    for name, key in [('checkpoint.json', 'checkpoint_sha256'),
                      ('pending_jobs.json', 'pending_jobs_sha256'),
                      ('process_exit_receipt.json', 'process_exit_receipt_sha256')]:
        if R.digest(checkpoint / name) != finish[key]:
            raise ValueError('Pause receipt changed: ' + name)
    p = R.verify(source)
    R.verify_hashes(saved['input_and_receipt_sha256'])
    retained = {s: read(checkpoint / 'completed_retry_rows' / (s + '.json'))['rows'] for s in LABELS}
    jobs = read(source / 'retry_jobs.json')['jobs']
    pending_registry = read(checkpoint / 'pending_jobs.json')
    completed, pending = partition_jobs(jobs, retained, pending_registry['pending'])
    if (len(jobs), len(completed), len(pending)) != (7309, 1764, 5545):
        raise ValueError('Unexpected authorized checkpoint denominators')
    started = {(s, f.name) for s in LABELS for f in (source / 'repeat_01/plan_workers' / s).iterdir() if f.is_dir()}
    if started != set(completed):
        raise ValueError('Started task directories differ from saved terminal records')
    if (p['budgets']['planner_workers'], p['budgets']['search_seconds'],
            p['budgets']['replay_seconds'], p['budgets']['planning_worker_seconds']) != (8, 60, 60, 180):
        raise ValueError('Unexpected frozen limits')
    # Exclusive claim prevents a second continuation from the same checkpoint.
    claim = checkpoint / 'resume_claim.json'
    R.write(claim, {'created_utc': R.now(), 'output': str(root),
        'authorization': 'User explicitly requested 8 workers, only remaining 5545, no duplicate execution.'})
    root.mkdir(parents=True)
    names = ('selected_groups.json', 'sources.json', 'worlds.json', 'baseline_tasks.json',
        'implementation.py', 'review.py', 'repeat_01/original_tasks.json',
        'repeat_01/composition_tasks.json', 'repeat_01/compilation_report.json',
        'repeat_01/compiled_freeze.json', 'repeat_01/references.json')
    for name in names:
        dest = root / name
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source / name, dest)
    for stage in LABELS:
        for folder in ('parent_rows', 'registered_jobs', 'retry_registry'):
            dest = root / folder / (stage + '.json')
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source / folder / (stage + '.json'), dest)
        dest = root / 'retained_retry_rows' / (stage + '.json')
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(checkpoint / 'completed_retry_rows' / (stage + '.json'), dest)
    for f in (source / 'repeat_01/groups').glob('*/compilation.json'):
        dest = root / f.relative_to(source)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(f, dest)
    shutil.copyfile(__file__, root / 'resume.py')
    R.write(root / 'retry_jobs.json', {'jobs': pending, 'registered_retry_slots': 7309,
        'retained_completed_retry_slots': len(completed), 'segment_registered_slots': len(pending)})
    start = datetime.fromisoformat(state['started_utc'])
    deadline = start + timedelta(seconds=p['budgets']['planning_total_seconds'])
    if deadline <= datetime.now(timezone.utc):
        raise ValueError('Original safety deadline has expired')
    resume = {'source': str(source), 'checkpoint': str(checkpoint),
        'checkpoint_sha256': R.digest(checkpoint / 'checkpoint.json'),
        'retained_completed_retry_slots': len(completed), 'segment_registered_slots': len(pending),
        'registered_retry_slots': len(jobs), 'absolute_safety_deadline_utc': deadline.isoformat(),
        'fresh_uniform_budget_experiment': False, 'new_api_requests': 0,
        'authorization': read(claim)['authorization']}
    R.write(root / 'resume_condition.json', resume)
    hashes = dict(p['input_sha256'])
    hashes.update(saved['input_and_receipt_sha256'])
    for name in ('checkpoint.json', 'pause_complete.json', 'pending_jobs.json', 'resume_claim.json'):
        hashes[str(checkpoint / name)] = R.digest(checkpoint / name)
    hashes[str(source / 'protocol.json')] = R.digest(source / 'protocol.json')
    hashes.update({str(f.resolve()): R.digest(f) for f in root.rglob('*') if f.is_file()})
    p.update(status='frozen_before_explicit_pause_continuation', condition=CONDITION,
        created_utc=R.now(), pause_continuation=resume, input_sha256=hashes)
    p['policies'] += [
        'Explicitly resumed after a drained pause; preserved 1764 terminal retries and dispatch only 5545 never-started IDs.',
        'Paused and resumed segments remain separate artifacts; do not describe the result as a fresh uninterrupted run.',
        'Original seven-day safety deadline is retained, including the pause; no budget reset.',
        'Exclusive checkpoint claim and execution-start receipt prevent duplicate continuation or restart.',
        'Only a user-created pause_request.json stops new dispatch; in-flight tasks drain and remain preserved.'
    ]
    R.write(root / 'protocol.json', p)
    (root / 'PROTOCOL.sha256').write_text(R.digest(root / 'protocol.json') + '\n', encoding='utf8')
    R.write(root / 'execution_condition.json', {'condition': CONDITION, 'pause_continuation': resume})
    R.progress(root, {}, status='prepared', stage='ready_for_explicit_resume', condition=CONDITION,
        completed_retry_slots=len(completed), registered_retry_slots=7309, pending_retry_slots=len(pending),
        segment_completed_retry_slots=0, segment_registered_slots=len(pending), planner_workers=8,
        active_workers=0, newly_dual_validated=sum(bool(r.get('valid')) for r in completed.values()),
        new_api_requests=0)
    return resume


def progress(root, state, results, retained, started, active, **updates):
    R.progress(root, state, completed_retry_slots=len(results),
        segment_completed_retry_slots=len(results) - len(retained),
        pending_retry_slots=7309 - len(results), started_retry_slots=len(retained) + len(started),
        segment_started_retry_slots=len(started), active_workers=len(active),
        active_jobs=[j['stage'] + '/' + j['id'] for j in active.values()],
        completed_by_stage=dict(Counter(s for s, _ in results)),
        newly_dual_validated=sum(bool(r.get('valid')) for r in results.values()),
        segment_newly_dual_validated=sum(bool(r.get('valid')) for k, r in results.items() if k not in retained),
        **updates)


def run(root):
    # 'x' is deliberate: restarting this output is forbidden, even after a crash.
    R.write(root / 'execution_started.json', {'created_utc': R.now(), 'pid': os.getpid(),
        'planner_workers': 8, 'new_api_requests': 0})
    state = {'status': 'running', 'stage': 'verify_inputs', 'condition': CONDITION,
        'registered_retry_slots': 7309, 'segment_registered_slots': 5545,
        'retained_completed_retry_slots': 1764, 'planner_workers': 8, 'pid': os.getpid(), 'new_api_requests': 0}
    R.progress(root, state)
    p = R.verify(root)
    jobs = read(root / 'retry_jobs.json')['jobs']
    retained = {(s, r['id']): r for s in LABELS for r in read(root / 'retained_retry_rows' / (s + '.json'))['rows']}
    parent_rows = {s: read(root / 'parent_rows' / (s + '.json'))['rows'] for s in LABELS}
    prior = {(s, r['id']): r for s, rows in parent_rows.items() for r in rows}
    jobmap = {(j['stage'], j['id']): j for j in jobs}
    if len(jobs) != 5545 or len(jobmap) != 5545 or len(retained) != 1764 or set(retained) & set(jobmap):
        raise ValueError('Retained/pending partition changed before launch')
    results, started, active = dict(retained), set(), {}
    terminal, error, pause_requested = 'complete', None, False
    deadline = time.monotonic() + (datetime.fromisoformat(p['pause_continuation']['absolute_safety_deadline_utc'])
                                  - datetime.now(timezone.utc)).total_seconds()
    streams = {}
    try:
        check = subprocess.run(['wsl.exe', '--exec', '/bin/true'], capture_output=True, timeout=30,
            creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0))
        R.write(root / 'environment_check.json', {'returncode': check.returncode, 'created_utc': R.now(),
            'new_planner_calls': 0, 'new_api_requests': 0})
        if check.returncode != 0:
            raise RuntimeError('WSL environment unavailable before dispatch')
        for stage in LABELS:
            streams[stage] = (root / 'repeat_01' / (stage + '_retry_events.jsonl')).open('x', encoding='utf8')
        with ThreadPoolExecutor(max_workers=8) as pool:
            iterator = iter(jobs)

            def dispatch():
                nonlocal pause_requested
                if (root / 'pause_request.json').exists():
                    pause_requested = True
                while not pause_requested and len(active) < 8 and time.monotonic() < deadline:
                    job = next(iterator, None)
                    if job is None:
                        return
                    key = (job['stage'], job['id'])
                    if key in started or key in results:
                        raise ValueError('Duplicate dispatch blocked')
                    started.add(key)
                    seconds = min(p['budgets']['planning_worker_seconds'], deadline - time.monotonic())
                    active[pool.submit(T.one, root, job, prior[key], seconds)] = job

            dispatch()
            progress(root, state, results, retained, started, active,
                stage='retry_search_and_replay', started_utc=R.now())
            while active:
                done, _ = wait(active, timeout=10, return_when=FIRST_COMPLETED)
                for future in done:
                    job = active.pop(future)
                    key = (job['stage'], job['id'])
                    row = future.result()
                    if row['id'] != job['id'] or key in results:
                        raise ValueError('Retry result identity mismatch')
                    results[key] = row
                    streams[job['stage']].write(json.dumps(row, ensure_ascii=False) + '\n')
                    streams[job['stage']].flush()
                    if row.get('status') in ('worker_exception', 'worker_failed_without_result'):
                        raise RuntimeError('Worker failure; stop dispatch: ' + job['id'])
                dispatch()
                progress(root, state, results, retained, started, active)
            if len(results) != 7309:
                terminal = 'paused' if pause_requested else 'stopped_total_budget'
    except Exception:
        terminal, error = 'stopped_error', traceback.format_exc()
        R.write(root / 'terminal_error.json', {'created_utc': R.now(), 'traceback': error})
    finally:
        for stream in streams.values():
            stream.close()
    # Recover completed receipts if orchestration failed between save and logging.
    for key in started - results.keys():
        f = root / 'repeat_01/plan_workers' / key[0] / key[1] / 'worker_result.json'
        if f.exists():
            row = T.normalize(jobmap[key]['task'], read(f))
            row['execution_provenance'] = T.provenance(jobmap[key], prior[key])
            results[key] = row
    active.clear()
    if any(results[k] != row for k, row in retained.items()):
        raise ValueError('Retained terminal result was modified')
    if terminal == 'paused':
        folder = root / 'pause_checkpoint'
        for stage in LABELS:
            R.write(folder / 'completed_retry_rows' / (stage + '.json'),
                {'rows': [r for (s, _), r in results.items() if s == stage]})
        R.write(folder / 'pending_jobs.json', {'jobs': [j for j in jobs if (j['stage'], j['id']) not in results]})
        R.write(folder / 'pause_complete.json', {'status': 'paused', 'created_utc': R.now(),
            'completed_retry_slots': len(results), 'active_workers': 0, 'all_inflight_saved': True})
        progress(root, state, results, retained, started, active, status='paused', stage='paused_after_inflight_drain')
        return {'status': 'paused', 'completed_retry_slots': len(results)}
    progress(root, state, results, retained, started, active,
        status='finalizing', stage='combine_preserved_and_retried', terminal_status=terminal)
    retry_keys = set(retained) | set(jobmap)
    combined = combine_rows(parent_rows, results, retry_keys, p['continuation']['parent'])
    for stage, rows in combined.items():
        if len(rows) != R.EXPECTED[stage]:
            raise ValueError('Combined evaluation denominator changed')
        R.write(root / 'repeat_01' / (stage + '_report.json'), {'registered_slots': len(rows), 'rows': rows})
    totals = {}
    for stage in LABELS:
        rows = [r for (s, _), r in results.items() if s == stage]
        transitions = Counter((R.outcome(prior[(stage, r['id'])]), R.outcome(r)) for r in rows)
        totals[stage] = {'retried': len(rows), 'newly_dual_validated': sum(bool(r.get('valid')) for r in rows),
            'retry_outcomes': dict(Counter(R.outcome(r) for r in rows)),
            'transitions': [{'before': a, 'after': b, 'count': n} for (a, b), n in sorted(transitions.items())]}
    R.write(root / 'retry_summary.json', {'status': terminal, 'created_utc': R.now(), 'condition': CONDITION,
        'registered_retry_slots': 7309, 'completed_retry_slots': len(results), 'stages': totals,
        'retained_completed_retry_slots': len(retained), 'segment_completed_retry_slots': len(results) - len(retained),
        'new_api_requests': 0, 'source_reference_backfill': False, 'historical_results_preserved': True})
    progress(root, state, results, retained, started, active, stage='evaluation')
    evaluation = R.evaluation(root, terminal)
    spec = importlib.util.spec_from_file_location('resumed_timeout_review', root / 'review.py')
    reviewer = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(reviewer)
    review = reviewer.review(root, root / 'paired_review_v1')
    R.write(root / 'completion.json', {'status': terminal, 'created_utc': R.now(), 'condition': CONDITION,
        'registered_retry_slots': 7309, 'completed_retry_slots': len(results),
        'retained_completed_retry_slots': len(retained), 'segment_started_retry_slots': len(started),
        'segment_completed_retry_slots': len(results) - len(retained), 'new_api_requests': 0,
        'no_duplicate_retry_dispatch': not (set(retained) & started), 'retained_results_unchanged': True,
        'evaluation': evaluation, 'review': review, 'error': error})
    progress(root, state, results, retained, started, active, status=terminal, stage='finished',
        evaluation=evaluation, review=review)
    return {'status': terminal, 'completed_retry_slots': len(results)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=('prepare', 'run'))
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--checkpoint', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    source, root = args.source.resolve(), args.output.resolve()
    load(source)
    result = prepare(source, args.checkpoint.resolve(), root) if args.mode == 'prepare' else run(root)
    print(json.dumps(result, ensure_ascii=False), flush=True)


if __name__ == '__main__':
    main()

"""Explicit scheduling continuation of an existing Batch round, without retries.

The parent remains immutable. Cloud batches are adopted by their existing IDs;
only shards with neither a local intent nor a cloud job can be submitted.
"""
import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
import ctypes
import importlib.util
import json
import os
from pathlib import Path
import shutil
import sys
import time
import uuid

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('original_batch_helpers', HERE / 'run_openai_alignment_batch.py')
base = importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)
read, write, digest = base.read, base.write, base.digest


def check_shards(shards):
    seen, names = set(), set()
    for s in shards:
        ids = s['request_ids']
        if s['id'] in names or len(ids) != len(set(ids)) or seen.intersection(ids):
            raise ValueError('Duplicate shard or candidate identity')
        if len(ids) != s['requests']:
            raise ValueError('Incorrect shard denominator')
        seen.update(ids)
        names.add(s['id'])
    return seen


def match_inventory(shards, local, remote, campaign):
    """An intent without a proven cloud ID is ambiguous, never eligible again."""
    known = {s['id']: s for s in shards}
    matched, batch_ids = {}, set()
    for b in remote:
        if (b.get('metadata') or {}).get('campaign') != campaign:
            continue
        sid = b['metadata'].get('shard')
        if sid not in known or sid in matched or b['id'] in batch_ids:
            raise ValueError('Unknown or duplicate cloud shard')
        loc = local.get(sid)
        if not loc or not loc.get('input_file_id'):
            raise ValueError('Cloud batch has no auditable local upload')
        if b['input_file_id'] != loc['input_file_id']:
            raise ValueError('Cloud input file differs from local receipt')
        if loc.get('batch_id') and loc['batch_id'] != b['id']:
            raise ValueError('Cloud batch ID differs from local receipt')
        matched[sid] = b
        batch_ids.add(b['id'])
    if set(local) != set(matched):
        raise ValueError('Unresolved local submission intent; do not resubmit')
    return matched


def restore_ledger(shards, matched, reconciled):
    ledger, results, stop = base.Ledger(200*base.NANO), {}, []
    for s in shards:
        sid = s['id']
        if sid not in matched:
            continue
        if not ledger.reserve(sid, s['reserved_max_cost_nano_usd']):
            raise ValueError('Inherited commitments exceed original global cap')
        r = reconciled.get(sid)
        if r is None:
            continue
        rows, amount = r['rows'], r['accounted_nano_usd']
        if (len(rows) != s['requests'] or {v['id'] for v in rows} != set(s['request_ids'])
                or any(v.get('batch_id') != matched[sid]['id'] for v in rows)):
            raise ValueError('Inherited result identity mismatch')
        if matched[sid]['status'] not in base.TERMINAL:
            raise ValueError('Reconciled batch is not terminal')
        if amount is not None and (type(amount) is not int or amount < 0):
            raise ValueError('Invalid inherited cost')
        ledger.settle(sid, amount)
        results.update({v['id']: v for v in rows})
        stop.extend(r.get('stop_reasons', []))
        if amount is None:
            stop.append('unknown_inherited_billing')
    return ledger, results, sorted(set(stop))


def admission_ready(active, limit, stop):
    # A newly created batch must pass the provider's quota/validation gate
    # before another is submitted. A failed admission is never resubmitted.
    return (not stop and len(active) < limit and
            all(a['status'] in {'in_progress', 'finalizing'} and not a['poll_errors']
                for a in active.values()))


def process_alive(pid):
    if os.name != 'nt':
        try:
            os.kill(pid, 0)
            return True
        except ProcessLookupError:
            return False
    kernel = ctypes.WinDLL('kernel32', use_last_error=True)
    kernel.OpenProcess.restype = ctypes.c_void_p
    kernel.OpenProcess.argtypes = [ctypes.c_ulong, ctypes.c_int, ctypes.c_ulong]
    kernel.GetExitCodeProcess.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_ulong)]
    kernel.CloseHandle.argtypes = [ctypes.c_void_p]
    handle = kernel.OpenProcess(0x1000, False, pid)
    if not handle:
        if ctypes.get_last_error() == 87:
            return False
        raise OSError('Cannot establish whether parent coordinator stopped')
    try:
        code = ctypes.c_ulong()
        if not kernel.GetExitCodeProcess(handle, ctypes.byref(code)):
            raise OSError('Cannot inspect parent coordinator')
        return code.value == 259
    finally:
        kernel.CloseHandle(handle)


def prepare(parent, root, limit):
    if root.exists() or not 3 <= limit <= 32:
        raise ValueError('Fresh continuation root and concurrency 3..32 required')
    p = base.verify(parent)
    print('Verifying frozen preparation and baseline; no remote mutations.', flush=True)
    base.verify_preparation(Path(p['preparation']), Path(p['audit']))
    shards = read(parent / 'shards.json')['shards']
    ids = check_shards(shards)
    if len(ids) != 17044:
        raise ValueError('Eligible denominator changed')
    root.mkdir(parents=True)
    implementation = root / 'implementation'
    implementation.mkdir()
    shutil.copyfile(__file__, implementation / Path(__file__).name)
    test = HERE.parents[1] / 'tests/test_openai_batch_acceleration.py'
    shutil.copyfile(test, implementation / test.name)
    quota_files = sorted(parent.glob('status_checks/*/quota_probe.json'))
    if quota_files:
        shutil.copyfile(quota_files[-1], root / 'quota_probe.json')
    protocol = {'condition': 'explicit_scheduling_continuation_same_inference_round',
        'parent': str(parent), 'parent_protocol_sha256': digest(parent / 'protocol.json'),
        'authorization': '提高 Batch 并发，在账户额度和200美元总预算内尽快跑完，保留已有结果和在途批次，不要重复提交请求。',
        'created_unix': time.time(), 'max_active_batches': limit,
        'spending_cap_usd_including_parent': 200, 'model': p['model'], 'reasoning': p['reasoning'],
        'request_bodies_and_shards': 'Unchanged; read only from verified parent inputs.',
        'original_started_unix': read(parent / 'execution_started.json')['started_unix'],
        'dispatch_window_hours_from_original_start': 72,
        'quota_policy': 'No management-read permission. Provider admission governs account quota. '
            'Submit at most one new batch per cycle; wait for every validating batch to enter '
            'in_progress before admitting another. Any rejection stops new submissions; never retry.',
        'budget_policy': p['budget_policy'], 'error_policy': p['error_policy'],
        'poll_seconds_full': 30, 'poll_seconds_ramp': 3,
        'adoption_policy': 'Parent interpreter must be stopped. Match all local intents against '
            'the complete cloud batch listing by campaign, shard, input_file_id and batch_id. '
            'Unresolved or duplicate identity blocks all new inference submissions.',
        'preservation_policy': 'No writes to parent; inherited result files are hashed and referenced. '
            'Existing cloud jobs are polled and collected under continuation root, never cancelled.',
        'implementation_sha256': {f.name: digest(f) for f in implementation.iterdir()},
        'api_sources': ['https://developers.openai.com/api/docs/guides/batch',
                        'https://developers.openai.com/api/docs/guides/rate-limits']}
    write(root / 'protocol.json', protocol)
    (root / 'PROTOCOL.sha256').write_text(digest(root / 'protocol.json')+'\n', encoding='utf-8')
    write(root / 'preflight.json', {'status': 'verified', 'parent_protocol_verified': True,
        'eligible_unique_requests': len(ids), 'shards': len(shards),
        'max_active_batches': limit, 'remote_mutations': 0})
    print(json.dumps(read(root / 'preflight.json')), flush=True)


def cloud_inventory(key, campaign, root):
    relevant, after, page = [], None, 0
    while True:
        data = base.api(key, 'batches?limit=100' + ('&after='+after if after else ''))
        # Store only this campaign's records, not unrelated account payloads.
        rows = [b for b in data['data'] if (b.get('metadata') or {}).get('campaign') == campaign]
        write(root / 'handoff/cloud' / f'page_{page:04d}.json', {'data': rows,
            'account_page_count': len(data['data']), 'has_more': data['has_more']})
        relevant.extend(rows)
        if not data['has_more']:
            return relevant
        cursor = data.get('last_id') or data['data'][-1]['id']
        if cursor == after:
            raise ValueError('Cloud pagination did not advance')
        after, page = cursor, page+1


def adopt(parent, root, key, shards):
    if process_alive(read(parent / 'execution_started.json')['pid']):
        raise ValueError('Parent coordinator still alive; no takeover allowed')
    local, reconciled = {}, {}
    for folder in sorted((parent / 'batches').iterdir()):
        sid = folder.name
        intent = read(folder / 'submission_intent.json')
        if intent['shard'] != next(s for s in shards if s['id'] == sid):
            raise ValueError('Parent intent differs from frozen shard')
        upload = read(folder / 'uploaded_file.json') if (folder / 'uploaded_file.json').exists() else {}
        receipt = read(folder / 'created_batch.json') if (folder / 'created_batch.json').exists() else {}
        local[sid] = {'input_file_id': upload.get('id'), 'batch_id': receipt.get('id')}
        if (folder / 'reconciled.json').exists():
            reconciled[sid] = read(folder / 'reconciled.json')
    remote = cloud_inventory(key, parent.name, root)
    matched = match_inventory(shards, local, remote, parent.name)
    # Snapshot every historical file only after the sole old writer has exited.
    protected = {str(p.relative_to(parent)): digest(p) for p in parent.rglob('*') if p.is_file()}
    write(root / 'handoff/parent_files.json', {'parent': str(parent), 'files': protected})
    shutil.copyfile(parent / 'progress.json', root / 'handoff/parent_progress.json')
    ledger, results, stop = restore_ledger(shards, matched, reconciled)
    stop.extend(read(parent / 'progress.json').get('stop_reasons', []))
    active, history = {}, []
    for s in shards:
        sid = s['id']
        if sid not in matched:
            continue
        b = matched[sid]
        history.append({'shard': sid, 'id': b['id'], 'requests': s['requests'], 'origin': 'parent'})
        if sid not in reconciled:
            write(root / 'batches' / sid / 'adopted_batch.json', b)
            active[sid] = {'id': b['id'], 'status': b['status'], 'poll_errors': 0, 'shard': s}
    pending = [s for s in shards if s['id'] not in matched]
    write(root / 'handoff/report.json', {'status': 'verified_no_duplicate_submissions',
        'inherited_batches': len(history), 'inherited_submitted_requests': sum(h['requests'] for h in history),
        'inherited_result_rows': len(results), 'adopted_batch_ids': [a['id'] for a in active.values()],
        'unsubmitted_shards': len(pending), 'unsubmitted_requests': sum(s['requests'] for s in pending),
        'budget': ledger.snapshot(), 'protected_parent_files': len(protected),
        'stop_reasons': sorted(set(stop))})
    return ledger, results, sorted(set(stop)), active, history, pending


def collect(root, key, current, batch, items, normalize, validate):
    folder = root / 'batches' / current['shard']['id']
    if not (folder / 'terminal_batch.json').exists():
        write(folder / 'terminal_batch.json', batch)
    lines = []
    for label in ('output', 'error'):
        fid = batch.get(label+'_file_id')
        if not fid:
            continue
        saved = folder / (label+'.jsonl')
        if not saved.exists():
            content = base.api(key, 'files/'+fid+'/content', raw=True)
            temporary = saved.with_suffix('.downloading')
            temporary.write_bytes(content)
            temporary.replace(saved)
        lines.extend(json.loads(v) for v in saved.read_text(encoding='utf-8').splitlines() if v.strip())
    rows, debit, failures = base.reconcile(current['shard'], batch, lines, items, normalize, validate)
    ceiling = current['shard']['reserved_max_cost_nano_usd']
    if debit is not None and (debit < 0 or debit > ceiling):
        raise ValueError('Observed billing outside reservation')
    write(folder / 'reconciled.json', {'rows': rows, 'accounted_nano_usd': debit,
        'unknown_billing_reserved_instead': debit is None, 'stop_reasons': failures})
    return rows, debit, failures


def run(root, env_file):
    p = read(root / 'protocol.json')
    if digest(root / 'protocol.json') != (root / 'PROTOCOL.sha256').read_text(encoding='utf-8').strip():
        raise ValueError('Continuation protocol changed')
    for name, sha in p['implementation_sha256'].items():
        if digest(root / 'implementation' / name) != sha:
            raise ValueError('Frozen continuation implementation changed')
    if digest(__file__) != p['implementation_sha256'][Path(__file__).name]:
        raise ValueError('Live continuation implementation changed')
    parent = Path(p['parent'])
    original = base.verify(parent)
    if digest(parent / 'protocol.json') != p['parent_protocol_sha256']:
        raise ValueError('Parent changed')
    if (root / 'execution_started.json').exists():
        raise ValueError('Continuation already started; no implicit retry')
    # One permanent claim per parent prevents competing continuation roots.
    # A stale claim is evidence of interruption, not permission to resubmit.
    claim = parent.parent / ('.'+parent.name+'.continuation_claim.json')
    write(claim, {'continuation': str(root), 'pid': os.getpid(), 'unix': time.time()})
    write(root / 'execution_started.json', {'pid': os.getpid(), 'started_unix': time.time(),
        'protocol_sha256': digest(root / 'protocol.json')})
    key = base.helpers.credential(env_file)
    shards = read(parent / 'shards.json')['shards']
    check_shards(shards)
    ledger, results, stop, active, history, pending = adopt(parent, root, key, shards)
    base.adapter.selection_adapter.bind_release(Path(original['release']))
    from rcnc.model_semantics_compact import normalize
    from rcnc.model_semantics import validate, to_group
    prep = Path(original['preparation'])
    items = {r['id']: r for r in (json.loads(line) for line in (prep / 'judgment_packet.jsonl').open(encoding='utf-8'))}
    eligibility = read(Path(original['audit']) / 'request_eligibility.json')['rows']
    results.update({r['id']: {'id': r['id'], 'kind': r['kind'], 'submitted': False,
        'status': r['status']} for r in eligibility if r['status'] != 'eligible'})
    attempted = {h['shard'] for h in history}
    unknown = set()
    limit = p['max_active_batches']

    def progress(status='running'):
        data = {'status': status, 'updated_unix': time.time(), 'condition': p['condition'],
            'parent': str(parent), 'model': p['model'], 'transport': 'batch',
            'registered_candidates': len(items), 'eligible_candidates': 17044,
            'max_active_batches': limit, 'submitted_batches': len(history),
            'submitted_requests': sum(h['requests'] for h in history),
            'unsubmitted_requests': sum(s['requests'] for s in pending),
            'status_counts': dict(Counter(r['status'] for r in results.values())),
            'active_batches': [{k: v for k, v in a.items() if k != 'shard'} for a in active.values()],
            'budget': ledger.snapshot(), 'stop_reasons': sorted(set(stop)),
            'ambiguous_shards': sorted(unknown), 'full_fusion_or_planning_complete': False}
        base.helpers.atomic_progress(root / 'progress.json', data)
        print(json.dumps({k: data[k] for k in ('status', 'submitted_batches', 'submitted_requests', 'budget', 'stop_reasons')}), flush=True)

    progress()
    while pending or active:
        if time.time()-p['original_started_unix'] >= 72*3600:
            if 'dispatch_window_elapsed' not in stop:
                stop.append('dispatch_window_elapsed')
        # Read-only GETs may run concurrently; all mutations and ledger changes
        # remain serial in this single coordinator.
        with ThreadPoolExecutor(max_workers=8) as pool:
            polls = {sid: pool.submit(base.api, key, 'batches/'+a['id']) for sid, a in active.items()}
            for sid, future in polls.items():
                current = active[sid]
                folder = root / 'batches' / sid
                try:
                    batch = future.result()
                    current.update(status=batch['status'], request_counts=batch.get('request_counts'))
                    base.helpers.atomic_progress(folder / 'latest_batch.json', batch)
                    if batch['status'] not in base.TERMINAL:
                        current['poll_errors'] = 0
                        continue
                    rows, debit, failures = collect(root, key, current, batch, items, normalize, validate)
                    ledger.settle(sid, debit)
                    results.update({r['id']: r for r in rows})
                    stop.extend(f for f in failures if f not in stop)
                    del active[sid]
                except Exception as exc:
                    current['poll_errors'] += 1
                    write(folder / ('poll_error_'+uuid.uuid4().hex+'.json'), base.safe_error(exc))
                    if current['poll_errors'] >= 3:
                        stop.append('collection_error_'+sid)
                        progress('stopped_with_unresolved_batch')
                        return
        if pending and admission_ready(active, limit, stop):
            shard = pending[0]
            sid = shard['id']
            if sid in attempted:
                raise ValueError('Attempted shard reached submission queue twice')
            if ledger.reserve(sid, shard['reserved_max_cost_nano_usd']):
                attempted.add(sid)
                pending.pop(0)
                folder = root / 'batches' / sid
                write(folder / 'submission_intent.json', {'shard': shard, 'created_unix': time.time(),
                    'policy': 'One create attempt only, including ambiguous transport outcomes.'})
                try:
                    uploaded = base.upload(key, Path(shard['path']))
                    write(folder / 'uploaded_file.json', uploaded)
                    creation = {'input_file_id': uploaded['id'], 'endpoint': '/v1/responses',
                        'completion_window': '24h', 'metadata': {'campaign': parent.name,
                        'continuation': root.name, 'shard': sid},
                        'output_expires_after': {'anchor': 'created_at', 'seconds': 30*24*3600}}
                    write(folder / 'create_request.json', creation)
                    batch = base.api(key, 'batches', creation)
                    write(folder / 'created_batch.json', batch)
                    active[sid] = {'id': batch['id'], 'status': batch['status'], 'poll_errors': 0, 'shard': shard}
                    history.append({'shard': sid, 'id': batch['id'], 'requests': shard['requests'], 'origin': 'continuation'})
                except Exception as exc:
                    write(folder / 'submission_failure.json', base.safe_error(exc))
                    unknown.add(sid)
                    stop.append('submission_failed_or_ambiguous_'+sid)
                    # Do not refund liability or repeat either upload/create.
            elif not active:
                stop.append('spending_cap_prevents_next_frozen_shard')
        progress('draining' if stop else 'running')
        if not active and (stop or not pending):
            break
        time.sleep(3 if pending and not stop and len(active) < limit else 30)
    submitted_ids = {cid for s in shards if s['id'] in attempted for cid in s['request_ids']}
    unknown_ids = {cid for s in shards if s['id'] in unknown for cid in s['request_ids']}
    for item in items.values():
        cid = item['id']
        results.setdefault(cid, {'id': cid, 'kind': item['kind'], 'submitted': cid in submitted_ids,
            'status': 'not_requested_budget_or_stop', 'stop_reasons': sorted(set(stop))})
        if cid in unknown_ids:
            results[cid].update(status='submission_unknown', submitted=None)
    groups = []
    for item in items.values():
        group = to_group(item, results[item['id']])
        for member in group['members']:
            if 'semantics' in member:
                member['semantics']['judgment_origin'] = 'automatic_openai_batch_model'
        groups.append(group)
    write(root / 'judgments/groups.json', {'groups': groups})
    write(root / 'judgments/report.json', {'status': 'stopped' if stop else 'complete_judgment_round',
        'condition': p['condition'], 'candidate_count': len(items), 'eligible_candidates': 17044,
        'submitted_batches': history, 'rows': list(results.values()),
        'status_counts': dict(Counter(r['status'] for r in results.values())),
        'budget': ledger.snapshot(), 'stop_reasons': sorted(set(stop)),
        'full_fusion_or_planning_complete': False, 'independent_semantic_labels': 0})
    progress('stopped' if stop else 'complete_judgment_round')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['prepare', 'run'])
    parser.add_argument('--parent', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--max-active', type=int, default=16)
    parser.add_argument('--env-file', type=Path)
    args = parser.parse_args()
    if args.command == 'prepare':
        prepare(args.parent.resolve(), args.output.resolve(), args.max_active)
    else:
        try:
            run(args.output.resolve(), args.env_file.resolve())
        except Exception as exc:
            # Preserve a safe failure receipt; never auto-resume a crashed writer.
            target = args.output / ('fatal_'+uuid.uuid4().hex+'.json')
            write(target, {**base.safe_error(exc), 'message': str(exc)[:500], 'time': time.time()})
            raise

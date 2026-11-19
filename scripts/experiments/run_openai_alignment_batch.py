"""Budgeted Batch transport for the frozen union/full alignment requests.

Each inference is submitted once. A small first shard checks provider acceptance;
later frozen shards use the same request bodies and belong to the same round.
"""
import argparse
from collections import Counter
import importlib.util
import json
import os
from pathlib import Path
import shutil
import time
import urllib.error
import urllib.request
import uuid

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('alignment_sync_helpers', HERE / 'run_openai_alignment_round.py')
helpers = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helpers)
adapter = helpers.adapter
read, digest, write = adapter.read, adapter.digest, adapter.write
TERMINAL = {'completed', 'failed', 'expired', 'cancelled'}
NANO = 1_000_000_000


def liability_nano(body):
    # UTF-8 bytes plus framing slack are a conservative token allowance, not a
    # measured token count. Include the largest documented Batch cache-write
    # input tariff as well as the full unchanged output ceiling.
    size = len(body['input'][0]['content'].encode('utf-8'))
    size += len(json.dumps(body['text']['format']).encode('utf-8'))
    return (size + 8192) * 2500 + body['max_output_tokens'] * 5000


def usage_nano(usage, *, conservative=True):
    a, b = usage.get('input_tokens'), usage.get('output_tokens')
    if type(a) is not int or type(b) is not int or min(a, b) < 0:
        raise ValueError('Missing auditable usage')
    return a * (2500 if conservative else 1000) + b * 5000


class Ledger:
    def __init__(self, cap_nano):
        if type(cap_nano) is not int or cap_nano <= 0:
            raise ValueError('Positive integer cap required')
        self.cap, self.spent, self.reserved = cap_nano, 0, {}

    def reserve(self, shard, amount):
        if shard in self.reserved or amount < 0:
            raise ValueError('Invalid or duplicate reservation')
        if self.spent + sum(self.reserved.values()) + amount > self.cap:
            return False
        self.reserved[shard] = amount
        return True

    def settle(self, shard, amount=None):
        ceiling = self.reserved.pop(shard)
        self.spent += ceiling if amount is None else amount
        if amount is not None and amount > ceiling:
            raise ValueError('Observed usage exceeded reserved ceiling')
        if self.spent + sum(self.reserved.values()) > self.cap:
            raise ValueError('Budget invariant violated')

    def snapshot(self):
        return {'cap_usd': self.cap/NANO, 'settled_conservative_usd': self.spent/NANO,
                'reserved_in_flight_usd': sum(self.reserved.values())/NANO,
                'remaining_uncommitted_usd': (self.cap-self.spent-sum(self.reserved.values()))/NANO}


def api(key, path, payload=None, *, raw=False, content_type='application/json', method=None):
    data = payload if isinstance(payload, bytes) else (json.dumps(payload).encode('utf-8') if payload is not None else None)
    request = urllib.request.Request('https://api.openai.com/v1/' + path, data=data,
        method=method, headers={'Authorization': 'Bearer ' + key, 'Content-Type': content_type})
    with urllib.request.urlopen(request, timeout=60) as response:
        content = response.read()
    return content if raw else json.loads(content)


def upload(key, path):
    boundary = 'batch_' + uuid.uuid4().hex
    prefix = (f'--{boundary}\r\nContent-Disposition: form-data; name="purpose"\r\n\r\nbatch\r\n'
              f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="{path.name}"\r\n'
              'Content-Type: application/jsonl\r\n\r\n').encode('utf-8')
    data = prefix + path.read_bytes() + f'\r\n--{boundary}--\r\n'.encode('ascii')
    return api(key, 'files', data, content_type='multipart/form-data; boundary=' + boundary)


def safe_error(exc):
    row = {'error_type': type(exc).__name__}
    if isinstance(exc, urllib.error.HTTPError):
        row['http_status'] = exc.code
        try:
            error = json.loads(exc.read().decode('utf-8')).get('error', {})
            row.update(provider_error_type=error.get('type'), provider_error_code=error.get('code'))
        except (ValueError, UnicodeError):
            pass
    return row


def verify_preparation(preparation, audit):
    gate = read(audit / 'report.json')
    if gate['status'] != 'verified_offline_preparation' or gate['preparation'] != str(preparation):
        raise ValueError('Mismatched prerequisite audit')
    for name, checksum in read(audit / 'audit_freeze.json')['files'].items():
        if digest(audit / name) != checksum:
            raise ValueError('Audit changed: ' + name)
    if digest(preparation / 'preparation_freeze.json') != gate['preparation_sha256']:
        raise ValueError('Preparation identity changed')
    for name, checksum in read(preparation / 'preparation_freeze.json')['files'].items():
        if digest(preparation / name) != checksum:
            raise ValueError('Preparation changed: ' + name)
    release = Path(read(preparation / 'preparation_policy.json')['release'])
    adapter.selection_adapter.verify_release(release)
    return gate, release


def partition(requests):
    return [requests[:32]] + [requests[i:i+128] for i in range(32, len(requests), 128)]


def prepare(preparation, audit, root):
    if root.exists():
        raise ValueError('Fresh campaign directory required')
    gate, release = verify_preparation(preparation, audit)
    eligible = {r['id'] for r in read(audit / 'request_eligibility.json')['rows'] if r['status'] == 'eligible'}
    all_requests = [json.loads(line) for line in (preparation / 'openai_requests.jsonl').open(encoding='utf-8')]
    requests = [r for r in all_requests if r['custom_id'] in eligible]
    if len(requests) != 17044 or len({r['custom_id'] for r in requests}) != len(requests):
        raise ValueError('Changed eligible request denominator')
    for request in requests:
        body = request['body']
        if (body['model'] != 'gpt-6.1-sol' or body['reasoning'] != {'effort': 'medium'}
                or body['max_output_tokens'] != 4096 or request['url'] != '/v1/responses'):
            raise ValueError('Request settings changed')
    root.mkdir(parents=True)
    implementation = root / 'implementation'
    implementation.mkdir()
    files = (Path(__file__), HERE / 'run_openai_alignment_round.py',
             HERE / 'prepare_union_full_openai.py', adapter.SELECTOR_PATH)
    for filename in files:
        shutil.copyfile(filename, implementation / filename.name)
    chunks = []
    for index, rows in enumerate(partition(requests)):
        sid = f'batch_{index:04d}'
        path = root / 'inputs' / (sid + '.jsonl')
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open('x', encoding='utf-8', newline='\n') as stream:
            for row in rows:
                stream.write(json.dumps(row, ensure_ascii=False) + '\n')
        chunks.append({'id': sid, 'path': str(path), 'sha256': digest(path),
            'request_ids': [r['custom_id'] for r in rows], 'requests': len(rows),
            'reserved_max_cost_nano_usd': sum(liability_nano(r['body']) for r in rows)})
    write(root / 'shards.json', {'shards': chunks})
    write(root / 'authorization.json', {'date': '2026-11-05', 'timezone': 'Australia/Sydney',
        'user_instruction': '200usd 然后是否可以batch 提交 进行加速和降本',
        'model_previously_selected': 'gpt-6.1-sol', 'reasoning': 'medium', 'spending_cap_usd': 200,
        'scope': 'One new Batch inference attempt per eligible frozen candidate; no historical requests reused.'})
    protocol = {'status': 'frozen_before_batch_submission', 'campaign': root.name,
        'condition': 'fresh_single_round_batch', 'preparation': str(preparation), 'audit': str(audit),
        'release': str(release), 'selection_sha256': gate['selection_sha256'],
        'preparation_sha256': gate['preparation_sha256'], 'baseline_sha256': gate['manifest_sha256'],
        'model': 'gpt-6.1-sol', 'reasoning': 'medium', 'max_output_tokens': 4096,
        'endpoint': '/v1/responses', 'completion_window': '24h', 'spending_cap_usd': 200,
        'candidate_count': 18948, 'eligible_candidates': 17044, 'excluded_missing_context': 1904,
        'groups': 1200, 'group_conditions': 2400, 'conditions': ['union', 'full'],
        'body_policy': 'Identical to offline-prepared requests; transport only changed to Batch.',
        'batch_policy': {'first_shard_requests': 32, 'later_shard_requests': 128,
            'max_active_batches': 2, 'first_shard_must_complete_before_further_submission': True,
            'submission_order': 'Frozen candidate hash order; no judgment outcomes enter order.',
            'poll_seconds': 30, 'read_only_poll_error_limit': 3, 'dispatch_window_hours': 72,
            'already_submitted_batches_after_window': 'Collect to terminal; no further submission.',
            'output_retention_days': 30},
        'prices_usd_per_million_tokens': {'batch_input': 1, 'batch_output': 5,
            'cached_input': .05, 'conservative_input_including_cache_writes': 2.5},
        'pricing_sources': ['https://developers.openai.com/api/docs/pricing',
                            'https://developers.openai.com/api/docs/guides/batch'],
        'budget_policy': 'Reserve UTF-8 input bytes plus 8192 framing tokens at the maximum '
            'documented cache-write input tariff and 4096 output tokens before submission. '
            'Settlement uses conservative input tariff and actual reported usage. No batch '
            'is submitted if settled costs plus all active worst-case reservations exceed $200. '
            'Unknown billing retains the full reservation and stops further submission.',
        'error_policy': 'No automatic inference retries or model switch. Transport ambiguity, '
            'batch validation failure, expired/cancelled work or request errors stop new submissions; '
            'already committed batches are collected. Invalid semantic JSON remains invalid.',
        'all_candidate_rows_retained': True, 'all_group_rows_retained': True,
        'input_sha256': {str(p): digest(p) for p in (root / 'inputs').glob('*.jsonl')},
        'implementation_sha256': {p.name: digest(p) for p in implementation.iterdir()},
        'authorization_sha256': digest(root / 'authorization.json'), 'shards_sha256': digest(root / 'shards.json')}
    write(root / 'protocol.json', protocol)
    (root / 'PROTOCOL.sha256').write_text(digest(root / 'protocol.json') + '\n', encoding='utf-8')
    report = {'status': 'ready_to_submit', 'eligible_requests': len(requests), 'shards': len(chunks),
        'spending_cap_usd': 200, 'all_request_bodies_unchanged': True,
        'first_shard_requests': chunks[0]['requests'],
        'first_shard_reserved_ceiling_usd': chunks[0]['reserved_max_cost_nano_usd']/NANO,
        'full_pool_output_only_theoretical_max_usd': 17044*4096*5/1e6,
        'full_pool_completion_within_budget_guaranteed': False, 'model_calls': 0}
    write(root / 'preparation_report.json', report)
    print(json.dumps(report, indent=2), flush=True)


def verify(root):
    p = read(root / 'protocol.json')
    if digest(root / 'protocol.json') != (root / 'PROTOCOL.sha256').read_text(encoding='utf-8').strip():
        raise ValueError('Batch protocol changed')
    for path, checksum in p['input_sha256'].items():
        if digest(path) != checksum:
            raise ValueError('Batch input changed')
    for name, checksum in p['implementation_sha256'].items():
        if digest(root / 'implementation' / name) != checksum or digest(HERE / name) != checksum:
            raise ValueError('Batch implementation changed: ' + name)
    if digest(root / 'shards.json') != p['shards_sha256']:
        raise ValueError('Shards changed')
    return p


def reconcile(shard, batch, lines, items, normalize, validate):
    expected, indexed = set(shard['request_ids']), {}
    for line in lines:
        cid = line['custom_id']
        if cid not in expected or cid in indexed:
            raise ValueError('Unexpected or duplicate Batch custom_id')
        indexed[cid] = line
    rows, fatal, known_usage = [], [], []
    for cid in shard['request_ids']:
        item, raw = items[cid], indexed.get(cid)
        row = {'id': cid, 'kind': item['kind'], 'submitted': True, 'batch_id': batch['id'],
               'inference_attempts_limit': 1}
        if raw is None:
            row.update(status='batch_result_missing', batch_status=batch['status'])
            fatal.append('batch_result_missing')
        elif raw.get('error') or (raw.get('response') or {}).get('status_code') != 200:
            row.update(status='request_failed', error=raw.get('error'),
                       http_status=(raw.get('response') or {}).get('status_code'))
            fatal.append('batch_request_failed')
        else:
            payload = raw['response']['body']
            try:
                known_usage.append(payload['usage'])
                usage_nano(payload['usage'])
                row.update(usage=payload['usage'], reported_model=payload.get('model'))
                if payload.get('model') != 'gpt-6.1-sol' and not str(payload.get('model', '')).startswith('gpt-6.1-sol-'):
                    fatal.append('unexpected_model')
                    raise ValueError('Unexpected returned model')
                compact, normalized = adapter.decode_response(payload, item, normalize, validate)
                row.update(status='checked', compact_judgment=compact, response=normalized)
            except (ValueError, TypeError, KeyError) as exc:
                row.update(status='invalid', reason=str(exc))
        rows.append(row)
    try:
        if batch.get('usage') is not None:
            debit = usage_nano(batch['usage'])
        elif len(known_usage) == len(expected):
            debit = sum(usage_nano(u) for u in known_usage)
        else:
            debit = None
    except (ValueError, TypeError, KeyError):
        debit = None
    if debit is None:
        fatal.append('unknown_batch_billing')
    if batch['status'] != 'completed':
        fatal.append('batch_terminal_' + batch['status'])
    return rows, debit, sorted(set(fatal))


def run(root, env_file):
    protocol = verify(root)
    if (root / 'execution_started.json').exists():
        raise ValueError('Already started; no implicit resume or duplicate submission')
    key = helpers.credential(env_file)
    preparation = Path(protocol['preparation'])
    verify_preparation(preparation, Path(protocol['audit']))
    adapter.selection_adapter.bind_release(Path(protocol['release']))
    from rcnc.model_semantics_compact import normalize
    from rcnc.model_semantics import validate, to_group
    items = {r['id']: r for r in (json.loads(line) for line in (
        preparation / 'judgment_packet.jsonl').open(encoding='utf-8'))}
    shards = read(root / 'shards.json')['shards']
    eligibility = read(Path(protocol['audit']) / 'request_eligibility.json')['rows']
    results = {r['id']: {'id': r['id'], 'kind': r['kind'], 'submitted': False,
                        'status': r['status']} for r in eligibility if r['status'] != 'eligible'}
    write(root / 'execution_started.json', {'pid': os.getpid(), 'started_unix': time.time(),
                                           'protocol_sha256': digest(root / 'protocol.json')})
    ledger = Ledger(200*NANO)
    active, history, stop_reasons = {}, [], []
    next_index, first_complete, began = 0, False, time.monotonic()

    def progress(status='running'):
        data = {'status': status, 'model': protocol['model'], 'transport': 'batch',
            'registered_candidates': len(items), 'eligible_candidates': 17044,
            'submitted_batches': len(history), 'submitted_requests': sum(r['requests'] for r in history),
            'terminal_candidate_rows': len(results), 'status_counts': dict(Counter(r['status'] for r in results.values())),
            'active_batches': [{k: v for k, v in a.items() if k != 'shard'} for a in active.values()],
            'next_shard_index': next_index, 'first_shard_complete': first_complete,
            'elapsed_seconds': time.monotonic()-began, 'budget': ledger.snapshot(), 'stop_reasons': stop_reasons}
        helpers.atomic_progress(root / 'progress.json', data)
        print(json.dumps({k: data[k] for k in ('status', 'submitted_batches', 'submitted_requests', 'budget', 'stop_reasons')}, ensure_ascii=False), flush=True)

    while next_index < len(shards) or active:
        if time.monotonic()-began >= 72*3600 and 'dispatch_window_elapsed' not in stop_reasons:
            stop_reasons.append('dispatch_window_elapsed')
        limit = 2 if first_complete else 1
        while not stop_reasons and len(active) < limit and next_index < len(shards):
            if next_index > 0 and not first_complete:
                break
            shard = shards[next_index]
            sid = shard['id']
            if not ledger.reserve(sid, shard['reserved_max_cost_nano_usd']):
                if not active:
                    stop_reasons.append('spending_cap_prevents_next_frozen_shard')
                break
            folder = root / 'batches' / sid
            write(folder / 'submission_intent.json', {'shard': shard, 'created_unix': time.time(),
                'policy': 'At most one upload/create sequence; an ambiguous create must not be repeated.'})
            try:
                uploaded = upload(key, Path(shard['path']))
                write(folder / 'uploaded_file.json', uploaded)
                creation = {'input_file_id': uploaded['id'], 'endpoint': '/v1/responses',
                    'completion_window': '24h', 'metadata': {'campaign': root.name, 'shard': sid},
                    'output_expires_after': {'anchor': 'created_at', 'seconds': 30*24*3600}}
                write(folder / 'create_request.json', creation)
                batch = api(key, 'batches', creation)
                write(folder / 'created_batch.json', batch)
                active[sid] = {'id': batch['id'], 'status': batch['status'], 'poll_errors': 0, 'shard': shard}
                history.append({'shard': sid, 'id': batch['id'], 'requests': shard['requests']})
                next_index += 1
                progress()
            except Exception as exc:
                write(folder / 'submission_failure.json', safe_error(exc))
                stop_reasons.append('submission_failed_or_ambiguous_' + sid)
                # Liability remains reserved. A created-but-unacknowledged batch
                # may still execute; no automatic resubmission is permitted.
                break
        if not active:
            break
        for sid in list(active):
            current = active[sid]
            folder = root / 'batches' / sid
            try:
                batch = api(key, 'batches/' + current['id'])
                current.update(status=batch['status'], poll_errors=0)
                helpers.atomic_progress(folder / 'latest_batch.json', batch)
                if batch['status'] not in TERMINAL:
                    continue
                if not (folder / 'terminal_batch.json').exists():
                    write(folder / 'terminal_batch.json', batch)
                lines = []
                for label in ('output', 'error'):
                    file_id = batch.get(label + '_file_id')
                    if file_id:
                        saved = folder / (label + '.jsonl')
                        if saved.exists():
                            content = saved.read_bytes()
                        else:
                            content = api(key, 'files/' + file_id + '/content', raw=True)
                            temporary = saved.with_suffix('.downloading')
                            with temporary.open('wb') as stream:
                                stream.write(content)
                            temporary.replace(saved)
                        lines.extend(json.loads(line) for line in content.decode('utf-8').splitlines() if line.strip())
                rows, debit, failures = reconcile(current['shard'], batch, lines, items, normalize, validate)
                ledger.settle(sid, debit)
                results.update({r['id']: r for r in rows})
                write(folder / 'reconciled.json', {'rows': rows, 'accounted_nano_usd': debit,
                    'unknown_billing_reserved_instead': debit is None, 'stop_reasons': failures})
                stop_reasons.extend(x for x in failures if x not in stop_reasons)
                if sid == 'batch_0000' and not failures:
                    first_complete = True
                del active[sid]
            except Exception as exc:
                current['poll_errors'] += 1
                write(folder / ('poll_error_' + uuid.uuid4().hex + '.json'), safe_error(exc))
                if current['poll_errors'] >= 3:
                    stop_reasons.append('collection_error_' + sid)
                    progress('stopped_with_unresolved_batch')
                    return
        progress('draining' if stop_reasons else 'running')
        if active:
            time.sleep(30)
    submitted_ids = {cid for shard in shards[:next_index] for cid in shard['request_ids']}
    for item in items.values():
        results.setdefault(item['id'], {'id': item['id'], 'kind': item['kind'],
            'submitted': item['id'] in submitted_ids, 'status': 'not_requested_budget_or_stop',
            'stop_reasons': stop_reasons})
    # Mark an ambiguous submission separately rather than declaring it unsent.
    for shard in shards:
        if (root / 'batches' / shard['id'] / 'submission_failure.json').exists():
            for cid in shard['request_ids']:
                results[cid].update(status='submission_unknown', submitted=None)
    normalized = []
    for item in items.values():
        group = to_group(item, results[item['id']])
        for member in group['members']:
            if 'semantics' in member:
                member['semantics']['judgment_origin'] = 'automatic_openai_batch_model'
        normalized.append(group)
    write(root / 'judgments/groups.json', {'groups': normalized})
    write(root / 'judgments/report.json', {'status': 'stopped' if stop_reasons else 'complete_judgment_round',
        'candidate_count': len(items), 'eligible_candidates': 17044,
        'submitted_batches': history, 'status_counts': dict(Counter(r['status'] for r in results.values())),
        'rows': list(results.values()), 'budget': ledger.snapshot(), 'stop_reasons': stop_reasons,
        'full_fusion_or_planning_complete': False, 'independent_semantic_labels': 0})
    progress('stopped' if stop_reasons else 'complete_judgment_round')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['prepare', 'run'])
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--preparation', type=Path)
    parser.add_argument('--audit', type=Path)
    parser.add_argument('--env-file', type=Path)
    args = parser.parse_args()
    if args.command == 'prepare':
        prepare(args.preparation.resolve(), args.audit.resolve(), args.output.resolve())
    else:
        run(args.output.resolve(), args.env_file.resolve())

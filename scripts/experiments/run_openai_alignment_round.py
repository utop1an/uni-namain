"""One fresh OpenAI alignment round with a spending guard and no retries.

This stage produces judgments only. Compilation and planning are separate stages
and cannot be mistaken for completed work when this stage stops early.
"""
import argparse
from collections import Counter
from concurrent.futures import FIRST_COMPLETED, ThreadPoolExecutor, wait
import importlib.util
import json
import os
from pathlib import Path
import shutil
import threading
import time
import urllib.error
import urllib.request

ADAPTER = Path(__file__).with_name('prepare_union_full_openai.py')
spec = importlib.util.spec_from_file_location('openai_adapter', ADAPTER)
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)
read, digest, write = adapter.read, adapter.digest, adapter.write


class SpendGuard:
    """Reserve conservative request liability before dispatch, then settle usage."""
    def __init__(self, cap):
        if not 0 < cap < float('inf'):
            raise ValueError('A positive finite USD cap is required')
        self.cap, self.spent, self.reserved = cap, 0.0, 0.0
        self.lock = threading.Lock()

    def reserve(self, amount):
        with self.lock:
            if amount < 0 or self.spent + self.reserved + amount > self.cap:
                return False
            self.reserved += amount
            return True

    def settle(self, reserved, actual=None):
        with self.lock:
            # A transport failure can have unknown billing; retain its full
            # reserved liability, halt dispatch and do not retry it.
            self.reserved -= reserved
            self.spent += reserved if actual is None else actual
            return self.spent + self.reserved <= self.cap

    def snapshot(self):
        with self.lock:
            return {'cap_usd': self.cap, 'accounted_usd': self.spent, 'reserved_usd': self.reserved}


def reservation(body):
    # Deliberately conservative byte-based estimate plus framing allowance.
    # Actual API usage is separately retained; this is not tokenizer evidence.
    input_bytes = len(body['input'][0]['content'].encode('utf-8'))
    input_bytes += len(json.dumps(body['text']['format']).encode('utf-8'))
    return (input_bytes + 8192) * 2 / 1e6 + body['max_output_tokens'] * 10 / 1e6


def usage_cost(payload):
    usage = payload.get('usage', {})
    a, b = usage.get('input_tokens'), usage.get('output_tokens')
    if type(a) is not int or type(b) is not int or min(a, b) < 0:
        raise ValueError('Missing auditable token usage')
    # Counting cached input at the full rate deliberately overstates the debit.
    return (a*2 + b*10) / 1e6


def credential(env_file):
    value = os.environ.get('OPENAI_API_KEY')
    if value:
        return value
    values = {}
    for line in env_file.read_text(encoding='utf-8-sig').splitlines():
        line = line.strip()
        if line and not line.startswith('#') and '=' in line:
            key, val = line.removeprefix('export ').split('=', 1)
            values[key.strip()] = val.strip().strip('"').strip("'")
    value = values.get('OPENAI_API_KEY') or values.get('openai_api')
    if not value:
        raise ValueError('OpenAI credential not configured')
    return value


def post(body, key, timeout):
    request = urllib.request.Request('https://api.openai.com/v1/responses',
        data=json.dumps(body, ensure_ascii=False).encode('utf-8'),
        headers={'Authorization': 'Bearer ' + key, 'Content-Type': 'application/json'})
    with urllib.request.urlopen(request, timeout=timeout) as response:
        return json.load(response)


def atomic_progress(path, value):
    temporary = path.with_suffix('.writing')
    temporary.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    temporary.replace(path)


def run(preparation, audit, output, env_file, max_usd, workers=4):
    if output.exists():
        raise ValueError('Fresh output required; no resume or retry')
    gate = read(audit / 'report.json')
    if gate['status'] != 'verified_offline_preparation' or gate['preparation'] != str(preparation):
        raise ValueError('Mismatched preparation gate')
    audit_freeze = read(audit / 'audit_freeze.json')
    for name, checksum in audit_freeze['files'].items():
        if digest(audit / name) != checksum:
            raise ValueError('Audit artifact changed')
    if digest(preparation / 'preparation_freeze.json') != gate['preparation_sha256']:
        raise ValueError('Preparation identity changed')
    manifest = read(preparation / 'preparation_freeze.json')
    for name, checksum in manifest['files'].items():
        if digest(preparation / name) != checksum:
            raise ValueError('Prepared input changed: ' + name)
    release = Path(read(preparation / 'preparation_policy.json')['release'])
    adapter.selection_adapter.verify_release(release)
    adapter.selection_adapter.bind_release(release)
    from rcnc.model_semantics_compact import normalize
    from rcnc.model_semantics import validate, to_group
    budget = SpendGuard(max_usd)
    key = credential(env_file)
    items = [json.loads(s) for s in (preparation / 'judgment_packet.jsonl').open(encoding='utf-8')]
    requests = {r['custom_id']: r['body'] for r in (
        json.loads(s) for s in (preparation / 'openai_requests.jsonl').open(encoding='utf-8'))}
    eligible = {r['id'] for r in read(audit / 'request_eligibility.json')['rows'] if r['status'] == 'eligible'}
    if set(requests) != {i['id'] for i in items} or len(eligible) != gate['maximum_paid_requests']:
        raise ValueError('Request denominator changed')
    if not 1 <= workers <= 4:
        raise ValueError('Workers must be from 1 to 4')
    output.mkdir(parents=True)
    implementation = output / 'implementation'
    implementation.mkdir()
    for filename in (Path(__file__), ADAPTER, adapter.SELECTOR_PATH):
        shutil.copyfile(filename, implementation / filename.name)
    protocol = {'status': 'frozen_before_paid_requests', 'condition': 'fresh_single_round',
        'preparation': str(preparation), 'audit': str(audit),
        'selection_sha256': gate['selection_sha256'], 'preparation_sha256': gate['preparation_sha256'],
        'baseline_manifest_sha256': gate['manifest_sha256'], 'model': 'gpt-6.1-sol',
        'reasoning': 'medium', 'endpoint': 'https://api.openai.com/v1/responses',
        'spending_cap_usd': max_usd, 'workers': workers, 'request_seconds': 240,
        'total_seconds': 144000, 'max_output_tokens': 4096, 'max_paid_requests': len(eligible),
        'all_candidates': len(items), 'attempts_per_candidate': 1, 'store': False,
        'price_usd_per_million_tokens': {'input': 2, 'output': 10},
        'billing_guard': 'Conservative reservation, actual token settlement, cached inputs at full price; '
                         'unknown billing halts dispatch. API billing itself is controlled by the provider.',
        'stop_on_transport_error': True, 'switch_model': False, 'retry': False,
        'model_seed': None, 'generated_determinism_claimed': False,
        'source_worlds_pooled': False, 'independent_semantic_labels': 0,
        'implementation_sha256': {p.name: digest(p) for p in implementation.iterdir()}}
    write(output / 'protocol.json', protocol)
    (output / 'PROTOCOL.sha256').write_text(digest(output / 'protocol.json') + '\n', encoding='utf-8')
    results = {i['id']: {'id': i['id'], 'kind': i['kind'], 'request_attempted': False,
                        'status': 'not_requested_insufficient_source_context'}
               for i in items if i['id'] not in eligible}
    queued = [i for i in items if i['id'] in eligible]
    started = time.monotonic()
    stop, reasons = threading.Event(), []
    stop_lock = threading.Lock()

    def halt(reason):
        with stop_lock:
            reasons.append(reason)
            stop.set()

    def perform(item, reserved):
        row = {'id': item['id'], 'kind': item['kind'], 'request_attempted': False}
        folder = output / 'responses' / item['id']
        folder.mkdir(parents=True)
        if stop.is_set():
            budget.settle(reserved, 0)
            row['status'] = 'not_requested_dispatch_stopped'
            return row
        write(folder / 'attempt.json', {'id': item['id'], 'started_unix': time.time(),
            'reserved_usd': reserved, 'attempt': 1, 'request': requests[item['id']]})
        row['request_attempted'] = True
        began, actual = time.monotonic(), None
        try:
            payload = post(requests[item['id']], key, min(240, max(1, 144000-(began-started))))
            write(folder / 'raw.json', payload)
            actual = usage_cost(payload)
            row.update(usage=payload['usage'], accounted_cost_usd=actual, reported_model=payload.get('model'))
            if payload.get('model') != 'gpt-6.1-sol' and not str(payload.get('model', '')).startswith('gpt-6.1-sol-'):
                halt('unexpected_reported_model')
                raise ValueError('Unexpected reported model')
            compact, normalized = adapter.decode_response(payload, item, normalize, validate)
            row.update(status='checked', compact_judgment=compact, response=normalized)
        except urllib.error.HTTPError as exc:
            # Do not persist headers or credential-bearing request objects.
            try:
                error = json.loads(exc.read().decode('utf-8')).get('error', {})
            except (ValueError, UnicodeError):
                error = {}
            row.update(status='request_failed', http_status=exc.code, error_type=error.get('type'), error_code=error.get('code'))
            halt('openai_http_error_' + str(exc.code))
        except (ValueError, KeyError, TypeError) as exc:
            row.update(status='invalid', reason=str(exc))
            if actual is None:
                halt('unaccounted_response_usage')
        except Exception as exc:
            row.update(status='request_failed', error_type=type(exc).__name__)
            halt('transport_error_' + type(exc).__name__)
        finally:
            within = budget.settle(reserved, actual)
            if actual is None:
                row['unknown_billing_liability_usd'] = reserved
            if not within or actual is not None and actual > reserved:
                halt('spending_reservation_exceeded')
            row['elapsed_seconds'] = time.monotonic()-began
        write(folder / 'result.json', row)
        return row

    index = 0
    with (output / 'events.jsonl').open('x', encoding='utf-8') as events:
        with ThreadPoolExecutor(max_workers=workers) as pool:
            active = {}
            while index < len(queued) or active:
                if time.monotonic()-started >= 144000:
                    halt('total_time_limit')
                while not stop.is_set() and len(active) < workers and index < len(queued):
                    item = queued[index]
                    liability = reservation(requests[item['id']])
                    if not budget.reserve(liability):
                        if not active:
                            halt('spending_cap')
                        break
                    active[pool.submit(perform, item, liability)] = item['id']
                    index += 1
                if not active:
                    break
                finished, _ = wait(active, timeout=5, return_when=FIRST_COMPLETED)
                for future in finished:
                    row = future.result()
                    del active[future]
                    results[row['id']] = row
                    events.write(json.dumps(row, ensure_ascii=False) + '\n')
                    events.flush()
                atomic_progress(output / 'progress.json', {'status': 'draining' if stop.is_set() else 'running',
                    'attempted_completed': sum(r['request_attempted'] for r in results.values()),
                    'status_counts': dict(Counter(r['status'] for r in results.values())),
                    'in_flight': list(active.values()), 'elapsed_seconds': time.monotonic()-started,
                    'budget': budget.snapshot(), 'stop_reasons': reasons})
    for item in queued:
        results.setdefault(item['id'], {'id': item['id'], 'kind': item['kind'], 'request_attempted': False,
                                       'status': 'not_requested_stopped', 'stop_reasons': reasons})
    rows = [results[i['id']] for i in items]
    groups = [to_group(i, results[i['id']]) for i in items]
    for group in groups:
        for member in group['members']:
            if 'semantics' in member:
                member['semantics']['judgment_origin'] = 'automatic_openai_model'
    write(output / 'groups.json', {'groups': groups})
    report = {'status': 'stopped' if stop.is_set() else 'complete_judgment_round',
        'candidate_count': len(items), 'eligible_candidates': len(eligible),
        'requests_attempted': sum(r['request_attempted'] for r in rows),
        'status_counts': dict(Counter(r['status'] for r in rows)), 'rows': rows,
        'stop_reasons': reasons, 'elapsed_seconds': time.monotonic()-started,
        'budget': budget.snapshot(), 'model': 'gpt-6.1-sol', 'reasoning': 'medium',
        'planning_or_full_experiment_complete': False, 'independent_semantic_labels': 0}
    write(output / 'report.json', report)
    print(json.dumps({k: v for k, v in report.items() if k != 'rows'}, ensure_ascii=False, indent=2), flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('preparation', 'audit', 'output', 'env-file'):
        parser.add_argument('--' + name, type=Path, required=True)
    parser.add_argument('--max-usd', type=float, required=True)
    parser.add_argument('--workers', type=int, default=4)
    args = parser.parse_args()
    run(args.preparation.resolve(), args.audit.resolve(), args.output.resolve(), args.env_file.resolve(),
        args.max_usd, args.workers)

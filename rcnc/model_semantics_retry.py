"""Explicit continuation of frozen requests with a bounded, auditable retry policy."""
from collections import Counter
from concurrent.futures import FIRST_COMPLETED, ThreadPoolExecutor, wait
import copy
import errno
import http.client
import json
from pathlib import Path
import re
import threading
import time

from rcnc.domain_building import digest, save
from rcnc.model_semantics_parallel import decode_payload
from rcnc.parallel_progress_io import durable_progress
from scripts.experiments.continue_revised_multistory import LocalConnection


LEGACY_RETRYABLE_ERRNOS = (32, 54, 60, 104, 110, 111, 10053, 10054, 10060, 10061)

POLICY = {
    'maximum_attempts_per_candidate_including_parent': 3,
    'retry_delays_seconds': [30, 60],
    'retryable_http_statuses': [408, 429, 500, 502, 503, 504],
    'retryable_os_errnos': sorted(set(LEGACY_RETRYABLE_ERRNOS + (errno.ENOBUFS, 10055))),
    'retryable_winerrors': [10053, 10054, 10055, 10060, 10061],
    'maximum_new_retry_attempts': 200,
    'invalid_outputs_retried': False,
    'exhausted_transient_failure': 'retain_unavailable_and_continue',
    'nontransient_failure': 'stop_dispatch_and_evaluate',
}


def transient(exc, policy=POLICY):
    match = re.match(r'^Ollama HTTP (\d{3}):', str(exc))
    if match:
        return int(match.group(1)) in policy['retryable_http_statuses']
    return isinstance(exc, (TimeoutError, ConnectionError, http.client.RemoteDisconnected,
                            http.client.IncompleteRead)) or (
        isinstance(exc, OSError) and (
            getattr(exc, 'errno', None) in policy.get('retryable_os_errnos', LEGACY_RETRYABLE_ERRNOS)
            or getattr(exc, 'winerror', None) in policy.get('retryable_winerrors', ())))


def partition(items, old_rows):
    if [i['id'] for i in items] != [r['id'] for r in old_rows] or len({i['id'] for i in items}) != len(items):
        raise ValueError('Parent rows must exactly match the unique frozen candidate order')
    retained, pending, previous = {}, [], {}
    for item, row in zip(items, old_rows):
        if item['kind'] != row['kind']:
            raise ValueError('Changed candidate kind')
        if row['status'] in ('checked', 'invalid') and row.get('request_attempted'):
            retained[item['id']] = copy.deepcopy(row)
        elif row['status'] == 'not_requested' and not row.get('request_attempted') and row.get('reason') == 'stop_after_transport_failure':
            pending.append(item); previous[item['id']] = 0
        elif row['status'] == 'request_failed' and row.get('request_attempted') and transient(OSError(row['reason'])):
            pending.append(item); previous[item['id']] = 1
        else:
            raise ValueError('Unregistered parent outcome: ' + item['id'])
    return retained, pending, previous


class AttemptBudget:
    def __init__(self, maximum_retries):
        self.maximum = maximum_retries
        self.retries = 0
        self.calls = 0
        self.lock = threading.Lock()

    def claim(self, attempt_number):
        with self.lock:
            if attempt_number > 1:
                if self.retries >= self.maximum:
                    return False
                self.retries += 1
            self.calls += 1
            return True


class WorkerClients:
    """Keep at most one reusable transport per worker; discard failed connections."""
    def __init__(self, factory):
        self.factory = factory
        self.clients = {}
        self.lock = threading.Lock()

    def get(self):
        worker = threading.get_ident()
        with self.lock:
            if worker not in self.clients:
                self.clients[worker] = self.factory()
            return self.clients[worker]

    def discard(self):
        with self.lock:
            client = self.clients.pop(threading.get_ident(), None)
        if client is not None:
            client.close()

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        # The executor exits first, so no worker can still be using these clients.
        with self.lock:
            clients = list(self.clients.values())
            self.clients.clear()
        for client in clients:
            client.close()


def perform(item, request, folder, manifest, prior_attempts, deadline, budget,
            stop, *, transport_factory=LocalConnection, clock=time.monotonic,
            wait_for_stop=None, client_pool=None):
    """Retry transport errors only; the first returned output is final, even if invalid."""
    policy = manifest['retry_policy']
    wait_for_stop = wait_for_stop or stop.wait
    row = {'id': item['id'], 'kind': item['kind'], 'request_attempted': False,
           'prior_attempts': prior_attempts, 'new_attempts': 0}
    attempts = []
    folder.mkdir(parents=True, exist_ok=False)
    began = clock()
    for number in range(prior_attempts + 1, policy['maximum_attempts_per_candidate_including_parent'] + 1):
        delay = policy['retry_delays_seconds'][number - 2] if number > 1 else 0
        if stop.is_set() or deadline - clock() <= delay:
            row.update(status='request_failed' if row['new_attempts'] else 'not_requested',
                       reason='dispatch_stopped' if stop.is_set() else 'total_budget_exhausted')
            break
        if delay and wait_for_stop(delay):
            row.update(status='request_failed' if row['new_attempts'] else 'not_requested', reason='dispatch_stopped')
            break
        if stop.is_set() or deadline <= clock():
            row.update(status='request_failed' if row['new_attempts'] else 'not_requested', reason='total_budget_exhausted')
            break
        if not budget.claim(number):
            row.update(status='request_failed' if row['new_attempts'] else 'not_requested', reason='retry_budget_exhausted')
            stop.set()
            break
        slot = folder / ('attempt_%02d' % number); slot.mkdir()
        receipt = {'id': item['id'], 'attempt_number_including_parent': number,
                   'started_unix': time.time(), 'request': request, 'backoff_seconds': delay}
        save(slot / 'attempt.json', receipt)
        row['request_attempted'] = True; row['new_attempts'] += 1
        client = None
        transport_failed = True
        started = clock()
        try:
            client = client_pool.get() if client_pool is not None else transport_factory()
            payload = client('http://127.0.0.1:11434/api/chat', request,
                             timeout=min(manifest['request_seconds'], max(.001, deadline - clock())))
            transport_failed = False
        except Exception as exc:
            retryable = transient(exc, policy)
            result = {'status': 'request_failed', 'reason': str(exc), 'transient': retryable,
                      'transport_error': {'type': type(exc).__name__,
                                          'errno': getattr(exc, 'errno', None),
                                          'winerror': getattr(exc, 'winerror', None)}}
            row.update(result)
            if not retryable:
                row['fatal_transport_failure'] = True; stop.set()
        else:
            save(slot / 'raw.json', payload)
            try:
                decode_payload(item, payload, manifest.get('schema_policy'), row)
            except (ValueError, KeyError, TypeError) as exc:
                row.update(status='invalid', reason=str(exc))
            result = {'status': row['status']}
        finally:
            if client_pool is not None:
                if transport_failed:
                    client_pool.discard()
            elif client is not None:
                client.close()
        result.update(attempt_number_including_parent=number, elapsed_seconds=clock() - started)
        save(slot / 'result.json', result); attempts.append(result)
        if row['status'] in ('checked', 'invalid') or stop.is_set():
            break
    row.update(attempt_history=attempts, total_attempts_including_parent=prior_attempts + row['new_attempts'],
               elapsed_seconds=clock() - began)
    if row['status'] in ('checked', 'invalid'):
        row.pop('transient', None)
        row.pop('transport_error', None)
        if row['status'] == 'checked': row.pop('reason', None)
    save(folder / 'result.json', row)
    return row


def run(output, *, transport_factory=LocalConnection):
    read = lambda p: json.loads(p.read_text(encoding='utf-8'))
    manifest = read(output / 'manifest.json')
    if any((output / n).exists() for n in ('responses', 'report.json', 'progress.json')):
        raise ValueError('Fresh continuation stage required')
    for name, expected in manifest['frozen_sha256'].items():
        if digest(Path(name)) != expected: raise ValueError('Frozen dependency changed: ' + name)
    items = read(output / 'packet.json')['items']; requests = read(output / 'requests.json')
    old = read(Path(manifest['parent_report']))
    retained, pending, previous = partition(items, old['rows'])
    if set(requests) != {i['id'] for i in items} or len(pending) != manifest['pending_candidates']:
        raise ValueError('Request denominator changed')
    started = time.monotonic(); deadline = started + manifest['total_seconds']
    budget = AttemptBudget(manifest['retry_policy']['maximum_new_retry_attempts'])
    completed = dict(retained); stop = threading.Event(); reason = None
    client = None
    try:
        client = transport_factory()
        models = client('http://127.0.0.1:11434/api/tags', timeout=10)['models']
        if not any(m['name'] == manifest['model'] and m['digest'] == manifest['model_digest'] for m in models):
            raise ValueError('Installed model digest differs')
    except Exception as exc:
        reason = 'model_unavailable: ' + str(exc); stop.set()
    finally:
        if client is not None:
            client.close()
    index = 0; peak = 0
    if not stop.is_set() and pending:
        (output / 'responses').mkdir()
    with WorkerClients(transport_factory) as clients, ThreadPoolExecutor(max_workers=manifest['workers']) as pool:
        futures = {}
        while True:
            if (output / 'STOP_REQUESTED').exists(): reason = 'operator_stop_requested'; stop.set()
            if time.monotonic() >= deadline: reason = 'total_budget_exhausted'; stop.set()
            while not stop.is_set() and len(futures) < manifest['workers'] and index < len(pending):
                item = pending[index]; index += 1
                if len(json.dumps(requests[item['id']])) > 60000:
                    completed[item['id']] = {'id': item['id'], 'kind': item['kind'], 'request_attempted': False,
                                              'status': 'not_requested', 'reason': 'context_size_limit'}
                    continue
                future = pool.submit(perform, item, requests[item['id']], output / 'responses' / item['id'],
                    manifest, previous[item['id']], deadline, budget, stop,
                    transport_factory=transport_factory, client_pool=clients)
                futures[future] = item
            peak = max(peak, len(futures))
            durable_progress(output / 'progress.json', {'status': 'draining' if stop.is_set() else 'running',
                'condition': 'interrupted_cache_continuation_with_bounded_retries',
                'candidate_count': len(items), 'retained_parent_outputs': len(retained),
                'completed': len(completed), 'new_completed': len(completed) - len(retained),
                'new_requests_attempted': budget.calls, 'new_retry_attempts': budget.retries,
                'status_counts': dict(Counter(r['status'] for r in completed.values())),
                'in_flight_ids': sorted(i['id'] for i in futures.values()), 'peak_client_inflight': peak,
                'elapsed_seconds': time.monotonic() - started, 'stop_reason': reason})
            if not futures: break
            done, _ = wait(futures, timeout=1, return_when=FIRST_COMPLETED)
            for f in sorted(done, key=lambda x: futures[x]['id']):
                item = futures.pop(f); row = f.result(); completed[item['id']] = row
                with (output / 'events.jsonl').open('a', encoding='utf-8') as stream:
                    stream.write(json.dumps({'finished_unix': time.time(), 'row': row}) + '\n')
                if row.get('fatal_transport_failure'): reason = 'nontransient_transport_failure'; stop.set()
                if row.get('reason') in ('retry_budget_exhausted', 'total_budget_exhausted'):
                    reason = row['reason']; stop.set()
    rows = [completed.get(i['id'], {'id': i['id'], 'kind': i['kind'], 'request_attempted': False,
            'status': 'not_requested', 'reason': reason or 'dispatch_stopped'}) for i in items]
    report = {'status': 'complete', 'condition': 'interrupted_cache_continuation_with_bounded_retries',
        'execution_status': 'stopped' if stop.is_set() else 'complete', 'stop_reason': reason,
        'candidate_count': len(items), 'retained_parent_outputs': len(retained),
        'parent_requests_attempted': old['requests_attempted'], 'new_requests_attempted': budget.calls,
        'new_retry_attempts': budget.retries, 'requests_attempted': old['requests_attempted'] + budget.calls,
        'candidate_requests_attempted': sum(r.get('request_attempted', False) or previous.get(r['id'], 0) > 0 for r in rows),
        'rows': rows, 'workers': manifest['workers'], 'peak_client_inflight': peak,
        'status_counts': dict(Counter(r['status'] for r in rows)),
        'decision_counts': dict(Counter(r['response']['decision'] for r in rows if r['status'] == 'checked')),
        'elapsed_seconds': time.monotonic() - started, 'parent_elapsed_seconds': old['elapsed_seconds'],
        'inputs_unchanged': all(digest(Path(n)) == h for n,h in manifest['frozen_sha256'].items()),
        'implementation_unchanged': all(digest(Path(n)) == h for n,h in manifest['implementation_sha256'].items()),
        'manifest_sha256': digest(output / 'manifest.json'), 'semantic_gold_labels': 0}
    from rcnc.model_semantics import to_group
    save(output / 'report.json', report)
    save(output / 'groups.json', {'groups': [to_group(i,r) for i,r in zip(items,rows)]})
    durable_progress(output / 'progress.json', {k:v for k,v in report.items() if k != 'rows'})
    return report

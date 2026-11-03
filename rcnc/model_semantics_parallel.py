"""Bounded parallel execution of unchanged frozen semantic requests."""
from collections import Counter
from concurrent.futures import FIRST_COMPLETED, ThreadPoolExecutor, wait
import json
from pathlib import Path
import threading
import time

from rcnc import model_semantics as semantics
from rcnc.domain_building import digest, save
from scripts.experiments.continue_revised_multistory import LocalConnection


def decode_payload(item, payload, policy, row):
    """Use the original normalization and validation, including invalid outcomes."""
    row['done_reason'] = payload.get('done_reason')
    row['eval_count'] = payload.get('eval_count')
    if not payload.get('done') or payload.get('done_reason') == 'length':
        raise ValueError('Incomplete or truncated generation')
    response = json.loads(payload['message']['content'])
    if policy in ('semantic_facets', 'semantic_facets_optional_roles'):
        from rcnc.model_semantics_facets import normalize
        row['semantic_facets'] = response
        response = normalize(item, response)
    elif policy == 'compact_kind_specific':
        from rcnc.model_semantics_compact import normalize
        row['compact_judgment'] = response
        response = normalize(item, response)
    elif policy == 'coupled_fields':
        from rcnc.model_semantics_schema import normalize
        response = normalize(response)
    semantics.validate(item, response)
    row.update(status='checked', response=response)


def atomic_save(path, value):
    temporary = path.with_name(path.name + '.writing')
    save(temporary, value)
    temporary.replace(path)


def run(output, *, transport_factory=LocalConnection):
    read = lambda p: json.loads(p.read_text(encoding='utf-8'))
    manifest = read(output/'manifest.json')
    if any((output/name).exists() for name in ('progress.json', 'report.json', 'responses')):
        raise ValueError('Fresh parallel stage required; no implicit resume')
    workers = manifest['workers']
    if type(workers) is not int or not 1 <= workers <= 10:
        raise ValueError('Bounded integer worker count required')
    for path, expected in {**manifest['source_sha256'], **manifest['implementation_sha256']}.items():
        if digest(Path(path)) != expected:
            raise ValueError('Frozen dependency changed: '+path)
    for name in ('packet', 'requests'):
        if digest(output/(name+'.json')) != manifest[name+'_sha256']:
            raise ValueError('Frozen request changed')
    items = read(output/'packet.json')['items']; requests = read(output/'requests.json')
    if len({i['id'] for i in items}) != len(items) or set(requests) != {i['id'] for i in items}:
        raise ValueError('Candidate/request identity mismatch')
    started = time.monotonic(); completed = {}; dispatched = set(); active = set()
    stop = threading.Event(); guard = threading.Lock(); thread_local = threading.local()
    clients = []; peak = 0; stop_reason = None; pilot_result = None
    pilot = manifest.get('parallel_pilot')
    if pilot and not 1 <= pilot['candidate_count'] <= len(items):
        raise ValueError('Pilot must be a nonempty frozen prefix')
    pilot_limit = pilot['candidate_count'] if pilot else len(items)
    phase_limit = pilot_limit; next_index = 0; phase_started = None
    preflight = transport_factory()
    try:
        models = preflight('http://127.0.0.1:11434/api/tags', timeout=10)['models']
        if not any(m['name']==manifest['model'] and m['digest']==manifest['model_digest'] for m in models):
            raise ValueError('Installed model digest differs')
    except Exception as exc:
        stop_reason = 'model_unavailable: '+str(exc); stop.set()
    finally:
        preflight.close()

    def progress():
        with guard:
            in_flight = sorted(active); observed_peak = peak
        atomic_save(output/'progress.json', {'status':'running' if not stop.is_set() else 'draining',
            'workers':workers,'candidate_count':len(items),'completed':len(completed),
            'attempted_completed':sum(r['request_attempted'] for r in completed.values()),
            'status_counts':dict(Counter(r['status'] for r in completed.values())),
            'in_flight_ids':in_flight,'peak_client_inflight':observed_peak,
            'elapsed_seconds':time.monotonic()-started,'stop_reason':stop_reason,
            'pilot':pilot_result or ({'status':'running','registered_candidates':pilot_limit} if pilot else None)})

    def perform(item):
        nonlocal peak
        row = {'id':item['id'],'kind':item['kind'],'request_attempted':False}
        remaining = manifest['total_seconds']-(time.monotonic()-started)
        if stop.is_set() or remaining <= 0:
            row.update(status='not_requested',reason='dispatch_stopped' if stop.is_set() else 'total_budget_exhausted')
            return row
        if len(json.dumps(requests[item['id']])) > 60000:
            row.update(status='not_requested',reason='context_size_limit')
            return row
        folder = output/'responses'/item['id']; folder.mkdir(parents=True)
        began = time.monotonic()
        row['request_attempted'] = True
        save(folder/'attempt.json', {'id':item['id'],'request_attempted':True,
            'started_unix':time.time(),'request':requests[item['id']], 'no_retry':True})
        with guard:
            active.add(item['id']); peak = max(peak, len(active))
        try:
            if not hasattr(thread_local, 'client'):
                thread_local.client = transport_factory()
                with guard: clients.append(thread_local.client)
            payload = thread_local.client('http://127.0.0.1:11434/api/chat', requests[item['id']],
                timeout=min(remaining,manifest['request_seconds']))
            save(folder/'raw.json',payload)
            decode_payload(item,payload,manifest.get('schema_policy'),row)
        except (ValueError,KeyError,TypeError) as exc:
            row.update(status='invalid',reason=str(exc))
        except Exception as exc:
            row.update(status='request_failed',reason=str(exc));stop.set()
        finally:
            row['elapsed_seconds']=time.monotonic()-began
            with guard: active.discard(item['id'])
        save(folder/'result.json',row)
        return row

    try:
        with ThreadPoolExecutor(max_workers=workers) as pool:
            futures = {}
            while True:
                if (output/'STOP_REQUESTED').exists():
                    stop_reason='operator_stop_requested';stop.set()
                if time.monotonic()-started >= manifest['total_seconds']:
                    stop_reason='total_budget_exhausted';stop.set()
                while not stop.is_set() and len(futures)<workers and next_index<phase_limit:
                    item=items[next_index];next_index+=1
                    if phase_started is None:phase_started=time.monotonic()
                    dispatched.add(item['id']);futures[pool.submit(perform,item)]=item
                progress()
                if not futures:
                    if stop.is_set():break
                    if pilot and pilot_result is None and next_index==pilot_limit:
                        elapsed=time.monotonic()-phase_started
                        first=[completed[i['id']] for i in items[:pilot_limit]]
                        rate=pilot_limit/elapsed
                        speedup=rate*pilot['serial_seconds_per_candidate']
                        passed=(all(r['request_attempted'] and r['status'] in ('checked','invalid') for r in first)
                                and speedup>=pilot['minimum_observed_speedup'])
                        pilot_result={'status':'passed' if passed else 'failed','candidate_count':pilot_limit,
                            'elapsed_seconds':elapsed,'candidates_per_minute':rate*60,
                            'serial_seconds_per_candidate':pilot['serial_seconds_per_candidate'],
                            'observed_speedup_unpaired':speedup,'peak_client_inflight':peak,
                            'status_counts':dict(Counter(r['status'] for r in first)),
                            'scope':'Engineering throughput against prior different candidates; not a paired speedup experiment or semantic quality gate'}
                        save(output/'pilot_report.json',pilot_result)
                        if not passed:
                            stop_reason='parallel_pilot_gate_failed';stop.set();break
                        phase_limit=len(items)
                        continue
                    if next_index==len(items):break
                    continue
                done,_=wait(futures,timeout=1,return_when=FIRST_COMPLETED)
                for future in sorted(done,key=lambda f:futures[f]['id']):
                    item=futures.pop(future);row=future.result();completed[item['id']]=row
                    with (output/'events.jsonl').open('a',encoding='utf-8') as stream:
                        stream.write(json.dumps({'finished_unix':time.time(),'row':row})+'\n')
                    if row['status']=='request_failed':stop_reason='stop_after_transport_failure';stop.set()
                    if row['status']=='not_requested' and row.get('reason')!='context_size_limit':
                        stop_reason=stop_reason or row.get('reason');stop.set()
    finally:
        for client in clients:client.close()
    rows=[completed.get(i['id'],{'id':i['id'],'kind':i['kind'],'request_attempted':False,
        'status':'not_requested','reason':stop_reason or 'dispatch_stopped'}) for i in items]
    if pilot and pilot_result is None:
        pilot_result={'status':'failed','reason':stop_reason,'registered_candidates':pilot_limit,
            'completed_candidates':len(completed),'peak_client_inflight':peak}
        save(output/'pilot_report.json',pilot_result)
    report={'status':'complete','execution_status':'stopped' if stop.is_set() else 'complete',
        'stop_reason':stop_reason,'candidate_count':len(rows),'requests_attempted':sum(r['request_attempted'] for r in rows),
        'elapsed_seconds':time.monotonic()-started,'rows':rows,'workers':workers,'peak_client_inflight':peak,
        'status_counts':dict(Counter(r['status'] for r in rows)),
        'decision_counts':dict(Counter(r['response']['decision'] for r in rows if r['status']=='checked')),
        'inputs_unchanged':all(digest(Path(p))==h for p,h in manifest['source_sha256'].items()),
        'implementation_unchanged':all(digest(Path(p))==h for p,h in manifest['implementation_sha256'].items()),
        'manifest_sha256':digest(output/'manifest.json'),'semantic_gold_labels':0,'pilot':pilot_result}
    save(output/'report.json',report)
    save(output/'groups.json',{'groups':[semantics.to_group(i,r) for i,r in zip(items,rows)]})
    atomic_save(output/'progress.json',{k:v for k,v in report.items() if k!='rows'})
    return report

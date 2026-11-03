"""Explicit, separately frozen continuation; never changes the interrupted run."""
import argparse
from collections import Counter
import copy
import http.client
import json
import math
import os
from pathlib import Path
import shutil
import traceback
from urllib.parse import urlsplit

from rcnc import model_semantics
from rcnc.domain_building import digest, save, snapshot_implementation
from scripts.experiments import run_revised_multistory as base


class LocalConnection:
    """One direct local HTTP connection, bounded calls, and no implicit retries."""
    def __init__(self):
        self.connection = None

    def close(self):
        if self.connection is not None:
            self.connection.close()
            self.connection = None

    def __call__(self, url, payload=None, timeout=15):
        address = urlsplit(url)
        if (address.scheme, address.hostname, address.port) != ('http', '127.0.0.1', 11434):
            raise ValueError('Only the registered local Ollama endpoint is allowed')
        if address.username or address.password or address.query or address.fragment:
            raise ValueError('Unexpected endpoint components')
        if address.path not in ('/api/chat', '/api/tags', '/api/version', '/api/ps'):
            raise ValueError('Unregistered local endpoint')
        if self.connection is None:
            self.connection = http.client.HTTPConnection('127.0.0.1', 11434, timeout=timeout)
        self.connection.timeout = timeout
        if self.connection.sock is not None:
            self.connection.sock.settimeout(timeout)
        body = None if payload is None else json.dumps(payload).encode('utf-8')
        try:
            self.connection.request('GET' if payload is None else 'POST', address.path,
                                    body=body, headers={'Content-Type': 'application/json'})
            response = self.connection.getresponse()
            content = response.read()
            if response.status != 200:
                raise OSError(f'Ollama HTTP {response.status}: {content[:300]!r}')
            return json.loads(content)
        except Exception:
            self.close()
            raise


def pending_items(items, old_rows):
    ids = [i['id'] for i in items]
    if len(set(ids)) != len(ids) or ids != [r['id'] for r in old_rows]:
        raise ValueError('Parent rows must exactly match the frozen candidate order')
    pending = []
    for item, row in zip(items, old_rows):
        if row['kind'] != item['kind']:
            raise ValueError('Changed candidate kind')
        if row['status'] == 'not_requested':
            if row.get('request_attempted') or row.get('reason') != 'stop_after_transport_failure':
                raise ValueError('Only never-sent transport-stop rows are eligible')
            pending.append(item)
        elif row['status'] not in ('checked', 'invalid', 'request_failed') or not row.get('request_attempted'):
            raise ValueError('Unrecognized historical outcome')
    return pending


def combine_rows(items, old_rows, new_rows):
    pending = pending_items(items, old_rows)
    if [r['id'] for r in new_rows] != [i['id'] for i in pending]:
        raise ValueError('Continuation rows must exactly cover the registered pending candidates')
    replacements = {r['id']: r for r in new_rows}
    if any(r['kind'] != i['kind'] for i, r in zip(pending, new_rows)):
        raise ValueError('Changed continuation candidate kind')
    return [copy.deepcopy(replacements.get(r['id'], r)) for r in old_rows]


def prepare(parent, output):
    if output.exists():
        raise ValueError('A fresh continuation directory is required')
    original = base.verify(parent)
    stopped = base.read(parent / 'coordinator.json')
    if stopped['status'] != 'stopped_model_stage_incomplete' or stopped['current_repeat'] != 'repeat_01':
        raise ValueError('Expected the registered first-repeat model interruption')
    if stopped['repeat_results']:
        raise ValueError('This continuation expects no completed planning repeats')
    old = base.read(parent / 'repeat_01/judgments/report.json')
    if not old['inputs_unchanged'] or not old['implementation_unchanged']:
        raise ValueError('Parent dependencies changed during execution')
    items = base.read(parent / 'repeat_01/judgments/packet.json')['items']
    pending = pending_items(items, old['rows'])
    requests = base.read(parent / 'repeat_01/judgments/requests.json')
    remaining_budget = original['budgets']['model_seconds_per_repeat'] - math.ceil(old['elapsed_seconds'])
    if not pending or remaining_budget <= 0:
        raise ValueError('No registered continuation work or active-time budget remains')
    # Snapshot all parent artifacts, including failures and every raw response.
    inherited = {str(p): digest(p) for p in sorted(parent.rglob('*')) if p.is_file()}
    output.mkdir(parents=True)
    shutil.copy2(parent / 'selected_groups.json', output / 'selected_groups.json')
    shutil.copytree(parent / 'runtime', output / 'runtime')
    repeats = []
    for item in original['repeats']:
        repeat = output / item['id']
        repeat.mkdir()
        if item['id'] == 'repeat_01':
            aggregate = repeat / 'judgments'; aggregate.mkdir()
            for name in ('packet.json', 'requests.json'):
                shutil.copy2(parent / item['id'] / 'judgments' / name, aggregate / name)
            suffix = repeat / 'remaining_judgments'; suffix.mkdir()
            save(suffix / 'packet.json', {'items': pending})
            save(suffix / 'requests.json', {i['id']: requests[i['id']] for i in pending})
            manifest = base.read(parent / item['id'] / 'judgments/manifest.json')
            manifest.update(created_utc=base.now(), candidate_count=len(pending), total_seconds=remaining_budget,
                packet_sha256=digest(suffix / 'packet.json'), requests_sha256=digest(suffix / 'requests.json'),
                scope='Explicit continuation: only previously unrequested candidates; no retry of invalid or failed rows',
                parent_report=str(parent / item['id'] / 'judgments/report.json'),
                parent_report_sha256=digest(parent / item['id'] / 'judgments/report.json'))
            save(suffix / 'manifest.json', manifest)
            save(aggregate / 'manifest.json', {'status': 'frozen_aggregate_before_continuation_calls',
                'condition': 'interrupted_cache_continuation', 'parent_report': manifest['parent_report'],
                'parent_report_sha256': manifest['parent_report_sha256'], 'new_stage': str(suffix),
                'retained_rows': len(items)-len(pending), 'new_request_limit': len(pending),
                'original_request_bodies_sha256': digest(aggregate / 'requests.json'),
                'historical_invalid_and_failed_rows_retained': True})
            model_stage = suffix
            label = 'interrupted_cache_continuation'
        else:
            source = parent / item['id'] / 'judgments'
            if (source / 'progress.json').exists() or (source / 'report.json').exists():
                raise ValueError('Later repeats must still be unexecuted')
            model_stage = repeat / 'judgments'
            shutil.copytree(source, model_stage)
            label = 'fresh_model_calls_persistent_local_transport'
        repeats.append({**item, 'path': str(repeat), 'model_stage': str(model_stage), 'condition': label,
            'new_request_limit': len(pending) if item['id'] == 'repeat_01' else item['candidate_count'],
            'manifest_sha256': digest(model_stage / 'manifest.json')})
    protocol = copy.deepcopy(original)
    protocol.update(status='frozen_explicit_continuation', created_utc=base.now(), parent=str(parent),
        parent_protocol_sha256=digest(parent / 'protocol.json'), repeats=repeats,
        runtime_jar=str(output / 'runtime/glaive-corrected.jar'), runtime_classes=str(output / 'runtime/classes'),
        condition='interrupted_cache_continuation_then_four_fresh_model_repeats',
        transport='direct persistent local HTTP connection; no automatic retries; identical frozen payloads',
        new_model_request_limit=sum(r['new_request_limit'] for r in repeats),
        original_requests_already_attempted=old['requests_attempted'],
        repeat_01_remaining_active_model_seconds=remaining_budget)
    protocol['policy'][0] = ('Repeat 1 is explicitly a cache continuation, not an uninterrupted fresh repeat. '
        'Retain all historical checked/invalid/request_failed rows. Only never-sent rows receive new requests. '
        'Repeats 2-5 use fresh calls. No retry, majority vote, best-run selection, or repaired answers.')
    protocol['policy'].append('Active model budget for repeat 1 is the original budget minus the ceiling of prior active elapsed time; the wall-clock interruption is explicitly recorded.')
    protocol['policy'].append('Stop before compilation after any NEW transport failure or NEW unexpected unrequested row. The historical failed candidate remains unavailable and does not dispatch another request.')
    added = snapshot_implementation(output, [Path(__file__), Path('tests/test_revised_multistory_continuation.py')])
    protocol['implementation_sha256'].update(added)
    protocol['input_sha256'].update(inherited)
    protocol['input_sha256'].update({str(p): digest(p) for p in output.rglob('*') if p.is_file()})
    save(output / 'protocol.json', protocol)
    (output / 'PROTOCOL.sha256').write_text(digest(output / 'protocol.json')+'  protocol.json\n', encoding='utf-8')
    return {'status': protocol['status'], 'retained_rows': len(items)-len(pending),
        'new_requests_repeat_01': len(pending), 'new_requests_total': protocol['new_model_request_limit'],
        'total_attempt_limit_including_parent': old['requests_attempted']+protocol['new_model_request_limit'],
        'remaining_active_seconds_repeat_01': remaining_budget, 'protocol_sha256': digest(output/'protocol.json')}


def reassemble(root, repeat, suffix):
    protocol = base.verify(root)
    aggregate = repeat / 'judgments'
    if (aggregate / 'report.json').exists():
        raise ValueError('Aggregate already assembled')
    parent = Path(protocol['parent']) / 'repeat_01/judgments'
    old = base.read(parent / 'report.json')
    items = base.read(aggregate / 'packet.json')['items']
    rows = combine_rows(items, old['rows'], suffix['rows'])
    report = {'status': 'complete', 'condition': 'interrupted_cache_continuation', 'candidate_count': len(rows),
        'requests_attempted': old['requests_attempted']+suffix['requests_attempted'],
        'requests_attempted_new': suffix['requests_attempted'], 'requests_attempted_parent': old['requests_attempted'],
        'elapsed_seconds': old['elapsed_seconds']+suffix['elapsed_seconds'], 'wall_clock_interruption_excluded': True,
        'rows': rows, 'status_counts': dict(Counter(r['status'] for r in rows)),
        'decision_counts': dict(Counter(r['response']['decision'] for r in rows if r['status']=='checked')),
        'inputs_unchanged': old['inputs_unchanged'] and suffix['inputs_unchanged'],
        'implementation_unchanged': old['implementation_unchanged'] and suffix['implementation_unchanged'],
        'semantic_gold_labels': 0, 'parent_report_sha256': digest(parent/'report.json'),
        'new_report_sha256': digest(repeat/'remaining_judgments/report.json')}
    save(aggregate / 'report.json', report)
    save(aggregate / 'groups.json', {'groups': [model_semantics.to_group(i,r) for i,r in zip(items,rows)]})
    continued = {r['id'] for r in suffix['rows']}
    save(aggregate / 'row_provenance.json', {'rows': [{'id': r['id'],
        'origin': 'new' if r['id'] in continued else 'parent',
        'raw_path': str((repeat/'remaining_judgments' if r['id'] in continued else parent)/'responses'/r['id']/'raw.json')
            if r['status'] in ('checked','invalid') else None} for r in rows]})
    return report


def pipeline(root):
    protocol = base.verify(root)
    path = root / 'coordinator.json'
    if path.exists():
        raise ValueError('This continuation coordinator has already started')
    state = {'status': 'running', 'condition': protocol['condition'], 'started_utc': base.now(),
        'pid': os.getpid(), 'protocol_sha256': digest(root/'protocol.json'), 'stage': 'startup',
        'current_repeat': None, 'repeat_results': []}
    save(path, state)
    client = LocalConnection()
    try:
        identity = {'version': client('http://127.0.0.1:11434/api/version'),
            'models': [m for m in client('http://127.0.0.1:11434/api/tags')['models'] if m['name']==protocol['model']]}
        save(root/'service_identity.json', identity)
        for item in protocol['repeats']:
            base.verify(root)
            repeat = Path(item['path'])
            state.update(current_repeat=item['id'], repeat_condition=item['condition'], stage='judgments',
                model_stage=item['model_stage'], completed_native=0, completed_source_query_slots=0)
            save(path, state)
            print('Starting', item['id'], item['condition'], 'new requests', item['new_request_limit'], flush=True)
            judgments = model_semantics.run(Path(item['model_stage']), transport=client)
            client.close()
            unrequested = [r for r in judgments['rows'] if r['status']=='not_requested' and r.get('reason')!='context_size_limit']
            if judgments['status_counts'].get('request_failed',0) or unrequested:
                state.update(status='stopped_model_stage_incomplete', reason=judgments['status_counts'])
                break
            if item['id']=='repeat_01':
                reassemble(root, repeat, judgments)
            state['stage']='compilation';save(path,state)
            base.compile_models(root,repeat)
            state['stage']='execution';save(path,state)
            summary=base.execute(root,repeat,state,path)
            state['repeat_results'].append({'id':item['id'],'condition':item['condition'],
                'new_model_requests':judgments['requests_attempted'],**summary})
            save(path,state)
            if summary['gate_violations'] or summary['invalid_returned_plans']:
                state.update(status='stopped_validation_gate');break
        else:
            state.update(status='complete',stage='complete')
        save(root/'report.json',{'status':state['status'],'condition':protocol['condition'],
            'completed_repeats':len(state['repeat_results']),'registered_repeats':len(protocol['repeats']),
            'repeat_results':state['repeat_results'],'independent_semantic_labels':0})
    except Exception as exc:
        state.update(status='failed',error=str(exc),traceback=traceback.format_exc())
        raise
    finally:
        client.close();state['ended_utc']=base.now();save(path,state)
    return state


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode',choices=['prepare','verify','pipeline'])
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--parent',type=Path)
    args=parser.parse_args()
    if args.mode=='prepare':result=prepare(args.parent,args.output)
    elif args.mode=='verify':p=base.verify(args.output);result={'status':'verified','condition':p['condition'],'new_model_request_limit':p['new_model_request_limit']}
    else:result=pipeline(args.output)
    print(json.dumps(result,indent=2))

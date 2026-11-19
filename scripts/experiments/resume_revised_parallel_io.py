"""Recover every persisted parallel result into an explicit metadata-I/O repair run."""
import argparse
from collections import Counter
import copy
from datetime import datetime
import json
import math
from pathlib import Path
import shutil

from rcnc import model_semantics
from rcnc.domain_building import digest,save,snapshot_implementation
from rcnc.parallel_progress_io import run_campaign
from scripts.experiments import run_revised_multistory as base
from scripts.experiments.continue_revised_multistory import combine_rows,pending_items


def recover_results(stage):
    items=base.read(stage/'packet.json')['items'];requests=base.read(stage/'requests.json')
    folders={p.name:p for p in (stage/'responses').iterdir() if p.is_dir()}
    if not set(folders)<={i['id'] for i in items}:raise ValueError('Unregistered result directory')
    rows=[]
    for item in items:
        if item['id'] not in folders:
            rows.append({'id':item['id'],'kind':item['kind'],'request_attempted':False,
                'status':'not_requested','reason':'stop_after_transport_failure'})
            continue
        folder=folders[item['id']]
        attempt=base.read(folder/'attempt.json')
        if attempt['id']!=item['id'] or attempt['request']!=requests[item['id']]:
            raise ValueError('Persisted attempted request differs from registration')
        # Require the worker's complete result. Ambiguous records need separate
        # diagnosis, never an automatic model retry or invented successful row.
        row=base.read(folder/'result.json')
        if row['id']!=item['id'] or row['kind']!=item['kind'] or not row['request_attempted']:
            raise ValueError('Persisted result identity changed')
        if row['status'] not in ('checked','invalid','request_failed'):
            raise ValueError('Unexpected persisted outcome')
        if row['status']=='checked':model_semantics.validate(item,row['response'])
        if row['status'] in ('checked','invalid'):base.read(folder/'raw.json')
        rows.append(row)
    return rows


def prepare(parent,output):
    if output.exists():raise ValueError('Fresh I/O repair directory required')
    previous=base.verify(parent);state=base.read(parent/'coordinator.json')
    if (state['status']!='failed' or state['stage']!='judgments' or state['current_repeat']!='repeat_01'
            or 'PermissionError' not in state.get('traceback','') or 'progress.json' not in state.get('error','')):
        raise ValueError('Expected the recorded progress-file failure')
    old_stage=parent/'repeat_01/remaining_judgments'
    prior=base.read(parent/'inherited_report.json')
    items=base.read(parent/'repeat_01/judgments/packet.json')['items']
    requests=base.read(parent/'repeat_01/judgments/requests.json')
    recovered=recover_results(old_stage)
    inherited=combine_rows(items,prior['rows'],recovered)
    pending=pending_items(items,inherited)
    newly_recovered=sum(r['request_attempted'] for r in recovered)
    attempted=prior['requests_attempted']+newly_recovered
    stage_seconds=(datetime.fromisoformat(state['ended_utc'])-datetime.fromisoformat(state['started_utc'])).total_seconds()
    elapsed=prior['elapsed_seconds']+stage_seconds
    remaining_budget=previous['budgets']['model_seconds_per_repeat']-math.ceil(elapsed)
    if not pending or remaining_budget<=0:raise ValueError('No pending work or active budget')
    output.mkdir(parents=True)
    save(output/'inherited_report.json',{'status':'historical_rows_with_pending_suffix','rows':inherited,
        'requests_attempted':attempted,'requests_attempted_before_failed_parallel_stage':prior['requests_attempted'],
        'requests_recovered_from_per_candidate_results':newly_recovered,'elapsed_seconds':elapsed,
        'status_counts':dict(Counter(r['status'] for r in inherited)),
        'condition':'explicit_parallel_continuation_after_progress_file_failure'})
    provenance=base.read(parent/'historical_row_provenance.json')['rows']
    provenance += [{'id':r['id'],'raw_path':str(old_stage/'responses'/r['id']/'raw.json')
                    if r['status'] in ('checked','invalid') else None} for r in recovered if r['request_attempted']]
    if len({r['id'] for r in provenance})!=attempted:raise ValueError('Duplicate/missing historical attempt')
    save(output/'historical_row_provenance.json',{'rows':provenance})
    shutil.copy2(parent/'selected_groups.json',output/'selected_groups.json')
    shutil.copytree(parent/'runtime',output/'runtime')
    added=snapshot_implementation(output,[Path(__file__),Path('rcnc/parallel_progress_io.py'),
                                          Path('tests/test_parallel_progress_io.py')])
    repeats=[]
    for registered in previous['repeats']:
        repeat=output/registered['id'];repeat.mkdir()
        old=Path(registered['model_stage'])
        if registered['id']=='repeat_01':
            aggregate=repeat/'judgments';aggregate.mkdir()
            for name in ('packet.json','requests.json'):shutil.copy2(parent/'repeat_01/judgments'/name,aggregate/name)
            save(aggregate/'manifest.json',{'status':'frozen_aggregate_before_recovery_calls',
                'condition':'explicit_parallel_continuation_after_progress_file_failure',
                'inherited_report_sha256':digest(output/'inherited_report.json'),
                'retained_attempts':attempted,'new_request_limit':len(pending)})
            target=repeat/'remaining_judgments';target.mkdir()
            save(target/'packet.json',{'items':pending});save(target/'requests.json',{i['id']:requests[i['id']] for i in pending})
            manifest=base.read(old/'manifest.json');manifest.pop('parallel_pilot',None)
            manifest.update(candidate_count=len(pending),total_seconds=remaining_budget,
                packet_sha256=digest(target/'packet.json'),requests_sha256=digest(target/'requests.json'))
            limit=len(pending);label='serial_and_parallel_interrupted_continuation_with_io_repair'
        else:
            if (old/'progress.json').exists():raise ValueError('Later repeat already executed')
            target=repeat/'judgments';shutil.copytree(old,target);manifest=base.read(target/'manifest.json')
            limit=registered['new_request_limit'];label='fresh_model_calls_ten_clients_robust_progress'
        manifest.update(created_utc=base.now(),scope='Same registered payloads and ten clients; local metadata replacement retries only; no model retries')
        manifest['implementation_sha256'].update(added);save(target/'manifest.json',manifest)
        repeats.append({**registered,'path':str(repeat),'model_stage':str(target),'condition':label,
            'new_request_limit':limit,'manifest_sha256':digest(target/'manifest.json')})
    protocol=copy.deepcopy(previous);new_limit=sum(r['new_request_limit'] for r in repeats)
    if new_limit+attempted!=23400:raise ValueError('Attempt limit changed')
    protocol.update(status='frozen_before_progress_io_recovery',created_utc=base.now(),
        condition='ten_client_continuation_after_progress_io_failure',io_failure_parent=str(parent),
        repeats=repeats,prior_requests_attempted=attempted,new_model_request_limit=new_limit,
        first_repeat_remaining_active_seconds=remaining_budget,not_before_unix=0,
        runtime_jar=str(output/'runtime/glaive-corrected.jar'),runtime_classes=str(output/'runtime/classes'),
        prior_pilot_report=str(old_stage/'pilot_report.json'),prior_pilot_sha256=digest(old_stage/'pilot_report.json'))
    protocol['policy'].append('The already-passed 60-candidate throughput pilot is retained and not repeated. '
        'Recover all per-candidate result files, including outcomes missing from the failed summary update. '
        'Only never-attempted candidates receive new model requests.')
    protocol['policy'].append('Metadata-only I/O adapter retries PermissionError on progress replacement for at most 0.74 seconds; '
        'if still locked, writes a new immutable progress.checkpoint.<timestamp>.json. No model/network retries are introduced. '
        'Use the newest progress snapshot when the main progress filename is locked.')
    protocol['implementation_sha256'].update(added)
    protocol['input_sha256'].update({str(p):digest(p) for p in parent.rglob('*') if p.is_file()})
    protocol['input_sha256'].update({str(p):digest(p) for p in output.rglob('*') if p.is_file()})
    save(output/'protocol.json',protocol)
    (output/'PROTOCOL.sha256').write_text(digest(output/'protocol.json')+'  protocol.json\n',encoding='utf-8')
    return {'status':protocol['status'],'recovered_worker_results':newly_recovered,'retained_attempts':attempted,
        'remaining_first_repeat':len(pending),'new_requests_total':new_limit,'total_attempt_limit':23400,
        'protocol_sha256':digest(output/'protocol.json')}


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('mode',choices=['prepare','verify','pipeline'])
    p.add_argument('--output',type=Path,required=True);p.add_argument('--parent',type=Path);a=p.parse_args()
    if a.mode=='prepare':result=prepare(a.parent,a.output)
    elif a.mode=='verify':x=base.verify(a.output);result={'status':'verified','workers':10,'new_request_limit':x['new_model_request_limit']}
    else:result=run_campaign(a.output)
    print(json.dumps(result,indent=2))

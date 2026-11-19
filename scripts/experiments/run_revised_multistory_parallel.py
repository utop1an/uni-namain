"""Ten-client concurrency trial and continuation of the frozen k=2/3/4 study."""
import argparse
from collections import Counter
import copy
from datetime import datetime
import json
import math
import os
from pathlib import Path
import shutil
import time
import traceback

from rcnc import model_semantics
from rcnc import model_semantics_parallel as parallel
from rcnc.domain_building import digest,save,snapshot_implementation
from scripts.experiments import run_revised_multistory as base
from scripts.experiments.continue_revised_multistory import LocalConnection,combine_rows,pending_items


def recover_partial(stage):
    """Recover persisted rows; an ambiguous dispatched request is never retried."""
    manifest=base.read(stage/'manifest.json');items=base.read(stage/'packet.json')['items']
    progress=base.read(stage/'progress.json')['rows']
    if [r['id'] for r in progress]!=[i['id'] for i in items[:len(progress)]]:
        raise ValueError('Serial progress is not a prefix of the frozen packet')
    by_id={r['id']:copy.deepcopy(r) for r in progress}
    folders={p.name:p for p in (stage/'responses').iterdir() if p.is_dir()}
    if not set(folders)<={i['id'] for i in items}:
        raise ValueError('Unregistered response directory')
    rows=[];recovered=[];unknown=[]
    for item in items:
        if item['id'] in by_id:
            row=by_id[item['id']]
            if row['kind']!=item['kind'] or not row.get('request_attempted'):
                raise ValueError('Unexpected serial row')
            if row['status']=='checked':model_semantics.validate(item,row['response'])
        elif item['id'] in folders:
            row={'id':item['id'],'kind':item['kind'],'request_attempted':True,
                'recovered_after_administrative_stop':True}
            raw=folders[item['id']]/'raw.json'
            try:
                payload=base.read(raw)
            except (OSError,ValueError):
                row.update(status='request_failed',reason='administrative_handoff_inflight_result_unknown_no_retry')
                unknown.append(item['id'])
            else:
                try:parallel.decode_payload(item,payload,manifest.get('schema_policy'),row)
                except (ValueError,KeyError,TypeError) as exc:row.update(status='invalid',reason=str(exc))
                recovered.append(item['id'])
        else:
            row={'id':item['id'],'kind':item['kind'],'request_attempted':False,
                'status':'not_requested','reason':'stop_after_transport_failure'}
        rows.append(row)
    return rows,{'persisted_rows':len(progress),'recovered_raw_rows':recovered,'interrupted_unknown_ids':unknown}


def prepare(parent,handoff,output):
    if output.exists():raise ValueError('Fresh parallel campaign directory required')
    previous=base.verify(parent)
    handoff_data=json.loads(handoff.read_text(encoding='utf-8-sig'))
    if handoff_data['status']!='handoff_stopped' or not handoff_data['stopped_verified_process']:
        raise ValueError('Verified serial-process stop required')
    if Path(handoff_data['source']).resolve()!=parent.resolve():raise ValueError('Wrong handoff parent')
    original=Path(previous['parent']);protocol=copy.deepcopy(base.verify(original))
    first=original/'repeat_01/judgments';original_report=base.read(first/'report.json')
    items=base.read(first/'packet.json')['items'];requests=base.read(first/'requests.json')
    stage=parent/'repeat_01/remaining_judgments';partial,recovery=recover_partial(stage)
    if [r['id'] for r in partial]!=[i['id'] for i in pending_items(items,original_report['rows'])]:
        raise ValueError('Continuation history does not cover original pending IDs')
    inherited=combine_rows(items,original_report['rows'],partial)
    pending=pending_items(items,inherited)
    if len(pending)<60:raise ValueError('At least 60 unseen candidates required')
    partial_attempts=sum(r['request_attempted'] for r in partial)
    attempted=original_report['requests_attempted']+partial_attempts
    state=base.read(parent/'coordinator.json')
    serial_seconds=(datetime.fromisoformat(handoff_data['stopped_utc'].replace('Z','+00:00'))-
                    datetime.fromisoformat(state['started_utc'])).total_seconds()
    elapsed=original_report['elapsed_seconds']+serial_seconds
    remaining_budget=protocol['budgets']['model_seconds_per_repeat']-math.ceil(elapsed)
    if remaining_budget<=0:raise ValueError('No active model budget remains')
    raw=sorted(stage.glob('responses/*/raw.json'),key=lambda p:p.stat().st_mtime)[-100:]
    if len(raw)<2:raise ValueError('No measured serial baseline')
    serial_rate=(raw[-1].stat().st_mtime-raw[0].stat().st_mtime)/(len(raw)-1)
    output.mkdir(parents=True)
    save(output/'inherited_report.json',{'status':'historical_rows_with_pending_suffix','rows':inherited,
        'requests_attempted':attempted,'requests_attempted_original':original_report['requests_attempted'],
        'requests_attempted_serial_continuation':partial_attempts,'elapsed_seconds':elapsed,
        'status_counts':dict(Counter(r['status'] for r in inherited)),
        'condition':'two_serial_segments_plus_parallel_continuation','recovery':recovery})
    save(output/'historical_row_provenance.json',{'rows':[{'id':r['id'],
        'raw_path':str((stage if r['id'] in {x['id'] for x in partial} else first)/'responses'/r['id']/'raw.json')
            if r['status'] in ('checked','invalid') else None} for r in inherited if r['request_attempted']]})
    shutil.copy2(original/'selected_groups.json',output/'selected_groups.json')
    shutil.copytree(original/'runtime',output/'runtime')
    code=[Path(__file__),Path('rcnc/model_semantics_parallel.py'),Path('scripts/experiments/continue_revised_multistory.py'),
          Path('tests/test_revised_multistory_parallel.py')]
    added=snapshot_implementation(output,code)
    repeats=[]
    for registered in protocol['repeats']:
        repeat=output/registered['id'];repeat.mkdir()
        old=original/registered['id']/'judgments'
        if registered['id']=='repeat_01':
            aggregate=repeat/'judgments';aggregate.mkdir()
            for name in ('packet.json','requests.json'):shutil.copy2(old/name,aggregate/name)
            save(aggregate/'manifest.json',{'status':'frozen_aggregate_before_parallel_calls',
                'condition':'serial_and_parallel_interrupted_continuation','inherited_report':str(output/'inherited_report.json'),
                'inherited_report_sha256':digest(output/'inherited_report.json'),'retained_attempted_rows':attempted,
                'new_request_limit':len(pending),'original_requests_sha256':digest(aggregate/'requests.json')})
            target=repeat/'remaining_judgments';target.mkdir()
            save(target/'packet.json',{'items':pending});save(target/'requests.json',{i['id']:requests[i['id']] for i in pending})
            manifest=base.read(old/'manifest.json');limit=len(pending)
            manifest.update(total_seconds=remaining_budget,candidate_count=limit,
                packet_sha256=digest(target/'packet.json'),requests_sha256=digest(target/'requests.json'),
                parallel_pilot={'candidate_count':60,'serial_seconds_per_candidate':serial_rate,
                    'serial_raw_sample_count':len(raw),'minimum_observed_speedup':1.5,
                    'gate':'No transport failures or undispatched trial candidates; at least 1.5x observed throughput. Invalid model outputs retained, not a semantic gate.'})
            label='serial_and_parallel_interrupted_continuation'
        else:
            if (old/'progress.json').exists():raise ValueError('Later original repeat already executed')
            target=repeat/'judgments';shutil.copytree(old,target)
            manifest=base.read(target/'manifest.json');limit=registered['candidate_count']
            label='fresh_model_calls_ten_client_concurrency'
        manifest.update(status='frozen_before_parallel_calls',created_utc=base.now(),workers=10,
            scope='Unchanged frozen request payloads; ten bounded clients; one attempt per candidate; no automatic retry',
            transport='One reusable direct local HTTP connection per worker')
        manifest['implementation_sha256'].update(added)
        save(target/'manifest.json',manifest)
        repeats.append({**registered,'path':str(repeat),'model_stage':str(target),'condition':label,
            'new_request_limit':limit,'manifest_sha256':digest(target/'manifest.json')})
    new_limit=sum(r['new_request_limit'] for r in repeats)
    if new_limit+attempted!=23400:raise ValueError('Total registered attempt count changed')
    protocol.update(status='frozen_before_ten_concurrency_trial',created_utc=base.now(),
        condition='ten_concurrency_trial_then_parallel_continuation',original_parent=str(original),serial_parent=str(parent),
        handoff_receipt=str(handoff),repeats=repeats,prior_requests_attempted=attempted,new_model_request_limit=new_limit,
        serial_baseline_seconds_per_candidate=serial_rate,serial_baseline_sample_count=len(raw),
        first_repeat_remaining_active_seconds=remaining_budget,
        not_before_unix=datetime.fromisoformat(handoff_data['stopped_utc'].replace('Z','+00:00')).timestamp()+240,
        runtime_jar=str(output/'runtime/glaive-corrected.jar'),runtime_classes=str(output/'runtime/classes'))
    protocol['budgets']['model_workers']=10
    protocol['policy'][0]=('Preserve all historical outcomes. Any administrative in-flight request with no complete response is '
        'retained as unknown, consumes its attempt, and is never retried. Repeat 1 is a separately labeled serial/parallel '
        'continuation; repeats 2-5 are fresh calls under the registered parallel execution condition.')
    protocol['policy'].extend(['The first 60 never-requested frozen candidates form an engineering throughput trial. '
        'After all 60 complete, proceed at ten clients only if the frozen throughput/resource gate passes. '
        'No filtering on compatible/different judgments or invalid-answer rate.',
        'One connection per worker; at most ten client requests in flight. On a new transport failure stop dispatch, '
        'wait for all in-flight requests, retain every result, then stop the campaign.',
        'Planner execution stays serial with original budgets. No change to model, prompts, seeds, candidates, or merge thresholds.',
        'STOP_REQUESTED in the active model-stage directory drains in-flight requests and checkpoints a distinct stopped condition.'])
    protocol['implementation_sha256'].update(added)
    for source in (parent,):
        protocol['input_sha256'].update({str(p):digest(p) for p in source.rglob('*') if p.is_file()})
    protocol['input_sha256'][str(handoff)]=digest(handoff)
    protocol['input_sha256'].update({str(p):digest(p) for p in output.rglob('*') if p.is_file()})
    save(output/'protocol.json',protocol)
    (output/'PROTOCOL.sha256').write_text(digest(output/'protocol.json')+'  protocol.json\n',encoding='utf-8')
    return {'status':protocol['status'],'retained_attempts':attempted,'new_first_repeat':len(pending),
        'new_requests_total':new_limit,'total_attempt_limit':23400,'recovery':recovery,
        'serial_seconds_per_candidate':serial_rate,'protocol_sha256':digest(output/'protocol.json')}


def aggregate_first(root,repeat,new):
    inherited=base.read(root/'inherited_report.json');aggregate=repeat/'judgments'
    if (aggregate/'report.json').exists():raise ValueError('Aggregate already exists')
    items=base.read(aggregate/'packet.json')['items'];rows=combine_rows(items,inherited['rows'],new['rows'])
    report={'status':'complete','condition':'serial_and_parallel_interrupted_continuation','rows':rows,
        'candidate_count':len(rows),'requests_attempted':inherited['requests_attempted']+new['requests_attempted'],
        'requests_attempted_new':new['requests_attempted'],'requests_attempted_historical':inherited['requests_attempted'],
        'elapsed_seconds':inherited['elapsed_seconds']+new['elapsed_seconds'],'wall_clock_interruption_excluded':True,
        'status_counts':dict(Counter(r['status'] for r in rows)),
        'decision_counts':dict(Counter(r['response']['decision'] for r in rows if r['status']=='checked')),
        'inputs_unchanged':new['inputs_unchanged'],'implementation_unchanged':new['implementation_unchanged'],
        'semantic_gold_labels':0,'inherited_report_sha256':digest(root/'inherited_report.json'),
        'new_report_sha256':digest(repeat/'remaining_judgments/report.json')}
    save(aggregate/'report.json',report)
    save(aggregate/'groups.json',{'groups':[model_semantics.to_group(i,r) for i,r in zip(items,rows)]})
    historical={r['id']:r for r in base.read(root/'historical_row_provenance.json')['rows']}
    save(aggregate/'row_provenance.json',{'rows':[historical.get(r['id'],{'id':r['id'],
        'raw_path':str(repeat/'remaining_judgments/responses'/r['id']/'raw.json') if r['status'] in ('checked','invalid') else None}) for r in rows]})


def pipeline(root):
    protocol=base.verify(root);path=root/'coordinator.json'
    if path.exists():raise ValueError('Fresh parallel coordinator required')
    state={'status':'running','condition':protocol['condition'],'started_utc':base.now(),'pid':os.getpid(),
        'stage':'startup','current_repeat':None,'repeat_results':[],'protocol_sha256':digest(root/'protocol.json')}
    save(path,state)
    try:
        if time.time()<protocol['not_before_unix']:
            state['stage']='waiting_for_prior_request_timeout_window';save(path,state)
            while time.time()<protocol['not_before_unix']:time.sleep(min(1,protocol['not_before_unix']-time.time()))
        client=LocalConnection()
        try:
            identity={'version':client('http://127.0.0.1:11434/api/version'),
                'models':[m for m in client('http://127.0.0.1:11434/api/tags')['models'] if m['name']==protocol['model']]}
            save(root/'service_identity.json',identity)
        finally:client.close()
        for item in protocol['repeats']:
            base.verify(root);repeat=Path(item['path'])
            state.update(current_repeat=item['id'],repeat_condition=item['condition'],stage='judgments',
                model_stage=item['model_stage'],model_workers=10,completed_native=0,completed_source_query_slots=0)
            save(path,state);print('Starting',item['id'],'ten clients',item['new_request_limit'],'new requests',flush=True)
            judgments=parallel.run(Path(item['model_stage']))
            if judgments['execution_status']!='complete':
                state.update(status='stopped_model_stage_incomplete',reason=judgments['stop_reason'],
                    model_status_counts=judgments['status_counts']);break
            if item['id']=='repeat_01':aggregate_first(root,repeat,judgments)
            state['stage']='compilation';save(path,state);base.compile_models(root,repeat)
            state['stage']='execution';save(path,state);summary=base.execute(root,repeat,state,path)
            state['repeat_results'].append({'id':item['id'],'condition':item['condition'],
                'new_model_requests':judgments['requests_attempted'],**summary});save(path,state)
            if summary['gate_violations'] or summary['invalid_returned_plans']:
                state.update(status='stopped_validation_gate');break
        else:state.update(status='complete',stage='complete')
        save(root/'report.json',{'status':state['status'],'condition':protocol['condition'],
            'completed_repeats':len(state['repeat_results']),'registered_repeats':len(protocol['repeats']),
            'repeat_results':state['repeat_results'],'independent_semantic_labels':0})
    except Exception as exc:
        state.update(status='failed',error=str(exc),traceback=traceback.format_exc());raise
    finally:state['ended_utc']=base.now();save(path,state)
    return state


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('mode',choices=['prepare','verify','pipeline'])
    p.add_argument('--output',type=Path,required=True);p.add_argument('--parent',type=Path);p.add_argument('--handoff',type=Path)
    args=p.parse_args()
    if args.mode=='prepare':result=prepare(args.parent,args.handoff,args.output)
    elif args.mode=='verify':x=base.verify(args.output);result={'status':'verified','workers':10,'new_request_limit':x['new_model_request_limit']}
    else:result=pipeline(args.output)
    print(json.dumps(result,indent=2))

"""Frozen interim audit, isolated from the ongoing five-repeat main campaign."""
import argparse
from collections import Counter
from datetime import datetime,timezone
from itertools import combinations
import json
import math
from pathlib import Path
import shutil
import time

from rcnc import model_semantics
from rcnc.model_semantics_parallel import decode_payload
from rcnc.domain_building import digest,save,snapshot_implementation
from rcnc.glaive_merge import build,map_problem,translate_plan
from rcnc.glaive_runtime import invoke
from rcnc.revised_multistory import select_groups
from rcnc.revised_sampling import rank
from scripts.experiments import run_revised_multistory as base


def group_coverage(groups,items,rows):
    terminal={r['id'] for r in rows if r['status'] in ('checked','invalid','request_failed')}
    by_pair={}
    for item in items:by_pair.setdefault(tuple(sorted(item['source_pair'])),set()).add(item['id'])
    result=[]
    for group in groups:
        required=set().union(*(by_pair.get(tuple(sorted(pair)),set()) for pair in combinations(group['sources'],2)))
        done=required&terminal
        result.append({'group':group['id'],'size':group['size'],'registered_candidates':len(required),
            'terminal_candidates':len(done),'pending_candidates':len(required-done),
            'all_registered_candidates_terminal':required<=terminal,'has_registered_candidates':bool(required)})
    return result


def audit_response(item,row,payload,policy):
    recomputed={'id':item['id'],'kind':item['kind'],'request_attempted':True}
    try:decode_payload(item,payload,policy,recomputed)
    except (ValueError,KeyError,TypeError) as exc:recomputed.update(status='invalid',reason=str(exc))
    match=recomputed['status']==row['status']
    if row['status']=='checked':match=match and recomputed.get('response')==row.get('response')
    if row['status']=='invalid':match=match and recomputed.get('reason')==row.get('reason')
    return {'id':item['id'],'status_match':match,'recorded_status':row['status'],
        'recomputed_status':recomputed['status'],'reason':recomputed.get('reason')}


def prepare(campaign,output):
    if output.exists():raise ValueError('Fresh audit directory required')
    main=base.verify(campaign)
    all_groups=base.read(campaign/'selected_groups.json')['groups']
    selected=[g for k in (2,3,4) for g in sorted((g for g in all_groups if g['size']==k),
        key=lambda g:rank('partial-audit-2026-11-02-v1',g['id']))[:3]]
    output.mkdir(parents=True)
    save(output/'selection_before_snapshot.json',{'created_utc':base.now(),
        'rule':'First three frozen group IDs per size ranked by partial-audit-2026-11-02-v1; independent of model outcomes and planning success',
        'groups':selected,'model_calls':0,'main_campaign':str(campaign)})
    cutoff=time.time();stage=campaign/'repeat_01/remaining_judgments'
    items=base.read(campaign/'repeat_01/judgments/packet.json')['items']
    requests=base.read(campaign/'repeat_01/judgments/requests.json')
    inherited=base.read(campaign/'inherited_report.json')
    rows={r['id']:r for r in inherited['rows']}
    provenance={r['id']:r['raw_path'] for r in base.read(campaign/'historical_row_provenance.json')['rows']}
    candidate_paths=sorted(p for p in stage.glob('responses/*/result.json') if p.stat().st_mtime<=cutoff)
    included=[];deferred=[]
    for path in candidate_paths:
        try:
            data=path.read_bytes();row=json.loads(data)
            if path.read_bytes()!=data:raise ValueError('Result still changing')
            if row['status'] in ('checked','invalid'):base.read(path.parent/'raw.json')
            attempt=base.read(path.parent/'attempt.json')
        except (OSError,ValueError):
            deferred.append(path.parent.name);continue
        if row['id'] not in rows or rows[row['id']]['request_attempted']:
            raise ValueError('Duplicate or unregistered result')
        if attempt['request']!=requests[row['id']]:raise ValueError('Changed request body')
        rows[row['id']]=row;provenance[row['id']]=str(path.parent/'raw.json');included.append(row['id'])
    snapshot=[];raw_sources={}
    (output/'raw').mkdir()
    for item in items:
        row=rows[item['id']]
        if row['status']=='not_requested':row={**row,'reason':'pending_or_inflight_at_interim_cutoff'}
        snapshot.append(row)
        if row['status'] in ('checked','invalid'):
            source=Path(provenance[item['id']]);data=source.read_bytes();json.loads(data)
            (output/'raw'/(item['id']+'.json')).write_bytes(data)
            raw_sources[item['id']]={'path':str(source),'sha256':digest(output/'raw'/(item['id']+'.json'))}
    shutil.copy2(campaign/'repeat_01/judgments/packet.json',output/'packet.json')
    shutil.copy2(campaign/'repeat_01/judgments/requests.json',output/'requests.json')
    shutil.copy2(campaign/'protocol.json',output/'main_protocol.json')
    shutil.copytree(campaign/'runtime',output/'runtime')
    save(output/'snapshot.json',{'cutoff_utc':datetime.fromtimestamp(cutoff,timezone.utc).isoformat(),
        'rows':snapshot,'candidate_count':len(snapshot),'included_current_stage_results':len(included),
        'deferred_partial_writes':deferred,'raw_provenance':raw_sources,'main_run_untouched':True})
    save(output/'coverage.json',{'groups':group_coverage(all_groups,items,snapshot)})
    code=[Path(__file__),Path('rcnc/model_semantics_parallel.py'),Path('tests/test_partial_revised_audit.py'),*base.IMPLEMENTATION]
    code=list({str(p.resolve()):p for p in code}.values())
    implementation=snapshot_implementation(output,code)
    inputs={str(p):digest(p) for p in output.rglob('*') if p.is_file()}
    # Original sources and all model-building dependencies are already frozen by
    # the main protocol. Mutable live progress files are intentionally excluded.
    inputs.update(main['input_sha256'])
    protocol={'status':'frozen_interim_snapshot_before_diagnostic_search','created_utc':base.now(),
        'main_campaign':str(campaign),'main_protocol_sha256':digest(campaign/'protocol.json'),
        'cutoff_utc':datetime.fromtimestamp(cutoff,timezone.utc).isoformat(),'selected_groups':selected,
        'source_rows':main['source_rows'],'source_inputs':str(Path(main['original_parent'])/'inputs'),
        'schema_policy':'compact_kind_specific','threshold':.9,'runtime_jar':str(output/'runtime/glaive-corrected.jar'),
        'runtime_classes':str(output/'runtime/classes'),'input_sha256':inputs,
        'implementation_sha256':{**main['implementation_sha256'],**implementation},
        'budgets':{'model_calls':0,'groups':9,'models':27,'native_search_limit':len({s for g in selected for s in g['sources']}),
            'merged_search_limit':54,'transport_slots':81,'per_search_seconds':15,'per_replay_seconds':15,
            'execution_wall_seconds':900,'planner_workers':1,'planner_memory_mb':4096},
        'policy':['Interim diagnostic only; not a completed main repeat or five-repeat estimate.',
            'All 4680 candidate rows, including invalid, failed, and pending, remain in the denominator.',
            'Pending/invalid/failed candidates never authorize a shared symbol. Provisional models can change when pending answers arrive.',
            'Compile and hash all 27 diagnostic domains and original-world mappings before diagnostic search.',
            'No new LLM calls, prompt edits, retries, threshold changes, or feedback into the running main campaign.',
            'Native original-world search; two preregistered anchors per group for merged search; native plan transport for every source.',
            'Replay checks are mechanical evidence, not independent semantic labels or narrative quality ratings.']}
    save(output/'protocol.json',protocol)
    (output/'PROTOCOL.sha256').write_text(digest(output/'protocol.json')+'  protocol.json\n',encoding='utf-8')
    return {'status':protocol['status'],'cutoff_utc':protocol['cutoff_utc'],
        'counts':dict(Counter(r['status'] for r in snapshot)),'diagnostic_budgets':protocol['budgets']}


def validate_and_compile(root):
    p=base.verify(root)
    if (root/'compilation.json').exists():raise ValueError('Fresh audit compilation required')
    items=base.read(root/'packet.json')['items'];rows=base.read(root/'snapshot.json')['rows']
    cache={};source_mismatches=[];results=[]
    for item,row in zip(items,rows):
        for side in item['sides']:
            key=(item['kind'],side['reference'])
            if key not in cache:
                cache[key]=json.loads(json.dumps(model_semantics.context(Path(p['source_inputs']),side['reference'],item['kind'])))
            if cache[key]!=side:source_mismatches.append({'candidate':item['id'],'reference':side['reference']})
        if row['status'] in ('checked','invalid'):
            results.append(audit_response(item,row,base.read(root/'raw'/(item['id']+'.json')),p['schema_policy']))
    report={'status':'passed' if not source_mismatches and all(r['status_match'] for r in results) else 'failed',
        'candidate_count':len(rows),'raw_responses_rechecked':len(results),'row_mismatches':[r for r in results if not r['status_match']],
        'source_packet_mismatches':source_mismatches,'unique_source_symbols_checked':len(cache),
        'status_counts':dict(Counter(r['status'] for r in rows)),
        'by_kind':{k:{'status':dict(Counter(r['status'] for i,r in zip(items,rows) if i['kind']==k)),
            'decision':dict(Counter(r['response']['decision'] for i,r in zip(items,rows) if i['kind']==k and r['status']=='checked'))} for k in ('predicate','action')},
        'invalid_reasons':dict(Counter(r.get('reason','') for r in rows if r['status']=='invalid')),
        'independent_semantic_labels':0,'scope':'Exact raw-response recomputation and frozen-source provenance checks'}
    save(root/'response_audit.json',report)
    if report['status']!='passed':raise ValueError('Snapshot audit mismatch; diagnostic planning blocked')
    raw_groups=[model_semantics.to_group(i,r) for i,r in zip(items,rows)]
    save(root/'judgment_groups.json',{'groups':raw_groups})
    sources=base.load_sources(p);models=[];tasks=[];audits=[];compiled_hashes={}
    coverage={g['group']:g for g in base.read(root/'coverage.json')['groups']}
    for group in p['selected_groups']:
        selected=[sources[s] for s in group['sources']]
        predicates,pa=select_groups(selected,raw_groups,'predicate',threshold=p['threshold'])
        union_folder=root/'models'/group['id']/'union';pred_folder=root/'models'/group['id']/'predicate_only';full_folder=root/'models'/group['id']/'full'
        union=build(selected,union_folder);pred=build(selected,pred_folder,groups=predicates)
        actions,aa=select_groups(selected,raw_groups,'action',threshold=p['threshold'],predicate_maps=pred['predicate_maps'])
        full=build(selected,full_folder,groups=predicates+actions,merge_actions=True)
        if pred['predicate_maps']!=full['predicate_maps']:raise ValueError('Predicate mappings differ across ablations')
        audits.append({'group':group['id'],'coverage':coverage[group['id']],'predicate':pa,'action':aa,'groups':predicates+actions})
        for condition,meta,folder in [('union',union,union_folder),('predicate_only',pred,pred_folder),('full',full,full_folder)]:
            models.append({'group':group['id'],'size':group['size'],'condition':condition,**meta})
            for source in selected:
                problem=folder/(source.id+'.pddl');map_problem(selected,source.id,meta,problem)
                tasks.append({'id':group['id']+'__'+condition+'__'+source.id,'group':group['id'],'size':group['size'],
                    'condition':condition,'source':source.id,'search_anchor':source.id in group['anchor_sources'],
                    'domain':str(folder/'domain.pddl'),'problem':str(problem),'mapping':str(folder/'mapping.json')})
            compiled_hashes.update({str(f):digest(f) for f in folder.iterdir() if f.is_file()})
    save(root/'consensus_audit.json',{'rows':audits})
    save(root/'compilation.json',{'status':'compiled_before_diagnostic_search','models':models,'tasks':tasks,
        'model_count':len(models),'source_query_slots':len(tasks),'anchor_search_slots':sum(t['search_anchor'] for t in tasks),
        'input_sha256':compiled_hashes})
    return {'response_audit':report['status'],'raw_responses':len(results),'models':len(models),'source_slots':len(tasks)}


def execute(root):
    p=base.verify(root);comp=base.read(root/'compilation.json')
    if (root/'execution_progress.json').exists():raise ValueError('Fresh diagnostic execution required')
    for path,h in comp['input_sha256'].items():
        if digest(Path(path))!=h:raise ValueError('Compiled input changed')
    sources=base.load_sources(p);source_ids=sorted({t['source'] for t in comp['tasks']})
    jar=Path(p['runtime_jar']);classes=Path(p['runtime_classes']);native={};rows=[];calls=Counter();start=time.monotonic()
    def remaining():return p['budgets']['execution_wall_seconds']-(time.monotonic()-start)
    def search(domain,problem,out):
        if remaining()<1:return {'status':'not_run_audit_budget','search_calls':0}
        calls['search']+=1
        return invoke(jar,domain,problem,out,seconds=max(1,min(15,int(remaining()))))
    def replay(domain,problem,plan,out):
        if remaining()<1:return {'status':'not_run_audit_budget','search_calls':0}
        calls['replay_slots']+=1
        try:return base.replay_checked(jar,classes,domain,problem,plan,out,seconds=max(1,min(15,int(remaining()))))
        except (ValueError,KeyError,TypeError) as exc:return {'status':'unsupported_or_invalid','reason':str(exc),'search_calls':0}
    def progress():
        save(root/'execution_progress.json',{'native_completed':len(native),'native_registered':len(source_ids),
            'source_slots_completed':len(rows),'source_slots_registered':len(comp['tasks']),'calls':dict(calls),
            'elapsed_seconds':time.monotonic()-start})
    progress()
    for sid in source_ids:
        source=sources[sid];out=root/'execution/native'/sid
        result=search(source.domain_path,source.problem_path,out)
        if result['status']=='solved':result['replay']=replay(source.domain_path,source.problem_path,out/'plan.pddl',out/'replay')
        native[sid]=result;save(root/'native_progress.json',native);progress()
    for task in comp['tasks']:
        row=dict(task);out=root/'execution'/task['group']/task['condition']/task['source']
        domain=Path(task['domain']);problem=Path(task['problem'])
        row['search']=search(domain,problem,out/'search') if task['search_anchor'] else {'status':'not_registered_anchor','search_calls':0}
        if row['search']['status']=='solved':row['replay']=replay(domain,problem,out/'search/plan.pddl',out/'replay')
        if native[task['source']]['status']=='solved' and base.valid(native[task['source']].get('replay',{})):
            source=sources[task['source']];terms={**source.term_map,**{o:source.id+'_o_'+o for o in source.objects}}
            out.mkdir(parents=True,exist_ok=True);plan=out/'transport.pddl'
            translate_plan(source.id,base.read(Path(task['mapping'])),terms,root/'execution/native'/source.id/'plan.pddl',plan)
            row['transport']=replay(domain,problem,plan,out/'transport')
        else:row['transport']={'status':'unavailable_valid_native_plan','native_status':native[task['source']]['status'],'search_calls':0}
        rows.append(row)
        with (root/'execution_events.jsonl').open('a',encoding='utf-8') as log:log.write(json.dumps(row)+'\n')
        progress()
    report={'status':'complete_interim_diagnostic','scope':'Nine fixed groups using a partial judgment snapshot; not final main results',
        'native':native,'rows':rows,'calls':dict(calls),'model_calls':0,'groups':9,'models':27,
        'elapsed_seconds':time.monotonic()-start,'native_counts':dict(Counter(r['status'] for r in native.values())),
        'by_size_condition':{str(k):{c:{'search_counts':dict(Counter(r['search']['status'] for r in rows if r['size']==k and r['condition']==c and r['search_anchor'])),
            'valid_returned_plans':sum(base.valid(r.get('replay',{})) for r in rows if r['size']==k and r['condition']==c),
            'transport_counts':dict(Counter(r['transport']['status'] for r in rows if r['size']==k and r['condition']==c)),
            'valid_transports':sum(base.valid(r['transport']) for r in rows if r['size']==k and r['condition']==c)} for c in base.CONDITIONS} for k in (2,3,4)},
        'observed_violations':[],'independent_semantic_labels':0,
        'compiled_inputs_unchanged':all(digest(Path(path))==h for path,h in comp['input_sha256'].items())}
    for r in rows:
        for kind,value in [('returned_plan',r.get('replay',{})),('transport',r['transport'])]:
            evidence=base.replay_evidence(value)
            if evidence not in ('valid','unknown'):report['observed_violations'].append({'id':r['id'],'kind':kind,'evidence':evidence})
    save(root/'report.json',report)
    return {k:v for k,v in report.items() if k not in ('native','rows','by_size_condition')}


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('mode',choices=['prepare','compile','execute'])
    parser.add_argument('--campaign',type=Path);parser.add_argument('--output',type=Path,required=True);a=parser.parse_args()
    if a.mode=='prepare':result=prepare(a.campaign,a.output)
    elif a.mode=='compile':result=validate_and_compile(a.output)
    else:result=execute(a.output)
    print(json.dumps(result,indent=2))

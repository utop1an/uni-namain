"""Frozen five-repeat k=2/3/4 experiment; fresh model calls and bounded planning."""
import argparse
from collections import Counter
from datetime import datetime,timezone
from itertools import combinations
import json
import os
from pathlib import Path
import shutil
import time
import traceback

from rcnc.domain_building import digest,save,snapshot_implementation
from rcnc.glaive_merge import Source,build,map_problem,translate_plan
from rcnc.glaive_runtime import invoke
from rcnc import model_semantics
from rcnc.model_semantics_contract import include_output_contract
from rcnc.pddl import parse_sexpr,section,serialize
from rcnc.revised_multistory import select_groups
from rcnc.revised_sampling import rank
from rcnc.saved_plan_validation import replay_saved
from scripts.data.freeze_revised_multistory import verify_frozen

DATA=Path('data/benchmarks/revised_multistory_balanced_2026_11_01_v1')
RUNTIME=Path('data/validation/glaive_runtime_correction_2026_11_01_v5')
MODEL='glm-5.3:cloud'
MODEL_DIGEST='8477dab3e25bb0f93c468af220186f55394262ee5e9f39262af4b60b54a8c4ba'
CONDITIONS=('union','predicate_only','full')
IMPLEMENTATION=[Path(__file__),*[Path('rcnc')/(n+'.py') for n in (
    'revised_multistory','revised_sampling','glaive_merge','glaive_runtime','domain_building','pddl','conditional_merge',
    'model_semantics','model_semantics_schema','model_semantics_facets','model_semantics_role_contract',
    'model_semantics_compact','model_semantics_contract','saved_plan_validation','revised_probe_validation')],
    Path('scripts/data/freeze_revised_multistory.py'),Path('scripts/java/GlaiveProbe.java'),
    Path('tests/test_revised_multistory.py')]


def read(p):return json.loads(Path(p).read_text(encoding='utf-8'))
def now():return datetime.now(timezone.utc).isoformat()


def physical(domain,problem,plan):
    try:return replay_saved(domain,problem,plan)
    except (ValueError,KeyError,TypeError) as exc:return {'status':'unsupported_or_invalid','reason':str(exc)}


def replay_checked(jar,classes,domain,problem,plan,output,seconds=15):
    steps=section(parse_sexpr(plan.read_text(encoding='utf-8')),':steps')
    if steps is None:raise ValueError('Missing plan steps')
    if any(s and s[0]=='non-executed' for s in steps[1:]):
        return {'status':'unavailable_counterfactual_plan_format','search_calls':0}
    result=invoke(jar,domain,problem,output,mode='replay',seconds=seconds,classes=classes,plan=plan)
    result={**result,'physical':physical(domain,problem,plan)}
    save(output/'checked_result.json',result)
    return result


def valid(result):
    return (result.get('status')=='replayed' and result.get('goal') is True and result.get('unexplained_steps')==0
        and result.get('physical',{}).get('status')=='replayed' and result['physical'].get('goal') is True)


def replay_evidence(result):
    if valid(result):return 'valid'
    physical_result=result.get('physical',{})
    if physical_result.get('status')=='inapplicable' or (physical_result.get('status')=='replayed' and physical_result.get('goal') is False):
        return 'physical_violation'
    if result.get('status')=='replayed' and (result.get('goal') is False or result.get('unexplained_steps',0)>0):
        return 'intentional_or_goal_violation'
    return 'unknown'


def preflight(output):
    if output.exists():raise ValueError('Fresh preflight directory required')
    from tests.test_revised_multistory import fixture
    runtime=read(RUNTIME/'report.json');jar=Path(runtime['jar']);classes=Path('.tmp/glaive_classes_v1')
    if runtime['status']!='verified' or digest(jar)!=runtime['jar_sha256']:raise ValueError('Unverified corrected runtime')
    output.mkdir(parents=True);tasks=[]
    for n in (3,4):
        folder=output/('sources_'+str(n));folder.mkdir();sources,raw=fixture(folder,n)
        predicates,_=select_groups(sources,raw,'predicate');pred=build(sources,folder/'predicate_only',groups=predicates)
        actions,_=select_groups(sources,raw,'action',predicate_maps=pred['predicate_maps'])
        full=build(sources,folder/'full',groups=predicates+actions,merge_actions=True)
        if len(actions)!=1 or len(actions[0]['members'])!=n or full['action_count']!=1:raise ValueError('Multiway preflight failed')
        for s in sources:
            pr=folder/(s.id+'_mapped.pddl');terms=map_problem(sources,s.id,full,pr)
            native=folder/(s.id+'_native_plan.pddl');native.write_text(f'(define (plan p) (:problem {s.id}) (:steps (travel alice home away)))',encoding='utf-8')
            plan=folder/(s.id+'_plan.pddl');translate_plan(s.id,full,terms,native,plan)
            neg=parse_sexpr(pr.read_text(encoding='utf-8'));section(neg,':init').remove([s.id+'_active'])
            negative=folder/(s.id+'_inactive.pddl');negative.write_text(serialize(neg),encoding='utf-8')
            for label,problem in [('positive',pr),('source_inactive',negative)]:
                tasks.append({'id':str(n)+'_'+s.id+'_'+label,'expected':label,'domain':str(folder/'full/domain.pddl'),'problem':str(problem),'plan':str(plan)})
    snapshots=snapshot_implementation(output,IMPLEMENTATION)
    inputs={str(p):digest(p) for p in output.rglob('*') if p.is_file()}
    inputs.update({str(jar):digest(jar),str(classes/'GlaiveProbe.class'):digest(classes/'GlaiveProbe.class')})
    save(output/'protocol.json',{'status':'frozen_before_preflight','tasks':tasks,'input_sha256':inputs,'implementation_sha256':snapshots,'model_calls':0,'search_calls':0})
    rows=[]
    for task in tasks:
        out=output/'execution'/task['id'];result=replay_checked(jar,classes,Path(task['domain']),Path(task['problem']),Path(task['plan']),out,10)
        if task['expected']=='positive':passed=valid(result)
        else:
            log=(out/'stdout.txt').read_text(encoding='utf-8',errors='replace')
            passed=(result.get('status')=='runtime_error' and result.get('returncode')==1 and
                'IllegalArgumentException: Inapplicable step 0' in log and result['physical'].get('status')=='inapplicable')
        rows.append({**task,'passed':passed,'result':result})
    unchanged=all(digest(Path(p))==h for p,h in {**inputs,**snapshots}.items())
    report={'status':'passed' if unchanged and all(x['passed'] for x in rows) else 'failed','rows':rows,'checks':len(rows),
        'passed':sum(x['passed'] for x in rows),'inputs_unchanged':unchanged,'model_calls':0,'search_calls':0,'replay_calls':len(rows)}
    save(output/'report.json',report)
    return {k:v for k,v in report.items() if k!='rows'}


def prepare(root,gate):
    if root.exists():raise ValueError('Fresh campaign directory required')
    audit=verify_frozen(DATA);preflight_report=read(gate/'report.json')
    if preflight_report['status']!='passed' or preflight_report['passed']!=14:raise ValueError('Preflight gate failed')
    runtime=read(RUNTIME/'report.json')
    if runtime['status']!='verified':raise ValueError('Runtime not verified')
    frozen=read(DATA/'freeze.json');source_rows=[s for s in read(DATA/'cohort.json')['sources'] if s['included']]
    groups=[g for g in read(DATA/'groups.json')['groups'] if g['size'] in (2,3,4)]
    pairs={p for g in groups for p in combinations(g['sources'],2)}
    candidates=[c for c in read(DATA/'candidate_inventory.json')['candidates'] if tuple(sorted(c['source_pair'])) in pairs]
    candidates.sort(key=lambda c:rank('k234-request-order-v1',c['id']))
    if len(groups)!=300 or len(pairs)!=538 or len(candidates)!=4680:raise ValueError('Unexpected subset denominator')
    root.mkdir(parents=True);(root/'inputs').mkdir();(root/'runtime/classes').mkdir(parents=True)
    for row in source_rows:
        shutil.copyfile(DATA/row['files']['revised-domain.pddl']['frozen_path'],root/'inputs'/(row['id']+'_domainfile.pddl'))
    shutil.copyfile(Path(runtime['jar']),root/'runtime/glaive-corrected.jar')
    shutil.copyfile('.tmp/glaive_classes_v1/GlaiveProbe.class',root/'runtime/classes/GlaiveProbe.class')
    save(root/'dataset_audit.json',audit);save(root/'selected_groups.json',{'groups':groups});save(root/'selected_candidates.json',{'candidates':candidates})
    template=root/'unexecuted_request_template'
    model_semantics.prepare(root/'inputs',candidates,template,model=MODEL,model_digest=MODEL_DIGEST,
        total_seconds=144000,request_seconds=240,schema_policy='compact_kind_specific',num_predict=16384,num_ctx=32768)
    include_output_contract(template)
    repeats=[]
    for i in range(1,6):
        repeat=root/('repeat_'+str(i).zfill(2));judgments=repeat/'judgments';shutil.copytree(template,judgments)
        requests=read(judgments/'requests.json');manifest=read(judgments/'manifest.json');seed=2026110100+i
        for request in requests.values():request['options']['seed']=seed
        manifest['options']['seed']=seed;manifest['repeat_id']=repeat.name
        manifest['seed_note']='Requested seed differs by repeat; provider-side enforcement is unverified. These are fresh API repetitions, not guaranteed independent seeded draws.'
        save(judgments/'requests.json',requests);manifest['requests_sha256']=digest(judgments/'requests.json');save(judgments/'manifest.json',manifest)
        repeats.append({'id':repeat.name,'path':str(repeat),'seed':seed,'candidate_count':len(candidates),
            'oversize_request_count':sum(len(json.dumps(r))>60000 for r in requests.values()),'manifest_sha256':digest(judgments/'manifest.json')})
    implementations=snapshot_implementation(root,IMPLEMENTATION)
    inputs={str(p):digest(p) for p in root.rglob('*') if p.is_file()}
    inputs.update({str(DATA/rel):h for rel,h in frozen['artifact_sha256'].items()})
    inputs.update({str(DATA/'freeze.json'):digest(DATA/'freeze.json'),str(gate/'report.json'):digest(gate/'report.json'),str(RUNTIME/'report.json'):digest(RUNTIME/'report.json')})
    gate_protocol=read(gate/'protocol.json');inputs.update(gate_protocol['input_sha256']);inputs.update(gate_protocol['implementation_sha256'])
    protocol={'status':'frozen_before_main_calls','created_utc':now(),'dataset':str(DATA),'dataset_freeze_sha256':audit['freeze_sha256'],
        'selected_sizes':[2,3,4],'groups_per_size':100,'groups':300,'sources':60,'source_pairs':538,'candidates_per_repeat':4680,
        'repeats':repeats,'conditions':['native',*CONDITIONS],'model':MODEL,'model_digest':MODEL_DIGEST,
        'runtime_jar':str(root/'runtime/glaive-corrected.jar'),'runtime_jar_sha256':digest(root/'runtime/glaive-corrected.jar'),
        'runtime_classes':str(root/'runtime/classes'),'runtime_variant':'glaive_disjunction_and_empty_type_correction',
        'confidence_threshold':.9,'max_consensus_cliques_per_kind_group':50000,
        'budgets':{'model_requests_per_repeat':4680,'model_total_requests':23400,'model_seconds_per_repeat':144000,
            'model_request_seconds':240,'model_workers':1,'search_seconds':15,'replay_seconds':15,'planner_memory_mb':4096,
            'planner_workers':1,'native_searches_per_repeat':60,'merged_searches_per_repeat':1800,
            'transport_slots_per_repeat':2700,'attempts_per_request_or_search':1},
        'source_rows':source_rows,'input_sha256':inputs,'implementation_sha256':implementations,
        'policy':['Fresh model calls in every repeat; no old predictions, retries, majority vote, best-run selection, or cache continuation.',
            'Identical original-symbol requests reused only within a repeat across groups and sizes; correlated uses are not independent samples.',
            'Complete-link compatible judgments, role-cycle consistency, identical concept/scope/aligned-role strings, and distinct source membership required.',
            'Select disjoint eligible clusters by descending source count, then minimum confidence, then canonical references. Missing/conflicting edges retain separate symbols.',
            'Action clusters must additionally have identical mapped effects and actor roles. No transitive semantic closure or rewritten effects.',
            'Build and hash all 900 parameterized models before any main planning in that repeat.',
            'Search the two fixed anchor original problems per group; transport available valid native plans for all sources in each group.',
            'Original initial states and goals stay source-local; no pooled facts or cross-source composition tasks.',
            'Retain all invalid answers, timeouts, missing plans and unsupported rows. Stop further repeat dispatch after model transport failure or total model budget exhaustion.',
            'Stop further repeat dispatch after an observed transport validity failure; preserved outputs require diagnosis, not silent recovery.',
            'Five consecutive fresh API repetitions; requested seeds differ, but cloud determinism and backend seed enforcement are not assumed.',
            'Results concern 60 known domains and correlated nested groups; independent semantic and narrative labels remain zero.']}
    save(root/'protocol.json',protocol)
    (root/'PROTOCOL.sha256').write_text(digest(root/'protocol.json')+'  protocol.json\n',encoding='utf-8')
    return {'status':protocol['status'],'groups':300,'repeats':len(repeats),'requests_per_repeat':4680,
        'requests_total':23400,'oversize_per_repeat':[r['oversize_request_count'] for r in repeats],
        'searches_per_repeat':1860,'transport_slots_per_repeat':2700,'protocol_sha256':digest(root/'protocol.json')}


def verify(root):
    p=read(root/'protocol.json')
    if digest(root/'protocol.json')!=(root/'PROTOCOL.sha256').read_text(encoding='utf-8').split()[0]:raise ValueError('Changed protocol')
    for name,h in {**p['input_sha256'],**p['implementation_sha256']}.items():
        if digest(Path(name))!=h:raise ValueError('Frozen dependency changed: '+name)
    return p


def load_sources(protocol):
    return {s['id']:Source(s['id'],DATA/s['files']['revised-domain.pddl']['frozen_path'],DATA/s['files']['revised-problem.pddl']['frozen_path']) for s in protocol['source_rows']}


def compile_models(root,repeat):
    protocol=verify(root);sources=load_sources(protocol);report=read(repeat/'judgments/report.json')
    if report['status']!='complete':raise ValueError('Model stage incomplete')
    if (repeat/'compilation.json').exists() or (repeat/'models').exists():raise ValueError('Fresh compilation only')
    raw=read(repeat/'judgments/groups.json')['groups'];models=[];tasks=[];audits=[];files=[]
    for row in read(root/'selected_groups.json')['groups']:
        selected=[sources[s] for s in row['sources']]
        predicates,pa=select_groups(selected,raw,'predicate',threshold=.9)
        union_folder=repeat/'models'/row['id']/'union';pred_folder=repeat/'models'/row['id']/'predicate_only';full_folder=repeat/'models'/row['id']/'full'
        union=build(selected,union_folder);pred=build(selected,pred_folder,groups=predicates)
        actions,aa=select_groups(selected,raw,'action',threshold=.9,predicate_maps=pred['predicate_maps'])
        full=build(selected,full_folder,groups=predicates+actions,merge_actions=True)
        if pred['predicate_maps']!=full['predicate_maps']:raise ValueError('Unmatched predicate mappings')
        audits.append({'group':row['id'],'predicate':pa,'action':aa,'consensus_groups':predicates+actions})
        for condition,meta,folder in [('union',union,union_folder),('predicate_only',pred,pred_folder),('full',full,full_folder)]:
            models.append({'group':row['id'],'size':row['size'],'chain_id':row['chain_id'],'condition':condition,**meta})
            for s in selected:
                problem=folder/(s.id+'.pddl');map_problem(selected,s.id,meta,problem)
                tasks.append({'id':row['id']+'__'+condition+'__'+s.id,'group':row['id'],'size':row['size'],
                    'chain_id':row['chain_id'],'condition':condition,'source':s.id,'search_anchor':s.id in row['anchor_sources'],
                    'domain':str(folder/'domain.pddl'),'problem':str(problem),'mapping':str(folder/'mapping.json')})
            files.extend(folder.iterdir())
    tasks.sort(key=lambda x:(rank('group-search-v1',x['chain_id']),x['size'],rank('condition-search-v1',x['group'],x['condition']),x['source']))
    save(repeat/'consensus_audit.json',{'rows':audits,'independent_semantic_labels':0})
    receipt={'status':'compiled_before_search','models':models,'tasks':tasks,'model_count':len(models),
        'source_query_slots':len(tasks),'anchor_search_slots':sum(t['search_anchor'] for t in tasks),
        'judgment_report_sha256':digest(repeat/'judgments/report.json'),'groups_sha256':digest(repeat/'judgments/groups.json'),
        'consensus_audit_sha256':digest(repeat/'consensus_audit.json'),'input_sha256':{str(f):digest(f) for f in files}}
    save(repeat/'compilation.json',receipt)
    return {k:receipt[k] for k in ['status','model_count','source_query_slots','anchor_search_slots']}


def execute(root,repeat,state,state_path):
    protocol=verify(root);comp=read(repeat/'compilation.json');sources=load_sources(protocol)
    if (repeat/'execution_progress.json').exists():raise ValueError('Fresh execution only')
    for p,h in comp['input_sha256'].items():
        if digest(Path(p))!=h:raise ValueError('Changed compiled model')
    if digest(repeat/'judgments/groups.json')!=comp['groups_sha256']:raise ValueError('Changed judgment groups')
    jar=Path(protocol['runtime_jar']);classes=Path(protocol['runtime_classes']);native={};rows=[]
    def event(kind,value):
        with (repeat/'execution_events.jsonl').open('a',encoding='utf-8') as stream:
            stream.write(json.dumps({'kind':kind,'row':value},ensure_ascii=False)+'\n')
    def progress():
        save(repeat/'execution_progress.json',{'native_completed':len(native),'source_query_slots_completed':len(rows),
            'events':'execution_events.jsonl','native_counts':dict(Counter(r['status'] for r in native.values())),
            'search_counts':dict(Counter(r['search']['status'] for r in rows)),
            'transport_counts':dict(Counter(r['transport']['status'] for r in rows))})
        state.update(completed_native=len(native),completed_source_query_slots=len(rows));save(state_path,state)
    progress()
    for sid in sorted(sources,key=lambda s:rank('native-order-v1',s)):
        source=sources[sid];out=repeat/'execution/native'/sid
        r=invoke(jar,source.domain_path,source.problem_path,out,seconds=15)
        if r['status']=='solved':r['replay']=replay_checked(jar,classes,source.domain_path,source.problem_path,out/'plan.pddl',out/'replay')
        native[sid]=r;event('native',{'source':sid,**r});progress();print(repeat.name,'native',sid,r['status'],flush=True)
    for task in comp['tasks']:
        out=repeat/'execution'/task['group']/task['condition']/task['source'];row=dict(task)
        domain=Path(task['domain']);problem=Path(task['problem'])
        if task['search_anchor']:
            row['search']=invoke(jar,domain,problem,out/'search',seconds=15)
            if row['search']['status']=='solved':row['replay']=replay_checked(jar,classes,domain,problem,out/'search/plan.pddl',out/'replay')
        else:row['search']={'status':'not_registered_anchor','search_calls':0}
        if native[task['source']]['status']=='solved' and valid(native[task['source']].get('replay',{})):
            s=sources[task['source']];terms={**s.term_map,**{o:s.id+'_o_'+o for o in s.objects}}
            out.mkdir(parents=True,exist_ok=True);plan=out/'transport.pddl'
            translate_plan(s.id,read(Path(task['mapping'])),terms,repeat/'execution/native'/s.id/'plan.pddl',plan)
            row['transport']=replay_checked(jar,classes,domain,problem,plan,out/'transport')
        else:
            row['transport']={'status':'unavailable_valid_native_plan','native_status':native[task['source']]['status'],
                'native_replay_status':native[task['source']].get('replay',{}).get('status'),
                'native_physical_status':native[task['source']].get('replay',{}).get('physical',{}).get('status'),'search_calls':0}
        rows.append(row);event('source_query',row);progress()
        print(repeat.name,task['id'],row['search']['status'],row['transport']['status'],flush=True)
    violations=[{'id':r['id'],'status':r['transport']['status'],'evidence':replay_evidence(r['transport'])} for r in rows
        if r['transport']['status']!='unavailable_valid_native_plan' and replay_evidence(r['transport']) not in ('valid','unknown')]
    invalid_returned=[r['id'] for r in rows if r['search']['status']=='solved' and replay_evidence(r.get('replay',{})) not in ('valid','unknown')]
    report={'status':'complete','native':native,'rows':rows,'sources':60,'groups':300,'source_query_slots':len(rows),
        'native_counts':dict(Counter(r['status'] for r in native.values())),
        'search_calls':sum(r['search_calls'] for r in native.values())+sum(r['search']['search_calls'] for r in rows),
        'model_requests':read(repeat/'judgments/report.json')['requests_attempted'],
        'gate_violations':violations,'invalid_returned_plans':invalid_returned,'independent_semantic_labels':0,
        'transport_unknowns':[r['id'] for r in rows if r['transport']['status']!='unavailable_valid_native_plan' and replay_evidence(r['transport'])=='unknown'],
        'returned_plan_unknowns':[r['id'] for r in rows if r['search']['status']=='solved' and replay_evidence(r.get('replay',{}))=='unknown'],
        'by_size_condition':{str(k):{c:{'search':dict(Counter(r['search']['status'] for r in rows if r['size']==k and r['condition']==c)),
            'transport':dict(Counter(r['transport']['status'] for r in rows if r['size']==k and r['condition']==c)),
            'transport_passed':sum(valid(r['transport']) for r in rows if r['size']==k and r['condition']==c)} for c in CONDITIONS} for k in (2,3,4)},
        'inputs_unchanged':all(digest(Path(p))==h for p,h in comp['input_sha256'].items())}
    save(repeat/'report.json',report)
    return {k:v for k,v in report.items() if k not in ('native','rows')}


def pipeline(root):
    protocol=verify(root);path=root/'coordinator.json'
    if path.exists():raise ValueError('Coordinator already started; no implicit continuation')
    state={'status':'running','started_utc':now(),'pid':os.getpid(),'protocol_sha256':digest(root/'protocol.json'),
        'stage':'startup','current_repeat':None,'repeat_results':[]};save(path,state)
    try:
        identity={'version':model_semantics.request_json('http://127.0.0.1:11434/api/version'),
            'models':[m for m in model_semantics.request_json('http://127.0.0.1:11434/api/tags')['models'] if m['name']==MODEL]}
        save(root/'service_identity.json',identity)
        for item in protocol['repeats']:
            repeat=Path(item['path']);state.update(current_repeat=item['id'],stage='judgments',completed_native=0,completed_source_query_slots=0);save(path,state)
            print('Starting',repeat.name,'judgments',flush=True)
            judgments=model_semantics.run(repeat/'judgments')
            # A timed-out request may still be active server-side. Never start another repeat after this.
            unexpected_unrequested=[r for r in judgments['rows'] if r['status']=='not_requested' and r.get('reason')!='context_size_limit']
            if judgments['status_counts'].get('request_failed',0) or unexpected_unrequested:
                state.update(status='stopped_model_stage_incomplete',stage='judgments',reason=judgments['status_counts']);break
            state['stage']='compilation';save(path,state);compile_models(root,repeat)
            state['stage']='execution';save(path,state);summary=execute(root,repeat,state,path)
            state['repeat_results'].append({'id':repeat.name,**summary});save(path,state)
            if summary['gate_violations'] or summary['invalid_returned_plans']:
                state.update(status='stopped_validation_gate',stage='execution');break
        else:state.update(status='complete',stage='complete')
        save(root/'report.json',{'status':state['status'],'completed_repeats':len(state['repeat_results']),
            'registered_repeats':len(protocol['repeats']),'repeat_results':state['repeat_results'],'independent_semantic_labels':0})
    except Exception as exc:
        state.update(status='failed',error=str(exc),traceback=traceback.format_exc());raise
    finally:
        state['ended_utc']=now();save(path,state)
    return state


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('mode',choices=['preflight','prepare','verify','pipeline']);p.add_argument('--output',type=Path,required=True);p.add_argument('--gate',type=Path)
    a=p.parse_args()
    if a.mode=='preflight':result=preflight(a.output)
    elif a.mode=='prepare':result=prepare(a.output,a.gate)
    elif a.mode=='verify':q=verify(a.output);result={'status':'verified','groups':q['groups'],'repeats':len(q['repeats'])}
    else:result=pipeline(a.output)
    print(json.dumps(result,indent=2))

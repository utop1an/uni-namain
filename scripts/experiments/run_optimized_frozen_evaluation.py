"""Offline replay regression and a fresh, fully registered 1200-group rerun.

Preparation runs with the repository Python. Execution runs under Linux user
and network namespaces (loopback only). No compilation, model inference,
reference backfill, opportunistic retries, or result overwrite is permitted.
"""
import argparse
import ast
from collections import Counter
from concurrent.futures import ProcessPoolExecutor, as_completed
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import socket
import subprocess
import sys
import time
import traceback
from types import SimpleNamespace

EXPECTED = {'native':428,'transport':21056,'anchor':4800,'composition':2400}
REPO_WIN = 'C:/anu/uninamain'
RELEASE = REPO_WIN+'/data/research_release/narrative_baseline_priority1_2026_11_05_v1'
JAR = None
LEGACY = None
TRANSLATE = None
ACTIVE = None


def local(value):
    s = str(value).replace('\\','/')
    if os.name != 'nt' and re.match(r'^[A-Za-z]:/', s):
        s = '/mnt/'+s[0].lower()+s[2:]
    if os.name == 'nt' and re.match(r'^/mnt/[a-z]/', s):
        s = s[5].upper()+':'+s[6:]
    return Path(s)


def external(value):
    """Reports use Windows paths so existing auditors can read them unchanged."""
    if isinstance(value, Path): value=str(value.resolve())
    if isinstance(value, str) and value.startswith('/mnt/c/'):
        return ('C:'+value[6:]).replace('/','\\')
    if isinstance(value, dict): return {external(k):v if k=='command' else external(v) for k,v in value.items()}
    if isinstance(value, (list,tuple)): return [external(v) for v in value]
    return value


def read(p): return json.loads(local(p).read_text(encoding='utf-8'))
def sha(p): return hashlib.sha256(local(p).read_bytes()).hexdigest()
def now(): return datetime.now(timezone.utc).isoformat()


def write(p, value):
    p=local(p); p.parent.mkdir(parents=True,exist_ok=True)
    with p.open('x',encoding='utf-8',newline='\n') as f:
        json.dump(external(value), f, ensure_ascii=False,indent=2); f.write('\n')


def progress(root, **value):
    value.update(updated_utc=now(),model_requests=0)
    tmp=root/'coordinator.next.json'; tmp.write_text(json.dumps(external(value),ensure_ascii=False,indent=2),encoding='utf-8')
    tmp.replace(root/'coordinator.json')


def offline_guard(event,args):
    if event in ('socket.connect','socket.connect_ex','socket.getaddrinfo','urllib.Request'):
        raise RuntimeError('Offline run forbids networking and model requests')


def isolation():
    if os.name=='nt': raise RuntimeError('Execution requires isolated Linux namespace')
    interfaces=socket.if_nameindex()
    if interfaces != [(1,'lo')]: raise RuntimeError('Expected loopback-only namespace: '+repr(interfaces))
    sys.addaudithook(offline_guard)
    for key in list(os.environ):
        if any(s in key.upper() for s in ('OPENAI','ANTHROPIC','GEMINI','OLLAMA','API_KEY','PROXY')):
            os.environ.pop(key,None)
    sys.dont_write_bytecode=True
    return {'network_interfaces':interfaces,'network_namespace':os.readlink('/proc/self/ns/net'),
            'python_network_audit':'deny','credential_environment':'removed','model_requests':0}


def initialize(jar):
    global JAR,LEGACY,TRANSLATE
    JAR=local(jar)
    code=local(RELEASE)/'code'; sys.path.insert(0,str(code)); sys.dont_write_bytecode=True
    from rcnc.pddl import parse_sexpr,section,serialize
    from rcnc.glaive_intake import casefold_tree
    from rcnc.saved_plan_validation import replay_saved
    # Execute the unchanged frozen function ASTs. Importing the whole legacy
    # orchestration would pull compiler/model clients into this replay-only path.
    scope=dict(Path=Path,json=json,hashlib=hashlib,parse_sexpr=parse_sexpr,section=section,
               serialize=serialize,casefold_tree=casefold_tree,replay_saved=replay_saved,invoke=invoke)
    for relative,names in [('rcnc/domain_building.py',{'save'}),
                           ('rcnc/glaive_merge.py',{'Unsupported','translate_plan'}),
                           ('scripts/experiments/run_revised_multistory.py',{'physical','replay_checked','valid'})]:
        source=code/relative;tree=ast.parse(source.read_text(encoding='utf-8'))
        nodes=[node for node in tree.body if isinstance(node,(ast.FunctionDef,ast.ClassDef)) and node.name in names]
        if {node.name for node in nodes}!=names:raise ValueError('Frozen function set changed')
        exec(compile(ast.Module(body=nodes,type_ignores=[]),str(source),'exec'),scope)
    LEGACY=SimpleNamespace(**{k:scope[k] for k in ('physical','replay_checked','valid')})
    TRANSLATE=scope['translate_plan']
    for name,mod in list(sys.modules.items()):
        if name.split('.')[0] in ('rcnc','scripts','unidomain','archive'):
            f=getattr(mod,'__file__',None)
            if f and not Path(f).resolve().is_relative_to(code):
                raise ValueError('Non-frozen validator import: '+f)


def timed_out(signum,frame):
    if ACTIVE is not None:
        try: os.killpg(ACTIVE.pid,signal.SIGKILL)
        except ProcessLookupError: pass
    raise TimeoutError('Registered worker wall-time cap')


def timeout_exit(code,elapsed,seconds,kill_after=2.0):
    # WSL propagates a killed timeout wrapper as 137. Native subprocess.Popen
    # reports the same signal as -9. An earlier SIGKILL could instead be OOM;
    # do not silently register that as a time-limit retry.
    return code in (124,137) or code == -9 and elapsed >= seconds+kill_after-.05


def invoke(jar,domain,problem,output,*,mode='search',seconds=15,classes=None,plan=None):
    global ACTIVE
    output=local(output); output.mkdir(parents=True,exist_ok=False)
    inputs={external(local(p).resolve()):sha(p) for p in (jar,domain,problem)}
    if plan is not None: inputs[external(local(plan).resolve())]=sha(plan)
    target=output/'plan.pddl' if mode=='search' else local(plan)
    cmd=['timeout','--signal=TERM','--kill-after=2s',str(seconds)+'s','java','-Xmx4096m','-cp',str(local(jar)),
         'GlaiveOptimized',mode,str(local(domain)),str(local(problem)),str(target),str(seconds)]
    write(output/'invocation.json',{'command':cmd,'mode':mode,'seconds':seconds,'input_sha256':inputs,'memory_mb':4096})
    start=time.monotonic()
    with (output/'stdout.txt').open('wb') as stream:
        ACTIVE=subprocess.Popen(cmd,stdout=stream,stderr=subprocess.STDOUT,start_new_session=True)
        try: code=ACTIVE.wait()
        finally: ACTIVE=None
    elapsed=time.monotonic()-start; log=(output/'stdout.txt').read_text(encoding='utf-8',errors='replace')
    events=[]
    for line in log.splitlines():
        if line.startswith('{'):
            try: events.append(json.loads(line))
            except json.JSONDecodeError: pass
    result={'status':'runtime_error','returncode':code,'seconds':elapsed,'mode':mode,
            'search_calls':int(mode=='search'),'input_sha256':inputs,'phase_events':events}
    if timeout_exit(code,elapsed,seconds): result['status']='wall_time_limit'
    elif 'OutOfMemoryError' in log: result['status']='memory_limit'
    elif 'ParseException' in log or 'FormatException' in log: result['status']='native_parse_error'
    elif code==0:
        terminal=[e for e in events if e['phase']=='result']
        if terminal: result.update({k:v for k,v in terminal[-1].items() if k not in ('phase','elapsed_seconds')})
    if result['status']=='solved' and not target.exists(): raise ValueError('Missing returned plan')
    if any(sha(p)!=h for p,h in inputs.items()): raise ValueError('Invocation changed input')
    write(output/'result.json',result)
    return result


def native_ok(r): return r.get('status')=='replayed' and r.get('goal') is True and r.get('unexplained_steps')==0


def _one(job):
    task=job['task']; start=time.monotonic(); root=local(job['root'])
    out=root/'repeat_01/execution'/task['kind']/task['id']
    row={**task,'status':'complete','valid':False,'native_valid':False,
         'execution_provenance':{'condition':job['condition'],'seconds':job['seconds'],'new_attempt':True}}
    signal.signal(signal.SIGALRM,timed_out); signal.alarm(job.get('worker_seconds',55))
    try:
        domain,problem=local(task['domain']),local(task['problem'])
        if job.get('replay_plan'):
            plan=local(job['replay_plan'])
            row['search']=job.get('retained_search',{'status':'regression_replay_only','search_calls':0})
        elif task['kind']=='transport':
            plan=out/'plan.pddl'; plan.parent.mkdir(parents=True,exist_ok=True)
            TRANSLATE(task['source'],read(task['mapping']),task['terms'],local(task['source_plan']),plan)
            row['search']={'status':'not_a_search','search_calls':0}
        else:
            row['search']=invoke(JAR,domain,problem,out/'search',seconds=job['seconds'])
            if row['search']['status']!='solved': return external(row)
            plan=out/'search/plan.pddl'
        row['plan']=external(plan)
        replay=LEGACY.replay_checked(JAR,None,domain,problem,plan,out/'replay',job['seconds'])
        row['replay']=replay; row['valid']=LEGACY.valid(replay); row['native_valid']=native_ok(replay)
        row['validation_level']='dual_validated' if row['valid'] else 'native_only_physical_unknown' if row['native_valid'] and replay.get('physical',{}).get('status') in ('unsupported','unsupported_or_invalid') else 'unavailable_valid_reference'
        return external(row)
    except TimeoutError as exc:
        row.update(status='worker_wall_time_limit',error=str(exc))
        row.setdefault('search',{'status':'worker_wall_time_limit','search_calls':None})
        return external(row)
    except Exception as exc:
        row.update(status='worker_failed',error=type(exc).__name__+': '+str(exc),traceback=traceback.format_exc())
        row.setdefault('search',{'status':'worker_failed','search_calls':None})
        return external(row)
    finally:
        signal.alarm(0); row['worker_seconds']=time.monotonic()-start


def one(job):
    start=time.monotonic(); result=_one(job)
    result['worker_seconds']=time.monotonic()-start
    return result


def execute(root,jobs,jar,workers,label):
    started=time.monotonic(); rows=[]; root.mkdir(parents=True,exist_ok=True)
    with (root/(label+'_events.jsonl')).open('x',encoding='utf-8') as stream:
        with ProcessPoolExecutor(max_workers=workers,initializer=initialize,initargs=(str(jar),)) as pool:
            futures={pool.submit(one,j):j for j in jobs}
            for future in as_completed(futures):
                row=future.result(); rows.append(row)
                stream.write(json.dumps(row,ensure_ascii=False)+'\n'); stream.flush()
                if len(rows)%25==0 or len(rows)==len(jobs):
                    progress(root,status='running',stage=label,completed=len(rows),registered=len(jobs),elapsed_seconds=time.monotonic()-started)
                    print(json.dumps({'stage':label,'completed':len(rows),'registered':len(jobs),'elapsed_seconds':round(time.monotonic()-started,2)}),flush=True)
    return rows,time.monotonic()-started


def regression(root,parents,jar,workers):
    if root.exists(): raise ValueError('Fresh regression directory required')
    receipt=isolation(); root.mkdir(parents=True)
    selected={}; negatives={}; files={external(jar):sha(jar),external(Path(__file__).resolve()):sha(__file__)}
    for parent in parents:
        for stage in EXPECTED:
            path=parent/'repeat_01'/(stage+'_report.json'); files[external(path)]=sha(path)
            for row in read(path)['rows']:
                if not row.get('plan') or not row.get('replay'): continue
                if row.get('native_valid'):
                    selected.setdefault((sha(row['domain']),sha(row['problem']),sha(row['plan'])),row)
                elif row['replay'].get('status')=='replayed':
                    key=(row['replay'].get('goal'),row['replay'].get('unexplained_steps',0)>0)
                    if len(negatives.setdefault(key,[]))<50: negatives[key].append(row)
    cases=list(selected.values())+[r for values in negatives.values() for r in values]
    jobs=[]
    for i,old in enumerate(cases):
        for k in ('domain','problem','plan'): files[old[k]]=sha(old[k])
        task={**old,'id':str(i).zfill(5),'original_id':old['id'],'kind':'regression'}
        jobs.append({'root':str(root),'task':task,'replay_plan':old['plan'],'seconds':60,'worker_seconds':180,'condition':'saved_plan_regression'})
    write(root/'protocol.json',{'status':'frozen_before_saved_plan_regression','jobs':jobs,'input_sha256':files,
          'historical_unique_positive_plans':len(selected),'negative_cases':len(cases)-len(selected),'isolation':receipt,
          'comparison_fields':['status','goal','steps','unexplained_steps','orphan_steps','physical','valid','native_valid']})
    rows,elapsed=execute(root,jobs,jar,workers,'regression')
    byid={r['id']:r for r in rows}; comparisons=[]
    for i,old in enumerate(cases):
        new=byid[str(i).zfill(5)]; differences=[]
        for key in ('status','goal','steps','unexplained_steps','orphan_steps','physical'):
            if old['replay'].get(key)!=new.get('replay',{}).get(key): differences.append(key)
        for key in ('valid','native_valid'):
            if bool(old.get(key))!=bool(new.get(key)): differences.append(key)
        comparisons.append({'id':new['id'],'original_id':old['id'],'differences':differences,'passed':not differences})
    unchanged=all(sha(p)==v for p,v in files.items())
    report={'status':'passed' if unchanged and all(r['passed'] for r in comparisons) else 'failed',
        'cases':len(cases),'positive_plans':len(selected),'negative_cases':len(cases)-len(selected),
        'passed':sum(r['passed'] for r in comparisons),'failed':sum(not r['passed'] for r in comparisons),
        'seconds':elapsed,'inputs_unchanged':unchanged,'model_requests':0,'comparisons':comparisons,'rows':rows}
    write(root/'report.json',report);progress(root,status=report['status'],completed=len(rows),registered=len(jobs),elapsed_seconds=elapsed)
    print(json.dumps({k:v for k,v in report.items() if k not in ('rows','comparisons')}),flush=True)


def prepare(root,parent,historical,jar,gate,workers):
    if root.exists(): raise ValueError('Fresh experiment directory required')
    if read(gate/'report.json')['status']!='passed': raise ValueError('Saved-plan regression must pass')
    root.mkdir(parents=True); files={};names={}
    for relative in ('selected_groups.json','sources.json','worlds.json','baseline_tasks.json',
                     'repeat_01/original_tasks.json','repeat_01/composition_tasks.json',
                     'repeat_01/compilation_report.json','repeat_01/compiled_freeze.json','repeat_01/references.json',
                     'implementation.py','review.py'):
        dest=root/relative;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(parent/relative,dest)
        files[external((parent/relative).resolve())]=sha(parent/relative)
    for path in (parent/'repeat_01/groups').glob('*/compilation.json'):
        dest=root/path.relative_to(parent);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(path,dest)
    for stage,n in EXPECTED.items():
        src=parent/'registered_jobs'/(stage+'.json');tasks=read(src)['tasks']
        if len(tasks)!=n or len({t['id'] for t in tasks})!=n: raise ValueError('Changed task identities')
        write(root/'registered_jobs'/(stage+'.json'),{'tasks':tasks})
        files[external(src.resolve())]=sha(src)
        for t in tasks:
            for k in ('domain','problem','mapping','source_plan'):
                if t.get(k):
                    if t[k] not in names:names[t[k]]=external(local(t[k]).resolve())
                    name=names[t[k]]
                    if name not in files: files[name]=sha(t[k])
        for base in (parent,historical):
            p=base/'repeat_01'/(stage+'_report.json');files[external(p.resolve())]=sha(p)
    for p,h in read(parent/'repeat_01/compiled_freeze.json')['input_sha256'].items():
        if sha(p)!=h: raise ValueError('Historical compiled input changed: '+p)
        files[p]=h
    runtime=root/'runtime/glaive-optimized.jar';runtime.parent.mkdir();shutil.copyfile(jar,runtime)
    shutil.copyfile(__file__,root/'runner.py')
    for p in (local(RELEASE)/'code').rglob('*.py'): files[external(p.resolve())]=sha(p)
    files[external((gate/'report.json').resolve())]=sha(gate/'report.json')
    files[external(jar.resolve())]=sha(jar)
    files.update({external(p.resolve()):sha(p) for p in root.rglob('*') if p.is_file()})
    protocol={'status':'frozen_before_optimized_rerun','created_utc':now(),'groups':1200,
       'condition':'optimized_fresh15_then_timeout60_once','parent':str(parent.resolve()),'historical_final':str(historical.resolve()),
       'runtime_jar':str(runtime.resolve()),'runtime_classes':None,'regression':str(gate.resolve()),'input_sha256':files,
       'budgets':{'planner_workers':workers,'search_seconds':15,'replay_seconds':15,'retry_seconds':60,
                  'planning_worker_seconds':55,'retry_worker_seconds':180,'memory_mb_per_worker':4096,
                  'model_requests':0,'registered_slots':EXPECTED},
       'policies':['Fresh replay/search over all 28684 registered slots in 1200 fixed groups; unchanged model/problem/mapping bytes.',
                   'Original raw/adapter reference choice is frozen; no backfill from newly found native plans.',
                   '15-second search and replay limits; timeout-selected slots retry once at 60 seconds; terminal retry replaces original row.',
                   'Search-solved replay timeout retries replay only, retaining the found plan and original search.',
                   'Missing references, construction limits, unsupported and failed rows remain in the full denominator.',
                   'No recompilation, alignment requests, language model requests or network access.',
                   'Native replay uses original axiom contexts; physical validator and validation criteria are frozen to release.',
                   'Native-only unsupported outcomes remain unknown; no independent semantic or narrative labels.',
                   'Eight concurrent Linux workers with per-invocation 4096 MB heap; historical mixed concurrency makes wall-time comparison descriptive.',
                   'Runtime includes static membership pruning, hash/index storage optimization and stale-axiom applicability recheck.'],
       'original_results_preserved':True,'model_requests':0}
    write(root/'protocol.json',protocol);(root/'PROTOCOL.sha256').write_text(sha(root/'protocol.json')+'\n',encoding='utf-8')
    progress(root,status='prepared',stage='frozen',registered_slots=EXPECTED,input_files=len(files))
    print(json.dumps({'status':'prepared','groups':1200,'slots':EXPECTED,'input_files':len(files),'model_requests':0}),flush=True)


def retry_reason(row):
    if row.get('search',{}).get('status') in ('wall_time_limit','worker_wall_time_limit') or row.get('status')=='worker_wall_time_limit' and not row.get('plan'):
        return 'search_timeout'
    if row.get('replay',{}).get('status')=='wall_time_limit' or row.get('status')=='worker_wall_time_limit' and row.get('plan'):
        return 'replay_timeout'
    return None


def merge_retry_results(initial, retried):
    """Task IDs are only unique within an evaluation stage."""
    originals={}
    for stage,rows in initial.items():
        for row in rows:
            key=(stage,row['id'])
            if row.get('kind',stage)!=stage or key in originals:
                raise ValueError('Invalid or duplicate initial stage identity')
            originals[key]=row
    replacements={}
    for row in retried:
        key=(row['kind'],row['id'])
        if key not in originals or key in replacements:
            raise ValueError('Unregistered or duplicate retry stage identity')
        if retry_reason(originals[key]) is None:
            raise ValueError('Retry replaces a non-timeout result')
        replacements[key]=row
    return {stage:[replacements.get((stage,row['id']),row) for row in rows]
            for stage,rows in initial.items()}


def run(root):
    receipt=isolation();p=read(root/'protocol.json')
    if sha(root/'protocol.json')!=(root/'PROTOCOL.sha256').read_text(encoding='utf-8').strip():raise ValueError('Protocol changed')
    if (root/'execution_start.json').exists():raise ValueError('No implicit resume or repeated attempt')
    if not all(sha(path)==h for path,h in p['input_sha256'].items()):raise ValueError('Frozen input changed')
    write(root/'execution_start.json',{'started_utc':now(),'isolation':receipt})
    start=time.monotonic();jar=local(p['runtime_jar']);workers=p['budgets']['planner_workers'];timing={};alltasks={};initial={}
    for stage in EXPECTED:
        tasks=read(root/'registered_jobs'/(stage+'.json'))['tasks'];alltasks[stage]={t['id']:t for t in tasks}
        ready=[t for t in tasks if t.get('status') in (None,'ready')]
        retained=[{**t,'valid':False,'native_valid':False,'search':{'status':t['status'],'search_calls':0}} for t in tasks if t.get('status') not in (None,'ready')]
        jobs=[{'root':str(root/'initial15'),'task':t,'seconds':15,'worker_seconds':55,'condition':'optimized_fresh15'} for t in ready]
        rows,elapsed=execute(root/'initial15',jobs,jar,workers,stage);rows+=retained;rows.sort(key=lambda r:r['id'])
        if len(rows)!=EXPECTED[stage]:raise ValueError('Denominator changed')
        initial[stage]=rows;timing['initial15_'+stage]=elapsed
        write(root/'initial15/repeat_01'/(stage+'_report.json'),{'status':'complete_registered_slots','registered_slots':len(rows),'rows':rows})
    retryjobs=[];registry={}
    for stage,rows in initial.items():
        registry[stage]=[]
        for row in rows:
            reason=retry_reason(row)
            if not reason:continue
            job={'root':str(root/'retry60'),'task':alltasks[stage][row['id']],'seconds':60,'worker_seconds':180,'condition':'optimized_timeout60_once','reason':reason}
            if reason=='replay_timeout':job.update(replay_plan=row['plan'],retained_search=row['search'])
            retryjobs.append(job);registry[stage].append(row['id'])
    retryjobs.sort(key=lambda j:hashlib.sha256(('optimized-retry-v1/'+j['task']['id']).encode()).hexdigest())
    write(root/'retry_registry.json',{'registered':len(retryjobs),'by_stage':registry,'jobs':retryjobs})
    retried,elapsed=execute(root/'retry60',retryjobs,jar,workers,'retry');timing['retry60']=elapsed
    combined_stages=merge_retry_results(initial,retried)
    for stage,combined in combined_stages.items():
        write(root/'repeat_01'/(stage+'_report.json'),{'status':'complete_registered_slots','registered_slots':len(combined),'rows':combined})
    unchanged=all(sha(path)==h for path,h in p['input_sha256'].items())
    if not unchanged:raise ValueError('Input integrity failed at completion')
    write(root/'timing.json',{'stage_wall_seconds':timing,'total_wall_seconds':time.monotonic()-start,
                            'finished_utc':now(),'inputs_unchanged':True,'model_requests':0,'retry_slots':len(retryjobs)})
    progress(root,status='complete',stage='complete',registered_slots=EXPECTED,elapsed_seconds=time.monotonic()-start,inputs_unchanged=True)
    print(json.dumps({'status':'complete','wall_seconds':time.monotonic()-start,'retry_slots':len(retryjobs),'model_requests':0}),flush=True)


def main():
    p=argparse.ArgumentParser();p.add_argument('mode',choices=['regression','prepare','run'])
    p.add_argument('--output',type=local,required=True);p.add_argument('--parent',type=local)
    p.add_argument('--historical',type=local);p.add_argument('--jar',type=local);p.add_argument('--gate',type=local)
    p.add_argument('--workers',type=int,default=8);a=p.parse_args()
    if a.mode=='regression':regression(a.output,[a.parent,a.historical],a.jar,a.workers)
    elif a.mode=='prepare':prepare(a.output,a.parent,a.historical,a.jar,a.gate,a.workers)
    else:run(a.output)


if __name__=='__main__':main()

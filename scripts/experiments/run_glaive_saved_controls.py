"""Run every frozen saved-plan control afresh under a separately versioned jar."""
import argparse,importlib.util,json,hashlib,sys,time
from pathlib import Path

def load(path):
    spec=importlib.util.spec_from_file_location('_glaive_executor',path);m=importlib.util.module_from_spec(spec);sys.modules[spec.name]=m;spec.loader.exec_module(m);return m
def prepare(root,previous,jar,executor,workers=2):
    if workers not in (1,2): raise ValueError('Use one or two workers for memory headroom')
    e=load(executor);p=e.read(previous);root.mkdir(parents=True,exist_ok=False)
    files=dict(p['input_sha256']);files[str(previous)]=e.sha(previous);files[str(jar)]=e.sha(jar)
    for src,dest in [(Path(__file__),root/'driver.py'),(executor,root/'executor.py')]:
        dest.write_bytes(src.read_bytes());files[str(dest)]=e.sha(dest)
    jobs=[]
    for job in p['jobs']:jobs.append({**job,'root':str(root),'condition':'initialization_saved_plan_fresh_regression'})
    assert len(jobs)==len({j['task']['id'] for j in jobs})
    for path,h in files.items():assert e.sha(path)==h,path
    e.write(root/'protocol.json',{'status':'frozen_fresh_saved_plan_controls','jobs':jobs,'jar':str(jar),'workers':workers,
        'input_sha256':files,'previous_registration':str(previous),'reuse':'Task and expected-result registration only; all controls execute afresh. No cached candidate results.',
        'positive_plans':p['historical_unique_positive_plans'],'negative_cases':p['negative_cases'],'model_requests':0})
    print(json.dumps({'registered':len(jobs),'model_requests':0}),flush=True)
def run(root):
    e=load(root/'executor.py');isolation=e.isolation();p=e.read(root/'protocol.json')
    assert all(e.sha(path)==h for path,h in p['input_sha256'].items())
    e.write(root/'execution_start.json',{'isolation':isolation,'started_utc':e.now()})
    rows,elapsed=e.execute(root,p['jobs'],e.local(p['jar']),p['workers'],'regression')
    old={j['task']['id']:j['task'] for j in p['jobs']};comp=[]
    for new in rows:
        before=old[new['id']];diff=[]
        for key in ('status','goal','steps','unexplained_steps','orphan_steps','physical'):
            if before.get('replay',{}).get(key)!=new.get('replay',{}).get(key):diff.append(key)
        for key in ('valid','native_valid'):
            if bool(before.get(key))!=bool(new.get(key)):diff.append(key)
        comp.append({'id':new['id'],'original_id':before['id'],'differences':diff,'passed':not diff})
    unchanged=all(e.sha(path)==h for path,h in p['input_sha256'].items())
    report={'status':'passed' if unchanged and len(rows)==len(old) and all(r['passed'] for r in comp) else 'failed',
        'cases':len(old),'positive_plans':p['positive_plans'],'negative_cases':p['negative_cases'],
        'passed':sum(r['passed'] for r in comp),'failed':sum(not r['passed'] for r in comp),'seconds':elapsed,
        'inputs_unchanged':unchanged,'model_requests':0,'comparisons':comp,'rows':rows}
    e.write(root/'report.json',report);e.progress(root,status=report['status'],completed=len(rows),registered=len(old))
    print(json.dumps({k:v for k,v in report.items() if k not in ('rows','comparisons')}),flush=True)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('mode',choices=['prepare','run']);p.add_argument('--output',type=Path,required=True)
    p.add_argument('--previous',type=Path);p.add_argument('--jar',type=Path);p.add_argument('--executor',type=Path);p.add_argument('--workers',type=int,default=2);a=p.parse_args()
    if a.mode=='prepare':prepare(a.output.resolve(),a.previous.resolve(),a.jar.resolve(),a.executor.resolve(),a.workers)
    else:run(a.output.resolve())

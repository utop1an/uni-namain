"""Run all predeclared development tasks, retaining failures and limits."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
from rcnc.planning import run_query


def isolate(query):
    q=copy.deepcopy(query); inverse={}
    for source_pred,entry in q.get('interfaces',{}).items():
        source,pred=source_pred.split(':',1)
        inverse.setdefault(entry['target'],[]).append(source.lower()+'__'+pred.lower())
    def expand(facts):
        return [[name,*f[1:]] for f in facts for name in inverse.get(f[0],[f[0]])]
    rewritten=any(f[0] in inverse for facts in q['goal'].values() for f in facts)
    q['initial']=expand(q['initial'])
    q['goal']={sign:expand(facts) for sign,facts in q['goal'].items()}
    q['interfaces']={};q['selection_mode']='all'
    return q,rewritten


def run_matrix(manifest_path,output):
    manifest=json.loads(manifest_path.read_text(encoding='utf-8'))
    output.mkdir(parents=True,exist_ok=True)
    if any(output.iterdir()):raise ValueError('Use an empty matrix output directory')
    (output/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    rows=[]
    for task in manifest['tasks']:
        task_path=manifest_path.parent/task
        base=json.loads(task_path.read_text(encoding='utf-8'))
        for method in manifest['methods']:
            query=copy.deepcopy(base);rewritten=False
            if method=='isolated':query,rewritten=isolate(query)
            else:query['selection_mode']=method
            result=run_query(query,Path('data/narra-domains'),output/task_path.stem/method)
            row={'task':task,'method':method,'task_sha256':hashlib.sha256(task_path.read_bytes()).hexdigest(),
                 'goal_rewritten':rewritten,'status':result['status'],'plan_length':result.get('plan_length'),
                 'validation':result.get('external_validation',{}).get('status'),
                 'states':result.get('states_discovered'),'reduction':result.get('reduction'),
                 'sources_used':result.get('sources_used'),'elapsed_seconds':result['elapsed_seconds']}
            rows.append(row)
            print(task,method,row['status'],row['plan_length'],row['validation'],flush=True)
    summary={'scope':manifest['scope'],'manifest_sha256':hashlib.sha256(manifest_path.read_bytes()).hexdigest(),
             'attempts':len(rows),'rows':rows}
    (output/'summary.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
    return summary

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--manifest',type=Path,default=Path('data/rcnc/fixed_tasks_v1/manifest.json'))
    p.add_argument('--output',type=Path,required=True)
    run_matrix(p.parse_args().manifest,p.parse_args().output)

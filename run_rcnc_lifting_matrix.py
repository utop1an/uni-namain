"""Run a predeclared constrained-lifting development matrix."""
import argparse
import hashlib
import json
from pathlib import Path
from rcnc.lifting import run_lifted_query

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--manifest',type=Path,default=Path('data/rcnc/lifting_tasks_v1/manifest.json'))
    p.add_argument('--output',type=Path,required=True)
    args=p.parse_args();manifest=json.loads(args.manifest.read_text())
    args.output.mkdir(parents=True,exist_ok=True)
    if any(args.output.iterdir()):raise ValueError('Use an empty matrix directory')
    (args.output/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    rows=[]
    for filename in manifest['tasks']:
        task=args.manifest.parent/filename
        r=run_lifted_query(json.loads(task.read_text()),Path('data/narra-domains'),args.output/task.stem)
        best=r.get('best') or {}
        row={'task':filename,'task_sha256':hashlib.sha256(task.read_bytes()).hexdigest(),
             'status':r['status'],'attempts':len(r.get('attempts',[])),
             'solved_assignments':sum(a['status']=='solved' for a in r.get('attempts',[])),
             'plan_length':best.get('plan_length'),'best_assignment':best.get('assignment'),
             'source_necessity':[{k:r[k] for k in ('removed_source','status','necessary_within_fixed_assignment')} for r in best.get('source_removal_controls',[])],
             'source_necessity_across_assignments':r.get('source_necessity_across_assignments',[]),
             'all_searches_complete':r.get('all_searches_complete'), 'reason':r.get('reason')}
        rows.append(row);print(json.dumps(row),flush=True)
    (args.output/'summary.json').write_text(json.dumps({'scope':manifest['scope'],
       'manifest_sha256':hashlib.sha256(args.manifest.read_bytes()).hexdigest(),'rows':rows},indent=2)+'\n',encoding='utf-8')

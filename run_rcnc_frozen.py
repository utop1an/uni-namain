"""Execute a frozen prospective development-variant bundle."""
import argparse
import json
from pathlib import Path
from rcnc.protocol import verify_bundle,digest,ROOT
from rcnc.lifting import run_lifted_query


def run_bundle(folder,output):
    manifest,lock=verify_bundle(folder)
    output.mkdir(parents=True,exist_ok=True)
    if any(output.iterdir()):raise ValueError('Use an empty run directory')
    (output/'freeze.json').write_text(json.dumps(lock,indent=2)+'\n',encoding='utf-8')
    rows=[]
    for name in manifest['tasks']:
        query=json.loads((folder/name).read_text(encoding='utf-8'))
        result=run_lifted_query(query,ROOT/'data/narra-domains',output/Path(name).stem)
        best=result.get('best') or {}
        row={'task':name,'split':query['evaluation_split'],'status':result['status'],
             'plan_length':best.get('plan_length'),'assignments':len(result.get('attempts',[])),
             'solved_assignments':sum(a['status']=='solved' for a in result.get('attempts',[])),
             'source_necessity':result.get('source_necessity_across_assignments',[]),
             'reason':result.get('reason')}
        rows.append(row);print(json.dumps(row),flush=True)
        (output/'progress.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8')
    verify_bundle(folder)
    summary={'scope':manifest['scope'],'freeze_sha256':digest(folder/'freeze.json'),'rows':rows}
    (output/'summary.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
    return summary

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--bundle',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();run_bundle(args.bundle,args.output)

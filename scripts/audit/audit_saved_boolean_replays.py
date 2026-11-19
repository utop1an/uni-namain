"""Offline physical checks of saved replay inputs; no planning or model calls."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path

from rcnc.domain_building import digest, save
from rcnc.revised_probe_validation import replay_physical


def windows_path(value):
    if not value.startswith('/mnt/') or len(value)<8:raise ValueError('Unknown saved path')
    return Path(value[5].upper()+':/'+value[7:])


def audit(root,output):
    if output.exists():raise ValueError('Fresh output required')
    rows=[];hashes={};engine=Path('rcnc/revised_probe_validation.py')
    hashes[str(engine)]=digest(engine);hashes[str(Path(__file__))]=digest(Path(__file__))
    for inv_path in sorted((root/'execution').rglob('invocation.json')):
        inv=json.loads(inv_path.read_text(encoding='utf-8'))
        if inv['mode']!='replay':continue
        result_path=inv_path.parent/'result.json'
        if not result_path.exists():raise ValueError('Incomplete execution')
        native=json.loads(result_path.read_text(encoding='utf-8'))
        for p,h in inv['input_sha256'].items():
            if digest(Path(p))!=h:raise ValueError('Frozen runtime input changed: '+p)
            hashes[p]=h
        hashes[str(inv_path)]=digest(inv_path);hashes[str(result_path)]=digest(result_path)
        domain,problem,plan=map(windows_path,inv['command'][-3:])
        category='native' if 'native' in inv_path.parts else ('transport' if inv_path.parent.name=='transport' else 'returned_plan')
        try:
            physical=replay_physical(domain,problem,plan)
            checked='valid_goal_plan' if physical['status']=='replayed' and physical['goal'] else physical['status']
        except (ValueError,KeyError,TypeError) as exc:
            physical={'status':'unsupported_or_invalid','reason':str(exc)};checked='unsupported_or_invalid'
        rows.append({'invocation':str(inv_path),'category':category,'native_status':native['status'],
                     'physical_status':checked,'physical':physical})
    output.mkdir(parents=True)
    counts={cat:dict(Counter(x['physical_status'] for x in rows if x['category']==cat)) for cat in sorted({x['category'] for x in rows})}
    report={'status':'complete','created_utc':datetime.now(timezone.utc).isoformat(),'run':str(root),'rows':rows,
        'total':len(rows),'counts':counts,'input_sha256':hashes,
        'inputs_unchanged':all(digest(Path(p))==h for p,h in hashes.items()),'search_calls':0,'model_calls':0,
        'scope':'Saved physical transitions and goals only. No intention explanation, semantic labels, exhaustive domain proof, or corrected-runtime search outcomes.'}
    save(output/'report.json',report)
    return {k:v for k,v in report.items() if k not in ('rows','input_sha256')}


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--run',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();print(json.dumps(audit(a.run,a.output),indent=2))

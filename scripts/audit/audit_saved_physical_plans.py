"""Audit saved physical plans, excluding axioms and preserving unsupported rows."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path

from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.saved_plan_validation import replay_saved
from scripts.audit.audit_saved_boolean_replays import windows_path


def audit(root,output):
    if output.exists():raise ValueError('Fresh output required')
    output.mkdir(parents=True);rows=[];hashes={}
    implementation=snapshot_implementation(output,[Path(__file__),Path('rcnc/saved_plan_validation.py'),
        Path('rcnc/revised_probe_validation.py'),Path('rcnc/pddl.py'),Path('scripts/audit/audit_saved_boolean_replays.py')])
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
            physical=replay_saved(domain,problem,plan)
            checked=physical['status']
            if checked=='replayed':checked='valid_goal_plan' if physical['goal'] else 'goal_not_reached'
        except (ValueError,KeyError,TypeError) as exc:
            physical={'status':'unsupported_or_invalid','reason':str(exc)};checked='unsupported_or_invalid'
        rows.append({'invocation':str(inv_path),'category':category,'native_status':native['status'],
                     'physical_status':checked,'physical':physical})
    counts={cat:dict(Counter(x['physical_status'] for x in rows if x['category']==cat)) for cat in sorted({x['category'] for x in rows})}
    report={'status':'complete','created_utc':datetime.now(timezone.utc).isoformat(),'run':str(root),'rows':rows,
        'total':len(rows),'counts':counts,'input_sha256':hashes,'implementation_sha256':implementation,
        'inputs_unchanged':all(digest(Path(p))==h for p,h in hashes.items()),'search_calls':0,'model_calls':0,
        'scope':'Saved finite physical transitions/goals only, with CWA explicit negatives. Axioms are unsupported. No intention explanation, semantic labels, exhaustive domain proof, or corrected-runtime search outcomes.'}
    save(output/'report.json',report)
    return {k:v for k,v in report.items() if k not in ('rows','input_sha256','implementation_sha256')}


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--run',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();print(json.dumps(audit(a.run,a.output),indent=2))

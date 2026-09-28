"""Audit every source action; parser acceptance is not semantic correctness."""
import argparse
import hashlib
import json
from collections import Counter
from pathlib import Path
from merge_domains import parse_domain
from rcnc.selection import audit_action


def run_audit(input_dir,output):
    output.mkdir(parents=True,exist_ok=True)
    if any(output.iterdir()):raise ValueError('Use an empty audit directory')
    rows=[]
    for path in sorted(input_dir.glob('*_domainfile.pddl')):
        domain=parse_domain(path,apply_reviewed_semantics=False)
        actions=[{'action':name,'issues':audit_action(domain,action)} for name,action in domain.actions.items()]
        independent={}
        try:
            import unified_planning
            from unified_planning.io import PDDLReader
            PDDLReader().parse_problem(str(path),str(path.with_name(path.name.replace('_domainfile','_problemfile'))))
            independent={'status':'PARSED','version':unified_planning.__version__}
        except ImportError as exc:independent={'status':'UNAVAILABLE','reason':str(exc)}
        except Exception as exc:independent={'status':'ERROR','reason':f'{type(exc).__name__}: {exc}'}
        rows.append({'source':path.stem.removesuffix('_domainfile'),'source_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
                     'action_count':len(actions),'actions':actions,'independent_problem_parse':independent})
    summary={'scope':'Syntactic/type/STRIPS-subset audit and independent source problem parsing; no semantic truth or solvability claim.',
             'domains':len(rows),'actions':sum(r['action_count'] for r in rows),
             'actions_with_issues':sum(bool(a['issues']) for r in rows for a in r['actions']),
             'issue_counts':dict(Counter(x for r in rows for a in r['actions'] for x in a['issues'])),
             'parse_counts':dict(Counter(r['independent_problem_parse']['status'] for r in rows)), 'rows':rows}
    (output/'audit.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
    return summary

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--input',type=Path,default=Path('data/narra-domains'));p.add_argument('--output',type=Path,required=True)
    args=p.parse_args();r=run_audit(args.input,args.output);print(json.dumps({k:v for k,v in r.items() if k!='rows'},indent=2))

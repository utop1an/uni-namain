"""Generate task-blind automatic semantic hypotheses from local PDDL."""
import argparse,json
from pathlib import Path
from rcnc.semantic_proposals import run_proposals
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--sources',nargs='+',required=True);p.add_argument('--output',type=Path,required=True)
 p.add_argument('--input',type=Path,default=Path('data/narra-domains'));p.add_argument('--model',default='gemma3:4b')
 p.add_argument('--kind',choices=['parameter','interface','role'])
 p.add_argument('--url',default='http://localhost:11434');p.add_argument('--response',type=Path)
 a=p.parse_args();r=run_proposals(a.input,a.sources,a.output,a.model,a.url,a.response,a.kind)
 print(json.dumps({k:v for k,v in r.items() if k!='checked'},indent=2));raise SystemExit(0 if r['status']=='completed' else 1)

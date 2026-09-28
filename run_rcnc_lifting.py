"""Run constrained constant lifting with global identity and independent validation."""
import argparse
import json
from pathlib import Path
from rcnc.lifting import run_lifted_query
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--query',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    p.add_argument('--input',type=Path,default=Path('data/narra-domains'))
    args=p.parse_args();r=run_lifted_query(json.loads(args.query.read_text(encoding='utf-8-sig')),args.input,args.output)
    print(json.dumps(r,indent=2));raise SystemExit(0 if r['status']=='solved' else 1)

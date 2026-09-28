"""Execute an explicit fixed-initial-state RCNC query."""
import argparse
import json
from pathlib import Path
from rcnc.planning import run_query

if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--query', type=Path, required=True)
    p.add_argument('--input', type=Path, default=Path('data/narra-domains'))
    p.add_argument('--output', type=Path, required=True)
    args = p.parse_args()
    result = run_query(json.loads(args.query.read_text(encoding='utf-8')), args.input, args.output)
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result['status']=='solved' else 1)

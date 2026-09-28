"""Judge bounded cross-source predicate pairs using local action contexts."""
import argparse
import json
from pathlib import Path
from rcnc.interface_proposals import run_interfaces

if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--sources', nargs='+', required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--input', type=Path, default=Path('data/narra-domains'))
    p.add_argument('--model', default='gemma3:4b')
    p.add_argument('--url', default='http://localhost:11434')
    p.add_argument('--max-pairs', type=int, default=12)
    p.add_argument('--replay-dir', type=Path)
    a = p.parse_args()
    result = run_interfaces(a.input, a.sources, a.output, a.model, a.url, a.max_pairs, a.replay_dir)
    print(json.dumps({k:v for k,v in result.items() if k != 'rows'}, indent=2))
    raise SystemExit(0 if result['status'] == 'completed' else 1)

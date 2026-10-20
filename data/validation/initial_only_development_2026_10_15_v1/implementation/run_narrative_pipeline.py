"""Run an explicit initial-state/goal request in a pre-search merged domain."""
import argparse
import json
from pathlib import Path
import traceback

from rcnc.narrative_pipeline import run, save


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--input', type=Path, default=Path('data/narra-domains'))
    p.add_argument('--query', type=Path)
    p.add_argument('--alignment', type=Path, help='Optional explicit, versioned alignment assumptions')
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--worker', action='store_true', help=argparse.SUPPRESS)
    p.add_argument('--domain', type=Path, help=argparse.SUPPRESS)
    p.add_argument('--problem', type=Path, help=argparse.SUPPRESS)
    p.add_argument('--budget', help=argparse.SUPPRESS)
    p.add_argument('--solver', choices=['typed_cartesian', 'pyperplan'], default='typed_cartesian', help=argparse.SUPPRESS)
    p.add_argument('--mode', choices=['initial_goal', 'initial_only'], default='initial_goal', help=argparse.SUPPRESS)
    a = p.parse_args()
    if a.worker:
        from rcnc.merged_planning import solve
        a.output.mkdir(parents=True, exist_ok=True)
        try:
            if a.mode == 'initial_only':
                from rcnc.outcome_planning import explore
                result = explore(a.domain, a.problem, a.output, **json.loads(a.budget))
            elif a.solver == 'pyperplan':
                from rcnc.heuristic_planning import solve as heuristic_solve
                result = heuristic_solve(a.domain, a.problem, a.output)
            else:
                result = solve(a.domain, a.problem, a.output, **json.loads(a.budget))
        except Exception as exc:
            traceback.print_exc()
            result = {'status': 'error', 'reason': f'{type(exc).__name__}: {exc}'}
        save(a.output / 'search.json', result)
    else:
        if a.query is None:
            p.error('--query is required')
        query = json.loads(a.query.read_text(encoding='utf-8'))
        if a.alignment:
            if 'alignment' in query:
                p.error('Specify alignment in the query or with --alignment, not both')
            query['alignment'] = json.loads(a.alignment.read_text(encoding='utf-8'))
        result = run(query, a.input, a.output)
        print(json.dumps(result, indent=2))
        raise SystemExit(0 if result['status'] in ('solved', 'outcomes_generated') else 1)

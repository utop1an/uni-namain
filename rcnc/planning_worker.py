"""Isolated solver dispatch and search report handling for request workers."""
import json
import traceback

from .domain_building import save


def run_worker(a):
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

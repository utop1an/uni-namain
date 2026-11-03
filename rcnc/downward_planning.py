"""Explicit-request adapter for the frozen Fast Downward 26.6 reference runner."""
from pathlib import Path

from rcnc.domain_building import require_empty_output, save
from scripts.experiments.run_downward_reference import run as run_reference, sha


def solve(domain, problem, output, planner, seconds=20, memory_mb=4096):
    """Search the exact exported request; preserve reference statuses and plans."""
    domain, problem, output, planner = map(Path, (domain, problem, output, planner))
    if type(seconds) is not int or seconds < 1 or type(memory_mb) is not int or memory_mb < 64:
        raise ValueError('Fast Downward requires integer seconds and memory_mb >= 64')
    require_empty_output(output)
    output.mkdir(parents=True, exist_ok=True)
    bundle = output / 'task_bundle'
    task = bundle / 'tasks/query'
    task.mkdir(parents=True)
    (task / 'domain.pddl').write_bytes(domain.read_bytes())
    (task / 'problem.pddl').write_bytes(problem.read_bytes())
    frozen_domain, frozen_problem = sha(task / 'domain.pddl'), sha(task / 'problem.pddl')
    manifest = {'status': 'frozen_before_search', 'mode': 'matched_source_representations',
        'task_count': 1, 'tasks': [{'id': 'query', 'source': 'explicit_request',
            'representation': 'supplied_parameterized_domain',
            'domain_sha256': frozen_domain, 'problem_sha256': frozen_problem}],
        'budget': {'wall_seconds': seconds, 'overall_cpu_seconds': seconds, 'memory_mb': memory_mb, 'workers': 1},
        'source_problem_facts_imported': False,
        'scope': 'Exact supplied planning domain/problem; no model repair, new facts or inferred goal'}
    save(bundle / 'manifest.json', manifest)
    report = run_reference(Path('.'), None, output / 'solver', planner,
                           seconds, memory_mb, task_bundle=bundle)
    if report['status'] != 'complete' or len(report['rows']) != 1 or report['rows'][0]['id'] != 'query':
        raise ValueError('Incomplete single-request solver evidence')
    row = report['rows'][0]
    integrity = {'binary_unchanged': report['binary_unchanged'], 'runner_unchanged': report['runner_unchanged'],
        'implementation_unchanged': report.get('implementation_unchanged') is True,
        'validator_unchanged': report.get('validator_unchanged') is True,
        'inputs_unchanged': row['inputs_unchanged'] and sha(domain) == frozen_domain and sha(problem) == frozen_problem}
    unchanged = all(integrity.values())
    directory = output / 'solver/tasks/query'
    for name in ('domain.pddl', 'problem.pddl', 'plan.txt'):
        path = directory / name
        if path.is_file():
            (output / name).write_bytes(path.read_bytes())
    return {'status': row['status'] if unchanged else 'artifact_changed',
        'solver': 'Fast Downward 26.6 lama-first', 'length': row.get('plan_length'),
        'validation': row.get('validation', {}), 'engine_status': row.get('engine_status'),
        'exit_code': row.get('exit_code'), 'elapsed_seconds': row['elapsed_seconds'],
        'inputs_unchanged': unchanged, 'budget': manifest['budget'],
        'integrity_checks': integrity,
        'solver_report_sha256': sha(output / 'solver/report.json'),
        'scope': manifest['scope']}

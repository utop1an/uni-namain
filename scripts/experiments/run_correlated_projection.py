"""Pre-search frozen paired projection strategies on all24 known PDDL inputs."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import subprocess
import sys
import time

from rcnc.domain_building import digest, save, snapshot_implementation
from scripts.experiments.run_state_projection_diagnostic import prepare as prepare_inputs


VARIANTS = ('cartesian_projection', 'positive_tuple_join')
STRATEGIES = {'correlated_parameter_tuples':VARIANTS,
              'precondition_witness_representatives':('cartesian_projection', 'precondition_witness')}


def expand_tasks(tasks, strategy_field='correlated_parameter_tuples'):
    if strategy_field not in STRATEGIES: raise ValueError('Unknown registered binding strategy')
    variants = STRATEGIES[strategy_field]
    if len(tasks) != 24 or len({r['id'] for r in tasks}) != 24 or len({r['pair_id'] for r in tasks}) != 6:
        raise ValueError('All24 input conditions and six known generated worlds required')
    expected = {('full', 'aligned_selected_sources'), ('full', 'zero_merge_same_source_action_sets'),
                ('recompiled', 'aligned_selected_recompiled'), ('recompiled', 'zero_merge_selected_recompiled')}
    if any({(r['cohort'], r['condition']) for r in tasks if r['pair_id'] == pair} != expected
           or sum(r['pair_id'] == pair for r in tasks) != 4 for pair in {r['pair_id'] for r in tasks}):
        raise ValueError('Each world requires all four exact PDDL conditions')
    result = []
    for index, task in enumerate(tasks):
        order = variants if index % 2 == 0 else variants[::-1]
        for variant in order:
            result.append({**task, 'input_id': task['id'], 'id': task['id'] + '__' + variant,
                           'variant': variant, strategy_field: variant == variants[1]})
    return result


def prepare(protocol_path, output):
    protocol = json.loads(protocol_path.read_text(encoding='utf-8'))
    field = protocol.get('strategy_field', 'correlated_parameter_tuples')
    if field not in STRATEGIES: raise ValueError('Unknown registered binding strategy')
    if (protocol['variants'] != list(STRATEGIES[field]) or protocol['budget']['workers'] != 1
            or protocol['budget']['search'].get('inert_parameter_representatives', False)
            or field in protocol['budget']['search']
            or any(protocol['budget']['search'].get(other, False) for other in STRATEGIES if other != field)):
        raise ValueError('Only one registered strategy switch may vary; one worker and complete bindings required')
    base = prepare_inputs(protocol_path, output)
    save(output / 'input_registry.json', base)
    tasks = expand_tasks(base['tasks'], field)
    implementation = {**base['implementation_sha256'], **snapshot_implementation(output, [Path(__file__)])}
    manifest = {**base, 'task_count': len(tasks), 'tasks': tasks,
        'world_count': 6, 'unique_pddl_inputs': 24, 'variants': list(STRATEGIES[field]), 'strategy_field':field,
        'registered_protocol':str(protocol_path.resolve()),
        'input_registry_sha256': digest(output / 'input_registry.json'),
        'implementation_sha256': implementation}
    save(output / 'manifest.json', manifest)
    return manifest


def execute(output):
    manifest = json.loads((output / 'manifest.json').read_text(encoding='utf-8'))
    if manifest['status'] != 'frozen_before_search' or (output / 'report.json').exists() or (output / 'searches').exists():
        raise ValueError('Only a fresh complete paired registry can execute')
    base = json.loads((output / 'input_registry.json').read_text(encoding='utf-8'))
    field = manifest.get('strategy_field', 'correlated_parameter_tuples')
    if field not in STRATEGIES: raise ValueError('Unknown registered binding strategy')
    variants = STRATEGIES[field]
    protocol = json.loads((output / 'protocol.json').read_text(encoding='utf-8'))
    if (manifest['budget'] != protocol['budget'] or manifest.get('scope') != protocol['scope']
            or protocol.get('strategy_field', 'correlated_parameter_tuples') != field
            or protocol['variants'] != list(variants)
            or manifest.get('variants', list(variants)) != list(variants)):
        raise ValueError('Registered strategy, budget or scope differs before search')
    if manifest.get('registered_protocol') and digest(Path(manifest['registered_protocol'])) != manifest['protocol_sha256']:
        raise ValueError('External registered protocol changed')
    if (digest(output / 'input_registry.json') != manifest['input_registry_sha256']
            or manifest['tasks'] != expand_tasks(base['tasks'], field) or manifest['task_count'] != 48):
        raise ValueError('Paired slot registry differs')
    if digest(output / 'protocol.json') != manifest['protocol_sha256']:
        raise ValueError('Frozen protocol changed')
    for name, expected in manifest['implementation_sha256'].items():
        if digest(Path(name)) != expected: raise ValueError('Frozen implementation changed')
    for task in manifest['tasks']:
        for name in ('domain', 'problem'):
            if digest(output / 'tasks' / task['input_id'] / (name + '.pddl')) != task[name + '_sha256']:
                raise ValueError('Frozen input changed')
    budget = manifest['budget']
    deadline = datetime.fromisoformat(budget['whole_goal_stop_before_utc'].replace('Z', '+00:00'))
    if deadline.tzinfo is None: raise ValueError('Explicit deadline timezone required')
    enough = (deadline - datetime.now(timezone.utc)).total_seconds() >= 48 * budget['wall_seconds_per_process'] + 600
    rows = []
    if enough:
        for task in manifest['tasks']:
            source = output / 'tasks' / task['input_id']
            target = output / 'searches' / task['id']; target.mkdir(parents=True)
            search_budget = {**budget['search'], field:task[field]}
            command = [sys.executable, '-X', 'utf8', '-m', 'rcnc', 'plan', '--worker', '--solver', 'state_projected',
                '--domain', str(source / 'domain.pddl'), '--problem', str(source / 'problem.pddl'),
                '--output', str(target), '--budget', json.dumps(search_budget)]
            save(target / 'command.json', command)
            start = time.monotonic()
            with (target / 'worker.log').open('w', encoding='utf-8') as log:
                try:
                    child = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT,
                                           timeout=budget['wall_seconds_per_process'])
                    path = target / 'search.json'
                    search = json.loads(path.read_text(encoding='utf-8')) if path.exists() else {'status': 'worker_error'}
                    search['worker_exit_code'] = child.returncode
                except subprocess.TimeoutExpired:
                    search = {'status': 'time_limit'}
                    if (target / 'progress.json').exists():
                        search['last_progress'] = json.loads((target / 'progress.json').read_text(encoding='utf-8'))
                except Exception as exc:
                    search = {'status': 'worker_error', 'reason': f'{type(exc).__name__}: {exc}'}
            rows.append({**task, **search, 'elapsed_seconds': round(time.monotonic() - start, 3)})
            save(output / 'progress.json', {'completed': len(rows), 'task_count': 48, 'rows': rows})
    else:
        rows = [{**task, 'status': 'not_run_due_goal_budget'} for task in manifest['tasks']]
    report = {'status': 'complete', 'task_count': len(rows), 'world_count': 6, 'unique_pddl_inputs': 24,
        'actual_search_processes': len(rows) if enough else 0, 'rows': rows,
        'status_counts': dict(Counter(row['status'] for row in rows)),
        'by_variant': {variant: dict(Counter(r['status'] for r in rows if r['variant'] == variant)) for variant in variants},
        'strategy_field':field,
        'manifest_sha256': digest(output / 'manifest.json'),
        'inputs_unchanged': all(digest(output / 'tasks' / r['input_id'] / (n + '.pddl')) == r[n + '_sha256']
                               for r in rows for n in ('domain', 'problem')),
        'implementation_unchanged': all(digest(Path(n)) == h for n,h in manifest['implementation_sha256'].items()),
        'scope': manifest['scope']}
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--protocol', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--execute-frozen', action='store_true')
    args = parser.parse_args()
    result = execute(args.output) if args.execute_frozen else prepare(args.protocol, args.output)
    print(json.dumps({k:v for k,v in result.items() if k not in ('rows', 'tasks', 'implementation_sha256')}, indent=2))

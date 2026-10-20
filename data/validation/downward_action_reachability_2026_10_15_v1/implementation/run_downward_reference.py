"""Fast Downward 26.6 via existing WSL, with immutable tasks and UP validation."""
import argparse
import ast
from collections import Counter
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import time

from rcnc.validation import validate_artifacts


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(path, value):
    path.write_text(json.dumps(value, indent=2)+'\n', encoding='utf-8')


def linux_path(path):
    path = Path(path).resolve()
    if not path.drive or len(path.drive) != 2:
        raise ValueError('Requires a local Windows drive path accessible under /mnt')
    return '/mnt/'+path.drive[0].lower()+'/'+path.as_posix()[3:]


def exit_status(code):
    # Verified against release 26.6 driver/returncodes.py. 13 is bounded only.
    return {0: 'plan_found', 1: 'plan_found_memory_limit', 2: 'plan_found_time_limit',
            3: 'plan_found_memory_time_limit', 10: 'unsolvable', 11: 'unsolvable',
            12: 'incomplete', 13: 'unsolvable_within_bound', 20: 'memory_limit',
            21: 'time_limit', 22: 'memory_limit', 23: 'time_limit', 24: 'memory_time_limit',
            31: 'input_error', 33: 'input_error', 34: 'unsupported', 36: 'input_error',
            37: 'unsupported', 124: 'wall_time_limit', 137: 'resource_killed'}.get(code, 'engine_error')


def freeze(inputs, composed, output, planner, seconds, memory_mb, probes=None, task_bundle=None):
    if type(seconds) is not int or seconds < 1 or type(memory_mb) is not int or memory_mb < 64:
        raise ValueError('Invalid resource budgets')
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    binary = planner/'builds/release/bin/downward'
    if not binary.is_file():
        raise ValueError('Planner release binary is not built')
    version_file = planner/'driver/version.py'
    version = next((ast.literal_eval(node.value) for node in ast.parse(version_file.read_text(encoding='utf-8')).body
                    if isinstance(node, ast.Assign) and any(isinstance(target, ast.Name) and target.id == '__version__' for target in node.targets)), None)
    if version != '26.6':
        raise ValueError('Exit-code mapping is verified only for Fast Downward 26.6')
    if sum(bool(x) for x in (composed, probes, task_bundle)) > 1:
        raise ValueError('Choose one task bundle mode')
    tasks = []
    if task_bundle:
        bundle = json.loads((task_bundle/'manifest.json').read_text(encoding='utf-8'))
        if bundle['status'] != 'frozen_before_search' or bundle['mode'] not in ('source_action_removal', 'external_source_preservation', 'source_action_reachability'):
            raise ValueError('Expected a supported frozen task bundle')
        if bundle['task_count'] != len(bundle['tasks']) or len({t['id'] for t in bundle['tasks']}) != bundle['task_count']:
            raise ValueError('Incomplete or duplicate bundle tasks')
        for task in bundle['tasks']:
            directory = task_bundle/'tasks'/task['id']
            domain, problem = directory/'domain.pddl', directory/'problem.pddl'
            if sha(domain) != task['domain_sha256'] or sha(problem) != task['problem_sha256']:
                raise ValueError('Frozen action-removal task changed: '+task['id'])
            fields = ('world', 'method', 'removed_source', 'origin_id') if bundle['mode'] == 'source_action_removal' else ('family', 'problem_id', 'representation')
            if bundle['mode'] == 'source_action_reachability':
                fields = ('source', 'target_action')
            tasks.append({'id': task['id'], 'domain': domain, 'problem': problem,
                          'condition': {k: task[k] for k in fields}})
    elif probes:
        frozen_probes = json.loads((probes/'manifest.json').read_text(encoding='utf-8'))
        if frozen_probes['status'] != 'frozen_before_search':
            raise ValueError('Probe bundle is not frozen')
        for task in frozen_probes['tasks']:
            directory = probes/'tasks'/task['id']
            domain, problem = directory/'domain.pddl', directory/'problem.pddl'
            if sha(domain) != task['domain_sha256'] or sha(problem) != task['problem_sha256']:
                raise ValueError('Frozen probe changed: '+task['id'])
            tasks.append({'id': task['id'], 'domain': domain, 'problem': problem,
                          'condition': {'source': task['source'], 'goal': task['goal']}})
    elif composed:
        report = json.loads((composed/'report.json').read_text(encoding='utf-8'))
        frozen = json.loads((composed/'frozen_tasks.json').read_text(encoding='utf-8'))
        if report['status'] != 'complete' or report['frozen_tasks_sha256'] != sha(composed/'frozen_tasks.json'):
            raise ValueError('Composed run must be complete with unchanged frozen tasks')
        for task in frozen['tasks']:
            run = composed/'runs'/task['id']
            previous = json.loads((run/'manifest.json').read_text(encoding='utf-8'))
            domain, problem = run/'union/meta_domain.pddl', run/'mapped_problem.pddl'
            if sha(domain) != previous['domain_sha256'] or sha(problem) != previous['problem_sha256']:
                raise ValueError('Prior exported model changed: '+task['id'])
            tasks.append({'id': task['id'], 'domain': domain, 'problem': problem,
                          'condition': {k: task[k] for k in ('world', 'method', 'policy')}})
    else:
        for domain in sorted(inputs.glob('*_domainfile.pddl')):
            source = domain.name.removesuffix('_domainfile.pddl')
            tasks.append({'id': source, 'domain': domain, 'problem': inputs/(source+'_problemfile.pddl'), 'condition': {'source': source}})
    if not tasks:
        raise ValueError('No input tasks')
    output.mkdir(parents=True)
    implementation = output/'implementation'
    implementation.mkdir()
    for path in (Path(__file__), Path(__file__).parent/'rcnc/validation.py'):
        (implementation/path.name).write_bytes(path.read_bytes())
    rows = []
    for task in tasks:
        directory = output/'tasks'/task['id']
        directory.mkdir(parents=True)
        for kind in ('domain', 'problem'):
            shutil.copyfile(task[kind], directory/(kind+'.pddl'))
        rows.append({'id': task['id'], **task['condition'],
                     'domain_sha256': sha(directory/'domain.pddl'), 'problem_sha256': sha(directory/'problem.pddl')})
    manifest = {'status': 'frozen_before_search', 'planner': 'Fast Downward', 'release': '26.6', 'alias': 'lama-first',
        'binary_sha256': sha(binary), 'version_file_sha256': sha(version_file),
        'returncodes_sha256': sha(planner/'driver/returncodes.py'),
        'alias_sha256': sha(planner/'driver/aliases.py'), 'runner_sha256': sha(Path(__file__)),
        'budget': {'wall_seconds': seconds, 'overall_cpu_seconds': seconds, 'memory_mb': memory_mb},
        'tasks': rows, 'task_count': len(rows),
        'mode': bundle['mode'] if task_bundle else 'synthetic_source_effect_probes' if probes else 'same_exported_composed_tasks' if composed else 'original_source_tasks',
        'task_bundle_origin': str(task_bundle) if task_bundle else None,
        'task_bundle_manifest_sha256': sha(task_bundle/'manifest.json') if task_bundle else None,
        'composed_origin': str(composed) if composed else None,
        'probe_origin': str(probes) if probes else None,
        'probe_manifest_sha256': sha(probes/'manifest.json') if probes else None,
        'scope': 'Solver reference coverage; no model repair or semantic/narrative quality claim',
        'timing_caveat': 'Concurrent workstation workloads; descriptive wall times only'}
    save(output/'manifest.json', manifest)
    return manifest


def run(inputs, composed, output, planner, seconds=60, memory_mb=4096, probes=None, task_bundle=None):
    manifest = freeze(inputs, composed, output, planner, seconds, memory_mb, probes, task_bundle)
    report = {'status': 'running', 'task_count': manifest['task_count'], 'manifest_sha256': sha(output/'manifest.json'), 'rows': []}
    save(output/'report.json', report)
    for task in manifest['tasks']:
        directory = output/'tasks'/task['id']
        command = ['wsl', '-d', 'Ubuntu', '--cd', linux_path(directory), '--',
            'timeout', '--signal=TERM', '--kill-after=5', str(seconds), 'python3', linux_path(planner/'fast-downward.py'),
            '--alias', 'lama-first', '--overall-time-limit', str(seconds)+'s',
            '--overall-memory-limit', str(memory_mb)+'M', '--plan-file', 'plan.txt', 'domain.pddl', 'problem.pddl']
        save(directory/'command.json', command)
        row = {'id': task['id']}
        start = time.monotonic()
        try:
            with (directory/'planner.log').open('w', encoding='utf-8') as log:
                process = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, timeout=seconds+30)
            row.update(exit_code=process.returncode, engine_status=exit_status(process.returncode))
            row['status'] = row['engine_status']
            if (directory/'plan.txt').exists():
                row['validation'] = validate_artifacts(directory)
                row['status'] = 'solved' if row['validation']['status'] == 'VALID' else 'invalid_plan'
                row['plan_length'] = sum(bool(line.strip()) and not line.lstrip().startswith(';') for line in
                                         (directory/'plan.txt').read_text(encoding='utf-8').splitlines())
            elif row['engine_status'].startswith('plan_found'):
                row['status'] = 'missing_plan_artifact'
        except subprocess.TimeoutExpired:
            row.update(status='wsl_observation_timeout', note='Linux timeout owns the process-group deadline; no rerun started')
        except Exception as exc:
            row.update(status='error', error=f'{type(exc).__name__}: {exc}')
        row.update(elapsed_seconds=round(time.monotonic()-start, 3),
                   inputs_unchanged=sha(directory/'domain.pddl') == task['domain_sha256'] and sha(directory/'problem.pddl') == task['problem_sha256'])
        report['rows'].append(row)
        report['status_counts'] = dict(Counter(r['status'] for r in report['rows']))
        save(output/'report.json', report)
        print(json.dumps(row), flush=True)
    report.update(status='complete', binary_unchanged=sha(planner/'builds/release/bin/downward') == manifest['binary_sha256'],
                  runner_unchanged=sha(Path(__file__)) == manifest['runner_sha256'])
    save(output/'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inputs', type=Path, default=Path('data/narra-domains'))
    parser.add_argument('--composed', type=Path)
    parser.add_argument('--probes', type=Path)
    parser.add_argument('--task-bundle', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--planner', type=Path, default=Path('.tmp/fast-downward-26.6'))
    parser.add_argument('--seconds', type=int, default=60)
    parser.add_argument('--memory-mb', type=int, default=4096)
    args = parser.parse_args()
    result = run(args.inputs, args.composed, args.output, args.planner, args.seconds, args.memory_mb, args.probes, args.task_bundle)
    print(json.dumps({k: v for k, v in result.items() if k != 'rows'}, indent=2))

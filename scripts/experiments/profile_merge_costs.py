"""Serial development cost control: fresh builds, translation, then SAS search.

Build timing is a Windows Python process; translation/search use WSL GNU time.
These memory measures must not be added or treated as one homogeneous peak.
"""
import argparse
from collections import Counter
import ctypes
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re
import shutil
import statistics
import subprocess
import sys
import time

from rcnc.conditional_merge import build
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.validation import validate_artifacts
from scripts.experiments.run_role_contract_merge import code_paths, read
from scripts.experiments.run_downward_reference import linux_path, exit_status

CONDITIONS = ('no_share', 'predicate090', 'full090')
CASES = {'transport': 'two_packages', 'clearance': 'two_packages', 'narrative': 'relocate_and_understand'}
PLANNER = Path('.tmp/fast-downward-26.6')


def windows_peak_kib():
    class Counters(ctypes.Structure):
        _fields_ = [('cb', ctypes.c_ulong), ('PageFaultCount', ctypes.c_ulong)] + [
            (name, ctypes.c_size_t) for name in ('PeakWorkingSetSize', 'WorkingSetSize', 'QuotaPeakPagedPoolUsage',
            'QuotaPagedPoolUsage', 'QuotaPeakNonPagedPoolUsage', 'QuotaNonPagedPoolUsage', 'PagefileUsage', 'PeakPagefileUsage')]
    value = Counters(); value.cb = ctypes.sizeof(value)
    current = ctypes.windll.kernel32.GetCurrentProcess
    current.restype = ctypes.c_void_p
    query = ctypes.windll.psapi.GetProcessMemoryInfo
    query.argtypes = [ctypes.c_void_p, ctypes.POINTER(Counters), ctypes.c_ulong]
    if not query(current(), ctypes.byref(value), value.cb):
        raise OSError('Cannot read Windows process memory counters')
    return value.PeakWorkingSetSize / 1024


def build_worker(model, inputs, output):
    specification = read(model / 'merge_specification.json')
    began, cpu = time.perf_counter(), time.process_time()
    result = build(inputs, output / 'compiled', specification, merge_actions=model.name.startswith('full'))
    measurement = {'status': 'complete', 'wall_seconds': time.perf_counter() - began,
        'cpu_seconds': time.process_time() - cpu, 'peak_working_set_kib': windows_peak_kib(),
        'domain_sha256': digest(output / 'compiled/meta_domain.pddl'),
        'reference_domain_sha256': digest(model / 'meta_domain.pddl'), 'counts': result['counts'],
        'scope': 'Build call wall/CPU time excludes imports; process-lifetime peak working set includes imports. Fresh process, filesystem/OS caches not flushed.'}
    measurement['same_domain'] = measurement['domain_sha256'] == measurement['reference_domain_sha256']
    save(output / 'build.json', measurement)
    return measurement


def prepare(primary, output):
    require_empty_output(output)
    if read(primary / 'report.json')['status'] != 'complete':
        raise ValueError('Completed preregistered primary planning run required')
    output.mkdir(parents=True)
    rows, pins = [], {}
    for repeat in range(3):
        for bundle, case in CASES.items():
            for condition in CONDITIONS[repeat:] + CONDITIONS[:repeat]:
                model = primary / 'models' / bundle / condition
                inputs = primary / 'bundle_inputs' / bundle
                problem = primary / 'bundle/tasks' / f'{bundle}__{case}__{condition}' / 'problem.pddl'
                row = {'id': f'r{repeat+1}_{bundle}_{condition}', 'repeat': repeat + 1, 'bundle': bundle,
                       'case': case, 'condition': condition, 'model': model.as_posix(), 'inputs': inputs.as_posix(),
                       'problem': problem.as_posix()}
                rows.append(row)
                for p in [model / 'merge_specification.json', model / 'meta_domain.pddl', problem, *inputs.glob('*.pddl')]:
                    pins[p.as_posix()] = digest(p)
    # Confirm predicate-only and full use identical correspondence input.
    for bundle in CASES:
        a, b = [read(primary / 'models' / bundle / c / 'merge_specification.json') for c in ('predicate090', 'full090')]
        if a != b: raise ValueError('Predicate/full correspondence input differs')
    for relative in ('fast-downward.py', 'driver/arguments.py', 'driver/aliases.py', 'driver/returncodes.py',
                     'driver/version.py', 'builds/release/bin/downward'):
        pins[(PLANNER / relative).as_posix()] = digest(PLANNER / relative)
    for p in [*(PLANNER / 'driver').rglob('*.py'), *(PLANNER / 'fast_downward').rglob('*.py'), *(PLANNER / 'builds/release/bin/fast_downward').rglob('*.py'), *(PLANNER / 'builds/release/bin/translate').rglob('*.py')]:
        pins[p.as_posix()] = digest(p)
    manifest = {'status': 'frozen_before_cost_execution', 'created_utc': datetime.now(timezone.utc).isoformat(),
        'task_count': 27, 'rows': rows, 'primary': primary.as_posix(), 'repeats': 3,
        'budgets': {'build_wall_seconds': 120, 'translation_seconds': 20, 'search_seconds': 20, 'memory_mb': 4096},
        'input_sha256': pins, 'implementation_sha256': snapshot_implementation(output, [*code_paths(), Path(__file__)]),
        'scope': 'Known authored worlds only, serial within campaign, three fresh processes per representation. No concurrent campaign tests/audits. OS cache/background services uncontrolled; descriptive paired costs, not formal unseen-scale speedup.',
        'memory_units': {'build': 'Windows process-lifetime peak working set KiB including imports',
                         'translation_search': 'GNU time maximum RSS KiB; largest process, not a sum over concurrent descendants'},
        'phase_definition': 'Translation includes PDDL parsing, normalization, grounding and SAS compilation. Search consumes only the saved SAS file; no repeated translation. Instantiation subtime/operator counts are additionally parsed from translator logs when reported.'}
    save(output / 'manifest.json', manifest)
    return {'status': manifest['status'], 'build_calls': 27, 'translation_calls_max': 27, 'search_calls_max': 27}


def timed_phase(folder, phase, budget):
    args = ['--translate', '--sas-file', 'output.sas', 'domain.pddl', 'problem.pddl'] if phase == 'translation' else ['--alias', 'lama-first', '--keep-sas-file', '--plan-file', 'plan.txt', 'output.sas']
    command = ['wsl', '-d', 'Ubuntu', '--cd', linux_path(folder), '--exec', '/usr/bin/time',
        '-f', 'wall_seconds=%e,user_seconds=%U,system_seconds=%S,max_rss_kib=%M', '-o', phase + '.time',
        'timeout', '--signal=TERM', '--kill-after=5', str(budget + 5), 'python3', linux_path(PLANNER / 'fast-downward.py'),
        '--overall-time-limit', str(budget) + 's', '--overall-memory-limit', '4096M', *args]
    save(folder / (phase + '.command.json'), command)
    with (folder / (phase + '.log')).open('w', encoding='utf-8') as log:
        result = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, timeout=budget + 40)
    metrics = {}
    path = folder / (phase + '.time')
    if path.exists():
        for line in path.read_text(encoding='utf-8').replace(',', '\n').splitlines():
            if '=' in line:
                key, value = line.split('=', 1)
                if key in ('wall_seconds', 'user_seconds', 'system_seconds', 'max_rss_kib'):
                    metrics[key] = float(value)
    metrics.update(exit_code=result.returncode, engine_status=exit_status(result.returncode))
    metrics.update(log_metrics((folder / (phase + '.log')).read_text(encoding='utf-8'), phase))
    return metrics


def log_metrics(text, phase):
    result = {}
    if phase == 'translation':
        match = re.search(r'^Instantiating: \[([\d.]+)s CPU, ([\d.]+)s wall-clock\]', text, re.M)
        if match:
            result.update(instantiation_cpu_seconds=float(match[1]), instantiation_wall_seconds=float(match[2]))
        for label in ('operators', 'variables', 'facts'):
            match = re.search(r'^Translator ' + label + r': (\d+)$', text, re.M)
            result['translator_' + label] = int(match[1]) if match else None
    else:
        for label, pattern in [('expanded_states', r'Expanded (\d+) state'), ('generated_states', r'Generated (\d+) state')]:
            match = re.search(pattern, text)
            result[label] = int(match[1]) if match else None
    return result


def execute(output):
    manifest = read(output / 'manifest.json')
    if (output / 'progress.json').exists(): raise ValueError('Fresh cost run only')
    for p, h in {**manifest['input_sha256'], **manifest['implementation_sha256']}.items():
        if digest(Path(p)) != h: raise ValueError('Frozen cost dependency changed: ' + p)
    rows = []
    save(output / 'progress.json', {'status': 'running', 'rows': rows})
    for task in manifest['rows']:
        folder = output / 'tasks' / task['id']; folder.mkdir(parents=True)
        row = {**task, 'status': 'not_started', 'translation': {'status': 'not_requested'}, 'search': {'status': 'not_requested'}}
        try:
            command = [sys.executable, '-X', 'utf8', '-m', 'scripts.experiments.profile_merge_costs', 'build-worker',
                '--output', str(folder), '--model', task['model'], '--inputs', task['inputs']]
            with (folder / 'build.log').open('w', encoding='utf-8') as log:
                process = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, timeout=120)
            row['build_exit_code'] = process.returncode
            if process.returncode != 0: raise ValueError('Build worker failed')
            row['build'] = read(folder / 'build.json')
            if not row['build']['same_domain']: raise ValueError('Fresh build differs from frozen reference domain')
            shutil.copyfile(folder / 'compiled/meta_domain.pddl', folder / 'domain.pddl')
            shutil.copyfile(task['problem'], folder / 'problem.pddl')
            row['translation'] = timed_phase(folder, 'translation', 20)
            row['status'] = 'translation_' + row['translation']['engine_status']
            if row['translation']['exit_code'] == 0 and (folder / 'output.sas').exists():
                sas = folder / 'output.sas'
                row['sas_sha256'], row['sas_bytes'] = digest(sas), sas.stat().st_size
                row['compiled_operators'] = sas.read_text(encoding='utf-8').splitlines().count('begin_operator')
                row['search'] = timed_phase(folder, 'search', 20)
                row['status'] = row['search']['engine_status']
                if digest(sas) != row['sas_sha256']: raise ValueError('Search modified frozen SAS input')
                if (folder / 'plan.txt').exists():
                    row['validation'] = validate_artifacts(folder)
                    row['status'] = 'solved' if row['validation']['status'] == 'VALID' else 'validation_failed'
            row['inputs_unchanged'] = digest(folder / 'problem.pddl') == digest(Path(task['problem'])) and digest(folder / 'domain.pddl') == row['build']['domain_sha256']
        except Exception as exc:
            row.update(status='error', reason=f'{type(exc).__name__}: {exc}')
        rows.append(row)
        save(output / 'progress.json', {'status': 'running', 'rows': rows})
        print(json.dumps({'id': row['id'], 'status': row['status']}), flush=True)
    summaries = []
    for bundle in CASES:
        for condition in CONDITIONS:
            group = [r for r in rows if r['bundle'] == bundle and r['condition'] == condition]
            values = {}
            for phase, field in [('build', 'wall_seconds'), ('build', 'peak_working_set_kib'),
                    ('translation', 'wall_seconds'), ('translation', 'instantiation_wall_seconds'), ('translation', 'max_rss_kib'), ('search', 'wall_seconds'), ('search', 'max_rss_kib')]:
                xs = [r.get(phase, {}).get(field) for r in group]
                xs = [x for x in xs if x is not None]
                values[phase + '/' + field] = {'n': len(xs), 'mean': statistics.mean(xs) if xs else None,
                    'sample_sd': statistics.stdev(xs) if len(xs) > 1 else None}
            summaries.append({'bundle': bundle, 'condition': condition, 'metrics': values,
                'compiled_operators': [r.get('compiled_operators') for r in group]})
    report = {'status': 'complete', 'task_count': len(rows), 'rows': rows, 'summaries': summaries,
        'status_counts': dict(Counter(r['status'] for r in rows)),
        'inputs_unchanged': all(digest(Path(p)) == h for p, h in manifest['input_sha256'].items()),
        'implementation_unchanged': all(digest(Path(p)) == h for p, h in manifest['implementation_sha256'].items()),
        'manifest_sha256': digest(output / 'manifest.json'), 'model_calls': 0,
        'search_calls': sum('exit_code' in r['search'] for r in rows), 'scope': manifest['scope']}
    save(output / 'report.json', report)
    return {k: v for k, v in report.items() if k not in ('rows', 'summaries')}


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('mode', choices=['prepare', 'execute', 'build-worker'])
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--primary', type=Path)
    p.add_argument('--model', type=Path)
    p.add_argument('--inputs', type=Path)
    args = p.parse_args()
    result = prepare(args.primary, args.output) if args.mode == 'prepare' else execute(args.output) if args.mode == 'execute' else build_worker(args.model, args.inputs, args.output)
    print(json.dumps(result, indent=2))

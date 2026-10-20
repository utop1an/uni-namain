"""Freeze and sample translator cases sequentially, separately from solver trials."""
import argparse
import json
from pathlib import Path
import subprocess
from rcnc.domain_building import require_empty_output, save
from scripts.experiments.run_downward_reference import sha, linux_path


def run(matched, selected, output, planner):
    report = json.loads((selected / 'solver/report.json').read_text(encoding='utf-8'))
    if report['status'] != 'complete':
        raise ValueError('Finish matched solver trials before diagnostic workloads')
    require_empty_output(output)
    output.mkdir(parents=True)
    cases = {
        'full_pool_CHIC_NP': matched / 'solver/tasks/CHIC_NP__machine_interfaces',
        'full_pool_ACCO': matched / 'solver/tasks/ACCO__machine_interfaces',
        'graph_closure_CHIC_NP': selected / 'solver/tasks/CHIC_NP__graph_closure_control',
        'world_selected_CHIC_NP': selected / 'solver/tasks/CHIC_NP__world_selected',
        'world_selected_HANS_NP': selected / 'solver/tasks/HANS_NP__world_selected'}
    sampler = Path('scripts/experiments/sample_downward_translation.py').resolve()
    tasks = []
    for key, origin in cases.items():
        directory = output / key
        directory.mkdir()
        for name in ('domain.pddl', 'problem.pddl'):
            (directory / name).write_bytes((origin / name).read_bytes())
        tasks.append({'id': key, 'origin': str(origin),
                      'domain_sha256': sha(directory / 'domain.pddl'),
                      'problem_sha256': sha(directory / 'problem.pddl')})
    frozen = {str(p): sha(p) for p in (sampler, Path(__file__), selected / 'solver/report.json')}
    for p in (planner / 'builds/release/bin/fast_downward/translate').rglob('*.py'):
        frozen[str(p)] = sha(p)
    manifest = {'status': 'frozen_before_sampling', 'tasks': tasks, 'frozen_sha256': frozen,
                'scope': '5 instrumented translator-only calls; never counted as planning trials',
                'seconds_per_diagnostic': 20, 'memory_mb': 4096, 'workers': 1}
    save(output / 'manifest.json', manifest)
    rows = []
    for task in tasks:
        directory = output / task['id']
        cmd = ['wsl', '-d', 'Ubuntu', '--cd', linux_path(directory.resolve()), '--',
               'timeout', '--signal=TERM', '--kill-after=2', '30', 'python3', linux_path(sampler),
               '--package-dir', linux_path((planner / 'builds/release/bin').resolve()),
               '--seconds', '20', '--output', 'sampling.json']
        result = subprocess.run(cmd, capture_output=True, timeout=40)
        (directory / 'translator.log').write_bytes(result.stdout + result.stderr)
        row = {'id': task['id'], 'exit_code': result.returncode,
               'sampling': json.loads((directory / 'sampling.json').read_text(encoding='utf-8'))
               if (directory / 'sampling.json').exists() else None}
        rows.append(row)
        save(output / 'progress.json', {'completed': len(rows), 'task_count': len(tasks)})
        print(json.dumps({'id': row['id'], 'exit_code': row['exit_code'],
                          'status': row['sampling']['status'] if row['sampling'] else 'missing_sample'}), flush=True)
    report = {'status': 'complete' if all(r['sampling'] for r in rows) else 'incomplete',
        'task_count': len(tasks), 'rows': rows, 'manifest_sha256': sha(output / 'manifest.json'),
        'hashes_unchanged': all(sha(Path(p)) == h for p, h in frozen.items()) and all(
            sha(output / t['id'] / (k + '.pddl')) == t[k + '_sha256'] for t in tasks for k in ('domain', 'problem')),
        'scope': manifest['scope']}
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('matched', 'selected', 'output'):
        parser.add_argument('--' + name, type=Path, required=True)
    parser.add_argument('--planner', type=Path, default=Path('.tmp/fast-downward-26.6'))
    args = parser.parse_args()
    run(args.matched, args.selected, args.output, args.planner)

"""Verify fresh paired selection trials and export complete comparison tables."""
import argparse
from collections import Counter
import csv
import json
from pathlib import Path
import re
from rcnc.domain_building import require_empty_output, save
from scripts.experiments.run_downward_reference import sha
from scripts.evidence.build_meeting_results import phase, RESOURCE_LIMITS


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def collect(root, historical):
    report = read(root / 'solver/report.json')
    manifest = read(root / 'solver/manifest.json')
    protocol = read(root / 'bundle/manifest.json')
    if report['manifest_sha256'] != sha(root / 'solver/manifest.json'):
        raise ValueError('Solver manifest drift')
    if report['status'] != 'complete' or not report['binary_unchanged'] or not report['runner_unchanged']:
        raise ValueError('Require complete unchanged solver trials')
    if manifest['budget'] != {'wall_seconds': 20, 'overall_cpu_seconds': 20, 'memory_mb': 4096}:
        raise ValueError('Budget drift')
    rows = {r['id']: r for r in report['rows']}
    if len(rows) != len(report['rows']) or set(rows) != {t['id'] for t in protocol['tasks']}:
        raise ValueError('Missing or duplicate trials')
    if dict(Counter(r['status'] for r in rows.values())) != report['status_counts']:
        raise ValueError('Status count mismatch')
    result = []
    for task in protocol['tasks']:
        row = rows[task['id']]
        directory = root / 'solver/tasks' / task['id']
        if not row['inputs_unchanged'] or any(sha(directory / (k + '.pddl')) != task[k + '_sha256']
                                             for k in ('domain', 'problem')):
            raise ValueError('Frozen task input drift')
        if row['status'] == 'solved' and row.get('validation', {}).get('status') != 'VALID':
            raise ValueError('Solved plan lacks validation')
        text = (directory / 'planner.log').read_text(encoding='utf-8', errors='replace')
        atoms = re.search(r'(\d+) relevant atoms', text)
        result.append({'source': task['source'], 'representation': task['representation'],
            'measurement_block': 'earlier_60_case_comparison' if historical else 'fresh_30_case_paired_selection',
            'status': row['status'], 'resource_limit': row['status'] in RESOURCE_LIMITS,
            'phase': phase(directory), 'elapsed_seconds': row['elapsed_seconds'],
            'plan_length': row.get('plan_length'), 'relevant_atoms': int(atoms[1]) if atoms else None,
            'selected_source_count': len(task.get('selected_sources', [])) or None})
    return result


def build(matched, selected, diagnostics, replay, output):
    require_empty_output(output)
    fresh_protocol = read(selected / 'bundle/manifest.json')
    for path, digest in fresh_protocol['implementation_sha256'].items():
        if sha(Path(path)) != digest:
            raise ValueError('Selector implementation changed')
    fresh = collect(selected, False)
    if len(fresh) != 30 or len({r['source'] for r in fresh}) != 15:
        raise ValueError('Require all 15 original worlds and both selection conditions')
    historical = collect(matched, True)
    diag, replay_report = read(diagnostics / 'report.json'), read(replay / 'report.json')
    if diag['status'] != 'complete' or not diag['hashes_unchanged']:
        raise ValueError('Incomplete diagnostic sampling')
    diagnostic_manifest = read(diagnostics / 'manifest.json')
    if sha(diagnostics / 'manifest.json') != diag['manifest_sha256']:
        raise ValueError('Diagnostic manifest drift')
    for path, digest in diagnostic_manifest['frozen_sha256'].items():
        if sha(Path(path)) != digest:
            raise ValueError('Diagnostic implementation drift')
    if replay_report['status'] != 'complete' or not replay_report['hashes_unchanged']:
        raise ValueError('Incomplete original-goal replay')
    for path, digest in replay_report['frozen_sha256'].items():
        if sha(Path(path)) != digest:
            raise ValueError('Replay evidence drift')
    certificates = {}
    for task in fresh_protocol['tasks']:
        if task['representation'] == 'world_selected':
            path = selected / 'models' / task['source'] / 'selection_certificate.json'
            if sha(path) != task['certificate_sha256']:
                raise ValueError('Selection certificate changed')
            certificates[task['source']] = read(path)
    rows = historical + fresh
    summaries = []
    for representation in dict.fromkeys(r['representation'] for r in rows):
        group = [r for r in rows if r['representation'] == representation]
        if len(group) != 15:
            raise ValueError('Representation denominator mismatch')
        summaries.append({'representation': representation, 'measurement_block': group[0]['measurement_block'],
            'task_count': len(group), 'status_counts': dict(Counter(r['status'] for r in group)),
            'solved': sum(r['status'] == 'solved' for r in group),
            'unsolvable': sum(r['status'] == 'unsolvable' for r in group),
            'resource_limits': sum(r['resource_limit'] for r in group),
            'limits_before_search': sum(r['resource_limit'] and r['phase'] == 'translation' for r in group)})
    reps = [s['representation'] for s in summaries]
    matrix = [{'source': source, **{rep: next(r['status'] for r in rows
               if r['source'] == source and r['representation'] == rep) for rep in reps}}
              for source in sorted(certificates)]
    paths = [matched / 'solver/report.json', matched / 'bundle/manifest.json',
        selected / 'solver/report.json', selected / 'solver/manifest.json', selected / 'bundle/manifest.json',
        diagnostics / 'report.json', replay / 'report.json', Path(__file__)]
    frozen = {str(p): sha(p) for p in paths}
    result = {'status': 'verified_complete_selection_comparison', 'fresh_solver_calls': 30,
        'source_count': 15, 'diagnostic_translator_calls': 5, 'budget': {'seconds': 20, 'memory_mb': 4096, 'workers': 1},
        'summary': summaries, 'rows': rows, 'matrix': matrix,
        'selection_certificates': certificates, 'diagnostics': diag, 'original_goal_replay': replay_report,
        'frozen_sha256': frozen, 'limitations': [
            'Exploratory development comparison; deterministic per-source order, optimized condition first; no repeated-seed uncertainty estimate.',
            'Earlier 60 trials are a separately labeled measurement block; only the two selection conditions were rerun together.',
            'Observed Windows elapsed time includes WSL launch/response and timeout termination grace; configured Linux limits remain 20 seconds.',
            'All 15 current worlds have disjoint source universes, so selected models are singletons; this measures removal of irrelevant overhead, not cross-source narrative fusion.',
            'Sampling runs are instrumented translator-only diagnostics, excluded from solver success and timing comparisons.',
            'The prior v1 diagnostic block attempted 5 calls: 4 lost samples during timer cleanup and 1 completed; it is retained and excluded. The v2 block retains all 5 reports, including 4 diagnostic wall limits with CPU-signal process exits during teardown.',
            'Compilation and selection are outside the solver budget. No independent semantic interface labels or narrative quality measurements.']}
    output.mkdir(parents=True)
    save(output / 'results.json', result)
    for name, records in [('task_results.csv', rows), ('source_matrix.csv', matrix), ('summary.csv', summaries)]:
        with (output / name).open('w', encoding='utf-8-sig', newline='') as file:
            writer = csv.DictWriter(file, fieldnames=list(records[0]))
            writer.writeheader()
            writer.writerows(records)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('matched', 'selected', 'diagnostics', 'replay', 'output'):
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    result = build(args.matched, args.selected, args.diagnostics, args.replay, args.output)
    print(json.dumps(result['summary'], indent=2))

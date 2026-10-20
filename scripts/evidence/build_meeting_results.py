"""Verify complete experiment denominators and export meeting tables, never partial runs."""
import argparse
from collections import Counter
import csv
import json
from pathlib import Path
import statistics

from scripts.experiments.run_downward_reference import sha, save


RESOURCE_LIMITS = {'wall_time_limit', 'time_limit', 'memory_limit', 'memory_time_limit',
                   'resource_killed', 'wsl_observation_timeout'}


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def phase(directory):
    text = (directory / 'planner.log').read_text(encoding='utf-8', errors='replace')
    if 'Running search' in text:
        return 'search'
    if 'Running translator.' in text:
        return 'translation'
    return 'startup_or_unknown'


def build(matched, replay, historical, output, selection=None, original_replay=None):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use a fresh meeting-results directory')
    report = read(matched / 'report.json')
    solver = read(matched / 'solver/manifest.json')
    protocol = read(matched / 'bundle/manifest.json')
    previous = read(historical / 'results.json')
    replay_report = read(replay / 'report.json')
    if (report['status'] != 'complete' or protocol['status'] != 'frozen_before_search'
            or not report['matched_protocol_unchanged'] or not report['construction_implementation_unchanged']
            or not report['binary_unchanged'] or not report['runner_unchanged']
            or report['manifest_sha256'] != sha(matched / 'solver/manifest.json')):
        raise ValueError('Complete unchanged matched run required')
    rows = {row['id']: row for row in report['rows']}
    tasks = {task['id']: task for task in solver['tasks']}
    if (len(rows) != len(report['rows']) or set(rows) != set(tasks)
            or len(rows) != protocol['task_count'] or len(rows) != protocol['planned_task_count']):
        raise ValueError('Matched task denominator mismatch')
    if dict(Counter(row['status'] for row in rows.values())) != report['status_counts']:
        raise ValueError('Solver count mismatch')
    long_rows = []
    for key, task in tasks.items():
        row = rows[key]
        directory = matched / 'solver/tasks' / key
        if not row['inputs_unchanged'] or any(sha(directory / (kind + '.pddl')) != task[kind + '_sha256']
                                              for kind in ('domain', 'problem')):
            raise ValueError('Changed solver task: ' + key)
        if row['status'] == 'solved' and row.get('validation', {}).get('status') != 'VALID':
            raise ValueError('Unvalidated solved row')
        long_rows.append({'id': key, 'source': task['source'], 'representation': task['representation'],
            'status': row['status'], 'engine_status': row.get('engine_status'),
            'last_logged_phase': phase(directory),
            'plan_length': row.get('plan_length'), 'elapsed_seconds': row['elapsed_seconds']})
    if previous['status'] != 'verified_snapshot':
        raise ValueError('Verified historical inventory required')
    for entry in previous['results'].values():
        if sha(Path(entry['path'])) != entry['sha256']:
            raise ValueError('Historical report changed after recheck')
    original_history_path = Path(previous['results']['original_source_planning']['path'])
    original_history_manifest = original_history_path.parent / 'manifest.json'
    if read(original_history_path)['manifest_sha256'] != sha(original_history_manifest):
        raise ValueError('Historical original-goal budget manifest changed')
    if (replay_report['status'] != 'complete' or not replay_report['hashes_unchanged']
            or len(replay_report['rows']) != replay_report['task_count']
            or len({r['id'] for r in replay_report['rows']}) != replay_report['task_count']
            or dict(Counter(r['status'] for r in replay_report['rows'])) != replay_report['counts']):
        raise ValueError('Complete full-denominator replay required')
    for name, expected in replay_report['frozen_sha256'].items():
        if sha(Path(name)) != expected:
            raise ValueError('Replay input drift: ' + name)
    summary, matrix = [], []
    for representation in protocol['representations']:
        group = [r for r in long_rows if r['representation'] == representation]
        if len(group) != protocol['source_count']:
            raise ValueError('Unequal representation denominator')
        summary.append({'representation': representation, 'task_count': len(group),
            'status_counts': dict(Counter(r['status'] for r in group)),
            'last_logged_phase_counts': dict(Counter(r['last_logged_phase'] for r in group)),
            'resource_limits_before_logged_search': sum(r['status'] in RESOURCE_LIMITS and
                r['last_logged_phase'] == 'translation' for r in group),
            'median_elapsed_seconds': statistics.median(r['elapsed_seconds'] for r in group),
            'total_elapsed_seconds': sum(r['elapsed_seconds'] for r in group)})
    for source in sorted({row['source'] for row in long_rows}):
        group = {r['representation']: r for r in long_rows if r['source'] == source}
        matrix.append({'source': source, **{name: group[name]['status'] for name in protocol['representations']}})
    baseline = {r['source']: r['status'] for r in long_rows if r['representation'] == 'source_isolated'}
    changes = {representation: {
        'gained_solved_vs_isolated': [r['source'] for r in long_rows if r['representation'] == representation
                                    and r['status'] == 'solved' and baseline[r['source']] != 'solved'],
        'lost_solved_vs_isolated': [r['source'] for r in long_rows if r['representation'] == representation
                                  and r['status'] != 'solved' and baseline[r['source']] == 'solved']}
        for representation in protocol['representations'] if representation != 'source_isolated'}
    selection_rows = []
    selection_result = None
    selection_hashes = {}
    if selection is not None:
        selected_report = read(selection / 'solver/report.json')
        selected_solver = read(selection / 'solver/manifest.json')
        selected_protocol = read(selection / 'bundle/manifest.json')
        if (selected_report['status'] != 'complete' or not selected_report['binary_unchanged']
                or not selected_report['runner_unchanged']
                or selected_report['manifest_sha256'] != sha(selection / 'solver/manifest.json')
                or selected_protocol['policy_sha256'] != sha(selection / 'policy.json')
                or selected_protocol['origin_bundle_sha256'] != sha(matched / 'bundle/manifest.json')
                or selected_solver['budget'] != solver['budget']
                or selected_solver['binary_sha256'] != solver['binary_sha256']):
            raise ValueError('Complete matched-budget selection follow-up required')
        selected_tasks = {t['id']: t for t in selected_solver['tasks']}
        selected_rows = {r['id']: r for r in selected_report['rows']}
        if (len(selected_rows) != len(selected_report['rows']) or set(selected_rows) != set(selected_tasks)
                or len(selected_rows) != protocol['source_count']
                or dict(Counter(r['status'] for r in selected_rows.values())) != selected_report['status_counts']):
            raise ValueError('Selection follow-up denominator mismatch')
        policy = read(selection / 'policy.json')
        for key, task in selected_tasks.items():
            row = selected_rows[key]
            directory = selection / 'solver/tasks' / key
            if not row['inputs_unchanged'] or any(sha(directory / (kind + '.pddl')) != task[kind + '_sha256']
                                                  for kind in ('domain', 'problem')):
                raise ValueError('Selected task changed')
            if row['status'] == 'solved' and row.get('validation', {}).get('status') != 'VALID':
                raise ValueError('Selection result has unvalidated plan')
            selection_rows.append({'source': task['source'], 'status': row['status'],
                'last_logged_phase': phase(directory), 'plan_length': row.get('plan_length'),
                'elapsed_seconds': row['elapsed_seconds'],
                'selected_source_count': len(policy['selected_sources'][task['source']])})
        full = {r['source']: r['status'] for r in long_rows if r['representation'] == 'machine_interfaces'}
        selection_result = {'label': policy['label'], 'task_count': len(selection_rows),
            'status_counts': selected_report['status_counts'], 'rows': selection_rows,
            'unique_selected_models': selected_protocol['unique_selected_models'],
            'gained_solved_vs_all_pool_machine': [r['source'] for r in selection_rows
                if r['status'] == 'solved' and full[r['source']] != 'solved'],
            'lost_solved_vs_all_pool_machine': [r['source'] for r in selection_rows
                if r['status'] != 'solved' and full[r['source']] == 'solved']}
        selection_hashes = {str(p): sha(p) for p in (selection / 'solver/report.json',
            selection / 'bundle/manifest.json', selection / 'policy.json')}
    original_replay_result = None
    if original_replay is not None:
        original = read(original_replay / 'report.json')
        if (original['status'] != 'complete' or not original['hashes_unchanged']
                or len(original['rows']) != protocol['source_count']
                or {r['source'] for r in original['rows']} != set(baseline)
                or dict(Counter(r['status'] for r in original['rows'])) != original['counts']
                or original['original_goal_plans'] != sum(s == 'solved' for s in baseline.values())):
            raise ValueError('Complete fresh original-goal replay required')
        if any(sha(Path(name)) != expected for name, expected in original['frozen_sha256'].items()):
            raise ValueError('Original-goal replay input drift')
        original_replay_result = {key: original[key] for key in ('source_count', 'counts', 'original_goal_plans',
            'valid_translations', 'states_compared', 'truth_comparisons', 'mismatch_count', 'scope')}
        original_replay_result['valid_plan_witness_despite_search_cutoff'] = sum(
            row['status'] == 'PASS' and row['pooled_machine_search_status'] in RESOURCE_LIMITS for row in original['rows'])
        selection_hashes[str(original_replay / 'report.json')] = sha(original_replay / 'report.json')
    result = {'status': 'verified_complete_meeting_results', 'meeting_date': '2026-10-21',
        'fresh_search': {'unique_original_worlds': protocol['source_count'], 'solver_invocations': len(long_rows),
            'budget': protocol['budget'], 'summary': summary, 'matrix': matrix, 'changes': changes,
            'scope': report['scope'], 'timing_limit': 'Fixed source/representation order on a shared workstation; descriptive timing, no speedup significance claim'},
        'new_machine_interface_replay': {key: replay_report[key] for key in (
            'task_count', 'counts', 'states_compared', 'truth_comparisons', 'mismatch_count', 'hashes_unchanged', 'scope')},
        'exploratory_selection': selection_result,
        'fresh_original_goal_replay': original_replay_result,
        'historical_rechecked': {'report_count': len(previous['results']),
            'data_kind': 'Historical saved measurements rechecked, not newly executed solver runs',
            'original_goal_budget': read(original_history_manifest)['budget'],
            'results': previous['results']},
        'construction': read(matched / 'construction.json'),
        'source_report_sha256': {str(original_history_manifest): sha(original_history_manifest),
            **selection_hashes, **{str(p): sha(p) for p in (
            matched / 'report.json', matched / 'bundle/manifest.json', matched / 'construction.json',
            replay / 'report.json', historical / 'results.json')}},
        'implementation_sha256': sha(Path(__file__)),
        'no_aggregate_success_rate': 'Original goals, action-invocation probes, replay checks, output-format checks and human labels are different units; never pool their denominators',
        'independent_semantic_labels': 0, 'independent_narrative_assessments': 0}
    output.mkdir(parents=True)
    save(output / 'results.json', result)
    exports = [('matched_tasks.csv', long_rows), ('matched_matrix.csv', matrix)]
    if selection_rows:
        exports.append(('selection_tasks.csv', selection_rows))
    for name, values in exports:
        with (output / name).open('x', newline='', encoding='utf-8-sig') as stream:
            writer = csv.DictWriter(stream, fieldnames=list(values[0]))
            writer.writeheader()
            writer.writerows(values)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('matched', 'replay', 'historical', 'output'):
        parser.add_argument('--' + name, type=Path, required=True)
    parser.add_argument('--selection', type=Path)
    parser.add_argument('--original-replay', type=Path)
    args = parser.parse_args()
    result = build(args.matched, args.replay, args.historical, args.output, args.selection, args.original_replay)
    print(json.dumps({k: v for k, v in result.items() if k not in ('historical_rechecked', 'source_report_sha256')}, indent=2))

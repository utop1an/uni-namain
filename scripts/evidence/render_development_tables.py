"""Render working-paper tables only from a pinned verified evidence snapshot."""
import argparse
import json
from pathlib import Path

from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation


def tex(value):
    replacements = {'_': r'\_', '&': r'\&', '%': r'\%', '#': r'\#', '$': r'\$',
        '{': r'\{', '}': r'\}', '\\': r'\textbackslash{}'}
    return ''.join(replacements.get(character, character) for character in str(value))


def table(columns, header, rows, caption, label):
    return ('\\begin{table}[t]\n\\centering\n\\small\n\\begin{tabular}{' + columns + '}\n\\toprule\n'
        + ' & '.join(header) + r' \\' + '\n\\midrule\n'
        + ''.join(' & '.join(map(str, row)) + r' \\' + '\n' for row in rows)
        + '\\bottomrule\n\\end{tabular}\n\\caption{' + caption + '}\n\\label{' + label + '}\n\\end{table}\n')


def render(snapshot_path, output):
    require_empty_output(output)
    snapshot = json.loads(snapshot_path.read_text(encoding='utf-8'))
    if snapshot['status'] != 'verified_snapshot' or digest(snapshot_path.parent / 'result_sources.json') != snapshot['index_sha256']:
        raise ValueError('Verified unchanged evidence snapshot required')
    used = {}
    def report(role):
        entry = snapshot['results'][role]
        path = Path(entry['path'])
        if digest(path) != entry['sha256']:
            raise ValueError('Pinned source report drift: ' + role)
        used[role] = {'path': path.as_posix(), 'sha256': entry['sha256']}
        return json.loads(path.read_text(encoding='utf-8'))
    matched = report('matched_source_worlds_audit')
    if matched['status'] != 'verified_matched_source_worlds' or matched['task_count'] != 90 or matched['actual_solver_calls'] != 75:
        raise ValueError('Complete matched90-slot/75-call audit required')
    labels = {'native_source': 'Native source', 'zero_merge_all': 'Zero merge, all actions',
        'zero_merge_components': 'Zero merge, components', 'machine_all': 'Fixed interfaces, all actions',
        'machine_components': 'Fixed interfaces, components'}
    rows, other = [], {}
    for name, label in labels.items():
        counts = matched['by_condition'][name]
        if sum(counts.values()) != 15:
            raise ValueError('Each representation must retain all15worlds')
        remaining = {key: value for key, value in counts.items() if key not in ('solved', 'unsolvable', 'wall_time_limit')}
        other[name] = remaining
        rows.append([label, counts.get('solved', 0), counts.get('unsolvable', 0), counts.get('wall_time_limit', 0), sum(remaining.values())])
    if matched['by_condition']['fresh_reference_model_unavailable'] != {'fresh_reference_construction_time_limit': 15} or matched['reference_construction_failures'] != 1:
        raise ValueError('Do not flatten model-construction failure into planning failures')
    files = {'matched_source_worlds.tex': table('lrrrr', ['Representation', 'Solved', 'Unsolv.', 'Wall', 'Other'], rows,
        'All 75 fresh searches over the same 15 known original worlds, Fast Downward 26.6 with LAMA-first, a 20-second wall/CPU limit and 4096 MiB memory limit, with one planner worker. '
        'The 15 reference-unavailable slots share one 10,800-second model-construction timeout and are not counted as planning failures. '
        'Component reduction matches native solve coverage; this block shows no source-goal benefit from the fixed unreviewed interfaces. '
        'Concurrent workstation workloads preclude statistical timing claims.', 'tab:matched-source-worlds-oct23')}
    probes = report('composition_primary_audit')
    generated = [row for row in probes['pair_results'] if row['status'] == 'generated']
    missing = [row for row in probes['pair_results'] if row['status'] != 'generated']
    if len(generated) != 6 or len(missing) != 12 or probes['task_count'] != 72 or probes['actual_solver_calls'] != 24:
        raise ValueError('Complete primary18-pair registry required')
    short = {'solved': 'S', 'unsolvable': 'U', 'wall_time_limit': 'T'}
    necessity = {'both_action_sources_necessary': 'Both', 'source_removal_still_solved': 'Not both',
        'aligned_wall_time_limit': 'Unresolved'}
    rows = []
    for row in generated:
        outcomes = row['condition_statuses']
        rows.append([tex(row['producer']), tex(row['consumer']),
            *[short[outcomes[key]] for key in ('aligned_selected_sources', 'zero_merge_same_source_action_sets',
                'aligned_remove_producer_actions', 'aligned_remove_consumer_actions')], necessity[row['source_necessity']]])
    files['composition_probes.tex'] = table('llccccc', ['Producer', 'Consumer', 'Aligned', 'Zero', '$-P$', '$-C$', 'Necessary'], rows,
        'All six generated worlds from 18 fixed directed source-pair slots; 12 pairs could not be constructed, retaining 48 unsupported condition slots. '
        'S: validated plan; U: solver-reported unsolvable; T: wall limit. $-P$/$-C$ remove the entire producer/consumer action set. '
        'Only three generated worlds establish both-source necessity; two remain solvable after a source removal, and one aligned case is limited. '
        'These model-derived worlds provide no independent semantic labels.', 'tab:composition-probes-oct23')
    live = report('live_interface_pair_audit')
    if live['condition_count'] != 2 or live['candidate_slots'] != 200 or live['matched_attempted_candidates'] != 100:
        raise ValueError('Complete200-slot live pair required')
    rows = [[tex(row['id']), row['counts'].get('checked', 0), row['counts'].get('invalid', 0),
        row['counts'].get('failed', 0), row['budget_exhausted']] for row in live['rows']]
    files['live_output_contract.tex'] = table('lrrrr', ['Schema policy', 'Checked', 'Invalid', 'Failed', 'Unrequested'], rows,
        'Each condition attempted the same 100 known candidates under a 600-second request-admission/socket budget. '
        'Both produced 95 responses compliant with their respective JSON schemas, while the common contract checker accepted different counts. '
        'Checker acceptance and schema compliance are not semantic accuracy. One sequential paired run does not establish a stochastic or timing improvement.', 'tab:live-contract-oct23')
    replay = report('live_model_source_replay_audit')
    ready = [row for row in replay['rows'] if row['admission_status'] == 'ready']
    if replay['status'] != 'verified_live_model_source_replay' or len(ready) != replay['available_source_plans']:
        raise ValueError('Every available witness must survive the replay audit')
    rows = [[tex(row['id']), row['mapped']['length'], row['truth_projection']['states'],
        row['truth_projection']['comparisons'], row['truth_projection']['mismatches']] for row in ready]
    files['live_model_source_replay.tex'] = table('lrrrr', ['Source', 'Steps', 'States', 'Atom checks', 'Mismatch'], rows,
        'All six available historical native 60-second original-goal witnesses in one fixed live-proposed parameterized model. '
        'Nine sources without a native witness remain in the 15-source registry. No new planner calls were made. '
        'The 38,331 truth comparisons and exact full-argument inverse checks concern these correlated source-only traces, not interface meaning or mixed-source behavior.', 'tab:live-model-replay-oct23')
    output.mkdir(parents=True)
    for name, content in files.items():
        (output / name).write_text(content, encoding='utf-8')
    implementation = snapshot_implementation(output, [Path(__file__), Path('rcnc/domain_building.py')])
    result = {'status': 'rendered_from_verified_snapshot', 'table_count': len(files),
        'snapshot_sha256': digest(snapshot_path), 'sources': used,
        'output_sha256': {name: digest(output / name) for name in files}, 'other_solver_statuses': other,
        'implementation_sha256': implementation,
        'scope': 'Working-paper table fragments. No aggregate rate across heterogeneous units and no new experiment or semantic label.'}
    save(output / 'manifest.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--snapshot', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(render(args.snapshot, args.output), indent=2))

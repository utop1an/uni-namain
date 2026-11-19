"""New offline attribution audit of completed, frozen composition reports.

No model, Java, planner, network, or historical-output writes. Source branches
are certified against the paired frozen Predicate-only model. All registered
rows, including no-plan returns and timeouts, retain their original identities.
"""
import argparse
from collections import Counter, defaultdict
from datetime import datetime, timezone
import json
from pathlib import Path

from rcnc.causal_attribution import (VERSION, causal_trace_v2, file_digest,
                                    recover_branch_provenance, value_digest)

DEFAULT_REPORTS = {
    'balanced70': 'data/validation/revised_multistory_composition_expanded70_2026_11_03_v1/report.json',
    'targeted263': 'data/validation/causal_multistory_2026_11_04_v1/composition/report.json',
    'chain3': 'data/validation/causal_chains_2026_11_05_v2/report.json',
    'chain4': 'data/validation/causal_chains_k04_expanded_2026_11_05_v1/report.json',
}


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


def condition_group(condition):
    if condition.startswith('without_') and condition not in ('without_producer', 'without_consumer'):
        return 'source_removal'
    return condition


def summarize(rows):
    groups = defaultdict(Counter)
    for row in rows:
        key = row['cohort'] + '/' + condition_group(row['condition'])
        counts = groups[key]
        counts['slots'] += 1
        counts['search_' + row['original_search_status']] += 1
        counts['valid'] += row['original_valid_plan']
        if not row['original_valid_plan']:
            continue
        audit = row['audit']
        counts['physical_replayed'] += (audit.get('physical', {}).get('status') == 'replayed'
                                       and audit.get('physical', {}).get('goal') is True)
        counts['origin_ambiguous'] += bool(audit.get('origin_ambiguous_steps'))
        for metric in ('cross', 'all_k'):
            counts[metric + '_' + audit[metric]['status']] += 1
        counts['v1_cross_' + row['original_causal_status']] += 1
    return {key: dict(value) for key, value in sorted(groups.items())}


def audit_reports(reports, output, *, max_interpretations=4096, max_supports=256):
    if output.exists():
        raise ValueError('Fresh audit directory required')
    hashes, documents, frozen, datasets = {}, {}, {}, {}

    def pin(path, expected=None):
        path = Path(path).resolve()
        key = str(path)
        if key not in hashes:
            hashes[key] = file_digest(path)
        if expected is not None and hashes[key] != expected:
            raise ValueError('Frozen input changed: ' + key)
        return hashes[key]

    for cohort, name in reports.items():
        report_path = Path(name).resolve()
        pin(report_path)
        report = read(report_path)
        protocol_path = report_path.parent / 'protocol.json'
        pin(protocol_path, report.get('protocol_sha256'))
        protocol = read(protocol_path)
        for path, digest in protocol['input_sha256'].items():
            pin(path, digest)
        tasks_path = report_path.parent / 'tasks.json'
        if tasks_path.exists():
            pin(tasks_path)
            tasks = read(tasks_path)['tasks']
        else:
            tasks = protocol['tasks']
        if (len(report['rows']) != len(tasks)
                or len({r['id'] for r in report['rows']}) != len(tasks)
                or {r['id'] for r in report['rows']} != {r['id'] for r in tasks}):
            raise ValueError('Registered row denominator mismatch: ' + cohort)
        for row in report['rows']:
            for key in ('domain', 'problem', 'mapping'):
                pin(row[key])
            for stage in ('search', 'replay'):
                for path, digest in row.get(stage, {}).get('input_sha256', {}).items():
                    pin(path, digest)
            domain = Path(row['domain']).resolve()
            mapping_path = Path(row['mapping']).resolve()
            mapping = documents.setdefault(str(mapping_path), read(mapping_path))
            names = Counter(v['name'] for v in mapping['action_maps'].values())
            if any(n > 1 for n in names.values()):
                pair = domain.parent.parent / 'predicate_only'
                pin(pair / 'domain.pddl')
                pin(pair / 'mapping.json')
                frozen[str(domain)] = (domain, mapping, pair)
            if row.get('valid_plan', row.get('valid', False)):
                plan = report_path.parent / 'execution' / row['id'] / 'search' / 'plan.pddl'
                plan_hash = pin(plan)
                recorded = row.get('replay', {}).get('input_sha256', {})
                if recorded.get(str(plan.resolve())) != plan_hash:
                    raise ValueError('Saved plan is not pinned by original replay: ' + str(plan))
        datasets[cohort] = (report_path, report, protocol)

    registry = None
    if 'balanced70' in datasets:
        path = datasets['balanced70'][0].parent / 'world_registry.json'
        pin(path)
        registry = read(path)
    implementation = [Path(__file__), Path('rcnc/causal_attribution.py'),
                      Path('rcnc/glaive_merge.py'), Path('rcnc/pddl.py'),
                      Path('rcnc/revised_probe_validation.py'), Path('rcnc/composition_probes.py')]
    for path in implementation:
        pin(path)
    protocol = {
        'status': 'frozen_before_offline_audit', 'created_utc': datetime.now(timezone.utc).isoformat(),
        'version': VERSION, 'reports': {k: str(v[0]) for k, v in datasets.items()},
        'input_sha256': hashes, 'registered_rows': sum(len(v[1]['rows']) for v in datasets.values()),
        'limits': {'max_interpretations': max_interpretations, 'max_supports': max_supports},
        'new_model_calls': 0, 'new_planner_calls': 0,
        'policy': 'All saved valid plans; original task IDs and every failure/limit row retained. Independent physical replay, then complete applicable source-branch and true-disjunct support interpretations. Cross and All-k independently universal/absent/mixed. Caps and unsupported constructs remain unknown. Positive-fact causal slice only; no semantic or narrative labels.',
        'all_k_scope': 'Only original chain tasks; not requested for pairwise tasks or source-removal controls.',
    }
    save(output / 'protocol.json', protocol)
    for path in implementation:
        target = output / 'implementation' / (path.name if path.is_absolute() else path)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(path.read_bytes())
    provenance_by_domain = {}
    for key, (domain, mapping, pair) in frozen.items():
        sidecar = recover_branch_provenance(domain, mapping, pair / 'domain.pddl', read(pair / 'mapping.json'))
        relative = 'provenance/' + value_digest(sidecar) + '.json'
        if not (output / relative).exists():
            save(output / relative, sidecar)
        provenance_by_domain[key] = (sidecar, relative)
    print(json.dumps({'phase': 'inputs_verified_and_branches_recorded', 'rows': protocol['registered_rows'],
                      'fused_models': len(frozen), 'pinned_files': len(hashes)}), flush=True)

    rows, transitions, regressions = [], Counter(), []
    for cohort, (path, report, _) in datasets.items():
        for original in report['rows']:
            valid = original.get('valid_plan', original.get('valid', False))
            old_causal = original.get('causal', original.get('trace', {})).get('status', 'not_evaluated')
            row = {'id': cohort + '/' + original['id'], 'original_id': original['id'], 'cohort': cohort,
                   'case_id': original.get('case_id', original['group']), 'group': original['group'],
                   'condition': original['condition'], 'original_search_status': original['search']['status'],
                   'original_valid_plan': valid, 'original_causal_status': old_causal,
                   'original_all_k_path': original.get('path'),
                   'domain': original['domain'], 'mapping': original['mapping'], 'problem': original['problem']}
            if not valid:
                row['audit'] = {'status': 'no_valid_saved_plan', 'cross': {'status': 'not_evaluated'},
                                'all_k': {'status': 'not_evaluated'}}
            else:
                domain = Path(original['domain']).resolve()
                mapping = documents[str(Path(original['mapping']).resolve())]
                sidecar, sidecar_path = provenance_by_domain.get(str(domain), (None, None))
                plan = path.parent / 'execution' / original['id'] / 'search' / 'plan.pddl'
                sources = original.get('sources') if condition_group(original['condition']) != 'source_removal' else None
                result = causal_trace_v2(domain, original['problem'], plan, mapping, provenance=sidecar,
                                         selected_sources=sources, max_interpretations=max_interpretations,
                                         max_supports=max_supports)
                row.update(audit=result, plan=str(plan), plan_sha256=hashes[str(plan.resolve())], branch_provenance=sidecar_path)
                transitions[cohort + '/' + original['condition'] + '/' + old_causal + '->' + result['cross']['status']] += 1
                if ((old_causal == 'cross_source_composition' and result['cross']['status'] != 'confirmed')
                        or (old_causal == 'no_goal_relevant_cross_source_link' and result['cross']['status'] != 'absent')
                        or (original.get('path') and result['all_k']['status'] != 'confirmed')):
                    regressions.append(row['id'])
            rows.append(row)
        print(json.dumps({'phase': 'cohort_complete', 'cohort': cohort,
                          'counts': summarize([r for r in rows if r['cohort'] == cohort])}), flush=True)
    world_rows = []
    if registry:
        representatives = {w['representative_case_id'] for w in registry['worlds']}
        world_rows = [r for r in rows if r['cohort'] == 'balanced70' and r['case_id'] in representatives]
        if len(world_rows) != 6 * len(registry['worlds']):
            raise ValueError('Fixed world denominator mismatch')
    for path, digest in hashes.items():
        if file_digest(path) != digest:
            raise ValueError('Input changed during audit: ' + path)
    report = {'status': 'complete_offline_causal_attribution_audit', 'version': VERSION,
              'protocol_sha256': file_digest(output / 'protocol.json'),
              'registered_rows': len(rows), 'valid_saved_plans': sum(r['original_valid_plan'] for r in rows),
              'rows': rows, 'by_cohort_condition': summarize(rows),
              'fixed_world_representatives': {'worlds': len(registry['worlds']) if registry else 0,
                                            'row_ids': [r['id'] for r in world_rows], 'counts': summarize(world_rows)},
              'v1_to_v2_cross_transitions': dict(sorted(transitions.items())),
              'previously_determinate_verdict_changes': regressions,
              'inputs_unchanged': True, 'pinned_files': len(hashes), 'fused_models': len(frozen),
              'new_model_calls': 0, 'new_planner_calls': 0, 'independent_semantic_labels': 0}
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--report', action='append', help='Optional cohort=report.json; default: four completed paper blocks')
    args = parser.parse_args()
    reports = dict(x.split('=', 1) for x in args.report) if args.report else DEFAULT_REPORTS
    result = audit_reports(reports, args.output)
    print(json.dumps({k: result[k] for k in ('status', 'registered_rows', 'valid_saved_plans',
                                            'inputs_unchanged', 'previously_determinate_verdict_changes')}, indent=2))

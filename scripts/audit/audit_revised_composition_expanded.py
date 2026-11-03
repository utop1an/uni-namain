"""Read-only evidence audit of the expanded composition matrix; no solver calls."""
import argparse
from collections import Counter, defaultdict
from pathlib import Path
import json

from rcnc.domain_building import digest, save, snapshot_implementation
from scripts.audit import eval_revised_composition as original
from scripts.audit.eval_revised_composition_expanded import counts
from scripts.experiments import run_revised_multistory as base


def audit(evaluation, output):
    if output.exists():
        raise ValueError('Fresh audit directory required')
    protocol = base.verify(evaluation)
    report = base.read(evaluation / 'report.json')
    summary = base.read(evaluation / 'expanded_summary.json')
    cases = base.read(evaluation / 'selected_cases.json')['cases']
    worlds = base.read(evaluation / 'world_registry.json')['worlds']
    rows = report['rows']; index = {(r['case_id'], r['condition']): r for r in rows}
    if len(index) != 420 or len(rows) != 420 or report['calls']['search'] != 420:
        raise ValueError('Incomplete or duplicated matrix')
    if not report['input_hashes_unchanged']:
        raise ValueError('Changed frozen input')
    if Counter(r['condition'] for r in rows) != {c: 70 for c in original.CONDITIONS}:
        raise ValueError('Condition denominator changed')
    output.mkdir(parents=True)
    checked = {}
    physical_rows = []
    for row in rows:
        if row['world_receipt']['source_problem_facts_copied'] != 0:
            raise ValueError('Pooled source facts')
        for result in (row['search'], row.get('replay', {})):
            for name, expected in result.get('input_sha256', {}).items():
                if name not in checked:
                    checked[name] = digest(Path(name))
                if checked[name] != expected:
                    raise ValueError('Changed executed input: ' + name)
        if row['search']['status'] != 'solved':
            if row['valid_plan']:
                raise ValueError('Non-solution counted as valid')
            continue
        domain = Path(row['domain']); problem = Path(row['problem'])
        plan = evaluation / 'execution' / row['id'] / 'search/plan.pddl'
        physical = base.physical(domain, problem, plan)
        if row['valid_plan']:
            if not base.valid(row.get('replay', {})):
                raise ValueError('Validity flag inconsistent')
            if physical.get('status') != 'replayed' or physical.get('goal') is not True:
                raise ValueError('Previously valid plan fails physical recheck')
            causal = original.causal_trace(domain, problem, plan, base.read(Path(row['mapping'])))
            if causal != row['causal']:
                raise ValueError('Causal recomputation differs')
        physical_rows.append({'id': row['id'], 'valid_plan': row['valid_plan'],
                              'physical': physical, 'causal': row['causal']})
    save(output / 'plan_rechecks.json', {'rows': physical_rows})
    # Link original-world preservation to byte-identical saved Full models.
    # These are previous searches/replays, not additional fresh execution evidence.
    parent = Path(protocol['parent_campaign']) / 'repeat_01/report.json'
    main = base.read(parent)
    groups = {c['group']['id'] for c in cases}
    old_rows = [r for r in main['rows'] if r['condition'] == 'full' and r['group'] in groups]
    if len(old_rows) != 116 or len({r['id'] for r in old_rows}) != 116:
        raise ValueError('Same-model source-slot denominator changed')
    preservation = []
    for row in old_rows:
        gid = row['group']; sid = row['source']
        saved_domain = evaluation / 'models' / gid / 'full/domain.pddl'
        if digest(saved_domain) != digest(Path(row['domain'])):
            raise ValueError('Preservation domain differs from composition model')
        result = row['transport']; status = base.replay_evidence(result)
        if base.valid(result):
            for name, expected in result['input_sha256'].items():
                if name not in checked:
                    checked[name] = digest(Path(name))
                if checked[name] != expected:
                    raise ValueError('Changed historical preservation input')
        preservation.append({'id': row['id'], 'group': gid, 'source': sid,
            'validated_historical_transport': base.valid(result),
            'transport_status': result['status'], 'evidence_status': status})
    save(output / 'same_model_historical_preservation.json', {'rows': preservation,
        'scope': 'Historical original-world plan replays in byte-identical models; not new planner calls, exhaustive source traces, or combined original worlds.'})
    by_group = defaultdict(list)
    for r in preservation:
        by_group[r['group']].append(r)
    crossed = [r for r in rows if r['condition'] == 'full' and r['causal']['status'] == 'cross_source_composition']
    paired = []
    for r in crossed:
        ps = by_group[r['group']]
        available = sum(p['validated_historical_transport'] for p in ps)
        paired.append({'case_id': r['case_id'], 'group': r['group'], 'world_id': r['world_id'],
            'source_slots': len(ps), 'available_preserved': available,
            'all_selected_sources_available_and_preserved': available == len(ps)})
    save(output / 'paired_composition_preservation.json', {'rows': paired})
    # Per-world context diagnostics are secondary to fixed representatives.
    context = []
    for world in worlds:
        items = []
        for condition in original.CONDITIONS:
            rs = [index[cid, condition] for cid in world['case_ids']]
            items.append({'condition': condition, **counts(rs),
                'causal_status_agrees_across_contexts': len({r['causal']['status'] for r in rs}) == 1})
        context.append({**world, 'conditions': items})
    save(output / 'world_contexts.json', {'worlds': context})
    representatives = {w['representative_case_id'] for w in worlds}
    fixed = {c: counts([r for r in rows if r['condition'] == c and r['case_id'] in representatives]) for c in original.CONDITIONS}
    if fixed != summary['fixed_world_representatives']:
        raise ValueError('Representative-world summary mismatch')
    compilation = base.read(evaluation / 'parent_compilation.json')
    action_merge_groups = {m['group'] for m in compilation['models']
        if m['group'] in groups and m['condition'] == 'full'
        and m['action_count'] < m['source_action_count']}
    full_risks = []
    for case in cases:
        desc = case['candidate']
        actions = (desc['producer_action'], desc['consumer_action'])
        if 'create-lightbox' in actions and 'fix-pedal' in actions:
            full_risks.append({'case_id': case['case_id'], 'world_id': case['world_id'],
                'group': case['group']['id'], 'reason': 'Previously observed lightbox/bike identity concern; no independent semantic label.'})
    save(output / 'known_identity_risks.json', {'rows': full_risks,
        'scope': 'Retained previously known concern; this detector is not an exhaustive semantic review.'})
    previous = Path(protocol['parent_diagnostic'])
    prior_cases = base.read(previous / 'selected_cases.json')['cases']
    prior_rows = base.read(previous / 'report.json')['rows']
    old_index = {(r['group'], r['condition']): r for r in prior_rows}
    new_by_descriptor = {(c['group']['id'], c['rank']): c['case_id'] for c in cases}
    comparisons = []
    for old_case in prior_cases:
        gid = old_case['group']['id']
        cid = new_by_descriptor[gid, old_case['rank']]
        for condition in original.CONDITIONS:
            old_row = old_index[gid, condition]; new_row = index[cid, condition]
            comparisons.append({'case_id': cid, 'condition': condition,
                'same_search_status': old_row['search']['status'] == new_row['search']['status'],
                'same_validity': old_row['valid_plan'] == new_row['valid_plan'],
                'same_causal_status': old_row['causal']['status'] == new_row['causal']['status']})
    save(output / 'previous18_fresh_search_comparison.json', {'rows': comparisons,
        'scope': 'Fresh searches of the 18 previously selected fixtures; no new LLM merge repeat and no pooled sample size.'})
    metrics = {'status': 'verified_expanded_composition_analysis', 'created_utc': base.now(),
        'row_count': 420, 'case_count': 70, 'distinct_worlds': 37, 'groups': 35,
        'all_tasks': summary['all_tasks'], 'fixed_world_representatives': fixed,
        'by_size': summary['by_size'],
        'generator_coverage': {'registered_groups': 300, 'supported_groups': 35,
            'outside_generator_coverage': 265, 'supported_descriptors': 70,
            'by_size_groups': {'2': 6, '3': 12, '4': 17}},
        'same_model_historical_preservation': {'registered_source_slots': 116,
            'validated': sum(r['validated_historical_transport'] for r in preservation),
            'transport_status': dict(Counter(r['transport_status'] for r in preservation)),
            'new_searches_or_replays': 0},
        'paired_cross_source_cases': {'count': len(paired),
            'at_least_one_preserved_original': sum(r['available_preserved'] > 0 for r in paired),
            'all_selected_sources_available_preserved': sum(r['all_selected_sources_available_and_preserved'] for r in paired),
            'all_sources_paired_distinct_worlds': len({r['world_id'] for r in paired if r['all_selected_sources_available_and_preserved']})},
        'known_identity_risk_cases': len(full_risks),
        'known_identity_risk_worlds': len({r['world_id'] for r in full_risks}),
        'source_action_pairs': len({tuple(c['candidate'][k] for k in ('producer', 'producer_action', 'consumer', 'consumer_action')) for c in cases}),
        'directed_source_pairs': len({tuple(c['candidate'][k] for k in ('producer', 'consumer')) for c in cases}),
        'actual_action_merge_groups': len(action_merge_groups),
        'actual_action_merge_cases': len({c['case_id'] for c in cases if c['group']['id'] in action_merge_groups}),
        'actual_action_merge_subset': {condition: counts([r for r in rows
            if r['condition'] == condition and r['group'] in action_merge_groups])
            for condition in ('predicate_only', 'full')},
        'physical_rechecks': len(physical_rows), 'execution_input_files_verified': len(checked),
        'returned_plan_validation_violations': [r['id'] for r in rows
            if r['search']['status'] == 'solved'
            and base.replay_evidence(r.get('replay', {})) not in ('valid', 'unknown')],
        'returned_plan_validation_unknowns': [r['id'] for r in rows
            if r['search']['status'] == 'solved'
            and base.replay_evidence(r.get('replay', {})) == 'unknown'],
        'previous18_fresh_search_comparison': {'checks': len(comparisons),
            'search_status_changes': sum(not r['same_search_status'] for r in comparisons),
            'validity_changes': sum(not r['same_validity'] for r in comparisons),
            'causal_status_changes': sum(not r['same_causal_status'] for r in comparisons)},
        'inputs_unchanged': True, 'calls': report['calls'],
        'new_model_calls': 0, 'new_planner_calls_in_this_audit': 0,
        'independent_semantic_labels': 0, 'plan_lengths': summary['plan_lengths'],
        'goal_relevant_source_counts': summary['goal_relevant_source_counts'],
        'limits': ['Posthoc supported-generator census, conditional on accepted interfaces.',
            '70 candidate tasks share 37 exact-world keys and overlapping sources; no iid confidence intervals.',
            '37-world primary table uses representatives fixed before search; context best-of results are not primary.',
            'Returned-plan causal structure is evaluated; absence of a returned composition does not prove none exists.',
            'All source-plan evidence is source-local and incomplete; no joint original-world preservation claim.',
            'Known identity concerns retained; no independent semantic or narrative-quality evaluation.',
            'This is fresh task execution on saved first-repeat domains, not another LLM merge repeat.']}
    save(output / 'analysis.json', metrics)
    save(output / 'source_manifest.json', {'files': {str(p): digest(p) for p in [
        evaluation / 'protocol.json', evaluation / 'report.json', evaluation / 'expanded_summary.json',
        evaluation / 'selected_cases.json', evaluation / 'world_registry.json', parent]},
        'checked_execution_inputs': checked})
    snapshot_implementation(output, [Path(__file__)])
    return metrics


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--evaluation', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    result = audit(args.evaluation, args.output)
    print(json.dumps({k: result[k] for k in ('status', 'all_tasks', 'fixed_world_representatives',
        'same_model_historical_preservation', 'paired_cross_source_cases', 'known_identity_risk_cases')}, indent=2))

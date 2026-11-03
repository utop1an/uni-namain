"""Recompute paper-facing first-repeat statistics from immutable artifacts.

No model requests or planner searches. Rows are descriptive correlated checks,
not independent trials, semantic labels, or estimates across five repetitions.
"""
import argparse
from collections import Counter
from itertools import combinations
from pathlib import Path
import json
import statistics

from rcnc import model_semantics
from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.glaive_merge import action_fields, canonical, rename_vars, rewrite, signed_effects
from rcnc.pddl import parse_sexpr, section, serialize, typed_symbols
from rcnc.revised_multistory import select_groups
from scripts.audit.partial_revised_multistory import audit_response
from scripts.audit.analyze_revised_main import invalid_category
from scripts.experiments import run_revised_multistory as base
from scripts.data.freeze_revised_multistory import verify_frozen


def plan_calls(path):
    steps = section(parse_sexpr(Path(path).read_text(encoding='utf-8')), ':steps')
    if steps is None: raise ValueError('Missing plan steps')
    return steps[1:]


def result_counts(rows):
    anchors = [r for r in rows if r['search_anchor']]
    return {'source_slots': len(rows), 'searches': len(anchors),
        'search_status': dict(Counter(r['search']['status'] for r in anchors)),
        'validated_returns': sum(base.valid(r.get('replay', {})) for r in anchors),
        'returned_unknown': sum(r['search']['status'] == 'solved' and base.replay_evidence(r.get('replay', {})) == 'unknown' for r in anchors),
        'return_violations': sum(base.replay_evidence(r.get('replay', {})) not in ('valid', 'unknown') for r in anchors),
        'transport_status': dict(Counter(r['transport']['status'] for r in rows)),
        'validated_transports': sum(base.valid(r['transport']) for r in rows),
        'transport_unknown': sum(r['transport']['status'] != 'unavailable_valid_native_plan' and base.replay_evidence(r['transport']) == 'unknown' for r in rows),
        'transport_violations': sum(base.replay_evidence(r['transport']) not in ('valid', 'unknown') for r in rows)}


def analyze(campaign, output):
    if output.exists(): raise ValueError('Fresh output required')
    protocol = base.verify(campaign)
    dataset = Path(protocol['dataset']); dataset_check = verify_frozen(dataset)
    repeat = campaign / 'repeat_01'
    report, compilation, judgments, consensus = [base.read(repeat / n) for n in (
        'report.json', 'compilation.json', 'judgments/report.json', 'consensus_audit.json')]
    if report['status'] != 'complete' or judgments['status'] != 'complete': raise ValueError('Incomplete first repeat')
    if len(report['rows']) != 2700 or len({r['id'] for r in report['rows']}) != 2700: raise ValueError('Invalid source denominator')
    if len(compilation['models']) != 900 or len(judgments['rows']) != 4680: raise ValueError('Invalid model denominator')
    evidence_paths = [campaign / 'protocol.json', campaign / 'selected_groups.json',
        repeat / 'report.json', repeat / 'compilation.json', repeat / 'judgments/report.json',
        repeat / 'judgments/groups.json', repeat / 'judgments/packet.json', repeat / 'consensus_audit.json',
        campaign / 'historical_row_provenance.json', dataset / 'protocol.json', dataset / 'cohort.json',
        dataset / 'coverage.json', dataset / 'freeze.json']
    checked = {}
    def require_hash(path, expected):
        path = Path(path); key = str(path.resolve())
        if key not in checked: checked[key] = digest(path)
        if checked[key] != expected: raise ValueError('Changed evidence: ' + key)
    for path, h in compilation['input_sha256'].items(): require_hash(path, h)
    for name, key in [('judgments/groups.json', 'groups_sha256'), ('judgments/report.json', 'judgment_report_sha256'), ('consensus_audit.json', 'consensus_audit_sha256')]:
        require_hash(repeat / name, compilation[key])
    groups = base.read(campaign / 'selected_groups.json')['groups']
    sources = base.load_sources(protocol)
    items = base.read(repeat / 'judgments/packet.json')['items']
    predictions = {r['id']: r for r in judgments['rows']}
    if len(predictions) != len(items) or set(predictions) != {i['id'] for i in items}: raise ValueError('Candidate mismatch')
    historical = {r['id']: Path(r['raw_path']) for r in base.read(campaign / 'historical_row_provenance.json')['rows'] if r.get('raw_path')}
    source_contexts = {}; raw_receipts = []; output_audits = []
    for item in items:
        for side in item['sides']:
            key = (item['kind'], side['reference'])
            if key not in source_contexts:
                source_contexts[key] = json.loads(json.dumps(model_semantics.context(Path(protocol['original_parent']) / 'inputs', side['reference'], item['kind'])))
            if source_contexts[key] != side: raise ValueError('Source context mismatch')
        row = predictions[item['id']]
        if row['status'] not in ('checked', 'invalid'): continue
        raw = repeat / 'remaining_judgments/responses' / item['id'] / 'raw.json'
        if not raw.exists(): raw = historical[item['id']]
        check = audit_response(item, row, base.read(raw), 'compact_kind_specific')
        if not check['status_match']: raise ValueError('Raw response recomputation mismatch: ' + item['id'])
        output_audits.append(check)
        raw_receipts.append({'id': item['id'], 'path': str(raw), 'sha256': digest(raw)})
    print('Raw responses and source contexts verified', len(output_audits), flush=True)
    models = {(m['group'], m['condition']): m for m in compilation['models']}
    audits = {r['group']: r for r in consensus['rows']}
    raw_groups = base.read(repeat / 'judgments/groups.json')['groups']
    certificates = []; model_rows = []; consensus_mismatches = []
    source_rows = {(r['group'], r['condition'], r['source']): r for r in report['rows']}
    for group in groups:
        gid = group['id']; selected = [sources[s] for s in group['sources']]
        predicates, _ = select_groups(selected, raw_groups, 'predicate', threshold=.9)
        pred = models[gid, 'predicate_only']; full = models[gid, 'full']; union = models[gid, 'union']
        actions, _ = select_groups(selected, raw_groups, 'action', threshold=.9, predicate_maps=pred['predicate_maps'])
        if predicates + actions != audits[gid]['consensus_groups']: consensus_mismatches.append(gid)
        if pred['predicate_maps'] != full['predicate_maps']: raise ValueError('Ablation mapping mismatch')
        model_rows.append({'id': gid, 'size': group['size'], 'chain': group['chain_id'],
            'sources': group['sources'], 'predicate_groups': len(predicates), 'action_groups': len(actions),
            'predicates_union': union['business_predicate_count'], 'predicates_full': full['business_predicate_count'],
            'actions_union': union['action_count'], 'actions_full': full['action_count'],
            'predicate_signatures': [tuple(sorted(m['predicate'] for m in g['members'])) for g in predicates],
            'action_signatures': [tuple(sorted(m['action'] for m in g['members'])) for g in actions]})
        for g in actions:
            effects = []; actors = []; preconditions = []; branches = []
            for member in g['members']:
                sid, name = member['action'].split(':'); source = sources[sid]
                f = action_fields(source.domain.actions[name]); variables = list(typed_symbols(f[':parameters']))
                substitution = {variables[j]: '?m' + str(i) for i, j in enumerate(member['order'])}
                effects.append(signed_effects(rename_vars(rewrite(f[':effect'], source, full['predicate_maps'][sid], source.term_map), substitution)))
                actors.append(set(rename_vars([source.term_map.get(a, a) for a in f[':agents']], substitution)))
                preconditions.append(canonical(rename_vars(rewrite(f[':precondition'], source, full['predicate_maps'][sid], source.term_map), substitution)))
                row = source_rows[gid, 'full', sid]
                path = repeat / 'execution' / gid / 'full' / sid / 'transport.pddl'
                calls = plan_calls(path) if base.valid(row['transport']) else []
                fused_name = full['action_maps'][member['action']]['name']
                branches.append({'reference': member['action'], 'transport_available': base.valid(row['transport']),
                    'fused_steps_exercised': sum(call[0] == fused_name for call in calls)})
            if any(e != effects[0] for e in effects) or any(a != actors[0] for a in actors): raise ValueError('Invalid action certificate')
            certificates.append({'group': gid, 'interface': g['id'], 'references': sorted(m['action'] for m in g['members']),
                'mapped_effects_and_actors_equal': True, 'business_preconditions_equal': all(v == preconditions[0] for v in preconditions),
                'branches': branches})
    if consensus_mismatches: raise ValueError('Consensus mismatch: ' + repr(consensus_mismatches))
    print('Consensus and action certificates verified', len(certificates), flush=True)
    # Read-only independent Boolean replay; existing intentional replay remains
    # a separate requirement. Unsupported counterfactual plans stay unknown.
    physical_cache = {}; physical_rows = []; activations = Counter()
    def check_physical(domain, problem, plan, label):
        for path in (domain, problem, plan):
            if str(Path(path).resolve()) not in checked: checked[str(Path(path).resolve())] = digest(Path(path))
        key = tuple(checked[str(Path(f).resolve())] for f in (domain, problem, plan))
        if key not in physical_cache: physical_cache[key] = base.physical(Path(domain), Path(problem), Path(plan))
        x = physical_cache[key]
        if x.get('status') != 'replayed' or x.get('goal') is not True: raise ValueError('Offline replay failed: ' + label)
        physical_rows.append({'id': label, 'steps': x['steps'], 'status': 'valid'})
    for sid, row in report['native'].items():
        for result in (row, row.get('replay', {})):
            for path, h in result.get('input_sha256', {}).items(): require_hash(path, h)
        if base.valid(row.get('replay', {})):
            s = sources[sid]
            check_physical(s.domain_path, s.problem_path, repeat / 'execution/native' / sid / 'plan.pddl', 'native:' + sid)
    for index, row in enumerate(report['rows']):
        domain, problem = Path(row['domain']), Path(row['problem'])
        initial = section(parse_sexpr(problem.read_text(encoding='utf-8')), ':init')[1:]
        active = [a[0] for a in initial if isinstance(a, list) and len(a) == 1 and a[0].endswith('_active')]
        if active != [row['source'] + '_active']: raise ValueError('Changed original-world activation')
        activations[len(active)] += 1
        folder = repeat / 'execution' / row['group'] / row['condition'] / row['source']
        for name, path in [('search', folder / 'search/plan.pddl'), ('replay', folder / 'search/plan.pddl'), ('transport', folder / 'transport.pddl')]:
            for file, h in row.get(name, {}).get('input_sha256', {}).items(): require_hash(file, h)
        if base.valid(row.get('replay', {})): check_physical(domain, problem, folder / 'search/plan.pddl', row['id'] + ':returned')
        if base.valid(row['transport']): check_physical(domain, problem, folder / 'transport.pddl', row['id'] + ':transport')
        if (index + 1) % 900 == 0: print('Source rows verified', index + 1, flush=True)
    by_size = {}; table_rows = []
    for k in (2, 3, 4):
        ms = [m for m in model_rows if m['size'] == k]
        freq = Counter(s for m in ms for s in m['sources'])
        detail = {'groups': len(ms), 'source_frequency_min': min(freq.values()), 'source_frequency_max': max(freq.values()),
            'groups_with_predicate_merge': sum(m['predicate_groups'] > 0 for m in ms),
            'groups_with_action_merge': sum(m['action_groups'] > 0 for m in ms),
            'predicate_groups': sum(m['predicate_groups'] for m in ms), 'action_groups': sum(m['action_groups'] for m in ms),
            'predicates_union': sum(m['predicates_union'] for m in ms), 'predicates_full': sum(m['predicates_full'] for m in ms),
            'actions_union': sum(m['actions_union'] for m in ms), 'actions_full': sum(m['actions_full'] for m in ms)}
        detail['conditions'] = {c: result_counts([r for r in report['rows'] if r['size'] == k and r['condition'] == c]) for c in base.CONDITIONS}
        for c, values in detail['conditions'].items():
            if values['source_slots'] != 100 * k or values['searches'] != 200: raise ValueError('Size/condition denominator changed')
            table_rows.append({'size': k, 'condition': c, **values})
        by_size[str(k)] = detail
    by_kind = {}
    for kind in ('predicate', 'action'):
        rs = [predictions[i['id']] for i in items if i['kind'] == kind]
        by_kind[kind] = {'candidates': len(rs), 'status': dict(Counter(r['status'] for r in rs)),
            'decisions': dict(Counter(r['response']['decision'] for r in rs if r['status'] == 'checked')),
            'invalid_reasons': dict(Counter(invalid_category(r.get('reason', '')) for r in rs if r['status'] == 'invalid'))}
    actual_pred = {m['id'] for m in model_rows if m['predicate_groups']}
    actual_act = {m['id'] for m in model_rows if m['action_groups']}
    scopes = {name: result_counts([r for r in report['rows'] if r['condition'] == 'full' and (ids is None or r['group'] in ids)])
        for name, ids in [('all_full', None), ('actual_predicate_merge', actual_pred), ('actual_action_merge', actual_act)]}
    matched = []
    for row in report['rows']:
        if row['condition'] != 'full' or not row['search_anchor']: continue
        pair = [source_rows[row['group'], c, row['source']] for c in base.CONDITIONS]
        matched.append({'id': row['group'] + ':' + row['source'],
            'same_search_status': len({r['search']['status'] for r in pair}) == 1,
            'same_validation_status': len({base.replay_evidence(r.get('replay', {})) for r in pair}) == 1})
    native = {'registered': 60, 'search_status': dict(Counter(r['status'] for r in report['native'].values())),
        'validated': sum(base.valid(r.get('replay', {})) for r in report['native'].values()),
        'unverified_returned': sum(r['status'] == 'solved' and not base.valid(r.get('replay', {})) for r in report['native'].values())}
    unknowns = [{'id': r['id'], 'source': r['source'], 'reason': r.get('replay', {}).get('status')}
        for r in report['rows'] if r['search']['status'] == 'solved' and base.replay_evidence(r.get('replay', {})) == 'unknown']
    composition = Path('data/validation/revised_multistory_composition_eval_2026_11_02_v1')
    preservation = Path('data/validation/revised_multistory_composition_preservation_2026_11_02_v1')
    base.verify(composition); base.verify(preservation)
    cr = base.read(composition / 'report.json'); cs = base.read(composition / 'eval_summary.json'); cp = base.read(preservation / 'report.json')
    cases = base.read(composition / 'selected_cases.json')['cases']
    cindex = {(r['group'], r['condition']): r for r in cr['rows']}
    if len(cr['rows']) != 108 or len(cindex) != 108: raise ValueError('Composition denominator mismatch')
    ccounts = {c: {'registered': 18, 'valid': sum(r['valid_plan'] for r in cr['rows'] if r['condition'] == c),
        'causal': dict(Counter(r['causal']['status'] for r in cr['rows'] if r['condition'] == c)),
        'search_status': dict(Counter(r['search']['status'] for r in cr['rows'] if r['condition'] == c))} for c in ('union', 'predicate_only', 'full', 'without_producer', 'without_consumer', 'separate_identity')}
    world_keys = {case['group']['id']: json.dumps({k: case['scenario'][k] for k in ('objects', 'facts', 'goal', 'intentions')}, sort_keys=True) for case in cases}
    cross = {g for (g, c), row in cindex.items() if c == 'full' and row['causal']['status'] == 'cross_source_composition'}
    comp_summary = {'groups_censused': 300, 'generated_groups': 35, 'selected_groups': 18,
        'unique_worlds': len(set(world_keys.values())), 'cross_source_groups': len(cross),
        'unique_cross_source_worlds': len({world_keys[g] for g in cross}), 'conditions': ccounts,
        'by_size': cr['by_size_condition'], 'same_model_preservation': cp['counts'],
        'paired_all_sources_available_groups': cs['cross_source_groups_with_all_selected_sources_having_preserved_native_plans'],
        'paired_all_sources_available_unique_worlds': 1,
        'actual_sources': dict(Counter(cindex[g, 'full']['causal']['actual_source_count'] for g in cross)),
        'plan_lengths': dict(Counter(len(cindex[g, 'full']['causal']['steps']) for g in cross)),
        'identity_concern': base.read(composition / 'posthoc_identity_review.json')}
    evidence_paths += [composition / n for n in ('protocol.json', 'report.json', 'eval_summary.json', 'census.json', 'selected_cases.json', 'posthoc_identity_review.json')]
    evidence_paths += [preservation / n for n in ('protocol.json', 'report.json')]
    packet = {'status': 'verified_first_repeat_analysis', 'created_utc': base.now(),
        'repeat_condition': 'single_interrupted_continuation_not_five_repeat_mean',
        'dataset': {'published_records': 192, 'legacy_development': 40, 'legacy_test': 152, 'admitted': 60,
            'corpus_counts': dict(Counter(s['corpus'] for s in protocol['source_rows'])), 'groups': 300, 'chains': 100, 'unique_source_pairs': 538,
            'dataset_freeze_sha256': dataset_check['freeze_sha256']},
        'model': {'name': protocol['model'], 'digest': protocol['model_digest'], 'confidence_threshold': .9,
            'candidate_count': 4680, 'by_kind': by_kind, 'all_status': judgments['status_counts'],
            'invalid_reasons': dict(Counter(invalid_category(r.get('reason', '')) for r in judgments['rows'] if r['status'] == 'invalid')),
            'unavailable_outcomes': [r for r in judgments['rows'] if r['status'] == 'request_failed']},
        'models': {'total': 900, 'full': 300, 'groups_with_predicate_merge': len(actual_pred), 'groups_with_action_merge': len(actual_act),
            'predicate_group_occurrences': sum(m['predicate_groups'] for m in model_rows),
            'action_group_occurrences': sum(m['action_groups'] for m in model_rows),
            'unique_predicate_groups': len({tuple(g) for m in model_rows for g in m['predicate_signatures']}),
            'unique_action_groups': len({tuple(g) for m in model_rows for g in m['action_signatures']}),
            'action_branch_occurrences': sum(len(c['branches']) for c in certificates),
            'branches_with_available_native_plan': sum(b['transport_available'] for c in certificates for b in c['branches']),
            'branches_exercised_by_native_transport': sum(b['fused_steps_exercised'] > 0 for c in certificates for b in c['branches']),
            'groups_with_unequal_business_preconditions': sum(not c['business_preconditions_equal'] for c in certificates)},
        'native': native, 'by_size': by_size, 'preservation_scopes': scopes,
        'matched_anchor_queries': {'count': len(matched), 'same_search_status': sum(r['same_search_status'] for r in matched),
            'same_validation_status': sum(r['same_validation_status'] for r in matched)},
        'main_totals': result_counts(report['rows']), 'returned_unknowns': unknowns,
        'composition': comp_summary,
        'verification': {'dataset_verified': True, 'compiled_models_verified': 900, 'original_world_activation_counts': dict(activations),
            'raw_responses_redecoded': len(output_audits), 'source_symbols_rechecked': len(source_contexts),
            'consensus_models_recomputed': 300, 'action_certificates_rechecked': len(certificates),
            'physical_checks': len(physical_rows), 'unique_physical_artifact_triples': len(physical_cache),
            'physical_steps': sum(r['steps'] for r in physical_rows), 'physical_violations': 0, 'hashed_execution_inputs': len(checked)},
        'new_model_calls': 0, 'new_planner_calls': 0, 'independent_semantic_labels': 0,
        'interpretation': 'Descriptive complete-first-repeat assessment. Source worlds are isolated; composition is a separate posthoc conditional diagnostic. No iid confidence intervals, five-repeat SD, semantic-accuracy or speedup claim.'}
    output.mkdir(parents=True)
    save(output / 'analysis.json', packet)
    save(output / 'group_metrics.json', {'rows': model_rows})
    save(output / 'source_metrics.json', {'rows': table_rows})
    save(output / 'action_certificates.json', {'rows': certificates})
    save(output / 'raw_response_receipts.json', {'rows': raw_receipts})
    save(output / 'physical_rechecks.json', {'rows': physical_rows})
    save(output / 'paired_anchor_checks.json', {'rows': matched})
    save(output / 'source_manifest.json', {'files': {str(f): digest(f) for f in evidence_paths},
        'raw_responses': 'raw_response_receipts.json', 'execution_inputs': checked})
    snapshot_implementation(output, [Path(__file__), Path('tests/test_revised_paper_eval.py')])
    return packet


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__); p.add_argument('--campaign', type=Path, required=True); p.add_argument('--output', type=Path, required=True)
    a = p.parse_args(); r = analyze(a.campaign, a.output)
    print(json.dumps({k: r[k] for k in ('status', 'native', 'models', 'verification')}, indent=2))

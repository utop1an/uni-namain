"""Raw-model matched control, original plans, unequal-precondition branch audit."""
import argparse
from collections import Counter
import copy
import json
from pathlib import Path
import shutil

from unified_planning.io import PDDLReader
from unified_planning.shortcuts import SequentialSimulator

from rcnc.conditional_merge import build, canonical_action, certify_replacement, fields
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.narrative_pipeline import map_problem
from rcnc.pddl import parse_domain
from rcnc.validation import validate_artifacts
from scripts.audit.audit_semantic_facets_comparison import verify_model
from scripts.audit.audit_transport_merge import transport, trace
from scripts.experiments.run_role_contract_merge import BUNDLES, check_freeze, clearance_variant
from scripts.experiments.run_transport_merge import CONDITIONS


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def compact_decisions(report):
    return [{'id': r['id'], 'status': r['status'], 'decision': r.get('response', {}).get('decision'),
             'confidence': r.get('response', {}).get('confidence'), 'eval_count': r.get('eval_count'),
             'done_reason': r.get('done_reason'), 'response': r.get('response'), 'facets': r.get('semantic_facets')}
            for r in report['rows']]


def branch_probe(model, query, source, action_name, old_args, expected, output):
    output.mkdir(parents=True)
    mapping = map_problem(query, model, output / 'problem.pddl')
    shutil.copyfile(model / 'meta_domain.pddl', output / 'domain.pddl')
    save(output / 'query.json', query)
    meta = read(model / 'meta_domain.json')
    problem = PDDLReader().parse_problem(str(output / 'domain.pddl'), str(output / 'problem.pddl'))
    params = [None] * len(old_args)
    for index, target_index in enumerate(meta['action_parameter_maps'][source][action_name]):
        params[target_index] = problem.object(mapping['objects'][old_args[index]])
    action = problem.action(meta['action_maps'][source][action_name])
    with SequentialSimulator(problem) as simulator:
        actual = simulator.is_applicable(simulator.get_initial_state(), action, params)
    return {'id': output.name, 'status': 'PASS' if actual == expected else 'FAIL',
            'expected_applicable': expected, 'actual_applicable': actual,
            'action': action.name, 'query_sha256': digest(output / 'query.json'),
            'scope': 'Declared source-only prerequisite probe; no planner/model calls or independent semantic label.'}


def audit(root, output, *, compare_budget=True):
    require_empty_output(output)
    output.mkdir(parents=True)
    check_freeze(root)
    protocol, manifest, solver = read(root / 'protocol.json'), read(root / 'manifest.json'), read(root / 'report.json')
    if solver['status'] != 'complete' or solver['manifest_sha256'] != digest(root / 'manifest.json'):
        raise ValueError('Incomplete or changed solver run')
    for key in ('inputs_unchanged', 'implementation_unchanged', 'solver_integrity'):
        if solver[key] is not True:
            raise ValueError('Runtime integrity failed: ' + key)
    for p, h in manifest['input_sha256'].items():
        if digest(Path(p)) != h:
            raise ValueError('Frozen input changed: ' + p)
    if [r['id'] for r in solver['rows']] != [r['id'] for r in manifest['rows']] or len(solver['rows']) != 126:
        raise ValueError('Planning denominator changed')
    control_root = Path(protocol.get('reused_budget_control', root / 'budget_control')) if compare_budget else None
    control_reused = compare_budget and 'reused_budget_control' in protocol
    primary = verify_model(root)
    control = verify_model(control_root) if compare_budget else {'requests_attempted': 0, 'status_counts': {}, 'rows': []}
    pp = read(root / 'judgments/packet.json')['items']
    if compare_budget:
        cp = read(control_root / 'judgments/packet.json')['items']
        if pp[:5] != cp:
            raise ValueError('Matched output-contract inputs differ')
        pr, cr = read(root / 'judgments/requests.json'), read(control_root / 'judgments/requests.json')
        for candidate in cp:
            a, b = copy.deepcopy(pr[candidate['id']]), copy.deepcopy(cr[candidate['id']])
            if a['messages'][0]['content'].splitlines()[-1] != b['messages'][0]['content'].splitlines()[-1]:
                raise ValueError('Visible model input differs')
            for request in (a, b):
                del request['messages']; del request['format']
            if a != b:
                raise ValueError('Model/options differ beyond output contract')
    elif protocol.get('stability_repeat') != 1 or protocol.get('planned_solver_calls') != 126:
        raise ValueError('No-control mode is restricted to the preregistered first stability repeat')
    followup = None
    if control_reused:
        parent = Path(protocol['followup_parent'])
        before = read(parent / 'protocol.json')
        for key in ('pairs', 'bundles', 'queries', 'conditions', 'primary_threshold', 'predeclared_sensitivity_threshold', 'budget', 'solver_tasks'):
            if protocol[key] != before[key]:
                raise ValueError('Prompt followup changes nonprompt protocol field: ' + key)
        for a, b in zip(protocol['originals'], before['originals']):
            if {k: v for k, v in a.items() if k != 'directory'} != {k: v for k, v in b.items() if k != 'directory'}:
                raise ValueError('Original world specification changed')
            for name in ('domain.pddl', 'problem.pddl'):
                if digest(Path(a['directory']) / name) != digest(Path(b['directory']) / name):
                    raise ValueError('Original world bytes changed')
        if pp != read(parent / 'judgments/packet.json')['items']:
            raise ValueError('Eleven model contexts differ from previous condition')
        followup = {'parent': parent.as_posix(), 'eleven_candidate_contexts_identical': True,
                    'planning_inputs_and_rules_identical': True, 'parent_model_report_sha256': digest(parent / 'judgments/report.json')}
    base = parse_domain(root / 'inputs/DLOG_domainfile.pddl')
    variant = parse_domain(root / 'inputs/DLOGC_domainfile.pddl')
    expected = clearance_variant(base)
    if variant.predicates != expected.predicates or variant.actions != expected.actions:
        raise ValueError('Clearance derivative differs from frozen two-conjunct rule')
    variants = {'source_predicates': len(base.predicates), 'variant_predicates': len(variant.predicates),
                'added_predicates': sorted(set(variant.predicates) - set(base.predicates)),
                'effects_unchanged': all(fields(a)[':effect'] == fields(variant.actions[n])[':effect'] for n, a in base.actions.items())}
    violations, validations, rows = [], [], []
    indexed = {r['id']: r for r in solver['rows']}
    for row in solver['rows']:
        if row['status'] == 'solved':
            verdict = validate_artifacts(root / 'solver/tasks' / row['id'])
            validations.append({'id': row['id'], **verdict})
            if verdict['status'] != 'VALID':
                violations.append(row['id'])
    for case in protocol['originals']:
        native_id = case['id'] + '__native'
        for condition in CONDITIONS:
            row = {'id': case['id'] + '/' + condition, 'unit': case['unit'], 'source': case['source'],
                   'bundle': case['bundle'], 'condition': condition, 'duplicate_of': case.get('duplicate_of')}
            if indexed[native_id]['status'] != 'solved':
                row.update(status='unavailable_no_native_goal_plan', native_status=indexed[native_id]['status'])
            else:
                target = root / 'bundle/tasks' / (case['id'] + '__' + condition)
                try:
                    row.update(transport(case['source'], root / 'solver/tasks' / native_id, target,
                        root / 'models' / case['bundle'] / condition, read(target / 'query_mapping.json'),
                        output / 'transports' / row['id']))
                except Exception as exc:
                    row.update(status='FAIL', reason=f'{type(exc).__name__}: {exc}')
                    violations.append(row['id'])
            rows.append(row)
    witness = Path('data/validation/conditional_merge_branch_witness_2026_10_27_v1/native')
    original_soup = root / 'native/narrative__soup'
    if any(digest(witness / n) != digest(original_soup / n) for n in ('domain.pddl', 'problem.pddl')):
        raise ValueError('Existing SOUP witness belongs to a different source world')
    if validate_artifacts(witness)['status'] != 'VALID':
        raise ValueError('Existing SOUP witness invalid')
    witness_hashes = {p.as_posix(): digest(p) for p in witness.iterdir() if p.is_file()}
    for condition in ('full090', 'full080'):
        target = root / 'bundle/tasks' / ('narrative__soup__' + condition)
        row = {'id': 'reused_soup_witness/' + condition, 'unit': 'reused_witness', 'source': 'SOUP', 'bundle': 'narrative', 'condition': condition}
        row.update(transport('SOUP', witness, target, root / 'models/narrative' / condition,
                             read(target / 'query_mapping.json'), output / 'transports' / row['id']))
        rows.append(row)
    merges = []
    for bundle in BUNDLES:
        for condition in CONDITIONS:
            folder = root / 'models' / bundle / condition
            result, meta = read(folder / 'validation.json'), read(folder / 'meta_domain.json')
            domain = parse_domain(folder / 'meta_domain.pddl')
            spec = read(folder / 'merge_specification.json')
            stage = parse_domain(folder / 'predicate_model/meta_domain.pddl')
            stage_meta = read(folder / 'predicate_model/meta_domain.json')
            certificates = []
            for decision in [d for d in result['decisions'] if d['kind'] == 'action' and d['status'] == 'accepted']:
                group = next(g for g in spec['action_candidates'] if g['id'] == decision['id'])
                originals = []
                for member in group['members']:
                    s, a = member['action'].split(':')
                    originals.append(canonical_action(stage.actions[stage_meta['action_maps'][s][a]], member['order']))
                    if meta['action_maps'][s][a] != decision['target']:
                        raise ValueError('Accepted action not actually mapped many-to-one')
                if len(meta['action_origins'][decision['target']]) != len(originals):
                    raise ValueError('Lost provenance branch')
                certificate = certify_replacement(originals, domain.actions[decision['target']])
                if certificate['status'] != 'accepted':
                    raise ValueError('Merged action recertification failed')
                certificates.append({'id': decision['id'], 'target': decision['target'], 'certificate': certificate})
            merges.append({'bundle': bundle, 'condition': condition, 'source_actions': result['source_actions'], 'actions': len(domain.actions),
                'source_predicates': result['source_predicates'], 'logical_predicates': len(domain.predicates) - len(meta['type_guards']),
                'accepted_actions': [c['id'] for c in certificates], 'certificates': certificates, 'decisions': result['decisions']})
    # Compile the budget-only model judgments as a diagnostic, without searching.
    control_models = []
    control_groups = read(control_root / 'judgments/groups.json')['groups'] if compare_budget else []
    inputs = control_root / 'inputs' if compare_budget else None
    for threshold in ((.9, .8) if compare_budget else ()):
        spec = {'version': 1, 'decision_basis': 'machine_hypothesis', 'semantic_min_confidence': threshold,
            'source_sha256': {p.name: digest(p) for p in inputs.iterdir()},
            'type_groups': [{'members': ['LOG98:object', 'DLOG:object'], 'evidence': 'Same declared object role with separate guards'}],
            'predicate_candidates': control_groups[:2], 'action_candidates': control_groups[2:]}
        result = build(inputs, output / 'budget_only_compilation' / str(threshold), spec)
        control_models.append({'threshold': threshold, 'merged_action_groups': result['merged_action_groups'],
                               'decisions': result['decisions'], 'planner_calls': 0})
    crosses = []
    for bundle, cases in protocol['queries'].items():
        for case in cases:
            for suffix in ('090', '080'):
                full, pred = 'full' + suffix, 'predicate' + suffix
                conditions = ['no_share', pred, full, *['remove_' + s + suffix for s in BUNDLES[bundle]]]
                statuses = {c: indexed[bundle + '__' + case + '__' + c]['status'] for c in conditions}
                meta = read(root / 'models' / bundle / full / 'meta_domain.json')
                steps = trace(root / 'solver/tasks' / (bundle + '__' + case + '__' + full), meta)
                crosses.append({'id': bundle + '/' + case + '/' + suffix, 'bundle': bundle, 'case': case,
                    'threshold': float('.' + suffix[1:]), 'unit': 'denied_clearance_control' if case == 'loading_not_cleared' else 'authored_cross_task',
                    'statuses': statuses, 'plan_steps': steps, 'plan_length': len(steps) if statuses[full] == 'solved' else None,
                    'uses_merged_action': any(len(s['possible_origins']) > 1 for s in steps),
                    'benefit_over_no_share': statuses[full] == 'solved' and statuses['no_share'] == 'unsolvable',
                    'both_sources_necessary': statuses[full] == 'solved' and all(statuses['remove_' + s + suffix] == 'unsolvable' for s in BUNDLES[bundle]),
                    'predicate_only_already_solves': statuses[pred] == 'solved'})
    probes = []
    for condition in ('full090', 'full080'):
        for allowed in (False, True):
            case = next(c for c in protocol['originals'] if c['id'] == 'clearance__' + ('allowed' if allowed else 'denied'))
            probes.append(branch_probe(root / 'models/clearance' / condition, case['query'], 'DLOGC', 'load-truck',
                ['v_parcel', 'v_truck', 'v_a'], allowed, output / 'probes' / ('clearance_' + str(allowed) + '_' + condition)))
            query = {'objects': {'visitor': 'SOUP:entity', 'start_site': 'SOUP:location', 'end_site': 'SOUP:location'},
                'initial': [['SOUP:at', 'visitor', 'start_site']],
                'goal': {'positive': [['SOUP:at', 'visitor', 'end_site']]}}
            if allowed:
                query['initial'].append(['SOUP:holds', 'visitor', 'SOUP:sausage_skewer'])
            probes.append(branch_probe(root / 'models/narrative' / condition, query, 'SOUP', 'travel_to',
                ['visitor', 'end_site', 'start_site'], allowed, output / 'probes' / ('skewer_' + str(allowed) + '_' + condition)))
    violations.extend(r['id'] for r in probes if r['status'] != 'PASS')
    result = {'status': 'verified' if not violations else 'audit_failed', 'integrity_verified': True,
        'raw_predictions_verified': True, 'matched_control_inputs': True if compare_budget else None,
        'only_contract_differs_in_matched_requests': True if compare_budget else None,
        'model_calls': primary['requests_attempted'] + (0 if control_reused else control['requests_attempted']),
        'budget_control_reused': control_reused, 'budget_control_requests': control['requests_attempted'],
        'prompt_followup_comparison': followup, 'planner_calls': solver['actual_solver_calls'],
        'task_count': len(solver['rows']), 'solver_status_counts': solver['status_counts'],
        'model_conditions': {**({'budget_only': {'status_counts': control['status_counts'], 'rows': compact_decisions(control)}} if compare_budget else {}),
                             ('compact_kind_specific' if not compare_budget else 'role_identity_first' if control_reused else 'optional_roles'): {'status_counts': primary['status_counts'], 'rows': compact_decisions(primary)}},
        'budget_only_compilation': control_models, 'variant_provenance': variants, 'returned_plans': validations,
        'replay_count': len(rows), 'rows': rows, 'replay_status_counts': dict(Counter(r['status'] for r in rows)),
        'replay_by_unit': {u: dict(Counter(r['status'] for r in rows if r['unit'] == u)) for u in sorted({r['unit'] for r in rows})},
        'replayed_steps': sum(r.get('steps', 0) for r in rows), 'truth_checks': sum(r.get('truth_checks', 0) for r in rows),
        'merges': merges, 'cross_source': crosses, 'prerequisite_probes': probes, 'violations': violations,
        'reused_witness_sha256': witness_hashes,
        'parent_reports': {p.as_posix(): digest(p) for p in [root / 'report.json', root / 'manifest.json', root / 'pre_model_freeze.json',
                            root / 'judgments/report.json', *([control_root / 'judgments/report.json'] if compare_budget else [])]},
        'scope': protocol['scope'] + ' Clearance derivative is not independent-source evidence; the same LOG98 problem is repeated in two bundles. Two SOUP witness transports reuse an existing plan, not fresh planner calls. Threshold views are correlated. Budget-only compilation is diagnostic, with zero planner calls.'}
    result['implementation_sha256'] = snapshot_implementation(output, [Path(__file__), Path('scripts/audit/audit_transport_merge.py'),
        Path('scripts/audit/audit_semantic_facets_comparison.py'), Path('rcnc/bidirectional_replay.py'), Path('rcnc/validation.py')])
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--root', required=True, type=Path)
    p.add_argument('--output', required=True, type=Path)
    p.add_argument('--without-budget-control', action='store_true')
    args = p.parse_args()
    r = audit(args.root, args.output, compare_budget=not args.without_budget_control)
    print(json.dumps({k: r[k] for k in ('status', 'model_calls', 'planner_calls', 'replay_by_unit', 'replayed_steps', 'truth_checks', 'violations')}, indent=2))

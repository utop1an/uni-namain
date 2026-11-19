"""Audit automatic judgments, actual merges, all task rows and forward plans."""
import argparse
from collections import Counter
import json
from pathlib import Path

from rcnc.domain_building import digest, require_empty_output, save
from rcnc.model_semantics import to_group
from rcnc.pddl import parse_domain, parse_sexpr, section, serialize
from rcnc.validation import validate_artifacts
from scripts.audit.audit_conditional_merge import state_replay
from scripts.experiments.run_union_regression import translate_plan


def read(path): return json.loads(path.read_text(encoding='utf-8'))


def audit(root, output):
    require_empty_output(output); output.mkdir(parents=True)
    manifest, report, protocol = [read(root / p) for p in ('manifest.json', 'report.json', 'protocol.json')]
    if report['manifest_sha256'] != digest(root / 'manifest.json'): raise ValueError('Manifest changed')
    for key in ('inputs_unchanged', 'implementation_unchanged', 'solver_integrity'):
        if report.get(key) is not True: raise ValueError('Execution integrity failed: ' + key)
    for p, h in manifest['input_sha256'].items():
        if digest(Path(p)) != h: raise ValueError('Frozen input changed: ' + p)
    if len(report['rows']) != protocol['solver_tasks'] or [r['id'] for r in report['rows']] != [r['id'] for r in manifest['rows']]:
        raise ValueError('Task denominator or identities changed')
    judgments = read(root / 'judgments/report.json')
    packet = read(root / 'judgments/packet.json')
    groups = read(root / 'judgments/groups.json')['groups']
    if len(packet['items']) != judgments['candidate_count'] or groups != [to_group(i, r) for i, r in zip(packet['items'], judgments['rows'])]:
        raise ValueError('Compiled groups do not reproduce the frozen model judgments')
    lookup = {r['id']: r for r in report['rows']}; plans = []
    for item in report['rows']:
        folder = root / 'solver/tasks' / item['id']
        if (folder / 'plan.txt').exists():
            valid = validate_artifacts(folder)
            plans.append({'id': item['id'], **valid})
            if valid['status'] != 'VALID': raise ValueError('Returned plan validation failed')
    merges = []; rows = []; cross = []
    for bundle, sources in protocol['bundles'].items():
        primary = root / 'models' / bundle / 'model_full'
        meta, compiled = read(primary / 'meta_domain.json'), read(primary / 'validation.json')
        domain = parse_domain(primary / 'meta_domain.pddl')
        expected_groups = [g for p, g in zip(packet['items'], groups) if p['bundle'] == bundle]
        applied = read(primary / 'merge_specification.json')
        if applied['predicate_candidates'] + applied['action_candidates'] != expected_groups:
            raise ValueError('Model judgments were changed before compilation')
        merges.append({'bundle': bundle, 'source_actions': compiled['source_actions'], 'actions': len(domain.actions),
                       'source_predicates': compiled['source_predicates'],
                       'logical_predicates': len(domain.predicates) - len(meta['type_guards']),
                       'decisions': compiled['decisions']})
        for source in sources:
            for unit in ['original', *(['witness'] if source in protocol['witness_goals'] else [])]:
                native_id = source + ('__native' if unit == 'original' else '__witness')
                native = root / 'solver/tasks' / native_id
                for condition in ('no_share', 'model_predicate', 'model_full'):
                    row = {'id': source + '__' + unit + '__' + condition, 'source': source, 'unit': unit, 'condition': condition}
                    if lookup[native_id]['status'] != 'solved':
                        row.update(status='not_replayed', reason='source_plan_unavailable', source_outcome=lookup[native_id]['status'])
                    else:
                        model = root / 'models' / bundle / condition
                        inputs = root / ('inputs' if unit == 'original' else 'witness_inputs/' + source)
                        target = output / 'replays' / row['id']
                        try:
                            target_problem = model / 'problems' / f'{source}_problemfile.pddl'
                            if unit == 'witness':
                                mm = read(model / 'meta_domain.json')
                                p = parse_sexpr(target_problem.read_text(encoding='utf-8'))
                                goal = protocol['witness_goals'][source]
                                args = [mm['constant_maps'][source][a] for a in goal[1:]]
                                section(p, ':goal')[1] = [mm['predicate_maps'][source][goal[0]],
                                    *[args[i] for i in mm['predicate_orders'][source][goal[0]]]]
                                target.mkdir(parents=True)
                                target_problem = target / 'witness_problem.pddl'
                                target_problem.write_text(serialize(p), encoding='utf-8')
                            translated = translate_plan(source, inputs, model, native, target, problem_path=target_problem)
                            if translated['validation']['status'] != 'VALID': raise ValueError(str(translated))
                            row.update(state_replay(source, inputs, model, native, target))
                        except Exception as exc:
                            row.update(status='FAIL', reason=f'{type(exc).__name__}: {exc}')
                    rows.append(row)
        for case in protocol['queries'][bundle]:
            prefix = bundle + '__' + case + '__'
            primary_row = lookup[prefix + 'model_full']
            calls = []
            plan = root / 'solver/tasks' / primary_row['id'] / 'plan.txt'
            if plan.exists():
                for line in plan.read_text(encoding='utf-8').splitlines():
                    text = line.split(';')[0].strip()
                    if text:
                        call = parse_sexpr(text)
                        calls.append({'action': call[0], 'arguments': call[1:], 'possible_origins': meta['action_origins'][call[0]]})
            control = {s: lookup[prefix + 'remove_' + s]['status'] for s in sources}
            no_share = lookup[prefix + 'no_share']['status']
            cross.append({'id': bundle + '__' + case, 'bundle': bundle, 'no_share': no_share,
                          'predicate_only': lookup[prefix + 'model_predicate']['status'], 'full': primary_row['status'],
                          'length': primary_row.get('plan_length'), 'source_removals': control,
                          'benefit_over_no_share': primary_row['status'] == 'solved' and no_share == 'unsolvable',
                          'all_sources_necessary': primary_row['status'] == 'solved' and all(v == 'unsolvable' for v in control.values()),
                          'uses_merged_action': any(a['action'].startswith('shared__a_') for a in calls), 'plan': calls})
    result = {'status': 'PASS' if not any(r['status'] == 'FAIL' for r in rows) else 'FAIL',
              'integrity_verified': True, 'task_count': len(report['rows']), 'returned_plans': len(plans),
              'model_status_counts': judgments['status_counts'], 'model_decision_counts': judgments['decision_counts'],
              'model_requests': judgments['requests_attempted'], 'merges': merges,
              'replay_count': len(rows), 'rows': rows, 'replay_status_counts': dict(Counter(r['status'] for r in rows)),
              'replay_by_unit': {u: dict(Counter(r['status'] for r in rows if r['unit'] == u)) for u in ('original', 'witness')},
              'replayed_steps': sum(r.get('steps', 0) for r in rows), 'truth_checks': sum(r.get('truth_checks', 0) for r in rows),
              'cross_source': cross, 'cross_source_benefit_count': sum(r['benefit_over_no_share'] for r in cross),
              'semantic_controls': [{'id': r['id'], 'status': r['status'], 'plan_length': r.get('plan_length')}
                                    for r in report['rows'] if r['family'] == 'semantic_control'],
              'all_sources_necessary_count': sum(r['all_sources_necessary'] for r in cross),
              'scope': 'Automatic unreviewed hypotheses on preselected development candidates; authored tasks in three explicit worlds; no independent semantic accuracy or held-out generalization'}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__); p.add_argument('--root', type=Path, required=True); p.add_argument('--output', type=Path, required=True)
    a = p.parse_args(); r = audit(a.root, a.output)
    print(json.dumps({k: r[k] for k in ['status', 'model_status_counts', 'model_decision_counts', 'replay_status_counts', 'replay_by_unit', 'cross_source_benefit_count']}, indent=2))

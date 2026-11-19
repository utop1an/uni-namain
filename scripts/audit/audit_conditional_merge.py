"""Public-simulator state replay and provenance audit for conditional fusion."""
import argparse
from collections import Counter
import copy
import itertools
import json
from pathlib import Path

from rcnc.conditional_merge import certify_replacement
from rcnc.domain_building import digest, require_empty_output, save
from rcnc.pddl import parse_domain, parse_sexpr
from rcnc.validation import validate_artifacts
from scripts.experiments.run_union_regression import translate_plan


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def state_replay(source, inputs, model, native_directory, target_directory):
    """Check every Boolean source atom, including false facts, at every step."""
    from unified_planning.io import PDDLReader
    from unified_planning.shortcuts import SequentialSimulator
    reader = PDDLReader()
    src = reader.parse_problem(str(inputs / f'{source}_domainfile.pddl'), str(inputs / f'{source}_problemfile.pddl'))
    dst = reader.parse_problem(str(target_directory / 'domain.pddl'), str(target_directory / 'problem.pddl'))
    old = reader.parse_plan(src, str(native_directory / 'plan.txt'))
    new = reader.parse_plan(dst, str(target_directory / 'plan.txt'))
    meta = read(model / 'meta_domain.json')
    symbols = {**meta['constant_maps'][source], **meta['namespaces'][source].get('objects', {})}
    pairs = []
    for fluent in src.fluents:
        if not fluent.type.is_bool_type(): raise ValueError('Boolean replay only')
        for args in itertools.product(*(list(src.objects(p.type)) for p in fluent.signature)):
            target_args = [dst.object(symbols[a.name]) for a in args]
            order = meta['predicate_orders'][source][fluent.name]
            pairs.append((fluent(*args), dst.fluent(meta['predicate_maps'][source][fluent.name])(*[target_args[i] for i in order])))
    checks = 0
    with SequentialSimulator(src) as left, SequentialSimulator(dst) as right:
        a, b = left.get_initial_state(), right.get_initial_state()
        def compare():
            nonlocal checks
            for x, y in pairs:
                checks += 1
                if a.get_value(x) != b.get_value(y):
                    raise ValueError(f'State projection mismatch: {x} -> {y}')
        compare()
        if len(old.actions) != len(new.actions): raise ValueError('Plan length differs')
        for x, y in zip(old.actions, new.actions):
            a = left.apply(a, x.action, x.actual_parameters)
            b = right.apply(b, y.action, y.actual_parameters)
            if a is None or b is None: raise ValueError('Source or transported step is not executable')
            compare()
        if not left.is_goal(a) or not right.is_goal(b): raise ValueError('Goal not preserved')
    return {'status': 'PASS', 'steps': len(old.actions), 'states': len(old.actions) + 1,
            'source_atoms_per_state': len(pairs), 'truth_checks': checks}


def audit(root, output):
    require_empty_output(output); output.mkdir(parents=True)
    manifest, report = read(root / 'manifest.json'), read(root / 'report.json')
    for key in ('inputs_unchanged', 'implementation_unchanged', 'solver_integrity'):
        if report.get(key) is not True: raise ValueError('Failed runtime integrity: ' + key)
    if report['manifest_sha256'] != digest(root / 'manifest.json'): raise ValueError('Manifest changed')
    for path, expected in manifest['input_sha256'].items():
        if digest(Path(path)) != expected: raise ValueError('Input changed: ' + path)
    if len(report['rows']) != manifest['task_count'] or [r['id'] for r in report['rows']] != [r['id'] for r in manifest['rows']]:
        raise ValueError('Task denominator or ordering differs')
    rows = []
    saved_plans = []
    lookup = {r['id']: r for r in report['rows']}
    for item in report['rows']:
        directory = root / 'solver/tasks' / item['id']
        if (directory / 'plan.txt').exists():
            validation = validate_artifacts(directory)
            saved_plans.append({'id': item['id'], **validation})
            if validation['status'] != 'VALID': raise ValueError('Returned plan invalid: ' + item['id'])
    for source in ('ACCO', 'BIRT', 'SOUP'):
        for condition in ('no_share', 'predicate_only', 'conditional', 'formal_only'):
            row = {'id': source + '__' + condition, 'source': source, 'condition': condition}
            native = lookup[source + '__native']
            if native['status'] != 'solved':
                row.update(status='not_replayed', reason='native_goal_plan_unavailable')
            else:
                model = root / 'models' / condition
                target = output / 'replays' / row['id']
                try:
                    replay = translate_plan(source, root / 'inputs', model, root / 'solver/tasks' / (source + '__native'), target)
                    row.update(validation=replay['validation'])
                    if replay['validation']['status'] != 'VALID': raise ValueError('Transported plan failed validation')
                    row.update(state_replay(source, root / 'inputs', model, root / 'solver/tasks' / (source + '__native'), target))
                except Exception as exc:
                    row.update(status='FAIL', reason=f'{type(exc).__name__}: {exc}')
            rows.append(row)
    model = root / 'models/conditional'
    meta = read(model / 'meta_domain.json'); result = read(model / 'validation.json')
    domain = parse_domain(model / 'meta_domain.pddl')
    accepted = [r for r in result['decisions'] if r['kind'] == 'action' and r['status'] == 'accepted']
    for row in accepted:
        if row['target'] not in domain.actions or len(meta['action_origins'][row['target']]) != len(row['members']):
            raise ValueError('Missing many-to-one action or origins')
    primary = {r['problem_id']: r for r in report['rows'] if r['family'] == 'cross' and r['representation'] == 'conditional'}
    cross = []
    for case, item in primary.items():
        directory = root / 'solver/tasks' / item['id']
        trace = []
        if (directory / 'plan.txt').exists():
            for line in (directory / 'plan.txt').read_text(encoding='utf-8').splitlines():
                line = line.split(';')[0].strip()
                if line:
                    call = parse_sexpr(line)
                    trace.append({'action': call[0], 'arguments': call[1:],
                                  'possible_origins': meta['action_origins'][call[0]]})
        cross.append({'id': case, 'primary_status': item['status'], 'plan_steps': trace,
            'no_share_status': lookup[case + '__no_share']['status'],
            'predicate_only_status': lookup[case + '__predicate_only']['status'],
            'source_removals': {s: lookup[case + '__remove_' + s]['status'] for s in ('ACCO', 'BIRT', 'SOUP')},
            'uses_merged_action': any(s['action'].startswith('shared__a_') for s in trace)})
    birt = parse_domain(root / 'inputs/BIRT_domainfile.pddl')
    old = birt.actions['turn_key_on_beech']; strengthened = copy.deepcopy(old)
    strengthened[5] = ['and', copy.deepcopy(old[5]), ['has', '?n', '?k']]
    old_travel = birt.actions['travel_to_trysting_place']; changed_effect = copy.deepcopy(old_travel)
    changed_effect[7] = ['and', copy.deepcopy(old_travel[7]), ['shrunk', '?n']]
    controls = {'constructed_BIRT_strengthening': certify_replacement([old], strengthened),
                'constructed_extra_effect': certify_replacement([old_travel], changed_effect),
                'semantic_trap': {c: lookup['semantic_trap__' + c]['status'] for c in ('conditional', 'formal_only')}}
    logical_count = len(domain.predicates) - len(meta['type_guards'])
    final = {'status': 'PASS' if all(r['status'] == 'PASS' for r in rows) else 'completed_with_gaps',
             'task_count': len(report['rows']), 'actual_solver_calls': report['actual_solver_calls'],
             'returned_plans': saved_plans, 'replay_count': len(rows), 'rows': rows,
             'replay_status_counts': dict(Counter(r['status'] for r in rows)),
             'total_replayed_steps': sum(r.get('steps', 0) for r in rows),
             'total_truth_checks': sum(r.get('truth_checks', 0) for r in rows),
             'merge_counts': {'source_actions': result['source_actions'], 'merged_actions': len(domain.actions),
                'source_predicates': result['source_predicates'], 'merged_logical_predicates': logical_count,
                'static_membership_predicates': len(meta['type_guards'])},
             'merge_decisions': result['decisions'], 'cross_source': cross, 'controls': controls,
             'integrity_verified': True,
             'scope': 'Known-source development comparison with authored semantic hypotheses and tasks; finite replay, no independent semantic accuracy or action-merge reachability gain claim'}
    save(output / 'report.json', final)
    return final


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', required=True, type=Path); parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args(); result = audit(args.root, args.output)
    print(json.dumps({k: result[k] for k in ('status', 'task_count', 'merge_counts', 'replay_status_counts', 'controls')}, indent=2))

"""Independent trace replay, goal-plan transport and scale-control accounting."""
import argparse
from collections import Counter
import json
from pathlib import Path

from rcnc.bidirectional_replay import replay_directions
from rcnc.domain_building import digest, require_empty_output, save


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def check_pins(manifest):
    if not all(digest(Path(p)) == h for p, h in manifest['input_sha256'].items()):
        raise ValueError('Frozen input drift')


def replay(root, output):
    from unified_planning.io import PDDLReader
    from unified_planning.plans import ActionInstance, SequentialPlan
    from scripts.experiments.reference_prefix_compare import compare_states_public
    manifest, report = read(root / 'manifest.json'), read(root / 'report.json')
    if report['status'] != 'complete' or len(report['rows']) != manifest['pair_count']:
        raise ValueError('Incomplete registered pair denominator')
    check_pins(manifest)
    rows = []
    for pair in report['rows']:
        registered = next(r for r in manifest['rows'] if r['id'] == pair['id'])
        receipt = read(pair['receipt']) if pair.get('receipt_sha256') else {'rows': []}
        if pair.get('receipt_sha256') and digest(Path(pair['receipt'])) != pair['receipt_sha256']:
            raise ValueError('Pair receipt drift')
        saved = {r['id']: r for r in receipt['rows']}
        parsed = None
        for direction in replay_directions(manifest['budget']):
            for seed in manifest['budget']['seeds']:
                identifier = f'{direction}__{seed}'
                original = saved.get(identifier, {})
                row = {'id': pair['id'] + '__' + identifier, 'pair': pair['id'], 'source': pair['source'],
                    'condition': pair['condition'], 'pool_size': pair['pool_size'], 'direction': direction,
                    'status': original.get('status', 'unavailable_from_pair'), 'parent_status': pair['status'],
                    'steps': original.get('steps', 0), 'unique_states': original.get('unique_states', 0),
                    'repeated_states': original.get('repeated_states', 0), 'truth_checks': original.get('truth_checks', 0),
                    'goal_reached_source': original.get('goal_reached_source', False),
                    'goal_reached_target': original.get('goal_reached_target', False), 'audit': 'not_replayed'}
                if row['status'] in ('running', 'not_started'):
                    row['status'] = 'interrupted_or_unstarted'
                if original.get('trace') or row['status'] in ('pass_sampled', 'no_executable_actions', 'truth_mismatch'):
                    try:
                        if parsed is None:
                            job = read(registered['job'])
                            reader = PDDLReader()
                            source = reader.parse_problem(job['source_domain'], job['source_problem'])
                            target = reader.parse_problem(job['target_domain'], job['target_problem'])
                            parsed = (source, target, job)
                        source, target, job = parsed
                        mapping = job['mapping']
                        if any(order != list(range(len(order))) for order in mapping.get('orders', {}).values()):
                            raise ValueError('Independent public comparator requires identity predicate orders')
                        left, right = [], []
                        # Only completed paired steps are replayed. The last
                        # failed/noninvertible attempt remains a failure record.
                        for event in original.get('trace', [])[:row['steps']]:
                            a = (event['origin_action'], event['arguments'])
                            b = (event['transported_action'], event['transported_arguments'])
                            if direction != 'forward':
                                a, b = b, a
                            left.append(ActionInstance(source.action(a[0]), tuple(source.object(n) for n in a[1])))
                            right.append(ActionInstance(target.action(b[0]), tuple(target.object(n) for n in b[1])))
                        verdict = compare_states_public(source, target, SequentialPlan(left), SequentialPlan(right),
                                                        mapping['predicates'], mapping['objects'], max_atoms=manifest['budget']['max_atoms'])
                        row['audit'] = verdict['status']
                        row['independent_replay'] = verdict
                        row['claimed_pass_confirmed'] = row['status'] == 'pass_sampled' and verdict['status'] == 'PASS' and verdict['complete']
                    except Exception as exc:
                        row.update(audit='audit_error', audit_reason=f'{type(exc).__name__}: {exc}')
                rows.append(row)
        save(output / 'progress.json', {'pair': pair['id'], 'traces_audited': len(rows)})
        print(pair['id'], len(rows), flush=True)
    if len(rows) != manifest['trace_slots'] or len({r['id'] for r in rows}) != len(rows):
        raise ValueError('Trace denominator differs')
    groups = {(r['condition'], r['pool_size'], r['direction']) for r in rows}
    result = {'status': 'verified' if all(r.get('claimed_pass_confirmed') for r in rows if r['status'] == 'pass_sampled') else 'audit_failed',
        'task_count': len(rows), 'rows': rows, 'status_counts': dict(Counter(r['status'] for r in rows)),
        'audit_counts': dict(Counter(r['audit'] for r in rows)),
        'completed_steps': sum(r['steps'] for r in rows), 'paired_truth_checks': sum(r['truth_checks'] for r in rows),
        'by_condition_size_direction': {f'{c}/{s}/{d}': dict(Counter(r['status'] for r in rows if (r['condition'], r['pool_size'], r['direction']) == (c,s,d))) for c,s,d in sorted(groups)},
        'all_claimed_passes_independently_confirmed': all(r.get('claimed_pass_confirmed') for r in rows if r['status'] == 'pass_sampled'),
        'source_worlds': manifest['source_worlds'], 'independent_semantic_labels': 0,
        'parent_report_sha256': digest(root / 'report.json'), 'inputs_unchanged': True,
        'scope': 'Independent public-simulator replay of every saved completed paired prefix. Limits and unavailable slots remain in denominator; partial prefixes are not full-depth passes.'}
    save(output / 'report.json', result)
    return result


def goals(root, output):
    from unified_planning.io import PDDLReader, PDDLWriter
    from unified_planning.plans import ActionInstance, SequentialPlan
    from rcnc.validation import validate_artifacts
    from rcnc.namespace_export import fold_symbol_map
    manifest, report = read(root / 'manifest.json'), read(root / 'report.json')
    if report['status'] != 'complete' or len(report['rows']) != manifest['task_count']:
        raise ValueError('Incomplete solver matrix')
    check_pins(manifest)
    protocol = read(root / 'protocol.json')
    for registered in protocol['native_models'].values():
        for name, expected in registered['sha256'].items():
            if digest(Path(registered['path']) / name) != expected:
                raise ValueError('Source mapping metadata drift')
    rows, transports = [], []
    indexed = {r['id']: r for r in report['rows']}
    for row in report['rows']:
        checked = dict(row)
        directory = root / 'solver/tasks' / row['id']
        command = read(directory / 'command.json')
        if '--overall-time-limit' not in command or command[command.index('--overall-time-limit') + 1] != str(protocol['budget']['seconds']) + 's':
            raise ValueError('Search command budget differs')
        if command[command.index('--overall-memory-limit') + 1] != str(protocol['budget']['memory_mb']) + 'M':
            raise ValueError('Search memory budget differs')
        if command[command.index('--kill-after=5') + 1] != str(protocol['budget']['seconds']):
            raise ValueError('Search wall budget differs')
        registered = next(r for r in manifest['rows'] if r['id'] == row['id'])
        if any(digest(directory / name) != registered[field] for name, field in
               [('domain.pddl', 'domain_sha256'), ('problem.pddl', 'problem_sha256')]):
            raise ValueError('Searched problem differs from frozen task')
        if row['status'] == 'solved':
            checked['fresh_validation'] = validate_artifacts(directory)
            if row['family'] == 'synthetic_scalability':
                checked['necessary_length_matches'] = row['plan_length'] == row['necessary_steps']
                model = root / 'models' / ('n' + str(row['source_count'])) / row['representation']
                metadata = read(model / 'meta_domain.json')
                ownership = {action: source for source, table in metadata['action_maps'].items() for action in table.values()}
                qm = read(root / 'bundle/tasks' / row['id'] / 'query_mapping.json')
                inverse_objects = {v:k for k,v in qm['objects'].items()}
                reader = PDDLReader()
                problem = reader.parse_problem(str(directory / 'domain.pddl'), str(directory / 'problem.pddl'))
                plan = reader.parse_plan(problem, str(directory / 'plan.txt'))
                positions = {f't{i}': 0 for i in range(row['tokens'])}
                sources_used, handoffs, previous = set(), 0, {}
                for step in plan.actions:
                    token, start, finish = [inverse_objects[p.object().name] for p in step.actual_parameters]
                    owner = ownership[step.action.name]
                    index = int(start[1:])
                    if positions[token] != index or finish != f'p{index+1}' or owner != f'S{index % row["source_count"]:02d}':
                        raise ValueError('Saved chain plan disagrees with independent token/edge ownership replay')
                    if token in previous and previous[token] != owner:
                        handoffs += 1
                    positions[token] += 1
                    previous[token] = owner
                    sources_used.add(owner)
                checked.update(token_paths_complete=all(v == row['chain_length'] for v in positions.values()),
                               sources_used=sorted(sources_used), producer_consumer_handoffs=handoffs)
        rows.append(checked)
    for source in sorted({r['source'] for r in report['rows'] if r['family'] == 'original_goal'}):
        for condition in ('zero', 'machine'):
            native_dir = root / 'solver/tasks' / (source + '__native')
            target_dir = root / 'solver/tasks' / (source + '__' + condition)
            reader = PDDLReader()
            native = reader.parse_problem(str(native_dir / 'domain.pddl'), str(native_dir / 'problem.pddl'))
            target = reader.parse_problem(str(target_dir / 'domain.pddl'), str(target_dir / 'problem.pddl'))
            model = Path(protocol['native_models'][condition]['path'])
            metadata = read(model / 'meta_domain.json')
            query_mapping = read(root / 'bundle/tasks' / (source + '__' + condition) / 'query_mapping.json')
            objects = fold_symbol_map({**metadata['constant_maps'][source], **query_mapping['objects']})
            actions = fold_symbol_map(metadata['action_maps'][source])
            for direction in ('forward', 'reverse'):
                origin_id = source + '__' + ('native' if direction == 'forward' else condition)
                row = {'id': source + '__' + condition + '__' + direction, 'source': source, 'condition': condition,
                       'direction': direction, 'origin_status': indexed[origin_id]['status']}
                if row['origin_status'] != 'solved':
                    row['status'] = 'unavailable_no_goal_plan'
                    transports.append(row)
                    continue
                try:
                    origin, destination = (native, target) if direction == 'forward' else (target, native)
                    origin_dir, destination_dir = (native_dir, target_dir) if direction == 'forward' else (target_dir, native_dir)
                    omap, amap = (objects, actions) if direction == 'forward' else ({v:k for k,v in objects.items()}, {v:k for k,v in actions.items()})
                    plan = reader.parse_plan(origin, str(origin_dir / 'plan.txt'))
                    if any(step.action.name not in amap for step in plan.actions):
                        row['status'] = 'mixed_source_plan_not_projected'
                    elif any(p.object().name not in omap for step in plan.actions for p in step.actual_parameters):
                        row['status'] = 'outside_source_object_universe'
                    else:
                        mapped = SequentialPlan([ActionInstance(destination.action(amap[step.action.name]),
                            tuple(destination.object(omap[p.object().name]) for p in step.actual_parameters)) for step in plan.actions])
                        folder = output / 'transports' / row['id']
                        folder.mkdir(parents=True)
                        for name in ('domain.pddl', 'problem.pddl'):
                            (folder / name).write_bytes((destination_dir / name).read_bytes())
                        PDDLWriter(destination).write_plan(mapped, str(folder / 'plan.txt'))
                        verdict = validate_artifacts(folder)
                        row.update(status=verdict['status'], steps=len(plan.actions), validation=verdict)
                except Exception as exc:
                    row.update(status='transport_error', reason=f'{type(exc).__name__}: {exc}')
                transports.append(row)
    violations = [r['id'] for r in rows if r['status'] == 'solved' and
                  (r['fresh_validation']['status'] != 'VALID' or r.get('necessary_length_matches') is False
                   or r.get('token_paths_complete') is False)]
    result = {'status': 'verified' if not violations else 'audit_failed', 'task_count': len(rows), 'rows': rows,
        'status_counts': dict(Counter(r['status'] for r in rows)), 'violations': violations,
        'goal_plan_transports': transports, 'transport_counts': dict(Counter(r['status'] for r in transports)),
        'chain_counts': {c: dict(Counter(r['status'] for r in rows if r['family'] == 'synthetic_scalability' and r['representation'] == c)) for c in protocol['chain_conditions']},
        'native_counts': {c: dict(Counter(r['status'] for r in rows if r['family'] == 'original_goal' and r['representation'] == c)) for c in protocol['native_conditions']},
        'inputs_unchanged': True, 'parent_report_sha256': digest(root / 'report.json'),
        'scope': 'Fresh goal-plan validation and full-argument bidirectional transport. Authored chains and original narrative goals remain separate.'}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--kind', choices=['replay', 'goals'], required=True)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    require_empty_output(args.output)
    args.output.mkdir(parents=True)
    result = (replay if args.kind == 'replay' else goals)(args.root, args.output)
    print(json.dumps({k: result[k] for k in ('status', 'task_count')}))

"""Revalidate plans and both source-only transport directions on saved external runs."""
import argparse
from collections import Counter
import json
from pathlib import Path

from unified_planning.io import PDDLReader, PDDLWriter
from unified_planning.plans import ActionInstance, SequentialPlan
from unified_planning.shortcuts import SequentialSimulator

from rcnc.bidirectional_replay import atom_projection
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.validation import validate_artifacts
from scripts.audit.audit_expanded_experiments import check_pins
from scripts.experiments.prepare_casefold_followup import casefold_ast
from rcnc.pddl import parse_sexpr


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def audit(primary, followup, output):
    require_empty_output(output)
    output.mkdir(parents=True)
    validations, transports = [], []
    for label, root in (('original', primary), ('casefold_followup', followup)):
        manifest, report = read(root / 'manifest.json'), read(root / 'report.json')
        check_pins(manifest)
        if (report['status'] != 'complete' or report['task_count'] != len(report['rows'])
                or {r['id'] for r in report['rows']} != {r['id'] for r in manifest['rows']}):
            raise ValueError('Incomplete parent denominator')
        for row in report['rows']:
            verdict = validate_artifacts(root / 'solver/tasks' / row['id']) if row['status'] == 'solved' else None
            validations.append({'id': label + '/' + row['id'], 'status': row['status'],
                                'fresh_validation': verdict})
    normalization = read(followup / 'normalization.json')
    for row in normalization['rows']:
        original, normalized = Path(row['original']), Path(row['normalized'])
        if digest(original) != row['original_sha256'] or digest(normalized) != row['normalized_sha256']:
            raise ValueError('Normalization input drift')
        if casefold_ast(parse_sexpr(original.read_text(encoding='utf-8'))) != parse_sexpr(normalized.read_text(encoding='utf-8')):
            raise ValueError('Normalization changed more than case')
    report = read(followup / 'report.json')
    indexed = {r['id']: r for r in report['rows']}
    reader = PDDLReader()
    for case in sorted({r['problem_id'] for r in report['rows']}):
        source = indexed[case + '__native']['source']
        native_dir = followup / 'solver/tasks' / (case + '__native')
        native = reader.parse_problem(str(native_dir / 'domain.pddl'), str(native_dir / 'problem.pddl'))
        for condition in ('zero', 'lexical'):
            target_dir = followup / 'solver/tasks' / (case + '__' + condition)
            target = reader.parse_problem(str(target_dir / 'domain.pddl'), str(target_dir / 'problem.pddl'))
            metadata = read(followup / 'models' / condition / 'meta_domain.json')
            mapping = read(followup / 'bundle/tasks' / (case + '__' + condition) / 'query_mapping.json')
            fold = lambda d: {k.lower(): v.lower() for k, v in d.items()}
            objects = fold({**metadata['constant_maps'][source], **mapping['objects']})
            actions = fold(metadata['action_maps'][source])
            predicates = fold(metadata['predicate_maps'][source])
            orders = metadata.get('predicate_orders', {}).get(source, {})
            pairs = atom_projection(native, target, predicates, objects, orders, 200000)
            for direction in ('forward', 'reverse'):
                row = {'id': case + '/' + condition + '/' + direction, 'direction': direction,
                       'source': source, 'condition': condition}
                try:
                    origin, destination = (native, target) if direction == 'forward' else (target, native)
                    origin_dir, destination_dir = (native_dir, target_dir) if direction == 'forward' else (target_dir, native_dir)
                    origin_id = case + '__' + ('native' if direction == 'forward' else condition)
                    if indexed[origin_id]['status'] != 'solved':
                        row['status'] = 'unavailable_no_goal_plan'
                        transports.append(row)
                        continue
                    amap, omap = ((actions, objects) if direction == 'forward'
                                  else ({v:k for k,v in actions.items()}, {v:k for k,v in objects.items()}))
                    plan = reader.parse_plan(origin, str(origin_dir / 'plan.txt'))
                    if any(a.action.name not in amap for a in plan.actions):
                        row['status'] = 'mixed_source_plan_not_projected'
                        transports.append(row)
                        continue
                    if any(p.object().name not in omap for a in plan.actions for p in a.actual_parameters):
                        row['status'] = 'outside_source_object_universe'
                        transports.append(row)
                        continue
                    mapped = SequentialPlan([ActionInstance(destination.action(amap[a.action.name]),
                        tuple(destination.object(omap[p.object().name]) for p in a.actual_parameters)) for a in plan.actions])
                    folder = output / 'transports' / row['id']
                    folder.mkdir(parents=True)
                    for name in ('domain.pddl', 'problem.pddl'):
                        (folder / name).write_bytes((destination_dir / name).read_bytes())
                    PDDLWriter(destination).write_plan(mapped, str(folder / 'plan.txt'))
                    verdict = validate_artifacts(folder)
                    left, right = (plan, mapped) if direction == 'forward' else (mapped, plan)
                    checks = 0
                    with SequentialSimulator(native) as ss, SequentialSimulator(target) as ts:
                        s, t = ss.get_initial_state(), ts.get_initial_state()
                        for step in range(len(left.actions)+1):
                            if any(s.get_value(a) != t.get_value(b) for b,a in pairs.items()):
                                raise ValueError('Complete source truth mismatch at step ' + str(step))
                            checks += len(pairs)
                            if step < len(left.actions):
                                a, b = left.actions[step], right.actions[step]
                                if (not ss.is_applicable(s, a.action, a.actual_parameters)
                                        or not ts.is_applicable(t, b.action, b.actual_parameters)):
                                    raise ValueError('Paired applicability mismatch')
                                s, t = ss.apply(s, a.action, a.actual_parameters), ts.apply(t, b.action, b.actual_parameters)
                    row.update(status=verdict['status'], steps=len(plan.actions), source_atoms=len(pairs),
                               truth_checks=checks, full_source_projection_equal=True, validation=verdict)
                except Exception as exc:
                    row.update(status='audit_error', reason=f'{type(exc).__name__}: {exc}')
                transports.append(row)
    violations = [r['id'] for r in validations if r['status'] == 'solved' and r['fresh_validation']['status'] != 'VALID']
    violations.extend(r['id'] for r in transports if r['status'] in ('INVALID', 'ERROR', 'audit_error'))
    result = {'status': 'verified' if not violations else 'audit_failed', 'task_count': len(validations),
        'rows': validations, 'status_counts': dict(Counter(r['status'] for r in validations)),
        'transports': transports, 'transport_counts': dict(Counter(r['status'] for r in transports)),
        'paired_steps': sum(r.get('steps',0) for r in transports),
        'source_atom_truth_checks': sum(r.get('truth_checks',0) for r in transports),
        'case_only_records_verified': len(normalization['rows']), 'violations': violations,
        'parent_reports': {str(p / 'report.json'): digest(p / 'report.json') for p in (primary,followup)},
        'scope': 'Original 18 slots and separate 12-slot engineering followup remain distinct. No semantic labels or independent cross-source tasks.'}
    result['implementation_sha256'] = snapshot_implementation(output, [Path(__file__),
        Path('rcnc/bidirectional_replay.py'), Path('rcnc/validation.py'),
        Path('scripts/experiments/prepare_casefold_followup.py')])
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    for name in ('primary', 'followup', 'output'):
        p.add_argument('--' + name, type=Path, required=True)
    args = p.parse_args()
    result = audit(args.primary, args.followup, args.output)
    print(json.dumps({k: result[k] for k in ('status','task_count','transport_counts','paired_steps','source_atom_truth_checks','violations')}))

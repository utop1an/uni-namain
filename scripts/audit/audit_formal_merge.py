"""Bounded source-plan transport and raw-evidence audit for the prospective run."""
import argparse
from collections import Counter
import json
from pathlib import Path
import subprocess
import sys

from rcnc.bidirectional_replay import ReplayLimit
from rcnc.conditional_merge import canonical_action, certify_replacement
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.pddl import parse_domain
from rcnc.validation import validate_artifacts
from scripts.audit.audit_semantic_facets_comparison import verify_model
from scripts.audit.audit_transport_merge import transport, trace
from scripts.experiments.run_formal_merge import check, read


def worker(root, task_id, output):
    manifest = read(root / 'manifest.json'); task = next(r for r in manifest['rows'] if r['id'] == task_id)
    folder = root / 'bundle/tasks' / task_id
    native = root / 'solver/tasks' / (task['problem_id'] + '__native')
    try:
        result = transport(task['source'], native, folder, root / 'models' / task['bundle'] / task['representation'],
            read(folder / 'query_mapping.json'), output / 'transport')
    except ReplayLimit as exc:
        result = {'status': 'replay_resource_limit', 'reason': str(exc)}
    except Exception as exc:
        result = {'status': 'replay_error', 'reason': f'{type(exc).__name__}: {exc}'}
    save(output / 'result.json', result)
    return result


def audit(root, output):
    require_empty_output(output); output.mkdir(parents=True); check(root)
    protocol, manifest, solver = read(root / 'protocol.json'), read(root / 'manifest.json'), read(root / 'report.json')
    if solver['status'] != 'complete' or solver['manifest_sha256'] != digest(root / 'manifest.json'):
        raise ValueError('Completed matching solver report required')
    for k in ('inputs_unchanged', 'implementation_unchanged', 'solver_integrity'):
        if solver[k] is not True: raise ValueError('Solver integrity failed: ' + k)
    for p, h in manifest['input_sha256'].items():
        if digest(Path(p)) != h: raise ValueError('Frozen input changed: ' + p)
    if [r['id'] for r in solver['rows']] != [r['id'] for r in manifest['rows']] or len(solver['rows']) != protocol['task_slots']:
        raise ValueError('Task identities/denominator changed')
    predictions = verify_model(root)
    indexed = {r['id']: r for r in solver['rows']}
    validations, violations, merges = [], [], []
    for row in solver['rows']:
        if row['status'] == 'solved':
            verdict = validate_artifacts(root / 'solver/tasks' / row['id'])
            validations.append({'id': row['id'], **verdict})
            if verdict['status'] != 'VALID': violations.append(row['id'])
    for model in read(root / 'compilation.json')['models']:
        if model['status'] != 'compiled':
            merges.append(model); continue
        folder = root / 'models' / model['bundle'] / model['condition']
        domain, meta = parse_domain(folder / 'meta_domain.pddl'), read(folder / 'meta_domain.json')
        stage, before = parse_domain(folder / 'predicate_model/meta_domain.pddl'), read(folder / 'predicate_model/meta_domain.json')
        spec = read(folder / 'merge_specification.json'); certificates = []
        for decision in model['decisions']:
            if decision['kind'] != 'action' or decision['status'] != 'accepted': continue
            group = next(g for g in spec['action_candidates'] if g['id'] == decision['id'])
            originals = []
            for member in group['members']:
                source, action = member['action'].split(':')
                originals.append(canonical_action(stage.actions[before['action_maps'][source][action]], member['order']))
                if meta['action_maps'][source][action] != decision['target']:
                    raise ValueError('Accepted action missing actual many-to-one mapping')
            certificate = certify_replacement(originals, domain.actions[decision['target']])
            if certificate['status'] != 'accepted' or len(meta['action_origins'][decision['target']]) != len(originals):
                raise ValueError('Lost action certificate or source branch')
            certificates.append({'id': decision['id'], 'members': decision['members'], 'certificate': certificate})
        merges.append({**model, 'exported_actions': len(domain.actions),
            'logical_predicates': len(domain.predicates) - len(meta['type_guards']), 'certificates': certificates})
    rows = []
    for task in manifest['rows']:
        if task['family'] != 'original_mapped': continue
        row = {'id': task['id'], 'source': task['source'], 'problem_id': task['problem_id'],
            'bundle': task['bundle'], 'condition': task['representation']}
        native = indexed[task['problem_id'] + '__native']
        if task['admission_status'] != 'ready':
            row.update(status='unavailable_compilation_or_mapping', reason=task['admission_status'])
        elif native['status'] != 'solved':
            row.update(status='unavailable_native_plan', native_status=native['status'])
        else:
            destination = output / 'replays' / task['id']; destination.mkdir(parents=True)
            command = [sys.executable, '-X', 'utf8', '-m', 'scripts.audit.audit_formal_merge', 'worker',
                '--root', str(root), '--output', str(destination), '--task', task['id']]
            try:
                with (destination / 'worker.log').open('w', encoding='utf-8') as log:
                    process = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT,
                                             timeout=protocol['replay_budget']['seconds_each'])
                if process.returncode != 0 or not (destination / 'result.json').exists():
                    row.update(status='replay_worker_error', exit_code=process.returncode)
                else: row.update(read(destination / 'result.json'))
            except subprocess.TimeoutExpired:
                row.update(status='replay_time_limit', seconds=protocol['replay_budget']['seconds_each'])
        if row['status'] in ('replay_error', 'replay_worker_error'): violations.append(row['id'])
        rows.append(row)
        save(output / 'progress.json', {'status': 'running', 'replay_rows': rows})
        if len(rows) % 30 == 0: print(json.dumps({'replay_slots_completed': len(rows), 'counts': Counter(r['status'] for r in rows)}), flush=True)
    crosses = []
    for query in protocol['queries']:
        sources = query['bundle'].split('__')
        conditions = [*protocol['conditions'], *['remove_' + s for s in sources]]
        statuses = {c: indexed[query['bundle'] + '__' + query['id'] + '__' + c]['status'] for c in conditions}
        folder = root / 'models' / query['bundle'] / 'full090'
        steps = trace(root / 'solver/tasks' / (query['bundle'] + '__' + query['id'] + '__full090'), read(folder / 'meta_domain.json')) if (folder / 'meta_domain.json').exists() else []
        crosses.append({'id': query['id'], 'bundle': query['bundle'], 'unit': query['unit'], 'statuses': statuses,
            'plan_steps': steps, 'plan_length': len(steps) if statuses['full090'] == 'solved' else None,
            'positive_benefit': query['unit'] == 'authored_cross_positive' and statuses['full090'] == 'solved' and statuses['no_share'] == 'unsolvable',
            'both_sources_necessary': statuses['full090'] == 'solved' and all(statuses['remove_' + s] == 'unsolvable' for s in sources),
            'semantic_risk_triggered': query['unit'] == 'authored_semantic_risk_control' and statuses['full090'] == 'solved',
            'scope': query['assumption']})
    result = {'status': 'verified' if not violations else 'verified_with_replay_errors',
        'integrity_verified': True, 'raw_predictions_verified': True, 'model_calls': predictions['requests_attempted'],
        'model_status_counts': predictions['status_counts'], 'planner_calls': solver['actual_solver_calls'],
        'task_slots': len(solver['rows']), 'solver_status_counts': solver['status_counts'],
        'returned_plans': validations, 'merges': merges, 'cross_source': crosses,
        'replay_count': len(rows), 'rows': rows, 'replay_status_counts': dict(Counter(r['status'] for r in rows)),
        'replayed_steps': sum(r.get('steps', 0) for r in rows), 'truth_checks': sum(r.get('truth_checks', 0) for r in rows),
        'violations': violations, 'scope': protocol['scope'] + ' Replay limits are unavailable, not successes. Cross-world expectations are authored hypotheses, not independent semantic labels.',
        'parent_reports': {p.as_posix(): digest(p) for p in [root / 'report.json', root / 'manifest.json', root / 'judgments/report.json']}}
    result['implementation_sha256'] = snapshot_implementation(output, [Path(__file__), Path('scripts/audit/audit_transport_merge.py'),
        Path('scripts/audit/audit_semantic_facets_comparison.py'), Path('rcnc/bidirectional_replay.py'), Path('rcnc/validation.py')])
    save(output / 'report.json', result)
    return {k: result[k] for k in ('status', 'model_calls', 'planner_calls', 'replay_status_counts', 'replayed_steps', 'truth_checks', 'violations')}


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__); p.add_argument('mode', choices=['audit', 'worker'])
    p.add_argument('--root', type=Path, required=True); p.add_argument('--output', type=Path, required=True)
    p.add_argument('--task'); args = p.parse_args()
    print(json.dumps(audit(args.root, args.output) if args.mode == 'audit' else worker(args.root, args.task, args.output), indent=2))

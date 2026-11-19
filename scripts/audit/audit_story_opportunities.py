"""Direct forward plan feasibility, separate from full Boolean state replay."""
import argparse
from collections import Counter
import json
from pathlib import Path
import shutil
import subprocess
import sys
import time

from rcnc.conditional_merge import canonical_action, certify_replacement
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.pddl import parse_domain, parse_sexpr, serialize
from rcnc.story_merge_protocol import translate_calls
from rcnc.validation import validate_artifacts
from scripts.audit.audit_semantic_facets_comparison import verify_model
from scripts.experiments.run_story_opportunities import check, read


def calls(path):
    return [parse_sexpr(line.split(';')[0].strip()) for line in path.read_text(encoding='utf-8').splitlines() if line.split(';')[0].strip()]


def worker(output):
    job = read(output / 'job.json'); start = time.monotonic()
    try:
        source = Path(job['native']); native = validate_artifacts(source)
        if native['status'] != 'VALID': raise ValueError('Source plan not valid: ' + str(native))
        meta = read(Path(job['model']) / 'meta_domain.json'); plan = calls(source / 'plan.txt')
        mapped = translate_calls(job['source'], meta, job['mapping'], plan)
        shutil.copyfile(Path(job['model']) / 'meta_domain.pddl', output / 'domain.pddl')
        shutil.copyfile(job['problem'], output / 'problem.pddl')
        (output / 'plan.txt').write_text('\n'.join(serialize(a) for a in mapped) + '\n', encoding='utf-8')
        mapped_at = time.monotonic(); verdict = validate_artifacts(output)
        status = 'PASS' if verdict['status'] == 'VALID' else 'invalid_transported_plan' if verdict['status'] == 'INVALID' else 'validation_unavailable'
        result = {'status': status, 'steps': len(plan), 'validation': verdict, 'source_validation': native,
            'mapping_and_source_validation_seconds': mapped_at - start, 'target_validation_seconds': time.monotonic() - mapped_at,
            'source_plan_sha256': digest(source / 'plan.txt'), 'transported_plan_sha256': digest(output / 'plan.txt'),
            'uses_merged_action': any(len(meta['action_origins'][a[0]]) > 1 for a in mapped),
            'full_truth_projection_checked': False}
    except Exception as exc: result = {'status': 'transport_error', 'reason': f'{type(exc).__name__}: {exc}'}
    save(output / 'result.json', result)
    return result


def audit(root, output):
    require_empty_output(output); output.mkdir(parents=True); check(root)
    protocol, manifest, solver = read(root / 'protocol.json'), read(root / 'manifest.json'), read(root / 'report.json')
    assert solver['status'] == 'complete' and solver['manifest_sha256'] == digest(root / 'manifest.json')
    assert all(solver[k] is True for k in ('inputs_unchanged', 'implementation_unchanged', 'solver_integrity'))
    assert len(solver['rows']) == protocol['task_slots'] and [r['id'] for r in solver['rows']] == [r['id'] for r in manifest['rows']]
    for p, h in manifest['input_sha256'].items():
        if digest(Path(p)) != h: raise ValueError('Frozen data changed: ' + p)
    predictions = verify_model(root); indexed = {r['id']: r for r in solver['rows']}
    validations, violations, certificates = [], [], []
    for row in solver['rows']:
        if row['status'] == 'solved':
            verdict = validate_artifacts(root / 'solver/tasks' / row['id'])
            validations.append({'id': row['id'], **verdict})
            if verdict['status'] != 'VALID': violations.append(row['id'])
    compilation = read(root / 'compilation.json')
    for model in compilation['models']:
        if model['status'] != 'compiled': continue
        folder = root / 'models' / model['case'] / model['condition']; meta = read(folder / 'meta_domain.json')
        domain = parse_domain(folder / 'meta_domain.pddl'); stage = parse_domain(folder / 'predicate_model/meta_domain.pddl')
        before = read(folder / 'predicate_model/meta_domain.json'); spec = read(folder / 'merge_specification.json')
        for decision in model['decisions']:
            if decision['kind'] != 'action' or decision['status'] != 'accepted': continue
            group = next(g for g in spec['action_candidates'] if g['id'] == decision['id']); originals = []
            for member in group['members']:
                s, a = member['action'].split(':'); target = meta['action_maps'][s][a]
                assert target == decision['target'] and len(meta['action_origins'][target]) == len(group['members'])
                originals.append(canonical_action(stage.actions[before['action_maps'][s][a]], member['order']))
            verdict = certify_replacement(originals, domain.actions[decision['target']])
            assert verdict['status'] == 'accepted'
            certificates.append({'case': model['case'], 'condition': model['condition'], 'id': decision['id'], 'certificate': verdict})
    jobs = []
    for task in manifest['rows']:
        if task['family'] != 'original_mapped': continue
        row = {'id': 'original__' + task['id'], 'unit': 'original_plan', 'source': task['source'], 'case': task['case'],
            'condition': task['representation'], 'problem_id': task['problem_id'], 'status': 'ready'}
        native = indexed[task['source'] + '__native']
        if task['admission_status'] != 'ready': row.update(status='unavailable_mapping', reason=task['admission_status'])
        elif native['status'] != 'solved': row.update(status='unavailable_native_plan', native_status=native['status'])
        else:
            folder = root / 'bundle/tasks' / task['id']
            row['job'] = {'source': task['source'], 'native': str(root / 'solver/tasks' / (task['source'] + '__native')),
                'model': str(root / 'models' / task['case'] / task['representation']), 'problem': str(folder / 'problem.pddl'), 'mapping': read(folder / 'query_mapping.json')}
        jobs.append(row)
    ws = {w['id']: w for w in protocol['witnesses']}
    for target in compilation['witness_rows']:
        witness = ws[target['witness_id']]
        row = {'id': 'witness__' + target['id'], 'unit': 'schema_constructed_witness', 'source': target['source'],
               'case': target['case'], 'condition': target['condition'], 'status': target['status']}
        if row['status'] == 'ready':
            row['job'] = {'source': target['source'], 'native': witness['directory'],
                'model': str(root / 'models' / target['case'] / target['condition']), 'problem': target['problem'], 'mapping': target['mapping']}
        jobs.append(row)
    expected = sum(r['family'] == 'original_mapped' for r in manifest['rows']) + len(protocol['witnesses']) * len(protocol['conditions'])
    assert len(jobs) == expected and len({r['id'] for r in jobs}) == expected
    rows = []
    for row in jobs:
        if row['status'] == 'ready':
            destination = output / 'transports' / row['id']; destination.mkdir(parents=True)
            save(destination / 'job.json', row.pop('job'))
            try:
                with (destination / 'worker.log').open('w', encoding='utf-8') as log:
                    process = subprocess.run([sys.executable, '-X', 'utf8', '-m', 'scripts.audit.audit_story_opportunities', 'worker', '--output', str(destination)],
                        stdout=log, stderr=subprocess.STDOUT, timeout=protocol['transport_budget']['seconds_each'])
                row.update(read(destination / 'result.json') if process.returncode == 0 and (destination / 'result.json').exists() else {'status': 'worker_error', 'exit_code': process.returncode})
            except subprocess.TimeoutExpired: row.update(status='transport_time_limit')
        if row['status'] in ('invalid_transported_plan', 'transport_error', 'worker_error'): violations.append(row['id'])
        rows.append(row); save(output / 'progress.json', {'status': 'running', 'rows': rows})
        if len(rows) % 20 == 0: print(json.dumps({'transport_slots': len(rows), 'counts': Counter(r['status'] for r in rows)}), flush=True)
    crosses = []
    for query in protocol['queries']:
        cases = [r for r in solver['rows'] if r.get('case') == query['case'] and r['problem_id'] == query['id']]
        statuses = {r['representation']: r['status'] for r in cases}
        full_id = query['case'] + '__' + query['id'] + '__full090'; steps = []
        if statuses['full090'] == 'solved':
            meta = read(root / 'models' / query['case'] / 'full090/meta_domain.json')
            steps = [{'call': call, 'possible_origins': meta['action_origins'][call[0]]} for call in calls(root / 'solver/tasks' / full_id / 'plan.txt')]
        crosses.append({'id': query['id'], 'unit': query['unit'], 'statuses': statuses, 'plan_steps': steps,
            'plan_length': len(steps) if steps else None,
            'positive_benefit': query['unit'] == 'authored_cross_positive' and statuses['full090'] == 'solved' and statuses['no_share'] == 'unsolvable',
            'both_sources_necessary': statuses['full090'] == 'solved' and all(v == 'unsolvable' for k, v in statuses.items() if k.startswith('remove_')) if query['unit'] == 'authored_cross_positive' else None,
            'semantic_risk_triggered': statuses['full090'] == 'solved' if query['unit'] == 'known_semantic_risk' else None, 'scope': query['scope']})
    report = {'status': 'verified' if not violations else 'verified_with_transport_errors', 'integrity_verified': True,
        'raw_predictions_verified': True, 'model_calls': predictions['requests_attempted'], 'model_status_counts': predictions['status_counts'],
        'planner_calls': solver['actual_solver_calls'], 'solver_status_counts': solver['status_counts'], 'returned_plans': validations,
        'transport_count': len(rows), 'rows': rows, 'transport_status_counts': dict(Counter(r['status'] for r in rows)),
        'by_unit': {u: dict(Counter(r['status'] for r in rows if r['unit'] == u)) for u in sorted({r['unit'] for r in rows})},
        'transported_steps': sum(r.get('steps', 0) for r in rows if r['status'] == 'PASS'), 'action_certificates': certificates,
        'models': compilation['models'], 'cross_source': crosses, 'violations': violations, 'full_truth_projection_checked': False,
        'scope': protocol['scope'] + ' Direct plan validation includes applicability and goals, not exhaustive all-atom state comparison. Timing fields are descriptive, not an isolated cost experiment.',
        'parent_reports': {p.as_posix(): digest(p) for p in [root / 'report.json', root / 'judgments/report.json', root / 'compilation.json']},
        'implementation_sha256': snapshot_implementation(output, [Path(__file__), Path('rcnc/story_merge_protocol.py'), Path('rcnc/validation.py')])}
    save(output / 'report.json', report)
    return {k: report[k] for k in ('status', 'model_calls', 'planner_calls', 'by_unit', 'transported_steps', 'violations')}


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__); p.add_argument('mode', choices=['audit', 'worker'])
    p.add_argument('--root', type=Path); p.add_argument('--output', type=Path, required=True); args = p.parse_args()
    print(json.dumps(audit(args.root, args.output) if args.mode == 'audit' else worker(args.output), indent=2))

"""Audit post-hoc representation controls and transport plans to primary models."""
import argparse
from collections import Counter
import json
from pathlib import Path

from unified_planning.io import PDDLReader, PDDLWriter
from unified_planning.plans import ActionInstance, SequentialPlan
from rcnc.domain_building import require_empty_output, save, archived_implementation, snapshot_implementation
from rcnc.pddl import parse_domain, parse_sexpr
from rcnc.validation import validate_artifacts
from scripts.audit.audit_composition_probes import world_checks
from scripts.audit.audit_original_world_pipeline import lookup
from scripts.evidence.build_meeting_results import phase
from scripts.experiments.run_downward_reference import sha


def transport_plan(projected, projected_meta, original, original_meta, query, output):
    reader = PDDLReader()
    left = reader.parse_problem(str(projected / 'domain.pddl'), str(projected / 'problem.pddl'))
    plan = reader.parse_plan(left, str(projected / 'plan.txt'))
    right = reader.parse_problem(str(original / 'domain.pddl'), str(original / 'problem.pddl'))
    owners = {target.lower(): (source, name) for source, table in projected_meta['action_maps'].items() for name, target in table.items()}
    constants = {target.lower(): (source, name) for source, table in projected_meta['constant_maps'].items() for name, target in table.items()}
    query_objects = {'q__' + name for name in query['objects']}
    instances = []
    for step in plan.actions:
        source, name = owners[step.action.name.lower()]
        action = right.action(lookup(original_meta['action_maps'][source], name).lower())
        values = []
        for parameter in step.actual_parameters:
            value = parameter.object().name.lower()
            if value not in query_objects:
                owner, constant = constants[value]
                value = lookup(original_meta['constant_maps'][owner], constant).lower()
            values.append(right.environment.expression_manager.ObjectExp(right.object(value)))
        if len(values) != len(action.parameters):
            raise ValueError('Action parameter order/arity changed')
        instances.append(ActionInstance(action, tuple(values)))
    output.mkdir(parents=True)
    for name in ('domain.pddl', 'problem.pddl'):
        (output / name).write_bytes((original / name).read_bytes())
    PDDLWriter(right).write_plan(SequentialPlan(instances), str(output / 'plan.txt'))
    validation = validate_artifacts(output)
    return {'status': 'valid' if validation['status'] == 'VALID' else 'invalid', 'validation': validation,
        'length': len(instances), 'projected_plan_sha256': sha(projected / 'plan.txt'),
        'scope': 'Source-owned action/constant identity transport with all argument positions preserved; exact primary model/problem unchanged'}


def audit(root, output):
    require_empty_output(output)
    read = lambda path: json.loads(path.read_text(encoding='utf-8'))
    protocol, manifest, report = read(root / 'protocol.json'), read(root / 'manifest.json'), read(root / 'report.json')
    primary = Path(protocol['primary'])
    if sha(primary / 'manifest.json') != protocol['primary_manifest_sha256']:
        raise ValueError('Primary manifest drift')
    if report['status'] != 'complete' or report['manifest_sha256'] != sha(root / 'manifest.json'):
        raise ValueError('Complete diagnostic run required')
    tasks = {row['id']: row for row in manifest['tasks']}
    rows = {row['id']: row for row in report['rows']}
    if len(tasks) != 12 or len(manifest['tasks']) != 12 or len(rows) != 12 or len(report['rows']) != 12 or set(tasks) != set(rows):
        raise ValueError('Complete12-condition diagnostic denominator required')
    for path, expected in manifest['input_sha256'].items():
        if sha(root / path) != expected:
            raise ValueError('Frozen diagnostic input drift')
    for path, expected in manifest['implementation_sha256'].items():
        if sha(archived_implementation(root, path)) != expected:
            raise ValueError('Frozen code drift')
    if not all(report[key] for key in ('inputs_unchanged', 'implementation_unchanged', 'solver_integrity')):
        raise ValueError('Diagnostic runtime integrity failed')
    pairs = {pair['id']: pair for pair in read(primary / 'generation.json')['pairs']}
    primary_rows = {row['id']: row for row in read(primary / 'report.json')['rows']}
    original_meta = {name: read(primary / 'models' / name / 'meta_domain.json') for name in ('machine', 'zero_merge')}
    output.mkdir(parents=True)
    checked, failures = [], []
    for task_id, task in tasks.items():
        row = dict(rows[task_id])
        pair = pairs[task['pair_id']]
        model = root / 'models' / task['model_key'] / task['condition']
        metadata = read(model / 'meta_domain.json')
        input_dir = model.parent / 'inputs'
        domains = {p.name.removesuffix('_domainfile.pddl'): parse_domain(p) for p in input_dir.glob('*.pddl')}
        directory = root / 'solver/tasks' / task_id
        for kind in ('domain', 'problem'):
            if sha(directory / (kind + '.pddl')) != task[kind + '_sha256']:
                raise ValueError('Actual solver input drift')
        primary_condition = 'zero_merge_same_source_action_sets' if task['condition'].startswith('zero_merge') else 'aligned_selected_sources'
        primary_id = task['pair_id'] + '__' + primary_condition
        original = primary / 'bundle/tasks' / primary_id
        primary_model = 'zero_merge' if task['condition'].startswith('zero_merge') else 'machine'
        if read(root / 'probes' / task['pair_id'] / 'query.json') != pair['query']:
            raise ValueError('Foreground request changed')
        row['world_checks'] = world_checks(pair['query'], metadata, domains,
            parse_sexpr((directory / 'problem.pddl').read_text(encoding='utf-8')),
            read(root / 'probes' / task['pair_id'] / (task['condition'] + '_mapping.json')))
        row['primary_status'] = primary_rows[primary_id]['status']
        row['primary_phase'] = phase(primary / 'solver/tasks' / primary_id)
        row['diagnostic_phase'] = phase(directory)
        row['whole_source_action_sets_match'] = all(set(metadata['action_maps'][source]) == set(original_meta[primary_model]['action_maps'][source]) for source in task['selected_sources'])
        row['projected_constant_count'] = len(parse_domain(directory / 'domain.pddl').constants)
        row['primary_constant_count'] = len(parse_domain(original / 'domain.pddl').constants)
        row['transport'] = {'status': 'no_plan'}
        if row['status'] == 'solved':
            row['fresh_plan_validation'] = validate_artifacts(directory)
            try:
                row['transport'] = transport_plan(directory, metadata, original, original_meta[primary_model], pair['query'],
                    output / 'primary_model_replays' / task_id)
            except Exception as exc:
                row['transport'] = {'status': 'mapping_error', 'reason': f'{type(exc).__name__}: {exc}'}
        valid = row['whole_source_action_sets_match'] and all(row['world_checks'][key] for key in
            ('request_objects_preserved', 'narrative_initial_preserved', 'pddl_initial_exact', 'goal_preserved'))
        if row['status'] == 'solved':
            valid = valid and row['fresh_plan_validation']['status'] == 'VALID' and row['transport']['status'] == 'valid'
        if not valid:
            failures.append(task_id)
        checked.append(row)
    witnesses = read(root / 'witnesses.json')['rows']
    for witness in witnesses:
        witness['fresh_validation'] = validate_artifacts(root / 'probes' / witness['id'] / 'provided_witness')
        if witness['fresh_validation']['status'] != witness['validation']['status']:
            raise ValueError('Constructed witness validation drift')
    implementation = snapshot_implementation(output, [Path(__file__), Path('scripts/audit/audit_composition_probes.py'),
        Path('scripts/audit/audit_original_world_pipeline.py'), Path('scripts/evidence/build_meeting_results.py'),
        Path('rcnc/pddl.py'), Path('rcnc/validation.py'), Path('rcnc/domain_building.py')])
    result = {'status': 'verified_projection_diagnostic' if not failures else 'audited_with_violations',
        'task_count': 12, 'probe_count': 6, 'rows': checked,
        'status_counts': dict(Counter(row['status'] for row in checked)),
        'transport_counts': dict(Counter(row['transport']['status'] for row in checked)),
        'constructed_witness_counts': dict(Counter(row['fresh_validation']['status'] for row in witnesses)),
        'constructed_witnesses': witnesses, 'audit_failures': failures, 'hashes_unchanged': True,
        'manifest_sha256': sha(root / 'manifest.json'), 'report_sha256': sha(root / 'report.json'),
        'implementation_sha256': implementation,
        'scope': manifest['scope'], 'primary_outcomes_replaced': False,
        'limits': protocol['limits']}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    report = audit(args.root, args.output)
    print(json.dumps({key: value for key, value in report.items() if key not in ('rows', 'constructed_witnesses', 'implementation_sha256')}, indent=2))

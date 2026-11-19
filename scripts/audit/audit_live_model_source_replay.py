"""Recheck explicit worlds, full argument round trips and source-atom metrics."""
import argparse
from collections import Counter
import json
from pathlib import Path

from unified_planning.io import PDDLReader

from rcnc.domain_building import archived_implementation, digest, require_empty_output, save, snapshot_implementation
from rcnc.pddl import parse_domain, parse_sexpr
from rcnc.validation import validate_artifacts
from scripts.audit.audit_original_world_pipeline import check_world, native_transport
from scripts.experiments.replay_live_model_sources import compare_states


def steps(plan):
    return [(step.action.name, tuple(str(argument) for argument in step.actual_parameters)) for step in plan.actions]


def audit(root, output):
    require_empty_output(output)
    read = lambda path: json.loads(path.read_text(encoding='utf-8'))
    manifest, report, protocol = (read(root / name) for name in ('manifest.json', 'report.json', 'protocol.json'))
    if report['status'] != 'complete' or report['manifest_sha256'] != digest(root / 'manifest.json'):
        raise ValueError('Complete unchanged source replay required')
    if any(report.get(key) is not True for key in ('inputs_unchanged', 'implementation_unchanged', 'compiled_model_unchanged')):
        raise ValueError('Replay integrity failure')
    for path, expected in manifest['input_sha256'].items():
        if digest(root / path) != expected:
            raise ValueError('Replay input drift')
    for path, expected in manifest['implementation_sha256'].items():
        if digest(archived_implementation(root, path)) != expected or digest(Path(path)) != expected:
            raise ValueError('Exact replay code required for metric reproduction')
    source_run = Path(protocol['source_run'])
    if digest(source_run / 'manifest.json') != protocol['source_manifest_sha256'] or digest(source_run / 'report.json') != protocol['source_report_sha256']:
        raise ValueError('Historical witness provenance drift')
    tasks = {row['id']: row for row in manifest['tasks']}
    rows = {row['id']: row for row in report['rows']}
    native = {row['id']: row for row in read(source_run / 'report.json')['rows']}
    if len(tasks) != 15 or len(rows) != 15 or len(manifest['tasks']) != 15 or len(report['rows']) != 15 or set(tasks) != set(rows) or set(tasks) != set(native):
        raise ValueError('Incomplete15-source denominator')
    meta = read(root / 'model/meta_domain.json')
    domains = {path.name.removesuffix('_domainfile.pddl'): parse_domain(path) for path in (root / 'inputs').glob('*_domainfile.pddl')}
    output.mkdir(parents=True)
    checked, failed, spent = [], [], 0
    for source, task in tasks.items():
        row = dict(rows[source])
        if task['source_search_status'] != native[source]['status']:
            raise ValueError('Source availability changed')
        if task['admission_status'] != 'ready':
            if native[source]['status'] == 'solved' or row['status'] != 'no_original_plan_evidence':
                raise ValueError('Missing plan evidence was promoted or omitted')
            checked.append(row)
            continue
        original, mapped = source_run / 'tasks' / source, root / 'replays' / source
        if digest(original / 'plan.txt') != task['native_plan_sha256']:
            raise ValueError('Native witness changed')
        for name in ('domain', 'problem'):
            suffix = '_domainfile.pddl' if name == 'domain' else '_problemfile.pddl'
            if (original / (name + '.pddl')).read_bytes() != (root / 'inputs' / (source + suffix)).read_bytes():
                raise ValueError('Original world differs from explicit replay inputs')
        if digest(mapped / 'domain.pddl') != protocol['domain_sha256'] or digest(mapped / 'problem.pddl') != task['mapped_problem_sha256']:
            raise ValueError('Actual replay model/world drift')
        mapping = read(root / 'worlds' / source / 'query_mapping.json')
        row['world_checks'] = check_world(source,
            parse_sexpr((original / 'problem.pddl').read_text(encoding='utf-8')), domains, meta,
            parse_sexpr((mapped / 'problem.pddl').read_text(encoding='utf-8')), mapping)
        row['fresh_mapped_validation'] = validate_artifacts(mapped)
        view = output / 'views' / source / 'planning'
        view.mkdir(parents=True)
        for name in ('domain.pddl', 'problem.pddl', 'plan.txt'):
            (view / name).write_bytes((mapped / name).read_bytes())
        row['inverse'] = native_transport(source, root / 'inputs', view.parent, meta, mapping, output / 'inverse' / source)
        reader = PDDLReader()
        native_problem = reader.parse_problem(str(original / 'domain.pddl'), str(original / 'problem.pddl'))
        left = reader.parse_plan(native_problem, str(original / 'plan.txt'))
        right = reader.parse_plan(native_problem, str(output / 'inverse' / source / 'plan.txt'))
        row['all_action_argument_positions_round_trip'] = steps(left) == steps(right)
        reproduced = compare_states(original, mapped, source, meta, mapping,
            protocol['budget']['max_total_atom_comparisons'] - spent)
        spent += reproduced['comparisons']
        row['truth_metric_reproduced'] = reproduced == row['truth_projection']
        valid = (all(value for value in row['world_checks'].values() if type(value) is bool)
            and row['fresh_mapped_validation']['status'] == 'VALID' and row['inverse']['status'] == 'valid'
            and row['all_action_argument_positions_round_trip'] and row['truth_metric_reproduced'])
        if not valid:
            failed.append(source)
        checked.append(row)
    if spent != report['source_atom_comparisons']:
        raise ValueError('Source-atom denominator mismatch')
    implementation = snapshot_implementation(output, [Path(__file__), Path('scripts/audit/audit_original_world_pipeline.py'),
        Path('scripts/experiments/replay_live_model_sources.py'), Path('rcnc/validation.py'),
        Path('rcnc/domain_building.py'), Path('rcnc/pddl.py')])
    result = {'status': 'verified_live_model_source_replay' if not failed else 'audited_with_violations',
        'task_count': 15, 'rows': checked, 'status_counts': dict(Counter(row['status'] for row in checked)),
        'source_atom_comparisons': spent, 'available_source_plans': report['available_source_plans'],
        'audit_failures': failed, 'hashes_unchanged': True, 'new_solver_or_model_calls': 0,
        'independent_semantic_labels': 0, 'report_sha256': digest(root / 'report.json'),
        'manifest_sha256': digest(root / 'manifest.json'), 'implementation_sha256': implementation,
        'scope': 'Independent original-world/goal reconstruction and inverse full-instance validation, plus reproduction of the frozen simulator truth checker. Same six historical native witnesses, not additional independent cases or interface-semantic labels.'}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = audit(args.root, args.output)
    print(json.dumps({key: value for key, value in result.items() if key not in ('rows', 'implementation_sha256')}, indent=2))

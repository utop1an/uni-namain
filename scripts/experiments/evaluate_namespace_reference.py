"""Predeclared fresh-reference comparison on separately supplied source worlds.

The reference exporter defines a positional literal projection, not a proof of
source truth/transition preservation. All construction and transport failures
remain in the fixed slot registry; no plan-specific model is constructed.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import shutil

from unified_planning.environment import Environment
from unified_planning.io import PDDLReader

from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.namespace_export import inverse_maps, name_maps, transform
from rcnc.pddl import parse_domain, parse_sexpr
from scripts.audit.export_namespace_diagnostic import candidate_path
from scripts.experiments.evaluate_cached_root_worlds import renamed_world, renaming_injectivity
from scripts.experiments.run_downward_reference import run as run_solver


REFERENCE = 'fresh_reference_category_qualified_all'
REFERENCE_ENTRYPOINTS = {'unidomain_ollama_fusion.py', 'unidomain/__main__.py'}
REFERENCE_ARCHIVE = {'rcnc/pddl.py', 'rcnc/pddl_checks.py',
    'rcnc/namespace_export.py', 'scripts/experiments/run_fusion_reference.py',
    'unidomain/__init__.py', 'unidomain/cli.py', 'unidomain/fusion.py', 'unidomain/models.py',
    'unidomain/pipeline.py', 'prompts/domain_fusion/check_merge_actions.txt',
    'prompts/domain_fusion/check_merge_predicates.txt', 'prompts/domain_fusion/update_action_string.txt'}


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def strict_parse(domain, problem=None):
    environment = Environment()
    environment.error_used_name = True
    return PDDLReader(environment=environment).parse_problem(str(domain), str(problem) if problem else None)


def checked_inventory(directory, inventory):
    for name, expected in inventory.items():
        if digest(candidate_path(directory, name)) != expected:
            raise ValueError('Frozen artifact changed: ' + name)


def registered_slots(protocol):
    sources, conditions = protocol['sources'], protocol['conditions']
    if (len(set(sources)) != len(sources) or sources != sorted(sources)
            or len(set(conditions)) != len(conditions) or REFERENCE not in conditions
            or any(not re.fullmatch(r'[A-Za-z][A-Za-z0-9_-]*', x) for x in sources + conditions)
            or len(sources) != protocol['world_count']
            or len(sources) * len(conditions) != protocol['slot_count']
            or protocol['budget']['maximum_calls'] != protocol['slot_count']):
        raise ValueError('Complete unique source/condition registry required')
    slots = []
    for index, source in enumerate(sources):
        start = index % len(conditions)
        for condition in conditions[start:] + conditions[:start]:
            slots.append({'id': source + '__' + condition, 'source': source,
                          'condition': condition, 'representation': condition})
    return slots


def parent_admission(parent, protocol):
    manifest_path, report_path = parent / 'manifest.json', parent / 'report.json'
    if not manifest_path.is_file() or not report_path.is_file():
        raise ValueError('Authoritative terminal parent receipts required; no active run comparison')
    manifest, report = read(manifest_path), read(report_path)
    if manifest['status'] in ('prepared', 'running', 'starting') or report['status'] in ('running', 'starting'):
        raise ValueError('Active parent cannot prepare downstream searches')
    if manifest['status'] != report['status']:
        raise ValueError('Parent terminal receipts disagree')
    build = read(Path(protocol['build_protocol']))
    expected_build = {'model':build['model'], 'node_workers':build['node_workers'],
        'budget_seconds':build['full_worker_budget_seconds'], 'namespace_policy':build['namespace_policy'],
        'source_count':protocol['world_count']}
    if (any(manifest.get(key) != value for key,value in expected_build.items())
            or build['full_input_sha256'] != protocol['source_sha256']
            or manifest.get('condition', 'fresh') != 'fresh'):
        raise ValueError('Parent differs from the registered fresh build condition')
    implementation = manifest.get('implementation_sha256', {})
    if (not REFERENCE_ARCHIVE.issubset(implementation)
            or not REFERENCE_ENTRYPOINTS.intersection(implementation)):
        raise ValueError('Parent has no complete archived export implementation')
    checked_inventory(parent / 'implementation', implementation)
    if manifest['source_sha256'] != protocol['source_sha256']:
        raise ValueError('Registered source cohort differs from parent')
    checked_inventory(parent / 'inputs', protocol['source_sha256'])
    if (manifest.get('namespace_policy') != 'category_qualified'
            or manifest.get('cache_policy') != 'new empty per-run cache; no historical answers imported'):
        raise ValueError('Registered fresh namespace condition required')
    if manifest['status'] != 'complete':
        return False, manifest['status'], None
    if (not isinstance(manifest.get('model_digest'), str)
            or not re.fullmatch(r'[0-9a-f]{64}', manifest['model_digest'])):
        raise ValueError('Parent differs from the registered fresh build condition: missing model digest')
    if build.get('pilot_output'):
        pilot = Path(build['pilot_output'])
        pilot_manifest, pilot_report = read(pilot / 'manifest.json'), read(pilot / 'report.json')
        if (pilot_manifest.get('status') != 'complete' or pilot_report.get('status') != 'complete'
                or pilot_report.get('validation', {}).get('valid') is not True
                or pilot_manifest.get('model_digest') != manifest['model_digest']):
            raise ValueError('Parent/pilot model identity or pilot admission differs')
    validation = read(parent / 'fusion/validation.json')
    valid = (report.get('source_snapshot_unchanged') is True
        and report.get('implementation_unchanged') is True
        and validation == report.get('validation') and validation.get('valid') is True
        and validation.get('namespace_export', {}).get('all_roundtrips_equal') is True
        and validation.get('namespace_export', {}).get('policy') == 'category_qualified'
        and validation.get('problem_files') == protocol['world_count']
        and len(validation.get('strict_parse_rows', [])) == protocol['world_count'] + 1
        and {row['id'] for row in validation.get('strict_parse_rows', [])}
            == {'domain_only', *[s + '_problemfile.pddl' for s in protocol['sources']]}
        and all(row['status'] == 'PARSED' for row in validation.get('strict_parse_rows', [])))
    if not valid:
        return False, 'complete_receipt_failed_admission', validation
    checked_inventory(parent / 'fusion/planning_export', validation['namespace_export']['output_sha256'])
    return True, 'complete', validation


def reference_worlds(parent, protocol, validation, *, model_root=None, input_root=None):
    """Verify raw literal projection and the actual fixed namespace export."""
    model = Path(model_root) if model_root is not None else parent / 'fusion'
    inputs = Path(input_root) if input_root is not None else parent / 'inputs'
    raw_domain = parse_sexpr((model / 'meta_domain.pddl').read_text(encoding='utf-8'))
    metadata = read(model / 'meta_domain.json')
    target = parse_domain(model / 'meta_domain.pddl')
    if set(metadata['sources']) != set(protocol['sources']):
        raise ValueError('Root source cohort incomplete')
    raw_worlds = {source: parse_sexpr((model / 'problems' / (source + '_problemfile.pddl')).read_text(encoding='utf-8'))
                  for source in protocol['sources']}
    maps = read(model / 'planning_export/namespace_maps.json')
    if maps != name_maps(raw_domain, list(raw_worlds.values())):
        raise ValueError('Export map differs from the complete fixed model/world cohort')
    reverse = inverse_maps(maps)
    if read(model / 'planning_export/inverse_namespace_maps.json') != reverse:
        raise ValueError('Recorded inverse namespace map differs')
    domain_path = candidate_path(model, validation['planning_domain'])
    adapted = parse_sexpr(domain_path.read_text(encoding='utf-8'))
    if adapted != transform(raw_domain, maps) or transform(adapted, reverse) != raw_domain:
        raise ValueError('Planning domain is not the reversible fixed export')
    strict_parse(domain_path)
    expected_paths = {'planning_export/problems/' + s + '_problemfile.pddl' for s in protocol['sources']}
    if set(validation['planning_problems']) != expected_paths or len(validation['planning_problems']) != len(expected_paths):
        raise ValueError('Complete actual planning-world inventory required')
    rows = {}
    for source in protocol['sources']:
        row = {'admission_status': 'ready',
               'world_interpretation': 'Recorded positional literal projection; source truth/transition equivalence not established'}
        try:
            native = parse_domain(inputs / (source + '_domainfile.pddl'))
            predicates, constants = metadata['predicate_maps'][source], metadata['constant_maps'][source]
            if set(predicates) != set(native.predicates) or set(constants) != set(native.constants):
                raise ValueError('Incomplete source predicate/constant mapping')
            row.update(renaming_injectivity(predicates,constants))
            if any(p not in target.predicates or native.predicates[n].arity != target.predicates[p].arity
                   for n, p in predicates.items()) or set(constants.values()) - set(target.constants):
                raise ValueError('Unsupported positional predicate/constant transport')
            original = parse_sexpr((inputs / (source + '_problemfile.pddl')).read_text(encoding='utf-8'))
            if raw_worlds[source] != renamed_world(original, target.name, predicates, constants):
                raise ValueError('Raw exported world differs beyond recorded renaming')
            path = model / 'planning_export/problems' / (source + '_problemfile.pddl')
            world = parse_sexpr(path.read_text(encoding='utf-8'))
            if world != transform(raw_worlds[source], maps, problem=True) or transform(world, reverse, problem=True) != raw_worlds[source]:
                raise ValueError('Planning world differs from reversible namespace export')
            strict_parse(domain_path, path)
            row.update(domain=domain_path, problem=path)
        except Exception as exc:
            row.update(admission_status='unsupported_transport', reason=f'{type(exc).__name__}: {exc}')
        rows[source] = row
    return rows


def prepare(protocol_path, output):
    require_empty_output(output)
    protocol = read(protocol_path)
    slots = registered_slots(protocol)
    if digest(Path(protocol['build_protocol'])) != protocol['build_protocol_sha256']:
        raise ValueError('Build registration changed')
    controls = Path(protocol['control_bundle'])
    if digest(controls / 'manifest.json') != protocol['control_manifest_sha256']:
        raise ValueError('Control manifest changed')
    checked_inventory(controls, protocol['control_file_sha256'])
    auxiliary_root = Path(protocol.get('control_auxiliary_root', controls.parent))
    auxiliary = protocol.get('control_auxiliary_sha256', {})
    checked_inventory(auxiliary_root, auxiliary)
    if protocol.get('historical_control_audit') and digest(Path(protocol['historical_control_audit'])) != protocol['historical_control_audit_sha256']:
        raise ValueError('Historical control audit changed')
    control_manifest = read(controls / 'manifest.json')
    control_index = {row['id']: row for row in control_manifest['tasks']}
    expected_controls = {row['id'] for row in slots if row['condition'] != REFERENCE}
    if (control_manifest['status'] != 'frozen_before_search' or len(control_index) != len(control_manifest['tasks'])
            or set(control_index) != expected_controls):
        raise ValueError('Complete control registry required')
    parent = Path(protocol['parent'])
    admitted, parent_status, validation = parent_admission(parent, protocol)
    worlds = reference_worlds(parent, protocol, validation) if admitted else {}
    output.mkdir(parents=True)
    (output / 'protocol.json').write_bytes(protocol_path.read_bytes())
    (output / 'control_manifest.json').write_bytes((controls / 'manifest.json').read_bytes())
    for name in auxiliary:
        path = candidate_path(output / 'control_evidence', name); path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(candidate_path(auxiliary_root, name), path)
    if protocol.get('historical_control_audit'):
        shutil.copyfile(Path(protocol['historical_control_audit']), output / 'historical_control_audit.json')
    for name in ('manifest.json', 'report.json'):
        (output / ('parent_' + name)).write_bytes((parent / name).read_bytes())
    source_snapshot = output / 'original_inputs'; source_snapshot.mkdir()
    for name in protocol['source_sha256']:
        shutil.copyfile(parent / 'inputs' / name, source_snapshot / name)
    if admitted:
        archive = output / 'reference_artifacts'
        for name in ('meta_domain.pddl', 'meta_domain.json', 'validation.json',
                     *['problems/' + s + '_problemfile.pddl' for s in protocol['sources']],
                     *['planning_export/' + n for n in validation['namespace_export']['output_sha256']]):
            path = candidate_path(archive, name); path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(candidate_path(parent / 'fusion', name), path)
    tasks = []
    for row in slots:
        if not admitted:
            row.update(admission_status='not_run_shared_parent_build_failure', parent_status=parent_status)
            continue
        if row['condition'] == REFERENCE:
            info = dict(worlds[row['source']])
            domain, problem = info.pop('domain', None), info.pop('problem', None)
            row.update(info)
            if row['admission_status'] != 'ready': continue
        else:
            task = control_index[row['id']]
            if task.get('source') != row['source'] or task.get('representation') != row['condition']:
                raise ValueError('Control source/representation differs')
            directory = controls / 'tasks' / row['id']
            domain, problem = directory / 'domain.pddl', directory / 'problem.pddl'
            if digest(domain) != task['domain_sha256'] or digest(problem) != task['problem_sha256']:
                raise ValueError('Control task hash differs from its manifest')
            row['admission_status'] = 'ready'
        directory = output / 'bundle/tasks' / row['id']; directory.mkdir(parents=True)
        shutil.copyfile(domain, directory / 'domain.pddl')
        shutil.copyfile(problem, directory / 'problem.pddl')
        row.update(domain_sha256=digest(directory / 'domain.pddl'), problem_sha256=digest(directory / 'problem.pddl'))
        tasks.append(dict(row))
    bundle = output / 'bundle'; bundle.mkdir(exist_ok=True)
    save(bundle / 'manifest.json', {'status': 'frozen_before_search', 'mode': 'matched_source_representations',
                                  'task_count': len(tasks), 'tasks': tasks})
    implementation = snapshot_implementation(output, [Path(__file__), Path('rcnc/domain_building.py'),
        Path('rcnc/namespace_export.py'), Path('rcnc/pddl.py'), Path('rcnc/pddl_checks.py'), Path('rcnc/validation.py'),
        Path('scripts/audit/export_namespace_diagnostic.py'), Path('scripts/experiments/evaluate_cached_root_worlds.py'),
        Path('scripts/experiments/run_downward_reference.py')])
    inputs = [p for p in output.rglob('*') if p.is_file() and 'implementation' not in p.relative_to(output).parts]
    manifest = {'status': 'frozen_before_search', 'world_count': protocol['world_count'], 'task_count': len(slots),
        'registered_protocol':str(protocol_path.resolve()), 'protocol_sha256':digest(output / 'protocol.json'),
        'slots': slots, 'parent_admitted': admitted, 'parent_status': parent_status,
        'construction_failure_count': 0 if admitted else 1, 'budget': protocol['budget'],
        'input_sha256': {p.relative_to(output).as_posix(): digest(p) for p in inputs},
        'implementation_sha256': implementation, 'scope': protocol['limits']}
    save(output / 'manifest.json', manifest)
    return manifest


def execute(output):
    manifest = read(output / 'manifest.json')
    if manifest['status'] != 'frozen_before_search' or (output / 'report.json').exists() or (output / 'solver').exists():
        raise ValueError('Only a fresh frozen registry can execute')
    protocol = read(output / 'protocol.json')
    expected_slots = registered_slots(protocol)
    if (manifest['budget'] != protocol['budget'] or manifest['scope'] != protocol['limits']
            or manifest['task_count'] != len(expected_slots) or manifest['world_count'] != protocol['world_count']
            or len(manifest['slots']) != len(expected_slots)
            or any(any(actual.get(key) != value for key,value in expected.items())
                   for actual,expected in zip(manifest['slots'],expected_slots))
            or digest(output / 'protocol.json') != manifest['protocol_sha256']
            or digest(Path(manifest['registered_protocol'])) != manifest['protocol_sha256']):
        raise ValueError('Registered source-world slots, budget or protocol changed before search')
    checked_inventory(output, manifest['input_sha256'])
    for name, expected in manifest['implementation_sha256'].items():
        if digest(Path(name)) != expected: raise ValueError('Frozen implementation changed')
    budget = manifest['budget']
    deadline = datetime.fromisoformat(budget['whole_goal_stop_before_utc'].replace('Z', '+00:00'))
    if deadline.tzinfo is None: raise ValueError('Explicit timezone required')
    enough = ((deadline - datetime.now(timezone.utc)).total_seconds()
        >= manifest['task_count'] * (budget['seconds_wall_and_cpu'] + budget['supervisor_grace_seconds_each'])
        + budget['cleanup_reserve_seconds'])
    ready_ids = {r['id'] for r in manifest['slots'] if r['admission_status'] == 'ready'}
    solved = run_solver(Path('.'), None, output / 'solver', Path('.tmp/fast-downward-26.6'),
        budget['seconds_wall_and_cpu'], budget['memory_mb'], task_bundle=output / 'bundle') if enough and ready_ids else None
    indexed = {row['id']: row for row in solved['rows']} if solved else {}
    if solved and (set(indexed) != ready_ids or len(indexed) != len(solved['rows'])):
        raise ValueError('Solver task denominator differs')
    rows = []
    for slot in manifest['slots']:
        row = dict(slot)
        if slot['id'] in indexed: row.update(indexed[slot['id']])
        else: row['status'] = 'not_run_due_goal_budget' if slot['admission_status'] == 'ready' else slot['admission_status']
        rows.append(row)
    integrity = (solved['status'] == 'complete' and all(solved.get(key) is True
        for key in ('binary_unchanged', 'runner_unchanged', 'implementation_unchanged', 'validator_unchanged'))
        and all(r.get('inputs_unchanged') is True for r in solved['rows'])) if solved else True
    result = {'status': 'complete', 'task_count': len(rows), 'world_count': manifest['world_count'],
        'actual_solver_calls': len(indexed), 'construction_failure_count': manifest['construction_failure_count'],
        'parent_admitted': manifest['parent_admitted'], 'rows': rows,
        'status_counts': dict(Counter(r['status'] for r in rows)),
        'by_condition': {c: dict(Counter(r['status'] for r in rows if r['condition'] == c))
                         for c in dict.fromkeys(r['condition'] for r in rows)},
        'manifest_sha256': digest(output / 'manifest.json'),
        'inputs_unchanged': all(digest(candidate_path(output, n)) == h for n, h in manifest['input_sha256'].items()),
        'implementation_unchanged': all(digest(Path(n)) == h for n, h in manifest['implementation_sha256'].items()),
        'solver_integrity': integrity, 'scope': manifest['scope']}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--protocol', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--execute-frozen', action='store_true')
    args = parser.parse_args()
    result = execute(args.output) if args.execute_frozen else prepare(args.protocol, args.output)
    print(json.dumps({k:v for k,v in result.items() if k not in ('rows', 'slots', 'input_sha256', 'implementation_sha256')}, indent=2))

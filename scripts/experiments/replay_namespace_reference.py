"""Frozen provided-prefix replay against an eligible fresh reference export.

All original action-invocation slots stay in the denominator. This performs no
search, never repairs/truncates a signature, and does not test original goals.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
import math
from pathlib import Path
import shutil
import subprocess
import sys
import time

from unified_planning.io import PDDLReader

from rcnc.action_alpha import structural_parameter_map
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.namespace_export import fold_symbol_map
from rcnc.pddl import parse_domain, typed_symbols
from scripts.audit.export_namespace_diagnostic import candidate_path
from scripts.experiments.evaluate_namespace_reference import parent_admission, reference_worlds


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def historical(protocol):
    root = Path(protocol['historical_root']).resolve()
    pins = protocol['historical_input_sha256']
    for name, expected in pins.items():
        if digest(candidate_path(root, name)) != expected:
            raise ValueError('Pinned historical prefix evidence changed: ' + name)

    def checked(path, expected=None):
        path = Path(path).resolve()
        try: name = path.relative_to(root).as_posix()
        except ValueError as exc: raise ValueError('Historical evidence escapes its explicit root') from exc
        if name not in pins or digest(path) != pins[name] or (expected is not None and pins[name] != expected):
            raise ValueError('Unpinned or mismatched historical input: ' + name)
        return path

    source_root, native_root = Path(protocol['source_task_bundle']), Path(protocol['native_solver_run'])
    tasks_manifest = read(checked(source_root / 'manifest.json'))
    native_manifest = read(checked(native_root / 'manifest.json'))
    native_report = read(checked(native_root / 'report.json'))
    audit = read(checked(Path(protocol['native_prefix_audit'])))
    tasks = tasks_manifest['tasks']
    native_rows = {r['id']:r for r in native_report['rows']}
    audited = {r['id']:r for r in audit['rows']}
    native_tasks = {r['id']:r for r in native_manifest['tasks']}
    ids = {r['id'] for r in tasks}
    count = protocol['task_count']
    if (len(tasks) != count or len(ids) != count
            or any(len(records) != count for records in (native_report['rows'],audit['rows'],native_manifest['tasks']))
            or any(len(records) != count for records in (native_rows,audited,native_tasks))
            or ids != set(native_rows) or ids != set(audited) or ids != set(native_tasks)
            or native_report['status'] != 'complete' or audit['status'] != 'complete'
            or audit.get('hashes_unchanged') is not True):
        raise ValueError('Complete pinned historical cohort required')
    if (len({(r['source'],r['target_action'].lower()) for r in tasks}) != count
            or {r['source'] for r in tasks} != set(protocol['sources'])):
        raise ValueError('One historical slot per source action and complete source population required')
    available = sum(r['status'] == 'PASS' for r in audited.values())
    if {'audited_prefixes':available,'no_audited_prefix':count-available} != protocol['source_trace_availability']:
        raise ValueError('Historical prefix availability changed')
    for task in tasks:
        identifier = task['id']
        if Path(identifier).name != identifier or '/' in identifier or '\\' in identifier:
            raise ValueError('Flat prefix identifiers required')
        source = candidate_path(source_root / 'tasks', identifier)
        native = candidate_path(native_root / 'tasks', identifier)
        for name in ('domain','problem'):
            if protocol['source_sha256'][task['source'] + '_' + name + 'file.pddl'] != task['source_' + name + '_sha256']:
                raise ValueError('Historical source world differs from fresh build population')
            checked(source / ('source_' + name + '.pddl'), task['source_' + name + '_sha256'])
            checked(native / (name + '.pddl'), task[name + '_sha256'])
            if native_tasks[identifier][name + '_sha256'] != task[name + '_sha256']:
                raise ValueError('Native task differs from source instrumentation registry')
        row = audited[identifier]
        if row['solver_status'] != native_rows[identifier]['status']:
            raise ValueError('Native solver/audit status differs')
        if row['status'] == 'PASS':
            if (row.get('target_invoked') is not True or row.get('instrumentation_audit') is not True
                    or row.get('instrumented_plan_validation') != 'VALID'):
                raise ValueError('Historical PASS lacks source-prefix admission evidence')
            checked(native / 'plan.txt')
    return tasks, audited


def action_bindings(source, target, source_id, metadata, namespace, budget):
    allowed, inventory = {}, []
    names = fold_symbol_map(namespace['actions'])
    predicates = metadata['predicate_maps'][source_id]
    constants = metadata['constant_maps'][source_id]
    mappings = metadata.get('action_maps', {}).get(source_id, {})
    for name, action in source.actions.items():
        mapped = mappings.get(name)
        entry = {'source':source_id, 'source_action':name, 'mapped_action':mapped}
        positions = None
        if mapped not in target.actions:
            entry['status'] = 'missing_mapping_or_target'
        else:
            def signature(value):
                return [(n.lower(),t.lower()) for n,t in typed_symbols(value[value.index(':parameters') + 1]).items()]
            left, right = signature(action), signature(target.actions[mapped])
            entry.update(source_parameter_count=len(left), target_parameter_count=len(right))
            if left == right:
                positions = list(range(len(left)))
                entry.update(status='unchanged_ordered_signature_only', checked=0)
            else:
                result = structural_parameter_map(action, target.actions[mapped], predicates, constants,
                    max_arity=budget['max_mapping_arity'], max_permutations=budget['max_mapping_permutations'])
                entry.update(result)
                if result['status'] == 'unique_structural_map':
                    positions = result['source_to_target_positions']
        if positions is not None:
            allowed[name.lower()] = {'target':names[mapped.lower()], 'positions':positions, 'basis':entry['status']}
            entry['source_to_target_positions'] = positions
        inventory.append(entry)
    return allowed, inventory


def prepare(protocol_path, output):
    require_empty_output(output)
    protocol = read(protocol_path)
    budget = protocol['budget']
    if (budget['workers'] != 1 or type(budget['workers']) is not int
            or type(budget['seconds_per_replay_process']) not in (int,float)
            or not math.isfinite(budget['seconds_per_replay_process']) or budget['seconds_per_replay_process'] <= 0
            or any(type(budget[key]) is not int or budget[key] < minimum for key,minimum in
                   (('max_source_atoms',1),('max_mapping_arity',0),('max_mapping_permutations',1)))
            or len(protocol['sources']) != protocol['world_count'] or len(set(protocol['sources'])) != protocol['world_count']):
        raise ValueError('Explicit valid single-worker replay/mapping budgets and sources required')
    if digest(Path(protocol['build_protocol'])) != protocol['build_protocol_sha256']:
        raise ValueError('Fresh build registration changed')
    tasks, audited = historical(protocol)
    parent = Path(protocol['parent'])
    admitted, parent_status, validation = parent_admission(parent, protocol)
    worlds = reference_worlds(parent, protocol, validation) if admitted else {}
    output.mkdir(parents=True)
    (output / 'protocol.json').write_bytes(protocol_path.read_bytes())
    for name in ('manifest.json','report.json'):
        shutil.copyfile(parent / name, output / ('parent_' + name))
    for key in ('native_prefix_audit',):
        shutil.copyfile(Path(protocol[key]), output / (key + '.json'))
    for key in ('source_task_bundle','native_solver_run'):
        shutil.copyfile(Path(protocol[key]) / 'manifest.json', output / (key + '_manifest.json'))
    shutil.copyfile(Path(protocol['native_solver_run']) / 'report.json', output / 'native_solver_report.json')
    source_inputs = output / 'source_inputs'; source_inputs.mkdir()
    for name in protocol['source_sha256']:
        shutil.copyfile(parent / 'inputs' / name, source_inputs / name)
    cache, inventories, allowed_by_source = {}, [], {}
    if admitted:
        model = parent / 'fusion'
        metadata = read(model / 'meta_domain.json')
        namespace = read(model / 'planning_export/namespace_maps.json')
        names = {category:fold_symbol_map(table) for category,table in namespace.items()}
        target_raw = parse_domain(model / 'meta_domain.pddl')
        target_dir = output / 'target'; target_dir.mkdir()
        shutil.copyfile(candidate_path(model, validation['planning_domain']), target_dir / 'domain.pddl')
        for path in validation['planning_problems']:
            original = candidate_path(model, path)
            destination = target_dir / 'problems' / original.name; destination.parent.mkdir(exist_ok=True)
            shutil.copyfile(original, destination)
        for name in ('meta_domain.pddl','meta_domain.json','validation.json'):
            shutil.copyfile(model / name, output / ('raw_' + name))
        for name in ('namespace_maps.json','inverse_namespace_maps.json'):
            shutil.copyfile(model / 'planning_export' / name, output / name)
        save(output / 'world_projection_inventory.json',
            {source:{k:v for k,v in info.items() if k not in ('domain','problem')} for source,info in worlds.items()})
        for source in protocol['sources']:
            source_tasks = [task for task in tasks if task['source'] == source]
            try:
                raw_source = parse_domain(source_inputs / (source + '_domainfile.pddl'))
                if {name.lower() for name in raw_source.actions} != {task['target_action'].lower() for task in source_tasks}:
                    raise ValueError('Historical action slots do not cover the entire source schema')
                allowed, inventory = action_bindings(raw_source,target_raw,source,metadata,namespace,protocol['budget'])
            except Exception as exc:
                allowed = {}
                inventory = [{'source':source,'source_action':task['target_action'],
                    'status':'unverified_mapping_context','reason':f'{type(exc).__name__}: {exc}'} for task in source_tasks]
            allowed_by_source[source] = allowed
            inventories.extend(inventory)
    reader = PDDLReader()
    slots = []
    for task in tasks:
        identifier, source = task['id'], task['source']
        history = audited[identifier]
        slot = {'id':identifier, 'source':source, 'target_action':task['target_action'],
                'original_solver_status':history['solver_status'], 'original_prefix_audit_status':history['status']}
        if not admitted:
            slot.update(admission_status='not_run_shared_parent_build_failure', parent_status=parent_status)
        elif history['status'] != 'PASS':
            slot['admission_status'] = 'no_audited_source_prefix'
        elif worlds[source]['admission_status'] != 'ready':
            slot.update(admission_status='unsupported_world_projection', reason=worlds[source].get('reason'))
        else:
            try:
                source_domain = source_inputs / (source + '_domainfile.pddl')
                source_problem = source_inputs / (source + '_problemfile.pddl')
                if digest(source_domain) != task['source_domain_sha256'] or digest(source_problem) != task['source_problem_sha256']:
                    raise ValueError('Source prefix world differs from the original frozen world')
                if source not in cache:
                    allowed = allowed_by_source[source]
                    parsed = reader.parse_problem(str(source_domain),str(source_problem))
                    constants = fold_symbol_map(metadata['constant_maps'][source])
                    objects = {obj.name.lower():names['objects'][constants.get(obj.name.lower(),obj.name.lower())]
                               for obj in parsed.all_objects}
                    predicates = {old.lower():names['predicates'][new.lower()] for old,new in metadata['predicate_maps'][source].items()}
                    cache[source] = parsed,allowed,objects,predicates
                parsed,allowed,objects,predicates = cache[source]
                original_plan = Path(protocol['native_solver_run']) / 'tasks' / identifier / 'plan.txt'
                plan = reader.parse_plan(parsed,str(original_plan))
                if (len(plan.actions) != history['plan_length']
                        or sorted({a.action.name for a in plan.actions}) != history['visited_actions']
                        or not any(a.action.name.lower() == task['target_action'].lower() for a in plan.actions)):
                    raise ValueError('Provided prefix differs from the pinned audit admission')
                missing = sorted({a.action.name.lower() for a in plan.actions if a.action.name.lower() not in allowed})
                if missing:
                    slot.update(admission_status='unverified_parameter_transport', unmapped_actions=missing)
                else:
                    case = output / 'cases' / identifier; case.mkdir(parents=True)
                    shutil.copyfile(original_plan,case / 'source.plan')
                    job = {'source_domain':str(source_domain.resolve()), 'source_problem':str(source_problem.resolve()),
                        'source_plan':str((case / 'source.plan').resolve()),
                        'target_domain':str((output / 'target/domain.pddl').resolve()),
                        'target_problem':str((output / 'target/problems' / (source + '_problemfile.pddl')).resolve()),
                        'output':str((case / 'replay').resolve()), 'objects':objects, 'predicates':predicates,
                        'actions':{a.action.name.lower():allowed[a.action.name.lower()] for a in plan.actions},
                        'applicability_policy':'public_is_applicable', 'max_atoms':protocol['budget']['max_source_atoms']}
                    job['input_sha256'] = {job[key]:digest(Path(job[key])) for key in
                        ('source_domain','source_problem','source_plan','target_domain','target_problem')}
                    save(case / 'job.json',job)
                    slot.update(admission_status='ready', source_steps=len(plan.actions), job='cases/' + identifier + '/job.json')
            except Exception as exc:
                slot.update(admission_status='unverified_source_prefix_preparation', reason=f'{type(exc).__name__}: {exc}')
        slots.append(slot)
    save(output / 'action_mapping_inventory.json', {'rows':inventories,
        'scope':'Complete formal transport candidates only; unchanged ordered names/types or unique bounded structural bijection, not semantic equivalence'})
    code = snapshot_implementation(output, [Path(__file__), Path('scripts/experiments/reference_prefix_worker.py'),
        Path('scripts/experiments/reference_prefix_compare.py'), Path('scripts/experiments/evaluate_namespace_reference.py'),
        Path('scripts/experiments/evaluate_cached_root_worlds.py'), Path('scripts/experiments/run_downward_reference.py'),
        Path('scripts/audit/export_namespace_diagnostic.py'), *sorted(Path('rcnc').glob('*.py'))])
    files = [p for p in output.rglob('*') if p.is_file() and 'implementation' not in p.relative_to(output).parts]
    manifest = {'status':'frozen_before_prefix_validation', 'task_count':len(slots), 'slots':slots,
        'parent_admitted':admitted, 'parent_status':parent_status, 'construction_failure_count':0 if admitted else 1,
        'ready_prefixes':sum(r['admission_status'] == 'ready' for r in slots), 'budget':protocol['budget'],
        'registered_protocol':str(protocol_path.resolve()), 'protocol_sha256':digest(output / 'protocol.json'),
        'input_sha256':{p.relative_to(output).as_posix():digest(p) for p in files},
        'historical_root':protocol['historical_root'], 'historical_input_sha256':protocol['historical_input_sha256'],
        'implementation_sha256':code, 'scope':protocol['scope'],
        'historical_dependency_scope':'Run-local snapshots replay the provided prefixes; original native planning/audit evidence remains externally pinned in this repository.'}
    save(output / 'manifest.json',manifest)
    return manifest


def execute(output):
    manifest = read(output / 'manifest.json')
    if (manifest['status'] != 'frozen_before_prefix_validation' or (output / 'report.json').exists()
            or any((output / 'cases' / r['id'] / 'replay').exists() for r in manifest['slots'])):
        raise ValueError('Only a fresh complete frozen prefix registry can execute')
    protocol = read(output / 'protocol.json')
    if (digest(Path(manifest['registered_protocol'])) != manifest['protocol_sha256']
            or digest(output / 'protocol.json') != manifest['protocol_sha256'] or manifest['budget'] != protocol['budget']
            or manifest['task_count'] != protocol['task_count'] or len(manifest['slots']) != protocol['task_count']):
        raise ValueError('Registered prefix budget or denominator changed')
    originals = read(output / 'source_task_bundle_manifest.json')['tasks']
    expected = {task['id']:task for task in originals}
    slots = {slot['id']:slot for slot in manifest['slots']}
    if (len(expected) != protocol['task_count'] or len(slots) != protocol['task_count'] or set(expected) != set(slots)
            or manifest['ready_prefixes'] != sum(s['admission_status'] == 'ready' for s in manifest['slots'])
            or any(slots[key]['source'] != task['source'] or slots[key]['target_action'] != task['target_action']
                   for key,task in expected.items())):
        raise ValueError('Complete unique source-prefix denominator required')
    for name, expected in manifest['input_sha256'].items():
        if digest(candidate_path(output,name)) != expected: raise ValueError('Frozen prefix input changed')
    for name, expected in manifest['implementation_sha256'].items():
        if digest(Path(name)) != expected: raise ValueError('Frozen prefix implementation changed')
    for name, expected in manifest['historical_input_sha256'].items():
        if digest(candidate_path(Path(manifest['historical_root']),name)) != expected:
            raise ValueError('Frozen historical prefix evidence changed before replay')
    budget = manifest['budget']
    deadline = datetime.fromisoformat(budget['stop_validation_utc'].replace('Z','+00:00'))
    if deadline.tzinfo is None: raise ValueError('Explicit deadline timezone required')
    enough = (deadline - datetime.now(timezone.utc)).total_seconds() >= manifest['ready_prefixes'] * (budget['seconds_per_replay_process'] + 1) + 600
    rows, calls = [], 0
    for slot in manifest['slots']:
        row = dict(slot)
        if slot['admission_status'] != 'ready': row['status'] = slot['admission_status']
        elif not enough: row['status'] = 'not_run_due_goal_budget'
        elif (deadline - datetime.now(timezone.utc)).total_seconds() < budget['seconds_per_replay_process'] + 1:
            row['status'] = 'not_run_diagnostic_deadline'
        else:
            job_path = candidate_path(output,slot['job']); case = job_path.parent
            start = time.monotonic(); calls += 1
            try:
                with (case / 'worker.log').open('w',encoding='utf-8') as log:
                    process = subprocess.run([sys.executable,'-X','utf8','-m','scripts.experiments.reference_prefix_worker',
                        '--job',str(job_path.resolve())], stdout=log,stderr=subprocess.STDOUT,
                        timeout=budget['seconds_per_replay_process'])
                child_path = case / 'replay/report.json'
                child = read(child_path) if child_path.exists() else None
                if process.returncode == 0 and child is not None:
                    row.update(child)
                else:
                    row.update(status='worker_error', child_report=child)
                row['worker_exit_code'] = process.returncode
            except subprocess.TimeoutExpired:
                row['status'] = 'diagnostic_time_limit'
            except Exception as exc:
                row.update(status='worker_error', reason=f'{type(exc).__name__}: {exc}')
            row['elapsed_seconds'] = round(time.monotonic() - start,3)
        rows.append(row)
        save(output / 'progress.json', {'completed':len(rows),'task_count':manifest['task_count'],'rows':rows})
    execution_complete = calls == manifest['ready_prefixes']
    result = {'status':'complete' if execution_complete else 'complete_registry_with_unrun_prefixes',
        'execution_complete':execution_complete, 'task_count':len(rows), 'rows':rows,
        'ready_prefixes':manifest['ready_prefixes'], 'actual_replay_processes':calls,
        'construction_failure_count':manifest['construction_failure_count'], 'parent_admitted':manifest['parent_admitted'],
        'status_counts':dict(Counter(r['status'] for r in rows)),
        'truth_comparisons':sum(r.get('truth_comparisons',0) for r in rows),
        'mismatch_count':sum(r.get('mismatch_count',0) for r in rows),
        'inputs_unchanged':all(digest(candidate_path(output,n)) == h for n,h in manifest['input_sha256'].items()),
        'historical_inputs_unchanged':all(digest(candidate_path(Path(manifest['historical_root']),n)) == h
                                        for n,h in manifest['historical_input_sha256'].items()),
        'implementation_unchanged':all(digest(Path(n)) == h for n,h in manifest['implementation_sha256'].items()),
        'manifest_sha256':digest(output / 'manifest.json'), 'model_calls':0, 'planner_calls':0,
        'goal_evaluation':'not_requested_source_prefix_only', 'scope':manifest['scope']}
    save(output / 'report.json',result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--protocol',type=Path)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--execute-frozen',action='store_true')
    args = parser.parse_args()
    result = execute(args.output) if args.execute_frozen else prepare(args.protocol,args.output)
    print(json.dumps({k:v for k,v in result.items() if k not in ('rows','slots','input_sha256','historical_input_sha256','implementation_sha256')},indent=2))

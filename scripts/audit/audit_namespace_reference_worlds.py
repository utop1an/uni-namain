"""Audit a fixed fresh-reference world comparison and every saved plan.

Shared world validators and independent plan validation are reused. This is not
independent interface semantics, universal source preservation, or timing evidence.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import shutil

from rcnc.domain_building import archived_implementation, digest, require_empty_output, save, snapshot_implementation
from rcnc.pddl import parse_domain, parse_sexpr
from rcnc.validation import validate_artifacts
from scripts.audit.audit_original_world_pipeline import check_world, native_transport
from scripts.audit.export_namespace_diagnostic import candidate_path
from scripts.experiments.evaluate_namespace_reference import REFERENCE, registered_slots, reference_worlds
from scripts.experiments.run_downward_reference import linux_path


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def audit(root, output):
    require_empty_output(output)
    manifest, report, protocol = [read(root / name) for name in ('manifest.json','report.json','protocol.json')]
    if (report['status'] != 'complete' or report['manifest_sha256'] != digest(root / 'manifest.json')
            or manifest['budget'] != protocol['budget'] or manifest['scope'] != protocol['limits']
            or any(report.get(k) is not True for k in ('inputs_unchanged','implementation_unchanged','solver_integrity'))):
        raise ValueError('Matching terminal comparison and runtime integrity required')
    for name, expected in manifest['input_sha256'].items():
        if digest(candidate_path(root,name)) != expected: raise ValueError('Frozen comparison input changed')
    for name, expected in manifest['implementation_sha256'].items():
        if digest(archived_implementation(root,name)) != expected: raise ValueError('Archived comparison implementation changed')
    expected_slots = registered_slots(protocol)
    if (len(manifest['slots']) != len(expected_slots) or len(report['rows']) != len(expected_slots)
            or manifest['task_count'] != len(expected_slots) or report['task_count'] != len(expected_slots)):
        raise ValueError('Complete registered source-world denominator required')
    slots = {r['id']:r for r in manifest['slots']}; rows = {r['id']:r for r in report['rows']}
    if (len(slots) != len(expected_slots) or len(rows) != len(expected_slots)
            or list(slots) != [r['id'] for r in expected_slots] or list(rows) != list(slots)
            or any(any(slots[r['id']].get(k) != v for k,v in r.items()) for r in expected_slots)):
        raise ValueError('Duplicate,reordered or changed source-world slots')
    if (dict(Counter(r['status'] for r in rows.values())) != report['status_counts']
            or {c:dict(Counter(r['status'] for r in rows.values() if r['condition'] == c)) for c in protocol['conditions']}
                != report['by_condition']):
        raise ValueError('Comparison summary differs from original rows')
    controls = Path(protocol['control_bundle']); control_manifest = read(root / 'control_manifest.json')
    if digest(root / 'control_manifest.json') != protocol['control_manifest_sha256']:
        raise ValueError('Control registry differs')
    for name, expected in protocol['control_file_sha256'].items():
        if digest(candidate_path(controls,name)) != expected: raise ValueError('Original control PDDL changed')
    for name, expected in protocol.get('control_auxiliary_sha256',{}).items():
        if digest(candidate_path(root / 'control_evidence',name)) != expected: raise ValueError('Frozen control mapping evidence changed')
    if protocol.get('historical_control_audit') and digest(root / 'historical_control_audit.json') != protocol['historical_control_audit_sha256']:
        raise ValueError('Frozen historical control audit differs')
    ready = {r['id'] for r in manifest['slots'] if r['admission_status'] == 'ready'}
    actual = {}; solver = None
    if (root / 'solver').exists():
        solver, solver_manifest = read(root / 'solver/report.json'), read(root / 'solver/manifest.json')
        actual = {r['id']:r for r in solver['rows']}
        if (solver['status'] != 'complete' or len(actual) != len(solver['rows']) or set(actual) != ready
                or list(actual) != [r['id'] for r in manifest['slots'] if r['admission_status'] == 'ready']
                or solver['manifest_sha256'] != digest(root / 'solver/manifest.json')
                or solver_manifest['budget'] != {'wall_seconds':protocol['budget']['seconds_wall_and_cpu'],
                    'overall_cpu_seconds':protocol['budget']['seconds_wall_and_cpu'],'memory_mb':protocol['budget']['memory_mb']}
                or any(solver.get(k) is not True for k in ('binary_unchanged','runner_unchanged','implementation_unchanged','validator_unchanged'))):
            raise ValueError('Actual solver cohort or registered budget differs')
    if report['actual_solver_calls'] != len(actual): raise ValueError('Actual solver-call denominator differs')
    parent_admitted = manifest['parent_admitted']
    if (report['parent_admitted'] != parent_admitted or report['construction_failure_count'] != (0 if parent_admitted else 1)):
        raise ValueError('Shared construction outcome changed')
    reference = {}
    if parent_admitted:
        reference_root = root / 'reference_artifacts'
        reference = reference_worlds(root,protocol,read(reference_root / 'validation.json'),
            model_root=reference_root,input_root=root / 'original_inputs')
    originals = {source:parse_domain(root / 'original_inputs' / (source + '_domainfile.pddl')) for source in protocol['sources']}
    for name, expected in protocol['source_sha256'].items():
        if digest(root / 'original_inputs' / name) != expected: raise ValueError('Original source world changed')
    control_index = {r['id']:r for r in control_manifest['tasks']}
    output.mkdir(parents=True,exist_ok=True)
    checked, failures, plan_pins = [], [], {}
    for slot in manifest['slots']:
        identifier, source, condition = slot['id'], slot['source'], slot['condition']
        row = rows[identifier]
        if any(row.get(k) != v for k,v in slot.items()): raise ValueError('Result identity changed')
        if not parent_admitted: expected = 'not_run_shared_parent_build_failure'
        elif condition == REFERENCE: expected = reference[source]['admission_status']
        else: expected = 'ready'
        if slot['admission_status'] != expected: raise ValueError('World admission differs from frozen model/projection')
        if expected != 'ready':
            if row['status'] != expected or identifier in actual: raise ValueError('Unavailable world was promoted')
            checked.append({**row,'fresh_validation':{'status':'NO_PLAN'},'native_replay':{'status':'not_run'}})
            continue
        frozen = root / 'bundle/tasks' / identifier
        for name in ('domain','problem'):
            if digest(frozen / (name + '.pddl')) != slot[name + '_sha256']: raise ValueError('Frozen task PDDL differs')
        if condition == REFERENCE:
            for name in ('domain','problem'):
                if digest(reference[source][name]) != slot[name + '_sha256']: raise ValueError('Reference task replaced the fixed export')
            world_checks = {'reference_positional_world_exact':True}
        else:
            previous = controls / 'tasks' / identifier
            if any(digest(previous / (name + '.pddl')) != slot[name + '_sha256']
                   or control_index[identifier][name + '_sha256'] != slot[name + '_sha256'] for name in ('domain','problem')):
                raise ValueError('Control task differs from predeclared PDDL')
            if condition == 'native_source':
                world_checks = {name + '_original_exact': (frozen / (name + '.pddl')).read_bytes()
                    == (root / 'original_inputs' / (source + suffix)).read_bytes()
                    for name,suffix in (('domain','_domainfile.pddl'),('problem','_problemfile.pddl'))}
            elif protocol.get('control_auxiliary_sha256'):
                kind = 'zero_merge' if condition.startswith('zero_merge') else 'machine'
                metadata = read(root / 'control_evidence/models' / kind / 'meta_domain.json')
                mapping = read(root / 'control_evidence/bundle/tasks' / identifier / 'query_mapping.json')
                original = parse_sexpr((root / 'original_inputs' / (source + '_problemfile.pddl')).read_text(encoding='utf-8'))
                mapped = parse_sexpr((frozen / 'problem.pddl').read_text(encoding='utf-8'))
                world_checks = check_world(source,original,originals,metadata,mapped,mapping)
            else: world_checks = {'exact_registered_control_bytes':True}
        if not all(v for v in world_checks.values() if type(v) is bool): failures.append({'id':identifier,'reason':'world mismatch'})
        result = {**row,'world_checks':world_checks,'fresh_validation':{'status':'NO_PLAN'},'native_replay':{'status':'no_plan'}}
        if identifier not in actual:
            if row['status'] != 'not_run_due_goal_budget': raise ValueError('Ready world missing from actual solver cohort')
            if (root / 'solver/tasks' / identifier).exists(): raise ValueError('Unrun world has solver artifacts')
            checked.append(result); continue
        child = actual[identifier]
        if row['status'] != child['status'] or child.get('inputs_unchanged') is not True:
            raise ValueError('Solver result or input integrity differs')
        directory = root / 'solver/tasks' / identifier
        for name in ('domain','problem'):
            if digest(directory / (name + '.pddl')) != slot[name + '_sha256']: raise ValueError('Actual solver input changed')
        command = read(directory / 'command.json')
        flags = {'--cd':linux_path(directory),'--alias':'lama-first',
            '--overall-time-limit':str(protocol['budget']['seconds_wall_and_cpu']) + 's',
            '--overall-memory-limit':str(protocol['budget']['memory_mb']) + 'M','--plan-file':'plan.txt'}
        if (any(command.count(key) != 1 or command[command.index(key) + 1] != value for key,value in flags.items())
                or command[-2:] != ['domain.pddl','problem.pddl'] or command.count('timeout') != 1
                or command[command.index('timeout'):command.index('timeout') + 4]
                    != ['timeout','--signal=TERM','--kill-after=5',str(protocol['budget']['seconds_wall_and_cpu'])]):
            raise ValueError('Actual solver command differs from registered model/world or budget')
        plan = directory / 'plan.txt'
        if plan.exists():
            view = output / 'plans' / identifier / 'planning'; view.mkdir(parents=True)
            for name in ('domain.pddl','problem.pddl','plan.txt'):
                shutil.copyfile(directory / name,view / name); plan_pins[str(directory / name)] = digest(directory / name)
            result['fresh_validation'] = validate_artifacts(view)
            if condition == 'native_source':
                result['native_replay'] = {'status':'native_plan','validation':result['fresh_validation']}
            elif condition == REFERENCE:
                result['native_replay'] = {'status':'unverified_reference_action_inverse',
                    'scope':'No native action inverse inferred from a valid reference plan or positional goal export'}
            elif protocol.get('control_auxiliary_sha256') and result['fresh_validation']['status'] == 'VALID':
                if any(len(set(metadata[key][source].values())) != len(metadata[key][source]) for key in ('action_maps','constant_maps')):
                    result['native_replay'] = {'status':'unverified_noninjective_inverse'}
                else:
                    try:
                        result['native_replay'] = native_transport(source,root / 'original_inputs',view.parent,
                            metadata,mapping,output / 'native_replays' / identifier)
                        verdict = result['native_replay'].get('validation',{}).get('status')
                        if verdict and verdict not in ('VALID','INVALID'):
                            result['native_replay']['raw_status'] = result['native_replay']['status']
                            result['native_replay']['status'] = 'unverified_native_validation_' + verdict.lower()
                    except Exception as exc:
                        result['native_replay'] = {'status':'unverified_native_transport','reason':f'{type(exc).__name__}: {exc}'}
        elif row['status'] == 'solved': result['fresh_validation'] = {'status':'MISSING_PLAN'}
        if row['status'] == 'solved' and result['fresh_validation']['status'] != 'VALID':
            failures.append({'id':identifier,'reason':'claimed solved plan did not revalidate'})
        checked.append(result)
    code = snapshot_implementation(output,[Path(__file__),Path('scripts/audit/audit_original_world_pipeline.py'),
        Path('scripts/audit/export_namespace_diagnostic.py'),Path('scripts/experiments/evaluate_namespace_reference.py'),
        Path('scripts/experiments/evaluate_cached_root_worlds.py'),Path('scripts/experiments/run_downward_reference.py'),
        Path('rcnc/domain_building.py'),Path('rcnc/namespace_export.py'),Path('rcnc/pddl.py'),Path('rcnc/validation.py')])
    result = {'status':'verified_fresh_reference_world_comparison' if not failures else 'audited_with_violations',
        'task_count':len(checked),'world_count':protocol['world_count'],'actual_solver_calls':len(actual),
        'parent_admitted':parent_admitted,'construction_failure_count':report['construction_failure_count'],
        'rows':checked,'status_counts':dict(Counter(r['status'] for r in checked)),
        'fresh_validation_counts':dict(Counter(r['fresh_validation']['status'] for r in checked)),
        'native_replay_counts':dict(Counter(r['native_replay']['status'] for r in checked)),
        'audit_failures':failures,'source_plan_artifacts_unchanged':all(digest(Path(n)) == h for n,h in plan_pins.items()),
        'manifest_sha256':digest(root / 'manifest.json'),'report_sha256':digest(root / 'report.json'),
        'implementation_sha256':code,'scope':'Registered explicit worlds,exact control bytes,provided mappings and independent plan validation only;not interface semantic accuracy,causal speedup or general source preservation.'}
    save(output / 'report.json',result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=Path,required=True); parser.add_argument('--output',type=Path,required=True)
    args = parser.parse_args(); result = audit(args.root,args.output)
    print(json.dumps({k:v for k,v in result.items() if k not in ('rows','implementation_sha256')},indent=2))
    raise SystemExit(0 if result['status'] == 'verified_fresh_reference_world_comparison' else 1)

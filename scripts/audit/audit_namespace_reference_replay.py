"""Static native-prefix admission/transport audit; does not repeat simulator truth."""
import argparse
from collections import Counter
import json
from pathlib import Path

from rcnc.action_alpha import structural_parameter_map
from rcnc.domain_building import archived_implementation, digest, require_empty_output, save, snapshot_implementation
from rcnc.namespace_export import fold_symbol_map, inverse_maps, transform
from rcnc.pddl import parse_domain, parse_sexpr, typed_symbols
from scripts.audit.audit_reference_prefix_diagnostic import plan_steps, registry, verify_bindings, inside
from scripts.audit.export_namespace_diagnostic import candidate_path
from scripts.experiments.evaluate_cached_root_worlds import renamed_world


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def audit(root, output):
    root = root.resolve(); require_empty_output(output)
    manifest, report, protocol = [read(root / name) for name in ('manifest.json','report.json','protocol.json')]
    if (report['status'] not in ('complete','complete_registry_with_unrun_prefixes')
            or report['manifest_sha256'] != digest(root / 'manifest.json')
            or digest(root / 'protocol.json') != manifest['protocol_sha256']
            or manifest['budget'] != protocol['budget']
            or any(report.get(key) is not True for key in ('inputs_unchanged','historical_inputs_unchanged','implementation_unchanged'))):
        raise ValueError('Matching terminal registry and execution integrity required')
    if (report.get('model_calls') != 0 or report.get('planner_calls') != 0
            or report.get('goal_evaluation') != 'not_requested_source_prefix_only'):
        raise ValueError('Provided-prefix/no-search evidence boundary changed')
    for name, expected in manifest['input_sha256'].items():
        if digest(candidate_path(root,name)) != expected: raise ValueError('Frozen run-local input changed')
    for name, expected in manifest['implementation_sha256'].items():
        if digest(archived_implementation(root,name)) != expected: raise ValueError('Archived implementation changed')
    historical_root = Path(protocol['historical_root'])
    for name, expected in protocol['historical_input_sha256'].items():
        if digest(candidate_path(historical_root,name)) != expected: raise ValueError('Pinned original evidence changed')
    for local, original in (('native_prefix_audit.json',Path(protocol['native_prefix_audit'])),
            ('source_task_bundle_manifest.json',Path(protocol['source_task_bundle']) / 'manifest.json'),
            ('native_solver_run_manifest.json',Path(protocol['native_solver_run']) / 'manifest.json'),
            ('native_solver_report.json',Path(protocol['native_solver_run']) / 'report.json')):
        if digest(root / local) != digest(original): raise ValueError('Copied historical receipt differs')
    slots, rows = registry(manifest,report,protocol)
    native_rows = read(root / 'native_prefix_audit.json')['rows']
    original_tasks = read(root / 'source_task_bundle_manifest.json')['tasks']
    native = {r['id']:r for r in native_rows}
    tasks = {r['id']:r for r in original_tasks}
    if (len(native_rows) != protocol['task_count'] or len(original_tasks) != protocol['task_count']
            or set(tasks) != set(slots) or set(native) != set(slots)):
        raise ValueError('Historical slot population differs')
    if list(rows) != list(slots) or list(slots) != list(tasks): raise ValueError('Frozen prefix order changed')
    available = sum(r['status'] == 'PASS' for r in native.values())
    if {'audited_prefixes':available,'no_audited_prefix':len(tasks)-available} != protocol['source_trace_availability']:
        raise ValueError('Historical availability denominator differs')
    admitted = manifest['parent_admitted']
    if report['parent_admitted'] != admitted or report['construction_failure_count'] != (0 if admitted else 1):
        raise ValueError('Shared construction failure changed')
    allowed, worlds, object_maps, predicate_maps, source_models = {}, {}, {}, {}, {}
    if admitted:
        parent_manifest, parent_report = read(root / 'parent_manifest.json'), read(root / 'parent_report.json')
        validation = read(root / 'raw_validation.json')
        if (parent_manifest['status'] != 'complete' or parent_report['status'] != 'complete'
                or parent_report['validation'] != validation or validation.get('valid') is not True):
            raise ValueError('Prefix run promoted an uncompleted parent')
        namespace, reverse = read(root / 'namespace_maps.json'), read(root / 'inverse_namespace_maps.json')
        if inverse_maps(namespace) != reverse: raise ValueError('Namespace inverse differs')
        names = {key:fold_symbol_map(value) for key,value in namespace.items()}
        raw_target = parse_domain(root / 'raw_meta_domain.pddl')
        raw_ast = parse_sexpr((root / 'raw_meta_domain.pddl').read_text(encoding='utf-8'))
        target_ast = parse_sexpr((root / 'target/domain.pddl').read_text(encoding='utf-8'))
        if transform(target_ast,reverse) != raw_ast or transform(raw_ast,namespace) != target_ast:
            raise ValueError('Actual planning model is not the reversible fixed root')
        for name, expected in validation['namespace_export']['output_sha256'].items():
            path = root / 'target' / name if name.endswith('.pddl') else root / name
            if digest(path) != expected: raise ValueError('Actual reference export hash differs')
        metadata = read(root / 'raw_meta_domain.json')
        if set(metadata['sources']) != set(protocol['sources']): raise ValueError('Root source population differs')
        inventory = read(root / 'action_mapping_inventory.json')['rows']
        recorded = {(r['source'],r['source_action'].lower()):r for r in inventory}
        if len(recorded) != len(inventory) or len(recorded) != len(tasks):
            raise ValueError('Complete unique source-action mapping inventory required')
        for source in protocol['sources']:
            original = parse_domain(root / 'source_inputs' / (source + '_domainfile.pddl'))
            source_models[source] = original
            original_world = parse_sexpr((root / 'source_inputs' / (source + '_problemfile.pddl')).read_text(encoding='utf-8'))
            predicates, constants = metadata['predicate_maps'][source], metadata['constant_maps'][source]
            adapted_world = parse_sexpr((root / 'target/problems' / (source + '_problemfile.pddl')).read_text(encoding='utf-8'))
            world_ok = (set(predicates) == set(original.predicates) and set(constants) == set(original.constants)
                and not (set(constants.values()) - set(raw_target.constants))
                and all(mapped in raw_target.predicates and original.predicates[p].arity == raw_target.predicates[mapped].arity
                        for p,mapped in predicates.items())
                and transform(adapted_world,reverse,problem=True)
                    == renamed_world(original_world,raw_target.name,predicates,constants))
            worlds[source] = world_ok
            constant_names = fold_symbol_map(constants)
            object_names = set(original.constants)
            for part in original_world[1:]:
                if part[0] == ':objects': object_names.update(typed_symbols(part[1:]))
            object_maps[source] = {obj.lower():names['objects'][constant_names.get(obj.lower(),obj.lower())] for obj in object_names}
            predicate_maps[source] = {old.lower():names['predicates'][new.lower()] for old,new in predicates.items()}
            allowed[source] = {}
            for name, action in original.actions.items():
                entry = recorded[(source,name.lower())]
                mapped = metadata['action_maps'][source].get(name)
                if entry.get('mapped_action') != mapped and entry['status'] != 'unverified_mapping_context':
                    raise ValueError('Action inventory target differs from fixed metadata')
                positions, basis = None, None
                if mapped in raw_target.actions:
                    def signature(expr):
                        return [(n.lower(),t.lower()) for n,t in typed_symbols(expr[expr.index(':parameters') + 1]).items()]
                    left, right = signature(action), signature(raw_target.actions[mapped])
                    if left == right:
                        positions, basis = list(range(len(left))), 'unchanged_ordered_signature_only'
                    else:
                        structural = structural_parameter_map(action,raw_target.actions[mapped],predicates,constants,
                            max_arity=protocol['budget']['max_mapping_arity'],max_permutations=protocol['budget']['max_mapping_permutations'])
                        basis = structural['status']
                        if basis == 'unique_structural_map': positions = structural['source_to_target_positions']
                    if entry['status'] != basis: raise ValueError('Action mapping admission differs from full signatures')
                elif entry['status'] != 'missing_mapping_or_target':
                    raise ValueError('Missing target action was promoted')
                if positions is not None:
                    if entry.get('source_to_target_positions') != positions: raise ValueError('Action bijection changed')
                    allowed[source][name.lower()] = {'target':names['actions'][mapped.lower()], 'positions':positions, 'basis':basis}
    ready = calls = truth = mismatches = steps = arguments = 0
    checked, unresolved, unverified_outputs = [], [], []
    for identifier, slot in slots.items():
        row, task, history = rows[identifier], tasks[identifier], native[identifier]
        if any(row.get(key) != value for key,value in slot.items()): raise ValueError('Result prefix identity differs from frozen slot')
        if (slot['source'] != task['source'] or slot['target_action'] != task['target_action']
                or slot['original_solver_status'] != history['solver_status']
                or slot['original_prefix_audit_status'] != history['status']):
            raise ValueError('Source prefix identity changed')
        source = slot['source']; original_steps = []
        if not admitted: expected = 'not_run_shared_parent_build_failure'
        elif history['status'] != 'PASS': expected = 'no_audited_source_prefix'
        elif not worlds[source]: expected = 'unsupported_world_projection'
        else:
            original_path = Path(protocol['native_solver_run']) / 'tasks' / identifier / 'plan.txt'
            original_steps = plan_steps(original_path)
            missing = sorted({step[0] for step in original_steps if step[0] not in allowed[source]})
            expected = 'unverified_parameter_transport' if missing else 'ready'
            if missing and slot.get('unmapped_actions') != missing: raise ValueError('Missing action maps changed')
        if slot['admission_status'] == 'unverified_source_prefix_preparation':
            if not admitted or history['status'] != 'PASS' or not worlds[source]:
                raise ValueError('Preparation error cannot replace an unadmitted native prefix')
            unresolved.append(identifier)
            expected = 'unverified_source_prefix_preparation'
        if slot['admission_status'] != expected: raise ValueError('Prefix admission differs from original evidence')
        if expected != 'ready':
            if row['status'] != expected: raise ValueError('Unadmitted prefix was promoted')
            checked.append({'id':identifier,'status':row['status']}); continue
        ready += 1
        case = candidate_path(root,'cases/' + identifier)
        job_path = candidate_path(root,slot['job']); job = read(job_path)
        if job_path != case / 'job.json' or Path(job['output']).resolve() != case / 'replay':
            raise ValueError('Child prefix path differs from its frozen slot')
        expected_paths = {'source_domain':root / 'source_inputs' / (source + '_domainfile.pddl'),
            'source_problem':root / 'source_inputs' / (source + '_problemfile.pddl'),
            'source_plan':case / 'source.plan', 'target_domain':root / 'target/domain.pddl',
            'target_problem':root / 'target/problems' / (source + '_problemfile.pddl')}
        for key in ('source_domain','source_problem','source_plan','target_domain','target_problem'):
            inside(root,Path(job[key]))
            if Path(job[key]).resolve() != expected_paths[key]:
                raise ValueError('Child replaced the fixed world/model or provided prefix')
            if digest(Path(job[key])) != job['input_sha256'][job[key]]: raise ValueError('Child prefix input drift')
        if Path(job['source_plan']).read_bytes() != original_path.read_bytes(): raise ValueError('Provided source prefix changed')
        expected_actions = {step[0]:allowed[source][step[0]] for step in original_steps}
        if (job['actions'] != expected_actions or job['objects'] != object_maps[source] or job['predicates'] != predicate_maps[source]
                or job.get('applicability_policy') != 'public_is_applicable' or job['max_atoms'] != protocol['budget']['max_source_atoms']):
            raise ValueError('Child total mapping or comparison policy differs')
        if row['status'] not in ('not_run_due_goal_budget','not_run_diagnostic_deadline'):
            calls += 1
        child_path, mapped_path = case / 'replay/report.json', case / 'replay/mapped.plan'
        if row['status'] in ('not_run_due_goal_budget','not_run_diagnostic_deadline') and (case / 'replay').exists():
            raise ValueError('Unrun prefix has child artifacts')
        if child_path.exists() and row.get('worker_exit_code') == 0:
            child = read(child_path)
            if any(row.get(k) != v for k,v in child.items()) or child.get('inputs_unchanged') is not True:
                raise ValueError('Child report aggregation differs')
            if child.get('goal_evaluation') != 'not_requested_source_prefix_only' or child.get('applicability_policy') != 'public_is_applicable':
                raise ValueError('Prefix/goal/policy boundary changed')
            if child['status'] == 'PASS' and not all(child.get(k) is True for k in ('complete','prefix_replay_complete','truth_projection_complete')):
                raise ValueError('Incomplete projection or prefix was promoted to PASS')
            if child.get('truth_projection_complete') is False and (child.get('truth_comparisons',0) or child.get('states_compared',0)):
                raise ValueError('Incomplete atom subset was counted as truth evidence')
            if child['status'] == 'FAIL' and child.get('failure_kind') == 'applicability_divergence' and (
                    child.get('source_applicable') is not True or child.get('target_applicable') is not False):
                raise ValueError('Applicability counterexample lacks a valid source step')
            truth += child.get('truth_comparisons',0); mismatches += child.get('mismatch_count',0)
        elif row['status'] not in ('not_run_due_goal_budget','not_run_diagnostic_deadline','diagnostic_time_limit','worker_error'):
            raise ValueError('Missing child report without a retained unverified/resource outcome')
        counts = {'steps':0,'arguments':0}
        mapped_checked = False
        if mapped_path.exists():
            try:
                counts = verify_bindings(original_steps,plan_steps(mapped_path),job['actions'],job['objects'])
                for source_step in original_steps:
                    original = source_models[source]
                    schema = next(action for name,action in original.actions.items() if name.lower() == source_step[0])
                    if len(source_step) - 1 != len(typed_symbols(schema[schema.index(':parameters') + 1])):
                        raise ValueError('Source prefix truncated formal arguments')
                mapped_checked = True
            except Exception as exc:
                if row['status'] in ('PASS','FAIL'): raise
                counts = {'steps':0,'arguments':0}
                unverified_outputs.append({'id':identifier,'reason':f'{type(exc).__name__}: {exc}'})
            steps += counts['steps']; arguments += counts['arguments']
        elif row['status'] in ('PASS','FAIL'):
            raise ValueError('Verified prefix lacks its complete mapped plan')
        checked.append({'id':identifier,'status':row['status'],'mapped_prefix_checked':mapped_checked,**counts})
    if (ready != manifest['ready_prefixes'] or calls != report['actual_replay_processes']
            or report['ready_prefixes'] != ready or report['execution_complete'] != (calls == ready)
            or truth != report['truth_comparisons'] or mismatches != report['mismatch_count']):
        raise ValueError('Replay process or truth denominator differs')
    output.mkdir(parents=True,exist_ok=True)
    code = snapshot_implementation(output,[Path(__file__),Path('scripts/audit/audit_reference_prefix_diagnostic.py'),
        Path('scripts/audit/export_namespace_diagnostic.py'),Path('scripts/experiments/evaluate_cached_root_worlds.py'),
        Path('rcnc/action_alpha.py'),Path('rcnc/domain_building.py'),Path('rcnc/pddl.py'),Path('rcnc/namespace_export.py')])
    result = {'status':'verified_fresh_reference_prefix_registry' if not unresolved else 'audited_with_unresolved_admission',
        'task_count':len(checked),'ready_prefixes':ready,'actual_replay_processes':calls,
        'parent_admitted':admitted,'construction_failure_count':report['construction_failure_count'],
        'execution_complete':report['execution_complete'],'mapped_prefix_steps':steps,'full_actual_parameters':arguments,
        'truth_comparisons_reconciled':truth,'mismatches_reconciled':mismatches,
        'status_counts':dict(Counter(r['status'] for r in checked)),'rows':checked,'unresolved_admission':unresolved,
        'unverified_mapped_outputs':unverified_outputs,
        'manifest_sha256':digest(root / 'manifest.json'),'report_sha256':digest(root / 'report.json'),
        'implementation_sha256':code,'model_calls':0,'planner_calls':0,
        'scope':'Static admission,full-argument transport,source provenance and counters only. Does not independently repeat simulator truth,original goals or semantic labels.'}
    save(output / 'report.json',result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=Path,required=True); parser.add_argument('--output',type=Path,required=True)
    args = parser.parse_args(); result = audit(args.root,args.output)
    print(json.dumps({k:v for k,v in result.items() if k not in ('rows','implementation_sha256')},indent=2))
    raise SystemExit(0 if result['status'] == 'verified_fresh_reference_prefix_registry' else 1)

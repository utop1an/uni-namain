"""Reconcile a frozen provided-prefix registry without replaying or searching.

This audits admission, complete argument transport, child-report aggregation and
artifact hashes. It does not independently reproduce simulator truth values.
"""
import argparse
from collections import Counter
import json
from pathlib import Path

from rcnc.action_alpha import bind_full_arguments
from rcnc.domain_building import (archived_implementation, digest,
    require_empty_output, save, snapshot_implementation)
from rcnc.namespace_export import fold_symbol_map
from rcnc.pddl import parse_sexpr, strip_comments


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def plan_steps(path):
    values = parse_sexpr('(' + strip_comments(path.read_text(encoding='utf-8')) + ')')
    if any(not isinstance(step, list) or not step or any(not isinstance(x, str) for x in step)
           for step in values):
        raise ValueError('Flat complete action invocations required')
    return [[token.lower() for token in step] for step in values]


def verify_bindings(source, mapped, actions, objects):
    """Check ordered total bijections, including unused actual arguments."""
    if len(source) != len(mapped):
        raise ValueError('Plan length changed')
    objects = fold_symbol_map(objects)
    arguments = 0
    for left, right in zip(source, mapped):
        binding = actions[left[0]]
        expected = bind_full_arguments([objects[a] for a in left[1:]],
            binding['positions'], len(right) - 1)
        if [binding['target'].lower(), *expected] != right:
            raise ValueError('Complete mapped invocation differs')
        arguments += len(expected)
    return {'steps': len(source), 'arguments': arguments}


def registry(manifest, report, protocol):
    count = protocol['task_count']
    slots = manifest['slots']; rows = report['rows']
    if (len(slots) != count or len(rows) != count
        or len({r['id'] for r in slots}) != count
        or len({r['id'] for r in rows}) != count
        or {r['id'] for r in slots} != {r['id'] for r in rows}):
        raise ValueError('Complete unique registered denominator required')
    if dict(Counter(r['status'] for r in rows)) != report['status_counts']:
        raise ValueError('Status count mismatch')
    if report['task_count'] != count or manifest['task_count'] != count:
        raise ValueError('Task denominator mismatch')
    return {r['id']: r for r in slots}, {r['id']: r for r in rows}


def inside(parent, path):
    path = path.resolve()
    if not path.is_relative_to(parent.resolve()):
        raise ValueError('Child artifact escapes frozen run')
    return path


def audit(parent, output):
    require_empty_output(output)
    root = Path.cwd().resolve(); parent = parent.resolve()
    manifest, report, protocol = (read(parent/name) for name in ('manifest.json','report.json','protocol.json'))
    if report['status'] != 'complete' or digest(parent/'manifest.json') != report['manifest_sha256']:
        raise ValueError('Complete pinned parent required')
    if any(report.get(k) is not True for k in ('inputs_unchanged','original_inputs_unchanged','implementation_unchanged')):
        raise ValueError('Parent integrity failure')
    slots, results = registry(manifest, report, protocol)
    for name, expected in manifest['input_sha256'].items():
        if digest(inside(parent, parent/name)) != expected:
            raise ValueError('Staged input drift')
    for name, expected in manifest['original_input_sha256'].items():
        if digest(root/name) != expected:
            raise ValueError('Original input drift')
    for name, expected in manifest['implementation_sha256'].items():
        if digest(archived_implementation(parent, name)) != expected:
            raise ValueError('Archived implementation drift')
    original = read(root/'data/validation/action_reachability_audit_2026_10_15_v1/report.json')
    native = {r['id']: r for r in original['rows']}
    if len(native) != protocol['task_count'] or set(native) != set(slots):
        raise ValueError('Original source availability registry differs')
    # These reports are pinned by the actual protocol, never merely current defaults.
    for name in ('data/validation/action_reachability_audit_2026_10_15_v1/report.json',
                 'data/validation/fusion_failed_root_mapping_2026_10_23_v2/report.json',
                 'data/validation/action_alpha_diagnostic_2026_10_23_v1/report.json'):
        pins = {Path(p).as_posix(): h for p,h in protocol['input_sha256'].items()}
        if pins.get(Path(name).as_posix()) != digest(root/name):
            raise ValueError('Admission evidence missing protocol pin')
    mapping = read(root/'data/validation/fusion_failed_root_mapping_2026_10_23_v2/report.json')
    alpha = read(root/'data/validation/action_alpha_diagnostic_2026_10_23_v1/report.json')
    names = read(root/protocol['target']/'namespace_maps.json')
    action_names = fold_symbol_map(names['actions'])
    unique = {r['id']: r['source_to_target_positions'] for r in alpha['rows'] if r['status']=='unique_structural_map'}
    allowed = {}
    for source in mapping['sources']:
        allowed[source['source']] = {}
        for item in source['actions']:
            positions = (list(range(item['source_parameter_count']))
                if item['parameter_transport_status']=='unchanged_ordered_signature_only'
                else unique.get(source['source']+':'+item['source_action']))
            if positions is not None:
                allowed[source['source']][item['source_action'].lower()] = {
                    'target': action_names[item['mapped_action'].lower()], 'positions': positions}
    output.mkdir(parents=True)
    implementation = snapshot_implementation(output, [Path(__file__),Path('rcnc/action_alpha.py'),
        Path('rcnc/pddl.py'),Path('rcnc/namespace_export.py'),Path('rcnc/domain_building.py')])
    pins = {str(p): digest(p) for p in parent.rglob('*') if p.is_file()}
    save(output/'manifest.json', {'status':'frozen_before_static_audit','input_sha256':pins,
        'implementation_sha256':implementation})
    checked=[];steps=arguments=truth=mismatches=available=admitted=mapped_count=0
    historical = root/'data/validation/downward_action_reachability_2026_10_15_v1/tasks'
    for key, slot in slots.items():
        row = results[key]; source=slot['source']
        if slot['original_solver_status'] != native[key]['solver_status']:
            raise ValueError('Original solver status changed')
        if native[key]['status'] != 'PASS':
            expected='no_audited_source_prefix'
        else:
            available+=1
            original_plan=historical/key/'plan.txt'; source_steps=plan_steps(original_plan)
            missing=sorted({s[0] for s in source_steps if s[0] not in allowed[source]})
            expected='unverified_parameter_transport' if missing else 'ready'
            if missing and slot.get('unmapped_actions') != missing:
                raise ValueError('Missing-map reasons changed')
        if slot['admission_status'] != expected:
            raise ValueError('Frozen admission differs from supplied source evidence')
        if expected != 'ready':
            if row['status'] != expected:
                raise ValueError('Unadmitted slot changed or promoted')
            checked.append({'id':key,'status':expected});continue
        admitted+=1
        job_path=inside(parent,Path(slot['job']));job=read(job_path);case=job_path.parent
        if any(digest(Path(p))!=h for p,h in job['input_sha256'].items()):
            raise ValueError('Child input drift')
        if Path(job['source_plan']).read_bytes()!=original_plan.read_bytes():
            raise ValueError('Provided native prefix changed')
        wanted={s[0]:allowed[source][s[0]] for s in source_steps}
        actual={a:{k:b[k] for k in ('target','positions')} for a,b in job['actions'].items()}
        if actual!=wanted:
            raise ValueError('Child action binding differs from frozen admission')
        child_path=case/'replay/report.json';mapped_path=case/'replay/mapped.plan'
        if child_path.exists():
            child=read(child_path)
            if any(row.get(k)!=v for k,v in child.items()) or child.get('inputs_unchanged') is not True:
                raise ValueError('Child report aggregation differs')
            if child.get('goal_evaluation')!='not_requested_source_prefix_only':
                raise ValueError('Prefix/goal evidence boundary changed')
            truth+=child.get('truth_comparisons',0);mismatches+=child.get('mismatch_count',0)
        elif row['status'] not in ('diagnostic_time_limit','not_run_diagnostic_deadline','worker_error','error'):
            raise ValueError('Missing child report without retained resource/error outcome')
        if mapped_path.exists():
            counts=verify_bindings(source_steps,plan_steps(mapped_path),actual,job['objects'])
            mapped_count+=1;steps+=counts['steps'];arguments+=counts['arguments']
        elif row['status'] in ('PASS','FAIL'):
            raise ValueError('Verified replay lacks mapped prefix')
        checked.append({'id':key,'status':row['status'],'full_mapped_prefix_checked':mapped_path.exists()})
    if (available!=protocol['source_trace_availability']['audited_prefixes']
        or admitted!=report['ready_prefixes'] or truth!=report['truth_comparisons']
        or mismatches!=report['mismatch_count']):
        raise ValueError('Source availability or aggregate comparison denominator changed')
    result={'status':'verified_static_prefix_audit','task_count':len(checked),'rows':checked,
        'status_counts':dict(Counter(r['status'] for r in checked)), 'available_source_prefixes':available,
        'admitted_prefixes':admitted,'mapped_prefixes_checked':mapped_count,'full_mapped_steps':steps,
        'full_mapped_arguments':arguments,'truth_comparisons_reconciled':truth,'truth_mismatches_reconciled':mismatches,
        'inputs_unchanged':all(digest(Path(p))==h for p,h in pins.items()),
        'implementation_unchanged':all(digest(root/p)==h for p,h in implementation.items()),
        'model_calls':0,'planner_calls':0,'replay_calls':0,
        'scope':'Static frozen-admission, full-argument and child-aggregation audit of the same correlated prefixes. Simulator truth values are reconciled, not independently reproduced; no goal-success or semantic labels.'}
    save(output/'report.json',result)
    return result


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();result=audit(args.root,args.output)
    print(json.dumps({k:v for k,v in result.items() if k!='rows'},indent=2))

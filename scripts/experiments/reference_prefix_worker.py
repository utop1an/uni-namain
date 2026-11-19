"""Bounded provided-prefix replay, without checking original-goal attainment."""
import argparse
import json
from pathlib import Path

from unified_planning.io import PDDLReader, PDDLWriter
from unified_planning.plans import ActionInstance, SequentialPlan
from rcnc.action_alpha import bind_full_arguments
from rcnc.domain_building import digest, save
from rcnc.trace_audit import compare_states
from rcnc.namespace_export import fold_symbol_map


def run(job_path):
    job=json.loads(job_path.read_text(encoding='utf-8'))
    policy=job.get('applicability_policy','legacy_apply')
    if policy not in ('legacy_apply','public_is_applicable'):
        raise ValueError('Unknown prefix applicability policy')
    output=Path(job['output'])
    if output.exists():raise ValueError('Fresh prefix output required')
    if any(digest(Path(p))!=h for p,h in job['input_sha256'].items()):raise ValueError('Frozen prefix input changed')
    output.mkdir(parents=True)
    save(output/'progress.json',{'stage':'parsing_source_and_target'})
    result={'status':'starting','goal_evaluation':'not_requested_source_prefix_only'}
    try:
        objects_map=fold_symbol_map(job['objects']);predicates_map=fold_symbol_map(job['predicates'])
        actions={}
        for key,binding in job['actions'].items():
            name=key.lower();value={'target':binding['target'].lower(),'positions':binding['positions']}
            if name in actions and actions[name]!=value:raise ValueError('Conflicting case-insensitive action bindings')
            actions[name]=value
        reader=PDDLReader()
        source=reader.parse_problem(job['source_domain'],job['source_problem'])
        target=reader.parse_problem(job['target_domain'],job['target_problem'])
        plan=reader.parse_plan(source,job['source_plan'])
        if set(objects_map)!={o.name.lower() for o in source.all_objects} or len(set(objects_map.values()))!=len(objects_map):
            raise ValueError('Complete injective source-object map required')
        mapped=[]
        save(output/'progress.json',{'stage':'checking_complete_argument_bindings','source_steps':len(plan.actions)})
        for step in plan.actions:
            binding=actions[step.action.name.lower()]
            action=target.action(binding['target'])
            source_args=[objects_map[p.object().name.lower()] for p in step.actual_parameters]
            names=bind_full_arguments(source_args,binding['positions'],len(action.parameters))
            objects=[target.object(name) for name in names]
            if any(obj not in list(target.objects(parameter.type)) for parameter,obj in zip(action.parameters,objects)):
                result={'status':'unverified_target_type_embedding','action':step.action.name}
                break
            mapped.append(ActionInstance(action,tuple(objects)))
        else:
            target_plan=SequentialPlan(mapped)
            PDDLWriter(target).write_plan(target_plan,str(output/'mapped.plan'))
            save(output/'progress.json',{'stage':'comparing_source_atom_projection','source_steps':len(plan.actions)})
            if policy=='public_is_applicable':
                from scripts.experiments.reference_prefix_compare import compare_states_public
                result=compare_states_public(source,target,plan,target_plan,predicates_map,objects_map,
                    max_atoms=job['max_atoms'])
            else:
                result=compare_states(source,target,plan,target_plan,predicates_map,objects_map,
                    max_atoms=job['max_atoms'])
            result['prefix_length']=len(plan.actions)
    except Exception as exc:
        result={'status':'replay_error','reason':f'{type(exc).__name__}: {exc}'}
    result.update(inputs_unchanged=all(digest(Path(p))==h for p,h in job['input_sha256'].items()),
        applicability_policy=policy,
        goal_evaluation='not_requested_source_prefix_only',
        scope='Provided source action-invocation prefix under frozen total argument maps and reference positional predicate export. No search, original-goal success, interface semantic label or source-universe theorem.')
    save(output/'report.json',result)
    return result


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--job',type=Path,required=True)
    print(run(parser.parse_args().job))

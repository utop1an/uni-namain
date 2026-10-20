"""Conditional source-trace transport through the reference adapter's own mappings."""
import argparse
from collections import Counter
import json
from pathlib import Path

from unified_planning.io import PDDLReader, PDDLWriter
from unified_planning.plans import ActionInstance, SequentialPlan
from merge_domains import parse_domain, rewrite_problem, typed_symbols
from replay_source_probes import read, sha
from rcnc.validation import validate_artifacts


def signature(action):
    i=action.index(':parameters')
    return [(name.lower(),typ.lower()) for name,typ in typed_symbols(action[i+1]).items()]


def transport(source, original, snapshot, output):
    meta=read(snapshot/'meta_domain.json')
    source_model=parse_domain(snapshot/'inputs'/(source+'_domainfile.pddl'),apply_reviewed_semantics=False)
    target_model=parse_domain(snapshot/'meta_domain.pddl',apply_reviewed_semantics=False)
    for key in ('predicate_maps','constant_maps','action_maps'):
        setattr(target_model,key,meta[key])
    result={'source':source,'original_validation':validate_artifacts(original)}
    if result['original_validation']['status']!='VALID':
        return {**result,'status':'source_plan_not_valid'}
    reader=PDDLReader()
    src=reader.parse_problem(str(original/'domain.pddl'),str(original/'problem.pddl'))
    plan=reader.parse_plan(src,str(original/'plan.txt'))
    missing=[]
    for step in plan.actions:
        name=step.action.name
        mapped=meta['action_maps'][source].get(name)
        if mapped not in target_model.actions:
            missing.append({'action':name,'reason':'missing_mapped_action'})
        elif signature(source_model.actions[name])!=signature(target_model.actions[mapped]):
            missing.append({'action':name,'mapped_action':mapped,'reason':'changed_ordered_formal_parameters'})
    if missing:
        return {**result,'status':'unverified_parameter_transport','unmapped_steps':missing}
    output.mkdir(parents=True)
    (output/'domain.pddl').write_bytes((snapshot/'meta_domain.pddl').read_bytes())
    # Use the same positional predicate/constant rewrite as the reference
    # exporter; do not infer a different role order to make a trace succeed.
    source_problem=output/(source+'_problemfile.pddl')
    source_problem.write_bytes((original/'problem.pddl').read_bytes())
    rewrite_problem(source_problem,target_model,output/'problem.pddl')
    dst=reader.parse_problem(str(output/'domain.pddl'),str(output/'problem.pddl'))
    terms=meta['constant_maps'][source]
    instances=[]
    for step in plan.actions:
        action=dst.action(meta['action_maps'][source][step.action.name])
        args=[dst.object(terms.get(p.object().name,p.object().name)) for p in step.actual_parameters]
        instances.append(ActionInstance(action,tuple(dst.environment.expression_manager.ObjectExp(o) for o in args)))
    PDDLWriter(dst).write_plan(SequentialPlan(instances),str(output/'plan.txt'))
    result.update(status='transport_validated',transported_length=len(instances),
        mapped_validation=validate_artifacts(output),
        argument_policy='Require unchanged ordered formal names and types; preserve actual argument positions',
        predicate_policy='Reference exporter positional renaming, not verified semantic role equivalence')
    return result


def run(audit,source_run,output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    inspected=read(audit/'report.json')
    snapshot=audit/'snapshot'
    meta=read(snapshot/'meta_domain.json')
    old=read(source_run/'report.json')
    if old['status']!='complete' or sha(source_run/'manifest.json')!=old['manifest_sha256']:
        raise ValueError('Requires completed unchanged source-planning run')
    model_hash=inspected['input_sha256'][str(Path(inspected['node'])/'meta_domain.pddl')]
    if sha(snapshot/'meta_domain.pddl')!=model_hash:
        raise ValueError('Audited snapshot changed')
    rows={r['id']:r for r in old['rows']}
    output.mkdir(parents=True)
    result={'status':'running','scope':inspected['scope'],'node_sources':len(meta['sources']),
        'original_source_pool':old['task_count'],'rows':[],
        'transport_contract':'Diagnostic of native adapter positional export, not an inferred semantic/permutation map',
        'audit_report_sha256':sha(audit/'report.json'),'source_report_sha256':sha(source_run/'report.json'),
        'compiled_domain_sha256':model_hash}
    for source in meta['sources']:
        row={'source':source,'source_solver_status':rows[source]['status']}
        if rows[source]['status']!='solved':
            row['status']='no_original_plan_evidence'
        else:
            original=source_run/'tasks'/source
            try:
                if sha(original/'domain.pddl')!=sha(snapshot/'inputs'/(source+'_domainfile.pddl')):
                    raise ValueError('Source model differs from fusion input')
                row['source_artifact_sha256']={name:sha(original/name) for name in ('domain.pddl','problem.pddl','plan.txt')}
                row.update(transport(source,original,snapshot,output/'sources'/source))
            except Exception as exc:
                row.update(status='ERROR',reason=f'{type(exc).__name__}: {exc}')
        result['rows'].append(row)
        (output/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    result.update(status='complete',counts=dict(Counter(r['status'] for r in result['rows'])),
        transported_validation_counts=dict(Counter(r['mapped_validation']['status'] for r in result['rows'] if 'mapped_validation' in r)),
        model_unchanged=sha(snapshot/'meta_domain.pddl')==model_hash,
        limit='Missing parameter maps are not failed plans; invalid transported traces are not proof that no alternative plan exists')
    implementation=output/'implementation';implementation.mkdir()
    result['implementation_sha256']={}
    for name in ('probe_fusion_source_plans.py','merge_domains.py','rcnc/validation.py'):
        path=Path(name);(implementation/path.name).write_bytes(path.read_bytes())
        result['implementation_sha256'][name]=sha(path)
    (output/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    return result


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--audit',type=Path,required=True)
    p.add_argument('--source-run',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args()
    r=run(a.audit,a.source_run,a.output)
    print(json.dumps({k:v for k,v in r.items() if k!='rows'},indent=2))

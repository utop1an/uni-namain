"""Inspect reference mapping coverage and literal rewrites without assuming permutations."""
import argparse
from collections import Counter
import copy
import json
from pathlib import Path

from unified_planning.io import PDDLReader
from scripts.audit.audit_union_preservation import normalized
from rcnc.pddl import parse_domain, typed_symbols
from scripts.experiments.replay_source_probes import read, sha


def inspect(inputs, domain_path, meta):
    merged=parse_domain(domain_path)
    result={'status':'audited','sources':[],'parameter_mapping_policy':'No inferred action-parameter permutation',
        'limit':'Literal rename-only equality is conservative syntactic evidence, not source-universe preservation, semantic equivalence or trace validity'}
    for source in meta['sources']:
        original=parse_domain(inputs/(source+'_domainfile.pddl'))
        row={'source':source,'mapping_categories':{},'actions':[],'predicates':[]}
        for kind,key in (('actions','action_maps'),('predicates','predicate_maps'),('constants','constant_maps')):
            mapping=meta.get(key,{}).get(source,{})
            original_names=set(getattr(original,kind))
            targets=set(getattr(merged,kind))
            row['mapping_categories'][kind]={
                'missing_source_keys':sorted(original_names-set(mapping)),
                'extra_source_keys':sorted(set(mapping)-original_names),
                'missing_targets':sorted({v for v in mapping.values() if v not in targets}),
                'within_source_collisions':{v:sorted(k for k,t in mapping.items() if t==v)
                    for v,n in Counter(mapping.values()).items() if n>1}}
        predicates=meta.get('predicate_maps',{}).get(source,{})
        constants=meta.get('constant_maps',{}).get(source,{})
        actions=meta.get('action_maps',{}).get(source,{})
        def formula(expr):
            if not isinstance(expr,list):
                return constants.get(expr,expr)
            if not expr:
                return []
            if expr[0] in ('forall','exists'):
                return [expr[0],copy.deepcopy(expr[1]),formula(expr[2])]
            return [predicates.get(expr[0],expr[0]),*[formula(x) for x in expr[1:]]]
        for name, action in original.actions.items():
            target=actions.get(name)
            entry={'source_action':name,'mapped_action':target}
            if target not in merged.actions:
                entry['status']='missing_mapping_or_target'
            else:
                rewritten=copy.deepcopy(action)
                rewritten[1]=target
                for i in range(2,len(rewritten),2):
                    if rewritten[i] in (':precondition',':effect'):
                        rewritten[i+1]=formula(rewritten[i+1])
                entry['status']=('rename_only_ast_equal' if normalized(rewritten)==normalized(merged.actions[target])
                                 else 'rewritten_ast_no_verified_parameter_map')
                def signature(value):
                    index=value.index(':parameters')
                    return list(typed_symbols(value[index+1]).items())
                entry['ordered_signature_equal']=signature(action)==signature(merged.actions[target])
            row['actions'].append(entry)
        for name,predicate in original.predicates.items():
            target=predicates.get(name)
            entry={'source_predicate':name,'mapped_predicate':target,'argument_order_trace':'not_recorded'}
            if target in merged.predicates:
                new=merged.predicates[target]
                entry.update(source_arity=predicate.arity,target_arity=new.arity,
                    ordered_signature_equal=predicate.parameters==new.parameters)
            else:
                entry['status']='missing_mapping_or_target'
            row['predicates'].append(entry)
        result['sources'].append(row)
    result['action_counts']=dict(Counter(a['status'] for r in result['sources'] for a in r['actions']))
    result['source_action_total']=sum(len(r['actions']) for r in result['sources'])
    result['mapped_action_total']=len(merged.actions)
    try:
        PDDLReader().parse_problem(str(domain_path))
        result['independent_domain_parse']='VALID'
    except Exception as exc:
        result['independent_domain_parse']='ERROR'
        result['parse_error']=f'{type(exc).__name__}: {exc}'
    return result


def run(reference,node,output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    manifest=read(reference/'manifest.json')
    is_root=node.resolve()==(reference/'fusion').resolve()
    if is_root and read(reference/'report.json')['status']!='complete':
        raise ValueError('Final-root audit requires a completed reference run')
    meta=read(node/'meta_domain.json')
    snapshot=output/'snapshot'
    (snapshot/'inputs').mkdir(parents=True)
    hashes={}
    for filename in ('meta_domain.json','meta_domain.pddl'):
        path=node/filename
        hashes[str(path)]=sha(path)
        (snapshot/filename).write_bytes(path.read_bytes())
    for source in meta['sources']:
        name=source+'_domainfile.pddl'
        path=reference/'inputs'/name
        if sha(path)!=manifest['source_sha256'][name]:
            raise ValueError('Reference source changed')
        (snapshot/'inputs'/name).write_bytes(path.read_bytes())
        hashes[str(path)]=sha(path)
    result=inspect(snapshot/'inputs',snapshot/'meta_domain.pddl',meta)
    result.update(scope='completed_final_root' if is_root else 'intermediate_node_not_final_reference_result',
        node=str(node),input_sha256=hashes,reference_manifest_sha256=sha(reference/'manifest.json'),
        snapshot_unchanged=all(sha(Path(p))==h for p,h in hashes.items()))
    implementation=output/'implementation';implementation.mkdir()
    result['implementation_sha256']={}
    for name in ('scripts/audit/audit_fusion_mapping.py','scripts/audit/audit_union_preservation.py','rcnc/pddl.py'):
        path=Path(name); destination=implementation/name
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(path.read_bytes())
        result['implementation_sha256'][name]=sha(path)
    (output/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    return result


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--reference',type=Path,required=True)
    p.add_argument('--node',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args()
    r=run(a.reference,a.node,a.output)
    print(json.dumps({k:v for k,v in r.items() if k not in ('sources','input_sha256')},indent=2))

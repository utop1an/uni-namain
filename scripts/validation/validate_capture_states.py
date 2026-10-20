"""Exhaustive finite-state comparison for the saved quantifier-capture fixture."""
import argparse
from itertools import product
import json
from pathlib import Path

from unified_planning.io import PDDLReader
from unified_planning.model.fluent import get_all_fluent_exp
from unified_planning.plans import ActionInstance, SequentialPlan
from rcnc.trace_audit import compare_states
from scripts.experiments.replay_source_probes import read, sha


def run(experiment,output):
    if output.exists():
        raise ValueError('Use a fresh report path')
    reader=PDDLReader()
    src=reader.parse_problem(str(experiment/'inputs/A_domainfile.pddl'),str(experiment/'inputs/A_problemfile.pddl'))
    facts=[f for schema in src.fluents for f in get_all_fluent_exp(src,schema)]
    if len(facts)>10:
        raise ValueError('Finite control limited to ten Boolean atoms')
    targets={}
    metadata={}
    for label in ('before','after'):
        root=experiment/('compiled_'+label)
        targets[label]=reader.parse_problem(str(root/'meta_domain.pddl'),str(root/'problems/A_problemfile.pddl'))
        metadata[label]=read(root/'meta_domain.json')
    result={'status':'PASS','source_ground_atoms':len(facts),'states':2**len(facts),'rows':[],
        'scope':'All valuations and action bindings of this authored finite fixture, not arbitrary source domains'}
    for bits in product((False,True),repeat=len(facts)):
        source=src.clone()
        for fact,value in zip(facts,bits):
            source.set_initial_value(fact,value)
        for action in source.actions:
            for binding in product(*[list(source.objects(p.type)) for p in action.parameters]):
                row={'valuation':list(bits),'binding':[o.name for o in binding]}
                sp=SequentialPlan([ActionInstance(action,tuple(source.environment.expression_manager.ObjectExp(o) for o in binding))])
                for label,target_base in targets.items():
                    target=target_base.clone();meta=metadata[label]
                    predicates=meta['predicate_maps']['A'];terms=meta['constant_maps']['A']
                    for fact,value in zip(facts,bits):
                        mapped=target.fluent(predicates[fact.fluent().name])(*[target.object(terms[a.object().name]) for a in fact.args])
                        target.set_initial_value(mapped,value)
                    mapped_action=target.action(meta['action_maps']['A'][action.name])
                    mapped_binding=tuple(target.environment.expression_manager.ObjectExp(target.object(terms[o.name])) for o in binding)
                    check=compare_states(source,target,sp,SequentialPlan([ActionInstance(mapped_action,mapped_binding)]),predicates,terms)
                    row[label]={k:check[k] for k in ('status','mismatch_count','truth_comparisons')}
                result['rows'].append(row)
    result.update(action_bindings_checked=len(result['rows']),
        before_mismatches=sum(r['before']['mismatch_count'] for r in result['rows']),
        after_mismatches=sum(r['after']['mismatch_count'] for r in result['rows']),
        input_sha256={str(p):sha(p) for p in [experiment/'inputs/A_domainfile.pddl',experiment/'inputs/A_problemfile.pddl',
            experiment/'compiled_before/meta_domain.pddl',experiment/'compiled_after/meta_domain.pddl']},
        implementation_sha256={p:sha(Path(p)) for p in ('scripts/validation/validate_capture_states.py','rcnc/trace_audit.py')})
    if not result['before_mismatches'] or result['after_mismatches'] or any(r['after']['status']!='PASS' for r in result['rows']):
        result['status']='FAIL'
    output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    return result


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--experiment',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args()
    r=run(a.experiment,a.output)
    print(json.dumps({k:v for k,v in r.items() if k!='rows'},indent=2))
    raise SystemExit(r['status']!='PASS')

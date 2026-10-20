"""Find the first applicability divergence in a pair of already transported traces."""
import argparse
import json
from pathlib import Path

from unified_planning.io import PDDLReader
from unified_planning.shortcuts import SequentialSimulator
from scripts.experiments.replay_source_probes import sha


def diagnose(original, transported):
    reader=PDDLReader()
    problems=[reader.parse_problem(str(root/'domain.pddl'),str(root/'problem.pddl'))
              for root in (original,transported)]
    plans=[reader.parse_plan(problem,str(root/'plan.txt')) for root,problem in zip((original,transported),problems)]
    if len(plans[0].actions)!=len(plans[1].actions):
        raise ValueError('Trace lengths differ')
    result={'status':'no_applicability_divergence','steps':[],
        'artifact_sha256':{str(root/name):sha(root/name) for root in (original,transported)
                           for name in ('domain.pddl','problem.pddl','plan.txt')},
        'limit':'This trace witness does not establish semantic correctness or absence of alternative plans'}
    with SequentialSimulator(problems[0]) as left, SequentialSimulator(problems[1]) as right:
        a,b=left.get_initial_state(),right.get_initial_state()
        for i,(source,target) in enumerate(zip(plans[0].actions,plans[1].actions),1):
            aa=left.apply(a,source.action,source.actual_parameters)
            bb=right.apply(b,target.action,target.actual_parameters)
            row={'step':i,'source_action':str(source),'mapped_action':str(target),
                 'source_applicable':aa is not None,'mapped_applicable':bb is not None}
            result['steps'].append(row)
            if aa is None or bb is None:
                result['status']='applicability_divergence' if (aa is None)!=(bb is None) else 'both_inapplicable'
                result['first_problem_step']=i
                if bb is None:
                    unsatisfied,reason=right.get_unsatisfied_conditions(b,target.action,target.actual_parameters)
                    row.update(mapped_unsatisfied_conditions=[str(c) for c in unsatisfied],mapped_reason=str(reason))
                break
            a,b=aa,bb
        else:
            result['final_goal_satisfaction']={'source':left.is_goal(a),'mapped':right.is_goal(b)}
    return result


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--original',type=Path,required=True)
    p.add_argument('--transported',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args()
    if a.output.exists():
        p.error('Use a fresh output path')
    result=diagnose(a.original,a.transported)
    result['implementation_sha256']=sha(Path(__file__))
    a.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in result.items() if k!='artifact_sha256'},indent=2))

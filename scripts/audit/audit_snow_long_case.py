"""Replay long plans, check contracts, and test individual-step necessity."""
import argparse
from collections import Counter
import json
from pathlib import Path
from unified_planning.io import PDDLReader
from unified_planning.shortcuts import SequentialSimulator
from rcnc.domain_building import require_empty_output, save
from rcnc.validation import validate_artifacts
from scripts.experiments.run_downward_reference import sha

def read(path):
    return json.loads(path.read_text(encoding='utf-8'))

def literals(expr):
    if expr.is_and():
        return [lit for arg in expr.args for lit in literals(arg)]
    if expr.is_fluent_exp():
        return [(expr,True)]
    if expr.is_not() and expr.arg(0).is_fluent_exp():
        return [(expr.arg(0),False)]
    raise ValueError('Unsupported causal-audit condition: '+str(expr))

def replay(directory, provenance, with_deletions=False):
    reader=PDDLReader()
    problem=reader.parse_problem(str(directory/'domain.pddl'),str(directory/'problem.pddl'))
    plan=reader.parse_plan(problem,str(directory/'plan.txt'))
    meta=read(provenance/'source_mapping.json'); registry=read(provenance/'action_registry.json')
    f=lambda s,p,*objects:problem.fluent(meta['predicate_maps'][s][p].lower())(*[problem.object(o) for o in objects])
    tree=meta['constant_maps']['JACK_NP']['beanstalk']; landing=meta['constant_maps']['JACK_NP']['cottage']
    actors=['q__snow_white','q__rescuer','q__companion','q__jack']
    places=['q__hut','q__outside','q__workshop',tree,landing]
    snow,comb=problem.object('q__snow_white'),problem.object('q__comb')
    sat=problem.fluent('scene_at')
    watched={'alive':f('SNOW','alive','q__snow_white'),'dead':f('SNOW','dead','q__snow_white'),
        'rescuer_has_comb':f('SNOW','has','q__rescuer','q__comb'),
        'witch_has_comb':f('SNOW','has','q__snow_white','q__comb'),
        'comb_poisoned':f('SNOW','poisoned','q__comb'),
        'cutter_has_axe':f('JACK_NP','has','q__jack','q__axe'),
        'descending':f('JACK_NP','climbing_down','q__snow_white'),
        'beanstalk_intact':f('JACK_NP','intact',tree),
        'comb_applied':problem.fluent('scene_comb_applied')(snow,comb),
        'rescue_recorded':problem.fluent('case_rescued_with_comb')(snow)}
    preconditions=[]
    atoms={str(v):v for v in watched.values()}
    for step in plan.actions:
        substitution={problem.environment.expression_manager.ParameterExp(p):v for p,v in zip(step.action.parameters,step.actual_parameters)}
        grounded=[problem.environment.substituter.substitute(p,substitution) for p in step.action.preconditions]
        requirements=[lit for expr in grounded for lit in literals(expr)]
        preconditions.append(requirements)
        atoms.update({str(a):a for a,_ in requirements})
    goal_lits=[lit for goal in problem.goals for lit in literals(goal)]
    atoms.update({str(a):a for a,_ in goal_lits})
    states,steps,violations,edges=[],[],[],[]
    holders=[(o,problem.fluent(meta['predicate_maps']['SNOW']['has'].lower())(o,comb)) for o in problem.all_objects]
    with SequentialSimulator(problem) as sim:
        state=sim.get_initial_state()
        last={(name,state.get_value(atom).bool_constant_value()):0 for name,atom in atoms.items()}
        for index in range(len(plan.actions)+1):
            facts={name:state.get_value(atom).bool_constant_value() for name,atom in watched.items()}
            positions={a:[p for p in places if state.get_value(sat(problem.object(a),problem.object(p))).bool_constant_value()] for a in actors}
            owners=[o.name for o,atom in holders if state.get_value(atom).bool_constant_value()]
            on_shelf=state.get_value(problem.fluent('scene_comb_on_shelf')(comb,problem.object('q__hut'))).bool_constant_value()
            role_checks={r:state.get_value(problem.fluent('case_role_'+r)(snow)).bool_constant_value() for r in ('snow_white','giant','witch')}
            states.append({'index':index,'facts':facts,'positions':positions,'comb_owners':owners,'comb_on_shelf':on_shelf,'identity_roles':role_checks})
            for actor in actors:
                if state.get_value(f('SNOW','alive',actor)).bool_constant_value() and state.get_value(f('SNOW','dead',actor)).bool_constant_value():
                    violations.append({'state':index,'kind':'alive_and_dead','actor':actor})
                if len(positions[actor])!=1:
                    violations.append({'state':index,'kind':'non_unique_position','actor':actor,'positions':positions[actor]})
            if len(owners)+int(on_shelf)!=1:
                violations.append({'state':index,'kind':'non_unique_comb_custody','owners':owners,'on_shelf':on_shelf})
            if not all(role_checks.values()):
                violations.append({'state':index,'kind':'identity_role_lost'})
            if index==len(plan.actions):
                break
            action=plan.actions[index]
            if not sim.is_applicable(state,action):
                raise ValueError('Inapplicable step '+str(index+1))
            origin=registry[action.action.name.lower()]
            supports=[]
            for atom,truth in preconditions[index]:
                producer=last.get((str(atom),truth),0)
                if producer:
                    edge={'producer_step':producer,'consumer_step':index+1,'literal':str(atom),'truth':truth}
                    edges.append(edge);supports.append(edge)
            following=sim.apply(state,action)
            changes=[]
            for name,atom in atoms.items():
                old=state.get_value(atom).bool_constant_value();new=following.get_value(atom).bool_constant_value()
                if old!=new:
                    changes.append({'atom':name,'before':old,'after':new});last[(name,new)]=index+1
            steps.append({'step':index+1,'instance':str(action),'origin_kind':origin['kind'],
                'source':origin['source'],'action':origin['original_action'],'applicable':True,
                'causal_supports':supports,'changed_relevant_atoms':changes})
            state=following
        goal_supports=[{'goal':str(atom),'truth':truth,'producer_step':last.get((str(atom),truth),0)} for atom,truth in goal_lits]
        goal_reached=sim.is_goal(state)
    deletions=[]
    if with_deletions:
        for deleted in range(len(plan.actions)):
            with SequentialSimulator(problem) as sim:
                state=sim.get_initial_state();failure=None
                for i,action in enumerate(plan.actions):
                    if i==deleted:
                        continue
                    if not sim.is_applicable(state,action):
                        unsatisfied,reason=sim.get_unsatisfied_conditions(state,action)
                        failure={'first_inapplicable_original_step':i+1,'instance':str(action),
                                 'unsatisfied_conditions':[str(v) for v in unsatisfied],'reason':str(reason)}
                        break
                    state=sim.apply(state,action)
                deletions.append({'deleted_step':deleted+1,'instance':str(plan.actions[deleted]),
                    'outcome':'inapplicable_remainder' if failure else 'goal_not_reached' if not sim.is_goal(state) else 'redundant_step',
                    'failure':failure})
    return {'validation':validate_artifacts(directory),'goal_reached':goal_reached,
        'plan_length':len(plan.actions),'steps':steps,'states':states,'violations':violations,
        'source_step_count':sum(s['origin_kind']=='source' for s in steps),
        'new_scenario_step_count':sum(s['origin_kind']=='new_scenario_rule' for s in steps),
        'causal_edges':edges,'goal_supports':goal_supports,'deletion_replays':deletions,
        'all_steps_deletion_necessary':bool(deletions) and all(d['outcome']!='redundant_step' for d in deletions)}

def run(case,output):
    require_empty_output(output)
    protocol=read(case/'bundle/manifest.json');solver=read(case/'solver/manifest.json');report=read(case/'solver/report.json')
    if report['status']!='complete' or not report['binary_unchanged'] or not report['runner_unchanged']:
        raise ValueError('Complete unchanged solver block required')
    if solver['budget']!={'wall_seconds':20,'overall_cpu_seconds':20,'memory_mb':4096}:
        raise ValueError('Changed budget')
    if sha(case/'solver/manifest.json')!=report['manifest_sha256'] or len(report['rows'])!=23 or {r['id'] for r in report['rows']}!={t['id'] for t in protocol['tasks']}:
        raise ValueError('Changed manifest or incomplete denominator')
    if solver['task_bundle_manifest_sha256']!=sha(case/'bundle/manifest.json'):
        raise ValueError('Frozen bundle manifest drift')
    if sha(case/'query.json')!=protocol['query_sha256'] or sha(case/'scenario_contract.json')!=protocol['contract_sha256']:
        raise ValueError('Frozen world or scenario contract drift')
    if dict(Counter(r['status'] for r in report['rows']))!=report['status_counts']:
        raise ValueError('Solver counts differ from individual rows')
    for p,h in protocol['implementation_sha256'].items():
        if sha(Path(p))!=h:raise ValueError('Construction code drift')
    frozen={str(p):sha(p) for p in (case/'bundle/manifest.json',case/'solver/manifest.json',case/'solver/report.json',
        case/'query.json',case/'scenario_contract.json',Path(__file__),Path('rcnc/validation.py'))}
    source_meta=read(case/'bundle/tasks/role_safe/source_mapping.json')
    for name,digest in source_meta['source_sha256'].items():
        path=case/'inputs'/name
        if sha(path)!=digest:
            raise ValueError('Pinned source snapshot drift')
        frozen[str(path)]=sha(path)
    rows=[]
    for task in protocol['tasks']:
        origin=case/'bundle/tasks'/task['id'];directory=case/'solver/tasks'/task['id']
        for kind in ('domain','problem'):
            path=directory/(kind+'.pddl')
            if sha(path)!=task[kind+'_sha256']:raise ValueError('Changed task')
            frozen[str(path)]=sha(path)
        for file,key in [('source_mapping.json','mapping_sha256'),('action_registry.json','registry_sha256')]:
            if sha(origin/file)!=task[key]:raise ValueError('Changed action provenance')
            frozen[str(origin/file)]=sha(origin/file)
        row=next(r for r in report['rows'] if r['id']==task['id']).copy()
        row.update(base_condition=task['base_condition'],removed_schema=task['removed_schema'],removed_origin=task['removed_origin'])
        if row['status']=='solved':
            frozen[str(directory/'plan.txt')]=sha(directory/'plan.txt')
            row['execution_audit']=replay(directory,origin,task['id']=='role_safe')
            trace=row['execution_audit']
            row['scenario_contract_pass']=trace['validation']['status']=='VALID' and trace['goal_reached'] and not trace['violations']
        else:
            row['scenario_contract_pass']=None
        rows.append(row)
    main=next(r for r in rows if r['id']=='role_safe')
    trace=main['execution_audit']
    if not main['scenario_contract_pass'] or not 8<=trace['plan_length']<=12 or not trace['all_steps_deletion_necessary']:
        raise ValueError('Primary long plan or per-step necessity failed')
    removal=[r for r in rows if r['removed_schema']]
    result={'status':'complete','task_count':len(rows),'rows':rows,'status_counts':dict(Counter(r['status'] for r in rows)),
        'primary_plan_length':trace['plan_length'],'source_steps':trace['source_step_count'],'new_scenario_steps':trace['new_scenario_step_count'],
        'primary_state_count':len(trace['states']),'step_deletion_checks':len(trace['deletion_replays']),
        'step_deletion_checks_failed_as_expected':sum(r['outcome']!='redundant_step' for r in trace['deletion_replays']),
        'schema_removal_count':len(removal),'schema_removal_status_counts':dict(Counter(r['status'] for r in removal)),
        'scenario_contract_pass_count':sum(r['scenario_contract_pass'] is True for r in rows),
        'compiled_source_behavior_modified':True,'independent_semantic_labels':0,
        'scope':'One authored long scenario; eight new scene schemas and four contextualized source steps. Deletion proves this returned plan is irredundant; whole-schema solver controls are separate bounded evidence, not a universal minimality theorem.',
        'semantic_limits':['Comb-based revival still does not test death cause; it is an explicit magical scenario assumption.',
            'Role permissions, life consistency, object custody, tools, travel and preparation are authored additions, not learned automatically.',
            'Common scenario rules remain available in single-source controls; these are not native-source goal tests.'],
        'frozen_sha256':frozen,'hashes_unchanged':all(sha(Path(p))==h for p,h in frozen.items())}
    output.mkdir(parents=True,exist_ok=True)
    save(output/'report.json',result)
    return result

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--case',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();r=run(args.case,args.output)
    print(json.dumps({k:r[k] for k in ('status','status_counts','primary_plan_length','source_steps','new_scenario_steps','step_deletion_checks_failed_as_expected','schema_removal_status_counts','hashes_unchanged')},indent=2))

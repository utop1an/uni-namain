"""Verify the compact final evidence and rebuild saved models without LLM calls."""
import argparse
from collections import Counter
from itertools import permutations
from pathlib import Path
import json

from rcnc.domain_building import digest, save
from rcnc.glaive_merge import Source, build
from rcnc.revised_followup import authored_problem
from rcnc.saved_plan_validation import replay_saved
from scripts.audit.eval_revised_composition import causal_trace, profiles_for
from scripts.experiments.run_four_domain_long_case import trace_case

DEFAULT = Path('data/research_release/icaps2027_2026_11_03')


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def load_sources(release):
    return {r['id']: Source(r['id'], release/r['domain.pddl']['path'], release/r['problem.pddl']['path'])
            for r in read(release/'sources.json')['sources']}


def verify(release, models=None):
    manifest=read(release/'manifest.json')
    for name, expected in manifest['files'].items():
        if digest(release/name)!=expected: raise ValueError('Changed release file: '+name)
    sources=load_sources(release)
    native=read(release/'native_results.json')['rows']; good={r['source'] for r in native if r['validated']}
    if len(sources)!=60 or len(native)!=60 or len(good)!=33:raise ValueError('Source denominator')
    for sid in good:
        result=replay_saved(sources[sid].domain_path,sources[sid].problem_path,release/'native_plans'/(sid+'.pddl'))
        if result['status']!='replayed' or not result['goal']:raise ValueError('Native physical replay failed: '+sid)
    groups=read(release/'groups.json')['groups']
    covered={g['id'] for g in groups if set(g['sources'])<=good}
    if Counter(g['size'] for g in groups if g['id'] in covered)!=Counter({2:31,3:16,4:10}):
        raise ValueError('Reference-covered subgroup changed')
    profiles,_=profiles_for(sources)
    consensus={r['group']:r['groups'] for r in read(release/'consensus.json')['rows']}
    coverage=Counter()
    for group in groups:
        interfaces=[g for g in consensus[group['id']] if 'predicate' in g['members'][0]]
        if not interfaces:
            coverage['no_shared_predicate']+=1;continue
        handoff=False;goal=False
        for interface in interfaces:
            members={m['predicate'].split(':')[0]:m['predicate'].split(':')[1] for m in interface['members']}
            for a,b in permutations(members,2):
                producers=[p for p in profiles[a].values() if any(sign and atom[0]==members[a] for sign,atom in p['effects'])]
                consumers=[p for p in profiles[b].values() if any(sign and atom[0]==members[b] for sign,atom in p['preconditions'])]
                if producers and consumers:
                    handoff=True
                    if any(any(sign and atom[0]!=members[b] for sign,atom in p['effects']) for p in consumers):goal=True
        coverage['supported_handoff_and_goal' if goal else 'handoff_without_distinct_goal' if handoff else 'no_supported_handoff']+=1
    if coverage!=Counter({'no_shared_predicate':180,'no_supported_handoff':83,'handoff_without_distinct_goal':2,'supported_handoff_and_goal':35}):
        raise ValueError('Generator coverage decomposition changed')
    transports=read(release/'transport_results.json')['rows']
    if len(transports)!=2700 or len({r['id'] for r in transports})!=2700:raise ValueError('Transport denominator')
    for condition in ('union','predicate_only','full'):
        rs=[r for r in transports if r['condition']==condition]
        if len(rs)!=900 or sum(r['validated'] for r in rs)!=499:raise ValueError('Transport summary mismatch')
    subgroup=[r for r in transports if r['condition']=='full' and r['group'] in covered]
    if len(subgroup)!=150 or not all(r['validated'] for r in subgroup):raise ValueError('Reference subgroup preservation changed')
    rows=read(release/'composition_results.json')['rows'];summary=read(release/'expanded_analysis.json')
    if len(rows)!=420 or len({r['id'] for r in rows})!=420:raise ValueError('Composition denominator')
    worlds=read(release/'world_registry.json')['worlds'];reps={w['representative_case_id'] for w in worlds}
    if len(worlds)!=37 or len(reps)!=37:raise ValueError('World denominator')
    for condition,expected in summary['all_tasks'].items():
        rs=[r for r in rows if r['condition']==condition]
        if len(rs)!=70 or sum(r['valid_plan'] for r in rs)!=expected['valid']:raise ValueError('Validity summary mismatch')
        if dict(Counter(r['causal']['status'] for r in rs))!=expected['causal_status']:raise ValueError('Causal summary mismatch')
        fixed=[r for r in rs if r['case_id'] in reps];target=summary['fixed_world_representatives'][condition]
        if len(fixed)!=37 or sum(r['valid_plan'] for r in fixed)!=target['valid']:raise ValueError('World validity mismatch')
        if dict(Counter(r['causal']['status'] for r in fixed))!=target['causal_status']:raise ValueError('World causal mismatch')
    case=release/'long_case';result=replay_saved(case/'domain.pddl',case/'problem.pddl',case/'plan.pddl')
    if result['status']!='replayed' or not result['goal'] or result['steps']!=11:raise ValueError('Long case physical replay failed')
    trace=trace_case(case/'domain.pddl',case/'problem.pddl',case/'plan.pddl',read(case/'mapping.json'))
    if trace!=read(case/'result.json')['causal']:raise ValueError('Long case causal reconstruction changed')
    replayed=0
    if models is not None:
        cases={c['case_id']:c for c in read(release/'composition_cases.json')['cases']}
        scratch=models/'verification'
        if scratch.exists():raise ValueError('Use a fresh model verification directory')
        scratch.mkdir()
        for row in rows:
            if not row['valid_plan']:continue
            c=cases[row['case_id']];base_condition=row['condition'] if row['condition'] in ('union','predicate_only','full') else 'full'
            folder=models/row['group']/base_condition;meta=read(folder/'mapping.json')
            active=set(c['group']['sources'])
            if row['condition']=='without_producer':active.remove(c['candidate']['producer'])
            if row['condition']=='without_consumer':active.remove(c['candidate']['consumer'])
            sub=scratch/row['id'];sub.mkdir();problem=sub/'problem.pddl';plan=sub/'plan.pddl'
            authored_problem([sources[s] for s in c['group']['sources']],meta,c['scenario'],problem,
                active_sources=active,separate_identity=row['condition']=='separate_identity')
            plan.write_text(row['plan'],encoding='utf-8')
            result=replay_saved(folder/'domain.pddl',problem,plan)
            if result['status']!='replayed' or not result['goal']:raise ValueError('Returned plan replay differs')
            if causal_trace(folder/'domain.pddl',problem,plan,meta)!=row['causal']:raise ValueError('Causal verdict differs')
            replayed+=1
        if replayed!=212:raise ValueError('Returned-plan denominator changed')
    return {'status':'verified_compact_release','manifest_files':len(manifest['files']),
        'sources':60,'native_plans_physically_replayed':33,'transport_rows':2700,
        'composition_rows':420,'worlds':37,'long_case_steps':11,
        'generator_coverage':dict(coverage),'fully_reference_covered_groups':57,'fully_reference_covered_transports':150,
        'reconstructed_returned_plans':replayed,'new_model_calls':0,'new_planner_calls':0,
        'intentionality_scope':'Saved Glaive results are retained; this offline command rechecks physical/causal evidence without invoking Glaive.'}


def rebuild(release, output):
    if output.exists():raise ValueError('Fresh model output required')
    output.mkdir(parents=True);sources=load_sources(release)
    consensus={r['group']:r['groups'] for r in read(release/'consensus.json')['rows']}
    expected={(r['group'],r['condition']):r['domain_sha256'] for r in read(release/'model_hashes.json')['models']}
    checked=[]
    for group in read(release/'groups.json')['groups']:
        sid=group['id'];selected=[sources[s] for s in group['sources']]
        predicates=[g for g in consensus[sid] if 'predicate' in g['members'][0]]
        for condition in ('union','predicate_only','full'):
            folder=output/sid/condition
            build(selected,folder,groups=() if condition=='union' else predicates if condition=='predicate_only' else consensus[sid],merge_actions=condition=='full')
            if digest(folder/'domain.pddl')!=expected[sid,condition]:raise ValueError('Rebuilt model differs: '+sid+' '+condition)
            checked.append({'group':sid,'condition':condition,'sha256':expected[sid,condition]})
    if len(checked)!=900:raise ValueError('Model denominator')
    save(output/'rebuild_receipt.json',{'status':'all_models_byte_identical','models':checked,'new_model_calls':0,'new_planner_calls':0})
    return {'status':'all_models_byte_identical','models':900,'new_model_calls':0,'new_planner_calls':0}


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode',choices=('verify','rebuild','replay-case'))
    parser.add_argument('--release',type=Path,default=DEFAULT)
    parser.add_argument('--output',type=Path)
    parser.add_argument('--models',type=Path)
    parser.add_argument('--runtime',type=Path)
    parser.add_argument('--classes',type=Path)
    args=parser.parse_args()
    if args.mode in ('rebuild','replay-case') and args.output is None:parser.error('--output required')
    if args.mode=='replay-case':
        if args.runtime is None or args.classes is None:parser.error('--runtime and --classes required')
        if args.output.exists():raise ValueError('Fresh replay output required')
        from scripts.experiments.run_revised_multistory import replay_checked, valid
        case=args.release/'long_case'
        result=replay_checked(args.runtime,args.classes,case/'domain.pddl',case/'problem.pddl',case/'plan.pddl',args.output,seconds=15)
        result={'status':'validated_case' if valid(result) else 'case_not_validated','result':result}
    else:
        result=rebuild(args.release,args.output) if args.mode=='rebuild' else verify(args.release,args.models)
    print(json.dumps(result,indent=2))

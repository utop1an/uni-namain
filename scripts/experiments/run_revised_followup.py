"""Frozen posthoc branch tests, authored composition controls and blind review pack."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import traceback

from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.glaive_merge import Source, map_problem, translate_plan
from rcnc.glaive_runtime import invoke
from rcnc.pddl import parse_sexpr, section
from rcnc.revised_followup import authored_problem, branch_specs, composition_scenarios, emit, write_native_fixture
from scripts.experiments.run_revised_development import JAR, CLASSES, replay, passed

MAIN=Path('data/validation/revised_main_2026_11_01_v1')
ANALYSIS=Path('data/validation/revised_main_analysis_2026_11_01_v1/analysis.json')
INTAKE=Path('data/external/there_and_back_gpt4_revised_2026_11_01_v1/upstream/results/runs')


def read(p):return json.loads(Path(p).read_text(encoding='utf-8'))


def load_sources():
    return {r['id']:Source(r['id'],INTAKE/r['upstream_id']/'revised-domain.pddl',INTAKE/r['upstream_id']/'revised-problem.pddl')
            for r in read(MAIN/'protocol.json')['rows'] if r.get('adapter')=='compiled'}


def review_packet(output):
    packet={i['id']:i for i in read(MAIN/'judgments/packet.json')['items']}
    rows=read(MAIN/'judgments/report.json')['rows'];models=read(MAIN/'compilation.json')['models']
    accepted={d['id'] for m in models if m['condition']=='full' for d in m['decisions'] if d['status']=='accepted'}
    selected=[]
    for kind in ('predicate','action'):
        positives=[i for i in accepted if packet[i]['kind']==kind]
        controls=[r['id'] for r in rows if r['kind']==kind and r.get('response',{}).get('decision')=='different']
        controls.sort(key=lambda i:(-packet[i].get('lexical_score',0),hashlib.sha256(('review-control|'+i).encode()).hexdigest()))
        selected += [(i,'accepted') for i in positives]+[(i,'model_rejected_control') for i in controls[:len(positives)]]
    selected.sort(key=lambda x:hashlib.sha256(('blind-revised-20261101|'+x[0]).encode()).hexdigest())
    cases=[];key=[];answers=[]
    for index,(gid,stratum) in enumerate(selected):
        item=packet[gid];case_id='case_'+str(index+1).zfill(3);sides=[]
        for side_index,s in enumerate(item['sides']):
            label='A' if side_index==0 else 'B'
            sides.append({'side':label,'declaration':s['declaration'],'parameters':s['parameters'],
                          'contexts':[{'id':label+'_context_'+str(j),'text':c['text']} for j,c in enumerate(s['contexts'])]})
        cases.append({'id':case_id,'kind':item['kind'],'sides':sides})
        key.append({'id':case_id,'candidate_id':gid,'sampling_stratum':stratum,'references':[s['reference'] for s in item['sides']]})
        answers.append({'id':case_id,'verdict':None,'role_correspondence':None,'evidence_ids':[],'notes':'','reviewer_id':None})
    folder=output/'independent_review';folder.mkdir()
    save(folder/'blind_cases.json',{'status':'awaiting_independent_review','cases':cases,'semantic_gold_labels':0,
        'instructions':['Judge meaning and participant roles from the supplied formulas. Model judgments, confidence and planner outcomes are withheld.',
                        'Use equivalent, compatible_action_variants, different, or unclear. A predicate cannot be compatible_action_variants.',
                        'Different applicability can be legitimate action variants; identical effects or names alone do not establish event identity.',
                        'Record role correspondence and cited context IDs. Leave uncertain cases unclear rather than forcing a label.']})
    save(folder/'answers_template.json',{'status':'unlabeled','answers':answers})
    save(folder/'allocation_key_do_not_show_reviewers.json',{'sampling':'All 37 accepted groups plus 37 same-kind model-rejected controls, ranked by source lexical similarity then fixed hash. These strata are not gold labels.','cases':key})
    return {'cases':len(cases),'accepted_groups':len(accepted),'model_rejected_controls':len(cases)-len(accepted),'independent_labels':0}


def prepare(root):
    if root.exists():raise ValueError('Fresh output directory required')
    main=read(MAIN/'protocol.json');comp=read(MAIN/'compilation.json');analysis=read(ANALYSIS)
    for path,h in {**main['input_sha256'],**main['implementation_sha256'],**comp['input_sha256']}.items():
        if digest(Path(path))!=h:raise ValueError('Primary artifact changed: '+path)
    root.mkdir(parents=True);sources=load_sources();models={(m['pair'],m['condition']):m for m in comp['models']}
    branch_tasks=[];branch_definitions=[];admission=[]
    for group in analysis['actual_action_groups']:
        pair=group['pair'];group_id=group['group'];pair_ids=list(models[pair,'full']['source_sha256'])
        for branch in group['branches']:
            sid,name=branch['reference'].split(':');source=sources[sid];branch_id=group_id+'__'+sid
            try:specs=branch_specs(source,name)
            except (ValueError,KeyError) as exc:
                admission.append({'branch':branch_id,'status':'unsupported','reason':str(exc)});continue
            admission.append({'branch':branch_id,'status':'prepared'})
            branch_definitions.append({'id':branch_id,'pair':pair,'group':group_id,'source':sid,'action':name,'specs':specs,
                'provenance':'Schema-derived authored engineering worlds; no original-story initial facts used.'})
            for spec in specs:
                folder=root/'branch_worlds'/branch_id/spec['id'];np=folder/'native_problem.pddl';plan=folder/'native_plan.pddl'
                fixture_source=write_native_fixture(source,spec,np,plan)
                branch_tasks.append({'id':branch_id+'__'+spec['id']+'__native','branch':branch_id,'pair':pair,'group':group_id,'source':sid,
                    'condition':'native','case':spec['id'],'expected':spec['expected'],'domain':str(source.domain_path),'problem':str(np),'plan':str(plan)})
                source_pair=[fixture_source if s==sid else sources[s] for s in pair_ids]
                for condition in ('union','predicate_only','full'):
                    m=models[pair,condition];problem=folder/(condition+'_problem.pddl');translated=folder/(condition+'_plan.pddl')
                    terms=map_problem(source_pair,sid,m,problem);translate_plan(sid,m,terms,plan,translated)
                    domain=MAIN/'models'/pair/condition/'domain.pddl'
                    task={'id':branch_id+'__'+spec['id']+'__'+condition,'branch':branch_id,'pair':pair,'group':group_id,'source':sid,
                        'condition':condition,'case':spec['id'],'expected':spec['expected'],'domain':str(domain),'problem':str(problem),'plan':str(translated)}
                    branch_tasks.append(task)
                    if spec['id']=='positive':
                        variants=[('source_inactive',[sid+'_active'])]
                        variants += [('missing_type_'+str(i),[sid+'_type_'+typ,terms[spec['binding'][var]]])
                                     for i,(var,typ) in enumerate(spec['parameters'].items())]
                        for label,remove in variants:
                            expression=parse_sexpr(problem.read_text(encoding='utf-8'));initial=section(expression,':init')
                            if remove not in initial:raise ValueError('Missing declared guard fact')
                            initial.remove(remove);negative=folder/(condition+'_'+label+'.pddl');emit(negative,expression)
                            branch_tasks.append({**task,'id':branch_id+'__'+label+'__'+condition,'case':label,'expected':'inapplicable','problem':str(negative)})
    scenarios=composition_scenarios();cross_tasks=[];cross_maps=[]
    conditions=[('union','both',False),('predicate_only','both',False),('full','both',False),
                ('predicate_only','left',False),('predicate_only','right',False),('full','left',False),('full','right',False),
                ('predicate_only','both',True),('full','both',True)]
    for scenario in scenarios:
        pair=scenario['pair'];pair_sources=[sources[s] for s in scenario['sources']]
        for condition,enabled,separate in conditions:
            label=condition+'_'+enabled+('_separate_identity' if separate else '')
            active=scenario['sources'] if enabled=='both' else [scenario['sources'][0 if enabled=='left' else 1]]
            problem=root/'cross_worlds'/scenario['id']/(label+'.pddl')
            mapping=authored_problem(pair_sources,models[pair,condition],scenario,problem,active_sources=active,separate_identity=separate)
            task={'id':scenario['id']+'__'+label,'family':scenario['family'],'size':scenario['size'],'pair':pair,'condition':condition,
                  'source_activation':enabled,'separate_identity':separate,'domain':str(MAIN/'models'/pair/condition/'domain.pddl'),
                  'problem':str(problem),'hypothesis':'solved' if condition!='union' and enabled=='both' and not separate else 'no_plan'}
            cross_tasks.append(task);cross_maps.append({'id':task['id'],**mapping})
    save(root/'branch_definitions.json',{'branches':branch_definitions,'admission':admission})
    save(root/'cross_scenarios.json',{'scope':'Posthoc authored mechanism tests; two families, correlated sizes 1 and 3; not new held-out stories or independent narrative labels.',
        'scenarios':scenarios,'maps':cross_maps})
    review=review_packet(root)
    implementation=snapshot_implementation(root,[Path(__file__),Path('rcnc/revised_followup.py'),Path('rcnc/glaive_merge.py'),Path('rcnc/glaive_runtime.py'),
        Path('rcnc/pddl.py'),Path('rcnc/conditional_merge.py'),Path('rcnc/domain_building.py'),Path('scripts/java/GlaiveProbe.java'),
        Path('scripts/experiments/run_revised_development.py')])
    files=[p for p in root.rglob('*') if p.is_file()]
    files += [MAIN/'protocol.json',MAIN/'report.json',MAIN/'compilation.json',MAIN/'judgments/groups.json',MAIN/'judgments/report.json',ANALYSIS,JAR,CLASSES/'GlaiveProbe.class']
    for t in branch_tasks+cross_tasks:
        files += [Path(t['domain']),Path(t['problem'])]
        if 'plan' in t:files.append(Path(t['plan']))
    protocol={'status':'frozen_before_followup_execution','created_utc':datetime.now(timezone.utc).isoformat(),
        'source_run':str(MAIN),'branch_tasks':branch_tasks,'branch_admission':admission,'cross_tasks':cross_tasks,'review':review,
        'budgets':{'model_calls':0,'branch_replays':len(branch_tasks),'search_calls':len(cross_tasks),'search_seconds':15,'replay_seconds':10,
                   'returned_plan_replay_seconds':15,'memory_mb':4096,'workers':1,'attempts':1},
        'policy':['Reuse exact primary merged domains, maps and .9 threshold; no new semantic predictions.',
                  'All branch worlds and composition worlds explicitly authored before execution. Never replace original main outcomes.',
                  'Branch negatives are fixed one-step applicability checks, not claims that their goal is globally unreachable.',
                  'Source-deactivation controls retain the same domain; guards disable one source, including its fused branch.',
                  'Cross-family outcomes, source-necessity controls and identity controls are mechanical evidence, not independent semantic/narrative labels.',
                  'Stop cross planning if any positive or negative branch check fails. Retain all errors, limits and unsupported rows. No automatic retries or cache continuation.'],
        'input_sha256':{str(p):digest(p) for p in files},'implementation_sha256':implementation}
    save(root/'protocol.json',protocol)
    return {'branch_count':len(admission),'branch_admission':dict(Counter(x['status'] for x in admission)),
            'branch_replay_tasks':len(branch_tasks),'cross_search_tasks':len(cross_tasks),'review':review}


def classify_replay(result, log, expected):
    if expected=='applicable':
        return 'pass' if passed(result) and result.get('steps')==1 else 'fail'
    if result.get('status')=='runtime_error' and result.get('returncode')==1 and 'IllegalArgumentException: Inapplicable step 0' in log:
        return 'pass_expected_rejection'
    return 'fail'


def execute(root):
    protocol=read(root/'protocol.json');state_path=root/'coordinator.json'
    if state_path.exists():raise ValueError('Fresh execution only')
    for p,h in {**protocol['input_sha256'],**protocol['implementation_sha256']}.items():
        if digest(Path(p))!=h:raise ValueError('Frozen followup input changed: '+p)
    import os
    state={'status':'running','stage':'branch_replays','pid':os.getpid(),'started_utc':datetime.now(timezone.utc).isoformat(),'completed_branch_replays':0}
    save(state_path,state);branch_rows=[];cross_rows=[]
    try:
        for task in protocol['branch_tasks']:
            out=root/'execution/branches'/task['id']
            result=invoke(JAR,Path(task['domain']),Path(task['problem']),out,mode='replay',seconds=10,classes=CLASSES,plan=Path(task['plan']))
            log=(out/'stdout.txt').read_text(encoding='utf-8',errors='replace')
            row={**task,'result':result,'check':classify_replay(result,log,task['expected'])}
            branch_rows.append(row);state['completed_branch_replays']=len(branch_rows)
            save(root/'branch_progress.json',{'rows':branch_rows});save(state_path,state)
            print(task['id'],row['check'],result['status'],flush=True)
        failures=[x['id'] for x in branch_rows if x['check']=='fail']
        if failures or any(x['status']!='prepared' for x in protocol['branch_admission']):
            state.update(status='blocked_by_branch_gate',stage='branch_replays',failures=failures)
        else:
            state['stage']='composition_search';save(state_path,state)
            for task in protocol['cross_tasks']:
                out=root/'execution/composition'/task['id']
                result=invoke(JAR,Path(task['domain']),Path(task['problem']),out/'search',seconds=15)
                row={**task,'search':result}
                if result['status']=='solved':
                    row['replay']=replay(Path(task['domain']),Path(task['problem']),out/'search/plan.pddl',out/'replay',15)
                cross_rows.append(row);save(root/'cross_progress.json',{'rows':cross_rows})
                state['completed_cross_searches']=len(cross_rows);save(state_path,state)
                print(task['id'],result['status'],flush=True)
            state.update(status='complete',stage='complete')
        report={'status':state['status'],'branch_rows':branch_rows,'cross_rows':cross_rows,
            'branch_check_counts':dict(Counter(x['check'] for x in branch_rows)),
            'branch_result_counts':dict(Counter(x['result']['status'] for x in branch_rows)),
            'branch_failures':failures,'cross_search_counts':dict(Counter(x['search']['status'] for x in cross_rows)),
            'cross_returned_plan_replays_passed':sum(passed(x.get('replay',{})) for x in cross_rows),
            'search_calls':sum(x['search']['search_calls'] for x in cross_rows),'model_calls':0,'independent_labels':0,
            'cross_scope':'Two posthoc authored families, correlated sizes and controls; not independent held-out tasks.',
            'inputs_unchanged':all(digest(Path(p))==h for p,h in protocol['input_sha256'].items()),
            'implementation_unchanged':all(digest(Path(p))==h for p,h in protocol['implementation_sha256'].items())}
        save(root/'report.json',report)
    except Exception as exc:
        state.update(status='failed',error=str(exc),traceback=traceback.format_exc());raise
    finally:
        state['ended_utc']=datetime.now(timezone.utc).isoformat();save(state_path,state)
    return {k:v for k,v in report.items() if k not in ('branch_rows','cross_rows')}


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('mode',choices=['prepare','execute']);p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();print(json.dumps(globals()[a.mode](a.output),indent=2))

"""One optimal physical search and original intentional replay of a long case."""
import argparse
from pathlib import Path
import json
import shutil
import subprocess

from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.pddl import parse_sexpr, section, serialize
from rcnc.validation import validate_artifacts
from scripts.experiments import run_revised_multistory as base
from scripts.experiments.run_four_domain_long_case import trace_case, independent_pairs
from scripts.experiments.run_downward_reference import linux_path


def prepare(previous, output):
    if output.exists(): raise ValueError('Fresh output required')
    prior=base.verify(previous);output.mkdir(parents=True)
    for name in ('original_domain.pddl','original_problem.pddl','physical_domain.pddl','physical_problem.pddl','mapping.json'):
        shutil.copy2(previous/name,output/name)
    root=parse_sexpr((output/'physical_domain.pddl').read_text(encoding='utf-8'))
    # Omit an empty optional declaration; source actions are unchanged.
    root=[x for x in root if not (isinstance(x,list) and len(x)==1 and x[0] in (':types',':constants'))]
    (output/'physical_domain.pddl').write_text(serialize(root),encoding='utf-8')
    old=previous/'solver/solver/tasks/query/plan.txt'
    shutil.copy2(old,output/'prior_lama_plan.txt')
    shutil.copytree(previous/'runtime',output/'runtime')
    planner=Path(prior['planner']);folder=output/'optimal';folder.mkdir()
    shutil.copy2(output/'physical_domain.pddl',folder/'domain.pddl')
    shutil.copy2(output/'physical_problem.pddl',folder/'problem.pddl')
    command=['wsl.exe','-d','Ubuntu','--cd',linux_path(folder),'--','timeout','--signal=TERM',
        '--kill-after=5','60s','python3',linux_path(planner/'fast-downward.py'),
        '--alias','seq-opt-lmcut','--overall-time-limit','60s','--overall-memory-limit','4096M',
        '--plan-file','plan.txt','domain.pddl','problem.pddl']
    save(output/'command.json',command)
    paths=[Path(__file__),Path('scripts/experiments/run_four_domain_long_case.py'),
        Path('rcnc/validation.py'),Path('scripts/experiments/run_downward_reference.py'),*base.IMPLEMENTATION]
    impl=snapshot_implementation(output,sorted({p.resolve() for p in paths},key=str))
    inputs={str(p):digest(p) for p in output.rglob('*') if p.is_file()}
    for name in ('builds/release/bin/downward','driver/version.py','driver/aliases.py'):
        p=planner/name;inputs[str(p)]=digest(p)
    protocol={'status':'frozen_before_optimal_case_search','created_utc':base.now(),
        'parent':str(previous),'scope':'Separate authored case; one physical optimal search followed by original Glaive validation. Prior search timeouts and parser failure retained.',
        'budgets':{'new_searches':1,'search_seconds':60,'max_glaive_replays':2,'seconds_per_replay':15,
            'memory_mb':4096,'workers':1,'new_model_calls':0,'retries':0},
        'changes':'Physical search omits intentional annotations and an empty optional :types declaration only; every original action parameter, condition, and effect remains. Validation uses unchanged original intentional artifacts.',
        'selection':'Prefer the new optimal candidate if it meets all requirements; prior LAMA candidate is diagnostic only.',
        'input_sha256':inputs,'implementation_sha256':impl,
        'runtime_jar':str(output/'runtime/glaive-corrected.jar'),'runtime_classes':str(output/'runtime/classes')}
    save(output/'protocol.json',protocol)
    (output/'PROTOCOL.sha256').write_text(digest(output/'protocol.json')+'  protocol.json\n',encoding='utf-8')
    return {'status':protocol['status'],'searches':1,'max_replays':2}


def replay(root, name, raw):
    problem=parse_sexpr((root/'original_problem.pddl').read_text(encoding='utf-8'))
    calls=[parse_sexpr(line.strip()) for line in raw.read_text(encoding='utf-8').splitlines() if line.strip().startswith('(')]
    folder=root/name;folder.mkdir();plan=folder/'plan.pddl'
    plan.write_text(serialize(['define',['plan',name],[':problem',section(problem,'problem')[1]],[':steps',*calls]]),encoding='utf-8')
    result=base.replay_checked(root/'runtime/glaive-corrected.jar',root/'runtime/classes',
        root/'original_domain.pddl',root/'original_problem.pddl',plan,folder/'replay',seconds=15)
    trace=trace_case(root/'original_domain.pddl',root/'original_problem.pddl',plan,base.read(root/'mapping.json'))
    pairs=independent_pairs(root/'original_domain.pddl',plan,trace) if trace['status']!='unknown' else []
    meets=(base.valid(result) and len(calls)>10 and trace.get('actual_source_count')==4
        and trace.get('goal_relevant_source_count')==4 and trace.get('all_steps_goal_relevant')
        and bool(trace.get('cross_source_edges')) and bool(pairs))
    return {'id':name,'steps':len(calls),'plan':str(plan),'replay':result,'causal':trace,
        'independent_pairs':pairs,'requirements_met':meets}


def execute(root):
    p=base.verify(root)
    if (root/'optimal/planner.log').exists():raise ValueError('Fresh execution required')
    with (root/'optimal/planner.log').open('w',encoding='utf-8') as f:
        result=subprocess.run(base.read(root/'command.json'),stdout=f,stderr=subprocess.STDOUT,timeout=90)
    rows=[];validation=None
    if (root/'optimal/plan.txt').exists():
        validation=validate_artifacts(root/'optimal')
        save(root/'optimal/physical_validation.json',validation)
        rows.append(replay(root,'optimal_candidate',root/'optimal/plan.txt'))
    rows.append(replay(root,'prior_lama_candidate',root/'prior_lama_plan.txt'))
    selected=next((r for r in rows if r['id']=='optimal_candidate' and r['requirements_met']),None)
    report={'status':'complete_optimal_long_case_validation','returncode':result.returncode,
        'physical_validation':validation,'rows':rows,'requirements_met':selected is not None,
        'selected':selected['id'] if selected else None,
        'inputs_unchanged':all(digest(Path(name))==h for name,h in p['input_sha256'].items()),
        'calls':{'search':1,'glaive_replay':len(rows),'new_model_calls':0},'scope':p['scope']}
    save(root/'report.json',report)
    return {'status':report['status'],'requirements_met':report['requirements_met'],
        'physical_validation':validation,'candidates':[{'id':r['id'],'steps':r['steps'],
        'intentional_status':r['replay']['status'],'valid':base.valid(r['replay']),
        'source_count':r['causal'].get('actual_source_count'),'requirements_met':r['requirements_met']} for r in rows]}


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('mode',choices=('prepare','execute'))
    parser.add_argument('--previous',type=Path);parser.add_argument('--output',required=True,type=Path)
    args=parser.parse_args()
    print(json.dumps(prepare(args.previous,args.output) if args.mode=='prepare' else execute(args.output),indent=2))

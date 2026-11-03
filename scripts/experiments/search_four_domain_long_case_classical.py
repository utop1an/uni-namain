"""Search unchanged physical rules, then validate in the original intentional model.

This is a separately labeled fallback after bounded Glaive search, not a
replacement primary experiment or a claim that intention annotations are free.
"""
import argparse
from pathlib import Path
import json
import shutil

from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.downward_planning import solve
from rcnc.pddl import parse_sexpr, section, serialize
from scripts.experiments import run_revised_multistory as base
from scripts.experiments.run_four_domain_long_case import trace_case, independent_pairs


def prepare(parent, output):
    if output.exists(): raise ValueError('Fresh output required')
    original = base.verify(parent)
    task = base.read(parent / 'tasks.json')['tasks'][0]
    output.mkdir(parents=True)
    for name, source in [('original_domain.pddl', task['domain']),
                         ('original_problem.pddl', task['problem']), ('mapping.json', task['mapping'])]:
        shutil.copy2(source, output / name)
    domain = parse_sexpr((output / 'original_domain.pddl').read_text(encoding='utf-8'))
    problem = parse_sexpr((output / 'original_problem.pddl').read_text(encoding='utf-8'))
    requirements = section(domain, ':requirements')
    requirements[:] = [x for x in requirements if x != ':intentionality']
    count = 0
    for action in domain:
        if not isinstance(action, list) or not action or action[0] != ':action': continue
        count += 1
        if ':agents' in action:
            i = action.index(':agents'); del action[i:i+2]
    init = section(problem, ':init')
    init[:] = [':init', *[f for f in init[1:] if f[0] != 'intends']]
    (output / 'physical_domain.pddl').write_text(serialize(domain), encoding='utf-8')
    (output / 'physical_problem.pddl').write_text(serialize(problem), encoding='utf-8')
    # Every parameter, precondition, and effect is inherited without repair.
    old_domain = parse_sexpr((output / 'original_domain.pddl').read_text(encoding='utf-8'))
    old_actions = {a[1]: a for a in old_domain if isinstance(a,list) and a and a[0]==':action'}
    for a in domain:
        if not isinstance(a,list) or not a or a[0]!=':action': continue
        before = dict(zip(old_actions[a[1]][2::2],old_actions[a[1]][3::2]))
        after = dict(zip(a[2::2],a[3::2]))
        assert all(before[k] == after[k] for k in (':parameters', ':precondition', ':effect'))
    save(output / 'projection_receipt.json', {'actions_retained':count,
        'preconditions_effects_parameters_unchanged':True,
        'only_dropped_for_search':[':intentionality',':agents','initial intends annotations'],
        'validation':'The found plan must validate against original_domain.pddl and original_problem.pddl, including Glaive intention checks.'})
    runtime = Path(original['runtime_jar']).parent
    shutil.copytree(runtime, output / 'runtime')
    dependencies=[Path(__file__),Path('scripts/experiments/run_four_domain_long_case.py'),
        Path('rcnc/downward_planning.py'),Path('scripts/experiments/run_downward_reference.py'),*base.IMPLEMENTATION]
    impl=snapshot_implementation(output,sorted({p.resolve() for p in dependencies},key=str))
    inputs={str(p):digest(p) for p in output.rglob('*') if p.is_file()}
    planner=Path('.tmp/fast-downward-26.6')
    for name in ['builds/release/bin/downward','fast-downward.py','driver/version.py']:
        p=planner/name;inputs[str(p)]=digest(p)
    protocol={'status':'frozen_before_classical_search_then_intentional_replay','created_utc':base.now(),
        'parent_case':str(parent),'scope':'One authored world; physical-search fallback with required original intentional replay. Original Glaive search failures retained separately.',
        'budgets':{'search_calls':1,'search_seconds':60,'replay_calls':1,'replay_seconds':15,
            'memory_mb':4096,'workers':1,'new_model_calls':0,'retry_calls':0},
        'planner':str(planner),'input_sha256':inputs,'implementation_sha256':impl,
        'runtime_jar':str(output/'runtime/glaive-corrected.jar'),'runtime_classes':str(output/'runtime/classes')}
    save(output/'protocol.json',protocol)
    (output/'PROTOCOL.sha256').write_text(digest(output/'protocol.json')+'  protocol.json\n',encoding='utf-8')
    return {'status':protocol['status'],'actions_retained':count,'new_model_calls':0}


def execute(root):
    p=base.verify(root)
    if (root/'report.json').exists() or (root/'solver').exists():raise ValueError('Fresh execution required')
    result=solve(root/'physical_domain.pddl',root/'physical_problem.pddl',root/'solver',Path(p['planner']),seconds=60,memory_mb=4096)
    row={'status':'complete_classical_search_intentional_validation','search':result,'new_model_calls':0,'requirements_met':False}
    if result['status']=='solved':
        text=(root/'solver/plan.txt').read_text(encoding='utf-8')
        calls=[parse_sexpr(line.strip()) for line in text.splitlines() if line.strip().startswith('(')]
        problem=parse_sexpr((root/'original_problem.pddl').read_text(encoding='utf-8'))
        plan=root/'plan.pddl'
        plan.write_text(serialize(['define',['plan','physical_search_candidate'],
            [':problem',section(problem,'problem')[1]],[':steps',*calls]]),encoding='utf-8')
        row['replay']=base.replay_checked(Path(p['runtime_jar']),Path(p['runtime_classes']),
            root/'original_domain.pddl',root/'original_problem.pddl',plan,root/'intentional_replay',seconds=15)
        row['valid_plan']=base.valid(row['replay'])
        row['causal']=trace_case(root/'original_domain.pddl',root/'original_problem.pddl',plan,base.read(root/'mapping.json'))
        if row['causal']['status']!='unknown':
            row['independent_pairs']=independent_pairs(root/'original_domain.pddl',plan,row['causal'])
        t=row['causal']
        row['requirements_met']=(row['valid_plan'] and len(calls)>=11 and t.get('actual_source_count')==4
            and t.get('goal_relevant_source_count')==4 and t.get('all_steps_goal_relevant')
            and bool(t.get('cross_source_edges')) and bool(row.get('independent_pairs')))
    row['inputs_unchanged']=all(digest(Path(name))==h for name,h in p['input_sha256'].items())
    save(root/'report.json',row)
    return {k:v for k,v in row.items() if k not in ('causal','independent_pairs')}


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode',choices=('prepare','execute'))
    parser.add_argument('--parent',type=Path)
    parser.add_argument('--output',required=True,type=Path)
    args=parser.parse_args()
    print(json.dumps(prepare(args.parent,args.output) if args.mode=='prepare' else execute(args.output),indent=2))

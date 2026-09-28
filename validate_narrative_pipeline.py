"""Read-only production audit plus isolated deterministic fusion smoke validation.

This does not implement narrative selection/fusion or rerun the LLM baseline.
"""
import argparse
from collections import deque, defaultdict
import hashlib
import json
from pathlib import Path
from unittest.mock import patch

from merge_domains import (parse_domain, parse_sexpr, merge_domains, write_domain,
                           rewrite_problem, domain_summary)
from rcnc.planning import run_query
from rcnc.validation import validate_artifacts
from rcnc.selection import audit_action

ROOT = Path(__file__).resolve().parent


def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def parse_check(domain, problem):
    from unified_planning.io import PDDLReader
    try:
        p = PDDLReader().parse_problem(str(domain), str(problem))
        return {'status': 'PASS', 'actions': len(p.actions)}
    except Exception as exc:
        return {'status': 'FAIL', 'error': f'{type(exc).__name__}: {exc}'}


def artifact_audit(output):
    directory = ROOT/'data/merged_strict'
    meta = json.loads((directory/'meta_domain.json').read_text(encoding='utf-8'))
    domain = parse_domain(directory/'meta_domain.pddl', apply_reviewed_semantics=False)
    domain.predicate_maps = meta['predicate_maps']
    domain.constant_maps = meta['constant_maps']
    domain.action_maps = meta['action_maps']
    rows = []
    symbols = defaultdict(list)
    for category in ('constants', 'predicates', 'actions'):
        for name in getattr(domain, category):
            symbols[name.lower()].append({'category':category,'name':name})
    collisions = {key:values for key,values in symbols.items() if len(values)>1}
    action_audit = [{'action':name,'reasons':audit_action(domain,action)}
                    for name,action in domain.actions.items() if audit_action(domain,action)]
    regressions = []
    for source in meta['sources']:
        original = ROOT/'data/narra-domains'/f'{source}_domainfile.pddl'
        original_problem = original.with_name(f'{source}_problemfile.pddl')
        src = parse_domain(original, apply_reviewed_semantics=False)
        issues = []
        for name,target in meta['action_maps'][source].items():
            if target in domain.actions and name in src.actions:
                errors = [e for e in audit_action(domain,domain.actions[target]) if not e.startswith('unsupported_logic:')]
                if errors:
                    regressions.append({'source_action':source+':'+name,'merged_action':target,
                                        'source_audit':audit_action(src,src.actions[name]),'merged_errors':errors})
        for category in ('predicate', 'constant', 'action'):
            table = meta[category+'_maps'][source]
            source_names = getattr(src, category+'s')
            target_names = getattr(domain, category+'s')
            if set(table) != set(source_names):
                issues.append(category+': source coverage differs')
            issues.extend(category+': absent target '+target for target in table.values() if target not in target_names)
        rewritten = output/'rewritten_problems'/original_problem.name
        rewrite_problem(original_problem, domain, rewritten)
        existing = directory/'problems'/original_problem.name
        same = parse_sexpr(rewritten.read_text(encoding='utf-8')) == parse_sexpr(existing.read_text(encoding='utf-8'))
        rows.append({'source': source, 'mapping_issues': issues, 'rewritten_problem_matches_snapshot': same,
                     'original_parse': parse_check(original, original_problem),
                     'merged_parse': parse_check(directory/'meta_domain.pddl', existing)})
    return {'scope': 'Existing historical artifact; no fresh LLM inference or semantic preservation proof',
            'snapshot_sha256': {p.name: digest(p) for p in directory.glob('*.json')},
            'domain_sha256': digest(directory/'meta_domain.pddl'), 'rows': rows,
            'case_insensitive_collisions':collisions, 'action_audit':action_audit,
            'source_to_merged_regressions':regressions}


def bounded_plan(domain, problem_path, directory, max_states=1000, max_depth=8):
    from unified_planning.io import PDDLReader, PDDLWriter
    from unified_planning.shortcuts import SequentialSimulator
    from unified_planning.plans import ActionInstance, SequentialPlan
    problem = PDDLReader().parse_problem(str(domain), str(problem_path))
    directory.mkdir(parents=True, exist_ok=True)
    (directory/'domain.pddl').write_bytes(domain.read_bytes())
    (directory/'problem.pddl').write_bytes(problem_path.read_bytes())
    with SequentialSimulator(problem) as simulator:
        start = simulator.get_initial_state()
        queue = deque([(start, [])]); visited = {start}; cutoff = False
        while queue:
            state, steps = queue.popleft()
            if simulator.is_goal(state):
                plan = SequentialPlan(steps)
                PDDLWriter(problem).write_plan(plan, str(directory/'plan.txt'))
                return {'status': 'solved', 'length': len(steps), 'plan': str(plan),
                        'validation': validate_artifacts(directory), 'states': len(visited)}
            if len(steps) >= max_depth:
                cutoff = True; continue
            for action, params in simulator.get_applicable_actions(state):
                after = simulator.apply(state, action, params)
                if after not in visited:
                    if len(visited) >= max_states:
                        return {'status': 'state_limit'}
                    visited.add(after)
                    queue.append((after, steps+[ActionInstance(action, params)]))
    return {'status': 'depth_limit' if cutoff else 'unsolvable', 'states': len(visited)}


def fusion_smoke(output):
    directory = output/'fusion_smoke'; inputs = directory/'input'; inputs.mkdir(parents=True)
    source_texts = {
        'HEAR': '''(define (domain hear) (:requirements :strips :typing) (:types person - object)
          (:predicates (messenger_present ?p - person) (rumor_known ?p - person))
          (:action hear_report :parameters (?p - person) :precondition (messenger_present ?p)
           :effect (rumor_known ?p)))''',
        'WARN': '''(define (domain warn) (:requirements :strips :typing) (:types person - object)
          (:predicates (rumor_known ?p - person) (warning_delivered ?p - person))
          (:action warn_village :parameters (?p - person) :precondition (rumor_known ?p)
           :effect (warning_delivered ?p)))'''}
    def problem(name, domain, initial, goal, person='hero'):
        return f'(define (problem {name}) (:domain {domain}) (:objects {person} - person) (:init {initial}) (:goal {goal}))'
    for source, text in source_texts.items():
        (inputs/f'{source}_domainfile.pddl').write_text(text, encoding='utf-8')
    (inputs/'HEAR_problemfile.pddl').write_text(problem('hear-original','hear','(messenger_present hero)','(rumor_known hero)'),encoding='utf-8')
    (inputs/'WARN_problemfile.pddl').write_text(problem('warn-original','warn','(rumor_known hero)','(warning_delivered hero)'),encoding='utf-8')
    merged = merge_domains(*(parse_domain(inputs/f'{s}_domainfile.pddl', apply_reviewed_semantics=False) for s in source_texts))
    merged_path = directory/'meta_domain.pddl'
    write_domain(merged, merged_path)  # Must exist before the first planning call.
    original_hash = digest(merged_path)
    save(directory/'mappings.json', domain_summary(merged))
    rows = []
    for source in source_texts:
        original = inputs/f'{source}_problemfile.pddl'
        mapped = directory/f'{source}_mapped_problem.pddl'
        rewrite_problem(original, merged, mapped)
        source_result = bounded_plan(inputs/f'{source}_domainfile.pddl',original,directory/(source+'_source'))
        merged_result = bounded_plan(merged_path,mapped,directory/(source+'_mapped'))
        rows.append({'case': source, 'source':source_result, 'mapped':merged_result})
    for name,person,initial in [('cross_source','hero','(messenger_present hero)'),
                                ('second_object','helper','(messenger_present helper)'),
                                ('missing_initial_fact','hero','')]:
        p=directory/f'{name}_problem.pddl'
        p.write_text(problem(name,merged.name,initial,f'(warning_delivered {person})',person),encoding='utf-8')
        rows.append({'case':name,'result':bounded_plan(merged_path,p,directory/name)})
    return {'scope':'Synthetic wiring test of existing deterministic same-name merger, not learned-domain or LLM evidence',
            'merged_before_planning':True,'merged_domain_unchanged':digest(merged_path)==original_hash,
            'domain_sha256':original_hash,'rows':rows}


def request_contract(output):
    query=json.loads((ROOT/'data/rcnc/queries/source_pool_smoke.json').read_text(encoding='utf-8'))
    rows=[]
    for case,key in [('goal_only','initial'),('initial_only','goal')]:
        q=dict(query);q.pop(key,None)
        with patch('rcnc.planning.solve', side_effect=AssertionError('Incomplete query reached planner')) as solver:
            result=run_query(q,ROOT/'data/narra-domains',output/case)
        rows.append({'case':case,'status':result['status'],'reason':result.get('reason'),
                     'planner_called':solver.called})
    return rows


def run(output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty validation directory')
    output.mkdir(parents=True,exist_ok=True)
    report={'scope':'Validation of current components against corrected pipeline; no production algorithm edits',
            'implementation_sha256':{str(p.relative_to(ROOT)):digest(p) for p in
                [Path(__file__),ROOT/'merge_domains.py',ROOT/'unidomain_ollama_fusion.py',
                 ROOT/'rcnc/planning.py',ROOT/'rcnc/validation.py']}}
    for label,fn in [('historical_fusion',artifact_audit),('fusion_smoke',fusion_smoke),('request_contract',request_contract)]:
        try:
            report[label]=fn(output)
        except Exception as exc:
            report[label]={'status':'ERROR','error':f'{type(exc).__name__}: {exc}'}
        save(output/'report.json',report)
    historical=report.get('historical_fusion',{}); smoke=report.get('fusion_smoke',{})
    hs=historical.get('rows',[]); ss=smoke.get('rows',[])
    checks={
        'source_problem_parsing': bool(hs) and all(r['original_parse']['status']=='PASS' for r in hs),
        'source_mapping_coverage': bool(hs) and all(not r['mapping_issues'] for r in hs),
        'problem_rewrite_reproduction': bool(hs) and all(r['rewritten_problem_matches_snapshot'] for r in hs),
        'historical_merged_problem_parsing': bool(hs) and all(r['merged_parse']['status']=='PASS' for r in hs),
        'historical_supported_action_structure': 'source_to_merged_regressions' in historical and not historical['source_to_merged_regressions'],
        'synthetic_merged_domain_preexists_and_unchanged': smoke.get('merged_before_planning',False) and smoke.get('merged_domain_unchanged',False),
        'synthetic_source_regressions': len(ss)==5 and all(r[k]['status']=='solved' and r[k]['validation']['status']=='VALID' for r in ss[:2] for k in ('source','mapped')),
        'synthetic_cross_source_plans': len(ss)==5 and all(r['result']['status']=='solved' and r['result']['length']==2 and r['result']['validation']['status']=='VALID' for r in ss[2:4]),
        'synthetic_missing_fact_control': len(ss)==5 and ss[-1]['result']['status']=='unsolvable'}
    contract=report.get('request_contract',[])
    if not isinstance(contract,list):contract=[]
    checks['incomplete_requests_do_not_plan']=len(contract)==2 and all(not r['planner_called'] for r in contract)
    checks['goal_only_user_request_status']=any(r['case']=='goal_only' and r['status']=='needs_initial_state' for r in contract)
    checks['initial_only_mode_available']=any(r['case']=='initial_only' and r['status'] not in ('rejected','failed') for r in contract)
    report['acceptance']={'status':'PASS' if all(checks.values()) else 'NOT_READY', 'checks':checks,
                          'note':'Even a passing smoke test is not an evaluation of narrative quality or automatic domain selection.'}
    save(output/'report.json',report)
    print(json.dumps(report['acceptance'],indent=2))
    return report

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,required=True)
    args=p.parse_args();result=run(args.output)
    raise SystemExit(0 if result['acceptance']['status']=='PASS' else 1)

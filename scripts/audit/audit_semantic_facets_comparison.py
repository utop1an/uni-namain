"""Verify fixed inputs, raw-model provenance, real merges and SOUP branch replay."""
import argparse
import json
from pathlib import Path

from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.model_semantics import validate, to_group
from rcnc.model_semantics_facets import normalize as normalize_facets
from rcnc.model_semantics_schema import normalize as normalize_coupled
from rcnc.validation import validate_artifacts
from scripts.audit.audit_conditional_merge import state_replay
from scripts.experiments.run_union_regression import translate_plan


def read(p):return json.loads(p.read_text(encoding='utf-8'))


def verify_model(root):
    folder=root/'judgments';manifest=read(folder/'manifest.json');report=read(folder/'report.json')
    if report['manifest_sha256']!=digest(folder/'manifest.json'):raise ValueError('Model manifest changed')
    for key in ('inputs_unchanged','implementation_unchanged'):
        if report[key] is not True:raise ValueError('Model integrity failed')
    for p,h in manifest['implementation_sha256'].items():
        if digest(folder/'implementation'/p)!=h:raise ValueError('Frozen model code changed')
    if digest(folder/'requests.json')!=manifest['requests_sha256']:raise ValueError('Requests changed')
    if digest(folder/'packet.json')!=manifest['packet_sha256']:raise ValueError('Context packet changed')
    packet=read(folder/'packet.json')['items'];groups=read(folder/'groups.json')['groups']
    if len(report['rows'])!=len(packet) or len(groups)!=len(packet):raise ValueError('Judgment denominator changed')
    for item,row,group in zip(packet,report['rows'],groups):
        if row['id']!=item['id'] or to_group(item,row)!=group:raise ValueError('Judgment/group identity mismatch')
        if row['status']=='checked':
            raw=read(folder/'responses'/item['id']/'raw.json')
            if not raw.get('done') or raw.get('done_reason')=='length':raise ValueError('Incomplete checked response')
            response=json.loads(raw['message']['content'])
            if manifest['schema_policy'] in ('semantic_facets','semantic_facets_optional_roles'):
                if response!=row['semantic_facets']:raise ValueError('Facet record differs from raw output')
                response=normalize_facets(item,response)
            elif manifest['schema_policy']=='compact_kind_specific':
                from rcnc.model_semantics_compact import normalize
                if response!=row['compact_judgment']:raise ValueError('Compact record differs from raw output')
                response=normalize(item,response)
            elif manifest['schema_policy']=='coupled_fields':response=normalize_coupled(response)
            validate(item,response)
            if response!=row['response']:raise ValueError('Checked response differs from raw model output')
    return report


def audit(roots, audit_paths, output):
    if len(roots)!=len(audit_paths):raise ValueError('One completed planning audit per condition required')
    require_empty_output(output);output.mkdir(parents=True)
    impl=snapshot_implementation(output,[Path(__file__)])
    packets=[read(r/'judgments/packet.json') for r in roots]
    if not all(p==packets[0] for p in packets):raise ValueError('Candidate contexts differ')
    protocols=[read(r/'protocol.json') for r in roots]
    keys=['bundles','pairs','queries','native_conditions','witness_goals','budget','semantic_threshold','semantic_trap']
    if not all(all(p[k]==protocols[0][k] for k in keys) for p in protocols):raise ValueError('Frozen tasks/worlds differ')
    source_hashes=[{p.name:digest(p) for p in (r/'inputs').iterdir()} for r in roots]
    if not all(h==source_hashes[0] for h in source_hashes):raise ValueError('Source bytes differ')
    reports=[read(r/'report.json') for r in roots]
    ids=[[r['id'] for r in report['rows']] for report in reports]
    if not all(i==ids[0] and len(i)==72 for i in ids):raise ValueError('Solver task identities differ')
    witness=Path('data/validation/conditional_merge_branch_witness_2026_10_27_v1/native')
    if validate_artifacts(witness)['status']!='VALID':raise ValueError('SOUP source witness invalid')
    rows=[];pins={}
    for root,audit_path,solver in zip(roots,audit_paths,reports):
        model=verify_model(root);execution=read(audit_path)
        if execution['status']!='PASS' or not execution['integrity_verified']:raise ValueError('Planning/replay audit failed')
        for p in [root/'manifest.json',root/'report.json',root/'judgments/manifest.json',root/'judgments/report.json',audit_path]:
            pins[p.as_posix()]=digest(p)
        decisions=[d for merge in execution['merges'] for d in merge['decisions']]
        full=root/'models/anchor/model_full'
        if digest(witness/'domain.pddl')!=digest(root/'inputs/SOUP_domainfile.pddl'):raise ValueError('SOUP witness source differs')
        if digest(witness/'problem.pddl')!=digest(root/'inputs/SOUP_problemfile.pddl'):raise ValueError('SOUP witness original world differs')
        destination=output/'branch_replays'/root.name
        translated=translate_plan('SOUP',root/'inputs',full,witness,destination)
        if translated['validation']['status']!='VALID':raise ValueError('SOUP branch transport failed')
        branch=state_replay('SOUP',root/'inputs',full,witness,destination)
        if branch['status']!='PASS':raise ValueError('SOUP branch state replay failed')
        mapping=read(full/'meta_domain.json')['action_maps']
        merged_travel=mapping['SOUP']['travel_to']==mapping['BIRT']['travel_to_trysting_place']
        rows.append({'id':root.name,'status':'verified','run':root.as_posix(),
            'model':read(root/'judgments/manifest.json')['model'],
            'model_requests':model['requests_attempted'],'model_status_counts':model['status_counts'],
            'model_decision_counts':model['decision_counts'],'planner_calls':solver['actual_solver_calls'],
            'solver_status_counts':solver['status_counts'],
            'predicate_reduction':sum(m['source_predicates']-m['logical_predicates'] for m in execution['merges']),
            'action_reduction':sum(m['source_actions']-m['actions'] for m in execution['merges']),
            'accepted_action_groups':[d['id'] for d in decisions if d['kind']=='action' and d['status']=='accepted'],
            'focus_decisions':[d for d in decisions if d['id'] in ('anchor_state_bad_alias','anchor_travel')],
            'merged_travel':merged_travel,'soup_branch_replay':branch,
            'soup_witness_uses_merged_action':merged_travel and mapping['SOUP']['travel_to'] in (destination/'plan.txt').read_text(encoding='utf-8'),
            'replay_by_unit':execution['replay_by_unit'],'replayed_steps':execution['replayed_steps'],
            'truth_checks':execution['truth_checks'],'cross_source_benefit_count':execution['cross_source_benefit_count'],
            'cross_source_task_count':len(execution['cross_source']),'semantic_controls':execution['semantic_controls'],
            'merged_action_cross_plans':[c['id'] for c in execution['cross_source'] if c['uses_merged_action']]})
    for p in witness.iterdir():pins[p.as_posix()]=digest(p)
    report={'status':'verified_comparison','inputs_matched':True,'raw_predictions_verified':True,
        'condition_count':len(rows),'rows':rows,'status_counts':{'verified':len(rows)},
        'model_calls':sum(r['model_requests'] for r in rows),'planner_calls':sum(r['planner_calls'] for r in rows),
        'candidate_count_per_condition':16,'task_count_per_condition':72,
        'input_sha256':pins,'implementation_sha256':impl,'fresh_planner_calls_in_audit':0,
        'branch_witness_scope':'The same existing 3-step SOUP witness is reused once per model-full condition; not new original-goal solutions.',
        'scope':'Sequential adaptive development conditions on fixed source bytes, contexts and tasks. Different model/prompt/format/token conditions, not independent samples or isolated causal effects. Independent semantic labels remain absent.'}
    save(output/'report.json',report)
    return report


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--roots',nargs='+',type=Path,required=True)
    p.add_argument('--audits',nargs='+',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();r=audit(a.roots,a.audits,a.output)
    print(json.dumps({k:r[k] for k in ['status','condition_count','model_calls','planner_calls']},indent=2))

"""Offline posthoc analysis of the frozen GPT-4 revised experiment.

Reads saved artifacts only. Does not call a model, planner or replay engine.
The output is descriptive: repeated source/pair rows are not independent samples.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import statistics

from rcnc.domain_building import digest, save
from rcnc.glaive_merge import Source, action_fields, canonical, rename_vars, rewrite, signed_effects
from rcnc.model_semantics import validate
from rcnc.model_semantics_compact import normalize
from rcnc.pddl import parse_sexpr, section, serialize, typed_symbols


def read(path): return json.loads(path.read_text(encoding='utf-8'))


def plan_steps(path):
    root = parse_sexpr(path.read_text(encoding='utf-8'))
    steps = section(root, ':steps')
    if steps is None: raise ValueError('Missing plan steps: ' + str(path))
    return steps[1:]


def ground_stats(path):
    text = path.read_text(encoding='utf-8', errors='replace')
    match = re.search(r'\[State Space: (\d+) literals, (\d+) steps, (\d+) axioms\]', text)
    return None if match is None else dict(zip(('literals','steps','axioms'), map(int,match.groups())))


def invalid_category(reason):
    if reason == 'Citation must belong to its own source side': return 'citation_mismatch'
    if reason == 'Incomplete or truncated generation': return 'incomplete_or_truncated'
    if reason.startswith(('Expecting ', 'Extra data:', 'Unterminated ')): return 'json_parse_error'
    return reason


def passed(row):
    return row.get('status') == 'replayed' and row.get('goal') is True and row.get('unexplained_steps') == 0


def analyze(root, output):
    if output.exists(): raise ValueError('Fresh analysis directory required')
    protocol, compilation, report, judgments, coordinator = [read(root/name) for name in (
        'protocol.json','compilation.json','report.json','judgments/report.json','coordinator.json')]
    if any(x['status'] != 'complete' for x in (report,judgments,coordinator)):
        raise ValueError('Only completed runs can be summarized')
    checked_hashes = {**protocol['input_sha256'],**protocol['implementation_sha256'],**compilation['input_sha256']}
    changed = [p for p,h in checked_hashes.items() if digest(Path(p)) != h]
    if changed: raise ValueError('Frozen input changed: ' + repr(changed))
    if digest(root/'judgments/groups.json') != compilation['groups_sha256']: raise ValueError('Changed groups')
    if digest(root/'judgments/report.json') != compilation['judgment_report_sha256']: raise ValueError('Changed judgments')
    packet = {x['id']:x for x in read(root/'judgments/packet.json')['items']}
    groups = {x['id']:x for x in read(root/'judgments/groups.json')['groups']}
    predictions = {x['id']:x for x in judgments['rows']}
    # Revalidate saved output contracts, not semantic correctness.
    for row in judgments['rows']:
        if row['status'] != 'checked': continue
        raw = read(root/'judgments/responses'/row['id']/'raw.json')
        normalized = normalize(packet[row['id']], json.loads(raw['message']['content']))
        validate(packet[row['id']],normalized)
        if normalized != row['response']: raise ValueError('Saved prediction differs from raw output')
    full_models = [m for m in compilation['models'] if m['condition']=='full']
    models = {(m['pair'],m['condition']):m for m in compilation['models']}
    index = {(r['pair'],r['source'],r['condition']):r for r in report['rows']}
    if len(index)!=360 or len(predictions)!=615 or len(full_models)!=60:
        raise ValueError('Unexpected registered denominator')
    for m in full_models:
        if m['predicate_maps'] != models[m['pair'],'predicate_only']['predicate_maps']:
            raise ValueError('Unmatched predicate maps')
    sources = {}
    for m in full_models:
        for sid in m['source_sha256']:
            if sid not in sources:
                inv = read(root/'execution/native'/sid/'invocation.json')
                files = list(inv['input_sha256'])
                d = next(Path(p) for p in files if p.endswith('revised-domain.pddl'))
                p = next(Path(p) for p in files if p.endswith('revised-problem.pddl'))
                sources[sid] = Source(sid,d,p)
    action_groups, all_branches = [], []
    for m in full_models:
        for decision in m['decisions']:
            if decision['kind']!='action' or decision['status']!='accepted': continue
            gid=decision['id']; group=groups[gid]; preconditions=[]; effects=[]; agents=[]; branches=[]
            for member in group['members']:
                sid,name=member['action'].split(':'); source=sources[sid]
                fields=action_fields(source.domain.actions[name]); variables=list(typed_symbols(fields[':parameters']))
                vm={variables[j]:'?m'+str(i) for i,j in enumerate(member['order'])}
                pre=rename_vars(rewrite(fields[':precondition'],source,m['predicate_maps'][sid],source.term_map),vm)
                eff=rename_vars(rewrite(fields[':effect'],source,m['predicate_maps'][sid],source.term_map),vm)
                acts=rename_vars([source.term_map.get(a,a) for a in fields[':agents']],vm)
                preconditions.append(pre); effects.append(signed_effects(eff)); agents.append(set(acts))
                row=index[m['pair'],sid,'full']; transported=[]; fresh=[]
                if row['transport']['status']=='replayed':
                    transported=plan_steps(root/'execution'/m['pair']/'full'/sid/'transport.pddl')
                if row['search']['status']=='solved':
                    fresh=plan_steps(root/'execution'/m['pair']/'full'/sid/'search/plan.pddl')
                n=sum(s[0]=='fused_'+gid for s in transported)
                n_fresh=sum(s[0]=='fused_'+gid for s in fresh)
                branch={'reference':member['action'],'pair':m['pair'],'group':gid,
                    'native_plan_available':row['transport']['status']=='replayed', 'transport_passed':passed(row['transport']),
                    'fused_steps_in_transport':n,'fused_steps_in_fresh_plan':n_fresh,
                    'source_precondition':serialize(fields[':precondition']), 'canonical_mapped_precondition':serialize(pre),
                    'role_permutation':member['order']}
                branches.append(branch); all_branches.append(branch)
            if any(x!=effects[0] for x in effects) or any(x!=agents[0] for x in agents):
                raise ValueError('Action certificate no longer holds')
            action_groups.append({'pair':m['pair'],'stratum':m['stratum'],'group':gid,
                'confidence':predictions[gid]['response']['confidence'],
                'same_action_name':len({b['reference'].split(':')[1] for b in branches})==1,
                'identical_mapped_business_preconditions':all(canonical(x)==canonical(preconditions[0]) for x in preconditions),
                'transport_branches_exercised':sum(b['fused_steps_in_transport']>0 for b in branches),
                'fresh_branches_exercised':sum(b['fused_steps_in_fresh_plan']>0 for b in branches),
                'branches':branches,'mapped_signed_effects_and_agent_roles_equal':True})
    actual={m['pair'] for m in full_models if m['action_count']<m['source_action_count']}
    strata={}
    for scope in ('all','random','opportunity','actual_action_merge'):
        ms=[m for m in full_models if scope=='all' or (scope=='actual_action_merge' and m['pair'] in actual) or m['stratum']==scope]
        ids={m['pair'] for m in ms}; rs=[x for x in report['rows'] if x['pair'] in ids]
        before=sum(m['source_action_count'] for m in ms); after=sum(m['action_count'] for m in ms)
        pb=sum(models[m['pair'],'union']['business_predicate_count'] for m in ms); pa=sum(m['business_predicate_count'] for m in ms)
        data={'pairs':len(ms),'unique_stories':len({sid for m in ms for sid in m['source_sha256']}),
            'pairs_with_action_merge':sum(m['pair'] in actual for m in ms),
            'action_schemas_before':before,'action_schemas_after':after,'action_reduction':(before-after)/before,
            'business_predicates_before':pb,'business_predicates_after':pa,
            'predicate_merge_groups':sum(d['kind']=='predicate' and d['status']=='accepted' for m in ms for d in m['decisions']),
            'action_merge_groups':sum(d['kind']=='action' and d['status']=='accepted' for m in ms for d in m['decisions']),
            'conditions':{}}
        for cond in ('union','predicate_only','full'):
            rows=[x for x in rs if x['condition']==cond]; solved=[x for x in rows if x['search']['status']=='solved']
            grounding=[ground_stats(root/'execution'/x['pair']/cond/x['source']/'search/stdout.txt') for x in rows]
            if any(x is None for x in grounding): raise ValueError('Missing grounding log')
            data['conditions'][cond]={'tasks':len(rows),'status_counts':dict(Counter(x['search']['status'] for x in rows)),
                'transport_passed':sum(passed(x['transport']) for x in rows),
                'transport_unavailable':sum(x['transport']['status']=='unavailable_native_plan' for x in rows),
                'grounded_steps_sum':sum(x['steps'] for x in grounding),'literals_sum':sum(x['literals'] for x in grounding),
                'total_search_process_seconds':sum(x['search']['seconds'] for x in rows),
                'solved_process_seconds_median':statistics.median(x['search']['seconds'] for x in solved),
                'solved_visited_nodes_sum':sum(x['search'].get('visited',0) for x in solved)}
        strata[scope]=data
    changes=[]
    for row in report['rows']:
        if row['condition']!='full':continue
        other=index[row['pair'],row['source'],'predicate_only']
        if other['search']['status']!=row['search']['status']:
            changes.append({'pair':row['pair'],'source':row['source'],'predicate_only':other['search']['status'],
                'full':row['search']['status'],'predicate_only_seconds':other['search']['seconds'],'full_seconds':row['search']['seconds']})
    judgment_stats={}
    for kind in ('predicate','action'):
        rows=[x for x in judgments['rows'] if x['kind']==kind]
        compatible=[x for x in rows if x.get('response',{}).get('decision')=='compatible']
        judgment_stats[kind]={'candidates':len(rows),'decisions':dict(Counter(x.get('response',{}).get('decision',x['status']) for x in rows)),
            'invalid_categories':dict(Counter(invalid_category(x['reason']) for x in rows if x['status']=='invalid')),
            'compatible_below_threshold':sum(x['response']['confidence']<.9 for x in compatible),
            'compatible_at_threshold':sum(x['response']['confidence']>=.9 for x in compatible)}
    all_transports=[x for x in report['rows'] if x['transport']['status']=='replayed']
    if not all(passed(x['transport']) for x in all_transports): raise ValueError('Observed transport failure')
    for row in report['rows']:
        if row['search']['status']=='solved' and not passed(row.get('replay',{})):
            raise ValueError('Returned merged plan failed saved replay')
    native=report['native']; solved_native=[(sid,x) for sid,x in native.items() if x['status']=='solved']
    replayed_native=[(sid,x) for sid,x in solved_native if passed(x.get('replay',{}))]
    native_exceptions=[{'source':sid,'replay_status':x.get('replay',{}).get('status')} for sid,x in solved_native if not passed(x.get('replay',{}))]
    found_sets=[{(x['pair'],x['source']) for x in report['rows'] if x['condition']==c and x['search']['status']=='solved'} for c in ('union','predicate_only','full')]
    summary={'status':'offline_analysis_complete','created_utc':datetime.now(timezone.utc).isoformat(),
        'new_model_calls':0,'new_planner_calls':0,'new_replay_calls':0,'source_run':str(root.resolve()),
        'verified_frozen_hash_count':len(checked_hashes),'saved_model_output_contracts_revalidated':sum(x['status']=='checked' for x in judgments['rows']),
        'registered_denominators':{'test_stories':len(protocol['rows']),'compiler_admitted_stories':sum(x.get('adapter')=='compiled' for x in protocol['rows']),
            'selected_unique_stories':len(sources),'pairs':len(full_models),'native_search_attempts':sum(x.get('search_calls',0) for x in native.values()),
            'paired_search_attempts':len(report['rows']),'original_transports_total':len(report['rows']),
            'original_transports_passed':len(all_transports),'original_transports_unavailable':len(report['rows'])-len(all_transports),
            'distinct_transported_stories':len({x['source'] for x in all_transports})},
        'native':{'status_counts':report['native_counts'],'solver_reported_solutions':len(solved_native),'saved_replay_passed':len(replayed_native),
            'zero_step_solutions':sum(x['replay']['steps']==0 for _,x in replayed_native),'replay_exceptions':native_exceptions},
        'strata':strata,'judgments':judgment_stats,'actual_action_groups':action_groups,
        'action_group_summary':{'groups':len(action_groups),'same_name':sum(x['same_action_name'] for x in action_groups),
            'identical_mapped_business_preconditions':sum(x['identical_mapped_business_preconditions'] for x in action_groups),
            'transport_coverage_histogram':dict(Counter(x['transport_branches_exercised'] for x in action_groups)),
            'fresh_plan_coverage_histogram':dict(Counter(x['fresh_branches_exercised'] for x in action_groups)),
            'source_branches_total':len(all_branches),'source_branches_with_native_plan':sum(x['native_plan_available'] for x in all_branches),
            'source_branches_exercised_by_transport':sum(x['fused_steps_in_transport']>0 for x in all_branches),
            'fused_transition_occurrences_in_transport':sum(x['fused_steps_in_transport'] for x in all_branches)},
        'solved_slot_sets_identical':all(x==found_sets[0] for x in found_sets),'status_changes_full_vs_predicate_only':changes,
        'action_rejections':dict(Counter(d.get('reason','unspecified') for m in full_models for d in m['decisions'] if d['kind']=='action' and d['status']!='accepted')),
        'limitations':['Source/pair and condition repetitions are correlated, not independent stories.',
            'Only one source is active in each task; no cross-source composition worlds were tested.',
            'Semantic judgments are automatic hypotheses; independent semantic and narrative labels remain zero.',
            'Replay uses the same pinned Glaive semantics; it is a separate execution path, not an independent validator.',
            'Mapped business-precondition comparison excludes guards and checks syntax modulo conjunction/disjunction order, not arbitrary logical equivalence.',
            'Timing is a single run with startup overhead; no speedup or significance claim.',
            'Compression sums count schema/grounded-step occurrences over pair models/tasks, not globally unique actions.',
            'No-solution-returned is not promoted to a proof of unsolvability.'],
        'source_artifact_sha256':{name:digest(root/name) for name in ('protocol.json','compilation.json','report.json','coordinator.json','judgments/report.json','judgments/packet.json','judgments/groups.json')},
        'analysis_script_sha256':digest(Path(__file__))}
    output.mkdir(parents=True); save(output/'analysis.json',summary)
    print(json.dumps({k:summary[k] for k in ('status','registered_denominators','action_group_summary','solved_slot_sets_identical')},indent=2))


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--run',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();analyze(a.run,a.output)

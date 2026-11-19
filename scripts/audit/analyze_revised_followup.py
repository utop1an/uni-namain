"""Combine preserved runtime comparison, branch checks and composition controls."""
import argparse
from collections import Counter
import json
from pathlib import Path

from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.saved_plan_validation import replay_saved

PARENT=Path('data/validation/revised_followup_2026_11_01_v1')
FIXED=Path('data/validation/revised_followup_corrected_2026_11_01_v1')
RUNTIME=Path('data/validation/glaive_runtime_correction_2026_11_01_v5')
MAIN_AUDIT=Path('data/validation/revised_main_physical_audit_2026_11_01_v2/report.json')


def read(p):return json.loads(p.read_text(encoding='utf-8'))


def analyze(output):
    if output.exists():raise ValueError('Fresh analysis required')
    original=read(PARENT/'report.json');fixed=read(FIXED/'report.json');protocol=read(FIXED/'protocol.json')
    coordinator=read(FIXED/'coordinator.json');receipt=read(FIXED/'runtime_receipt.json')
    if fixed['status']!='complete' or coordinator['status']!='complete' or receipt['status']!='verified':
        raise ValueError('Execution has not completed successfully')
    hashes={**protocol['input_sha256'],**protocol['implementation_sha256']}
    inputs=[PARENT/'report.json',FIXED/'report.json',FIXED/'protocol.json',FIXED/'coordinator.json',FIXED/'runtime_receipt.json',RUNTIME/'report.json',MAIN_AUDIT]
    hashes.update({str(p):digest(p) for p in inputs})
    if not all(digest(Path(p))==h for p,h in hashes.items()):raise ValueError('Changed frozen inputs')
    branch_physical=[]
    for row in fixed['branch_rows']:
        physical=replay_saved(Path(row['domain']),Path(row['problem']),Path(row['plan']))
        passed=(physical['status']=='replayed' and physical['goal'] and physical['steps']==1 and not physical['initial_goal']) if row['expected']=='applicable' else (physical['status']=='inapplicable' and physical['step']==0)
        branch_physical.append({'id':row['id'],'passed':passed,'physical_status':physical['status']})
    cross=[]
    for row in fixed['cross_rows']:
        physical=None
        if row['search']['status']=='solved':
            plan=FIXED/'execution/composition'/row['id']/'search/plan.pddl'
            hashes[str(plan)]=digest(plan);physical=replay_saved(Path(row['domain']),Path(row['problem']),plan)
        cross.append({'id':row['id'],'family':row['family'],'size':row['size'],'condition':row['condition'],
            'source_activation':row['source_activation'],'separate_identity':row['separate_identity'],'hypothesis':row['hypothesis'],
            'search_status':row['search']['status'],'physical':physical,'intentional_replay':row.get('replay'),
            'matches_frozen_hypothesis':(physical is not None and physical['status']=='replayed' and physical['goal']) if row['hypothesis']=='solved' else row['search']['status']=='no_solution_returned'})
    by_condition={c:dict(Counter(x['check'] for x in fixed['branch_rows'] if x['condition']==c)) for c in ['native','union','predicate_only','full']}
    positives=[x for x in fixed['branch_rows'] if x['condition']=='full' and x['case']=='positive' and x['check']=='pass']
    old_failures=[x for x in original['branch_rows'] if x['check']=='fail']
    cross_table=[]
    for family in sorted({x['family'] for x in cross}):
        for condition in ['union','predicate_only','full']:
            rows=[x for x in cross if x['family']==family and x['condition']==condition and x['source_activation']=='both' and not x['separate_identity']]
            cross_table.append({'family':family,'condition':condition,'tasks':len(rows),
                'search_counts':dict(Counter(x['search_status'] for x in rows)),
                'plan_lengths':[x['physical']['steps'] if x['physical'] else None for x in rows]})
    summary={'status':'complete','runtime_variant':protocol['runtime_variant'],
        'original_runtime':{'branch_checks':len(original['branch_rows']),'failures':len(old_failures),
            'failure_status_counts':dict(Counter(x['result']['status'] for x in old_failures)),
            'cross_search_calls':original['search_calls'],'status':original['status']},
        'corrected_runtime':{'branch_checks':len(fixed['branch_rows']),'checks':fixed['branch_check_counts'],
            'by_condition':by_condition,'full_groups_covered':len({x['group'] for x in positives}),
            'full_source_branches_covered':len({x['branch'] for x in positives}),
            'independent_physical_checks_passed':sum(x['passed'] for x in branch_physical),
            'cross_search_calls':fixed['search_calls'],'cross_counts':fixed['cross_search_counts'],
            'cross_returned_plan_replays_passed':fixed['cross_returned_plan_replays_passed'],
            'cross_hypotheses_matched':sum(x['matches_frozen_hypothesis'] for x in cross),
            'cross_table':cross_table,'invocation_runtime_receipt':str(FIXED/'runtime_receipt.json')},
        'main_saved_plan_audit':{'path':str(MAIN_AUDIT),'counts':read(MAIN_AUDIT)['counts'],
            'earlier_diagnostic_superseded':'v1 physical audit lacked an axiom support gate; its story_034 goal discrepancy is not an established runtime failure.'},
        'review':protocol['review'],'search_calls_this_followup':fixed['search_calls']+original['search_calls'],'new_model_calls':0,
        'limits':['Two posthoc authored composition families, each tested at correlated sizes 1 and 3. Not additional held-out stories.',
            'Predicate-only and Full must be compared separately: composition may rely on shared predicates, without requiring action fusion.',
            'No-solution-returned is an observed bounded-search outcome, not a universal unsolvability certificate.',
            'Independent semantic labels remain zero; mechanical checks do not establish semantic equivalence or narrative quality.',
            'Original main search metrics remain original-runtime measurements. A corrected-runtime comparison needs a fresh frozen main run.'],
        'input_sha256':hashes,'inputs_unchanged':True,'branch_physical':branch_physical,'cross_rows':cross}
    output.mkdir(parents=True)
    summary['implementation_sha256']=snapshot_implementation(output,[Path(__file__),Path('rcnc/saved_plan_validation.py'),Path('rcnc/revised_probe_validation.py')])
    save(output/'analysis.json',summary)
    return {k:v for k,v in summary.items() if k not in ('input_sha256','implementation_sha256','branch_physical','cross_rows')}


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,required=True)
    print(json.dumps(analyze(p.parse_args().output),indent=2))

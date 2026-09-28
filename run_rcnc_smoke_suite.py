"""Run designed success/failure controls, not a paper benchmark."""
import argparse
import copy
import json
from pathlib import Path
from rcnc.planning import run_query


def run_suite(output):
    base=json.loads(Path('data/rcnc/queries/fixed_initial_smoke.json').read_text(encoding='utf-8'))
    cases={'cross_source': (copy.deepcopy(base), 'solved')}
    missing=copy.deepcopy(base);missing['initial']=missing['initial'][:2];missing['max_depth']=20
    cases['missing_initial_fact']=(missing,'unsolvable')
    isolated=copy.deepcopy(base);isolated['interfaces']={};isolated['max_depth']=20
    isolated['initial'][0][0]='birt__at';isolated['initial'][1][0]='chic_np__at'
    cases['without_interface']=(isolated,'unsolvable')
    wrong=copy.deepcopy(base);wrong['constant_bindings']['BIRT:bench']='hero'
    cases['wrong_role_type']=(wrong,'rejected')
    unsupported=copy.deepcopy(base);unsupported['actions'].append('HANS_NP:follow_breadcrumbs_home')
    cases['conditional_effect']=(unsupported,'rejected')
    results=[]
    for name,(query,expected) in cases.items():
        r=run_query(query,Path('data/narra-domains'),output/name)
        results.append({'case':name,'expected':expected,'status':r['status'],
                        'matches_expected':r['status']==expected,'plan_length':r.get('plan_length'),
                        'sources_used':r.get('sources_used'), 'reason':r.get('reason')})
    summary={'purpose':'Designed engineering controls, not a success-rate benchmark', 'cases':results,
             'all_expected':all(r['matches_expected'] for r in results)}
    (output/'summary.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
    return summary

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,required=True)
    result=run_suite(p.parse_args().output);print(json.dumps(result,indent=2))
    raise SystemExit(0 if result['all_expected'] else 1)

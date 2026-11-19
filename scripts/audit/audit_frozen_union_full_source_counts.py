"""Post-hoc source-count profiles of all saved valid frozen diagnostic plans.

No model, Java or planner invocation. Recheck saved plans symbolically, retain
all 2,400 registered slots, and never replace original planning/replay results.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import shutil
import sys

from rcnc.causal_attribution import (VERSION, SOURCE_COUNT_PROFILE_VERSION,
    causal_trace_v2, file_digest, recover_branch_provenance)


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x', encoding='utf-8') as stream:
        json.dump(data, stream, ensure_ascii=False, indent=2)
        stream.write('\n')


def summary(rows, k):
    good = [r for r in rows if r['original_dual_validated']]
    result = {'registered': len(rows), 'dual_validated': len(good),
              'attribution_statuses': dict(Counter(r['audit']['status'] for r in good)),
              'original_outcomes': dict(Counter(r['original_outcome'] for r in rows)),
              'at_least': {}, 'exact_maximum_chain_sources': {}, 'ambiguous_ranges': {}}
    for j in range(2, k+1):
        counts = Counter(r['audit'].get('source_count_profile', {}).get('at_least', {}).get(str(j), {}).get('status', 'unknown') for r in good)
        result['at_least'][str(j)] = {s: counts[s] for s in ('confirmed', 'absent', 'ambiguous', 'unknown')}
        result['at_least'][str(j)]['no_dual_validated_plan'] = len(rows)-len(good)
    result['exact_maximum_chain_sources'] = dict(Counter(str(r['audit']['source_count_profile']['exact_count']) for r in good
        if r['audit'].get('source_count_profile',{}).get('exact_count') is not None))
    result['ambiguous_ranges'] = dict(Counter(str(p['minimum_over_interpretations'])+'-'+str(p['maximum_over_interpretations'])
        for r in good for p in [r['audit'].get('source_count_profile',{})]
        if p.get('status')=='classified' and p.get('exact_count') is None))
    return result


def audit(run, output, *, execution_scope=None):
    if output.exists():
        raise ValueError('Fresh audit output required')
    hashes = {}
    def pin(path, expected=None):
        path=Path(path).resolve(); current=file_digest(path)
        if expected is not None and current != expected:
            raise ValueError('Frozen input changed: '+str(path))
        hashes[str(path)] = current
        return current
    review_path=run/'paired_review_v1/report.json'
    review=read(review_path)
    for name,expected in read(run/'paired_review_v1/review_freeze.json')['files'].items():
        pin(run/'paired_review_v1'/name,expected)
    for name,expected in review['input_sha256'].items():
        pin(name,expected)
    assert review['experiment_status']=='complete' and review['registered_groups']==1200
    original_path=run/'repeat_01/composition_report.json'
    originals=read(original_path)['rows']; groups={g['id']:g for g in review['groups']}
    assert len(originals)==len({r['id'] for r in originals})==2400
    assert len({(r['cohort'],r['method'],r['size'],r['condition']) for r in originals})==48
    models={}; variant_paths={}
    for row in originals:
        if not row.get('valid'):
            continue
        for key in ('domain','problem','mapping','plan'):
            pin(row[key])
        for phase in ('search','replay'):
            for name,expected in row.get(phase,{}).get('input_sha256',{}).items():pin(name,expected)
        assert row['replay']['input_sha256'][str(Path(row['plan']).resolve())]==file_digest(row['plan'])
        mapping=read(row['mapping']);models[row['domain']]=mapping
        if any(n>1 for n in Counter(x['name'] for x in mapping['action_maps'].values()).values()):
            variants=Path(row['domain']).parent.parent/'predicate_mapping_stage'
            pin(variants/'domain.pddl');pin(variants/'mapping.json')
            variant_paths[row['domain']]=variants
    repo=Path(__file__).resolve().parents[2]
    implementation={Path(__file__).resolve()}
    for module in list(sys.modules.values()):
        filename=getattr(module,'__file__',None)
        if filename:
            path=Path(filename).resolve()
            if path.is_relative_to(repo/'rcnc') or path.is_relative_to(repo/'scripts'):
                implementation.add(path)
    for path in implementation:pin(path)
    protocol={'status':'frozen_before_offline_source_count_audit','created_utc':datetime.now(timezone.utc).isoformat(),
              'parent_run':str(run),'attribution_version':VERSION,'profile_version':SOURCE_COUNT_PROFILE_VERSION,
              'registered_rows':2400,'saved_dual_validated_plans':sum(bool(r.get('valid')) for r in originals),
              'max_interpretations':4096,'max_supports_per_step':256,'input_sha256':hashes,
              'new_model_calls':0,'new_planner_calls':0,'new_native_replay_calls':0,
              'metric':'For each feasible source/support interpretation, find the maximum distinct selected sources on a single goal-relevant positive-fact path. Confirm >=j iff every interpretation reaches j; absent iff none; otherwise ambiguous. Caps/unsupported constructs remain unknown. Exact m requires every interpretation to have the same maximum m.',
              'scope':execution_scope or 'Post-hoc audit of saved 15-second results, not a new planning condition. Source-count thresholds 2..k; no new predicate-only planning arm. Internal predicate mapping artifact is used only to certify fused branch provenance.'}
    write(output/'protocol.json',protocol)
    for source in implementation:
        dest=output/'implementation'/source.relative_to(repo);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,dest)
    provenance={}; provenance_errors={}
    for name,path in variant_paths.items():
        try:
            value=recover_branch_provenance(Path(name),models[name],path/'domain.pddl',read(path/'mapping.json'))
            provenance[name]=value
            write(output/'provenance'/(Path(name).parent.parent.name+'.json'),value)
        except (ValueError,KeyError,TypeError) as exc:
            provenance_errors[name]=str(exc)
    rows=[]
    for old in originals:
        g=groups[old['group']]
        row={k:old[k] for k in ('id','group','cohort','method','condition')}
        row.update(selected_k=old['size'],constructed_target_size=g['constructed_target_size'],
                   original_dual_validated=bool(old.get('valid')),
                   original_outcome=g['diagnostic_outcomes'][old['condition']])
        if not old.get('valid'):
            result={'status':'no_dual_validated_saved_plan'}
        elif old['domain'] in provenance_errors:
            result={'status':'unknown','reason':provenance_errors[old['domain']]}
        else:
            result=causal_trace_v2(old['domain'],old['problem'],old['plan'],models[old['domain']],
                provenance=provenance.get(old['domain']),selected_sources=old['sources'],
                source_count_profile=True,max_interpretations=4096,max_supports=256)
        row['audit']=result
        if old.get('valid'):
            row.update(domain=old['domain'],problem=old['problem'],plan=old['plan'],mapping=old['mapping'])
            profile=result.get('source_count_profile',{})
            if profile.get('status')=='classified':
                assert profile['at_least']['2']['status']==result['cross']['status']
                assert profile['at_least'][str(old['size'])]['status']==result['all_k']['status']
        rows.append(row)
    cells=[]
    for cohort in ('story','human','mixed'):
        for k in (2,3,4,5):
            for method in ('random','causal_link'):
                for arm in ('union','full'):
                    rr=[r for r in rows if (r['cohort'],r['selected_k'],r['method'],r['condition'])==(cohort,k,method,arm)]
                    assert len(rr)==50
                    cells.append(dict(cohort=cohort,k=k,method=method,condition=arm,**summary(rr,k)))
    by_k=[dict(k=k,condition=arm,**summary([r for r in rows if r['selected_k']==k and r['condition']==arm],k))
          for k in (2,3,4,5) for arm in ('union','full')]
    for name,expected in hashes.items():
        assert file_digest(name)==expected,name
    report={'status':'complete_offline_source_count_audit','created_utc':datetime.now(timezone.utc).isoformat(),
            'protocol_sha256':file_digest(output/'protocol.json'),'registered_rows':len(rows),
            'saved_dual_validated_plans':sum(r['original_dual_validated'] for r in rows),
            'rows':rows,'cells':cells,'by_selected_k':by_k,
            'input_files_verified':len(hashes),'inputs_unchanged':True,
            'new_model_calls':0,'new_planner_calls':0,'new_native_replay_calls':0,
            'new_offline_symbolic_checks':sum(r['original_dual_validated'] for r in rows)-len(provenance_errors),
            'independent_semantic_labels':0,'profile_version':SOURCE_COUNT_PROFILE_VERSION}
    write(output/'report.json',report)
    write(output/'evidence_index.json',{'reports':{'frozen_union_full_source_count_profiles':{
        'path':str(output/'report.json'),'sha256':file_digest(output/'report.json'),
        'terminal_status':report['status'],'scope':'All 2400 registered diagnostic slots; saved-plan post-hoc causal depth profiles, no new model or native planner calls.',
        'metrics':['registered_rows','saved_dual_validated_plans','cells','by_selected_k','inputs_unchanged','profile_version'],
        'denominator':'registered_rows','row_id':'id','required_true':['inputs_unchanged']}},
        'excluded_pending':[] if execution_scope else ['incomplete_timeout60_retry_campaign']})
    return {'status':report['status'],'saved_plans':report['saved_dual_validated_plans'],
            'cells':len(cells),'by_selected_k':by_k,
            'unknown_reasons':dict(Counter(r['audit'].get('reason') for r in rows if r['original_dual_validated'] and r['audit']['status']!='classified'))}


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--execution-scope',default=None)
    args=parser.parse_args()
    print(json.dumps(audit(args.run.resolve(),args.output.resolve(),execution_scope=args.execution_scope),ensure_ascii=False,indent=2))

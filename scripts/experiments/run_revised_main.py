"""GPT-4 revised held-out source preservation and schema-compression experiment.

All source records, rejected candidates, time limits and missing plans are kept.
This block does not claim independent semantics or cross-story narrative quality.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import shutil
import time

from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.glaive_merge import Source, build, candidate_pairs, map_problem, translate_plan
from rcnc.glaive_runtime import invoke
from rcnc import model_semantics
from rcnc.model_semantics_contract import include_output_contract
from scripts.experiments.run_revised_development import INTAKE, ADMISSION, JAR, CLASSES, paths, read, replay, passed

MODEL = 'glm-5.3:cloud'
MODEL_DIGEST = '8477dab3e25bb0f93c468af220186f55394262ee5e9f39262af4b60b54a8c4ba'


def order(label): return hashlib.sha256(('revised-main-20261101|' + label).encode()).hexdigest()


def prepare(root, development):
    if root.exists(): raise ValueError('Fresh main output required')
    if not read(development / 'report.json')['gate_passed']: raise ValueError('Development gate failed')
    for x in read(INTAKE / 'download_report.json')['files']:
        if digest(INTAKE / 'upstream' / x['path']) != x['sha256']: raise ValueError('Changed upstream file')
    # Hash input stories across both partitions before selecting any test pair.
    story_hashes = {}; duplicates = []
    for x in read(INTAKE / 'protocol.json')['sources']:
        p = paths(x)[0].parent / 'input.txt'; h = digest(p)
        if h in story_hashes: duplicates.append([story_hashes[h], x['id']])
        story_hashes[h] = x['id']
    if duplicates: raise ValueError('Duplicate source stories require a new group split')
    root.mkdir(parents=True); inputs = root / 'inputs'; inputs.mkdir()
    sources, rows = [], []
    for row in read(ADMISSION)['rows']:
        if row['split'] != 'test': continue
        r = {k: row[k] for k in ('id','upstream_id','split','status')}
        if row['status'] == 'parsed':
            try:
                s = Source(row['id'], *paths(row))
                # Construction is admitted without search, never by solvability.
                model = root / 'admission_models' / s.id
                m = build([s], model); map_problem([s], s.id, m, model / 'problem.pddl')
                sources.append(s); r['adapter'] = 'compiled'
                shutil.copyfile(s.domain_path, inputs / (s.id + '_domainfile.pddl'))
            except (ValueError, KeyError, TypeError) as exc: r.update(adapter='unsupported', reason=str(exc))
        rows.append(r)
    census = candidate_pairs(sources)
    random_pairs = sorted(census, key=lambda r: order(r['id']))[:30]
    selected = {r['id'] for r in random_pairs}
    # Enrichment uses source-only coarse structural opportunity, never model answers or plans.
    enriched = sorted((r for r in census if r['id'] not in selected),
        key=lambda r: (-sum(c['lexical_score'] for c in r['candidates'] if c['kind']=='action'),
                       -min(4,r['action_opportunities']), -min(8,r['predicate_opportunities']), order(r['id'])))[:30]
    pairs = [{**r, 'stratum': st} for st, collection in [('random',random_pairs),('opportunity',enriched)] for r in collection]
    candidates = []
    # Interleave pairs so a global inference limit does not exhaust one stratum first.
    interleaved = sorted(pairs, key=lambda r: order('requests|' + r['id']))
    slots = {}
    for pair in interleaved:
        pp = [c for c in pair['candidates'] if c['kind']=='predicate']
        aa = [c for c in pair['candidates'] if c['kind']=='action']
        slots[pair['id']] = [c for i in range(8) for c in (pp[i:i+1] + aa[i:i+1])]
    for i in range(12):
        for pair in interleaved:
            if i < len(slots[pair['id']]): candidates.append(slots[pair['id']][i])
    if len(candidates) > 720: raise ValueError('Main request cap exceeded')
    model_semantics.prepare(inputs, candidates, root / 'judgments', model=MODEL, model_digest=MODEL_DIGEST,
        total_seconds=21600, request_seconds=240, schema_policy='compact_kind_specific', num_predict=16384, num_ctx=32768)
    include_output_contract(root / 'judgments')
    save(root / 'census.json', {'source_count': len(sources), 'pair_count': len(census), 'pairs': census})
    protocol = {'status': 'frozen_before_main_model_and_search_calls', 'created_utc': datetime.now(timezone.utc).isoformat(),
        'dataset': 'there-and-back GPT-4 revised, published bytes without repairs', 'rows': rows, 'pairs': pairs,
        'duplicate_story_groups': duplicates, 'development_report': str(development / 'report.json'),
        'development_report_sha256': digest(development / 'report.json'), 'confidence_threshold': .9,
        'conditions': ['native','union','predicate_only','full'], 'model_max_requests': 720,
        'model_seconds': 21600, 'seconds_per_search': 15, 'seconds_per_replay': 15, 'memory_mb': 4096,
        'search_workers': 1, 'attempts': 1, 'source_world_policy': 'Separate original initial states and goals; only the selected source active; no shared object identities assumed.',
        'selection': 'Thirty SHA256-ordered random pairs plus thirty distinct source-only opportunity-enriched pairs. Report separately. No replenishment after outcomes.',
        'test_scope': 'Source-preserving parameterized merge, native intentional replay and schema compression. No independently labeled semantic accuracy or narrative quality. Source-pair rows are correlated, not independent stories.',
        'failure_policy': 'Every source and selected pair retained. No retries, threshold changes, replacement pairs, syntax repair, cache continuation or fallback originals.',
        'search_order': 'Unique native source tasks in hashed order, followed by hashed pair blocks with hashed condition order; all merged models constructed and hashed before first search.'}
    files = [INTAKE/'protocol.json', ADMISSION, JAR, CLASSES/'GlaiveProbe.class', development/'report.json', root/'judgments/manifest.json', root/'judgments/requests.json']
    for r in rows:
        files.extend(paths(r))
    protocol['input_sha256'] = {str(p): digest(p) for p in files}
    protocol['implementation_sha256'] = snapshot_implementation(root, [Path(__file__), Path('rcnc/glaive_merge.py'),
        Path('rcnc/glaive_runtime.py'), Path('scripts/experiments/run_revised_development.py'), Path('scripts/java/GlaiveProbe.java')])
    save(root / 'protocol.json', protocol)
    return {'source_rows': len(rows), 'admitted_sources': len(sources), 'pairs': len(pairs), 'model_candidates': len(candidates),
            'search_slots': sum(r['status']=='parsed' for r in rows)+6*len(pairs)}


def verify(root):
    p = read(root / 'protocol.json')
    for path,h in {**p['input_sha256'],**p['implementation_sha256']}.items():
        if digest(Path(path)) != h: raise ValueError('Frozen dependency changed: '+path)
    return p


def judge(root):
    verify(root); r = model_semantics.run(root/'judgments')
    return {k: v for k,v in r.items() if k!='rows'}


def compile_models(root):
    protocol = verify(root)
    if (root/'compilation.json').exists() or (root/'models').exists(): raise ValueError('Fresh compilation only')
    jr = read(root/'judgments/report.json')
    if jr['status']!='complete': raise ValueError('Model stage incomplete')
    groups = {g['id']: g for g in read(root/'judgments/groups.json')['groups']}
    source_rows = {r['id']:r for r in protocol['rows']}
    tasks, compiled, files = [], [], []
    for pair in protocol['pairs']:
        sources = [Source(sid,*paths(source_rows[sid])) for sid in pair['sources']]
        gs = [groups[c['id']] for c in pair['candidates']]
        for condition in ('union','predicate_only','full'):
            folder = root/'models'/pair['id']/condition
            m = build(sources,folder,groups=[] if condition=='union' else gs,merge_actions=condition=='full',threshold=.9)
            compiled.append({'pair':pair['id'],'stratum':pair['stratum'],'condition':condition,**m})
            for s in sources:
                problem = folder/(s.id+'.pddl'); map_problem(sources,s.id,m,problem)
                tasks.append({'pair':pair['id'],'source':s.id,'stratum':pair['stratum'],'condition':condition,'domain':str(folder/'domain.pddl'),'problem':str(problem)})
            files.extend(folder.iterdir())
        pred = read(root/'models'/pair['id']/'predicate_only/mapping.json')
        full = read(root/'models'/pair['id']/'full/mapping.json')
        if pred['predicate_maps'] != full['predicate_maps']: raise ValueError('Paired predicate maps differ')
    tasks.sort(key=lambda t:(order(t['pair']),order(t['pair']+'|'+t['condition']),t['source']))
    receipt = {'status':'compiled_before_search','tasks':tasks,'models':compiled,
        'input_sha256':{str(p):digest(p) for p in files}, 'judgment_report_sha256':digest(root/'judgments/report.json'),
        'groups_sha256':digest(root/'judgments/groups.json')}
    save(root/'compilation.json',receipt)
    return {'models':len(compiled),'tasks':len(tasks),'action_groups_accepted':sum(d['kind']=='action' and d['status']=='accepted' for m in compiled for d in m['decisions'])}


def execute(root):
    p=verify(root); comp=read(root/'compilation.json')
    if (root/'execution_progress.json').exists(): raise ValueError('Fresh execution only')
    for path,h in comp['input_sha256'].items():
        if digest(Path(path))!=h: raise ValueError('Changed compiled model')
    if digest(root/'judgments/groups.json')!=comp['groups_sha256']: raise ValueError('Changed judgments')
    native, results = {}, []
    def progress(): save(root/'execution_progress.json',{'native':native,'rows':results})
    progress()
    for row in sorted(p['rows'],key=lambda r:order(r['id'])):
        sid=row['id']; out=root/'execution/native'/sid
        if row['status']!='parsed': native[sid]={'status':row['status'],'search_calls':0}; progress(); continue
        d,pr=paths(row); r=invoke(JAR,d,pr,out,seconds=p['seconds_per_search'])
        if r['status']=='solved': r['replay']=replay(d,pr,out/'plan.pddl',out/'replay',p['seconds_per_replay'])
        native[sid]=r; progress(); print('native',sid,r['status'],flush=True)
    byid={r['id']:r for r in p['rows']}
    for task in comp['tasks']:
        out=root/'execution'/task['pair']/task['condition']/task['source']
        d,pr=Path(task['domain']),Path(task['problem']); r=dict(task)
        r['search']=invoke(JAR,d,pr,out/'search',seconds=p['seconds_per_search'])
        if r['search']['status']=='solved': r['replay']=replay(d,pr,out/'search/plan.pddl',out/'replay',p['seconds_per_replay'])
        if native[task['source']]['status']=='solved':
            source=Source(task['source'],*paths(byid[task['source']]))
            terms={**source.term_map,**{o:source.id+'_o_'+o for o in source.objects}}
            translate_plan(source.id,read(d.parent/'mapping.json'),terms,root/'execution/native'/source.id/'plan.pddl',out/'transport.pddl')
            r['transport']=replay(d,pr,out/'transport.pddl',out/'transport',p['seconds_per_replay'])
        else: r['transport']={'status':'unavailable_native_plan','search_calls':0}
        results.append(r);progress();print(task['pair'],task['condition'],task['source'],r['search']['status'],r['transport']['status'],flush=True)
    report={'status':'complete','source_count':len(p['rows']),'pair_count':len(p['pairs']),
        'native_counts':dict(Counter(r['status'] for r in native.values())), 'native':native,'rows':results,
        'condition_counts':{c:{'search':dict(Counter(r['search']['status'] for r in results if r['condition']==c)),
                               'transport':dict(Counter(r['transport']['status'] for r in results if r['condition']==c)),
                               'transport_passed':sum(passed(r['transport']) for r in results if r['condition']==c)} for c in p['conditions'][1:]},
        'search_calls':sum(r['search_calls'] for r in native.values())+sum(r['search']['search_calls'] for r in results),
        'model_requests':read(root/'judgments/report.json')['requests_attempted'],
        'independent_semantic_labels':0,'independent_narrative_labels':0,
        'gate_violations':[{'pair':r['pair'],'source':r['source'],'condition':r['condition'],'status':r['transport']['status']}
             for r in results if r['transport']['status'] not in ('unavailable_native_plan','unavailable_counterfactual_plan_format') and not passed(r['transport'])]}
    save(root/'report.json',report)
    return {k:v for k,v in report.items() if k not in ('native','rows')}


def pipeline(root):
    """One bounded coordinator; no retries, cache continuation or new tasks."""
    import os
    import traceback
    status_path=root/'coordinator.json'
    if status_path.exists(): raise ValueError('Coordinator already started; no implicit resume')
    state={'status':'running','started_utc':datetime.now(timezone.utc).isoformat(),'pid':os.getpid(),
           'protocol_sha256':digest(root/'protocol.json'),'stages':{}}
    try:
        for name, function in [('judgments',judge),('compilation',compile_models),('execution',execute)]:
            state['stage']=name;save(status_path,state);print('Starting',name,flush=True)
            result=function(root);state['stages'][name]=result;save(status_path,state)
            print('Completed',name,json.dumps(result),flush=True)
        state['status']='complete'
    except Exception as exc:
        state.update(status='failed',error=str(exc),traceback=traceback.format_exc())
        save(status_path,state);raise
    finally:
        state['ended_utc']=datetime.now(timezone.utc).isoformat();save(status_path,state)
    return state


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('mode',choices=['prepare','judge','compile_models','execute','pipeline']);p.add_argument('--output',type=Path,required=True);p.add_argument('--development',type=Path)
    a=p.parse_args();result=prepare(a.output,a.development) if a.mode=='prepare' else globals()[a.mode](a.output)
    print(json.dumps(result,indent=2))

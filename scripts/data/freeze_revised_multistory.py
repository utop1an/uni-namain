"""Freeze outcome-blind k=2..10 source groups; never call a model or planner."""
import argparse
from collections import Counter
from datetime import datetime, timezone
from itertools import combinations
import json
from pathlib import Path
import shutil

from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.glaive_merge import Source, candidate_pairs, action_fields
from rcnc.pddl import typed_symbols
from rcnc.revised_sampling import balanced_chains,materialize_groups,pair_features,validate_sampling

INTAKE=Path('data/external/there_and_back_gpt4_revised_2026_11_01_v1')
COHORT_PARENT=Path('data/validation/revised_main_2026_11_01_v1/protocol.json')
SEED='there-and-back-gpt4-revised-balanced-k2-10-20261101-v1'
IMPLEMENTATION=[Path(__file__),Path('rcnc/revised_sampling.py'),Path('rcnc/glaive_merge.py'),
    Path('rcnc/pddl.py'),Path('rcnc/domain_building.py'),Path('rcnc/conditional_merge.py'),Path('tests/test_revised_sampling.py')]


def read(p):return json.loads(p.read_text(encoding='utf-8'))


def checked_file(root,relative,download):
    p=root/relative
    if relative not in download or digest(p)!=download[relative]['sha256']:raise ValueError('Changed published input: '+relative)
    return p


def verify_frozen(root):
    freeze=read(root/'freeze.json')
    if digest(root/'freeze.json')!=(root/'FREEZE.sha256').read_text(encoding='utf-8').split()[0]:raise ValueError('Changed freeze manifest')
    for rel,h in freeze['artifact_sha256'].items():
        if digest(root/rel)!=h:raise ValueError('Changed frozen artifact: '+rel)
    protocol=read(root/'protocol.json');cohort=read(root/'cohort.json')
    chains=read(root/'chains.json')['chains'];groups=read(root/'groups.json')['groups']
    ids=[s['id'] for s in cohort['sources'] if s['included']]
    coverage=validate_sampling(chains,groups,ids,chain_count=100,max_size=10,pair_cap=12)
    regenerated,trace=balanced_chains(ids,chain_count=100,max_size=10,seed=protocol['sampling']['seed'],pair_cap=12)
    if chains!=regenerated or trace!=read(root/'chains.json')['assignment_trace']:raise ValueError('Non-reproducible sampling')
    used={tuple(sorted(p)) for g in groups for p in combinations(g['sources'],2)}
    candidate_data=read(root/'candidate_inventory.json');features=read(root/'pair_features.json')['pairs']
    by_pair={tuple(sorted(p['sources'])):p for p in features}
    if len(features)!=1770 or len(by_pair)!=1770:raise ValueError('Pair census denominator changed')
    expected={cid for pair in used for cid in by_pair[pair]['candidate_ids']}
    actual={c['id'] for c in candidate_data['candidates']}
    if actual!=expected or len(actual)!=len(candidate_data['candidates']):raise ValueError('Candidate inventory mismatch')
    if any(g['semantic_relation_label'] is not None for g in groups):raise ValueError('Invented group labels')
    if protocol['calls_performed']!={'model':0,'planner':0}:raise ValueError('Unexpected executions')
    for row in cohort['sources']:
        if row['included']:
            for f in row['files'].values():
                if digest(root/f['frozen_path'])!=f['sha256']:raise ValueError('Changed source copy')
    return {'status':'verified','frozen_artifacts_checked':len(freeze['artifact_sha256']),
        'source_count':len(ids),'chains':len(chains),'groups':len(groups),'source_pair_census':len(features),
        'unique_pairs_used':len(used),'unique_candidates_used':len(actual),'coverage':coverage,
        'reproducible_from_seed':True,'duplicate_groups':0,'semantic_labels':0,'model_calls':0,'planner_calls':0,
        'freeze_sha256':digest(root/'freeze.json')}


def prepare(root):
    if root.exists():raise ValueError('Fresh versioned output directory required')
    intake=read(INTAKE/'protocol.json');parent=read(COHORT_PARENT);download_report=read(INTAKE/'download_report.json')
    downloaded={x['path']:x for x in download_report['files']};legacy={x['id']:x for x in parent['rows']}
    source_ids=sorted(x['id'] for x in parent['rows'] if x.get('adapter')=='compiled')
    if len(source_ids)!=60 or len(legacy)!=152:raise ValueError('Unexpected legacy cohort denominator')
    # Selection sees only the fixed admitted IDs. Features are calculated afterwards.
    chains,trace=balanced_chains(source_ids,chain_count=100,max_size=10,seed=SEED,pair_cap=12)
    groups=materialize_groups(chains)
    coverage=validate_sampling(chains,groups,source_ids,chain_count=100,max_size=10,pair_cap=12)
    root.mkdir(parents=True);(root/'provenance').mkdir()
    parent_files={'intake_protocol.json':INTAKE/'protocol.json','download_report.json':INTAKE/'download_report.json',
        'legacy_cohort_protocol.json':COHORT_PARENT,'upstream_README.md':checked_file(INTAKE/'upstream','README.md',downloaded)}
    provenance={}
    for label,p in parent_files.items():
        shutil.copyfile(p,root/'provenance'/label);provenance[str(p)]={'sha256':digest(p),'copy':'provenance/'+label}
    all_rows=[];sources={};source_features=[];story_hashes={};metadata_keys=Counter();metadata_hashes={}
    for item in sorted(intake['sources'],key=lambda x:x['id']):
        sid=item['id'];previous=legacy.get(sid);included=sid in source_ids
        row={'id':sid,'corpus':item['upstream_id'].split('/')[0],'upstream_id':item['upstream_id'],
            'legacy_split':item['split'],'included':included,'legacy_admission':previous and {k:v for k,v in previous.items() if k not in ('id','upstream_id','split')},
            'selection_role':'eligible_fixed_pool' if included else ('excluded_previous_development_split' if previous is None else 'excluded_legacy_admission')}
        meta_relative='results/runs/'+item['upstream_id']+'/metadata.json'
        metadata=checked_file(INTAKE/'upstream',meta_relative,downloaded)
        metadata_keys[tuple(sorted(read(metadata)))]+=1;metadata_hashes[meta_relative]=digest(metadata)
        if included:
            files={}
            for name in ['revised-domain.pddl','revised-problem.pddl','input.txt','metadata.json']:
                rel='results/runs/'+item['upstream_id']+'/'+name;p=checked_file(INTAKE/'upstream',rel,downloaded)
                target=root/'sources'/sid/name;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,target)
                files[name]={'upstream_path':rel,'frozen_path':target.relative_to(root).as_posix(),'sha256':digest(p)}
            story_hash=files['input.txt']['sha256']
            if story_hash in story_hashes:raise ValueError('Duplicate input story in source pool')
            story_hashes[story_hash]=sid
            row['files']=files;s=Source(sid,root/files['revised-domain.pddl']['frozen_path'],root/files['revised-problem.pddl']['frozen_path']);sources[sid]=s
            source_features.append({'id':sid,'corpus':row['corpus'],'action_count':len(s.domain.actions),
                'predicate_count':len(s.domain.predicates),'declared_type_count':len(s.domain.types),
                'constant_count':len(s.domain.constants),'problem_object_count':len(s.objects),
                'action_parameter_counts':dict(Counter(len(typed_symbols(action_fields(a)[':parameters'])) for a in s.domain.actions.values()))})
        all_rows.append(row)
    if len(all_rows)!=192:raise ValueError('Unexpected published intake denominator')
    pairs=candidate_pairs([sources[sid] for sid in source_ids]);pair_rows=[];used={p for g in groups for p in combinations(g['sources'],2)};candidate_rows=[]
    for p in pairs:
        f=pair_features(p,sources);f['candidate_ids']=[c['id'] for c in p['candidates']];f['used_by_frozen_groups']=tuple(sorted(p['sources'])) in used;pair_rows.append(f)
        if f['used_by_frozen_groups']:
            candidate_rows.extend({**c,'source_pair':p['sources']} for c in p['candidates'])
    by_pair={tuple(sorted(p['sources'])):p for p in pair_rows};by_source={s['id']:s for s in source_features}
    for g in groups:
        ps=[by_pair[p] for p in combinations(g['sources'],2)]
        g['descriptive_features']={'action_templates_sum':sum(by_source[s]['action_count'] for s in g['sources']),
            'predicate_declarations_sum':sum(by_source[s]['predicate_count'] for s in g['sources']),
            'same_arity_predicate_pairs_sum':sum(p['same_arity_predicate_pairs'] for p in ps),
            'coarse_action_shape_pairs_sum':sum(p['coarse_action_shape_pairs'] for p in ps),
            'same_name_predicate_arity_mismatches_sum':sum(len(p['same_name_predicate_arity_mismatches']) for p in ps),
            'same_name_action_parameter_count_mismatches_sum':sum(len(p['same_name_action_parameter_count_mismatches']) for p in ps),
            'corpus_counts':dict(Counter(by_source[s]['corpus'] for s in g['sources']))}
    save(root/'cohort.json',{'published_records':192,'legacy_development_records':40,'legacy_test_records':152,
        'included_sources':60,'excluded_test_records':92,'policy':'Reuse previously declared parser/compiler cohort. No new admission, repairs, semantic decisions, or selection by planning outcomes.',
        'sources':all_rows})
    save(root/'chains.json',{'chains':chains,'assignment_trace':trace})
    save(root/'groups.json',{'groups':groups})
    save(root/'source_features.json',{'role':'description_only_not_used_by_sampler','sources':source_features})
    save(root/'pair_features.json',{'role':'description_only_not_semantic_labels','pairs':pair_rows})
    save(root/'candidate_inventory.json',{'status':'source_only_candidates_no_model_judgments',
        'rule':{'max_predicates_per_pair':8,'max_actions_per_pair':4,'implementation':'rcnc/glaive_merge.py:candidate_pairs'},
        'unique_pairs_used':len(used),'candidate_count':len(candidate_rows),'candidates':candidate_rows})
    save(root/'coverage.json',{'sizes':coverage})
    save(root/'annotation_audit.json',{'status':'no_merge_relation_labels_used_or_found_in_inspected_schema',
        'inspected_metadata_records':sum(metadata_keys.values()),
        'metadata_top_level_schemas':[{'keys':list(k),'records':v} for k,v in sorted(metadata_keys.items())],
        'metadata_sha256':metadata_hashes,'upstream_readme_copy':'provenance/upstream_README.md',
        'finding':'Upstream documents per-story extraction/compose artifacts, compile/plan rates and a thematic analysis of selected outputs. These are not complementary/conflict labels for cross-story groups.',
        'inspection_scope':'Published README and top-level metadata schemas of all 192 downloaded GPT-4 stories. This is not an exhaustive manual semantic review of every archive file.',
        'prior_40_40_20_strata':'Assistant-proposed heuristic sampling, not upstream labels; withdrawn from this frozen dataset by user choice.',
        'semantic_gold_labels':0})
    implementation=snapshot_implementation(root,IMPLEMENTATION)
    protocol={'status':'frozen_data_only','created_utc':datetime.now(timezone.utc).isoformat(),
        'dataset':'There and Back Again GPT-4 revised','upstream_commit':intake['upstream_commit'],
        'sampling':{'policy':'balanced_random_nested_id_only','seed':SEED,'chain_count':100,'sizes':list(range(2,11)),
            'groups_per_size':100,'total_groups':900,'max_assignment_attempts_per_column':256,'max_pair_recurrence_per_size':12,
            'balance':'Each source occurs floor(100*k/60) or ceil(100*k/60) times at every size k.',
            'algorithm':'Columnwise quota-constrained randomized bipartite matching; SHA256 orders extras, rows and eligible slots. Accept first feasible assignment with unique unordered prefixes and bounded pair recurrence.',
            'semantic_strata':False,'feature_based_selection':False,'uniform_iid_sampling':False},
        'query_contract':{'anchor_sources':'First two sources in each frozen chain; their original problems remain separate across all sizes.',
            'all_source_regression':'All available original plans may be translated later; missing plans remain unavailable.',
            'initial_state':'Retain explicit source-local original initial facts. No pooled or synthesized cross-story initial world.',
            'cross_source_composition_tasks':'Not constructed or frozen in this data-only artifact.'},
        'future_repeats':{'proposed_ids':['repeat_01','repeat_02','repeat_03','repeat_04','repeat_05'],
            'status':'not_executed; model settings and complete execution protocol must be frozen separately'},
        'provenance':provenance,'implementation_sha256':implementation,'calls_performed':{'model':0,'planner':0},
        'limits':['900 correlated combinations from 60 known source stories; not 900 independent stories or unseen-source generalization.',
            'Structural features and raw text differences do not establish compatibility, conflict, role identity or correctness.',
            'Candidate truncation is frozen but is not exhaustive semantic recall.',
            'Previous original/corrected runtime outcomes and LLM judgments are not sampling inputs.',
            'The 60-source pool is conditional on legacy admission; excluded or unsupported records remain in the cohort denominator.']}
    save(root/'protocol.json',protocol)
    text='''GPT-4 revised 多故事组合数据冻结

按用户选择，采用覆盖均衡的随机组合，取消 40/40/20 语义风险分层。
互补/冲突不是此数据集提供的跨故事标签；结构特征仅作描述，不参与抽样。

来源：60 个既有准入故事域（全部源文件逐字节保留）；192 个原始记录的纳入/排除均记录。
组合：100 条长度为 10 的嵌套序列，每条产生 k=2..10 的 9 个组，共 900 组。
每个规模的源故事出现次数严格相差不超过 1；同一规模无重复无序集合。
同一序列固定前两个来源的问题作为后续规划查询；原始初始状态始终分开。

结构描述包括：动作/谓词数、同元数谓词对、粗动作结构候选数、同名符号元数差异。
这些数字不代表语义正确、互补或冲突。更不能作为独立人工标签。
5 轮 LLM 实验仅为后续计划；本次模型调用 0，规划器调用 0。

protocol.json：抽样与状态契约；cohort.json：全部来源纳入排除；groups.json：900 组。
chains.json：100 条序列；coverage.json：各规模覆盖；candidate_inventory.json：去重候选。
sources/：冻结的原始故事、域、问题、metadata；implementation/：代码快照。
freeze.json + FREEZE.sha256：文件完整性清单；verification.json：独立核查和重建结果。

900 组共享 60 个来源且存在嵌套关系，不能当作 900 个独立样本。
本次不构造跨故事共同初始世界，不编译合并域，不调用 LLM 或规划器。
'''
    (root/'README.txt').write_text(text,encoding='utf-8')
    hashes={p.relative_to(root).as_posix():digest(p) for p in sorted(root.rglob('*')) if p.is_file()}
    save(root/'freeze.json',{'status':'frozen','artifact_sha256':hashes,'model_calls':0,'planner_calls':0})
    (root/'FREEZE.sha256').write_text(digest(root/'freeze.json')+'  freeze.json\n',encoding='utf-8')
    verification=verify_frozen(root);save(root/'verification.json',verification)
    return {k:v for k,v in verification.items() if k!='coverage'}


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('mode',choices=['prepare','verify']);p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();result=prepare(a.output) if a.mode=='prepare' else verify_frozen(a.output)
    print(json.dumps({k:v for k,v in result.items() if k!='coverage'},indent=2))

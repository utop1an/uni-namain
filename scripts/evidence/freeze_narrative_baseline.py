"""Freeze an offline, source-hashed narrative intake baseline; never run experiments."""
import argparse
from collections import Counter, defaultdict
from datetime import datetime, timezone
import importlib.metadata
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import sys

from rcnc.domain_building import digest, save
from scripts.evidence.check_submission_checkpoint import code_fingerprint, check_snapshot
from scripts.audit.recheck_human_single_domain import read, verify as verify_hashes

REPO = Path(__file__).resolve().parents[2]
COVERAGE = REPO/'data/validation/all_narrative_coverage_priority1_2026_11_05_v1'
PACKAGING = REPO/'data/validation/narrative_mixed_content_2026_11_05_v1'
FINITE = REPO/'data/validation/priority1_language_checks_2026_11_05_v1'
TEXT_SUFFIXES = {'.py','.java','.json','.toml','.md','.txt','.pddl','.csv','.tsv','.yaml','.yml','.ps1','.sh','.bat','.ini','.cfg'}


def code_files():
    files = set(REPO.glob('*.py'))
    files.update(REPO/name for name in ('pyproject.toml','requirements-research.txt','AGENTS.md','README.md'))
    for name in ('rcnc','unidomain','scripts','tests','archive'):
        for directory, children, names in os.walk(REPO/name):
            children[:] = [child for child in children if child != '__pycache__']
            if Path(directory) == REPO/'archive' and 'research-data-v1' in children:
                children.remove('research-data-v1')
            files.update(Path(directory)/file for file in names if Path(file).suffix in TEXT_SUFFIXES)
    return sorted(files)


def observe(command):
    try:
        result = subprocess.run(command, capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=20)
        return {'command':command,'returncode':result.returncode,'stdout':result.stdout.strip(),'stderr':result.stderr.strip()}
    except (OSError,subprocess.TimeoutExpired) as exc:
        return {'command':command,'status':'unavailable','reason':str(exc)}


def prepare(output):
    if output.exists(): raise ValueError('Fresh baseline directory required')
    report, protocol = read(COVERAGE/'report.json'), read(COVERAGE/'protocol.json')
    assert report['status']=='complete' and report['registered_rows']==len(report['rows'])==512
    assert report['no_admission_regressions']
    check_snapshot(COVERAGE/'evidence_index.json', COVERAGE/'verified_snapshot/results.json')
    verify_hashes(protocol['sha256']); verify_hashes(read(COVERAGE/'conversion_hashes.json'))
    assert read(FINITE/'report.json')['status']=='verified'
    output.mkdir(parents=True)
    copied_origins = {}
    def copy(path, relative):
        path = path.resolve(); target = output/relative
        target.parent.mkdir(parents=True,exist_ok=True)
        before=digest(path); shutil.copyfile(path,target)
        if digest(path)!=before or digest(target)!=before: raise ValueError('Input changed during copy: '+str(path))
        copied_origins[str(path)]={'path':target.relative_to(output).as_posix(),'sha256':before}
        return {'path':target.relative_to(output).as_posix(),'sha256':before}
    def blob(path):
        path=Path(path).resolve()
        if str(path) in copied_origins: return dict(copied_origins[str(path)])
        sha=digest(path)
        return copy(path,Path('inputs')/(sha+path.suffix.lower()))
    code={}
    for path in code_files():
        code[path.relative_to(REPO).as_posix()]=copy(path,Path('code')/path.relative_to(REPO))['sha256']
    for name in ('docs/research/narrative-domain-fusion-plan.md','docs/dev-notes/2026-11-05-causal-path-domain-selection.md',
                 'paper/submission_workplan.json','paper/claim_evidence.json'):
        copy(REPO/name,Path('context')/name)
    for folder,name in [(COVERAGE,'coverage'),(PACKAGING,'packaging'),(FINITE,'finite_checks')]:
        for path in sorted(folder.rglob('*')):
            if path.is_file(): copy(path,Path('evidence')/name/path.relative_to(folder))
    runtime={'jar':copy(Path(protocol['jar']),'runtime/glaive-language.jar'),
             'inspect_class':copy(Path(protocol['classes'])/'GlaiveProbe.class','runtime/classes/GlaiveProbe.class'),
             'condition':protocol['runtime_condition']}
    rows=[]; groups=defaultdict(list); story_folders=set()
    for row in report['rows']:
        item={k:row[k] for k in ('id','pool','collection','source_id','constant_contract','status','single_domain_pass','provenance')}
        for k in ('story_id','historical_split','canonical_domain_sha256','reason','consent_policy'):
            if k in row: item[k]=row[k]
        item['raw']={k:{**blob(Path(row[k])),'origin':row[k]} for k in ('domain','problem')}
        item['source_inputs']={k:blob(Path(row.get('effective_'+k,row[k]))) for k in ('domain','problem')}
        if 'packaging_adapter' in row:
            item['packaging_adapter']={**row['packaging_adapter'],'frozen_manifest':'evidence/packaging/manifest.json'}
        if row['single_domain_pass']:
            item['exported']={name:{'path':f"evidence/coverage/{row['id']}/model/{name}",
                                   'sha256':digest(COVERAGE/row['id']/'model'/name)}
                              for name in ('domain.pddl','problem.pddl','mapping.json')}
            groups[(row['pool'],row['canonical_domain_sha256'])].append(row)
        if row['pool'].startswith('learned_'): story_folders.add(Path(row['domain']).parent)
        rows.append(item)
    attachments=[]
    for folder in sorted(story_folders):
        for path in sorted(folder.iterdir()):
            if path.is_file(): attachments.append({'origin':str(path),**blob(path)})
    assert len(story_folders)==192
    models=[]
    for (pool,sha), items in sorted(groups.items()):
        models.append({'id':pool+'__syntax_'+sha[:16],'pool':pool,'canonical_domain_sha256':sha,
                       'admitted_pair_ids':[x['id'] for x in items],
                       'domain_origins':sorted({x['domain'] for x in items}),
                       'scope':'Identical normalized syntax grouped within each pool, not independently labeled semantic families.'})
    primary=[r['id'] for r in rows if r['pool'] in ('human','learned_revised') and r['single_domain_pass']]
    assert len(primary)==214 and sum(r['single_domain_pass'] for r in rows)==367
    save(output/'source_catalog.json',{'registered_rows':512,'rows':rows,'pools':report['pools'],
         'primary_admitted_pair_ids':primary,'primary_pools':['human','learned_revised'],
         'supplemental_pools':['learned_original','legacy_unverified'],
         'failure_policy':'All 145 non-admitted version records retained; no repair or fallback changes this baseline.'})
    save(output/'model_catalog.json',{'models':models,'by_pool':dict(Counter(x['pool'] for x in models)),
         'counting_policy':'Do not count problem variants or original/revised versions as independent stories.'})
    save(output/'story_attachments.json',{'published_stories':192,'files':attachments,'scope':'Pinned source texts, metadata and existing outputs; no reconstructed models.'})
    save(output/'input_origins.json',copied_origins)
    environment={'python':sys.version,'python_executable':sys.executable,'platform':platform.platform(),
                 'python_packages':sorted([{'name':d.metadata['Name'],'version':d.version} for d in importlib.metadata.distributions()],key=lambda x:x['name'].lower()),
                 'java':observe(['wsl.exe','--exec','java','-version']),
                 'git_head':observe(['git','rev-parse','HEAD']),
                 'git_branch':observe(['git','branch','--show-current']),
                 'git_status':observe(['git','status','--short']),
                 'scope':'Local dependency/version observation; no credentials or environment-variable dump; source copy is authoritative despite dirty Git state.'}
    save(output/'environment.json',environment)
    freeze={'status':'prepared_pending_current_full_test_receipt','baseline_id':output.name,
            'prepared_utc':datetime.now(timezone.utc).isoformat(),'coverage_report_sha256':digest(COVERAGE/'report.json'),
            'runtime':runtime,'code_sha256':code,'python_code_sha256':code_fingerprint(REPO),
            'historical_evidence':'Copied byte-for-byte; original absolute references inside evidence remain historical provenance.',
            'experiment_policy':{'source_repairs':False,'variant_fallback':False,'initial_fact_pooling':False,
                'future_model_budget':None,'future_planner_budget':None,'new_model_calls':0,'new_planner_calls':0,
                'future_runs':'Separate versioned protocol must fix source groups, worlds, interfaces, conditions and budgets before execution.'}}
    save(output/'freeze_protocol.json',freeze)
    print(json.dumps({'status':freeze['status'],'source_rows':len(rows),'admitted':367,'primary':len(primary),'code_files':len(code)}))


def seal(output,test_log):
    if (output/'manifest.json').exists(): raise ValueError('Baseline already sealed')
    protocol=read(output/'freeze_protocol.json')
    assert protocol['python_code_sha256']==code_fingerprint(REPO),'Live Python code changed after snapshot preparation'
    assert set(protocol['code_sha256'])=={p.relative_to(REPO).as_posix() for p in code_files()}
    for path,sha in protocol['code_sha256'].items():
        assert digest(REPO/path)==sha==digest(output/'code'/path),path
    for origin,item in read(output/'input_origins.json').items():
        assert digest(Path(origin))==item['sha256']==digest(output/item['path']),origin
    log=test_log.read_text(encoding='utf-8-sig')
    result=re.search(r'Ran (\d+) tests in ([\d.]+)s\s+OK\s*$',log)
    if result is None: raise ValueError('Successful completed full test log required')
    target=output/'evidence/full_suite_current.log'; shutil.copyfile(test_log,target)
    receipt={'status':'passed','all_tests_passed':True,'code_unchanged_during_suite':True,
             'tests':int(result.group(1)),'elapsed_seconds':float(result.group(2)),
             'code_sha256':protocol['python_code_sha256'],'log':'evidence/full_suite_current.log','log_sha256':digest(target),
             'scope':'Current full-suite checkpoint bound to the prepared working-tree Python fingerprint; no new model/planning experiment.'}
    save(output/'full_test_receipt.json',receipt)
    text='''叙事域准入与合并实验基线（2026-11-05，优先级 1 后冻结）

状态：已冻结；后续研究使用此目录中的副本及清单。工作目录后续修改不改变本基线。

主实验源池：Story 修订版 127/192 个准入模型。
人工对照：87/113 个准入配对，涉及 24/46 个 domain 文件，规范化语法去重后 17 种模型。
主口径合计：214/305 配对，151/238 个 domain 文件。文件数、语法模型数与语义独立领域数是不同口径。
补充对照：Story 原始版 138/192；旧故事域 15/15（学习来源未核实）。
全部 512 条版本记录保留，367 条通过、145 条未准入。原始版与修订版不是独立故事。

冻结内容：代码、源 domain/problem、原故事及 metadata、混合内容拆分、显式 consent 策略、常量契约、运行时、解析结果、有限回归、测试日志和哈希。
代码来自当前工作目录完整副本，含未提交代码；Git HEAD 仅作为辅助定位信息。

使用入口：
- source_catalog.json：每条记录的原始文件、实际读取文件、明确初始状态、准入状态与所需策略。
- model_catalog.json：在各池内部按规范化语法分组，用于避免把同域多问题当成多个模型。
- code/：冻结的实现。运行后续实验时需验证其哈希，并使用此代码条件。
- runtime/：与本次覆盖复核相同的 Glaive JAR 和解析检查入口。
- manifest.json / MANIFEST.sha256：逐文件完整性检查。

加载一条已准入记录时：Source(row['source_id'], release / row['source_inputs']['domain']['path'], release / row['source_inputs']['problem']['path'], constant_contract=row['constant_contract'], consent_policy=row.get('consent_policy'))。
source_id 是同域多问题共享的模型命名空间；对同一 domain 只选择一个模型，问题分别保留。先依据 model_catalog 分组，禁止同时装入同一来源的不同问题作为独立域。

下一轮建议：固定来源池和选择规则，对 Union、Predicate-only、Full 使用相同组合、显式世界和预算；分别记录有效计划、跨来源因果联系、全来源参与、行为/意图保持和限制状态。
执行前另立实验协议。此冻结未确定或消耗未来模型/规划预算，也不授权续跑以前停止的实验。

边界：冻结的是解析/导出准入基线，不是全部域已成功合并或通过语义验证的结论。
保留原始失败和分母；源模型修复、重新生成、版本替代均另建条件。
consent 是显式方言解释：参与者和同意者均需意图解释；不补写意图，不等价于旧读取器忽略 consent 的行为。
本目录为本地研究快照，不是已审核的对外发布包。
'''
    (output/'README_zh.txt').write_text(text,encoding='utf-8')
    manifest={'status':'frozen_narrative_baseline','baseline_id':output.name,'sealed_utc':datetime.now(timezone.utc).isoformat(),
              'registered_rows':512,'admitted_rows':367,'primary_admitted_pairs':214,
              'tests':receipt['tests'],'scope':'Frozen source/code/intake baseline, not semantic certification or experiment results.',
              'files':{p.relative_to(output).as_posix():digest(p) for p in sorted(output.rglob('*')) if p.is_file()},
              'new_model_calls':0,'new_planner_calls':0}
    save(output/'manifest.json',manifest)
    (output/'MANIFEST.sha256').write_text(digest(output/'manifest.json')+'\n',encoding='utf-8')
    print(json.dumps({'status':manifest['status'],'files':len(manifest['files']),'tests':receipt['tests']}))


def check(release,output):
    if output.exists(): raise ValueError('Fresh independent verification output required')
    from rcnc import glaive_merge
    if not Path(glaive_merge.__file__).resolve().is_relative_to(release/'code'):
        raise ValueError('Verification must import the frozen code: run this module from release/code')
    manifest=read(release/'manifest.json')
    assert manifest['status']=='frozen_narrative_baseline'
    assert digest(release/'manifest.json')==(release/'MANIFEST.sha256').read_text(encoding='utf-8').strip()
    for path,sha in manifest['files'].items():
        target=(release/path).resolve()
        assert target.is_relative_to(release) and digest(target)==sha,path
    catalog=read(release/'source_catalog.json')
    assert len(catalog['rows'])==len({x['id'] for x in catalog['rows']})==512
    assert sum(x['single_domain_pass'] for x in catalog['rows'])==367
    receipt=read(release/'full_test_receipt.json')
    assert receipt['code_sha256']==code_fingerprint(release/'code')
    output.mkdir(parents=True)
    rebuilt=[]
    for row in catalog['rows']:
        if not row['single_domain_pass']: continue
        source=glaive_merge.Source(row['source_id'],release/row['source_inputs']['domain']['path'],
            release/row['source_inputs']['problem']['path'],constant_contract=row['constant_contract'],consent_policy=row.get('consent_policy'))
        folder=output/'rebuilt'/row['id']
        meta=glaive_merge.build([source],folder)
        glaive_merge.map_problem([source],source.id,meta,folder/'problem.pddl')
        for name,wanted in row['exported'].items(): assert digest(folder/name)==wanted['sha256'],(row['id'],name)
        rebuilt.append({'id':row['id'],'status':'byte_identical_rebuild','pool':row['pool']})
    assert len(rebuilt)==367
    for path,sha in manifest['files'].items(): assert digest(release/path)==sha
    report={'status':'verified_frozen_baseline','release':str(release),'manifest_sha256':digest(release/'manifest.json'),
            'frozen_files_verified':len(manifest['files']),'registered_rows':512,'registered_rebuilds':367,'rows':rebuilt,
            'counts':dict(Counter(x['status'] for x in rebuilt)),'all_rebuilds_byte_identical':True,'snapshot_unchanged':True,
            'used_frozen_code':True,'tests':receipt['tests'],'new_model_calls':0,'new_planner_calls':0,
            'scope':'Integrity and deterministic reconstruction of admitted single-source exports; no new planner search or semantic labels.'}
    save(output/'report.json',report)
    print(json.dumps({k:v for k,v in report.items() if k!='rows'}))


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode',choices=['prepare','seal','verify'])
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--release',type=Path)
    parser.add_argument('--test-log',type=Path)
    args=parser.parse_args()
    if args.mode=='prepare': prepare(args.output.resolve())
    elif args.mode=='seal': seal(args.output.resolve(),args.test_log.resolve())
    else: check(args.release.resolve(),args.output.resolve())

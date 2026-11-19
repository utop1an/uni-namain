"""Freeze k=2/3/4/5 random/path selections separately for learned/human domains."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import platform
import subprocess

from rcnc.causal_path_selection import (
    SIZES, RANK_FIELDS, action_graph, census_pairs, path_inventory, select_comparison,
)
from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.glaive_merge import Source

REPO = Path(__file__).resolve().parents[2]
STORY = REPO / 'data/benchmarks/revised_multistory_balanced_2026_11_01_v1'
HUMAN = REPO / 'data/human_narrative_domains_2026_11_04_v1'
ADMISSION = REPO / 'data/validation/human_single_domain_round2_2026_11_05_v3'
SEED = 'selection-comparison-k2345-n50-20261105-v1'
# One representative per known family; original/plain precedes compiled/robust
# variants, official sources precede mirrors. No planning results enter this map.
HUMAN_REPRESENTATIVES = {
    'rooms': 'src_009', 'ark': 'src_012', 'best_laid_plans': 'src_013',
    'fantasy': 'src_014', 'heist': 'src_015', 'space': 'src_016',
    'batman': 'src_025', 'aladdin': 'src_035', 'basketball': 'src_036',
    'hospital': 'src_037', 'red_riding_hood': 'src_038', 'western': 'src_039',
}


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def source_census(sources):
    pairs, excluded = census_pairs(sources)
    # JSON arrays replace tuples (notably directed_edges) on disk. Compare the
    # persisted representation when verifying a freshly generated census.
    return json.loads(json.dumps(pairs)), excluded


def enumerate_paths(graph, policy):
    limits = policy['path_limits']
    return path_inventory(graph, max_sources=limits['max_sources'],
                          max_local_hops=limits['max_local_hops'],
                          max_visits=limits['max_enumerated_prefixes'])


def copy_checked(original, target, expected=None):
    data = original.read_bytes()
    import hashlib
    checksum = hashlib.sha256(data).hexdigest()
    if expected is not None and checksum != expected:
        raise ValueError('Changed input: ' + str(original))
    if target.exists():
        raise ValueError('Refusing to overwrite: ' + str(target))
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(data)
    return checksum


def provenance(root):
    paths = [STORY / name for name in ('protocol.json', 'cohort.json', 'freeze.json', 'FREEZE.sha256')]
    paths += [HUMAN / name for name in ('manifest.json', 'catalog.json', 'structural_inventory.json', 'README.md')]
    paths += [ADMISSION / name for name in ('protocol.json', 'PROTOCOL.sha256', 'report.json',
              'admitted_domains.json', 'constant_contracts.json', 'verification.json')]
    paths += [REPO / name for name in (
        'data/validation/causal_multistory_2026_11_04_v1/selection_report.json',
        'data/validation/causal_multistory_2026_11_04_v1/report.json',
        'data/validation/causal_chains_2026_11_05_v2/report.json',
        'data/validation/causal_chains_k04_expanded_2026_11_05_v1/report.json',
        'data/validation/human_language_traces_2026_11_05_v1/report.json')]
    result = []
    for original in paths:
        target = root / 'provenance' / original.relative_to(REPO)
        checksum = copy_checked(original, target)
        result.append({'original': str(original), 'copy': target.relative_to(root).as_posix(),
                       'sha256': checksum, 'role': 'historical_context_not_selection_outcomes'})
    return result


def story_sources(root):
    freeze = read(STORY / 'freeze.json')
    if digest(STORY / 'freeze.json') != (STORY / 'FREEZE.sha256').read_text(encoding='utf-8').split()[0]:
        raise ValueError('Story freeze manifest changed')
    for name, checksum in freeze['artifact_sha256'].items():
        if digest(STORY / name) != checksum:
            raise ValueError('Story frozen artifact changed: ' + name)
    cohort = read(STORY / 'cohort.json')
    sources, rows, worlds = {}, [], []
    for old in cohort['sources']:
        if not old['included']:
            continue
        sid, files = old['id'], {}
        for name, item in old['files'].items():
            target = root / 'story_learned/sources' / sid / name
            checksum = copy_checked(STORY / item['frozen_path'], target, item['sha256'])
            files[name] = {'path': target.relative_to(root).as_posix(), 'sha256': checksum,
                           'upstream_path': item['upstream_path']}
        domain, problem = (files[n]['path'] for n in ('revised-domain.pddl', 'revised-problem.pddl'))
        sources[sid] = Source(sid, root / domain, root / problem)
        wid = sid + '__original'
        rows.append({'id': sid, 'family': sid, 'corpus': old['corpus'], 'domain': domain,
                     'representative_problem': problem, 'constant_contract': {},
                     'world_ids': [wid], 'files': files,
                     'upstream_id': old['upstream_id'], 'admission': 'unchanged_60_source_legacy_pool'})
        worlds.append({'id': wid, 'source': sid, 'problem': problem,
                       'current_source_load': 'passed', 'explicit_initial_state': True,
                       'initial_facts_pooled': False})
    if len(sources) != 60:
        raise ValueError('Changed 60-source story cohort')
    return sources, rows, worlds, {'historical_published_records': len(cohort['sources']),
        'historical_excluded_records': sum(not r['included'] for r in cohort['sources']),
        'source_pool': len(rows), 'prior_freeze_verified_artifacts': len(freeze['artifact_sha256'])}


def human_sources(root):
    protocol = read(ADMISSION / 'protocol.json')
    if digest(ADMISSION / 'protocol.json') != (ADMISSION / 'PROTOCOL.sha256').read_text(encoding='utf-8').split()[0]:
        raise ValueError('Human admission protocol changed')
    report = read(ADMISSION / 'report.json')
    if report['status'] != 'complete' or len(report['rows']) != 113:
        raise ValueError('Incomplete human admission inventory')
    # Preserve the whole published text collection, including rejected and duplicate models.
    for item in read(HUMAN / 'manifest.json')['files']:
        copy_checked(HUMAN / item['local_path'], root / 'human_authored/upstream' / item['local_path'], item['sha256'])
    by_id = {d['source_id']: d for d in report['domains']}
    historical_cases = {r['id']: r for r in report['rows']}
    selected = set(HUMAN_REPRESENTATIVES.values())
    sources, rows, worlds, representatives = {}, [], [], []
    for family, original_sid in sorted(HUMAN_REPRESENTATIVES.items()):
        d = by_id[original_sid]
        if not d['passed_pairs']:
            raise ValueError('Representative is not admitted: ' + family)
        sid = 'human_' + family
        cases = [historical_cases[c] for c in d['cases']]
        representative = next(c for c in cases if c['single_domain_pass'])
        target = root / 'human_authored/sources' / sid / 'domain.pddl'
        checksum = copy_checked(HUMAN / d['domain'], target, d['raw_sha256'])
        files = {'domain.pddl': {'path': target.relative_to(root).as_posix(), 'sha256': checksum}}
        world_ids = []
        representative_problem = None
        for case in cases:
            wid = sid + '__' + case['id']
            problem = root / 'human_authored/sources' / sid / 'problems' / (case['id'] + '.pddl')
            checksum = copy_checked(HUMAN / case['problem'], problem,
                protocol['sha256'][str((HUMAN / case['problem']).resolve())])
            relative = problem.relative_to(root).as_posix()
            files['problems/' + case['id'] + '.pddl'] = {'path': relative, 'sha256': checksum}
            row = {'id': wid, 'source': sid, 'problem': relative, 'original_path': case['problem'],
                   'historical_case': case['id'], 'historical_parse_pass': case['single_domain_pass'],
                   'historical_status': case['conversion'], 'explicit_initial_state': True,
                   'initial_facts_pooled': False}
            try:
                source = Source(sid, target, problem, constant_contract=d['constant_contract'])
                row.update(current_source_load='passed', normalization=source.normalization)
            except ValueError as exc:
                row.update(current_source_load='unsupported_or_invalid', reason=str(exc))
            worlds.append(row)
            world_ids.append(wid)
            if case['id'] == representative['id']:
                if row['current_source_load'] != 'passed':
                    raise ValueError('Current representative load failed: ' + sid)
                representative_problem = relative
                sources[sid] = source
        rows.append({'id': sid, 'family': family, 'original_source_id': original_sid,
            'collection': d['collection'], 'original_domain': d['domain'],
            'domain': target.relative_to(root).as_posix(), 'representative_problem': representative_problem,
            'constant_contract': d['constant_contract'], 'world_ids': world_ids, 'files': files,
            'admission': 'latest_parse_admission_not_plan_or_semantic_validation'})
        representatives.append({'family': family, 'representative_source_id': original_sid,
            'canonical_source_sha256': d['canonical_source_sha256']})
    decisions = []
    canonical_to_family = {r['canonical_source_sha256']: r['family'] for r in representatives}
    family_variants = {'src_007': 'rooms', 'src_026': 'batman'}
    for d in report['domains']:
        if d['source_id'] in selected:
            status, family = 'included_representative', next(k for k, v in HUMAN_REPRESENTATIVES.items() if v == d['source_id'])
        elif not d['passed_pairs']:
            status, family = 'excluded_latest_language_admission', None
        elif d['canonical_source_sha256'] in canonical_to_family:
            status, family = 'excluded_duplicate_canonical_model', canonical_to_family[d['canonical_source_sha256']]
        elif d['source_id'] in family_variants:
            status, family = 'excluded_same_family_variant', family_variants[d['source_id']]
        else:
            raise ValueError('Unaccounted admitted domain: ' + d['domain'])
        decisions.append({**d, 'freeze_decision': status, 'family': family})
    save(root / 'human_authored/cohort_decisions.json', {'domains': decisions,
        'policy': 'Conservative known-family deduplication; no independent-family claim inferred from hashes.'})
    if len(sources) != 12 or len({r['canonical_source_sha256'] for r in representatives}) != 12:
        raise ValueError('Unexpected human family cohort')
    return sources, rows, worlds, {'registered_domain_files': 46, 'registered_original_pairs': 113,
        'admitted_domain_files': 20, 'admitted_canonical_models': 14, 'source_pool': 12,
        'cohort_decisions': dict(Counter(d['freeze_decision'] for d in decisions)),
        'selected_original_worlds': len(worlds),
        'retained_historical_failed_worlds': sum(not w['historical_parse_pass'] for w in worlds)}


def freeze(root, *, count=50, seed=SEED):
    if root.exists():
        raise ValueError('Fresh versioned output directory required')
    root.mkdir(parents=True)
    policy = {'status': 'registered_before_selection', 'created_utc': datetime.now(timezone.utc).isoformat(),
        'sizes': list(SIZES), 'groups_per_cell': count, 'seed': seed,
        'methods': ['random', 'causal_path'], 'cohorts': ['story_learned', 'human_authored'],
        'random': 'Uniform sampling without replacement over unordered domain combinations; independent seed per cohort/k; no balance/nesting constraint.',
        'causal_rank': list(RANK_FIELDS), 'human_representatives': HUMAN_REPRESENTATIVES,
        'candidate_caps_per_pair': {'predicate': 8, 'action': 4},
        'path_limits': {'max_sources': 5, 'max_local_hops': 2, 'max_enumerated_prefixes': 2_000_000},
        'path_contract': ['Positive ordinary variable-only STRIPS action fragment, predicate arity <=6.',
            'Cross-source candidates require lexical overlap and potential type compatibility; no prior semantic judgments.',
            'Action-level directed simple paths, contiguous source blocks; no source revisit, at most k+2 actions.',
            'Count each distinct action-node sequence once; path ends on first entry to the final source.',
            'Highest covered source count first. If fewer than N full-k-path groups, retain best partial/zero-path groups explicitly.',
            'No initial-world, goal, plan, model response, success rate or historical composition outcome enters ranking.'],
        'evaluation_contract': ['All selected source worlds remain separate, including failed/unsupported worlds.',
            'No repeated domain within a combination and no duplicate combinations within a cell.',
            'Random/causal overlap is allowed and reported. Reused domains/groups are correlated evidence.',
            'Source membership and constant contracts are explicit; cross-source entity identity is not inferred.',
            'This freezes selection inputs, candidate mappings and separate original worlds only.',
            'Before experiment execution, separately freeze semantic decisions, reusable merged domains/mappings, explicit cross-source worlds and execution budgets.',
            'No planning/semantic success or full executable causal chain is asserted by a path candidate.'],
        'calls_performed': {'model': 0, 'planner': 0, 'replay': 0}}
    save(root / 'selection_policy.json', policy)
    history = provenance(root)
    cells, all_groups, cohorts = [], [], {}
    for cohort, loader in [('story_learned', story_sources), ('human_authored', human_sources)]:
        sources, rows, worlds, intake = loader(root)
        folder = root / cohort
        save(folder / 'sources.json', {'sources': rows, 'intake': intake})
        save(folder / 'worlds.json', {'worlds': worlds})
        print(cohort, 'sources', len(sources), 'worlds', len(worlds), 'building source-only graph', flush=True)
        pairs, excluded = source_census(sources)
        graph = action_graph(sources, pairs)
        paths = enumerate_paths(graph, policy)
        selection = select_comparison(sources, pairs, paths, cohort=cohort, count=count, seed=seed)
        save(folder / 'pair_census.json', {'pairs': pairs, 'excluded_scoring_actions': excluded})
        save(folder / 'action_graph.json', graph)
        save(folder / 'path_inventory.json', paths)
        save(folder / 'groups.json', {'groups': selection['groups']})
        save(folder / 'coverage.json', {k: v for k, v in selection.items() if k != 'groups'})
        by_source = {r['id']: r for r in rows}
        query_slots = []
        for group in selection['groups']:
            for sid in group['sources']:
                for wid in by_source[sid]['world_ids']:
                    query_slots.append({'id': group['id'] + '__' + wid, 'group': group['id'],
                                        'source': sid, 'world': wid})
        save(folder / 'original_world_slots.json', {'slots': query_slots,
            'scope': 'Logical source-world/group units, not executed planner calls; retain every unsupported slot.'})
        for method in policy['methods']:
            for k in SIZES:
                destination = folder / method / f'k{k:02d}'
                destination.mkdir(parents=True)
                save(destination / 'groups.json', {'groups': [g for g in selection['groups']
                                                           if g['method'] == method and g['size'] == k]})
        all_groups.extend(selection['groups'])
        cells.extend(selection['cells'])
        cohorts[cohort] = {**intake, 'worlds': len(worlds), 'groups': len(selection['groups']),
            'pair_census': len(pairs), 'graph_edges': len(graph['edges']),
            'path_prefixes': paths['visited_prefixes'], 'original_world_group_slots': len(query_slots),
            'method_overlap': selection['method_overlap']}
        print(cohort, 'frozen selections', len(selection['groups']), flush=True)
    save(root / 'groups.json', {'groups': all_groups})
    summary = {'status': 'frozen_selection_data_only', 'groups': len(all_groups),
               'cells': cells, 'cohorts': cohorts, 'calls_performed': policy['calls_performed']}
    save(root / 'summary.json', summary)
    implementations = sorted((REPO / 'rcnc').glob('*.py')) + [Path(__file__), REPO / 'tests/test_selection_comparison.py']
    hashes = snapshot_implementation(root, implementations, root=REPO)
    git = subprocess.run(['git', 'rev-parse', 'HEAD'], cwd=REPO, capture_output=True, text=True, check=True).stdout.strip()
    save(root / 'protocol.json', {**policy, 'status': 'frozen_data_only', 'total_groups': len(all_groups),
        'cohort_summary': cohorts, 'provenance': history, 'implementation_sha256': hashes,
        'git_head': git, 'working_tree': 'dirty; implementation snapshots are authoritative',
        'python': platform.python_version(), 'platform': platform.platform()})
    lines = ['# 领域选择实验数据冻结：2026-11-05', '',
        f'每格 {count} 个不重复组合；2 类来源 × 2 种方法 × k=2/3/4/5，共 {len(all_groups)} 个登记组合。', '',
        'Story-learned 沿用 60 个已准入 GPT-4 revised 源；人工领域按已知家族去重为 12 个。',
        '原始 domain/problem 逐字节保留。人工 46 个文件／113 个配对的排除和重复版本记录完整保留；入选来源的失败问题也保留。', '',
        '| 来源 | 方法 | k | 组合 | 覆盖全部 k 域的路径候选 |', '|---|---|---:|---:|---:|']
    for cell in cells:
        lines.append(f"| {cell['cohort']} | {cell['method']} | {cell['k']} | {cell['registered_groups']} | {cell['selected_full_k_path_groups']} |")
    lines += ['', '随机方法：固定种子的均匀无放回抽样；各 k 分别抽样，不沿用旧版嵌套均衡抽样。',
        '因果方法：先按动作路径覆盖的来源数，再按路径数量、最短见证长度和接口统计排序。每条路径最多 k+2 个动作，允许两个域内衔接动作。',
        '完整 k 域路径不足时按同一规则保留部分覆盖组合；full_k_path_candidate=false，不能解读为完整因果链。',
        '路径只使用源模型中的候选谓词连接，没有采用既有 LLM 判断或成功计划。词汇、类型和支持片段会漏掉其他可能接口。',
        '所有路径仅为结构性候选；尚未验证语义等价、全链变量绑定一致性、可执行性、意图保持或叙事质量。', '',
        '文件：groups.json 为完整名单；各来源下 random/causal_path/k02..k05/groups.json 为分格名单。',
        'sources.json、worlds.json、original_world_slots.json 保存来源及独立原始世界；pair_census.json、action_graph.json、path_inventory.json 保存候选与路径依据。',
        'selection_policy.json 为选择前登记规则；protocol.json、freeze.json、FREEZE.sha256 与 implementation/ 固定规则、输入和代码。',
        '本轮只准备和冻结数据：模型调用 0，规划调用 0，计划回放 0。后续执行前另冻结融合决策、参数化模型、显式跨域问题及执行预算。', '',
        '复核命令：', '```powershell',
        '.venv/Scripts/python.exe -m scripts.data.freeze_selection_comparison verify --output ' + root.relative_to(REPO).as_posix(),
        '```', '']
    (root / 'README.md').write_text('\n'.join(lines), encoding='utf-8')
    artifacts = {p.relative_to(root).as_posix(): digest(p) for p in sorted(root.rglob('*')) if p.is_file()}
    save(root / 'freeze.json', {'status': 'frozen', 'artifact_sha256': artifacts})
    (root / 'FREEZE.sha256').write_text(digest(root / 'freeze.json') + '  freeze.json\n', encoding='utf-8')
    return verify(root)


def verify(root):
    expected = (root / 'FREEZE.sha256').read_text(encoding='utf-8').split()[0]
    if digest(root / 'freeze.json') != expected:
        raise ValueError('Freeze manifest changed')
    manifest = read(root / 'freeze.json')
    for name, checksum in manifest['artifact_sha256'].items():
        if digest(root / name) != checksum:
            raise ValueError('Frozen artifact changed: ' + name)
    protocol = read(root / 'protocol.json')
    for name, checksum in protocol['implementation_sha256'].items():
        if digest(REPO / name) != checksum:
            raise ValueError('Current implementation differs; use frozen implementation for regeneration: ' + name)
    count, seed = protocol['groups_per_cell'], protocol['seed']
    combined, cells = [], []
    for cohort in protocol['cohorts']:
        folder = root / cohort
        source_rows = read(folder / 'sources.json')['sources']
        sources = {r['id']: Source(r['id'], root / r['domain'], root / r['representative_problem'],
                                  constant_contract=r['constant_contract']) for r in source_rows}
        pairs, excluded = source_census(sources)
        if {'pairs': pairs, 'excluded_scoring_actions': excluded} != read(folder / 'pair_census.json'):
            raise ValueError('Pair census cannot be reproduced')
        graph = action_graph(sources, pairs)
        paths = enumerate_paths(graph, protocol)
        if graph != read(folder / 'action_graph.json') or paths != read(folder / 'path_inventory.json'):
            raise ValueError('Action paths cannot be reproduced')
        selection = select_comparison(sources, pairs, paths, cohort=cohort, count=count, seed=seed)
        if selection['groups'] != read(folder / 'groups.json')['groups']:
            raise ValueError('Selection cannot be reproduced')
        if {k: v for k, v in selection.items() if k != 'groups'} != read(folder / 'coverage.json'):
            raise ValueError('Selection coverage cannot be reproduced')
        for method in protocol['methods']:
            for k in protocol['sizes']:
                rows = [g for g in selection['groups'] if g['method'] == method and g['size'] == k]
                if len(rows) != count or len({tuple(r['sources']) for r in rows}) != count:
                    raise ValueError('Cell count or uniqueness violation')
                if rows != read(folder / method / f'k{k:02d}/groups.json')['groups']:
                    raise ValueError('Per-cell manifest mismatch')
        expected_slots = [(g['id'], sid, wid) for g in selection['groups'] for sid in g['sources']
                          for r in source_rows if r['id'] == sid for wid in r['world_ids']]
        slots = read(folder / 'original_world_slots.json')['slots']
        if [(s['group'], s['source'], s['world']) for s in slots] != expected_slots:
            raise ValueError('Missing original-world evaluation slot')
        combined.extend(selection['groups'])
        cells.extend(selection['cells'])
    if combined != read(root / 'groups.json')['groups']:
        raise ValueError('Combined group registry mismatch')
    summary = read(root / 'summary.json')
    if cells != summary['cells'] or summary['groups'] != len(combined):
        raise ValueError('Summary denominator mismatch')
    if len(combined) != 2 * 2 * 4 * count or len({g['id'] for g in combined}) != len(combined):
        raise ValueError('Overall denominator mismatch')
    if protocol['calls_performed'] != {'model': 0, 'planner': 0, 'replay': 0}:
        raise ValueError('Unexpected execution status')
    return {'status': 'verified', 'groups': len(combined), 'cells': len(cells),
            'groups_per_cell': count, 'frozen_artifacts_checked': len(manifest['artifact_sha256']),
            'reproduced_random_and_causal_selection': True, 'freeze_sha256': expected,
            'calls_performed': protocol['calls_performed']}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=('prepare', 'verify'))
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--groups-per-cell', type=int, default=50)
    parser.add_argument('--seed', default=SEED)
    args = parser.parse_args()
    destination = args.output.resolve()
    result = (freeze(destination, count=args.groups_per_cell, seed=args.seed)
              if args.mode == 'prepare' else verify(destination))
    print(json.dumps(result, ensure_ascii=False, indent=2))

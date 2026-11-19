"""Verify a completed coverage census and attach separate historical evidence."""
import argparse
from collections import Counter
import hashlib
from pathlib import Path
import json

from rcnc.domain_building import digest, save
from scripts.audit.audit_all_narrative_coverage import HUMAN_RESULT, LEARNED, RELEASE, summarize
from scripts.audit.recheck_human_single_domain import REPO, read, verify
from scripts.audit.separate_narrative_packages import load_adapters


def finish(output):
    if (output / 'coverage_summary.json').exists(): raise ValueError('Summary already exists')
    r = read(output / 'report.json'); p = read(output / 'protocol.json')
    assert r['status'] == 'complete' and len(r['rows']) == len({x['id'] for x in r['rows']}) == 512
    assert r.get('no_admission_regressions', r['human_matches_round2'])
    assert digest(output / 'protocol.json') == (output / 'PROTOCOL.sha256').read_text(encoding='utf-8').strip()
    verify(p['sha256']); verify(p['historical_sha256']); verify(read(output / 'conversion_hashes.json'))
    assert dict(Counter(x['status'] for x in r['rows'])) == r['counts']
    assert [(x['id'], x['domain'], x['problem']) for x in p['rows']] == [(x['id'], x['domain'], x['problem']) for x in r['rows']]
    for row in r['rows']:
        assert read(output / row['id'] / 'row.json') == row
        for key, folder in [('native', 'native_inspect'), ('converted_native', 'converted_inspect')]:
            if key in row and 'input_sha256' in row[key]:
                assert read(output / row['id'] / folder / 'result.json') == row[key]
                verify(row[key]['input_sha256'])
    for pool, value in r['pools'].items(): assert summarize([x for x in r['rows'] if x['pool'] == pool]) == value
    packaging = {'selected': 0, 'lossless_verified': 0, 'passed': 0, 'plans_preserved': 0, 'rows': []}
    if p.get('source_adapters'):
        adapters, _ = load_adapters(Path(p['source_adapters']), r['rows'])
        assert set(adapters) == set(r['packaging_adapted_rows']) == set(p['packaging_adapted_rows'])
        for row in r['rows']:
            if row['id'] not in adapters: continue
            adapter = adapters[row['id']]
            for kind in ('domain', 'problem'):
                assert row['effective_' + kind] == adapter['effective_' + kind]
                assert row['effective_' + kind + '_sha256'] == digest(Path(adapter['effective_' + kind]))
            if row['conversion'] == 'exported':
                # Model/initial state conversion consumes only extracted model paths.
                mapping = read(output / row['id'] / 'model/mapping.json')
                for kind in ('domain', 'problem'):
                    assert mapping['source_sha256'][row['source_id']][kind] == row['effective_' + kind + '_sha256']
            packaging['rows'].append({'id': row['id'], 'passed': row['single_domain_pass'],
                                      'status': row['status'], 'reason': row.get('reason'),
                                      'plan_preserved': bool(adapter['plan'])})
        packaging.update(selected=len(adapters), lossless_verified=len(adapters),
                         passed=sum(x['passed'] for x in packaging['rows']),
                         plans_preserved=sum(x['plan_preserved'] for x in packaging['rows']),
                         manifest=p['source_adapters'], plan_validation='not_performed', model_repairs=0)
    admission_paths, export_errors = {}, []
    for pool in r['pools']:
        rows = [x for x in r['rows'] if x['pool'] == pool]
        admission_paths[pool] = {
            'native_and_export_pass': [x['id'] for x in rows if x['native']['status'] == 'parsed' and x['single_domain_pass']],
            'native_pass_export_not_pass': [x['id'] for x in rows if x['native']['status'] == 'parsed' and not x['single_domain_pass']],
            'native_not_pass_export_pass': [x['id'] for x in rows if x['native']['status'] != 'parsed' and x['single_domain_pass']]}
        for row in rows:
            if row['status'] == 'export_parse_failure':
                log = output / row['id'] / 'converted_inspect/stdout.txt'
                export_errors.append({'id': row['id'], 'pool': pool, 'native_status': row['native']['status'],
                                      'export_status': row['converted_native']['status'],
                                      'diagnostic': log.read_text(encoding='utf-8'), 'log_sha256': digest(log)})
    # These are historical results, whose artifacts and correspondence are
    # verified here. No new planning or replay is implied by reading them.
    manifest = read(RELEASE / 'manifest.json')
    verify({str(RELEASE / path): sha for path, sha in manifest['files'].items()})
    released = read(RELEASE / 'sources.json')['sources']
    revised = {x['story_id']: x for x in r['rows'] if x['pool'] == 'learned_revised'}
    original = {x['story_id']: x for x in r['rows'] if x['pool'] == 'learned_original'}
    assert set(revised) == set(original) and len(revised) == 192
    for x in released:
        source = revised[x['id']]
        assert source['domain_sha256'] == x['domain.pddl']['sha256']
        assert source['problem_sha256'] == x['problem.pddl']['sha256']
    selected = {x['id'] for x in released}
    native = read(RELEASE / 'native_results.json')['rows']
    transports = read(RELEASE / 'transport_results.json')['rows']
    native_good = {x['source'] for x in native if x['validated']}
    transport_good = {x['source'] for x in transports if x['validated'] and x['condition'] == 'full'}
    groups = read(RELEASE / 'group_metrics.json')['rows']
    merged = {kind: sorted({ref.split(':')[0] for g in groups for sig in g[kind + '_signatures'] for ref in sig})
              for kind in ('predicate', 'action')}
    current_admitted = {key for key, row in revised.items() if row['single_domain_pass']}
    historical = {'condition': 'historical_single_interrupted_continuation; not a fresh experiment in this audit',
                  'selected_sources': len(selected), 'selected_source_ids': sorted(selected),
                  'selected_still_admitted': len(selected & current_admitted),
                  'current_admitted_not_in_historical_selected_set': sorted(current_admitted - selected),
                  'historical_selected_not_currently_admitted': sorted(selected - current_admitted),
                  'native_plan_validated_sources': len(native_good), 'native_plan_validated_ids': sorted(native_good),
                  'full_transport_validated_sources': len(transport_good), 'full_transport_validated_ids': sorted(transport_good),
                  'sources_participating_in_predicate_merges': merged['predicate'],
                  'sources_participating_in_action_merges': merged['action'],
                  'registered_groups': len(groups), 'verified_release_files': len(manifest['files']),
                  'native_source_status_counts': dict(Counter(x['search_status'] for x in native)),
                  'new_model_calls': 0, 'new_search_calls': 0, 'new_plan_replay_calls': 0,
                  'independent_semantic_labels': 0}
    trace_path = REPO / 'data/validation/human_language_traces_2026_11_05_v1/report.json'
    traces = read(trace_path)
    human_followup = REPO / 'data/validation/human_narrative_repeat01_local_followup_2026_11_04_v1/report.json'
    human_parent = REPO / 'data/validation/human_narrative_repeat01_2026_11_04_v1/protocol.json'
    hp = read(human_parent); hf = read(human_followup)
    for source in hp['source_rows']:
        for entry in source['files'].values(): assert digest(Path(entry['frozen_path'])) == entry['sha256']
    human_history = {'registered_earlier_merge_sources': hp['sources'],
                     'source_names': [s['id'] for s in hp['source_rows']],
                     'condition': hf['condition'], 'reported_native_status': hf['result']['native_counts'],
                     'successful_original_plan_transports': sum(c['transport_passed'] for size in hf['result']['by_size_condition'].values() for c in size.values()),
                     'round2_trace_tasks': 6, 'round2_trace_comparisons': len(traces['comparisons']),
                     'round2_trace_comparison_counts': traces['comparison_counts'],
                     'round2_matched_single_domain_tasks': [c['task'] for c in traces['comparisons'] if c['status'] == 'trace_match'],
                     'scope': 'Historical three-source merge attempt and separate reference traces; no broader preservation claim'}
    legacy_audit_path = REPO / 'data/validation/story_opportunities_audit_2026_10_31_v1/report.json'
    legacy_audit = read(legacy_audit_path)
    texts, upstream_models = [], Counter()
    for source in read(LEARNED / 'protocol.json')['sources']:
        folder = LEARNED / 'upstream/results/runs' / source['upstream_id']
        texts.append(hashlib.sha256(' '.join((folder / 'input.txt').read_text(encoding='utf-8').split()).encode('utf-8')).hexdigest())
        metadata = read(folder / 'metadata.json')
        for variant in ('original', 'revised'): upstream_models[variant + ':' + str(metadata.get(variant, {}).get('model_name'))] += 1
    paired = Counter()
    for key, row in revised.items():
        o, v = original[key]['single_domain_pass'], row['single_domain_pass']
        paired['both' if o and v else 'original_only' if o else 'revised_only' if v else 'neither'] += 1
    lineage = {'published_story_records': len(revised), 'normalized_unique_story_texts': len(set(texts)),
               'corpora': dict(Counter(x['collection'] for x in revised.values())),
               'upstream_model_counts': dict(upstream_models), 'variant_admission_overlap': dict(paired),
               'variant_union_is_not_primary_coverage': paired['both'] + paired['original_only'] + paired['revised_only'],
               'legacy_upstream_verified': 0, 'legacy_records': 15,
               'excluded_non_narrative_controls': ['external/prospective_sources', 'external/formal_merge_intake', 'external/transport_merge', 'external/action_merge_candidates'],
               'excluded_generated_artifact_copies': ['merged_*', 'research_release sources', 'benchmarks/revised_multistory_balanced', 'validation outputs'],
               'scope': 'All local registered narrative source pools; not all narrative domains available worldwide'}
    evidence = [RELEASE / 'manifest.json', RELEASE / 'sources.json', RELEASE / 'native_results.json', RELEASE / 'transport_results.json',
                RELEASE / 'group_metrics.json', trace_path, human_followup, human_parent, legacy_audit_path]
    hashes = {str(x): digest(x) for x in evidence}
    problem_intention_adapters = []
    priority1_normalizations = []
    for row in r['rows']:
        if row['conversion'] != 'exported': continue
        mapping = read(output / row['id'] / 'model/mapping.json')
        interpretation = mapping['normalization'][row['source_id']].get('problem_intentionality', {})
        if interpretation.get('declarations'):
            problem_intention_adapters.append({'id':row['id'], 'passed':row['single_domain_pass'], **interpretation})
        normalization = mapping['normalization'][row['source_id']]
        priority = {k: normalization[k] for k in ('type_self_inheritance', 'action_consent') if k in normalization}
        if priority: priority1_normalizations.append({'id': row['id'], 'passed': row['single_domain_pass'], **priority})
    summary = {'status': 'verified_coverage_audit', 'registered_version_rows': 512,
               'pools': r['pools'], 'by_collection': r['by_collection'], 'lineage': lineage,
               'native_to_export_admission': admission_paths, 'export_parse_errors': export_errors,
               'comparison': r.get('comparison', {}), 'runtime_condition': p.get('runtime_condition'),
               'problem_intention_adapters': problem_intention_adapters,
               'packaging_adapters': packaging,
               'priority1_normalizations': priority1_normalizations,
               'historical_learned_experiments': historical, 'historical_human_evidence': human_history,
               'legacy_historical_evidence': {'status': legacy_audit['status'], 'by_unit': legacy_audit['by_unit'],
                                               'scope': 'Known local development material with unverified learning provenance'},
               'inputs_unchanged': True, 'exports_unchanged': True, 'historical_outputs_unchanged': True,
               'human_matches_round2': r['human_matches_round2'], 'historical_source_bytes_match_current_records': True,
               'evidence_sha256': hashes, 'model_calls': 0, 'search_calls': 0, 'plan_replay_calls': 0,
               'scope': 'Current parser/export coverage with separately labeled historical behavior evidence; no aggregate semantic success rate'}
    save(output / 'coverage_summary.json', summary)
    names = {'human': '人工叙事域', 'learned_revised': 'Story 学习：修订版（主口径）',
             'learned_original': 'Story 学习：原始版（单独对照）', 'legacy_unverified': '旧故事域（来源未核实）'}
    lines = ['全部本地叙事域覆盖率复核（2026-11-05）', '',
             '固定 512 条版本记录，每个非空原域和每个成功导出均使用同一 corrected Glaive 运行时解析；每次 10 秒、一次尝试。',
             '人工 113 配对、学习域 192 个故事的两个版本、旧故事 15 配对。两个学习版本不可算作 384 个独立故事。',
             '学习库中 TinyStories 100 条、WritingPrompts 92 条；共 192 条公开记录，192 个规范化去重故事文本。不能用计划中的 200 或历史筛选的 60 代替总体分母。', '',
             '| 来源 | 登记配对 | 原域解析 | 导出完成 | 导出解析通过 | 覆盖率 |', '|---|---:|---:|---:|---:|---:|']
    for pool, stats in r['pools'].items():
        lines.append(f"| {names[pool]} | {stats['pairs']} | {stats['raw_parsed']} | {stats['exported']} | {stats['passed']} | {stats['pass_percent']:.2f}% |")
    if r.get('comparison'):
        lines += ['', '与上一轮固定 512 项比较：', '']
        for pool, comparison in r['comparison'].items():
            lines.append(f"- {names[pool]}：{comparison['baseline_passed']} → {r['pools'][pool]['passed']}；新增 {len(comparison['newly_passed'])}，退化 {len(comparison['regressed'])}。")
        lines += ['', '本轮运行时条件：' + str(p.get('runtime_condition')),
                  '运行时已包含意图内部目标的校验，以及状态空间使用已实例化的初始状态／目标；旧运行时及所有旧结果保留。',
                  '导出的 problem 显式声明 :adl/:intentionality；普通谓词名 exists 与真正量词按语法结构和声明区分。']
    if packaging['selected']:
        lines += ['', '混合内容分离：',
                  f"- 预先指定 {packaging['selected']} 条记录，全部逐字节分离并通过重组校验；保留 {packaging['plans_preserved']} 份计划，其余说明与分隔符单独存放。",
                  f"- 分离后 {packaging['passed']}/{packaging['selected']} 条通过导出解析；原始路径、原始解析和旧失败仍保留。",
                  '- 本轮沿用上一轮同一运行时。模型内容不作修复，计划和说明不用于构造初始状态、目标或动作；没有验证附带计划。',
                  '- admitted_sources.json 保留原路径；source_inputs 指定复现时实际读取的 domain/problem。']
    if p.get('priority1', {}).get('enabled'):
        lines += ['', '本轮仅新增优先级 1 支持：',
                  '- 类型自继承作为冗余边处理，保留类型和其他父类型；真正的类型环继续拒绝。',
                  '- 两条 consent 记录显式选择 require_intentional_agents：参与者与同意者的并集进入导出的 agents，不补写意图。',
                  '- 原读取器忽略 consent；这是记录在案的方言解释，不宣称与旧读取器行为等价。',
                  '- admitted_sources.json 的 consent_policy 必须与 source_inputs、constant_contract 一同用于复现。',
                  '- 未开展低优先级模型修复、完整错误诊断或表达式／信念扩展。']
    lines += ['', 'domain 口径（人工多问题不能当作多个独立领域）：', '']
    for pool, stats in r['pools'].items():
        lines.append(f"- {names[pool]}：通过 {stats['admitted_domain_files']}/{stats['domain_files']} 个 domain 文件；其中 {stats['all_problem_passed_domain_files']} 个的全部登记问题通过；通过模型按规范化语法去重为 {stats['admitted_unique_canonical_syntax']}。")
    lines += ['', '分来源：', '']
    for pool in ('human', 'learned_revised', 'learned_original'):
        for name, stats in r['by_collection'][pool].items(): lines.append(f"- {names[pool]} / {name}：{stats['passed']}/{stats['pairs']} = {stats['pass_percent']:.2f}%；原域解析 {stats['raw_parsed']}。")
    lines += ['', '未覆盖原因（第一处阻塞，不代表只存在一种错误）：', '']
    for pool in r['pools']:
        lines.append(names[pool] + '：')
        for reason, count in r['pools'][pool]['rejection_reasons'].items(): lines.append(f'  {count}: {reason}')
    lines += ['', '原始版与修订版逐故事对应：' + str(dict(paired)),
              '这是版本差异诊断，不使用原始版替补主口径修订版。解析覆盖高低不能用于判断哪个版本故事语义更准确。', '',
              '已有合并／行为证据覆盖（历史结果，本次未新跑模型、规划或回放）：',
              f"- Story 修订版历史选择 {len(selected)}/192 = {100*len(selected)/192:.2f}% 个源模型参与合并实验；其中 {len(selected & current_admitted)} 个仍在当前准入集合。",
              f"- 当前新增准入而未进入这批历史实验的学习域有 {len(current_admitted-selected)} 个，ID 完整列于 coverage_summary.json。",
              f"- 历史有效原域目标计划涉及 {len(native_good)}/192 = {100*len(native_good)/192:.2f}% 个故事；若仅对已选 60 个计，为 {100*len(native_good)/len(selected):.2f}%。Full 运输验证涉及 {len(transport_good)} 个独立来源，不能把反复出现的运输槽位当作新故事。",
              f"- 历史模型中参与谓词合并的独立来源 {len(merged['predicate'])} 个，参与动作合并 {len(merged['action'])} 个；这表示构造覆盖，不是独立语义正确标签。",
              '- 人工历史合并尝试仅覆盖 Rooms、Heist、Batman 三个来源，模型阶段不完整；后续本地检查无成功原计划运输。',
              '- 第二轮另选 6 个原始任务做轨迹对照：12 项比较中 2 项单域轨迹一致、8 项缺少完整成对轨迹、2 项无法转换。四域联合没有完成的轨迹对照。',
              '- 旧 15 故事域可以继续作为开发材料，但来源记录没有可核实的人工编写／学习者信息，不能并入已确认的 story 学习集。',
              '', '仍未覆盖的可解析学习域与导出失败：',
              '- 修订版原域可解析但当前导出未通过：' + str(admission_paths['learned_revised']['native_pass_export_not_pass']),
              f"- 修订版导出后解析失败 {len([x for x in export_errors if x['pool']=='learned_revised'])} 个；逐项日志保留在下方。",
              '- 补上前置语法支持后暴露的类型循环或元数错误仍保留为拒绝，不自动猜测修复。',
              '', 'problem :intentionality 的解释边界：',
              f'- {len(problem_intention_adapters)} 条导出记录把显式声明放入自身初始状态；对象、目标和来源映射完整记录。',
              '- 原始 Glaive 读取器忽略这个非标准 section。本适配是保留显式声明的方言解释，不宣称与原先忽略声明的行为等价。',
              '', '完整性与范围：',
              '- 原始文件、故事文本、metadata、旧结果、当前导出逐项哈希核对通过；原始解析变化和准入变化分别记录。',
              '- 每条版本记录保留原始路径、哈希、常量契约、转换错误、原生解析日志与导出解析日志。',
              '- 常量补声明仅使用显式对象声明；通过且需要此补全的配对数量分别为：' + str({k:v['passed_with_constant_completion'] for k,v in r['pools'].items()}),
              '- 非叙事 IPC/Transport 控制域与实验生成的复制件不重复计入本次叙事源库。',
              '- 解析准入、行为保持、跨域语义正确及故事质量分别统计。没有独立语义标签，不给出语义正确覆盖率。',
              '', '文件：report.json（512 行）；coverage_summary.json（汇总与历史证据）；admitted_sources.json（各池准入清单）；source_lineage.json（故事与版本口径）。']
    lines += ['', '导出成功但原生解析拒绝的逐项原因：', '']
    for item in export_errors:
        lines.append(item['id'] + '：' + item['diagnostic'].strip())
    (output / 'assessment_zh.txt').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    save(output / 'source_lineage.json', lineage)
    save(output / 'admitted_sources.json', {'pools': {pool: [{**{k:x[k] for k in ('id', 'domain', 'problem', 'source_id', 'constant_contract', 'domain_sha256', 'problem_sha256')},
                                                           'source_inputs': {k: x.get('effective_' + k, x[k]) for k in ('domain', 'problem')},
                                                           **{k: x[k] for k in ('effective_domain', 'effective_problem', 'effective_domain_sha256', 'effective_problem_sha256', 'packaging_adapter', 'consent_policy') if k in x}}
                                                           for x in r['rows'] if x['pool'] == pool and x['single_domain_pass']]
                                                    for pool in r['pools']}})
    index = {'reports': {
        'all_narrative_current_parse_coverage': {'path': str((output/'report.json').relative_to(REPO)), 'sha256': digest(output/'report.json'),
            'terminal_status': 'complete', 'required_true': ['inputs_unchanged','exports_unchanged','historical_outputs_unchanged', 'no_admission_regressions' if 'no_admission_regressions' in r else 'human_matches_round2'],
            'denominator': 'registered_rows', 'row_id': 'id', 'count_field': 'counts',
            'scope': '512 version records; four source pools with distinct denominators; local native parsing only',
            'metrics': ['registered_rows','pools','by_collection','counts','model_calls','search_calls','plan_replay_calls'] + (['comparison'] if 'comparison' in r else [])},
        'all_narrative_verified_summary': {'path': str((output/'coverage_summary.json').relative_to(REPO)), 'sha256': digest(output/'coverage_summary.json'),
            'terminal_status': 'verified_coverage_audit', 'required_true': ['inputs_unchanged','exports_unchanged','historical_outputs_unchanged','historical_source_bytes_match_current_records'],
            'scope': 'Current coverage and separately labeled historical evidence, verified hashes and source correspondence',
            'metrics': ['registered_version_rows','lineage','historical_learned_experiments','historical_human_evidence','packaging_adapters','priority1_normalizations']}},
        'excluded_pending': ['Behavior and intentionality preservation across all newly admitted sources', 'Cross-domain semantic correctness and narrative quality',
                             'Verified upstream provenance for the 15 legacy stories', 'Five-repeat fresh-run experimental estimates']}
    save(output / 'evidence_index.json', index)
    return {'status': summary['status'], 'pools': r['pools'], 'historical_selected_still_admitted': len(selected & current_admitted),
            'newly_admitted_outside_historical_selection': len(current_admitted-selected), 'variant_overlap': dict(paired)}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(finish(args.output.resolve()), ensure_ascii=False, indent=2))

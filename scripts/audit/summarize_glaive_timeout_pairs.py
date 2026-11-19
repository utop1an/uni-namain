"""Audit and summarize the separate frozen timeout-only development comparison."""
import argparse
from collections import Counter, defaultdict
import hashlib
import json
from pathlib import Path
import statistics


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def write(path, value):
    with Path(path).open('x', encoding='utf-8') as stream:
        json.dump(value, stream, ensure_ascii=False, indent=2)
        stream.write('\n')


def last_phase(row):
    part = 'replay' if row['kind'] == 'transport' else 'search'
    events = row.get(part, {}).get('phase_events', [])
    return events[-1]['phase'] if events else 'unrecorded'


def intervals(rows, arm):
    phases = ('parse', 'state_space', 'axiom_filter', 'axiom_tree', 'search_setup', 'replay_axioms')
    result = {}
    for phase in phases:
        values = []
        started = 0
        for pair in rows:
            for part in ('search', 'replay'):
                events = {e['phase']: e['elapsed_seconds'] for e in pair[arm].get(part, {}).get('phase_events', [])}
                if phase+'_begin' in events:
                    started += 1
                    if phase+'_end' in events:
                        values.append(events[phase+'_end']-events[phase+'_begin'])
        result[phase] = {'started_intervals': started, 'completed_intervals': len(values),
                         'unfinished_intervals': started-len(values),
                         'median_completed_seconds': statistics.median(values) if values else None,
                         'total_completed_seconds': sum(values)}
    return result


def paired_intervals(rows):
    result = {}
    for part in ('search', 'replay'):
        for name in ('parse', 'state_space', 'axiom_filter', 'axiom_tree', 'search_setup', 'replay_axioms'):
            matched = []
            recovered = 0
            after_only = 0
            for row in rows:
                events = {arm: {e['phase']: e['elapsed_seconds'] for e in row[arm].get(part, {}).get('phase_events', [])}
                          for arm in ('before', 'after')}
                begun = {arm: name+'_begin' in events[arm] for arm in events}
                complete = {arm: begun[arm] and name+'_end' in events[arm] for arm in events}
                if all(complete.values()):
                    matched.append(tuple(events[arm][name+'_end']-events[arm][name+'_begin'] for arm in ('before', 'after')))
                elif complete['after']:
                    if begun['before']:
                        recovered += 1
                    else:
                        after_only += 1
            result[part+'/'+name] = {'matched_completed_pairs': len(matched),
                                   'median_before_seconds_matched': statistics.median(x[0] for x in matched) if matched else None,
                                   'median_after_seconds_matched': statistics.median(x[1] for x in matched) if matched else None,
                                   'before_unfinished_after_completed': recovered,
                                   'before_not_started_after_completed': after_only}
    return result


def audit(root, output):
    report_path = root/'report.json'
    protocol = read(root/'protocol.json')
    report = read(report_path)
    assert report['status'] == 'complete_paired_timeout_comparison'
    assert report['inputs_unchanged'] and report['completed_pairs'] == report['registered_pairs'] == 355
    registered = {(p['task']['kind'], p['task']['id']): p for p in protocol['pairs']}
    assert len(registered) == 355
    assert {(r['kind'], r['id']) for r in report['rows']} == set(registered)
    assert len(report['rows']) == 355
    assert all(sha(p) == h for p, h in protocol['input_sha256'].items())
    assert sha(root/'protocol.json') == (root/'PROTOCOL.sha256').read_text().strip()
    assert read(root/'execution_start.json')['isolation']['network_interfaces'] == [[1, 'lo']]
    counts = Counter()
    statuses = defaultdict(Counter)
    for row in report['rows']:
        task = registered[(row['kind'], row['id'])]['task']
        for arm in ('before', 'after'):
            actual = row[arm]
            for field in ('kind', 'id', 'domain', 'problem', 'mapping'):
                assert actual.get(field) == task.get(field), (arm, row['id'], field)
            for part in ('search', 'replay'):
                call = actual.get(part, {})
                if call.get('mode'):
                    assert call['mode'] == part
                    assert sha(protocol['jars'][arm]) in call['input_sha256'].values()
                    counts[arm+'_'+part] += 1
            if row['kind'] == 'transport':
                assert actual['search']['search_calls'] == 0
                assert actual['plan'] == row['historical']['plan']
            if actual.get('search', {}).get('status') == 'wall_time_limit' or actual.get('replay', {}).get('status') == 'wall_time_limit':
                statuses[arm][row['kind']+'/'+last_phase(actual)] += 1
    phases = {arm: intervals(report['rows'], arm) for arm in ('before', 'after')}
    gate_reports = [read(g) for g in protocol['gates']]
    assert all(r['status'] == 'passed' and r['inputs_unchanged'] for r in gate_reports)
    saved = next(r for r in gate_reports if r.get('cases') == 8360)
    assert saved['passed'] == 8360 and saved['failed'] == 0
    output.mkdir(parents=True, exist_ok=False)
    value = {'status': 'verified_paired_timeout_comparison', 'registered_pairs': 355,
             'completed_pairs': 355, 'inputs_unchanged': True, 'model_requests': 0,
             'comparison': report['comparison'], 'phase_intervals': phases, 'paired_phase_intervals': paired_intervals(report['rows']),
             'remaining_timeout_phases': {k: dict(v) for k, v in statuses.items()},
             'invocation_counts': dict(counts), 'wall_seconds_both_arms': report['wall_seconds_both_arms'],
             'saved_plan_regression': {k: saved[k] for k in ('cases', 'passed', 'failed', 'seconds')},
             'input_sha256': {str(report_path): sha(report_path), str(root/'protocol.json'): sha(root/'protocol.json')},
             'limits': report['limitations']}
    write(output/'report.json', value)
    index = {'reports': {}, 'excluded_pending': []}
    for name, path in [('paired_timeout_run', report_path), ('paired_timeout_audit', output/'report.json')]+[
            ('regression_'+str(i), Path(g)) for i, g in enumerate(protocol['gates'])]:
        r = read(path)
        index['reports'][name] = {'path': str(path.resolve()), 'sha256': sha(path),
                                 'terminal_status': r['status'], 'scope': name,
                                 'metrics': [k for k in ('registered_pairs', 'completed_pairs', 'comparison', 'cases', 'passed', 'failed', 'inputs_unchanged') if k in r],
                                 'required_true': ['inputs_unchanged']}
    write(output/'evidence_index.json', index)
    c = report['comparison']['all']
    b, a = c['before'], c['after']
    saved_pct = 100*(1-a['invocation_seconds_including_timeouts']/b['invocation_seconds_including_timeouts'])
    names = {'native': '原始/适配模型搜索', 'transport': '既有计划迁移回放', 'anchor': '原始目标搜索', 'composition': '组合目标搜索'}
    lines = [
        '# 剩余公理展开与搜索初始化优化：超时任务对照', '',
        '本轮只验证先前卡在搜索开始前或回放公理准备阶段的 355 项任务。它是独立开发条件，不替代已有 1,200 组完整实验结果。346 项已经进入搜索后超时的任务不在本轮范围内。', '',
        f'优化前后各重新执行一次：每次搜索和回放各限 60 秒，8 并发，每个 Java 进程堆上限 4096 MB。两版按任务配对顺序执行，179 对先旧后新、176 对先新后旧；无重试、无缓存续跑。实验在仅有 loopback 的独立网络环境执行，LLM 请求为 0。', '',
        '## 配对结果', '',
        '| 任务 | 数量 | 完成初始化：优化前 → 后 | 原生验证通过：前 → 后 | 双重验证通过：前 → 后 | 调用累计耗时（分钟）：前 → 后 |',
        '|---|---:|---:|---:|---:|---:|']
    for stage in names:
        x, y = report['comparison'][stage]['before'], report['comparison'][stage]['after']
        lines.append(f"| {names[stage]} | {x['cases']} | {x['initialization_completed']} → {y['initialization_completed']} | {x['native_valid']} → {y['native_valid']} | {x['dual_valid']} → {y['dual_valid']} | {x['invocation_seconds_including_timeouts']/60:.2f} → {y['invocation_seconds_including_timeouts']/60:.2f} |")
    lines += [f"| 合计 | 355 | {b['initialization_completed']} → {a['initialization_completed']} | {b['native_valid']} → {a['native_valid']} | {b['dual_valid']} → {a['dual_valid']} | {b['invocation_seconds_including_timeouts']/60:.2f} → {a['invocation_seconds_including_timeouts']/60:.2f} |", '',
        f"累计调用耗时减少 **{saved_pct:.2f}%**。这是包含超时和验证调用的累计实际耗时，不是 CPU 时间；优化后新找到计划还会增加回放工作。两版合计墙钟时间 **{report['wall_seconds_both_arms']/60:.2f} 分钟**。", '',
        f"本次配对新增双重验证通过 {c['paired']['gained_dual_valid']} 项，丢失原有通过 {c['paired']['lost_dual_valid']} 项。优化后 {a['search_solved']} 项返回计划，{a['no_solution_returned']} 项返回未找到计划；后者不计为成功，也不证明不可解。", '',
        '原生验证与双重验证分列：派生公理任务可能通过原生验证，但独立物理验证器不支持其公理，仍属于物理验证未知，不能计作双重验证成功。', '',
        '“完成初始化”对搜索任务指实际出现 search_begin，对迁移回放指 replay_axioms_end。公理树改为按需创建后，axiom_tree_end 只表示外壳创建完成，因此不用该标记宣称全部初始化结束。', '',
        '## 改动及定位依据', '',
        '- 量词表达式的 DNF/CNF 展开原先把不产生分支的合取也计入笛卡尔积，造成重复展开和整数溢出；现在仅按真正分支计数，并显式检测溢出。',
        '- 在公理实例化之前筛除必然为假的静态类型/激活条件，保留幸存公理的原始条件与效果。动态谓词、否定、析取、量词和零参数边界保留原规则。',
        '- 公理索引改为按需建立分支，预先统计顶层带符号文字的出现次数；保持原分支选择及适用规则顺序。',
        '- 搜索初始化的因果回溯改用位集合检查路径冲突，复用已覆盖的路径条件，并提前排除无关代理；保持原 DFS 距离结果。', '',
        '## 回归与证据边界', '',
        '- 8,360 条去重后的历史计划全部重新回放；状态、目标、步数、未解释/孤立步、物理回放、最终有效性全部相同。',
        '- 68,820 项有限模型检查：402 个逻辑表达式、120 组公理、1,200 个意图图；公理适用顺序和因果距离对照原始算法。',
        '- 量词控制 257 项；静态公理控制 46 项，确认加载 10 个模板、展开 16 条公理、筛后 8 条，并比较 16 个状态的完整闭包。',
        '- 有效计划、空计划、重复非法动作、未知动作四类控制两版均符合预期，共 8 次回放。',
        '- Python 对照执行/报告检查 26 项通过。',
        '- 旧小型公理测试因解析要求顺序而加载了 0 条公理，原 32 项“通过”不构成公理等价证据；保留原报告并附 CORRECTION_2026_11_08.json。当前非空公理检查替代该证据。',
        '- 两个中间候选分别因公理顺序、零参数公理行为被拒绝/替代；两轮未完成的历史回放保持为中止记录，不计为通过。',
        '- 双重验证只是本地符号/物理模型回放，不提供独立语义或叙事质量标签。超时、失败、未找到计划及物理语义不支持仍保留原状态。', '',
        '## 剩余超时', '',
        '| 最后记录阶段 | 优化前 | 优化后 |', '|---|---:|---:|']
    for phase in sorted(set(statuses['before']) | set(statuses['after'])):
        lines.append(f"| {phase} | {statuses['before'][phase]} | {statuses['after'][phase]} |")
    lines += ['', '完整阶段耗时、所有任务结果、输入与运行器哈希见 report.json、上级 protocol.json 和各任务原始日志。paired_phase_intervals 仅在同一任务两版均完成该阶段时比较中位数，另列旧版未完成而新版完成的数量，避免把未完成阶段记为零。所有历史实验文件均保留；当前结果没有写回旧 1,200 组汇总。', '',
              f"基线运行器 SHA-256：`{sha(protocol['jars']['before'])}`。", '',
              f"新运行器 SHA-256：`{sha(protocol['jars']['after'])}`。", '']
    (output/'comparison.md').write_text('\n'.join(lines), encoding='utf-8')
    print(json.dumps({'status': value['status'], 'registered_pairs': 355, 'invocation_time_reduction_percent': saved_pct,
                      'before': b, 'after': a, 'summary': str(output/'comparison.md')}, ensure_ascii=False))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    audit(args.root.resolve(), args.output.resolve())

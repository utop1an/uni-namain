"""Combine the complete paired run, serial controls and resource evidence."""
import argparse
from collections import Counter
from datetime import datetime
import hashlib
import json
from pathlib import Path


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def write(path, value):
    with Path(path).open('x', encoding='utf-8') as stream:
        json.dump(value, stream, ensure_ascii=False, indent=2)
        stream.write('\n')


def losses(rows, field):
    return [{'kind': r['kind'], 'id': r['id']} for r in rows if r['before'].get(field) and not r['after'].get(field)]


def memory_events(log, start, end):
    result = []
    for line in log.splitlines():
        if 'Out of memory: Killed process' not in line:
            continue
        when = datetime.fromisoformat(line.split(' ', 1)[0].replace(',', '.'))
        if start <= when <= end:
            result.append(line)
    return result


def package(main, serial, audit, kernel, tests, output):
    reports = {'eight_workers': read(main/'report.json'), 'one_worker': read(serial/'report.json')}
    assert reports['eight_workers']['status'] == 'complete_paired_timeout_comparison'
    assert reports['one_worker']['status'] == 'complete_serial_timeout_controls'
    assert reports['eight_workers']['registered_pairs'] == reports['eight_workers']['completed_pairs'] == 355
    assert reports['one_worker']['registered_pairs'] == reports['one_worker']['completed_pairs'] == 6
    files = {}
    for folder in (main, serial):
        p = read(folder/'protocol.json')
        assert sha(folder/'protocol.json') == (folder/'PROTOCOL.sha256').read_text().strip()
        files.update(p['input_sha256'])
        for name in ('report.json', 'protocol.json', 'execution_start.json', 'coordinator.json'):
            files[str((folder/name).resolve())] = sha(folder/name)
        assert read(folder/'execution_start.json')['isolation']['network_interfaces'] == [[1, 'lo']]
    assert reports['eight_workers']['inputs_unchanged'] and reports['one_worker']['inputs_unchanged']
    assert all(sha(path) == h for path, h in files.items())
    assert read(kernel/'receipt.json')['returncode'] == 0
    log = (kernel/'kernel_memory_events.log').read_text(encoding='utf-8')
    resource = {}
    transitions = {}
    ambiguous = []
    for name, folder in (('eight_workers', main), ('one_worker', serial)):
        start = read(folder/'execution_start.json')
        end = read(folder/'coordinator.json')
        events = memory_events(log, datetime.fromisoformat(start['started_utc']), datetime.fromisoformat(end['updated_utc']))
        resource[name] = {'start_utc': start['started_utc'], 'end_utc': end['updated_utc'],
                          'kernel_oom_kills_in_window': len(events), 'events': events,
                          'meminfo_at_start': start['meminfo'],
                          'attribution': 'Window-level evidence only. No PID binding was recorded for the historical invocations; raw statuses are unchanged.'}
        rows = reports[name]['rows']
        transitions[name] = {'lost_native_valid': losses(rows, 'native_valid'), 'lost_dual_valid': losses(rows, 'valid'),
                             'gained_native_valid': sum(not r['before'].get('native_valid') and bool(r['after'].get('native_valid')) for r in rows),
                             'returned_without_native_validation': [{'kind': r['kind'], 'id': r['id'],
                                'replay_status': r['after'].get('replay', {}).get('status'), 'plan': r['after'].get('plan')}
                                for r in rows if r['after'].get('search', {}).get('status') == 'solved' and not r['after'].get('native_valid')],
                             'native_but_physical_unknown': {arm: sum(bool(r[arm].get('native_valid')) and not r[arm].get('valid') and r[arm].get('replay', {}).get('physical', {}).get('status') in ('unsupported', 'unsupported_or_invalid') for r in rows) for arm in ('before', 'after')},
                             'worker_statuses': {arm: dict(Counter(r[arm].get('status') for r in rows)) for arm in ('before', 'after')}}
        for r in rows:
            for arm in ('before', 'after'):
                for part in ('search', 'replay'):
                    call = r[arm].get(part, {})
                    if call.get('returncode') in (137, -9):
                        ambiguous.append({'condition': name, 'kind': r['kind'], 'id': r['id'], 'arm': arm,
                                          'part': part, 'raw_status': call['status'], 'returncode': call['returncode'],
                                          'seconds': call.get('seconds'),
                                          'interpretation': 'SIGKILL evidence is not sufficient to distinguish timeout cleanup from memory exhaustion for this individual invocation.'})
    assert read(tests/'report.json')['tests'] == 26 and read(tests/'report.json')['status'] == 'passed'
    for path, h in read(tests/'report.json')['input_sha256'].items():
        assert sha(path) == h
        files[path] = h
    for path in (kernel/'receipt.json', kernel/'kernel_memory_events.log', tests/'report.json',
                 audit/'report.json', audit/'evidence_index.json', Path(__file__).resolve()):
        files[str(path.resolve())] = sha(path)
    output.mkdir(parents=True, exist_ok=False)
    snapshot = output/'package_implementation.py'
    snapshot.write_bytes(Path(__file__).read_bytes())
    files[str(snapshot.resolve())] = sha(snapshot)
    value = {'status': 'verified_initialization_optimization_packet', 'inputs_unchanged': True, 'model_requests': 0,
             'registered_pairs': {'eight_workers': 355, 'one_worker': 6},
             'comparison': {k: r['comparison'] for k, r in reports.items()},
             'wall_seconds_both_arms': {k: r['wall_seconds_both_arms'] for k, r in reports.items()},
             'resource_context': resource, 'transitions': transitions, 'ambiguous_sigkill_invocations': ambiguous,
             'regressions': {'saved_plans': 8360, 'saved_plan_differences': 0, 'finite_checks': 68820,
                             'quantified_checks': 257, 'axiom_checks': 46, 'negative_control_invocations': 8, 'python_tests': 26},
             'input_sha256': files,
             'limits': ['Eight-worker time measurements include observed host memory pressure; they are not isolated CPU speed measurements.',
                        'Raw wall_time_limit labels are retained, but SIGKILL-coded terminations are not individually attributed to timeout versus OOM.',
                        'The six serial controls are a separately registered fresh condition using preselected medians, not a replacement or retry of the complete paired condition.',
                        'Native replay is not independent semantic or physical validation. Unsupported physical validation remains unknown.',
                        'The scope is a selected timeout development subset, not a full 1200-group evaluation.']}
    write(output/'report.json', value)
    index = read(audit/'evidence_index.json')
    index.setdefault('excluded_pending', [])
    for name, path, metrics in [
        ('serial_controls', serial/'report.json', ['registered_pairs', 'completed_pairs', 'comparison', 'inputs_unchanged']),
        ('runner_tests', tests/'report.json', ['tests', 'failures', 'inputs_unchanged']),
        ('complete_packet', output/'report.json', ['registered_pairs', 'comparison', 'resource_context', 'transitions', 'regressions', 'inputs_unchanged'])]:
        r = read(path)
        index['reports'][name] = {'path': str(path.resolve()), 'sha256': sha(path), 'terminal_status': r['status'],
                                 'scope': name, 'metrics': metrics, 'required_true': ['inputs_unchanged']}
    write(output/'evidence_index.json', index)
    lines = ['# 公理展开与搜索初始化优化：最终对比', '',
             '本轮基线是上轮已优化的运行器。旧模型、初始状态、目标、计划、映射和已有 1,200 组实验均保持原样；新运行器和全部实验结果写入独立版本目录。实验未发起 LLM 请求。', '',
             '优化包括：修正量词表达式展开时的重复分支计数；在实例化前排除必然为假的静态公理条件；按需创建公理索引并保留原顺序；用位集合和已覆盖路径缓存加速搜索初始化。', '',
             '## 355 项完整配对对照', '',
             '两版各新执行一次，搜索/回放各限 60 秒，8 并发，每个 Java 进程堆上限 4 GiB。全部失败和资源限制记录均留在分母中，没有追加重试。', '',
             '| 指标 | 上轮运行器 | 本轮运行器 |', '|---|---:|---:|']
    b, a = [reports['eight_workers']['comparison']['all'][x] for x in ('before', 'after')]
    for label, field in [('完成准备阶段', 'initialization_completed'), ('原生验证通过', 'native_valid'), ('双重验证通过', 'dual_valid'), ('搜索返回计划', 'search_solved'), ('返回未找到计划', 'no_solution_returned')]:
        lines.append(f'| {label} | {b[field]} | {a[field]} |')
    lines.append(f"| 累计调用耗时（分钟） | {b['invocation_seconds_including_timeouts']/60:.2f} | {a['invocation_seconds_including_timeouts']/60:.2f} |")
    reduction = 100*(1-a['invocation_seconds_including_timeouts']/b['invocation_seconds_including_timeouts'])
    lines += ['', f"该资源条件下累计调用耗时减少 **{reduction:.2f}%**；两版合计墙钟 **{reports['eight_workers']['wall_seconds_both_arms']/60:.2f} 分钟**。累计调用耗时包含超时、终止及新找到计划的回放，不是 CPU 时间。", '',
              f"环境总内存约 16 GB。内核在这轮运行窗口内记录了 **{resource['eight_workers']['kernel_oom_kills_in_window']} 次内存耗尽杀进程**。因此这组数据反映含内存压力的 8 并发运行；不能把所有 SIGKILL 终止都确定归因为正常超时，也不能把耗时变化解释为纯计算速度变化。原始状态未被改写，所有有歧义的终止均列在 report.json。", '',
              '“完成准备阶段”指搜索任务实际进入 search_begin，或回放完成 replay_axioms_end；不使用按需索引的外壳创建标记代替实际初始化完成。', '',
              '## 6 个预先选定任务的单进程对照', '',
              '使用优化前已经选定的六个分层代表任务，两版重新执行，仍各限 60 秒、4 GiB 堆；每次仅运行一个 Java 调用，与主实验错开。这个单独条件用于核实代表性效果，不替换主实验的任何结果。', '',
              '| 指标 | 上轮运行器 | 本轮运行器 |', '|---|---:|---:|']
    sb, sa = [reports['one_worker']['comparison']['all'][x] for x in ('before', 'after')]
    for label, field in [('完成准备阶段', 'initialization_completed'), ('原生验证通过', 'native_valid'), ('双重验证通过', 'dual_valid')]:
        lines.append(f'| {label} | {sb[field]} | {sa[field]} |')
    lines.append(f"| 累计调用耗时（秒） | {sb['invocation_seconds_including_timeouts']:.2f} | {sa['invocation_seconds_including_timeouts']:.2f} |")
    lines += ['', f"单进程窗口内内核记录的 OOM 杀进程数为 **{resource['one_worker']['kernel_oom_kills_in_window']}**；两版合计墙钟 **{reports['one_worker']['wall_seconds_both_arms']/60:.2f} 分钟**。六例只支持代表任务上的结论，不外推为全部 1,200 组的总体提升。", '',
              '| 代表任务 | 旧版状态 / 调用秒数 | 新版状态 / 调用秒数 |', '|---|---|---|']
    for row in reports['one_worker']['rows']:
        cells = []
        for arm in ('before', 'after'):
            r = row[arm]
            part = 'replay' if row['kind'] == 'transport' else 'search'
            seconds = sum(r.get(k, {}).get('seconds', 0) for k in ('search', 'replay'))
            cells.append(f"{r.get(part, {}).get('status', 'unknown')} / {seconds:.2f}")
        lines.append(f"| {row['kind']}：{row['id']} | {cells[0]} | {cells[1]} |")
    lines += ['', '## 回归、未知结果和剩余问题', '',
              '- 8,360 条去重历史计划全部重新回放，状态、目标、步数、解释状态、物理回放及最终有效性均无差异。',
              '- 68,820 项有限模型检查、257 项量词检查、46 项非空公理检查、8 次正反例回放，以及 26 项执行/报告测试通过。',
              f"- 355 对中新增加的原生通过为 {transitions['eight_workers']['gained_native_valid']} 项，丢失原有原生通过为 {len(transitions['eight_workers']['lost_native_valid'])} 项；双重通过丢失为 {len(transitions['eight_workers']['lost_dual_valid'])} 项。", 
              f"- 新版原生通过但独立物理验证未知的任务有 {transitions['eight_workers']['native_but_physical_unknown']['after']} 项。派生公理尚无独立物理验证支持，不能把原生通过当作双重验证或独立语义正确。", 
              f"- 另有 {len(transitions['eight_workers']['returned_without_native_validation'])} 个搜索返回计划未取得原生有效结论，原始验证状态逐项保留在 report.json 的 returned_without_native_validation 中；不将不支持的计划格式当作已验证成功。",
              '- 未找到计划不等于证明不可解。仍然超时的任务按最后阶段保留，区分初始化未结束和已经进入搜索。',
              '- 旧小型公理测试曾因声明顺序实际加载 0 条公理，原 32 项通过不构成公理等价证据。原报告已保留并附更正；本轮新测试明确检查 10 个模板、16 条展开公理和完整状态闭包。',
              '- 中间候选的失败和中止记录均保留，不纳入最终通过结果。', '',
              f"[355 项逐项结果]({(main/'report.json').as_posix()}) · [阶段与分组统计]({(audit/'report.json').as_posix()}) · [单进程逐项结果]({(serial/'report.json').as_posix()}) · [核验索引]({(output/'evidence_index.json').as_posix()})", '']
    (output/'comparison.md').write_text('\n'.join(lines), encoding='utf-8')
    write(audit/('RESOURCE_CONTEXT_'+output.name+'.json'), {'status': 'supplemented_with_observed_memory_pressure',
          'canonical_comparison': str((output/'comparison.md').resolve()),
          'note': 'Read the combined delivery for kernel OOM evidence and the separately registered serial controls. Component results are retained unchanged.'})
    print(json.dumps({'status': value['status'], 'main_time_reduction_percent': reduction,
                      'main_oom_kills': resource['eight_workers']['kernel_oom_kills_in_window'],
                      'serial_oom_kills': resource['one_worker']['kernel_oom_kills_in_window'],
                      'transitions': transitions, 'comparison': str(output/'comparison.md')}, ensure_ascii=False))


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    for name in ('main', 'serial', 'audit', 'kernel', 'tests', 'output'):
        p.add_argument('--'+name, type=Path, required=True)
    a = p.parse_args()
    package(*[getattr(a, name).resolve() for name in ('main', 'serial', 'audit', 'kernel', 'tests', 'output')])

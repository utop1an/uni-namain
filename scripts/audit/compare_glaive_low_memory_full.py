"""Read-only paired report for the complete, frozen low-memory rerun."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import sys

from scripts.audit.compare_optimized_frozen_evaluation import (
    STAGES, classify, measured_phases, read, remaining_timeouts,
    retry_increment, sha, summary, timing, write,
)
from scripts.experiments.run_optimized_frozen_evaluation import EXPECTED, merge_retry_results, retry_reason


def compare(root, output):
    if output.exists():
        raise ValueError('Fresh output required')
    assert read(root/'coordinator.json')['status'] == 'complete'
    assert read(root/'launcher_exit.json')['returncode'] == 0
    protocol = read(root/'protocol.json')
    checkpoint = Path(protocol['checkpoint_root']) if protocol.get('checkpoint_root') else None
    before = Path(protocol['parent'])
    final = Path(protocol['historical_final'])
    roots = {'before_initial15': before/'initial15', 'before_final': final,
             'after_initial15': root/'initial15', 'after_final': root}
    hashes = {}

    def pin(path):
        hashes[str(path.resolve())] = sha(path)
        return read(path)

    def events_at(path, allow_last_partial=False):
        hashes[str(path.resolve())] = sha(path)
        lines = path.read_text(encoding='utf-8').splitlines()
        rows = []
        for i, line in enumerate(lines):
            try:
                rows.append(json.loads(line))
            except json.JSONDecodeError:
                assert allow_last_partial and i == len(lines)-1
        return rows

    retained = {}
    checkpoint_evidence = None
    if checkpoint:
        assert protocol['not_original_fresh_budget_completion'] is True
        checkpoint_evidence = pin(root/'checkpoint_rows.json')
        assert checkpoint_evidence['reuse_is_explicit_continuation'] is True
        retained = checkpoint_evidence['rows_by_stage']
        for stage, rows in retained.items():
            if stage in checkpoint_evidence['source_files']:
                path = Path(checkpoint_evidence['source_files'][stage])
                original = events_at(path, True) if path.suffix == '.jsonl' else pin(path)['rows']
                assert rows == original
            else:
                assert rows == []
        assert pin(checkpoint/'interruption_receipt.json')['status'] == 'interrupted_for_user_concurrency_change'
        assert pin(checkpoint/'launcher_exit.json')['returncode'] == -9
        pin(root/'cgroup_before.json')
        pin(root/'cgroup_after.json')
        for name in ('launcher.py', 'supervisor.py'):
            hashes[str((root/name).resolve())] = sha(root/name)

    for path in (Path(__file__), root/'runner.py', root/'executor.py'):
        hashes[str(path.resolve())] = sha(path)
    for path in (root/'protocol.json', root/'timing.json', root/'execution_start.json',
                 root/'launcher_exit.json', before/'timing.json', final/'reconciliation.json'):
        pin(path)
    groups = pin(root/'selected_groups.json')['groups']
    assert len(groups) == len({g['id'] for g in groups}) == 1200
    group_cells = Counter((g['cohort'], g['size'], g['method']) for g in groups)
    assert len(group_cells) == 24 and set(group_cells.values()) == {50}
    assert sha(root/'protocol.json') == (root/'PROTOCOL.sha256').read_text().strip()
    aborted_conditions = []
    for name in protocol.get('excluded_aborted_conditions', []):
        path = Path(name)
        receipt = pin(path/'abort_receipt.json')
        accounting = pin(path/'aborted_slot_accounting.json')
        start = pin(path/'execution_start.json')['started_utc']
        finish = pin(path/'launcher_exit.json')['finished_utc']
        assert accounting['not_a_completed_full_run'] is True
        aborted_conditions.append({'root': str(path), 'reason': receipt['reason'],
            'slot_accounting': accounting['slot_accounting'],
            'elapsed_until_abort_seconds': (datetime.fromisoformat(finish)-datetime.fromisoformat(start)).total_seconds(),
            'first_launch_utc': pin(path/'kernel_before.json')['utc'],
            'excluded_from_full_run_comparison': True, 'model_requests': 0})
    data = {name: {} for name in roots}
    registered = {}
    for stage, n in EXPECTED.items():
        tasks = pin(root/'registered_jobs'/f'{stage}.json')['tasks']
        registered[stage] = {t['id']: t for t in tasks}
        assert len(registered[stage]) == n
        for name, path in roots.items():
            rows = pin(path/'repeat_01'/f'{stage}_report.json')['rows']
            assert len(rows) == n == len({r['id'] for r in rows})
            assert {r['id'] for r in rows} == set(registered[stage])
            assert all(r.get('kind', stage) == stage for r in rows)
            data[name][stage] = rows

    # Independently bind reports to complete, stage-qualified raw events.
    initial = data['after_initial15']
    all_attempts = []
    for stage, rows in initial.items():
        path = root/'initial15'/f'{stage}_events.jsonl'
        events = events_at(path)
        ready = {k for k, t in registered[stage].items() if t.get('status') in (None, 'ready')}
        assert len(events) == len(ready) and {r['id'] for r in events} == ready
        indexed = {r['id']: r for r in rows}
        assert all(r == indexed[r['id']] for r in events)
        if checkpoint:
            old = {r['id']: r for r in retained[stage]}
            assert all(r == indexed[r['id']] for r in old.values())
            old_events_path = checkpoint/'initial15'/f'{stage}_events.jsonl'
            old_events = events_at(old_events_path, True) if old_events_path.exists() else []
            assert len(old_events) == len(ready & set(old))
            assert {r['id'] for r in old_events} == ready & set(old)
            assert all(r == old[r['id']] for r in old_events)
            fresh_path = root/'resumed15'/f'{stage}_events.jsonl'
            fresh = events_at(fresh_path) if fresh_path.exists() else []
            assert len(fresh) == len(ready-set(old))
            assert {r['id'] for r in fresh} == ready-set(old)
            assert all(r == indexed[r['id']] for r in fresh)
        all_attempts.extend(('initial15', r, None) for r in events)
    registry = pin(root/'retry_registry.json')
    retry_path = root/'retry60/retry_events.jsonl'
    hashes[str(retry_path.resolve())] = sha(retry_path)
    retried = [json.loads(s) for s in retry_path.read_text(encoding='utf-8').splitlines()]
    jobs = {(j['task']['kind'], j['task']['id']): j for j in registry['jobs']}
    expected = {(s, r['id']) for s, rows in initial.items() for r in rows if retry_reason(r)}
    assert expected == set(jobs) == {(r['kind'], r['id']) for r in retried}
    assert len(retried) == len(jobs) == registry['registered']
    assert merge_retry_results(initial, retried) == data['after_final']
    all_attempts.extend(('retry60', r, jobs[(r['kind'], r['id'])]) for r in retried)

    # Use actual process receipts, not inferred timeout/OOM labels.
    receipts = []
    intervals = []
    segment_intervals = {}
    exception_types = Counter()
    retained_ids = {s: {r['id'] for r in rr} for s, rr in retained.items()}
    for attempt, row, job in all_attempts:
        for mode in ('search', 'replay'):
            if job and mode == 'search' and job.get('replay_plan'):
                continue
            result = row.get(mode, {})
            segment = checkpoint if checkpoint and attempt == 'initial15' and row['id'] in retained_ids[row['kind']] else root
            path = segment/attempt/'repeat_01/execution'/row['kind']/row['id']/mode
            if not (path/'process_start.json').exists():
                assert not result.get('process_receipt')
                continue
            started = pin(path/'process_start.json')
            exited = pin(path/'process_exit.json')
            actual = pin(path/'result.json')
            invocation = pin(path/'invocation.json')
            assert all(result.get(k) == v for k, v in actual.items())
            assert invocation['seconds'] == (15 if attempt == 'initial15' else 60)
            assert invocation['memory_mb'] == 4096
            assert all(exited[k] == v for k, v in result['process_receipt'].items())
            assert started['pid'] == exited['pid'] and started['start_ticks'] == exited['start_ticks']
            assert result['status'] != 'wall_time_limit' or exited['deadline_triggered']
            if exited['returncode'] != 0 and not exited['deadline_triggered']:
                log = path/'stdout.txt'
                hashes[str(log.resolve())] = sha(log)
                message = next((s for s in log.read_text(encoding='utf-8', errors='replace').splitlines()
                                if s.startswith('Exception in thread')), 'no_uncaught_exception_line')
                exception_types[message] += 1
            receipts.append({'attempt': attempt, 'stage': row['kind'], 'id': row['id'],
                             'segment': str(segment), 'mode': mode, 'status': result['status'], **exited})
            intervals.extend(((started['started_utc'], 1), (exited['finished_utc'], -1)))
            segment_intervals.setdefault(str(segment), []).extend(((started['started_utc'], 1), (exited['finished_utc'], -1)))
    active = peak = 0
    for _, delta in sorted(intervals):
        active += delta
        peak = max(peak, active)
        assert active >= 0
    assert active == 0 and peak <= protocol['budgets']['planner_workers']
    segment_peaks = {}
    for segment, points in segment_intervals.items():
        active = maximum = 0
        for _, delta in sorted(points):
            active += delta
            maximum = max(maximum, active)
            assert active >= 0
        assert active == 0 and maximum <= (2 if checkpoint and segment == str(checkpoint) else protocol['budgets']['planner_workers'])
        segment_peaks[segment] = maximum
    kernel_segments, oom_lines = [], []
    for segment in ([checkpoint, root] if checkpoint else [root]):
        kernel_before = pin(segment/'kernel_before.json')
        kernel_after = pin(segment/'kernel_after.json')
        assert kernel_before['returncode'] == kernel_after['returncode'] == 0
        assert kernel_before['boot_id'] == kernel_after['boot_id']
        assert {r['boot_id'] for r in receipts if r['segment'] == str(segment)} <= {kernel_before['boot_id']}
        old_lines = set(kernel_before['stdout'].splitlines())
        new_lines = [s for s in kernel_after['stdout'].splitlines() if s not in old_lines]
        selected = [s for s in new_lines if any(t in s.lower() for t in ('out of memory', 'oom-kill', 'killed process'))]
        oom_lines.extend(selected)
        kernel_segments.append({'root': str(segment), 'boot_id': kernel_after['boot_id'],
            'new_kernel_oom_lines': selected, 'kernel_boot_continuity_verified': True,
            'kernel_before_lines_retained': old_lines.issubset(set(kernel_after['stdout'].splitlines()))})
    interrupted_invocations = []
    if checkpoint:
        interruption_utc = read(checkpoint/'interruption_receipt.json')['utc']
        for item in checkpoint_evidence['interrupted_attempts']:
            assert item['id'] not in retained_ids[item['stage']]
            for mode in ('search', 'replay'):
                path = Path(item['path'])/mode
                if not (path/'process_start.json').exists():
                    continue
                start = pin(path/'process_start.json')
                invocation = pin(path/'invocation.json')
                record = {**item, 'mode': mode, 'start': start, 'invocation': invocation,
                    'status': 'interrupted_unknown', 'included_in_matched_terminal_call_totals': False}
                if (path/'process_exit.json').exists():
                    record['exit'] = pin(path/'process_exit.json')
                else:
                    record['censored_elapsed_until_interruption_seconds'] = (datetime.fromisoformat(interruption_utc)-datetime.fromisoformat(start['started_utc'])).total_seconds()
                for name in ('stdout.txt', 'result.json'):
                    if (path/name).exists():
                        hashes[str((path/name).resolve())] = sha(path/name)
                interrupted_invocations.append(record)
    shared_memory = None
    if checkpoint:
        cb, ca = read(root/'cgroup_before.json'), read(root/'cgroup_after.json')
        assert cb['path'] == ca['path'] == read(root/'execution_start.json')['isolation']['shared_cgroup']
        for key, expected_limit in (('memory.high', 10*1024**3), ('memory.max', 12*1024**3), ('memory.swap.max', 1024**3)):
            assert int(cb[key]) == int(ca[key]) == expected_limit
        def counts(text):
            return {key: int(value) for key, value in (line.split() for line in text.splitlines())}
        c0, c1 = counts(cb['memory.events']), counts(ca['memory.events'])
        shared_memory = {'high_bytes': int(ca['memory.high']), 'max_bytes': int(ca['memory.max']),
            'swap_max_bytes': int(ca['memory.swap.max']), 'peak_bytes': int(ca['memory.peak']),
            'events_delta': {k: c1[k]-c0[k] for k in c0}, 'no_remaining_processes': ca['cgroup.procs'] == ''}
    resources = {'recorded_java_invocations': len(receipts), 'peak_overlapping_java_intervals': peak,
                 'peak_overlapping_java_by_segment': segment_peaks,
                 'peak_process_rss_gib': max(r['peak_sampled_rss_kb'] for r in receipts)/1048576,
                 'peak_process_hwm_gib': max(r['peak_reported_hwm_kb'] for r in receipts)/1048576,
                 'minimum_host_available_gib': min(r['minimum_host_available_kb'] for r in receipts)/1048576,
                 'explicit_deadlines': sum(r['deadline_triggered'] for r in receipts),
                 'deadline_hard_kills': sum(r['deadline_hard_kill'] for r in receipts),
                 'early_signal_terminations': sum(r['status'] == 'terminated_by_signal' for r in receipts),
                 'java_heap_errors': sum(r['status'] == 'memory_limit' for r in receipts),
                 'nondeadline_exception_types': dict(exception_types),
                 'remaining_class_cast_errors': sum(n for s, n in exception_types.items() if 'ClassCastException' in s),
                 'new_kernel_oom_lines': oom_lines, 'kernel_segments': kernel_segments,
                 'kernel_boot_continuity_verified': True,
                 'kernel_before_lines_retained': all(s['kernel_before_lines_retained'] for s in kernel_segments),
                 'shared_memory': shared_memory, 'interrupted_invocations': interrupted_invocations,
                 'sampling_interval_seconds': .2}
    outcomes, costs, transitions, losses, cells = {}, {}, [], [], []
    for stage in STAGES:
        conditions = ('raw', 'adapter') if stage == 'native' else ('union', 'full')
        outcomes[stage] = {name: {c: summary([r for r in d[stage] if r['condition'] == c])
                          for c in conditions} for name, d in data.items()}
        costs[stage] = {}
        for label in ('before', 'after'):
            first = data[label+'_initial15'][stage]
            extra = retry_increment(first, data[label+'_final'][stage])
            costs[stage][label] = {'initial15': timing(first), 'retry60_increment': timing(extra),
                                   'all_attempts': timing(first+extra)}
        for budget in ('initial15', 'final'):
            a = {r['id']: r for r in data['before_'+budget][stage]}
            for c in conditions:
                rr = [r for r in data['after_'+budget][stage] if r['condition'] == c]
                matrix = Counter((classify(a[r['id']]), classify(r)) for r in rr)
                transitions.append({'stage': stage, 'budget': budget, 'condition': c,
                    'gained_dual_validated': sum(bool(r.get('valid')) and not a[r['id']].get('valid') for r in rr),
                    'lost_dual_validated': sum(bool(a[r['id']].get('valid')) and not r.get('valid') for r in rr),
                    'matrix': [{'before': b, 'after': d, 'count': n} for (b, d), n in sorted(matrix.items())]})
                losses.extend({'stage': stage, 'budget': budget, 'id': r['id'], 'after': classify(r),
                               'historical_plan': a[r['id']].get('plan'),
                               'historical_domain': a[r['id']]['domain'],
                               'historical_problem': a[r['id']]['problem']}
                              for r in rr if a[r['id']].get('valid') and not r.get('valid'))
    gate = pin(Path(protocol['regression'])/'report.json')
    assert gate['status'] == 'passed' and gate['passed'] == 8360 and gate['failed'] == 0
    gate_keys = {}
    for row in gate['rows']:
        evidence = row['replay']['input_sha256']
        key = tuple(evidence[str(Path(row[k]).resolve())] for k in ('domain', 'problem', 'plan'))
        gate_keys[key] = row['id']
    for loss in losses:
        key = []
        for name in ('domain', 'problem', 'plan'):
            path = Path(loss['historical_'+name]).resolve()
            hashes[str(path)] = sha(path)
            key.append(hashes[str(path)])
        loss['historical_plan_sha256'] = key[-1]
        loss['prior_candidate_regression_case'] = gate_keys.get(tuple(key))
        loss['prior_candidate_regression_passed'] = tuple(key) in gate_keys
    for cohort in ('story', 'human', 'mixed'):
        for k in (2, 3, 4, 5):
            for method in ('random', 'causal_link'):
                cells.append({'cohort': cohort, 'k': k, 'method': method, 'stages': {
                    s: {name: {c: summary([r for r in d[s] if (r['cohort'], r['size'], r['method'], r['condition']) == (cohort, k, method, c)])
                               for c in ('union', 'full')} for name, d in data.items()}
                    for s in ('transport', 'anchor', 'composition')}})
    totals = {label: sum(costs[s][label]['all_attempts'][p]['total_seconds'] for s in STAGES for p in ('search', 'replay')) for label in ('before', 'after')}
    assert abs(totals['after']-sum(r['seconds'] for r in receipts)) < 1e-5
    previous_protocol = pin(before/'protocol.json')
    original = {'initial_root': previous_protocol['parent'],
                'final_root': previous_protocol['historical_final'], 'stages': {}}
    original_seconds = 0
    for s in STAGES:
        first = pin(Path(original['initial_root'])/'repeat_01'/f'{s}_report.json')['rows']
        last = pin(Path(original['final_root'])/'repeat_01'/f'{s}_report.json')['rows']
        assert len(first) == len(last) == EXPECTED[s]
        assert {r['id'] for r in first} == {r['id'] for r in last} == set(registered[s])
        conditions = ('raw', 'adapter') if s == 'native' else ('union', 'full')
        times = timing(first+retry_increment(first, last))
        original_seconds += sum(times[p]['total_seconds'] for p in ('search', 'replay'))
        original['stages'][s] = {'final': {c: summary([r for r in last if r['condition'] == c]) for c in conditions},
                                'all_attempts': times}
    original['aggregate_search_replay_seconds'] = original_seconds
    original['wall_time_comparability'] = 'Original execution used mixed concurrency and pauses; no single directly comparable elapsed duration.'
    report = {'status': 'complete_low_memory_full_comparison', 'created_utc': datetime.now(timezone.utc).isoformat(),
              'registered_groups': 1200, 'registered_slots': EXPECTED, 'outcomes': outcomes,
              'paired_transitions': transitions, 'previously_valid_not_returned': losses, 'cells': cells,
              'invocation_timing': costs, 'aggregate_search_replay_seconds': totals,
              'wall_time': {'before': read(before/'timing.json'), 'after': read(root/'timing.json')},
              'original_preoptimization_context': original,
              'concurrency': {'before': 8, 'after': {'checkpoint': 2, 'continuation': 8} if checkpoint else 2}, 'resources': resources,
              'not_original_fresh_budget_completion': bool(checkpoint),
              'checkpoint_retained_rows': protocol.get('retained_rows'),
              'excluded_aborted_conditions': aborted_conditions,
              'remaining_timeout_phases': {name: {s: remaining_timeouts(rows) for s, rows in d.items()} for name, d in data.items()},
              'completed_phase_timings': {name: {s: measured_phases(rows) for s, rows in d.items()} for name, d in data.items()},
              'isolation': read(root/'execution_start.json')['isolation'], 'model_requests': 0,
              'raw_event_binding_verified': True, 'inputs_unchanged': True, 'input_sha256': hashes,
              'limits': ['All 1200 groups and 28684 registered slots remain; unavailable inputs are not backfilled.',
                         'Initial 15-second attempts and one timeout-selected 60-second retry are reported separately.',
                         'Runtime, concurrency (initially 2, then an explicitly authorized 8-worker continuation), and shared memory control changed together. This is descriptive, not an isolated CPU speedup.',
                         'Invocation totals include failed attempts and exclude retained search records in replay-only retries; these are not CPU or elapsed wall time.',
                         'Prior signal exit 137 was ambiguous; new explicit deadline evidence distinguishes timeout from early termination. No retroactive OOM attribution.',
                         'The incomplete v4 trial is preserved separately. The corrected v5 campaign retains completed two-worker checkpoint rows verbatim and explicitly continues unfinished work with eight workers; it is not the original fresh-budget condition.',
                         'Interrupted invocations stay unknown in a separate inventory; matched terminal call totals exclude these censored attempts. End-to-end wall time includes both segments and the switching gap.',
                         'Memory samples and /proc high-water marks are observed bounds, not exact continuous peak total memory.',
                         'Completed phase timings exclude censored intervals; timeout phase counts remain explicit.',
                         'Native validation, physical validation and independent semantic/narrative labels remain separate. No independent semantic labels.']}
    assert all(sha(Path(p)) == h for p, h in hashes.items())
    output.mkdir(parents=True)
    write(output/'report.json', report)
    write(output/'process_receipts.json', {'rows': receipts})
    labels = {'native': '源世界', 'transport': '原始计划运输', 'anchor': '原始目标查询', 'composition': '跨域诊断'}
    lines = ['# 完整 1,200 组：初始化优化与 2→8 并发续跑', '',
             '冻结模型、初始状态、目标、映射和参考计划；28,684 个登记槽位全部保留。LLM 请求为 0。', '',
             '|任务|条件|之前首轮|本次首轮|之前最终|本次最终|登记数|', '|---|---|---:|---:|---:|---:|---:|']
    for s in STAGES:
        for c in (('raw', 'adapter') if s == 'native' else ('union', 'full')):
            values = [outcomes[s][name][c]['dual_validated'] for name in ('before_initial15', 'after_initial15', 'before_final', 'after_final')]
            lines.append('|'+ '|'.join(map(str, [labels[s], c, *values, outcomes[s]['after_final'][c]['registered']]))+'|')
    lines += ['', '表中为原生意图回放与物理回放均通过；最终结果包含首轮 15 秒及仅超时任务的一次 60 秒重试。', '',
              f'累计搜索/回放调用：{totals["before"]/3600:.3f} → {totals["after"]/3600:.3f} 小时，减少 {(1-totals["after"]/totals["before"])*100:.2f}%。',
              f'实际墙钟时间：{report["wall_time"]["before"]["total_wall_seconds"]/3600:.3f} → {report["wall_time"]["after"]["total_wall_seconds"]/3600:.3f} 小时。本次先以 2 并发执行，按用户要求调整为 8 并发并设置总内存限制；包含切换准备间隔，不能作为单独算法加速比。', '',
              f'核验的 Java 调用 {len(receipts)} 次，最大同时运行 {peak} 个；单进程观测 RSS 峰值 {resources["peak_process_rss_gib"]:.2f} GiB，系统可用内存最低 {resources["minimum_host_available_gib"]:.2f} GiB。',
              f'新内核 OOM 相关记录 {len(oom_lines)} 行；Java 堆内存错误 {resources["java_heap_errors"]} 次；非超时信号终止 {resources["early_signal_terminations"]} 次。', '',
              f'完整运行中仍出现的类型转换错误：{resources["remaining_class_cast_errors"]} 次。其他异常类型保留在资源审计中。', '',
              f'原先最终通过但本次未通过：{sum(x["budget"] == "final" for x in losses)} 个，逐项保留原因与历史计划。',
              '原生通过但物理验证不支持仍为 unknown。全部失败、缺失、超时、逐项变化和 24 个分组单元均在 report.json 中保留。',
              '本次包含公理展开和搜索初始化优化；模型与验证规则保持冻结。没有独立语义或叙事质量标注。', '']
    if aborted_conditions:
        excluded = sum(r['elapsed_until_abort_seconds'] for r in aborted_conditions)
        first_launch = min(datetime.fromisoformat(r['first_launch_utc']) for r in aborted_conditions)
        campaign_elapsed = (datetime.fromisoformat(read(root/'launcher_exit.json')['finished_utc'])-first_launch).total_seconds()
        lines += [f'一次未完成轮次因搜索初始化类型转换回归而中止，已执行约 {excluded/60:.1f} 分钟；原始记录完整保留，不混入正式结果。修复后从头执行，并在用户要求调整并发时建立独立续跑条件。',
                  f'从首次启动到本轮完整结束共约 {campaign_elapsed/3600:.2f} 小时，其中包含中止轮次、诊断、修复、回归与准备；该数值不用于算法性能比较。', '']
    if checkpoint:
        t = report['wall_time']['after']
        lines += [f'2 并发阶段 {t["prior_segment_wall_seconds"]/60:.2f} 分钟；切换准备 {t["between_segments_wall_seconds"]/60:.2f} 分钟；8 并发续跑 {t["resumed_execution_wall_seconds"]/60:.2f} 分钟。',
                  f'保留已完成登记行 {sum(protocol["retained_rows"].values())} 条；切换时中断调用 {len(interrupted_invocations)} 次，原始记录和删失时间单列，不计为完成或失败判定。',
                  f'8 并发组内存峰值 {shared_memory["peak_bytes"]/1024**3:.2f} GiB，硬上限 12 GiB；组内 OOM 杀进程 {shared_memory["events_delta"]["oom_kill"]} 次。',
                  '这是显式检查点续跑，不能表述为在原先全新运行预算内完成。', '']
    lines += ['## 原生回放与物理验证未知', '',
              '|任务|条件|之前最终原生通过|本次最终原生通过|本次原生通过但物理未知|',
              '|---|---|---:|---:|---:|']
    for s in STAGES:
        for c in (('raw', 'adapter') if s == 'native' else ('union', 'full')):
            a, b = outcomes[s]['before_final'][c], outcomes[s]['after_final'][c]
            lines.append(f'|{labels[s]}|{c}|{a["native_validated"]}|{b["native_validated"]}|{b["outcomes"].get("native_valid_physical_unknown", 0)}|')
    lines += ['', '## 相对于最初未优化版本', '',
              f'最初未优化版本累计调用 {original_seconds/3600:.3f} 小时；上轮优化版本 {totals["before"]/3600:.3f} 小时；本次 {totals["after"]/3600:.3f} 小时。',
              '最初运行含不同并发和暂停，仅提供累计调用时间与同登记项的最终结果背景。', '',
              '|任务|条件|最初未优化最终通过|上轮最终通过|本次最终通过|', '|---|---|---:|---:|---:|']
    for s in STAGES:
        for c in (('raw', 'adapter') if s == 'native' else ('union', 'full')):
            lines.append(f'|{labels[s]}|{c}|{original["stages"][s]["final"][c]["dual_validated"]}|{outcomes[s]["before_final"][c]["dual_validated"]}|{outcomes[s]["after_final"][c]["dual_validated"]}|')
    lines.append('')
    (output/'comparison.md').write_text('\n'.join(lines), encoding='utf-8')
    print(json.dumps({'status': report['status'], 'totals': totals, 'resources': resources}, ensure_ascii=False))


if __name__ == '__main__':
    def offline(event, args):
        if event in ('socket.connect', 'socket.connect_ex', 'socket.getaddrinfo', 'urllib.Request'):
            raise RuntimeError('Offline report forbids network')
    sys.addaudithook(offline)
    p = argparse.ArgumentParser()
    p.add_argument('--run', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    compare(a.run.resolve(), a.output.resolve())

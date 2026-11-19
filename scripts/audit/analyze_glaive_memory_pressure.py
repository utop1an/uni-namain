"""Bind focused pressure experiments to raw receipts and report censored costs."""
import argparse
import ast
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import statistics
import sys


def read(path): return json.loads(Path(path).read_text(encoding='utf-8'))
def sha(path): return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def key(row): return row['kind'], row['id']
def phase(row):
    events = row.get('search', {}).get('phase_events', [])
    return events[-1]['phase'] if events else 'no_phase'
def counters(value): return {k: int(v) for k, v in (s.split() for s in value.splitlines())}
def psi(value):
    return {line.split()[0]: int(line.rsplit('total=', 1)[1]) for line in value.splitlines()}


def analyze(selection, roots, output):
    assert not output.exists()
    hashes = {}
    hashes[str(Path(__file__).resolve())] = sha(__file__)
    def pin(path):
        path = Path(path).resolve()
        hashes[str(path)] = sha(path)
        return read(path)
    def lines(path):
        hashes[str(path.resolve())] = sha(path)
        raw = path.read_text(encoding='utf-8').splitlines()
        result = []
        for i, line in enumerate(raw):
            try: result.append(json.loads(line))
            except json.JSONDecodeError: assert i == len(raw)-1
        return result
    selected = pin(selection)
    original = pin(Path(selected['parent'])/'comparison_v1/report.json')
    historical = {key(r): r for r in selected['historical_rows']}
    losses = {tuple(k) for k in selected['loss_keys']}
    population = {}
    for stage in ('native', 'transport', 'anchor', 'composition'):
        prior = pin(Path(selected['parent'])/'repeat_01'/f'{stage}_report.json')
        for row in prior['rows']:
            if row.get('search', {}).get('status') == 'wall_time_limit':
                assert key(row) not in population
                population[key(row)] = row
    assert len(population) == 586 and dict(Counter(phase(r) for r in population.values())) == selected['phase_counts']
    assert all(population[k] == r for k,r in historical.items())
    late = [r['search']['phase_events'][-1] for r in population.values() if phase(r) == 'result']
    arms, metrics = {}, {}
    execution_signatures = set()
    for label, root in roots.items():
        p = pin(root/'protocol.json')
        code = ast.parse((root/'runner.py').read_text(encoding='utf-8'))
        run_code = next(node for node in code.body if isinstance(node, ast.FunctionDef) and node.name == 'run')
        execution_signatures.add((hashlib.sha256(ast.dump(run_code, include_attributes=False).encode()).hexdigest(), sha(root/'supervisor.py'), sha(root/'executor.py')))
        report = pin(root/'report.json')
        execution_start = pin(root/'execution_start.json')
        isolation = execution_start['isolation']
        assert [x[1] for x in isolation['network_interfaces']] == ['lo']
        assert isolation['python_network_audit'] == 'deny' and isolation['credential_environment'] == 'removed'
        assert isolation['model_requests'] == 0
        assert pin(root/'launcher_exit.json')['returncode'] == 0
        assert report['inputs_unchanged'] and report['model_requests'] == 0
        assert sha(root/'protocol.json') == (root/'PROTOCOL.sha256').read_text().strip()
        tasks = {key(t): t for t in p['tasks']}
        rows = {key(r): r for r in report['rows']}
        assert len(rows) == len(report['rows']) == report['registered'] == p['registered']
        assert set(rows) == set(tasks) == (losses if p.get('losses_only') else set(historical))
        events = lines(root/'diagnostic_events.jsonl')
        assert {key(r): r for r in events} == rows and len(events) == len(rows)
        for k, task in tasks.items():
            for field in ('domain', 'problem', 'mapping', 'condition'):
                assert task.get(field) == historical[k].get(field) == rows[k].get(field)
        before, after = pin(root/'cgroup_before.json'), pin(root/'cgroup_after.json')
        assert before['path'] == after['path'] == execution_start['private_cgroup']
        assert int(before['memory.high']) == int(after['memory.high']) == p['shared_memory_high_bytes']
        assert int(after['memory.max']) == 12*1024**3 and after['cgroup.procs'] == ''
        kernel0, kernel1 = pin(root/'kernel_before.json'), pin(root/'kernel_after.json')
        assert kernel0['boot_id'] == kernel1['boot_id'] and kernel0['returncode'] == kernel1['returncode'] == 0
        assert kernel1['stdout'].startswith(kernel0['stdout']), 'Kernel log wrapped; cannot isolate new OOM events'
        new_kernel = kernel1['stdout'][len(kernel0['stdout']):]
        killed_pids = {int(pid) for pid in re.findall(r'Killed process (\d+) \(java\)', new_kernel)}
        oom_scope_lines = [line for line in new_kernel.splitlines() if 'oom-kill:' in line]
        group_name = Path(execution_start['private_cgroup']).name
        assert all('constraint=CONSTRAINT_MEMCG' in line and 'cpuset='+group_name+',' in line for line in oom_scope_lines)
        assert len(oom_scope_lines) == len(killed_pids)
        pressure = lines(root/'pressure.jsonl')
        p0, p1 = psi(pressure[0]['memory.pressure']), psi(pressure[-1]['memory.pressure'])
        c0, c1 = counters(before['memory.events']), counters(after['memory.events'])
        cpu0, cpu1 = counters(pressure[0]['cpu.stat']), counters(pressure[-1]['cpu.stat'])
        current = {}
        aggregate_top = Counter()
        intervals = []
        total_calls = 0.0
        signal_receipts = []
        for k, row in rows.items():
            phase_times = {e['phase']: e['elapsed_seconds'] for e in row['search'].get('phase_events', [])}
            cost = {'status': row['search']['status'], 'last_phase': phase(row),
                    'search_seconds': row['search'].get('seconds'),
                    'native_valid': bool(row.get('native_valid')), 'dual_valid': bool(row.get('valid')),
                    'search_start_seconds': next((x['elapsed_seconds'] for x in row['search'].get('phase_events', []) if x['phase']=='search_begin'), None)}
            cost['completed_phase_seconds'] = {name: phase_times[name+'_end']-phase_times[name+'_begin']
                for name in ('parse', 'state_space', 'axiom_filter', 'axiom_tree', 'search_setup')
                if name+'_begin' in phase_times and name+'_end' in phase_times}
            cost['physical_validation'] = row.get('replay', {}).get('physical')
            for mode in ('search', 'replay'):
                directory = root/'repeat_01/execution'/k[0]/k[1]/mode
                if not (directory/'process_start.json').exists(): continue
                start, end = pin(directory/'process_start.json'), pin(directory/'process_exit.json')
                actual, command = pin(directory/'result.json'), pin(directory/'effective_command.json')['command']
                invocation = pin(directory/'invocation.json')
                assert invocation['seconds'] == p['seconds'] == 60 and invocation['memory_mb'] == p['heap_mb'] == 4096
                for path, digest in invocation['input_sha256'].items():
                    assert sha(path) == digest, path
                    hashes[str(Path(path).resolve())] = digest
                if (directory/'plan.pddl').exists():
                    hashes[str((directory/'plan.pddl').resolve())] = sha(directory/'plan.pddl')
                assert '-Xmx4096m' in command and all(flag in command for flag in p['jvm_flags'])
                assert start['pid'] == end['pid'] and start['start_ticks'] == end['start_ticks']
                assert start['boot_id'] == end['boot_id'] == kernel0['boot_id']
                assert all(row[mode].get(f) == v for f, v in actual.items())
                assert actual['status'] != 'wall_time_limit' or end['deadline_triggered']
                if actual['status'] == 'terminated_by_signal':
                    signal_receipts.append({'kind': k[0], 'id': k[1], 'mode': mode, 'pid': start['pid'],
                        'status': actual['status'], 'deadline_triggered': end['deadline_triggered']})
                total_calls += end['seconds']
                intervals += [(start['started_utc'], 1), (end['finished_utc'], -1)]
                telemetry = lines(directory/'telemetry.jsonl')
                hashes[str((directory/'gc.log').resolve())] = sha(directory/'gc.log')
                hashes[str((directory/'stdout.txt').resolve())] = sha(directory/'stdout.txt')
                if mode == 'search':
                    tops = Counter(f for t in telemetry for thread in t['threads'] for f in thread['frames'][:3] if 'stephengware' in f)
                    aggregate_top.update(tops)
                    cost.update(peak_rss_gib=end['peak_sampled_rss_kb']/1048576,
                        peak_heap_used_gib=max((t['heap_used'] for t in telemetry), default=0)/1024**3,
                        gc_millis=max((t['gc_millis'] for t in telemetry), default=0),
                        top_frames=tops.most_common(8), telemetry_samples=len(telemetry))
            current[k] = cost
        active = peak = 0
        for _, d in sorted(intervals):
            active += d; peak = max(peak, active)
            assert active >= 0
        assert active == 0 and peak <= p['workers']
        assert len(killed_pids) == c1['oom_kill']-c0['oom_kill'], 'Kernel and private-cgroup OOM counts differ'
        for path, digest in p['input_sha256'].items(): assert sha(path) == digest, path
        arms[label] = {'root': str(root), 'registered': len(rows), 'workers': p['workers'], 'jvm_flags': p['jvm_flags'],
            'jar_sha256': sha(root/'runtime.jar'), 'soft_memory_gib': p['shared_memory_high_bytes']/1024**3,
            'hard_memory_gib': 12, 'wall_seconds': report['seconds'], 'aggregate_call_seconds': total_calls,
            'search_statuses': dict(Counter(r['search']['status'] for r in rows.values())),
            'native_valid': sum(bool(r.get('native_valid')) for r in rows.values()),
            'dual_valid': sum(bool(r.get('valid')) for r in rows.values()),
            'native_only_reasons': dict(Counter(r.get('replay', {}).get('physical', {}).get('reason', 'unknown')
                for r in rows.values() if r.get('native_valid') and not r.get('valid'))),
            'regression_losses_recovered': sum(bool(rows[k].get('valid')) for k in losses),
            'reached_search': sum(any(e['phase']=='search_begin' for e in r['search'].get('phase_events', [])) for r in rows.values()),
            'last_phases': dict(Counter(phase(r) for r in rows.values())),
            'peak_overlapping_java': peak, 'peak_group_gib': int(after['memory.peak'])/1024**3,
            'memory_events': {k: c1[k]-c0[k] for k in c0},
            'early_signal_receipts': signal_receipts,
            'kernel_oom_parent_namespace_pids': sorted(killed_pids),
            'kernel_oom_scope_verified': True,
            'individual_oom_pid_binding': 'unavailable: kernel uses the parent PID namespace, process receipts use the WSL namespace; NSpid mappings were not captured',
            'offline_isolation_verified': True,
            'memory_pressure_stall_seconds': {k:(p1[k]-p0[k])/1e6 for k in p0},
            'group_cpu_seconds': (cpu1['usage_usec']-cpu0['usage_usec'])/1e6,
            'top_frames': aggregate_top.most_common(15),
            'by_historical_phase': {s: {'registered': sum(phase(historical[k])==s for k in rows),
                'native': sum(bool(r.get('native_valid')) and phase(historical[k])==s for k,r in rows.items()),
                'dual': sum(bool(r.get('valid')) and phase(historical[k])==s for k,r in rows.items()),
                'timeout': sum(r['search']['status']=='wall_time_limit' and phase(historical[k])==s for k,r in rows.items())}
                for s in selected['sample_phase_counts']}}
        metrics[label] = current
    assert len(execution_signatures) == 1, 'Execution code changed across diagnostic arms'
    pairs = []
    for k, old in historical.items():
        pairs.append({'id': k[0]+'/'+k[1], 'kind': k[0], 'task_id': k[1], 'historical_phase': phase(old),
            'historical_search_seconds': old['search']['seconds'],
            'full_run_regression': k in losses, 'arms': {label: rows[k] for label, rows in metrics.items() if k in rows}})
    report = {'status': 'complete_focused_pressure_analysis', 'created_utc': datetime.now(timezone.utc).isoformat(),
        'registered': 32, 'rows': pairs, 'arms': arms, 'population_timeouts': 586,
        'population_phase_counts': selected['phase_counts'], 'input_sha256': hashes,
        'historical_shared_memory': original['resources']['shared_memory'],
        'historical_late_results': {'count': len(late), 'result_statuses': dict(Counter(e['status'] for e in late)),
            'jvm_elapsed_seconds_min': min(e['elapsed_seconds'] for e in late),
            'jvm_elapsed_seconds_max': max(e['elapsed_seconds'] for e in late)},
        'raw_binding_verified': True, 'execution_code_identical_across_arms': True,
        'inputs_unchanged': True, 'model_requests': 0,
        'limits': ['32 phase-balanced development cases, including all four regressions; no full-586 or full-1200 improvement claim.',
            'The four-case 1.5 GiB soft-limit probe isolates a memory-pressure mechanism from worker count; it is not the original 10 GiB condition.',
            'All standalone JVMs are fresh. Results do not replace the preserved full run or count as original-budget completion.',
            'Native and dual validation stay separate; no-solution-returned and resource limits are not successes or independent semantic labels.',
            'Instrumentation is identical across paired arms but differs from the historical full run. Single runs do not isolate all scheduling and JVM-order variability.',
            'Elapsed call totals include deadlines/cleanup; they are not CPU time. Memory PSI reports group stall time, not per-task causal attribution.',
            'Kernel OOM events are bound to the private cgroup, not to individual invocation PIDs; WSL parent/child PID mappings were not captured.']}
    assert all(sha(path)==digest for path,digest in hashes.items())
    output.mkdir(parents=True)
    (output/'analysis_snapshot.py').write_bytes(Path(__file__).read_bytes())
    (output/'report.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    lines_md = ['# 超时、并发与内存限流对照', '',
        '旧的 1,200 组结果保持不变。本报告是独立的定向诊断与回归；全部调用离线，LLM 请求为 0。', '',
        '原完整运行剩余 586 项超时：状态空间构建 63，搜索初始化 148，搜索中 360，截止后宽限期才输出结果 15。',
        '冻结 32 项样本，每个阶段 8 项，含全部 4 项回退。另以这 4 项做固定 2 并发的人工内存压力对照。', '',
        '|条件|登记数|并发|软阈值 GiB|原生通过|双重通过|搜索超时|堆错误|提前信号终止|耗时 秒|内存峰值 GiB|组 OOM 杀进程|',
        '|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|']
    for label,a in arms.items():
        s=a['search_statuses']
        lines_md.append(f'|{label}|{a["registered"]}|{a["workers"]}|{a["soft_memory_gib"]:g}|{a["native_valid"]}|{a["dual_valid"]}|{s.get("wall_time_limit",0)}|{s.get("memory_limit",0)}|{s.get("terminated_by_signal",0)}|{a["wall_seconds"]:.2f}|{a["peak_group_gib"]:.2f}|{a["memory_events"]["oom_kill"]}|')
    lines_md += ['', '所有条件单调用预算均为 60 秒，单 JVM 堆上限为 4 GiB，组硬上限为 12 GiB。gc2 条件仅设置 ActiveProcessorCount=2；optimized 同时使用新的搜索初始化实现。', '',
        '|条件|组内存限流事件|全部可运行进程均受内存阻塞 秒|部分进程受内存阻塞 秒|组 CPU 秒|', '|---|---:|---:|---:|---:|']
    for label,a in arms.items():
        stall=a['memory_pressure_stall_seconds']
        lines_md.append(f'|{label}|{a["memory_events"]["high"]}|{stall["full"]:.3f}|{stall["some"]:.3f}|{a["group_cpu_seconds"]:.2f}|')
    lines_md += ['', '## 四项回退的逐项证据', '']
    for r in pairs:
        if not r['full_run_regression']: continue
        lines_md += [f'### {r["task_id"]}', '', '|条件|搜索状态|搜索秒|双重通过|最终阶段|', '|---|---|---:|---|---|']
        for label,c in r['arms'].items():
            lines_md.append(f'|{label}|{c["status"]}|{c["search_seconds"]:.3f}|{c["dual_valid"]}|{c["last_phase"]}|')
        lines_md.append('')
    lines_md += ['## 边界', '', *['- '+s for s in report['limits']], '']
    (output/'comparison.md').write_text('\n'.join(lines_md), encoding='utf-8')
    compact = {k: {f:v for f,v in a.items() if f in ('registered','wall_seconds','native_valid','dual_valid','search_statuses','memory_events','peak_group_gib')} for k,a in arms.items()}
    print(json.dumps({'status': report['status'], 'arms': compact}, ensure_ascii=False), flush=True)
    return report


if __name__ == '__main__':
    def offline(event,args):
        if event in ('socket.connect','socket.connect_ex','socket.getaddrinfo','urllib.Request'): raise RuntimeError('Offline analysis')
    sys.addaudithook(offline)
    p=argparse.ArgumentParser();p.add_argument('--selection',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--arm',action='append',required=True)
    a=p.parse_args();analyze(a.selection.resolve(),{k:Path(v).resolve() for k,v in (x.split('=',1) for x in a.arm)},a.output.resolve())

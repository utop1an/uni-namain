"""Compare all registered outcomes and invocation costs without new execution."""
import argparse
from collections import Counter
from datetime import datetime,timezone
import hashlib
import json
from pathlib import Path
import statistics


STAGES=('native','transport','anchor','composition')
def read(p):return json.loads(Path(p).read_text(encoding='utf-8'))
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def write(p,value):
    p.parent.mkdir(parents=True,exist_ok=True)
    with p.open('x',encoding='utf-8') as f:json.dump(value,f,ensure_ascii=False,indent=2);f.write('\n')
def classify(r):
    if r.get('valid'):return 'dual_validated'
    if r.get('replay'):
        physical=r['replay'].get('physical',{})
        if physical.get('status')=='inapplicable' or physical.get('status')=='replayed' and physical.get('goal') is False:return 'physical_violation'
        if r['replay'].get('status')=='replayed' and (r['replay'].get('goal') is False or r['replay'].get('unexplained_steps',0)>0):return 'intentional_or_goal_violation'
        if r.get('native_valid'):return 'native_valid_physical_unknown'
        return 'replay_'+r['replay'].get('status','unknown')
    if r.get('search',{}).get('status') in ('solved','not_a_search'):return 'replay_not_recorded'
    return r.get('search',{}).get('status',r.get('status','unknown'))
def summary(rows):
    return {'registered':len(rows),'dual_validated':sum(bool(r.get('valid')) for r in rows),
            'native_validated':sum(bool(r.get('native_valid')) for r in rows),
            'goal_achieved_from_initial_false':sum(bool(r.get('valid')) and r.get('replay',{}).get('physical',{}).get('initial_goal') is False for r in rows),
            'initial_goal_already_true':sum(bool(r.get('valid')) and r.get('replay',{}).get('physical',{}).get('initial_goal') is True for r in rows),
            'outcomes':dict(Counter(classify(r) for r in rows))}
def timing(rows):
    result={}
    for phase in ('search','replay'):
        values=[r[phase]['seconds'] for r in rows if isinstance(r.get(phase,{}).get('seconds'),(int,float))]
        result[phase]={'measured_calls':len(values),'total_seconds':sum(values),'median_seconds':statistics.median(values) if values else None,
                       'p95_seconds':sorted(values)[min(len(values)-1,int(.95*len(values)))] if values else None}
    return result
def retry_increment(initial,terminal):
    old={r['id']:r for r in initial};out=[]
    for r in terminal:
        row={'id':r['id']}
        for phase in ('search','replay'):
            value=r.get(phase,{})
            if value!=old[r['id']].get(phase,{}) and isinstance(value.get('seconds'),(int,float)):row[phase]=value
        if len(row)>1:out.append(row)
    return out
def stage_counts(rows,initial=False):
    counts=Counter()
    for r in rows:
        s=r.get('search',{})
        if s.get('status') not in ('wall_time_limit','worker_wall_time_limit'):continue
        phases=[p.get('phase') for p in s.get('phase_events',[])]
        counts['after_search_started' if 'search_begin' in phases else 'before_search_started']+=1
        if phases:counts['last_phase:'+phases[-1]]+=1
    return dict(counts)

def remaining_timeouts(rows):
    replay=Counter()
    for row in rows:
        result=row.get('replay',{})
        if result.get('status')=='wall_time_limit':
            events=result.get('phase_events',[])
            replay[events[-1].get('phase','unknown') if events else 'unknown']+=1
    return {'search':stage_counts(rows),'replay_last_phase':dict(replay)}

def measured_phases(rows):
    result={}
    for mode in ('search','replay'):
        samples={}
        for row in rows:
            starts={}
            for event in row.get(mode,{}).get('phase_events',[]):
                phase=event.get('phase','');seconds=event.get('elapsed_seconds')
                if phase.endswith('_begin'):starts[phase[:-6]]=seconds
                elif phase.endswith('_end') and phase[:-4] in starts:
                    samples.setdefault(phase[:-4],[]).append(seconds-starts[phase[:-4]])
        result[mode]={k:{'completed_intervals':len(v),'median_seconds':statistics.median(v),'total_measured_seconds':sum(v)} for k,v in samples.items()}
    return result


def compare(original,old_final,new,output):
    if output.exists():raise ValueError('Fresh comparison output required')
    if read(new/'coordinator.json')['status']!='complete':raise ValueError('Optimized run incomplete')
    output.mkdir(parents=True)
    snapshot=output/'compare_implementation.py';snapshot.write_bytes(Path(__file__).read_bytes())
    paths=[snapshot,new/'protocol.json',new/'timing.json',new/'execution_start.json',new/'PROTOCOL.sha256']
    correction=read(new/'reconciliation.json') if (new/'reconciliation.json').exists() else None
    execution_root=Path(correction['execution_root']) if correction else new
    if correction:paths.append(new/'reconciliation.json')
    excluded=[]
    for receipt in sorted(execution_root.parent.glob(execution_root.name.rsplit('_v',1)[0]+'_v*/abort_receipt.json')):
        paths.append(receipt)
        accounting=receipt.parent/'aborted_slot_accounting.json'
        if accounting.exists():paths.append(accounting)
        excluded.append({'path':str(receipt.parent),'receipt':read(receipt),
                         'slot_accounting':read(accounting) if accounting.exists() else None})
    roots={'before_initial15':original,'before_final':old_final,'after_initial15':new/'initial15','after_final':new}
    data={}
    for name,root in roots.items():
        data[name]={}
        for stage in STAGES:
            p=root/'repeat_01'/(stage+'_report.json');paths.append(p);rows=read(p)['rows']
            if len(rows)!=len({r['id'] for r in rows}):raise ValueError('Duplicate result identity')
            if any(r.get('kind',stage)!=stage for r in rows):raise ValueError('Result assigned to the wrong evaluation stage')
            data[name][stage]=rows
    hashes={str(p.resolve()):sha(p) for p in paths}
    cells=[];transitions=[];lost=[];outcomes={};costs={}
    for stage in STAGES:
        baseline_ids={r['id'] for r in data['before_initial15'][stage]}
        if any({r['id'] for r in d[stage]}!=baseline_ids for d in data.values()):raise ValueError('Changed registered denominator')
        conditions=('raw','adapter') if stage=='native' else ('union','full')
        outcomes[stage]={name:{c:summary([r for r in d[stage] if r['condition']==c]) for c in conditions} for name,d in data.items()}
        for budget in ('initial15','final'):
            before={r['id']:r for r in data['before_'+budget][stage]};after={r['id']:r for r in data['after_'+budget][stage]}
            for c in conditions:
                rr=[r for r in after.values() if r['condition']==c]
                matrix=Counter((classify(before[r['id']]),classify(r)) for r in rr)
                transitions.append({'stage':stage,'budget':budget,'condition':c,'registered':len(rr),
                    'gained_dual_validated':sum(r.get('valid') and not before[r['id']].get('valid') for r in rr),
                    'lost_dual_validated':sum(before[r['id']].get('valid') and not r.get('valid') for r in rr),
                    'matrix':[{'before':a,'after':b,'count':n} for (a,b),n in sorted(matrix.items())]})
            for id,r in after.items():
                if before[id].get('valid') and not r.get('valid'):
                    lost.append({'stage':stage,'budget':budget,'id':id,'after':classify(r),'historical_plan':before[id].get('plan')})
        costs[stage]={}
        for label in ('before','after'):
            first=data[label+'_initial15'][stage];extra=retry_increment(first,data[label+'_final'][stage])
            costs[stage][label]={'initial15':timing(first),'retry60_increment':timing(extra),'all_attempts':timing(first+extra)}
    for cohort in ('story','human','mixed'):
        for k in (2,3,4,5):
            for method in ('random','causal_link'):
                row={'cohort':cohort,'k':k,'method':method,'stages':{}}
                for stage in ('transport','anchor','composition'):
                    row['stages'][stage]={name:{c:summary([r for r in d[stage] if (r['cohort'],r['size'],r['method'],r['condition'])==(cohort,k,method,c)]) for c in ('union','full')} for name,d in data.items()}
                cells.append(row)
    totals={label:sum(costs[s][label]['all_attempts'][phase]['total_seconds'] for s in STAGES for phase in ('search','replay')) for label in ('before','after')}
    if correction:
        retry_seconds=sum(costs[s]['after']['retry60_increment'][phase]['total_seconds'] for s in STAGES for phase in ('search','replay'))
        if abs(retry_seconds-correction['actual_retry_invocation_seconds'])>1e-6:
            raise ValueError('Retry timing does not match the independently verified invocation receipts')
    result={'status':'complete_paired_optimization_comparison','created_utc':datetime.now(timezone.utc).isoformat(),
        'registered_groups':1200,'registered_slots':{s:len(data['after_final'][s]) for s in STAGES},
        'outcomes':outcomes,'paired_transitions':transitions,'previously_valid_not_returned':lost,'cells':cells,
        'excluded_aborted_setup_attempts':excluded,
        'postprocessing_correction':correction,
        'invocation_timing':costs,'aggregate_search_replay_seconds':totals,
        'aggregate_invocation_speedup':totals['before']/totals['after'],
        'optimized_wall':read(new/'timing.json'),'optimized_timeout_phases':{name:{c:stage_counts([r for r in d['composition'] if r['condition']==c]) for c in ('union','full')} for name,d in data.items() if name.startswith('after')},
        'remaining_timeout_phases':{name:{stage:remaining_timeouts(rows) for stage,rows in d.items()} for name,d in data.items() if name.startswith('after')},
        'completed_phase_timings':{name:{stage:measured_phases(rows) for stage,rows in d.items()} for name,d in data.items() if name.startswith('after')},
        'isolation':read(new/'execution_start.json')['isolation'],'model_requests':0,'input_sha256':hashes,
        'limits':['Both 15-second fresh results and retained15 plus one timeout-selected60 retry are shown separately.',
                  'Aggregate invocation time sums bounded search/replay durations, including failed attempts; it is not elapsed wall time or CPU time.',
                  'Phase duration summaries include only completed begin/end intervals. Timed-out intervals remain censored and have separate counts.',
                  'Historical execution mixed two/eight workers and pauses; optimized dispatch runs inside Linux. Speedup includes dispatch and runtime changes.',
                  'Compiler outputs, original reference selection and all unavailable slots stay fixed. Construction is not rerun or timed here.',
                  'Runtime changes can alter search tie-breaking. A previously found plan not found again does not establish a semantic regression or unsolvability.',
                  'Regression/setup and explicitly aborted debugging attempts are retained separately and excluded from the completed fresh-run timing comparison.',
                  'Native replay retains original axiom contexts and rechecks rule applicability. This runtime correctness fix is part of the treatment.',
                  'Dual validation and native-only physical-unknown outcomes remain separate. No independent semantic/narrative labels.']}
    if not all(sha(p)==h for p,h in hashes.items()):raise ValueError('Comparison input changed')
    write(output/'report.json',result)
    lines=['优化前后完整实验对比','','固定 1,200 组、28,684 个登记槽位；所有失败、缺失和不支持项保留。','LLM 请求：0；执行环境只有回环网络接口。','',
           '任务 | 条件 | 优化前15秒 | 优化后15秒 | 优化前最终 | 优化后最终 | 登记数']
    labels={'native':'原始源世界','transport':'原始计划运输','anchor':'原始目标查询','composition':'跨域诊断'}
    for stage in STAGES:
        for c in (('raw','adapter') if stage=='native' else ('union','full')):
            values=[outcomes[stage][name][c]['dual_validated'] for name in roots]
            # Present initial pairs before final pairs.
            a,b,d,e=values
            lines.append(f'{labels[stage]} | {c} | {a} | {d} | {b} | {e} | {outcomes[stage]["after_final"][c]["registered"]}')
    lines+=['','最终 = 保留15秒首轮结果，仅超时任务再试一次60秒；不等于全部任务统一60秒。','',
            f'累计搜索与回放调用耗时：{totals["before"]/3600:.3f} → {totals["after"]/3600:.3f} 小时，降低 {(1-totals["after"]/totals["before"])*100:.2f}%。',
            f'新实验实际墙钟时间：{result["optimized_wall"]["total_wall_seconds"]/3600:.3f} 小时。',
            '累计调用时间包含失败与两次尝试，不能当作机器实际运行时间；旧实验存在并发变化与暂停，墙钟时间不能作严格性能倍数。','',
            '任务 | 优化前累计调用小时 | 优化后累计调用小时']
    for stage in STAGES:
        times={label:sum(costs[stage][label]['all_attempts'][phase]['total_seconds'] for phase in ('search','replay'))/3600 for label in ('before','after')}
        lines.append(f'{labels[stage]} | {times["before"]:.3f} | {times["after"]:.3f}')
    lines+=['','原先最终通过、这次最终未通过的任务：'+str(sum(r['budget']=='final' for r in lost))+' 个。',
            '所有逐项收益、退步、未通过原因、分阶段超时和24个实验单元的结果均保存在 report.json。','',
            '优化包含对象候选过滤、动作哈希修复、图节点存储扩容、公理静态条件处理、直接计划回放及公理适用性复核。',
            '模型、任务、映射、参考计划和物理验证规则没有更改。搜索顺序可能改变；逐项收益和退步见 JSON 配对表。',
            '准备、回归以及因超时返回码识别修正而中止的调试轮次单独保留，不计入正式完整实验耗时。',
            '原生通过但物理验证不支持的结果仍为 unknown；结果不代表独立语义或故事质量验证。','']
    if correction:
        lines+=['此报告根据原始逐项记录重新汇总，使用阶段与任务编号联合标识，修正跨阶段同名任务的重试合并。',
                '没有新增规划、回放或模型调用；正式运行时间沿用同一次完整执行。此前汇总保留并标为已替代。','']
    (output/'comparison_zh.txt').write_text('\n'.join(lines),encoding='utf-8')
    write(output/'evidence_sha256.json',{str(p.resolve()):sha(p) for p in output.iterdir() if p.is_file()})
    print(json.dumps({'status':result['status'],'groups':1200,'aggregate_seconds':totals,'lost_final':sum(r['budget']=='final' for r in lost),'report':str(output/'report.json')},ensure_ascii=False))


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--original',type=Path,required=True);p.add_argument('--historical-final',type=Path,required=True)
    p.add_argument('--optimized',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    compare(a.original.resolve(),a.historical_final.resolve(),a.optimized.resolve(),a.output.resolve())

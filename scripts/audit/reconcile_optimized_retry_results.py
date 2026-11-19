"""Rebuild derived summaries from complete frozen events, without new execution."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import sys
from scripts.experiments.run_optimized_frozen_evaluation import merge_retry_results, EXPECTED


def read(path): return json.loads(path.read_text(encoding='utf-8'))
def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def write(path,value):
    path.parent.mkdir(parents=True,exist_ok=True)
    with path.open('x',encoding='utf-8') as f: json.dump(value,f,ensure_ascii=False,indent=2)


def reconcile(root,output):
    if output.exists(): raise ValueError('Fresh derived output required')
    assert read(root/'coordinator.json')['status']=='complete'
    assert read(root/'timing.json')['inputs_unchanged']
    inputs={}
    def pin(path): inputs[str(path.resolve())]=digest(path)
    def copy(src,dest):
        pin(src); dest.parent.mkdir(parents=True,exist_ok=True); shutil.copyfile(src,dest)
    initial={}; event_rows=0
    for stage,count in EXPECTED.items():
        report=root/'initial15/repeat_01'/f'{stage}_report.json'
        pin(report); initial[stage]=read(report)['rows']
        assert len(initial[stage])==count
        by_id={r['id']:r for r in initial[stage]}
        assert len(by_id)==count
        event=root/'initial15'/f'{stage}_events.jsonl'; pin(event)
        events=[json.loads(line) for line in event.read_text(encoding='utf-8').splitlines()]
        assert len(events)==len({r['id'] for r in events})
        for row in events:
            assert row==by_id[row['id']] and row['kind']==stage
        event_rows+=len(events)
    registry=root/'retry_registry.json'; event=root/'retry60/retry_events.jsonl'
    pin(registry); pin(event)
    jobs=read(registry)['jobs']
    retried=[json.loads(line) for line in event.read_text(encoding='utf-8').splitlines()]
    registered={(j['task']['kind'],j['task']['id']):j for j in jobs}
    assert len(registered)==len(jobs)==len(retried)==read(registry)['registered']
    assert set(registered)=={(r['kind'],r['id']) for r in retried}
    receipt_count=0; actual_retry_seconds=0
    for row in retried:
        job=registered[(row['kind'],row['id'])]
        for key,value in job['task'].items():
            if key!='status': assert row[key]==value,(row['kind'],row['id'],key)
        for phase in ('search','replay'):
            if phase=='search' and job.get('replay_plan'): continue
            result=row.get(phase,{})
            if not isinstance(result.get('seconds'),(int,float)): continue
            receipt=root/'retry60/repeat_01/execution'/row['kind']/row['id']/phase/'result.json'
            invocation=receipt.parent/'invocation.json'
            pin(receipt); pin(invocation); actual=read(receipt)
            assert all(result.get(k)==v for k,v in actual.items()),str(receipt)
            assert read(invocation)['mode']==phase and read(invocation)['seconds']==60
            receipt_count+=1; actual_retry_seconds+=actual['seconds']
    combined=merge_retry_results(initial,retried)
    changed={}
    for stage,rows in combined.items():
        oldfile=root/'repeat_01'/f'{stage}_report.json'; pin(oldfile)
        old={r['id']:r for r in read(oldfile)['rows']}
        changed[stage]=[r['id'] for r in rows if r!=old[r['id']]]
    output.mkdir(parents=True,exist_ok=False)
    for src in root.iterdir():
        if src.is_file() and src.name not in ('postprocessing_notice.json',):copy(src,output/src.name)
    for src in (root/'repeat_01').glob('*.json'):
        if src.name not in {s+'_report.json' for s in EXPECTED}:copy(src,output/'repeat_01'/src.name)
    for src in (root/'repeat_01/groups').glob('*/compilation.json'):
        copy(src,output/'repeat_01/groups'/src.parent.name/src.name)
    for stage,rows in combined.items():
        copy(root/'initial15/repeat_01'/f'{stage}_report.json',output/'initial15/repeat_01'/f'{stage}_report.json')
        write(output/'repeat_01'/f'{stage}_report.json',{'status':'complete_registered_slots','registered_slots':len(rows),'rows':rows})
    copy(Path(__file__),output/'reconciliation_implementation.py')
    import scripts.experiments.run_optimized_frozen_evaluation as runner
    copy(Path(runner.__file__),output/'corrected_runner_source.py')
    assert all(digest(Path(p))==h for p,h in inputs.items())
    report={'status':'reconciled_complete_execution','execution_root':str(root),
        'derived_root':str(output),'registered_slots':EXPECTED,'initial_events_verified':event_rows,
        'retry_events_verified':len(retried),'retry_invocation_receipts_verified':receipt_count,
        'actual_retry_invocation_seconds':actual_retry_seconds,
        'corrected_rows_by_stage':{s:len(ids) for s,ids in changed.items()},'corrected_ids':changed,
        'inputs_unchanged':True,'input_sha256':inputs,'new_model_calls':0,'new_planner_calls':0,'new_replay_calls':0,
        'reason':'Final merge used globally shared task IDs. Corrected join uses (stage, task ID). Original execution, attempts, input files, budgets and timings are unchanged.',
        'supersedes':[str(root/'evaluation'),str(root/'paired_review_v1'),str(root/'comparison')]}
    write(output/'reconciliation.json',report)
    write(root/'postprocessing_notice.json',{'status':'derived_summaries_superseded','use':str(output),
        'reason':report['reason'],'raw_execution_unchanged':True,'reconciliation_sha256':digest(output/'reconciliation.json')})
    print(json.dumps({k:report[k] for k in ('status','initial_events_verified','retry_events_verified','retry_invocation_receipts_verified','corrected_rows_by_stage')},ensure_ascii=False))
    return report


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--root',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    def offline(event,args):
        if event in ('socket.connect','socket.connect_ex','socket.getaddrinfo','urllib.Request'):raise RuntimeError('Offline reconciliation')
    sys.addaudithook(offline)
    reconcile(args.root.resolve(),args.output.resolve())

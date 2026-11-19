"""Fresh, separately labelled followup using a verified corrected Glaive JAR."""
import argparse
from datetime import datetime, timezone
import json
from pathlib import Path

from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.glaive_runtime import invoke
from scripts.experiments import run_revised_followup as engine

PARENT=Path('data/validation/revised_followup_2026_11_01_v1')
RUNTIME=Path('data/validation/glaive_runtime_correction_2026_11_01_v5')


def prepare(root):
    if root.exists():raise ValueError('Fresh directory required')
    protocol=engine.read(PARENT/'protocol.json');runtime=engine.read(RUNTIME/'report.json')
    if runtime['status']!='verified':raise ValueError('Corrected runtime failed its regression gate')
    if engine.read(PARENT/'report.json')['status']!='blocked_by_branch_gate':raise ValueError('Unexpected parent status')
    for p,h in {**protocol['input_sha256'],**protocol['implementation_sha256'],**runtime['output_sha256']}.items():
        if digest(Path(p))!=h:raise ValueError('Changed frozen input: '+p)
    root.mkdir(parents=True)
    protocol.update(created_utc=datetime.now(timezone.utc).isoformat(),
        parent_protocol=str(PARENT/'protocol.json'),parent_report=str(PARENT/'report.json'),
        runtime_variant='glaive_disjunction_and_empty_type_correction',runtime_jar=runtime['jar'],
        runtime_jar_sha256=runtime['jar_sha256'],runtime_report=str(RUNTIME/'report.json'),
        status='frozen_before_corrected_runtime_execution')
    protocol['policy'] += ['New runtime condition, fresh execution of all identical 610 branch probes and (if gate passes) 36 composition searches.',
        'The original stopped run is retained. This is neither a continuation nor replacement of the primary experiment.',
        'Both returned-plan replay and search use the corrected JAR; no new model calls.']
    files=[PARENT/'protocol.json',PARENT/'report.json',RUNTIME/'report.json']
    protocol['input_sha256'].update(runtime['output_sha256'])
    protocol['input_sha256'].update({str(p):digest(p) for p in files})
    protocol['implementation_sha256'].update(snapshot_implementation(root,[Path(__file__)]))
    save(root/'protocol.json',protocol)
    return {'status':protocol['status'],'branch_tasks':len(protocol['branch_tasks']),
            'cross_tasks':len(protocol['cross_tasks']),'jar_sha256':runtime['jar_sha256']}


def execute(root):
    protocol=engine.read(root/'protocol.json');jar=Path(protocol['runtime_jar'])
    if digest(jar)!=protocol['runtime_jar_sha256']:raise ValueError('Changed runtime')
    engine.JAR=jar
    def corrected_replay(domain,problem,plan,output,seconds):
        return invoke(jar,domain,problem,output,mode='replay',seconds=seconds,classes=engine.CLASSES,plan=plan)
    engine.replay=corrected_replay
    report=engine.execute(root)
    invocations=list((root/'execution').rglob('invocation.json'))
    expected=str(jar.resolve());checks=[]
    for p in invocations:
        row=engine.read(p);checks.append({'path':str(p),'corrected_jar':row['input_sha256'].get(expected)==protocol['runtime_jar_sha256']})
    save(root/'runtime_receipt.json',{'status':'verified' if all(x['corrected_jar'] for x in checks) else 'failed',
        'runtime_variant':protocol['runtime_variant'],'invocations':len(checks),'checks':checks})
    return report


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('mode',choices=['prepare','execute']);p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();print(json.dumps(globals()[a.mode](a.output),indent=2))

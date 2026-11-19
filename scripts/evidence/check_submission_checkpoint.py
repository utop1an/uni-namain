"""Check current code/test receipts and evidence pointers without experiments.

A successful consistency audit is not an assessment of scientific readiness.
Table provenance is checked against its explicitly supplied historical snapshot.
"""
import argparse
import json
from pathlib import Path
import re

from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from scripts.evidence.build_paper_results import checked_report


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def code_fingerprint(root):
    paths=set(root.glob('*.py'))
    for name in ('rcnc','unidomain','scripts','tests','archive'):
        paths.update((root/name).rglob('*.py'))
    return {p.relative_to(root).as_posix():digest(p) for p in sorted(paths)}


def check_test_receipt(root, receipt):
    if receipt['status']!='passed' or any(receipt.get(k) is not True
            for k in ('all_tests_passed','code_unchanged_during_suite')):
        raise ValueError('Passing stable-code full test receipt required')
    if code_fingerprint(root)!=receipt['code_sha256']:
        raise ValueError('Current code differs from the full test checkpoint')
    log=root/receipt['log']
    if digest(log)!=receipt['log_sha256']:
        raise ValueError('Test log changed')
    counts=re.findall(r'Ran (\d+) tests in ([\d.]+)s',log.read_text(encoding='utf-8'))
    if (not counts or int(counts[-1][0])!=receipt['tests']
            or float(counts[-1][1])!=receipt['elapsed_seconds']):
        raise ValueError('Test count or duration differs from saved log')
    return {'tests':receipt['tests'],'elapsed_seconds':receipt['elapsed_seconds'],
            'code_files':len(receipt['code_sha256']),'log_sha256':receipt['log_sha256']}


def check_snapshot(index_path, snapshot_path):
    index,snapshot=read(index_path),read(snapshot_path)
    if snapshot['status']!='verified_snapshot' or snapshot['index_sha256']!=digest(index_path):
        raise ValueError('Snapshot does not match the selected index')
    if set(snapshot['results'])!=set(index['reports']):
        raise ValueError('Snapshot report denominator differs')
    for key,entry in index['reports'].items():
        report=checked_report(entry)
        wanted={'path':entry['path'],'sha256':entry['sha256'],'scope':entry['scope'],
                'metrics':{name:report[name] for name in entry['metrics']}}
        if snapshot['results'][key]!=wanted:
            raise ValueError('Snapshot metric or provenance differs: '+key)
    return {'verified_reports':len(index['reports']),'index_sha256':digest(index_path)}


def check_tables(manifest_path, snapshot_path):
    manifest=read(manifest_path)
    if (manifest['status']!='rendered_from_verified_snapshot'
            or manifest['snapshot_sha256']!=digest(snapshot_path)):
        raise ValueError('Table provenance differs from explicit historical snapshot')
    snapshot=read(snapshot_path)
    if snapshot['status']!='verified_snapshot':
        raise ValueError('Tables require a verified historical snapshot')
    for key,entry in manifest['sources'].items():
        if (digest(Path(entry['path']))!=entry['sha256']
                or snapshot['results'][key]['sha256']!=entry['sha256']):
            raise ValueError('Table source differs: '+key)
    if len(manifest['output_sha256'])!=manifest['table_count']:
        raise ValueError('Table denominator differs')
    for name,expected in manifest['output_sha256'].items():
        path=manifest_path.parent/name
        if not path.resolve().is_relative_to(manifest_path.parent.resolve()) or digest(path)!=expected:
            raise ValueError('Table output changed or escapes table folder')
    return {'table_count':manifest['table_count'],'historical_snapshot_sha256':digest(snapshot_path)}


def verify(index_path,snapshot_path,checkpoint_path,table_manifest,table_snapshot,output):
    require_empty_output(output);output.mkdir(parents=True)
    implementation=snapshot_implementation(output,[Path(__file__),Path('rcnc/domain_building.py'),
        Path('scripts/evidence/build_paper_results.py')])
    inputs=[index_path,snapshot_path,checkpoint_path,table_manifest,table_snapshot,
            Path('paper/claim_evidence.json'),Path('paper/submission_workplan.json')]
    pins={};copies={}
    (output/'inputs').mkdir()
    for index,path in enumerate(inputs):
        copy=output/'inputs'/f'{index:02d}_{path.name}'
        copy.write_bytes(path.read_bytes())
        pins[str(path)]=digest(copy)
        copies[str(path)]=copy.relative_to(output).as_posix()
    save(output/'manifest.json',{'status':'fixed_before_checkpoint_consistency_audit',
        'input_sha256':pins,'input_copies':copies,'implementation_sha256':implementation})
    checks={};failure=None
    try:
        checks['evidence']=check_snapshot(index_path,snapshot_path)
        checks['tests']=check_test_receipt(Path.cwd(),read(checkpoint_path))
        checks['tables']=check_tables(table_manifest,table_snapshot)
        for path in inputs[-2:]:
            current=read(path)['latest_verified_evidence_inventory']
            if (Path(current['index']).resolve()!=index_path.resolve()
                or Path(current['snapshot']).resolve()!=snapshot_path.resolve()
                or current['verified_reports']!=checks['evidence']['verified_reports']):
                raise ValueError('Current documentation points at a different evidence checkpoint: '+str(path))
        checks['current_document_pointers_match']=True
    except Exception as exc:
        failure=f'{type(exc).__name__}: {exc}'
    stable=all(digest(Path(p))==h for p,h in pins.items())
    code_stable=all(digest(Path(p))==h for p,h in implementation.items())
    result={'status':'verified_checkpoint_consistency' if failure is None and stable and code_stable else 'checkpoint_inconsistent',
        'checks':checks,'failure':failure,'inputs_unchanged':stable,
        'implementation_unchanged':code_stable,
        'model_calls':0,'planner_calls':0,'replay_calls':0,
        'scientific_submission_readiness':'not_assessed',
        'scope':'Current code/full-test receipt, selected evidence snapshot, current structured document pointers and explicitly historical table provenance only. No fresh experiments, independent semantic labels, proof/novelty review or readiness claim.'}
    save(output/'report.json',result)
    return result


def main(arguments=None):
    parser=argparse.ArgumentParser(description=__doc__)
    for flag in ('index','snapshot','test-checkpoint','table-manifest','table-snapshot','output'):
        parser.add_argument('--'+flag,type=Path,required=True)
    a=parser.parse_args(arguments)
    result=verify(a.index,a.snapshot,a.test_checkpoint,a.table_manifest,a.table_snapshot,a.output)
    print(json.dumps(result,indent=2))
    return 0 if result['status']=='verified_checkpoint_consistency' else 1


if __name__=='__main__':
    raise SystemExit(main())

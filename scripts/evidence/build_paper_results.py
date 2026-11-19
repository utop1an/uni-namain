"""Freeze a verified result inventory from explicitly selected completed reports."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path

from scripts.experiments.replay_source_probes import read, sha


def resolve_report_path(path):
    """Locate moved paper evidence without rewriting frozen index contents."""
    path = Path(path)
    if path.exists():
        return path
    root = Path(__file__).resolve().parents[2]
    try:
        relative = path.resolve().relative_to(root).as_posix()
    except ValueError:
        return path
    if relative.startswith('data/'):
        archive = root / 'archive/research-data-v1/data'
        candidate = (archive / relative.removeprefix('data/')).resolve()
        if candidate.is_relative_to(archive) and candidate.is_file():
            return candidate
    relocations = root / 'paper/records/relocation.json'
    if not relative.startswith('paper/') or not relocations.is_file():
        return path
    for original, relocated in read(relocations)['paths'].items():
        if relative == original or relative.startswith(original + '/'):
            target = (root / (relocated + relative[len(original):])).resolve()
            if not target.is_relative_to(root / 'paper'):
                raise ValueError('Relocated evidence escapes paper folder')
            return target
    return path


def checked_report(entry):
    path=resolve_report_path(entry['path'])
    if sha(path)!=entry['sha256']:
        raise ValueError('Pinned report changed: '+str(path))
    report=read(path)
    if report.get('status')!=entry['terminal_status']:
        raise ValueError('Report is not at its expected terminal state: '+str(path))
    for key in entry.get('required_true',[]):
        if report.get(key) is not True:
            raise ValueError('Integrity check not true: '+key)
    if entry.get('denominator'):
        if len(report['rows'])!=report[entry['denominator']]:
            raise ValueError('Incomplete row denominator')
        key=entry.get('row_id','id')
        if len({r[key] for r in report['rows']})!=len(report['rows']):
            raise ValueError('Duplicate result rows')
        if entry.get('count_field'):
            if dict(Counter(r['status'] for r in report['rows']))!=report[entry['count_field']]:
                raise ValueError('Summary count differs from individual rows')
    return report


def build(index_path,output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    index_path=resolve_report_path(index_path)
    index=read(index_path)
    results={}
    for role,entry in index['reports'].items():
        report=checked_report(entry)
        results[role]={'path':entry['path'],'sha256':entry['sha256'],
                      'scope':entry['scope'],'metrics':{key:report[key] for key in entry['metrics']}}
    result={'status':'verified_snapshot','created_utc':datetime.now(timezone.utc).isoformat(),
        'index_sha256':sha(index_path),'results':results,
        'excluded_pending':index['excluded_pending'],
        'scope':'Versioned development evidence inventory; no aggregate success rate across heterogeneous units',
        'implementation_sha256':sha(Path(__file__))}
    output.mkdir(parents=True)
    (output/'results.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    (output/'result_sources.json').write_bytes(index_path.read_bytes())
    (output/'build_paper_results.py').write_bytes(Path(__file__).read_bytes())
    return result


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--index',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args()
    result=build(a.index,a.output)
    print(json.dumps({'status':result['status'],'verified_reports':len(result['results']),
                      'excluded_pending':result['excluded_pending']},indent=2))

"""Replay new source plans through pre-existing fixed source-preserving models."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path

from scripts.experiments.run_union_regression import translate_plan
from rcnc.validation import validate_artifacts


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def run(inputs, source_run, compiled, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    previous = read(source_run/'report.json')
    manifest = read(source_run/'manifest.json')
    if previous['status'] != 'complete' or manifest['mode'] != 'original_source_tasks':
        raise ValueError('Requires a completed original-source reference run')
    if sha(source_run/'manifest.json') != previous['manifest_sha256']:
        raise ValueError('Source manifest changed')
    tasks = {task['id']: task for task in manifest['tasks']}
    if len(tasks) != manifest['task_count'] or len(previous['rows']) != len(tasks) or {row['id'] for row in previous['rows']} != set(tasks):
        raise ValueError('Source result denominator mismatch')
    meta = read(compiled/'meta_domain.json')
    if set(meta['sources']) != set(tasks):
        raise ValueError('Compiled source coverage differs from reference')
    output.mkdir(parents=True)
    frozen = sha(compiled/'meta_domain.pddl')
    report = {'status': 'running', 'source_count': len(tasks), 'compiled_domain_sha256': frozen,
              'source_report_sha256': sha(source_run/'report.json'), 'compiled': str(compiled),
              'scope': 'Source-local plan replay conditional on available valid plans; no semantic/narrative inference', 'rows': []}
    for old in previous['rows']:
        source = old['id']
        row = {'source': source, 'source_search_status': old['status']}
        original = source_run/'tasks'/source
        try:
            for kind in ('domain', 'problem'):
                name = source+'_'+kind+'file.pddl'
                if sha(original/(kind+'.pddl')) != tasks[source][kind+'_sha256']:
                    raise ValueError('Recorded source input hash changed')
                if (inputs/name).read_bytes() != (original/(kind+'.pddl')).read_bytes():
                    raise ValueError('Current source differs from searched source')
                recorded = meta.get('source_sha256', {}).get(name)
                if recorded is not None and sha(inputs/name) != recorded:
                    raise ValueError('Compiled model was built from a different source')
            if old['status'] == 'solved' and old.get('validation', {}).get('status') == 'VALID':
                row['source_revalidation'] = validate_artifacts(original)
                if row['source_revalidation']['status'] != 'VALID':
                    raise ValueError('Saved source plan fails fresh validation')
                row['mapped'] = translate_plan(source, inputs, compiled, original, output/'replays'/source)
                row['status'] = row['mapped']['validation']['status']
            else:
                row['status'] = 'no_source_plan_evidence'
        except Exception as exc:
            row.update(status='ERROR', error=f'{type(exc).__name__}: {exc}')
        report['rows'].append(row)
        (output/'report.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
        print(json.dumps(row), flush=True)
    report.update(status='complete', compiled_domain_unchanged=sha(compiled/'meta_domain.pddl') == frozen,
                  source_plan_count=sum(row['source_search_status'] == 'solved' for row in report['rows']),
                  valid_translations=sum(row['status'] == 'VALID' for row in report['rows']),
                  counts=dict(Counter(row['status'] for row in report['rows'])),
                  implementation_sha256={p.name: sha(p) for p in [Path(__file__), (Path(__file__).resolve().parents[2] / 'scripts/experiments/run_union_regression.py')]})
    (output/'report.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inputs', type=Path, default=Path('data/narra-domains'))
    parser.add_argument('--source-run', type=Path, required=True)
    parser.add_argument('--compiled', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = run(args.inputs, args.source_run, args.compiled, args.output)
    raise SystemExit(0 if result['compiled_domain_unchanged'] and result['valid_translations'] == result['source_plan_count'] and not result['counts'].get('ERROR') else 1)

"""Replay available source plans after type-membership compilation (no merges)."""
import argparse
import hashlib
import json
from pathlib import Path

from rcnc.aligned_domain import build
from scripts.experiments.run_union_regression import translate_plan


def run(inputs, source_run, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    previous = json.loads((source_run / 'report.json').read_text(encoding='utf-8'))
    if previous['status'] != 'complete':
        raise ValueError('Source regression must be complete')
    spec = {'version': 1, 'decision_basis': 'authored_assumption',
            'source_sha256': {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs.glob('*_domainfile.pddl')},
            'type_groups': [], 'predicate_groups': []}
    build(inputs, output / 'compiled', spec)
    original_hash = hashlib.sha256((output / 'compiled/meta_domain.pddl').read_bytes()).hexdigest()
    report = {'status': 'running', 'scope': 'Type encoding regression with zero semantic merges; available source-plan denominator retained',
              'source_report_sha256': hashlib.sha256((source_run / 'report.json').read_bytes()).hexdigest(),
              'compiled_before_replay': True, 'rows': []}
    for row in previous['rows']:
        source = row['source']
        current = {'source': source, 'source_search_status': row['search']['status']}
        if row['search']['status'] == 'solved' and row['search'].get('validation', {}).get('status') == 'VALID':
            original = source_run / 'sources' / source / 'original'
            for filename, input_name in [('domain.pddl', f'{source}_domainfile.pddl'),
                                          ('problem.pddl', f'{source}_problemfile.pddl')]:
                if (original / filename).read_bytes() != (inputs / input_name).read_bytes():
                    raise ValueError(f'Source files changed since the recorded plan: {source}')
            current['mapped'] = translate_plan(source, inputs, output / 'compiled', original, output / 'replays' / source)
            current['status'] = current['mapped']['validation']['status']
        else:
            current['status'] = 'no_source_plan_evidence'
        report['rows'].append(current)
        (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
        print(json.dumps(current), flush=True)
    report['status'] = 'complete'
    report['compiled_domain_unchanged'] = original_hash == hashlib.sha256((output / 'compiled/meta_domain.pddl').read_bytes()).hexdigest()
    report['validated_count'] = sum(row['status'] == 'VALID' for row in report['rows'])
    report['source_plan_count'] = sum('mapped' in row for row in report['rows'])
    report['source_count'] = len(report['rows'])
    (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    return report


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--input', type=Path, default=Path('data/narra-domains'))
    p.add_argument('--source-run', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    result = run(a.input, a.source_run, a.output)
    raise SystemExit(0 if result['compiled_domain_unchanged'] and result['validated_count'] == result['source_plan_count'] else 1)

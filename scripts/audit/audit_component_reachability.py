"""Verify exhaustive valuation coverage and recompute finite-control summaries."""
import argparse
from collections import Counter
import itertools
import json
from pathlib import Path

from rcnc.domain_building import require_empty_output, save, archived_implementation
from scripts.experiments.run_downward_reference import sha


def audit(root, output):
    require_empty_output(output)
    manifest = json.loads((root / 'manifest.json').read_text(encoding='utf-8'))
    report = json.loads((root / 'report.json').read_text(encoding='utf-8'))
    if report['status'] != 'complete' or report['manifest_sha256'] != sha(root / 'manifest.json'):
        raise ValueError('Incomplete or changed finite experiment')
    for path, digest in manifest['input_sha256'].items():
        if sha(root / path) != digest:
            raise ValueError('Frozen input drift: ' + path)
    for path, digest in manifest['implementation_sha256'].items():
        if sha(archived_implementation(root, path)) != digest:
            raise ValueError('Frozen implementation drift: ' + path)
    cases = {case['id']: case for case in manifest['cases']}
    if len(cases) != 6 or len(manifest['cases']) != 6 or manifest['case_count'] != 6:
        raise ValueError('Expected six finite cases')
    expected = {(case['id'], index): list(bits) for case in cases.values()
        for index, bits in enumerate(itertools.product((False, True), repeat=len(case['dynamic_atoms'])))}
    rows = {(row['case'], row['valuation']): row for row in report['rows']}
    if (len(rows) != len(report['rows']) or set(rows) != set(expected)
            or len(rows) != manifest['valuation_count'] or report['valuation_count'] != len(rows)):
        raise ValueError('Incomplete or duplicate valuation denominator')
    verified, mutations = [], Counter()
    for key, row in rows.items():
        if row['bits'] != expected[key] or any(type(bit) is not bool for bit in row['bits']):
            raise ValueError('Valuation differs from exhaustive order')
        outcomes = [row[k]['status'] for k in ('full', 'selected', 'mutant')]
        definite = all(status in ('reachable', 'unreachable') for status in outcomes)
        mismatch = definite and outcomes[0] != outcomes[1]
        mutation = definite and outcomes[0] != outcomes[2]
        if (row['definite'], row['selection_mismatch'], row['mutation_detected']) != (definite, mismatch, mutation):
            raise ValueError('Per-valuation summary differs from recorded outcomes')
        if mutation:
            mutations[key[0]] += 1
        status = 'inconclusive' if not definite else 'selection_mismatch' if mismatch else 'equivalent_reachability'
        verified.append({**row, 'id': key[0] + ':' + str(key[1]), 'status': status})
    counts = dict(Counter(row['status'] for row in verified))
    if counts != {'equivalent_reachability': len(rows)}:
        raise ValueError('Finite equivalence check did not pass completely')
    if any(mutations[case['id']] == 0 for case in cases.values() if case['mutant_must_be_detected']):
        raise ValueError('Expected incorrect-policy control was not detected')
    if (report['selection_mismatches'] != 0 or report['inconclusive'] != 0
            or report['mutation_mismatches_by_case'] != dict(mutations)
            or report['expected_mutations_detected'] is not True):
        raise ValueError('Aggregate finite-control summary drift')
    result = {'status': 'verified_finite_control', 'task_count': len(rows), 'case_count': len(cases),
        'searches': 3 * len(rows), 'counts': counts, 'selection_mismatches': 0,
        'mutation_mismatches_by_case': dict(mutations), 'expected_mutations_detected': True,
        'hashes_unchanged': True, 'rows': verified, 'scope': manifest['scope'],
        'manifest_sha256': sha(root / 'manifest.json'), 'report_sha256': sha(root / 'report.json'),
        'auditor_sha256': sha(Path(__file__))}
    output.mkdir(parents=True)
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    report = audit(args.root, args.output)
    print(json.dumps({k: v for k, v in report.items() if k != 'rows'}, indent=2))

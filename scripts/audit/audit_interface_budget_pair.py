"""Audit frozen requests, complete candidate slots and live/replay provenance."""
import argparse
from collections import Counter
import json
from pathlib import Path

from rcnc.domain_building import archived_implementation, require_empty_output, save, snapshot_implementation
from rcnc.interface_annotation import digest
from scripts.annotation.compare_annotation_predictions import compare
from scripts.experiments.run_downward_reference import sha


def audit(root, output):
    require_empty_output(output)
    read = lambda path: json.loads(path.read_text(encoding='utf-8'))
    manifest, protocol, report = (read(root / name) for name in ('manifest.json', 'protocol.json', 'report.json'))
    if report['status'] != 'complete' or report['condition_count'] != 2 or report['manifest_sha256'] != sha(root / 'manifest.json'):
        raise ValueError('Complete fixed pair required')
    if any(report.get(key) is not True for key in ('inputs_unchanged', 'implementation_unchanged')):
        raise ValueError('Execution integrity failure')
    for path, expected in manifest['input_sha256'].items():
        if sha(root / path) != expected:
            raise ValueError('Frozen input drift')
    for path, expected in manifest['implementation_sha256'].items():
        if sha(archived_implementation(root, path)) != expected:
            raise ValueError('Archived implementation mismatch')
    packet = read(root / 'packet.json')
    if digest(packet) != protocol['packet_sha256']:
        raise ValueError('Packet drift')
    condition_rows = {row['id']: row for row in report['rows']}
    if len(report['rows']) != 2 or set(condition_rows) != set(protocol['conditions']):
        raise ValueError('Missing or duplicate conditions')
    rows = []
    for policy in protocol['conditions']:
        directory = root / 'conditions' / policy
        actual_manifest, actual_report = read(directory / 'manifest.json'), read(directory / 'report.json')
        summary = condition_rows[policy]
        if sha(directory / 'manifest.json') != summary['manifest_sha256'] or sha(directory / 'report.json') != summary['report_sha256']:
            raise ValueError('Condition report drift')
        if actual_manifest['execution_kind'] != 'local_model' or actual_report['replay'] is not False:
            raise ValueError('Expected new local-model condition, not replay')
        if actual_manifest.get('model_digest') != protocol['model_digest'] or actual_manifest['options'] != protocol['options'] or actual_manifest['total_budget_seconds'] != protocol['budget']['total_seconds_per_condition']:
            raise ValueError('Local protocol mismatch')
        if summary['protocol_matched'] is not True or summary['attempted_requests_match_freeze'] is not True:
            raise ValueError('Frozen request mismatch reported')
        indexed = {row['candidate_id']: row for row in actual_report['rows']}
        if len(indexed) != len(actual_report['rows']) or set(indexed) != {item['id'] for item in packet['items']}:
            raise ValueError('Incomplete or duplicate100-slot denominator')
        if actual_report['processed'] != 100 or actual_report['total'] != 100 or actual_report['counts'] != dict(Counter(row['status'] for row in indexed.values())):
            raise ValueError('Condition counts differ from rows')
        attempted = sum(row['request_attempted'] is True for row in indexed.values())
        if attempted != actual_report['requests_attempted']:
            raise ValueError('Request attempt count mismatch')
        for candidate_id, row in indexed.items():
            if read(directory / candidate_id / 'report.json') != row:
                raise ValueError('Candidate report differs from aggregate')
            if row['request_attempted'] and read(directory / candidate_id / 'request.json') != read(root / 'frozen_requests' / policy / (candidate_id + '.json')):
                raise ValueError('Actual request differs from pre-live freeze')
        rows.append({'id': policy, 'status': actual_report['status'], 'counts': actual_report['counts'],
            'total': 100, 'requests_attempted': attempted, 'budget_exhausted': actual_report['budget_exhausted_count'],
            'elapsed_seconds': actual_report['elapsed_seconds'], 'all_candidates_requested': actual_report['all_candidates_requested']})
    output.mkdir(parents=True)
    comparison = compare(root / 'conditions/free_fields', root / 'conditions/coupled_fields', output / 'fresh_comparison.json')
    original_comparison = read(root / 'comparison.json')
    ignored = {'implementation_sha256'}
    if {k: v for k, v in comparison.items() if k not in ignored} != {k: v for k, v in original_comparison.items() if k not in ignored}:
        raise ValueError('Comparison is not reproducible')
    implementation = snapshot_implementation(output, [Path(__file__), Path('scripts/annotation/compare_annotation_predictions.py'),
        Path('scripts/annotation/run_annotation_predictions.py'), Path('rcnc/interface_annotation.py'), Path('rcnc/domain_building.py')])
    result = {'status': 'verified_live_budget_pair', 'condition_count': 2, 'candidate_slots': 200, 'rows': rows,
        'comparison_status': comparison['status'], 'matched_attempted_candidates': comparison['matched_attempted_candidates'],
        'unmatched_or_unrequested_candidates': comparison['request_comparison_unavailable'],
        'strict_schema_compliant': comparison['strict_schema_compliant'],
        'hashes_unchanged': True, 'independent_semantic_labels': 0,
        'report_sha256': sha(root / 'report.json'), 'manifest_sha256': sha(root / 'manifest.json'),
        'implementation_sha256': implementation, 'scope': protocol['scope']}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = audit(args.root, args.output)
    print(json.dumps({k: v for k, v in result.items() if k != 'implementation_sha256'}, indent=2))

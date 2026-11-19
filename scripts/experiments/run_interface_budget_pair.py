"""Freeze both schema conditions before a bounded local prediction pair."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path

from rcnc.domain_building import require_empty_output, save, snapshot_implementation
from rcnc.interface_annotation import digest
from scripts.annotation.compare_annotation_predictions import compare
from scripts.annotation.run_annotation_predictions import PROMPT, request_json, response_schema, run
from scripts.experiments.run_downward_reference import sha


def prepare(protocol_path, output):
    require_empty_output(output)
    protocol = json.loads(protocol_path.read_text(encoding='utf-8'))
    packet_path = Path(protocol['packet'])
    packet = json.loads(packet_path.read_text(encoding='utf-8'))
    if sha(packet_path) != protocol['packet_file_sha256'] or digest(packet) != protocol['packet_sha256']:
        raise ValueError('Packet drift')
    if len(packet['items']) != protocol['budget']['max_candidates_per_condition'] or len({item['id'] for item in packet['items']}) != len(packet['items']):
        raise ValueError('Incomplete or duplicate candidate registry')
    if protocol['conditions'] != ['free_fields', 'coupled_fields'] or protocol['budget']['workers'] != 1:
        raise ValueError('Expected the fixed sequential schema pair')
    output.mkdir(parents=True)
    (output / 'protocol.json').write_bytes(protocol_path.read_bytes())
    (output / 'packet.json').write_bytes(packet_path.read_bytes())
    for policy in protocol['conditions']:
        (output / 'frozen_requests' / policy).mkdir(parents=True)
        for item in packet['items']:
            payload = {'model': protocol['model'], 'stream': False, 'format': response_schema(item, policy),
                'options': protocol['options'], 'messages': [{'role': 'system', 'content': PROMPT},
                    {'role': 'user', 'content': json.dumps(item, ensure_ascii=False)}]}
            save(output / 'frozen_requests' / policy / (item['id'] + '.json'), payload)
    implementation = snapshot_implementation(output, [Path(__file__), Path('scripts/annotation/run_annotation_predictions.py'),
        Path('scripts/annotation/compare_annotation_predictions.py'), Path('rcnc/interface_annotation.py'),
        Path('rcnc/domain_building.py')])
    files = [p for p in output.rglob('*') if p.is_file() and 'implementation' not in p.relative_to(output).parts]
    manifest = {'status': 'frozen_before_live_requests', 'conditions': protocol['conditions'],
        'candidates_each': len(packet['items']), 'condition_count': 2, 'budget': protocol['budget'],
        'input_sha256': {p.relative_to(output).as_posix(): sha(p) for p in files},
        'implementation_sha256': implementation, 'scope': protocol['scope']}
    save(output / 'manifest.json', manifest)
    return manifest


def check_admission(protocol, reference_manifest, reference_report, now):
    if any(reference_manifest.get(key) != value for key, value in protocol['reference_identity'].items()):
        raise ValueError('Reference identity differs from the frozen predecessor')
    if reference_manifest.get('status') == 'running' or reference_report.get('status') not in (
            'complete', 'time_limit', 'worker_error', 'error', 'missing_or_invalid_final_validation'):
        raise ValueError('Fusion reference is not authoritatively terminal')
    if reference_manifest.get('status') != reference_report['status'] or reference_manifest.get('finished_utc') != reference_report.get('finished_utc'):
        raise ValueError('Reference terminal records disagree')
    if reference_report.get('implementation_unchanged') is not True or reference_report.get('source_snapshot_unchanged') is not True:
        raise ValueError('Reference integrity failure requires diagnosis first')
    finished = datetime.fromisoformat(reference_report['finished_utc'].replace('Z', '+00:00'))
    if (now - finished).total_seconds() < protocol['admission_quiet_seconds']:
        raise ValueError('Reference quiet interval has not elapsed')
    deadline = datetime.fromisoformat(protocol['budget']['whole_goal_stop_before_utc'].replace('Z', '+00:00'))
    if (deadline - now).total_seconds() < 2 * protocol['budget']['total_seconds_per_condition'] + 600:
        raise ValueError('Insufficient overall time for both conditions and cleanup')


def execute(output):
    read = lambda path: json.loads(path.read_text(encoding='utf-8'))
    manifest, protocol = read(output / 'manifest.json'), read(output / 'protocol.json')
    if (output / 'conditions').exists() or (output / 'report.json').exists():
        raise ValueError('No rerun or silent continuation')
    if not all(sha(output / p) == value for p, value in manifest['input_sha256'].items()):
        raise ValueError('Frozen input drift')
    if not all(sha(Path(p)) == value for p, value in manifest['implementation_sha256'].items()):
        raise ValueError('Frozen implementation drift')
    reference = Path(protocol['reference'])
    predecessor_manifest, predecessor_report = read(reference / 'manifest.json'), read(reference / 'report.json')
    check_admission(protocol, predecessor_manifest, predecessor_report, datetime.now(timezone.utc))
    tags = request_json('http://127.0.0.1:11434/api/tags', timeout=10)
    model = next((row for row in tags.get('models', []) if row['name'] == protocol['model']), None)
    if model is None or model.get('digest') != protocol['model_digest'] or model.get('remote_host') or model.get('remote_model'):
        raise ValueError('Existing local model identity mismatch')
    save(output / 'admission.json', {'reference_report_sha256': sha(reference / 'report.json'),
        'reference_manifest_sha256': sha(reference / 'manifest.json'), 'observed_utc': datetime.now(timezone.utc).isoformat(),
        'model_digest': model['digest'], 'condition_order': protocol['conditions'],
        'scope': 'Caller also verifies the reference process handle is terminal. Quiet interval does not prove absence of unrelated external model users.'})
    rows = []
    for policy in protocol['conditions']:
        directory = output / 'conditions' / policy
        result = run(output / 'packet.json', directory, protocol['model'], schema_policy=policy,
            total_seconds=protocol['budget']['total_seconds_per_condition'])
        actual_manifest = read(directory / 'manifest.json')
        pinned_fields = {'options': protocol['options'], 'request_timeout_seconds': protocol['budget']['request_timeout_seconds'],
            'total_budget_seconds': protocol['budget']['total_seconds_per_condition'], 'model_digest': protocol['model_digest']}
        matched = all(actual_manifest.get(key) == value for key, value in pinned_fields.items())
        request_checks = []
        for row in result['rows']:
            if row.get('request_attempted'):
                request_checks.append(read(directory / row['candidate_id'] / 'request.json') ==
                    read(output / 'frozen_requests' / policy / (row['candidate_id'] + '.json')))
        rows.append({'id': policy, 'status': result['status'], 'counts': result.get('counts'),
            'processed': result['processed'], 'total': result['total'], 'requests_attempted': result['requests_attempted'],
            'protocol_matched': matched, 'attempted_requests_match_freeze': all(request_checks),
            'report_sha256': sha(directory / 'report.json'), 'manifest_sha256': sha(directory / 'manifest.json')})
        save(output / 'progress.json', {'status': 'running', 'rows': rows, 'condition_count': 2})
    comparison = None
    if all(row['status'] == 'complete' and row['protocol_matched'] and row['attempted_requests_match_freeze'] for row in rows):
        comparison = compare(output / 'conditions/free_fields', output / 'conditions/coupled_fields', output / 'comparison.json')
    report = {'status': 'complete', 'condition_count': 2, 'rows': rows,
        'status_counts': dict(Counter(row['status'] for row in rows)), 'manifest_sha256': sha(output / 'manifest.json'),
        'comparison_status': comparison['status'] if comparison else 'unavailable',
        'inputs_unchanged': all(sha(output / p) == value for p, value in manifest['input_sha256'].items()),
        'implementation_unchanged': all(sha(Path(p)) == value for p, value in manifest['implementation_sha256'].items()),
        'scope': manifest['scope'], 'independent_semantic_labels': 0}
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--protocol', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--prepare-only', action='store_true')
    parser.add_argument('--execute-frozen', action='store_true')
    args = parser.parse_args()
    if args.prepare_only and args.execute_frozen:
        parser.error('Choose preparation or execution')
    result = None if args.execute_frozen else prepare(args.protocol, args.output)
    if not args.prepare_only:
        result = execute(args.output)
    print(json.dumps({k: v for k, v in result.items() if k not in ('rows', 'input_sha256', 'implementation_sha256')}, indent=2))

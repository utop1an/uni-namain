"""Freeze and audit a complete machine prediction run without approving merges."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path

from rcnc.interface_annotation import digest, save
from rcnc.interface_graph import audit_graph
from run_annotation_predictions import check_response


def audit(packet, predictions):
    items = {item['id']: item for item in packet['items']}
    rows = predictions['rows']
    if (predictions.get('status') != 'complete'
            or predictions.get('packet_sha256') != digest(packet)
            or predictions.get('total') != len(items)
            or predictions.get('processed') != len(items)
            or len(items) != len(packet['items'])
            or len(rows) != len(items)
            or {r['candidate_id'] for r in rows} != set(items)):
        raise ValueError('Complete, unique, hash-matched packet coverage required')
    if dict(Counter(r['status'] for r in rows)) != predictions.get('counts'):
        raise ValueError('Prediction count mismatch')
    edges, exclusions, skipped = [], [], []
    for row in rows:
        key = row['candidate_id']
        if row['status'] != 'checked':
            skipped.append({'candidate_id': key, 'reason': row['status']})
            continue
        response, item = row['response'], items[key]
        errors = check_response(packet, item, response)
        if errors:
            raise ValueError(f'Claimed checked response failed revalidation: {key}: {errors}')
        left, right = [f"{s['source']}:{s['predicate']}" for s in item['sides']]
        edge = {'id': key, 'left': left, 'right': right, 'label': response['label']}
        if response['label'] in ('equivalent', 'permuted_equivalent'):
            edges.append({**edge, 'right_from_left': response['right_from_left']})
        elif response['label'] != 'uncertain':
            exclusions.append(edge)
        else:
            skipped.append({'candidate_id': key, 'reason': 'uncertain'})
    return {'status': 'complete', 'packet_sha256': digest(packet),
            'total_candidates': len(items), 'prediction_status_counts': predictions['counts'],
            'definite_non_equivalence_edges': len(exclusions), 'skipped': skipped,
            **audit_graph(edges, exclusions)}


def run(packet_path, prediction_path, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    packet_bytes, prediction_bytes = packet_path.read_bytes(), prediction_path.read_bytes()
    result = audit(json.loads(packet_bytes), json.loads(prediction_bytes))
    output.mkdir(parents=True, exist_ok=True)
    (output/'packet.json').write_bytes(packet_bytes)
    (output/'predictions.json').write_bytes(prediction_bytes)
    implementation = output/'implementation'
    implementation.mkdir()
    hashes = {}
    for path in (Path(__file__), Path('rcnc/interface_graph.py'),
                 Path('rcnc/interface_annotation.py'), Path('run_annotation_predictions.py')):
        data = path.read_bytes()
        hashes[str(path)] = hashlib.sha256(data).hexdigest()
        (implementation/path.name).write_bytes(data)
    result['implementation_sha256'] = hashes
    result['prediction_file_sha256'] = hashlib.sha256(prediction_bytes).hexdigest()
    save(output/'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--packet', required=True, type=Path)
    parser.add_argument('--predictions', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    print(json.dumps(run(args.packet, args.predictions, args.output), indent=2))

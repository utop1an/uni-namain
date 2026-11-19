"""Check blind delivery bytes and score only actually supplied independent labels."""
import argparse
from collections import Counter
import json
from pathlib import Path
import zipfile

from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.interface_annotation import digest as json_digest
from rcnc.interface_evaluation import evaluate
from rcnc.prospective_evaluation import audit_task_registry
from scripts.annotation.run_annotation_predictions import check_response


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def audit(bundle, output, task_file=None, annotations=()):
    require_empty_output(output)
    output.mkdir(parents=True)
    report = read(bundle / 'report.json')
    for item in [*report['annotator_bundles'], report['task_author_bundle']]:
        if digest(Path(item['path'])) != item['sha256']:
            raise ValueError('Delivery bundle changed')
    template = read(bundle / 'task_author/tasks_template.json')
    # Bind the loose intake template and source files to the frozen delivery archive.
    with zipfile.ZipFile(report['task_author_bundle']['path']) as archive:
        for name in archive.namelist():
            if archive.read(name) != (bundle / 'task_author' / name).read_bytes():
                raise ValueError('Loose author packet drift')
    for item in report['annotator_bundles']:
        with zipfile.ZipFile(item['path']) as archive:
            if set(archive.namelist()) != {'index.html', 'INSTRUCTIONS.txt', 'annotation_template.json'}:
                raise ValueError('Unexpected blind packet member')
            for name in archive.namelist():
                if archive.read(name) != (bundle / 'annotators' / name).read_bytes():
                    raise ValueError('Loose annotator packet drift')
            blank = json.loads(archive.read('annotation_template.json'))
            if (blank['annotator_id'] or blank['independent_of_model_and_solver_outcomes'] is not None
                    or any(r['status'] != 'unreviewed' or r['label'] is not None for r in blank['rows'])):
                raise ValueError('Pre-filled human judgments in delivery')
    tasks = read(task_file) if task_file else template
    if [(t['id'], t['sources'], t['source_availability']) for t in tasks['tasks']] != [
            (t['id'], t['sources'], t['source_availability']) for t in template['tasks']]:
        raise ValueError('Submitted tasks changed registered identities or source availability')
    save(output / 'received_tasks.json', tasks)
    intake = audit_task_registry(tasks, template['tasks'][0]['source_sha256'])
    save(output / 'task_intake.json', intake)
    received = []
    for i, path in enumerate(annotations):
        (output / ('received_annotations_' + str(i) + '.json')).write_bytes(path.read_bytes())
        received.append(read(path))
    rows = []
    for entry in report['rows']:
        folder = bundle / 'coordinator' / entry['cohort']
        packet = read(folder / 'packet.json')
        condition = entry['condition']
        predictions = read(folder / (condition + '_predictions.json'))
        pins = read(folder / (condition + '_manifest.json'))
        if (json_digest(packet) != entry['packet_sha256'] or pins['packet_sha256'] != json_digest(packet)
                or digest(folder / (condition + '_predictions.json')) != pins['prediction_sha256']
                or predictions['total'] != len(packet['items'])
                or len(predictions['rows']) != len(packet['items'])
                or len({r['candidate_id'] for r in predictions['rows']}) != len(packet['items'])
                or {r['candidate_id'] for r in predictions['rows']} != {i['id'] for i in packet['items']}):
            raise ValueError('Prediction or packet integrity failure')
        indexed = {r['candidate_id']: r for r in predictions['rows']}
        for item in packet['items']:
            if check_response(packet, item, indexed[item['id']]['response']):
                raise ValueError('Offline baseline fails response contract')
        matching = [a for a in received if a.get('packet_sha256') == json_digest(packet)]
        score = evaluate(packet, matching, predictions, json_digest(packet))
        save(output / (entry['cohort'] + '_' + condition + '_score.json'), score)
        rows.append({'id': entry['id'], 'status': score['status'], 'candidate_count': len(packet['items']),
            'annotations_received': len(matching), 'metrics': score.get('metrics'),
            'source_pair_counts': dict(Counter('/'.join(sorted(s['source'] for s in i['sides'])) for i in packet['items']))})
    result = {'status': 'verified_delivery_and_gates', 'row_count': len(rows), 'rows': rows,
        'prediction_rows_checked': sum(r['candidate_count'] for r in rows),
        'annotation_files_received': len(received),
        'cross_source_tasks': intake['task_count'],
        'tasks_ready_for_mapping_review': intake['ready_for_semantic_and_mapping_review'],
        'tasks_blocked_by_source': sum('source_not_available' in r['missing'] for r in intake['rows']),
        'planner_calls': 0, 'new_model_calls': 0, 'semantic_metrics_available': any(r['metrics'] for r in rows),
        'bundle_report_sha256': digest(bundle / 'report.json'), 'independence_verified': False,
        'scope': 'Delivery integrity, input contracts, and missing-human gates only; actual human independence and semantic truth are not certified.'}
    result['implementation_sha256'] = snapshot_implementation(output, [Path(__file__),
        Path('rcnc/prospective_evaluation.py'), Path('rcnc/interface_evaluation.py'),
        Path('rcnc/interface_annotation.py'), Path('rcnc/annotation_agreement.py')])
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--bundle', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--tasks', type=Path)
    p.add_argument('--annotations', type=Path, nargs='*', default=[])
    a = p.parse_args()
    result = audit(a.bundle, a.output, a.tasks, a.annotations)
    print(json.dumps({k: result[k] for k in ('status', 'prediction_rows_checked', 'annotation_files_received', 'tasks_ready_for_mapping_review', 'tasks_blocked_by_source', 'semantic_metrics_available')}))

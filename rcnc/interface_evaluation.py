"""Offline comparison with two declared-independent judgments, not semantic certification."""
from collections import Counter

from rcnc.annotation_agreement import agreement
from rcnc.interface_annotation import LABELS, digest
from scripts.annotation.run_annotation_predictions import check_response


MERGE = {'equivalent', 'permuted_equivalent'}


def evaluate(packet, annotations, predictions, prediction_packet_sha256):
    if prediction_packet_sha256 != digest(packet):
        raise ValueError('Prediction packet hash mismatch')
    items = {item['id']: item for item in packet['items']}
    if len(items) != len(packet['items']):
        raise ValueError('Duplicate packet candidate')
    assessment = agreement(packet, annotations)
    result = {'packet_sha256': digest(packet), 'candidate_count': len(items),
              'agreement': assessment,
              'scope': 'Sample-descriptive comparison with exact two-rater consensus; '
                       'declared independence is not verified and agreement is not truth. '
                       'No population prevalence or held-out generalization estimate.'}
    if assessment['status'] not in ('agreement_computed', 'no_paired_completed_judgments'):
        return dict(result, status='needs_valid_independent_annotations')
    rows = predictions.get('rows', [])
    indexed = {r['candidate_id']: r for r in rows}
    if (predictions.get('status') != 'complete' or predictions.get('total') != len(items)
            or len(indexed) != len(rows) or set(indexed) != set(items)):
        raise ValueError('Complete unique prediction denominator required')
    raters = [{r['candidate_id']: r for r in a['rows'] if r['status'] == 'completed'}
              for a in annotations]
    counts = Counter()
    matrix = {label: {p: 0 for p in (*LABELS, 'unavailable')} for label in LABELS}
    details = []
    for key, item in items.items():
        left, right = (r.get(key) for r in raters)
        reference = None
        if left is None or right is None:
            reference_status = 'missing'
        elif (left['label'], left['right_from_left']) != (right['label'], right['right_from_left']):
            reference_status = 'disagreement'
        elif left['label'] == 'uncertain':
            reference_status = 'uncertain'
        else:
            reference_status, reference = 'consensus', left
        counts['reference_' + reference_status] += 1
        prediction = indexed[key]
        checked = prediction['status'] == 'checked'
        if checked and check_response(packet, item, prediction.get('response', {})):
            raise ValueError('Claimed checked response fails offline validation: ' + key)
        counts['prediction_' + prediction['status']] += 1
        response = prediction.get('response', {}) if checked else {}
        label = response.get('label', 'unavailable')
        details.append({'candidate_id': key, 'reference_status': reference_status,
                        'prediction_status': prediction['status'], 'prediction_label': label})
        if reference is None:
            continue
        gold = reference['label']
        matrix[gold][label] += 1
        counts['scored'] += 1
        counts['label_correct'] += label == gold
        proposed, positive = label in MERGE, gold in MERGE
        exact = proposed and positive and response['right_from_left'] == reference['right_from_left']
        counts['merge_proposed'] += proposed
        counts['merge_positive'] += positive
        counts['merge_true_positive'] += proposed and positive
        counts['merge_exact_true_positive'] += exact
        counts['merge_false_positive'] += proposed and not positive
        counts['merge_false_negative'] += positive and not proposed
        counts['permutation_compared'] += proposed and positive
        counts['permutation_correct'] += exact
    def ratio(numerator, denominator):
        return counts[numerator] / counts[denominator] if counts[denominator] else None
    result.update(status='scored' if counts['scored'] else 'no_definite_consensus',
        counts=dict(counts), confusion_matrix=matrix, rows=details,
        metrics={'label_accuracy': ratio('label_correct', 'scored'),
                 'merge_precision': ratio('merge_true_positive', 'merge_proposed'),
                 'merge_recall': ratio('merge_true_positive', 'merge_positive'),
                 'exact_merge_precision': ratio('merge_exact_true_positive', 'merge_proposed'),
                 'exact_merge_recall': ratio('merge_exact_true_positive', 'merge_positive'),
                 'permutation_accuracy': ratio('permutation_correct', 'permutation_compared')},
        metric_policy='Only definite exact consensus is scored; unavailable outputs and uncertain '
                      'predictions remain in that denominator. Merge metrics concern this sampled '
                      'candidate set, not candidate-generation recall. Zero denominators are null.')
    return result

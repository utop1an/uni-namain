"""Descriptive two-annotator agreement; agreement does not create semantic gold."""
from rcnc.interface_annotation import LABELS, digest, validate_annotations


def agreement(packet, annotations):
    result = {'packet_sha256': digest(packet), 'candidate_count': len(packet['items']),
              'annotation_files': len(annotations), 'paired_completed': 0,
              'raw_agreement': None, 'cohen_kappa': None,
              'limit': 'Declared independence is not verified; agreement is not semantic truth. Uncertain remains a label; missing judgments are not disagreements.'}
    if len(annotations) != 2:
        result.update(status='needs_two_annotation_files')
        return result
    checks = [validate_annotations(packet, a) for a in annotations]
    result['validation'] = checks
    if not all(c['valid'] for c in checks):
        result.update(status='invalid_annotations')
        return result
    if annotations[0]['annotator_id'].strip() == annotations[1]['annotator_id'].strip():
        result.update(status='distinct_annotator_ids_required')
        return result
    rows = [{r['candidate_id']: r for r in a['rows'] if r['status'] == 'completed'} for a in annotations]
    keys = sorted(set(rows[0]) & set(rows[1]))
    matrix = {a: {b: 0 for b in LABELS} for a in LABELS}
    disagreements = []
    maps_equal = maps_total = 0
    for key in keys:
        left, right = rows[0][key], rows[1][key]
        matrix[left['label']][right['label']] += 1
        if left['label'] != right['label'] or left['right_from_left'] != right['right_from_left']:
            disagreements.append(key)
        if left['label'] in ('equivalent','permuted_equivalent') and right['label'] in ('equivalent','permuted_equivalent'):
            maps_total += 1
            maps_equal += left['right_from_left'] == right['right_from_left']
    count = len(keys)
    result.update(status='agreement_computed' if count else 'no_paired_completed_judgments',
        paired_completed=count, completed_each=[len(r) for r in rows],
        unpaired_or_missing=result['candidate_count']-count, confusion_matrix=matrix,
        disagreement_ids=disagreements, permutation_comparison_count=maps_total,
        permutation_exact_agreements=maps_equal, permutation_exact_agreement=maps_equal/maps_total if maps_total else None)
    if count:
        observed = sum(matrix[x][x] for x in LABELS)/count
        chance = sum(sum(matrix[x].values()) * sum(matrix[y][x] for y in LABELS) for x in LABELS)/(count*count)
        result.update(raw_agreement=observed, expected_agreement=chance,
            cohen_kappa=(observed-chance)/(1-chance) if chance < 1 else None,
            kappa_undefined_reason='constant_identical_marginals' if chance == 1 else None)
    return result

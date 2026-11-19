"""Verify artifact identity across live proposals, compilation and probe search.

This is provenance verification, never semantic annotation or another experiment.
"""
import argparse
import json
from pathlib import Path

from rcnc.domain_building import require_empty_output, save, snapshot_implementation
from scripts.experiments.run_downward_reference import sha


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def same(left, right, label):
    digest = sha(left)
    if digest != sha(right):
        raise ValueError('Lineage mismatch: ' + label)
    return digest


def audit(pair, bridge, probes, output):
    require_empty_output(output)
    pair_report, bridge_report = read(pair / 'report.json'), read(bridge / 'report.json')
    probe_manifest, probe_report = read(probes / 'manifest.json'), read(probes / 'report.json')
    if any(report['status'] != 'complete' for report in (pair_report, bridge_report, probe_report)):
        raise ValueError('Only complete processing reports may enter lineage verification')
    for root, report in ((pair, pair_report), (bridge, bridge_report), (probes, probe_report)):
        if report['manifest_sha256'] != sha(root / 'manifest.json'):
            raise ValueError('Parent report/manifest link changed')
        if not all(report.get(key) is True for key in ('inputs_unchanged', 'implementation_unchanged')):
            raise ValueError('Parent runtime integrity did not pass')
    pair_rows = {row['id']: row for row in pair_report['rows']}
    bridge_rows = {row['id']: row for row in bridge_report['rows']}
    if (len(pair_rows) != 2 or len(pair_report['rows']) != 2 or pair_report['condition_count'] != 2
            or len(bridge_rows) != 4 or len(bridge_report['rows']) != 4 or bridge_report['condition_count'] != 4):
        raise ValueError('Complete two-schema/four-export registry required')
    if probe_report['manifest_sha256'] != sha(probes / 'manifest.json'):
        raise ValueError('Probe report/manifest link changed')
    for name, expected in probe_manifest['input_sha256'].items():
        if sha(probes / name) != expected:
            raise ValueError('Frozen probe input drift: ' + name)
    packet_hash = same(pair / 'packet.json', bridge / 'packet.json', 'live packet to bridge')
    rows = []
    for name, row in sorted(bridge_rows.items()):
        case = bridge / 'cases' / name
        schema = row['schema_policy']
        prediction = pair / 'conditions' / schema / 'report.json'
        prediction_manifest = pair / 'conditions' / schema / 'manifest.json'
        if sha(prediction) != pair_rows[schema]['report_sha256'] or sha(prediction_manifest) != pair_rows[schema]['manifest_sha256']:
            raise ValueError('Live condition digest changed')
        links = {
            'predictions': same(prediction, case / 'predictions.json', name + ' predictions'),
            'prediction_manifest': same(prediction_manifest, case / 'prediction_manifest.json', name + ' request manifest'),
            'packet': same(pair / 'packet.json', case / 'packet.json', name + ' packet')}
        if (sha(case / 'alignment.json') != row['alignment_sha256']
                or sha(case / 'compiled/meta_domain.pddl') != row['compiled_domain_sha256']
                or sha(case / 'compiled/meta_domain.json') != row['compiled_metadata_sha256']):
            raise ValueError('Bridge alignment/model digest changed')
        rows.append({'id': name, 'links': links, 'groups': row['exported_groups'],
                     'compiled_domain_sha256': row['compiled_domain_sha256']})
    selected = bridge / 'cases/coupled_fields__inferred_role_types'
    alignment_hash = same(selected / 'alignment.json', probes / 'alignment.json', 'proposal alignment to probes')
    model_hash = same(selected / 'compiled/meta_domain.pddl', probes / 'models/machine/meta_domain.pddl', 'compiled model to probes')
    sources = read(selected / 'alignment.json')['source_sha256']
    for name, expected in sources.items():
        if sha(selected / 'inputs' / name) != expected or sha(probes / 'inputs' / name) != expected:
            raise ValueError('Source identity drift: ' + name)
    if list((probes / 'inputs').glob('*_problemfile.pddl')):
        raise ValueError('Probe construction must use domain-only sources')
    output.mkdir(parents=True)
    implementation = snapshot_implementation(output, [Path(__file__)])
    result = {'status': 'verified_live_composition_lineage', 'condition_count': len(rows), 'rows': rows,
        'packet_sha256': packet_hash, 'alignment_sha256': alignment_hash, 'model_sha256': model_hash,
        'source_count': len(sources), 'probe_slots': probe_report['task_count'],
        'probe_status_counts': probe_report['status_counts'],
        'parent_report_sha256': {str(root): sha(root / 'report.json') for root in (pair, bridge, probes)},
        'implementation_sha256': implementation,
        'scope': 'Exact artifact lineage only. Does not independently validate parent semantics, model accuracy, narrative quality or benchmark independence. No new model/planner requests.'}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('pair', 'bridge', 'probes', 'output'):
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(audit(args.pair, args.bridge, args.probes, args.output), indent=2))

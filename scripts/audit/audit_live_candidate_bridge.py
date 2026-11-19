"""Check graph/export provenance and whole-source ownership, never semantics."""
import argparse
from collections import Counter
import json
from pathlib import Path

from unified_planning.io import PDDLReader

from rcnc.domain_building import archived_implementation, digest, require_empty_output, save, snapshot_implementation
from rcnc.pddl import parse_domain
from scripts.audit.audit_interface_graph import audit as audit_graph


def audit(root, output):
    require_empty_output(output)
    read = lambda path: json.loads(path.read_text(encoding='utf-8'))
    manifest, report, protocol = (read(root / name) for name in ('manifest.json', 'report.json', 'protocol.json'))
    if report['status'] != 'complete' or report['manifest_sha256'] != digest(root / 'manifest.json'):
        raise ValueError('Complete unchanged bridge required')
    if any(report.get(key) is not True for key in ('inputs_unchanged', 'implementation_unchanged')):
        raise ValueError('Bridge integrity failure')
    for path, expected in manifest['input_sha256'].items():
        if digest(root / path) != expected:
            raise ValueError('Frozen input drift')
    for path, expected in manifest['implementation_sha256'].items():
        if digest(archived_implementation(root, path)) != expected:
            raise ValueError('Missing exact archived bridge code')
    pair_audit = read(root / 'prediction_pair_audit.json')
    if pair_audit['report_sha256'] != protocol['prediction_pair_report_sha256']:
        raise ValueError('Incorrect live pair provenance link')
    rows, conditions = {row['id']: row for row in report['rows']}, {row['id']: row for row in manifest['conditions']}
    if len(rows) != 4 or len(report['rows']) != 4 or len(manifest['conditions']) != 4 or set(rows) != set(conditions):
        raise ValueError('Incomplete or duplicate four-policy denominator')
    if report['planner_calls'] != 0 or report['model_calls'] != 0 or report['independent_semantic_labels'] != 0:
        raise ValueError('Bridge must retain its offline/unverified evidence tier')
    packet = read(root / 'packet.json')
    checked, failures = [], []
    for identifier, condition in conditions.items():
        row = dict(rows[identifier])
        directory = root / 'cases' / identifier
        if row['status'] != 'complete':
            row['audit_status'] = 'preserved_failed_bridge_condition'
            failures.append(identifier)
            checked.append(row)
            continue
        case, spec = read(directory / 'report.json'), read(directory / 'alignment.json')
        if digest(directory / 'report.json') != row['report_sha256'] or digest(directory / 'alignment.json') != row['alignment_sha256']:
            raise ValueError('Case report/alignment drift')
        if any(case.get(key) is not True for key in ('inputs_unchanged', 'implementation_unchanged', 'alignment_unchanged')):
            raise ValueError('Case integrity failure')
        for path, expected in case['implementation_sha256'].items():
            if digest(archived_implementation(directory, path)) != expected:
                raise ValueError('Case code archive mismatch')
        if spec['decision_basis'] != 'machine_hypothesis' or spec['semantic_status'] != 'unverified_machine_assumptions':
            raise ValueError('Machine hypotheses were promoted to semantic approval')
        if spec['initial_facts_inferred'] is not False or spec['object_identity_inferred'] is not False:
            raise ValueError('World/identity inference is outside this bridge')
        predictions = read(root / 'predictions' / condition['schema_policy'] / 'predictions.json')
        reconstructed = audit_graph(packet, predictions)
        if reconstructed != case['graph']:
            raise ValueError('Graph audit is not reproducible')
        exported = {decision['group_id']: decision for decision in case['decisions'] if decision['status'] == 'exported_unverified'}
        if len(spec['predicate_groups']) != len(exported) or len(exported) != row['exported_groups']:
            raise ValueError('Exported group denominator mismatch')
        for group in spec['predicate_groups']:
            decision = exported[group['id']]
            component = next(item for item in reconstructed['components'] if item['root'] == decision['root'])
            if component['conflicts']:
                raise ValueError('Inconsistent component exported')
            positions = {member['predicate']: member['order'] for member in group['members']}
            if positions != component['canonical_positions']:
                raise ValueError('Compiler argument positions differ from audited canonical slots')
        model = parse_domain(directory / 'compiled/meta_domain.pddl')
        meta = read(directory / 'compiled/meta_domain.json')
        if digest(directory / 'compiled/meta_domain.pddl') != row['compiled_domain_sha256'] or meta['compiled_domain_sha256'] != row['compiled_domain_sha256']:
            raise ValueError('Compiled artifact hash mismatch')
        if digest(directory / 'compiled/meta_domain.json') != row['compiled_metadata_sha256']:
            raise ValueError('Compiled provenance drift')
        source_actions, owners = 0, set()
        for source in meta['sources']:
            path = directory / 'inputs' / (source + '_domainfile.pddl')
            if digest(path) != protocol['source_domain_sha256'][path.name] or meta['source_sha256'][path.name] != digest(path):
                raise ValueError('Source-domain provenance mismatch')
            native = parse_domain(path)
            mapping = meta['action_maps'][source]
            if set(mapping) != set(native.actions) or len(set(mapping.values())) != len(mapping):
                raise ValueError('Incomplete source action ownership')
            if owners & set(mapping.values()):
                raise ValueError('Source action variants were fused')
            owners.update(mapping.values())
            source_actions += len(native.actions)
        if set(model.actions) != owners or source_actions != len(model.actions):
            raise ValueError('Missing/extra parameterized action variants')
        if list((directory / 'inputs').glob('*_problemfile.pddl')) or list((directory / 'compiled/problems').glob('*.pddl')):
            raise ValueError('Source worlds entered the pre-search domain-only bridge')
        PDDLReader().parse_problem(str(directory / 'compiled/meta_domain.pddl'))
        row.update(audit_status='verified_structure', source_action_variants=source_actions,
            parameterized_actions=len(model.actions), independent_parse='PARSED',
            source_problem_files_imported=0, semantic_equivalence_verified=False)
        checked.append(row)
    hashes = {}
    for row in checked:
        if row.get('compiled_domain_sha256'):
            hashes.setdefault(row['compiled_domain_sha256'], []).append(row['id'])
    implementation = snapshot_implementation(output, [Path(__file__), Path('scripts/audit/audit_interface_graph.py'),
        Path('rcnc/interface_graph.py'), Path('scripts/annotation/run_annotation_predictions.py'),
        Path('rcnc/interface_annotation.py'), Path('rcnc/domain_building.py'), Path('rcnc/pddl.py')])
    result = {'status': 'verified_live_candidate_bridge_structure' if not failures else 'audited_with_failed_conditions',
        'condition_count': 4, 'rows': checked, 'status_counts': dict(Counter(row['status'] for row in checked)),
        'distinct_model_hashes': len(hashes), 'same_model_hash_groups': hashes,
        'hashes_unchanged': True, 'independent_semantic_labels': 0, 'planner_or_model_calls': 0,
        'report_sha256': digest(root / 'report.json'), 'manifest_sha256': digest(root / 'manifest.json'),
        'implementation_sha256': implementation,
        'scope': 'Offline provenance/graph/order/action-ownership checks only. Complete variants and parsing do not prove interface semantics, source-local transition preservation or narrative quality. Identical artifact hashes are not additional independent models.'}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = audit(args.root, args.output)
    print(json.dumps({key: value for key, value in result.items() if key not in ('rows', 'implementation_sha256')}, indent=2))

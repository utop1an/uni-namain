"""Offline bridge from one complete live schema pair to four model-policy slots."""
import argparse
from collections import Counter
import json
from pathlib import Path
import traceback

from rcnc.candidate_alignment import run as build_candidate
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation


def prepare(protocol_path, output):
    require_empty_output(output)
    protocol = json.loads(protocol_path.read_text(encoding='utf-8'))
    audit = Path(protocol['prediction_pair_audit'])
    if digest(audit) != protocol['prediction_pair_audit_sha256'] or json.loads(audit.read_text(encoding='utf-8'))['status'] != 'verified_live_budget_pair':
        raise ValueError('Verified live pair required')
    if digest(Path(protocol['packet'])) != protocol['packet_sha256'] or len(protocol['conditions']) != 4:
        raise ValueError('Fixed packet/four-policy registry required')
    sources = Path(protocol['source_root'])
    if len(protocol['source_domain_sha256']) != 15 or not all(digest(sources / name) == value for name, value in protocol['source_domain_sha256'].items()):
        raise ValueError('Original domain pool drift')
    for condition in protocol['conditions']:
        for name in ('predictions', 'prediction_manifest'):
            if digest(Path(condition[name])) != condition[name + '_sha256']:
                raise ValueError('Live prediction drift')
    output.mkdir(parents=True)
    (output / 'protocol.json').write_bytes(protocol_path.read_bytes())
    (output / 'packet.json').write_bytes(Path(protocol['packet']).read_bytes())
    (output / 'prediction_pair_audit.json').write_bytes(audit.read_bytes())
    (output / 'inputs').mkdir()
    for name in protocol['source_domain_sha256']:
        (output / 'inputs' / name).write_bytes((sources / name).read_bytes())
    (output / 'predictions').mkdir()
    for policy in ('free_fields', 'coupled_fields'):
        condition = next(row for row in protocol['conditions'] if row['schema_policy'] == policy)
        directory = output / 'predictions' / policy
        directory.mkdir()
        for name in ('predictions', 'prediction_manifest'):
            (directory / (name + '.json')).write_bytes(Path(condition[name]).read_bytes())
    implementation = snapshot_implementation(output, [Path(__file__), Path('rcnc/candidate_alignment.py'),
        Path('rcnc/interface_graph.py'), Path('scripts/audit/audit_interface_graph.py'),
        Path('scripts/annotation/run_annotation_predictions.py'), Path('rcnc/interface_annotation.py'),
        Path('rcnc/aligned_domain.py'), Path('rcnc/domain_union.py'), Path('rcnc/domain_building.py'),
        Path('rcnc/pddl.py'), Path('rcnc/pddl_checks.py')])
    files = [path for path in output.rglob('*') if path.is_file() and 'implementation' not in path.relative_to(output).parts]
    manifest = {'status': 'frozen_before_graph_and_compile', 'conditions': protocol['conditions'], 'condition_count': 4,
        'input_sha256': {path.relative_to(output).as_posix(): digest(path) for path in files},
        'implementation_sha256': implementation, 'scope': protocol['scope'], 'planner_calls': 0, 'model_calls': 0}
    save(output / 'manifest.json', manifest)
    return manifest


def execute(output):
    manifest = json.loads((output / 'manifest.json').read_text(encoding='utf-8'))
    if (output / 'cases').exists() or (output / 'report.json').exists():
        raise ValueError('Use a new condition, not a silent rerun')
    if not all(digest(output / path) == expected for path, expected in manifest['input_sha256'].items()):
        raise ValueError('Frozen input drift')
    if not all(digest(Path(path)) == expected for path, expected in manifest['implementation_sha256'].items()):
        raise ValueError('Frozen code drift')
    (output / 'cases').mkdir()
    rows = []
    for condition in manifest['conditions']:
        directory = output / 'cases' / condition['id']
        policy = condition['schema_policy']
        row = {'id': condition['id'], 'schema_policy': policy, 'infer_role_types': condition['infer_role_types']}
        try:
            result = build_candidate(output / 'packet.json', output / 'predictions' / policy / 'predictions.json',
                output / 'inputs', directory, condition['infer_role_types'], True,
                output / 'predictions' / policy / 'prediction_manifest.json')
            graph = result['graph']
            row.update(status=result['status'], exported_groups=result['exported_groups'],
                equivalence_edges=graph['equivalence_edges'], withheld_components=graph['withheld_components'],
                component_count=graph['component_count'], compilation_status=result['compilation']['status'],
                report_sha256=digest(directory / 'report.json'), alignment_sha256=digest(directory / 'alignment.json'))
            if (directory / 'compiled/meta_domain.pddl').exists():
                row['compiled_domain_sha256'] = digest(directory / 'compiled/meta_domain.pddl')
                row['compiled_metadata_sha256'] = digest(directory / 'compiled/meta_domain.json')
        except Exception as exc:
            row.update(status='bridge_error', reason=f'{type(exc).__name__}: {exc}')
            directory.mkdir(parents=True, exist_ok=True)
            (directory / 'bridge_error.log').write_text(traceback.format_exc(), encoding='utf-8')
        rows.append(row)
        save(output / 'progress.json', {'completed': len(rows), 'condition_count': 4, 'rows': rows})
    groups = {}
    for row in rows:
        if row.get('compiled_domain_sha256'):
            groups.setdefault(row['compiled_domain_sha256'], []).append(row['id'])
    result = {'status': 'complete', 'condition_count': len(rows), 'rows': rows,
        'status_counts': dict(Counter(row['status'] for row in rows)), 'distinct_model_hashes': len(groups),
        'same_model_hash_groups': groups, 'planner_calls': 0, 'model_calls': 0, 'independent_semantic_labels': 0,
        'manifest_sha256': digest(output / 'manifest.json'),
        'inputs_unchanged': all(digest(output / path) == expected for path, expected in manifest['input_sha256'].items()),
        'implementation_unchanged': all(digest(Path(path)) == expected for path, expected in manifest['implementation_sha256'].items()),
        'scope': manifest['scope']}
    save(output / 'report.json', result)
    return result


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
    print(json.dumps({key: value for key, value in result.items() if key not in ('conditions', 'rows', 'input_sha256', 'implementation_sha256')}, indent=2))

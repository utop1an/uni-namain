"""Freeze and inspect every completed internal node at one live-run checkpoint.

These are intermediate diagnostics, never a completed reference comparison.
Historical original-goal traces are reused as conditional transport witnesses.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import traceback

from rcnc.domain_building import require_empty_output, save, snapshot_implementation
from scripts.audit.audit_fusion_mapping import run as audit_mapping
from scripts.experiments.probe_fusion_source_plans import run as probe_plans
from scripts.experiments.run_downward_reference import sha


def run(reference, source_run, output):
    require_empty_output(output)
    read = lambda path: json.loads(path.read_text(encoding='utf-8'))
    manifest, native_manifest, native_report = read(reference / 'manifest.json'), read(source_run / 'manifest.json'), read(source_run / 'report.json')
    if native_manifest['mode'] != 'original_source_tasks' or native_report['status'] != 'complete':
        raise ValueError('Complete original-world native witness bundle required')
    if native_report['manifest_sha256'] != sha(source_run / 'manifest.json'):
        raise ValueError('Native witness manifest drift')
    for task in native_manifest['tasks']:
        source = task['id']
        for kind, suffix in [('domain', '_domainfile.pddl'), ('problem', '_problemfile.pddl')]:
            path = source_run / 'tasks' / source / (kind + '.pddl')
            if sha(path) != task[kind + '_sha256'] or sha(path) != manifest['source_sha256'][source + suffix]:
                raise ValueError('Native witness uses a different original world/model')
    nodes = []
    for directory in sorted((reference / 'fusion/domain_fusion').iterdir(), key=lambda p: int(p.name) if p.name.isdigit() else -1):
        if not directory.name.isdigit() or int(directory.name) < manifest['source_count']:
            continue
        if not (directory / 'meta_domain.pddl').is_file() or not (directory / 'meta_domain.json').is_file():
            continue
        metadata = read(directory / 'meta_domain.json')
        nodes.append({'id': directory.name, 'sources': metadata['sources'],
            'domain_sha256': sha(directory / 'meta_domain.pddl'), 'metadata_sha256': sha(directory / 'meta_domain.json')})
    if not nodes:
        raise ValueError('No completed internal node to inspect')
    output.mkdir(parents=True)
    for label, path in [('reference_manifest.json', reference / 'manifest.json'),
                        ('native_manifest.json', source_run / 'manifest.json'), ('native_report.json', source_run / 'report.json')]:
        (output / label).write_bytes(path.read_bytes())
    implementation = snapshot_implementation(output, [Path(__file__), Path('scripts/audit/audit_fusion_mapping.py'),
        Path('scripts/audit/audit_union_preservation.py'), Path('scripts/experiments/probe_fusion_source_plans.py'),
        Path('rcnc/pddl.py'), Path('rcnc/validation.py'), Path('rcnc/domain_building.py')])
    protocol = {'status': 'frozen_before_audit', 'observed_utc': datetime.now(timezone.utc).isoformat(),
        'node_count': len(nodes), 'nodes': nodes, 'reference_status_at_checkpoint': manifest['status'],
        'reference_manifest_sha256': sha(output / 'reference_manifest.json'),
        'native_manifest_sha256': sha(output / 'native_manifest.json'), 'native_report_sha256': sha(output / 'native_report.json'),
        'native_budget': native_manifest['budget'], 'implementation_sha256': implementation,
        'scope': 'All completed internal nodes at the frozen checkpoint. Repeated source plans across nodes are correlated diagnostics. No new inference or solver calls, no final-root completion or semantic-accuracy claim.'}
    save(output / 'protocol.json', protocol)
    report = {'status': 'running', 'task_count': len(nodes), 'protocol_sha256': sha(output / 'protocol.json'), 'rows': []}
    save(output / 'report.json', report)
    for node in nodes:
        directory = reference / 'fusion/domain_fusion' / node['id']
        row = {'id': node['id'], 'sources': node['sources']}
        try:
            if sha(directory / 'meta_domain.pddl') != node['domain_sha256'] or sha(directory / 'meta_domain.json') != node['metadata_sha256']:
                raise ValueError('Completed node changed after registry freeze')
            mapping_dir = output / 'nodes' / node['id'] / 'mapping'
            mapping = audit_mapping(reference, directory, mapping_dir)
            transport_dir = output / 'nodes' / node['id'] / 'transport'
            transport = probe_plans(mapping_dir, source_run, transport_dir)
            row.update(status='audited', independent_domain_parse=mapping['independent_domain_parse'],
                action_counts=mapping['action_counts'], source_action_total=mapping['source_action_total'],
                mapped_action_total=mapping['mapped_action_total'], transport_counts=transport['counts'],
                transported_validation_counts=transport['transported_validation_counts'],
                mapping_report_sha256=sha(mapping_dir / 'report.json'), transport_report_sha256=sha(transport_dir / 'report.json'))
        except Exception as exc:
            row.update(status='audit_error', reason=f'{type(exc).__name__}: {exc}')
            error = output / 'nodes' / node['id'] / 'error.log'
            error.parent.mkdir(parents=True, exist_ok=True)
            error.write_text(traceback.format_exc(), encoding='utf-8')
        report['rows'].append(row)
        report['status_counts'] = dict(Counter(r['status'] for r in report['rows']))
        save(output / 'report.json', report)
        print(json.dumps(row), flush=True)
    report.update(status='complete', implementation_unchanged=all(sha(Path(p)) == h for p, h in implementation.items()),
        nodes_unchanged=all(sha(reference / 'fusion/domain_fusion' / n['id'] / 'meta_domain.pddl') == n['domain_sha256']
            and sha(reference / 'fusion/domain_fusion' / n['id'] / 'meta_domain.json') == n['metadata_sha256'] for n in nodes),
        scope=protocol['scope'])
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--reference', type=Path, required=True)
    parser.add_argument('--source-run', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    report = run(args.reference, args.source_run, args.output)
    print(json.dumps({k: v for k, v in report.items() if k != 'rows'}, indent=2))

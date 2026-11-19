"""Rehash explicit completed-run inputs and archived code, without rerunning them."""
import argparse
import json
from pathlib import Path

from rcnc.domain_building import archived_implementation, digest, require_empty_output, save, snapshot_implementation


def recheck(protocol_path, output):
    require_empty_output(output)
    protocol = json.loads(protocol_path.read_text(encoding='utf-8'))
    roots = [Path(name) for name in protocol['roots']]
    if not roots or len({p.resolve() for p in roots}) != len(roots):
        raise ValueError('Require a nonempty unique explicit run list')
    rows = []
    for root in roots:
        row = {'id': root.as_posix(), 'checks': [], 'failures': []}
        try:
            manifest = json.loads((root / 'manifest.json').read_text(encoding='utf-8'))
            report = json.loads((root / 'report.json').read_text(encoding='utf-8'))
            if report['status'] != 'complete' or report['manifest_sha256'] != digest(root / 'manifest.json'):
                raise ValueError('Complete report tied to its frozen manifest required')
            for kind, table in (('input', manifest['input_sha256']),
                                ('archived_code', manifest['implementation_sha256'])):
                if not table:
                    raise ValueError('Empty frozen ' + kind + ' inventory')
                for name, expected in sorted(table.items()):
                    try:
                        if kind == 'input':
                            path = root / name
                            if Path(name).is_absolute() or not path.resolve().is_relative_to(root.resolve()):
                                raise ValueError('Frozen input escapes its run root')
                        else:
                            path = archived_implementation(root, name)
                        actual = digest(path)
                        status = 'match' if actual == expected else 'mismatch'
                        item = {'kind': kind, 'name': name, 'expected_sha256': expected,
                                'actual_sha256': actual, 'status': status}
                    except Exception as exc:
                        item = {'kind': kind, 'name': name, 'status': 'error', 'reason': f'{type(exc).__name__}: {exc}'}
                    row['checks'].append(item)
                    if item['status'] != 'match':
                        row['failures'].append(item)
            row.update(status='verified' if not row['failures'] else 'integrity_failure',
                       manifest_sha256=digest(root / 'manifest.json'),
                       parent_report_sha256=digest(root / 'report.json'))
        except Exception as exc:
            row.update(status='rejected', reason=f'{type(exc).__name__}: {exc}')
        rows.append(row)
    output.mkdir(parents=True)
    (output / 'protocol.json').write_bytes(protocol_path.read_bytes())
    implementation = snapshot_implementation(output, [Path(__file__), Path('rcnc/domain_building.py')])
    result = {'status': 'verified_frozen_artifacts' if all(r['status'] == 'verified' for r in rows) else 'audited_with_integrity_failures',
        'task_count': len(rows), 'rows': rows, 'file_checks': sum(len(r['checks']) for r in rows),
        'protocol_sha256': digest(output / 'protocol.json'), 'implementation_sha256': implementation,
        'scope': 'Current byte identity of explicitly listed completed-run frozen inputs and archived code only. Not a fresh execution, independent dataset, recursive proof of every downstream file or semantic assessment. Legacy archive recovery timing remains as separately documented.'}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--protocol', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = recheck(args.protocol, args.output)
    print(json.dumps({k: v for k, v in result.items() if k != 'rows'}, indent=2))

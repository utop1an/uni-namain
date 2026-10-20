"""Offline, hash-checked admission audit; no translations or planner calls."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

from rcnc.domain_building import save
from rcnc.pddl import parse_domain


MARKERS = (':actors', ':not-needs-intention', ':rank-fun', ':constraints', 'intends')


def sha(data):
    return hashlib.sha256(data).hexdigest()


def inspect_text(text):
    evidence = []
    for number, line in enumerate(text.splitlines(), 1):
        code = line.split(';', 1)[0].lower()
        for marker in MARKERS:
            if re.search(r'(?<![\w-])' + re.escape(marker) + r'(?![\w-])', code):
                evidence.append({'marker': marker, 'line': number, 'text': line.strip()})
    return evidence


def audit(snapshot, local_inputs, attribution_report, output):
    if output.exists():
        raise ValueError('Use a fresh report path')
    manifest_path = snapshot / 'snapshot_manifest.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    if manifest['status'] != 'complete':
        raise ValueError('Completed source snapshot required')
    tree = (snapshot / 'tree.json').read_bytes()
    if sha(tree) != manifest['tree_sha256']:
        raise ValueError('Snapshot tree changed')
    tree_entries = {entry['path']: entry for entry in json.loads(tree)['tree']}
    expected = {name for name in tree_entries if any(
        name.startswith('originals/' + family + '/') for family in manifest['families'])
        and name.endswith(('.lbl', '.lbp'))}
    selected = {row['path'] for row in manifest['files'] if row['path'].startswith('originals/')}
    if selected != expected or len({r['path'] for r in manifest['files']}) != len(manifest['files']):
        raise ValueError('Snapshot is incomplete or duplicated')
    local = {str(path): path.read_bytes() for path in sorted(local_inputs.glob('*.pddl'))}
    files, families = [], []
    for entry in manifest['files']:
        relative = Path(entry['path'])
        if relative.is_absolute() or '..' in relative.parts:
            raise ValueError('Unsafe snapshot path')
        path = snapshot / 'candidate_files' / relative
        data = path.read_bytes()
        blob = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
        if (sha(data) != entry['sha256'] or blob != entry['git_blob_sha1']
                or blob != tree_entries[entry['path']]['sha']):
            raise ValueError('Candidate hash mismatch: ' + entry['path'])
        if not entry['path'].startswith('originals/'):
            continue
        evidence = inspect_text(data.decode('utf-8-sig'))
        parser = {'status': 'not_applicable_problem_not_PDDL'}
        if path.suffix == '.lbl':
            try:
                parse_domain(path)
                parser = {'status': 'parsed_not_semantically_admitted'}
            except Exception as exc:
                parser = {'status': 'unsupported_raw_source', 'error': f'{type(exc).__name__}: {exc}'}
        files.append({'path': entry['path'], 'sha256': entry['sha256'], 'url': entry['url'],
            'feature_evidence': evidence, 'parser': parser,
            'exact_local_matches': [p for p, value in local.items() if value == data],
            'newline_normalized_local_matches': [p for p, value in local.items()
                if value.replace(b'\r\n', b'\n') == data.replace(b'\r\n', b'\n')]})
    attribution = attribution_report.read_text(encoding='utf-8')
    headings = {'aladdin': 'Aladdin', 'bribery': 'Bribery', 'deerhunter': 'Deer Hunter', 'secretagent': 'Secret Agent'}
    for family in manifest['families']:
        rows = [r for r in files if r['path'].startswith('originals/' + family + '/')]
        title = '\\subsection{' + headings[family] + '}'
        start = attribution.find(title)
        if start < 0:
            raise ValueError('Missing attribution section: ' + family)
        prefix = attribution[start:start + 550]
        families.append({'family': family, 'status': 'not_admitted', 'files': len(rows),
            'format': 'original .lbl action library and .lbp problem, not classical PDDL',
            'feature_counts': dict(Counter(e['marker'] for row in rows for e in row['feature_evidence'])),
            'origin_evidence': {'path': str(attribution_report),
                'line': attribution[:start].count('\n') + 1, 'section': headings[family],
                'excerpt': prefix.split('\\end{quote}')[0]},
            'upstream_lineage': 'Riedl dissertation / IPOCL examples as attributed by benchmark maintainers; not four independent acquisition lineages',
            'learning_provenance': 'not asserted; supplied original authored narrative models',
            'blocking_reasons': ['Raw representation unsupported',
                'Actors/intention/ranking semantics require a faithful representation audit and adapter',
                'Story-level overlap with observed sources unresolved; byte nonidentity is insufficient',
                'Per-problem redistribution terms not established by tool GPL notice'],
            'next_action': 'Keep as audited candidates; do not strip actor or intention fields or promote to held-out test'})
    report = {'status': 'audit_complete_not_admitted', 'commit': manifest['commit'],
        'family_count': len(families), 'admitted_families': 0, 'new_independent_test_families': 0,
        'model_or_planner_called': False, 'translation_applied': False,
        'snapshot_manifest_sha256': sha(manifest_path.read_bytes()),
        'attribution_report_sha256': sha(attribution_report.read_bytes()),
        'local_file_sha256': {name: sha(value) for name, value in local.items()},
        'implementation_sha256': sha(Path(__file__).read_bytes()),
        'files': files, 'families': families,
        'scope': 'Raw compatibility/provenance screening only. No prediction or solution files or solver outcomes read; attribution report used for origin metadata only. Inspection does not create held-out evaluation results.'}
    output.parent.mkdir(parents=True, exist_ok=True)
    save(output, report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--snapshot', type=Path, required=True)
    parser.add_argument('--local-inputs', type=Path, default=Path('data/narra-domains'))
    parser.add_argument('--attribution-report', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = audit(args.snapshot, args.local_inputs, args.attribution_report, args.output)
    print(json.dumps({k: v for k, v in result.items() if k not in ('files', 'families', 'local_file_sha256')}, indent=2))

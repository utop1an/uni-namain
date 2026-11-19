"""Byte-preserving pinned intake for the approved GPT-4 revised experiment."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import io
import json
from pathlib import Path
import urllib.request
import zipfile

from rcnc.domain_building import digest, require_empty_output, save
from rcnc.pddl import parse_sexpr, section

COMMIT = 'de333cbc07a2c735942516bf6ef87d55d4b723a2'
EXPOSED = {'tiny_stories/story_001', 'tiny_stories/story_002', 'writing_prompts/wp_001'}


def prepare(tree_path, output):
    require_empty_output(output)
    tree = json.loads(tree_path.read_text(encoding='utf-8'))
    if tree['commit'] != COMMIT or tree['truncated']:
        raise ValueError('Complete pinned upstream tree required')
    output.mkdir(parents=True)
    stories = sorted({e['path'].split('/')[2] + '/' + e['path'].split('/')[3]
                      for e in tree['entries'] if e['path'].startswith('results/runs/')})
    if len(stories) != 192:
        raise ValueError('Expected 192 public GPT-4 story records')
    development = set(EXPOSED)
    for corpus in ('tiny_stories', 'writing_prompts'):
        pool = sorted((s for s in stories if s.startswith(corpus + '/') and s not in EXPOSED),
                      key=lambda s: hashlib.sha256(('revised-split-20261101|' + s).encode()).hexdigest())
        development.update(pool[:20 - sum(s.startswith(corpus + '/') for s in development)])
    protocol = {'status': 'frozen_before_download_and_execution', 'created_utc': datetime.now(timezone.utc).isoformat(),
                'upstream_commit': COMMIT, 'tree_sha256': digest(tree_path), 'source_variant': 'gpt4_revised',
                'sources': [{'id': s.replace('/', '__'), 'upstream_id': s,
                             'split': 'development' if s in development else 'test',
                             'previously_inspected': s in EXPOSED} for s in stories],
                'split_rule': '20 per corpus development; three previously inspected stories forced to development; remaining IDs ordered by SHA256(revised-split-20261101|corpus/story). Admission and solver outcomes do not affect split. Text duplicates will be audited before test execution.',
                'rules': ['All 192 records retained, including empty and unsupported files.',
                          'Use paired revised domain/problem only; originals retained for provenance, never fallback.',
                          'No new source-model generation or repair.',
                          'Retain intentionality and domain axioms; no classical projection in primary conditions.',
                          'Parameterized merged models and mappings must predate downstream planning.',
                          'Freeze complete candidate/task/budget protocol before any model or search call.'],
                'development_native_budget': {'seconds_each': 30, 'memory_mb': 4096, 'attempts': 1, 'workers': 1},
                'planned_main_maxima': {'domain_pairs': 60, 'predicate_candidates_per_pair': 8,
                                       'action_candidates_per_pair': 4, 'model_requests': 720},
                'main_execution_frozen': False,
                'entries': tree['entries']}
    save(output / 'protocol.json', protocol)
    save(output / 'manifest.json', {'protocol_sha256': digest(output / 'protocol.json'),
                                    'implementation_sha256': digest(Path(__file__))})
    return {'status': protocol['status'], 'sources': len(stories), 'development': len(development),
            'test': len(stories) - len(development), 'files': len(tree['entries'])}


def fetch(output):
    manifest = json.loads((output / 'manifest.json').read_text(encoding='utf-8'))
    if digest(output / 'protocol.json') != manifest['protocol_sha256']:
        raise ValueError('Changed intake protocol')
    if (output / 'download_report.json').exists() or (output / 'upstream.zip').exists():
        raise ValueError('Fresh download only; existing files must not be replaced')
    protocol = json.loads((output / 'protocol.json').read_text(encoding='utf-8'))
    url = f'https://codeload.github.com/alex-calderwood/there-and-back/zip/{COMMIT}'
    with urllib.request.urlopen(url, timeout=60) as response:
        raw = response.read(32_000_001)
    if len(raw) > 32_000_000:
        raise ValueError('Archive exceeds 32 MB intake bound')
    (output / 'upstream.zip').write_bytes(raw)
    archive = zipfile.ZipFile(io.BytesIO(raw))
    prefix = f'there-and-back-{COMMIT}/'
    rows = []
    for entry in protocol['entries']:
        relative = Path(entry['path'])
        if relative.is_absolute() or '..' in relative.parts:
            raise ValueError('Unsafe archive path')
        data = archive.read(prefix + entry['path'])
        git_hash = hashlib.sha1(f'blob {len(data)}\0'.encode() + data).hexdigest()
        if git_hash != entry['sha'] or len(data) != entry['size']:
            raise ValueError('Upstream blob verification failed: ' + entry['path'])
        target = output / 'upstream' / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        rows.append({'path': entry['path'], 'bytes': len(data), 'git_blob_sha1': git_hash,
                     'sha256': hashlib.sha256(data).hexdigest()})
    report = {'status': 'verified', 'upstream_commit': COMMIT, 'archive_sha256': hashlib.sha256(raw).hexdigest(),
              'archive_url': url, 'files': rows, 'file_count': len(rows), 'model_calls': 0, 'planner_calls': 0}
    save(output / 'download_report.json', report)
    return {k: v for k, v in report.items() if k != 'files'}


def audit(output):
    protocol = json.loads((output / 'protocol.json').read_text(encoding='utf-8'))
    if (output / 'intake_report.json').exists():
        raise ValueError('Intake report already exists')
    rows = []
    for source in protocol['sources']:
        folder = output / 'upstream/results/runs' / source['upstream_id']
        row = dict(source, status='sexpr_parsed_not_semantically_admitted')
        row['files'] = {name: {'bytes': (folder / name).stat().st_size, 'sha256': digest(folder / name)}
                        for name in ('input.txt', 'metadata.json', 'revised-domain.pddl', 'revised-problem.pddl')}
        for kind in ('domain', 'problem'):
            path = folder / f'revised-{kind}.pddl'
            if path.stat().st_size == 0:
                row['status'] = 'empty_revised_output'; continue
            try:
                root = parse_sexpr(path.read_text(encoding='utf-8'))
                if not isinstance(root, list) or root[0] != 'define' or root[1][0] != kind:
                    raise ValueError('Wrong define header')
                row[kind + '_sections'] = [x[0] for x in root[2:] if isinstance(x, list) and x]
                if kind == 'domain':
                    row['action_count'] = sum(x[0] == ':action' for x in root[2:] if isinstance(x, list) and x)
                elif section(root, ':init') is None:
                    row['status'] = 'needs_initial_state'
            except Exception as exc:
                if row['status'] != 'empty_revised_output': row['status'] = 'sexpr_error'
                row[kind + '_error'] = str(exc)
        try:
            meta = json.loads((folder / 'metadata.json').read_text(encoding='utf-8'))
            rmeta = meta.get('revised', {})
            row['upstream_model'] = rmeta.get('model_name')
            row['upstream_revised_planner_status'] = {k: rmeta.get('plan_metadata', {}).get(k) for k in ('compiled', 'planned')}
            messages = [p['content'] for p in rmeta.get('prompt', []) if p.get('role') == 'user']
            last = messages[-1] if messages else ''
            row['revision_story_field_is_path'] = last.startswith('<|Story|>\n./results/')
        except Exception as exc:
            row['metadata_error'] = str(exc)
        rows.append(row)
    report = {'status': 'intake_complete_not_native_or_merge_validation', 'source_count': len(rows),
              'counts': dict(Counter(r['status'] for r in rows)),
              'split_counts': dict(Counter(r['split'] for r in rows)), 'rows': rows,
              'model_calls': 0, 'planner_calls': 0}
    save(output / 'intake_report.json', report)
    return {k: v for k, v in report.items() if k != 'rows'}


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('mode', choices=['prepare', 'fetch', 'audit'])
    p.add_argument('--tree', type=Path)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    result = prepare(a.tree, a.output) if a.mode == 'prepare' else globals()[a.mode](a.output)
    print(json.dumps(result, ensure_ascii=False, indent=2))

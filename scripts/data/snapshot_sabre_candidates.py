"""Snapshot previously uninspected original source families, without solutions."""
import argparse
import hashlib
import json
from pathlib import Path
import urllib.request

from rcnc.domain_building import require_empty_output, save


COMMIT = 'd9327b3ec2706a468c580c332d3f848ffb4c47fc'
FAMILIES = ('aladdin', 'bribery', 'deerhunter', 'secretagent')


def fetch(url):
    request = urllib.request.Request(url, headers={'User-Agent': 'narrative-domain-admission-audit'})
    with urllib.request.urlopen(request, timeout=45) as response:
        return response.read()


def snapshot(output):
    require_empty_output(output)
    output.mkdir(parents=True, exist_ok=True)
    url = f'https://api.github.com/repos/sgware/sabre-benchmarks/git/trees/{COMMIT}?recursive=1'
    tree_bytes = fetch(url)
    tree = json.loads(tree_bytes)
    if tree.get('truncated'):
        raise ValueError('Truncated repository tree')
    (output / 'tree.json').write_bytes(tree_bytes)
    manifest = {'status': 'downloading', 'repository': 'https://github.com/sgware/sabre-benchmarks',
                'commit': COMMIT, 'tree_url': url, 'tree_sha256': hashlib.sha256(tree_bytes).hexdigest(),
                'families': list(FAMILIES), 'files': [], 'solutions_downloaded': False,
                'selection': 'All original lbl/lbp artifacts in four families absent from previous six-family audit; no outcome selection',
                'scope': 'Admission material only, not an admitted independent benchmark'}
    save(output / 'snapshot_manifest.json', manifest)
    for entry in tree['tree']:
        name = entry['path']
        selected = any(name.startswith('originals/' + family + '/') for family in FAMILIES)
        if entry['type'] != 'blob' or not (name == 'readme.md' or (selected and name.endswith(('.lbl', '.lbp')))):
            continue
        url = f'https://raw.githubusercontent.com/sgware/sabre-benchmarks/{COMMIT}/{name}'
        data = fetch(url)
        blob = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
        if blob != entry['sha']:
            raise ValueError('Git blob mismatch: ' + name)
        path = output / 'candidate_files' / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
        manifest['files'].append({'path': name, 'url': url, 'bytes': len(data),
                                  'sha256': hashlib.sha256(data).hexdigest(), 'git_blob_sha1': blob})
        save(output / 'snapshot_manifest.json', manifest)
    covered = {f for f in FAMILIES if any(row['path'].startswith('originals/' + f + '/') for row in manifest['files'])}
    if covered != set(FAMILIES):
        raise ValueError('Missing selected family')
    manifest['status'] = 'complete'
    manifest['implementation_sha256'] = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    save(output / 'snapshot_manifest.json', manifest)
    return manifest


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = snapshot(args.output)
    print(json.dumps({'status': result['status'], 'files': len(result['files']), 'families': result['families']}))

"""Download a fixed selection of public PDDL source artifacts; never execute them."""
import argparse
import hashlib
import json
from pathlib import Path

from rcnc.domain_building import require_empty_output, save
from scripts.data.snapshot_sabre_candidates import fetch


def snapshot(selection_path, output):
    require_empty_output(output)
    selection = json.loads(selection_path.read_text(encoding='utf-8'))
    output.mkdir(parents=True, exist_ok=True)
    (output / 'selection.json').write_bytes(selection_path.read_bytes())
    manifest = {'status': 'downloading', 'selection_sha256': hashlib.sha256(selection_path.read_bytes()).hexdigest(),
                'repositories': [], 'files': [], 'solutions_downloaded': False}
    save(output / 'manifest.json', manifest)
    for provider in selection['repositories']:
        repo, commit, key = provider['repository'], provider['commit'], provider['id']
        url = f'https://api.github.com/repos/{repo}/git/trees/{commit}?recursive=1'
        raw_tree = fetch(url)
        tree = json.loads(raw_tree)
        if tree.get('truncated'):
            raise ValueError('Truncated source tree')
        directory = output / key
        directory.mkdir()
        (directory / 'tree.json').write_bytes(raw_tree)
        entries = {entry['path']: entry for entry in tree['tree'] if entry['type'] == 'blob'}
        paths = set(provider['metadata'])
        for candidate in selection['candidates']:
            if candidate['provider'] == key:
                paths.update([candidate['domain'], candidate['problem']])
        manifest['repositories'].append({**provider, 'tree_url': url,
            'tree_sha256': hashlib.sha256(raw_tree).hexdigest(),
            'pddl_file_count': sum(path.endswith('.pddl') for path in entries)})
        for name in sorted(paths):
            relative = Path(name)
            if relative.is_absolute() or '..' in relative.parts or name not in entries:
                raise ValueError('Missing or unsafe selected artifact: ' + name)
            url = f'https://raw.githubusercontent.com/{repo}/{commit}/{name}'
            data = fetch(url)
            blob = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
            if blob != entries[name]['sha']:
                raise ValueError('Git blob mismatch: ' + name)
            destination = directory / 'files' / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(data)
            manifest['files'].append({'provider': key, 'path': name, 'url': url,
                'sha256': hashlib.sha256(data).hexdigest(), 'git_blob_sha1': blob, 'bytes': len(data)})
            save(output / 'manifest.json', manifest)
    manifest.update(status='complete', implementation_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    save(output / 'manifest.json', manifest)
    return manifest


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--selection', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = snapshot(args.selection, args.output)
    print(json.dumps({'status': result['status'], 'files': len(result['files']), 'providers': len(result['repositories'])}))

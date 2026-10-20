"""Freeze experiment inputs and reject drift before any planning run."""
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def contained(root,relative):
    root=root.resolve();path=(root/relative).resolve()
    if not path.is_relative_to(root):raise ValueError('Frozen path escapes root')
    return path


def implementation_path(relative):
    """Resolve a moved source without changing a historical lock or its hash."""
    original = contained(ROOT, relative)
    if original.exists():
        return original
    for inventory in (ROOT/'scripts/relocation.json', ROOT/'archive/rcnc/package-relocation.json', ROOT/'rcnc/entrypoints-relocation.json'):
        if inventory.exists():
            entries = json.loads(inventory.read_text(encoding='utf-8'))['files']
            for entry in entries:
                if entry['original_path'] == relative:
                    return contained(ROOT, entry.get('current_path', entry.get('archive_path')))
    return original


def freeze_bundle(folder,manifest):
    if (folder/'freeze.json').exists():raise ValueError('Already frozen; create a new version')
    files=['registry.json','manifest.json',*manifest['tasks']]
    if manifest.get('annotation_queue'):files.append(manifest['annotation_queue'])
    source_files=sorted((ROOT/'data/narra-domains').glob('*_domainfile.pddl'))
    code_files=sorted((ROOT/'rcnc').glob('*.py')) + sorted((ROOT/'archive/rcnc').glob('*.py')) + [ROOT/'scripts/experiments/build_rcnc_frozen.py',ROOT/'scripts/experiments/run_rcnc_frozen.py',ROOT/'archive/domain_merge.py']
    lock={'bundle_files':{name:digest(contained(folder,name)) for name in files},
          'source_files':{p.relative_to(ROOT).as_posix():digest(p) for p in source_files},
          'implementation_files':{p.relative_to(ROOT).as_posix():digest(p) for p in code_files}}
    (folder/'freeze.json').write_text(json.dumps(lock,indent=2)+'\n',encoding='utf-8')
    return digest(folder/'freeze.json')


def verify_bundle(folder):
    lock=json.loads((folder/'freeze.json').read_text(encoding='utf-8'))
    for group,root in [('bundle_files',folder),('source_files',ROOT),('implementation_files',ROOT)]:
        for name,expected in lock[group].items():
            path = implementation_path(name) if group == 'implementation_files' else contained(root,name)
            if not path.is_file() or digest(path)!=expected:raise ValueError(f'Frozen input changed: {group}/{name}')
    manifest=json.loads((folder/'manifest.json').read_text(encoding='utf-8'))
    if any(name not in lock['bundle_files'] for name in manifest['tasks']):raise ValueError('Unfrozen task')
    return manifest,lock

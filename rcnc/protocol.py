"""Freeze experiment inputs and reject drift before any planning run."""
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def contained(root,relative):
    root=root.resolve();path=(root/relative).resolve()
    if not path.is_relative_to(root):raise ValueError('Frozen path escapes root')
    return path


def freeze_bundle(folder,manifest):
    if (folder/'freeze.json').exists():raise ValueError('Already frozen; create a new version')
    files=['registry.json','manifest.json',*manifest['tasks']]
    if manifest.get('annotation_queue'):files.append(manifest['annotation_queue'])
    source_files=sorted((ROOT/'data/narra-domains').glob('*_domainfile.pddl'))
    code_files=sorted((ROOT/'rcnc').glob('*.py')) + [ROOT/'build_rcnc_frozen.py',ROOT/'run_rcnc_frozen.py',ROOT/'merge_domains.py',ROOT/'pddl_checks.py']
    lock={'bundle_files':{name:digest(contained(folder,name)) for name in files},
          'source_files':{p.relative_to(ROOT).as_posix():digest(p) for p in source_files},
          'implementation_files':{p.relative_to(ROOT).as_posix():digest(p) for p in code_files}}
    (folder/'freeze.json').write_text(json.dumps(lock,indent=2)+'\n',encoding='utf-8')
    return digest(folder/'freeze.json')


def verify_bundle(folder):
    lock=json.loads((folder/'freeze.json').read_text(encoding='utf-8'))
    for group,root in [('bundle_files',folder),('source_files',ROOT),('implementation_files',ROOT)]:
        for name,expected in lock[group].items():
            if digest(contained(root,name))!=expected:raise ValueError(f'Frozen input changed: {group}/{name}')
    manifest=json.loads((folder/'manifest.json').read_text(encoding='utf-8'))
    if any(name not in lock['bundle_files'] for name in manifest['tasks']):raise ValueError('Unfrozen task')
    return manifest,lock

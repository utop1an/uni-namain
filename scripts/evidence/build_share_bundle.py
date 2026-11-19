"""Package current code and complete selected reports without local credentials.

This compact handoff is not a full raw-trace experiment reproduction archive.
Run from the repository root and choose a new output directory.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import zipfile


def digest(data):
    return hashlib.sha256(data).hexdigest()


def build(output):
    root = Path(__file__).resolve().parents[2]
    if Path.cwd().resolve() != root:
        raise ValueError('Run from the repository root')
    selected = {}

    def add(path, sha256=None):
        p = Path(path)
        if not p.is_file():
            raise FileNotFoundError(p)
        if p.is_symlink() or not p.resolve().is_relative_to(root):
            raise ValueError('File escapes repository: ' + str(p))
        if any(part in {'.env', '.git', '.venv', '.cache', '.tmp'} or part.startswith('.env.')
               for part in p.parts):
            raise ValueError('Private/local path selected: ' + str(p))
        previous = selected.setdefault(p.as_posix(), sha256)
        if sha256 is not None:
            if previous is not None and previous != sha256:
                raise ValueError('Conflicting pinned hashes: ' + str(p))
            selected[p.as_posix()] = sha256

    def tree(path, suffixes):
        for base, dirs, files in os.walk(path):
            dirs[:] = [d for d in dirs if not d.startswith('.') and d != '__pycache__']
            if Path(base) == Path('archive/scripts') and 'diagnostics' in dirs:
                dirs.remove('diagnostics')
            for name in files:
                p = Path(base) / name
                if p.suffix.lower() in suffixes:
                    add(p)

    for p in ('README.md', 'AGENTS.md', 'pyproject.toml', 'requirements-research.txt',
              'THIRD_PARTY_NOTICES.md', '.gitignore', '.gitattributes'):
        add(p)
    code_suffixes = {'.py', '.java', '.md', '.json', '.html', '.txt', '.toml', '.ps1'}
    for directory in ('rcnc', 'unidomain', 'scripts', 'tests', 'prompts', 'templates',
                      'archive/rcnc', 'archive/scripts', 'archive/entrypoints',
                      'archive/requirements', 'docs'):
        tree(directory, code_suffixes)
    for p in Path('archive').iterdir():
        if p.is_file() and p.suffix in {'.py', '.json', '.md'}:
            add(p)
    for directory in ('data/narra-domains', 'data/human_narrative_domains_2026_11_04_v1',
                      'data/rcnc/queries'):
        tree(directory, {'.pddl', '.json', '.md', '.txt', '.csv'})
    # Small saved fixtures required by the shipped regression suite.
    tree('data/research_release/icaps2027_2026_11_03', {'.json', '.pddl', '.txt'})
    add('data/benchmarks/selection_comparison_k2345_n50_2026_11_05_v2/groups.json')
    for p in ('data/merged_strict/meta_domain.pddl',
              'data/validation/transport_merge_glm_2026_10_28_v1/inputs/DLOG_domainfile.pddl',
              'data/external/action_merge_candidates_2026_10_28_v1/logistics98/domain.pddl',
              'data/external/prospective_sources_2026_10_26_v1/ipc/files/driverlog/domain.pddl'):
        add(p)
    for p in ('paper/AnonymousSubmission2027.tex', 'paper/references.bib',
              'paper/aaai2027.sty', 'paper/aaai2027.bst', 'paper/build_icaps2027.ps1',
              'paper/README.md', 'paper/current_evidence.json', 'paper/claim_evidence.json',
              'paper/submission_workplan.json', 'paper/records/relocation.json'):
        add(p)
    figure_root = next(p for p in Path('paper').iterdir() if p.name.lower() == 'figures')
    for p in figure_root.glob('*.pdf'):
        add(p)
    for name in ('draw_figures.py', 'draw_rescue_example.py'):
        add(figure_root / name)
    tree('paper/records/protocols', {'.json', '.md'})
    tree('paper/results/narrafuse_main_experiment_freeze_2026_11_15_v1', {'.json', '.tex'})
    tree('paper/results/narrafuse_interactive_case_2026_11_16_v1', {'.json', '.py'})
    rescue = Path('paper/results/rescue_action_explanation_2026_11_18_v1')
    revision = json.loads((rescue / 'revision_checks.json').read_text(encoding='utf-8'))
    for name in ('review.md', 'revision_checks.json', 'final_build_summary.json',
                 revision['evidence_index'], revision['verified_inventory'], revision['audit']):
        add(rescue / name)
    tree((rescue / revision['audit']).parent / 'physical_replay', {'.pddl', '.txt'})
    add(revision['active_manuscript'], revision['manuscript_sha256'])
    for path, receipt in revision['outputs'].items():
        add(path.replace('\\', '/'), receipt['sha256'])
    tree('data/validation/narrafuse_interactive_case_2026_11_16_v1',
         {'.json', '.pddl', '.md', '.txt', '.zip'})
    registry = json.loads(Path('paper/current_evidence.json').read_text(encoding='utf-8'))
    for item in registry['entries']:
        add(item['index'])
        index = json.loads(Path(item['index']).read_text(encoding='utf-8'))
        add(item['original_index'], index['original_index']['sha256'])
        for entry in index['reports'].values():
            add(entry['path'], entry['sha256'])
            p = Path(entry['path']).parent / 'protocol.json'
            if p.is_file():
                add(p)
    files = []
    output.mkdir(parents=True, exist_ok=False)
    archive = output / 'narrafuse_collaborator.zip'
    with zipfile.ZipFile(archive, 'x', zipfile.ZIP_DEFLATED, compresslevel=6) as bundle:
        for path, expected in sorted(selected.items()):
            data = Path(path).read_bytes()
            checksum = digest(data)
            if expected is not None and checksum != expected:
                raise ValueError('Pinned delivery or report changed: ' + path)
            member = Path(path)
            if member.parent == figure_root:
                member = Path('paper/Figures') / member.name
            bundle.writestr(member.as_posix(), data)
            files.append({'path': member.as_posix(), 'bytes': len(data), 'sha256': checksum})
        manifest = {'schema_version': 1, 'scope': 'Compact collaborator code and report bundle',
                    'full_raw_reproduction_bundle': False, 'files': files,
                    'excluded': ['credentials', 'environments', 'model caches', 'raw solver campaign directories',
                                 'historical scratch/recovery archives', 'historical paper PDFs'],
                    'evidence_registry': 'paper/current_evidence.json'}
        content = json.dumps(manifest, indent=2) + '\n'
        bundle.writestr('SHARE_MANIFEST.json', content)
    with zipfile.ZipFile(archive) as bundle:
        for row in files:
            if digest(bundle.read(row['path'])) != row['sha256']:
                raise ValueError('Archive verification failed: ' + row['path'])
    (output / 'manifest.json').write_text(content, encoding='utf-8')
    result = {'files': len(files), 'uncompressed_bytes': sum(r['bytes'] for r in files),
              'archive_bytes': archive.stat().st_size, 'archive_sha256': digest(archive.read_bytes()),
              'verified': True, 'archive': str(archive)}
    (output / 'summary.json').write_text(json.dumps(result, indent=2), encoding='utf-8')
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    print(json.dumps(build(parser.parse_args().output), indent=2))

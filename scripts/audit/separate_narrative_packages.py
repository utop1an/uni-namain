"""Separate the ten preidentified revised packages, retaining every raw byte."""
import argparse
from pathlib import Path
import shutil

from rcnc.domain_building import digest, save
from rcnc.pddl_package import separate_pair, verify_package
from scripts.audit.recheck_human_single_domain import REPO, read, verify

TARGETS = tuple('learned_revised__tiny_stories__story_' + x for x in ('014', '018', '038', '074', '078', '092', '100')) + tuple(
    'learned_revised__writing_prompts__wp_' + x for x in ('057', '084', '091'))


def prepare(output, baseline):
    if output.exists(): raise ValueError('Fresh output required')
    report = read(baseline / 'report.json')
    rows = {r['id']: r for r in report['rows']}
    selected = [rows[key] for key in TARGETS]
    for row in selected:
        assert not row['single_domain_pass'] and 'Expected one PDDL root expression' in row['reason']
        assert digest(Path(row['domain'])) == row['domain_sha256']
        assert digest(Path(row['problem'])) == row['problem_sha256']
    code = [Path(__file__), REPO / 'rcnc/pddl_package.py', REPO / 'tests/test_pddl_package.py',
            REPO / 'rcnc/pddl.py', REPO / 'rcnc/domain_building.py']
    historical = {str(p): digest(p) for p in baseline.rglob('*') if p.is_file()}
    output.mkdir(parents=True)
    for path in code:
        target = output / 'implementation' / path.relative_to(REPO)
        target.parent.mkdir(parents=True, exist_ok=True); shutil.copyfile(path, target)
    save(output / 'protocol.json', {'status': 'frozen_before_extraction', 'target_ids': list(TARGETS),
         'baseline': str(baseline), 'historical_sha256': historical,
         'implementation_sha256': {str(p): digest(p) for p in code}, 'raw_sources': selected,
         'policy': 'Packaging split only; exact model spans, no repair, no plan-derived model facts.'})
    packages = []
    for row in selected:
        package = separate_pair(Path(row['domain']), Path(row['problem']), output / row['id'])
        packages.append({'id': row['id'], **package})
    assert all(verify_package(p) for p in packages)
    verify(historical)
    files = {str(p): digest(p) for p in output.rglob('*') if p.is_file()}
    manifest = {'status': 'verified_lossless_packages', 'registered_rows': len(packages), 'rows': packages,
                'files': files, 'historical_outputs_unchanged': True,
                'model_repairs': 0, 'model_calls': 0, 'search_calls': 0, 'plan_replay_calls': 0}
    save(output / 'manifest.json', manifest)
    return manifest


def load_adapters(manifest_path, registry):
    manifest = read(manifest_path)
    if manifest['status'] != 'verified_lossless_packages': raise ValueError('Unverified package manifest')
    verify(manifest['files'])
    adapters = {r['id']: r for r in manifest['rows']}
    if set(adapters) != set(TARGETS) or len(manifest['rows']) != 10 or manifest['registered_rows'] != 10:
        raise ValueError('Adapter selection differs from the approved ten records')
    registered = {r['id']: r for r in registry}
    for key, adapter in adapters.items():
        verify_package(adapter)
        for kind in ('domain', 'problem'):
            if adapter['sources'][kind]['path'] != registered[key][kind]:
                raise ValueError('Adapter source differs from raw registry')
    return adapters, {str(manifest_path): digest(manifest_path), **manifest['files']}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--baseline', type=Path, required=True)
    args = parser.parse_args()
    result = prepare(args.output.resolve(), args.baseline.resolve())
    print({'status': result['status'], 'packages': len(result['rows']), 'plans': sum(bool(r['plan']) for r in result['rows'])})

"""Hash-bound classical-PDDL admission with explicit header-only packaging."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path

from unified_planning.io import PDDLReader

from rcnc.domain_building import check_raw_declarations, require_empty_output, save
from rcnc.domain_catalog import catalog
from rcnc.domain_union import build as build_union
from rcnc.pddl import parse_domain, parse_sexpr, validate_domain, serialize
from scripts.data.package_external_problem import package


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def audit(snapshot, local_inputs, output, allow_header_packaging=False, allow_parser_name_overlap=False):
    require_empty_output(output)
    manifest_path = snapshot / 'manifest.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    selection_path = snapshot / 'selection.json'
    if manifest['status'] != 'complete' or sha(selection_path) != manifest['selection_sha256']:
        raise ValueError('Incomplete or changed snapshot selection')
    selection = json.loads(selection_path.read_text(encoding='utf-8'))
    expected = set()
    trees = {}
    for provider in manifest['repositories']:
        path = snapshot / provider['id'] / 'tree.json'
        if sha(path) != provider['tree_sha256']:
            raise ValueError('Changed repository tree')
        trees[provider['id']] = {entry['path']: entry for entry in json.loads(path.read_text(encoding='utf-8'))['tree']}
        expected.update((provider['id'], name) for name in provider['metadata'])
    for candidate in selection['candidates']:
        expected.update((candidate['provider'], candidate[key]) for key in ('domain', 'problem'))
    files = {(row['provider'], row['path']): row for row in manifest['files']}
    if len(files) != len(manifest['files']) or set(files) != expected:
        raise ValueError('Snapshot artifact denominator mismatch')
    for (provider, name), row in files.items():
        if Path(name).is_absolute() or '..' in Path(name).parts:
            raise ValueError('Unsafe snapshot artifact path')
        path = snapshot / provider / 'files' / name
        data = path.read_bytes()
        blob = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
        if sha(path) != row['sha256'] or blob != row['git_blob_sha1'] or blob != trees[provider][name]['sha']:
            raise ValueError('Changed artifact: ' + name)
    output.mkdir(parents=True, exist_ok=True)
    (output / 'selection.json').write_bytes(selection_path.read_bytes())
    report = {'status': 'running', 'candidate_count': len(selection['candidates']), 'rows': [],
        'snapshot_manifest_sha256': sha(manifest_path), 'selection_sha256': sha(selection_path),
        'admission_policy': 'Unchanged source domain; optional header-only problem packaging; structural checks, independent parsing, namespaced compilation; no solver or model outcomes',
        'header_packaging_enabled': allow_header_packaging,
        'parser_name_overlap_diagnostic_enabled': allow_parser_name_overlap,
        'independent_semantic_labels': 0, 'planner_called': False,
        'implementation_sha256': {str(p): sha(p) for p in (Path(__file__),
            Path('rcnc/domain_union.py'), Path('rcnc/domain_catalog.py'), Path('rcnc/pddl.py'),
            Path('rcnc/domain_building.py'), Path('scripts/data/package_external_problem.py'))}}
    local = {str(p): sha(p) for p in sorted(local_inputs.glob('*.pddl'))}
    report['local_sha256'] = local
    admitted = output / 'annotation_inputs'
    admitted.mkdir()
    providers = {p['id']: p for p in selection['repositories']}
    for candidate in selection['candidates']:
        key, provider = candidate['id'], candidate['provider']
        directory = output / 'cases' / key
        directory.mkdir(parents=True)
        inputs = directory / 'inputs'
        inputs.mkdir()
        domain = snapshot / provider / 'files' / candidate['domain']
        problem = snapshot / provider / 'files' / candidate['problem']
        target_domain = inputs / (key + '_domainfile.pddl')
        target_problem = inputs / (key + '_problemfile.pddl')
        target_domain.write_bytes(domain.read_bytes())
        target_problem.write_bytes(problem.read_bytes())
        row = {**candidate, 'status': 'checking', 'lineage': providers[provider]['lineage'],
            'domain_sha256': sha(domain), 'problem_sha256': sha(problem),
            'source_urls': {k: files[(provider, candidate[k])]['url'] for k in ('domain', 'problem')},
            'exact_local_domain_matches': [name for name, value in local.items() if value == sha(domain)],
            'story_overlap': 'not established by byte screening; no pristine held-out claim',
            'learning_run_provenance': 'Repository-level description only; exact model/prompt/seed/training history unknown',
            'independent_source_lineage_claim': False, 'packaging': {'status': 'unchanged'}}
        try:
            domain_ast = parse_sexpr(domain.read_text(encoding='utf-8'))
            problem_ast = parse_sexpr(problem.read_text(encoding='utf-8'))
            check_raw_declarations(domain_ast, str(domain))
            check_raw_declarations(problem_ast, str(problem))
            errors = validate_domain(parse_domain(target_domain))
            if errors:
                raise ValueError('Source structural errors: ' + str(errors))
            catalog(inputs)
            if allow_header_packaging:
                packaged, changes = package(domain_ast, problem_ast)
                if packaged != problem_ast:
                    target_problem.write_text(serialize(packaged) + '\n', encoding='utf-8')
                row['packaging'] = {'status': 'header_only_policy_checked', 'changes': changes,
                    'domain_bytes_unchanged': sha(target_domain) == sha(domain),
                    'packaged_problem_sha256': sha(target_problem)}
            try:
                PDDLReader().parse_problem(str(target_domain), str(target_problem))
                row['original_parser'] = {'status': 'parsed_default_policy'}
            except Exception as exc:
                row['original_parser'] = {'status': 'rejected_default_policy',
                    'error': f'{type(exc).__name__}: {exc}'}
                if not allow_parser_name_overlap or 'already defined' not in str(exc):
                    raise
                # Dedicated environment only; domain and world bytes unchanged.
                from unified_planning.environment import Environment
                environment = Environment()
                environment.error_used_name = False
                PDDLReader(environment=environment).parse_problem(str(target_domain), str(target_problem))
                row['original_parser']['diagnostic'] = 'same_bytes_parsed_with_error_used_name_false'
            compiled = build_union(inputs, directory / 'union')
            if not compiled['valid']:
                raise ValueError('Mapped problem failed independent parsing: ' + str(compiled['problems']))
            row.update(status='admitted_compatibility_only', counts=compiled['counts'],
                limit='No semantic fidelity, narrative quality, plan success or learned-domain generalization established')
            if candidate['annotation_selected']:
                (admitted / target_domain.name).write_bytes(target_domain.read_bytes())
        except Exception as exc:
            row.update(status='not_admitted', error=f'{type(exc).__name__}: {exc}')
            row['failure_category'] = ('parser_name_policy' if 'already defined' in str(exc)
                                       else 'unsupported_or_structural_source')
        report['rows'].append(row)
        save(output / 'report.json', report)
    report.update(status='complete', counts=dict(Counter(row['status'] for row in report['rows'])),
        annotation_selected_admitted=[r['id'] for r in report['rows']
            if r['status'] == 'admitted_compatibility_only' and r['annotation_selected']],
        missing_artifact_lead=selection['missing_artifact_lead'],
        scope='Compatibility admission and annotation-pilot inputs; auxiliary classical domains are not narrative evidence. No outcome-driven repairs or best-run selection.')
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--snapshot', type=Path, required=True)
    parser.add_argument('--local-inputs', type=Path, default=Path('data/narra-domains'))
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--allow-header-packaging', action='store_true')
    parser.add_argument('--allow-parser-name-overlap', action='store_true',
                        help='Diagnose default UP name-policy rejection in a dedicated environment; no PDDL edits')
    args = parser.parse_args()
    result = audit(args.snapshot, args.local_inputs, args.output, args.allow_header_packaging,
                   args.allow_parser_name_overlap)
    print(json.dumps({k: v for k, v in result.items() if k not in ('rows', 'local_sha256', 'implementation_sha256')}, indent=2))

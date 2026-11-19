"""Fixed-denominator coverage audit of authored, learned and legacy narratives.

No new model calls, planning, source repairs or fallback between learned variants.
"""
import argparse
from collections import Counter, defaultdict
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import shutil

from rcnc.domain_building import digest, save
from rcnc.glaive_intake import constant_contract, feature_inventory, read_tree
from rcnc.glaive_merge import Source, build, map_problem
from rcnc.glaive_runtime import invoke
from rcnc.pddl import serialize
from scripts.audit.recheck_human_single_domain import REPO, read, verify
from scripts.audit.separate_narrative_packages import load_adapters

HUMAN = REPO / 'data/human_narrative_domains_2026_11_04_v1'
HUMAN_RESULT = REPO / 'data/validation/human_single_domain_round2_2026_11_05_v3'
LEARNED = REPO / 'data/external/there_and_back_gpt4_revised_2026_11_01_v1'
LEGACY = REPO / 'data/narra-domains'
RELEASE = REPO / 'data/research_release/icaps2027_2026_11_03'


def registry():
    rows = []
    for row in read(HUMAN_RESULT / 'report.json')['rows']:
        rows.append({'id': 'human__' + row['id'], 'pool': 'human', 'collection': row['collection'],
                     'domain': str(HUMAN / row['domain']), 'problem': str(HUMAN / row['problem']),
                     'baseline_id': row['id'], 'provenance': 'authored_narrative_collection'})
    for variant in ('revised', 'original'):
        for source in read(LEARNED / 'protocol.json')['sources']:
            folder = LEARNED / 'upstream/results/runs' / source['upstream_id']
            rows.append({'id': 'learned_' + variant + '__' + source['id'], 'pool': 'learned_' + variant,
                         'story_id': source['id'], 'collection': source['upstream_id'].split('/')[0],
                         'domain': str(folder / (variant + '-domain.pddl')),
                         'problem': str(folder / (variant + '-problem.pddl')),
                         'historical_split': source['split'], 'provenance': 'pinned_upstream_gpt4_story_record'})
    for domain in sorted(LEGACY.glob('*_domainfile.pddl')):
        stem = domain.name.removesuffix('_domainfile.pddl')
        rows.append({'id': 'legacy__' + stem, 'pool': 'legacy_unverified', 'collection': 'legacy_narra',
                     'domain': str(domain), 'problem': str(LEGACY / (stem + '_problemfile.pddl')),
                     'provenance': 'local_custody_only_learning_origin_unverified'})
    expected = {'human': 113, 'learned_revised': 192, 'learned_original': 192, 'legacy_unverified': 15}
    if dict(Counter(r['pool'] for r in rows)) != expected or len({r['id'] for r in rows}) != 512:
        raise ValueError('Registry denominator changed')
    return rows


def summarize(rows):
    """Each pool has its own denominator; variants are never pooled as stories."""
    domains = defaultdict(list)
    for row in rows:
        domains[row['domain']].append(row)
    admitted = [r for r in rows if r['single_domain_pass']]
    nonempty = [r for r in rows if r.get('domain_bytes', 0)]
    return {'pairs': len(rows), 'raw_parsed': sum(r['native']['status'] == 'parsed' for r in rows),
            'exported': sum(r['conversion'] == 'exported' for r in rows), 'passed': len(admitted),
            'pass_percent': round(100 * len(admitted) / len(rows), 2) if rows else None,
            'status_counts': dict(Counter(r['status'] for r in rows)),
            'native_status_counts': dict(Counter(r['native']['status'] for r in rows)),
            'domain_files': len(domains),
            'admitted_domain_files': len({r['domain'] for r in admitted}),
            'all_problem_passed_domain_files': sum(all(r['single_domain_pass'] for r in rs) for rs in domains.values()),
            'nonempty_unique_raw_domain_hashes': len({r['domain_sha256'] for r in nonempty}),
            'admitted_unique_raw_domain_hashes': len({r['domain_sha256'] for r in admitted}),
            'admitted_unique_canonical_syntax': len({r['canonical_domain_sha256'] for r in admitted}),
            'passed_with_constant_completion': sum(bool(r['constant_contract']) for r in admitted),
            'rejection_reasons': dict(Counter(r.get('reason', r['status']) for r in rows if not r['single_domain_pass']))}


def prepare(output, baseline=None, jar=None, source_adapters=None, priority1=False):
    if output.exists(): raise ValueError('Fresh output required')
    rows = registry()
    if baseline is not None:
        previous = read(baseline / 'report.json')
        assert [(r['id'], r['domain'], r['problem']) for r in rows] == [(r['id'], r['domain'], r['problem']) for r in previous['rows']]
    adapter_hashes = {}
    if priority1:
        if baseline is None: raise ValueError('Priority-one comparison requires a frozen baseline')
        for row in rows:
            if row['id'] in {'human__case_019', 'human__case_112'}:
                row['consent_policy'] = 'require_intentional_agents'
    if source_adapters is not None:
        if baseline is None: raise ValueError('Adapted coverage requires a frozen baseline')
        adapters, adapter_hashes = load_adapters(source_adapters, rows)
        for row in rows:
            if row['id'] not in adapters: continue
            adapter = adapters[row['id']]
            row.update(effective_domain=adapter['effective_domain'], effective_problem=adapter['effective_problem'],
                       packaging_adapter={'manifest': str(source_adapters), 'sha256': digest(source_adapters),
                                          'plan': adapter['plan'], 'plan_validation': adapter['plan_validation'],
                                          'model_repairs': 0, 'lossless_verified': True})
    # Verify all downloaded artifacts, including raw story texts and metadata.
    upstream = {str(LEARNED / 'upstream' / r['path']): r['sha256'] for r in read(LEARNED / 'download_report.json')['files']}
    upstream.update({str(HUMAN / r['local_path']): r['sha256'] for r in read(HUMAN / 'manifest.json')['files']})
    provenance = REPO / 'data/validation/source_provenance_2026_10_15_v1/report.json'
    for row in read(provenance)['rows']:
        upstream.update({str(REPO / f['path']): f['sha256'] for f in row['files']})
    verify(upstream)
    old = read(HUMAN_RESULT / 'protocol.json')
    output.mkdir(parents=True)
    implementation = [Path(__file__), REPO / 'scripts/audit/recheck_human_single_domain.py']
    implementation += [REPO / 'rcnc' / name for name in ('glaive_merge.py', 'glaive_intake.py', 'pddl.py', 'glaive_runtime.py', 'conditional_merge.py', 'domain_building.py')]
    implementation += [REPO/'tests/test_glaive_problem_language.py', REPO/'tests/test_narrative_coverage.py',
                       REPO/'scripts/audit/summarize_narrative_coverage.py', REPO/'scripts/audit/separate_narrative_packages.py',
                       REPO/'rcnc/pddl_package.py', REPO/'tests/test_pddl_package.py']
    if priority1:
        implementation += [REPO/'tests/test_glaive_priority1.py', REPO/'scripts/java/GlaivePriorityOneRegression.java',
                           REPO/'scripts/audit/check_glaive_priority1.py']
    for path in implementation:
        target = output / 'implementation' / path.relative_to(REPO)
        target.parent.mkdir(parents=True, exist_ok=True); shutil.copyfile(path, target)
    histories = [HUMAN_RESULT / 'report.json', HUMAN_RESULT / 'verification.json', HUMAN_RESULT / 'constant_contracts.json',
                 LEARNED / 'protocol.json', LEARNED / 'intake_report.json', LEARNED / 'download_report.json',
                 provenance, REPO / 'data/validation/revised_native_admission_2026_11_01_v1/report.json',
                 REPO / 'data/validation/human_language_traces_2026_11_05_v1/report.json',
                 REPO / 'data/validation/story_opportunities_audit_2026_10_31_v1/report.json',
                 REPO / 'data/validation/revised_multistory_repeat01_paper_eval_2026_11_03_v1/analysis.json']
    histories += [RELEASE / name for name in ('sources.json', 'native_results.json', 'transport_results.json', 'manifest.json')]
    histories += list((HUMAN_RESULT / 'verified_snapshot').glob('*'))
    if baseline is not None: histories += [p for p in baseline.rglob('*') if p.is_file()]
    selected_jar = jar if jar is not None else Path(old['jar'])
    if jar is not None:
        runtime_report = read(jar.parent/'report.json')
        assert runtime_report['status'] == 'verified' and digest(jar) == runtime_report['jar_sha256']
        histories += [p for p in jar.parent.rglob('*') if p.is_file()]
    if priority1:
        checks = REPO / 'data/validation/priority1_language_checks_2026_11_05_v1'
        receipt = read(checks / 'report.json')
        assert receipt['status'] == 'verified' and receipt['runtime_sha256'] == digest(selected_jar)
        verify(read(checks / 'protocol.json')['sha256'])
        histories += [p for p in checks.rglob('*') if p.is_file()]
    histories = sorted(set(histories))
    inputs = {str(p.resolve()): digest(p) for p in [*implementation, *histories, selected_jar, Path(old['classes']) / 'GlaiveProbe.class']}
    inputs.update(upstream)
    inputs.update(adapter_hashes)
    protocol = {'status': 'frozen_before_conversion_and_parse', 'created_utc': datetime.now(timezone.utc).isoformat(),
                'rows': rows, 'registered_rows': 512, 'pool_counts': dict(Counter(r['pool'] for r in rows)),
                'primary_pools': ['human', 'learned_revised'], 'supplemental_pools': ['learned_original', 'legacy_unverified'],
                'jar': str(selected_jar), 'classes': old['classes'], 'inspect_seconds': 10, 'memory_mb': 4096, 'attempts': 1, 'workers': 1,
                'baseline': str(baseline) if baseline is not None else None,
                'source_adapters': str(source_adapters) if source_adapters is not None else None,
                'packaging_adapted_rows': [r['id'] for r in rows if 'packaging_adapter' in r],
                'priority1': {'enabled': priority1, 'scope': ['reflexive type declarations', 'explicit consent role interpretation'],
                             'consent_rows': [r['id'] for r in rows if 'consent_policy' in r],
                             'finite_checks': str(checks / 'report.json') if priority1 else None,
                             'consent_interpretation': 'Opt-in union of acting and consenting roles as required intentional agents. Native reader ignores consent; no equivalence to that behavior.',
                             'excluded': ['undeclared symbol repair', 'arity repair', 'full diagnostic collection', 'expression variables', 'belief/delegation', 'missing-output reconstruction']},
                'runtime_condition': 'separately_versioned_intention_reader_and_quantified_state_fix' if jar is not None else old['runtime_condition'],
                'sha256': inputs, 'historical_sha256': {str(p): digest(p) for p in histories},
                'policies': ['All 113 authored pairs, all 192 public learned stories in each variant, and all 15 legacy local pairs.',
                             'Original and revised outputs reported separately; no fallback or pooling into independent-story counts.',
                             'Legacy 15 have unverified origin, not included as confirmed story-learned or human-authored sources.',
                             'No new model-content repair, learning, model request, planner search or plan replay; native parse only.',
                             'Optional frozen packaging adapters extract exact model byte spans only for the ten selected records; plans and notes never enter conversion. Raw registry and raw native inspections remain unchanged.',
                             'Explicit constant completion from unanimous object declarations of every registered problem for each domain.',
                             'Explicit problem :intentionality declarations mapped to initial intends literals; dialect interpretation recorded, not equivalence to the stock reader which ignored the section.',
                             'Every empty, malformed, unsupported or limited row retained. Explicit source worlds stay separate.',
                             'Historical planning/transport evidence labeled as historical with its own tested-source denominator.',
                             'Parser inspection of historical test-split records is descriptive; no new held-out generalization claim.']}
    save(output / 'protocol.json', protocol)
    (output / 'PROTOCOL.sha256').write_text(digest(output / 'protocol.json') + '\n', encoding='utf-8')
    by_domain = defaultdict(list)
    for row in rows: by_domain[row['domain']].append(row)
    contracts = {}
    for index, (domain, domain_rows) in enumerate(sorted(by_domain.items())):
        entry = {'source_id': f'coverage_{index:03d}', 'constant_contract': {}, 'status': 'checked'}
        effective_domains = {r.get('effective_domain', r['domain']) for r in domain_rows}
        if len(effective_domains) != 1: raise ValueError('Inconsistent domain adapters across registered problems')
        problems = {r.get('effective_problem', r['problem']) for r in domain_rows}
        try: entry['constant_contract'] = constant_contract(Path(next(iter(effective_domains))), [Path(p) for p in sorted(problems)])
        except (ValueError, TypeError, IndexError, KeyError) as exc: entry.update(status='unavailable', reason=str(exc))
        contracts[domain] = entry
    historical_contracts = read(HUMAN_RESULT / 'constant_contracts.json')
    for domain, entry in historical_contracts.items():
        assert contracts[str(HUMAN / domain)]['constant_contract'] == entry['constant_contract']
    save(output / 'constant_contracts.json', contracts)
    for row in rows:
        target = output / row['id']; target.mkdir()
        domain, problem = Path(row['domain']), Path(row['problem'])
        contract = contracts[row['domain']]
        row.update(source_id=contract['source_id'], constant_contract=contract['constant_contract'],
                   domain_sha256=digest(domain), problem_sha256=digest(problem),
                   domain_bytes=domain.stat().st_size, problem_bytes=problem.stat().st_size)
        row['missing_or_empty'] = not row['domain_bytes'] or not row['problem_bytes']
        if 'packaging_adapter' in row:
            domain, problem = Path(row['effective_domain']), Path(row['effective_problem'])
            row.update(effective_domain_sha256=digest(domain), effective_problem_sha256=digest(problem))
        try:
            if row['missing_or_empty']: raise ValueError('Empty source domain or problem')
            root, task = read_tree(domain), read_tree(problem)
            row['features'] = feature_inventory(root, task)
            row['canonical_domain_sha256'] = hashlib.sha256(serialize(root).encode('utf-8')).hexdigest()
            source = Source(row['source_id'], domain, problem, constant_contract=row['constant_contract'], consent_policy=row.get('consent_policy'))
            meta = build([source], target / 'model')
            map_problem([source], source.id, meta, target / 'model/problem.pddl')
            row.update(conversion='exported', exported_domain_sha256=digest(target / 'model/domain.pddl'))
        except (ValueError, TypeError, IndexError, KeyError) as exc:
            row.update(conversion='rejected', reason=str(exc), error_type=type(exc).__name__)
    save(output / 'conversion.json', {'rows': rows})
    generated = [p for p in output.glob('*__*/model/*') if p.is_file()]
    generated += [output / 'conversion.json', output / 'constant_contracts.json']
    save(output / 'conversion_hashes.json', {str(p): digest(p) for p in generated})
    verify(inputs)
    return {'registered_rows': len(rows), 'conversion': {pool: dict(Counter(r['conversion'] for r in rows if r['pool'] == pool)) for pool in protocol['pool_counts']}}


def execute(output):
    if (output / 'progress.json').exists() or (output / 'report.json').exists(): raise ValueError('Fresh execution required')
    p = read(output / 'protocol.json'); hashes = read(output / 'conversion_hashes.json')
    assert digest(output / 'protocol.json') == (output / 'PROTOCOL.sha256').read_text(encoding='utf-8').strip()
    verify(p['sha256']); verify(hashes)
    rows = read(output / 'conversion.json')['rows']
    control = next(r for r in rows if r['id'] == 'human__case_017')
    preflight = invoke(Path(p['jar']), Path(control['domain']), Path(control['problem']), output / 'runtime_preflight',
                       mode='inspect', seconds=10, classes=Path(p['classes']))
    if preflight['status'] != 'parsed': raise ValueError('Native runtime preflight failed')
    for n, row in enumerate(rows, 1):
        target = output / row['id']
        if row['missing_or_empty']: row['native'] = {'status': 'empty_source', 'search_calls': 0}
        else:
            row['native'] = invoke(Path(p['jar']), Path(row['domain']), Path(row['problem']), target / 'native_inspect',
                                   mode='inspect', seconds=10, classes=Path(p['classes']))
        if row['conversion'] == 'exported':
            row['converted_native'] = invoke(Path(p['jar']), target / 'model/domain.pddl', target / 'model/problem.pddl',
                                             target / 'converted_inspect', mode='inspect', seconds=10, classes=Path(p['classes']))
        row['single_domain_pass'] = row.get('converted_native', {}).get('status') == 'parsed'
        row['status'] = ('source_empty' if row['missing_or_empty'] else 'export_rejected' if row['conversion'] != 'exported'
                         else 'export_parse_pass' if row['single_domain_pass'] else 'export_parse_failure')
        save(target / 'row.json', row)
        save(output / 'progress.json', {'completed': n, 'registered': len(rows), 'last': row['id']})
        print(n, row['id'], row['native']['status'], row['status'], flush=True)
    previous = {r['id']: r for r in read(HUMAN_RESULT / 'report.json')['rows']}
    human_consistent = all(r['single_domain_pass'] == previous[r['baseline_id']]['single_domain_pass'] and
                           r['native']['status'] == previous[r['baseline_id']]['native']['status'] for r in rows if r['pool'] == 'human')
    comparison = {}
    if p.get('baseline'):
        baseline_rows = {r['id']: r for r in read(Path(p['baseline'])/'report.json')['rows']}
        for pool in p['pool_counts']:
            selected = [r for r in rows if r['pool'] == pool]
            comparison[pool] = {'baseline_passed': sum(baseline_rows[r['id']]['single_domain_pass'] for r in selected),
                                'newly_passed': [r['id'] for r in selected if r['single_domain_pass'] and not baseline_rows[r['id']]['single_domain_pass']],
                                'regressed': [r['id'] for r in selected if not r['single_domain_pass'] and baseline_rows[r['id']]['single_domain_pass']],
                                'raw_status_changes': [{'id':r['id'], 'before':baseline_rows[r['id']]['native']['status'], 'after':r['native']['status']} for r in selected if r['native']['status'] != baseline_rows[r['id']]['native']['status']]}
    report = {'status': 'complete', 'registered_rows': len(rows), 'rows': rows,
              'counts': dict(Counter(r['status'] for r in rows)),
              'pools': {pool: summarize([r for r in rows if r['pool'] == pool]) for pool in p['pool_counts']},
              'by_collection': {pool: {c: summarize([r for r in rows if r['pool'] == pool and r['collection'] == c])
                                     for c in sorted({r['collection'] for r in rows if r['pool'] == pool})} for pool in p['pool_counts']},
              'human_matches_round2': human_consistent, 'inputs_unchanged': verify(p['sha256']),
              'comparison': comparison, 'no_admission_regressions': all(not x['regressed'] for x in comparison.values()),
              'packaging_adapted_rows': p.get('packaging_adapted_rows', []),
              'historical_outputs_unchanged': verify(p['historical_sha256']), 'exports_unchanged': verify(hashes),
              'model_calls': 0, 'search_calls': 0, 'plan_replay_calls': 0,
              'scope': 'Local narrative-source inventory coverage. Parse admission only, no independent semantic labels; variants and legacy origin remain separate.'}
    save(output / 'report.json', report)
    return {k: report[k] for k in ('status', 'registered_rows', 'pools', 'human_matches_round2')}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['prepare', 'execute'])
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--baseline', type=Path)
    parser.add_argument('--jar', type=Path)
    parser.add_argument('--source-adapters', type=Path)
    parser.add_argument('--priority1', action='store_true')
    args = parser.parse_args()
    result = prepare(args.output.resolve(), args.baseline.resolve() if args.baseline else None, args.jar.resolve() if args.jar else None,
                     args.source_adapters.resolve() if args.source_adapters else None, args.priority1) if args.mode == 'prepare' else execute(args.output.resolve())
    print(json.dumps(result, ensure_ascii=False, indent=2))

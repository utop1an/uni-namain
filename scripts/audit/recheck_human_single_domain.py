"""Frozen 113-pair compatibility recheck; no search or semantic judgments."""
import argparse
from collections import Counter, defaultdict
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import shutil

from rcnc.domain_building import digest, save
from rcnc.glaive_intake import constant_contract, read_tree, feature_inventory
from rcnc.glaive_merge import Source, build, map_problem
from rcnc.glaive_runtime import invoke
from rcnc.pddl import serialize

REPO = Path(__file__).resolve().parents[2]
COLLECTION = REPO / 'data/human_narrative_domains_2026_11_04_v1'
BASELINE = REPO / 'data/validation/human_single_domain_2026_11_04_v3'


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def verify(hashes):
    changed = [name for name, value in hashes.items() if not Path(name).is_file() or digest(Path(name)) != value]
    if changed:
        raise ValueError('Frozen files changed: ' + ', '.join(changed[:10]))
    return True


def prepare(output, baseline=BASELINE):
    if output.exists():
        raise ValueError('Fresh output required')
    baseline = baseline.resolve()
    old = read(baseline / 'protocol.json')
    previous = read(baseline / 'report.json')
    pairs = old['pairs']
    if len(pairs) != 113 or [(x['id'], x['domain'], x['problem']) for x in pairs] != [
            (x['id'], x['domain'], x['problem']) for x in previous['rows']]:
        raise ValueError('Baseline pairing/denominator mismatch')
    raw_files = [COLLECTION / row['local_path'] for row in read(COLLECTION / 'manifest.json')['files']]
    # Check the original download inventory, then pin every historical output.
    for row in read(COLLECTION / 'manifest.json')['files']:
        if digest(COLLECTION / row['local_path']) != row['sha256']:
            raise ValueError('Original download changed: ' + row['local_path'])
    historical = [p for folder in sorted((REPO / 'data/validation').glob('human_single_domain*'))
                  for p in folder.rglob('*') if p.is_file()]
    implementation = [REPO / 'rcnc' / n for n in
                      ['glaive_intake.py', 'glaive_merge.py', 'pddl.py', 'glaive_runtime.py',
                       'conditional_merge.py', 'domain_building.py']]
    implementation += [Path(__file__), REPO / 'tests/test_glaive_intake.py', REPO / 'tests/test_glaive_merge.py']
    implementation += [REPO / 'tests/test_glaive_quantifiers_axioms.py']
    output.mkdir(parents=True)
    for path in implementation:
        target = output / 'implementation' / path.relative_to(REPO)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(path, target)
    by_domain = defaultdict(list)
    for row in pairs:
        by_domain[row['domain']].append(row)
    contracts = {}
    for index, (domain, rows) in enumerate(sorted(by_domain.items())):
        entry = {'source_id': f'src_{index:03d}', 'domain': domain,
                 'problems': sorted({r['problem'] for r in rows}), 'constant_contract': {}}
        try:
            entry['constant_contract'] = constant_contract(COLLECTION / domain,
                                                          [COLLECTION / p for p in entry['problems']])
            entry['status'] = 'checked_all_registered_problem_declarations'
        except (ValueError, TypeError, IndexError) as exc:
            entry.update(status='unavailable', reason=str(exc))
        contracts[domain] = entry
    save(output / 'constant_contracts.json', contracts)
    files = [*raw_files, *implementation, COLLECTION / 'manifest.json', COLLECTION / 'structural_inventory.json',
             Path(old['jar']), Path(old['classes']) / 'GlaiveProbe.class', output / 'constant_contracts.json']
    protocol = {'status': 'frozen_before_conversion_and_parse', 'created_utc': datetime.now(timezone.utc).isoformat(),
                'baseline': str(baseline), 'collection': str(COLLECTION), 'pairs': pairs,
                'domain_files': len(by_domain), 'problem_files': len({r['problem'] for r in pairs}),
                'jar': old['jar'], 'classes': old['classes'], 'inspect_seconds': old['inspect_seconds'],
                'runtime_condition': old['runtime_condition'], 'attempts': 1, 'workers': 1,
                'runtime_preflight': 'One separate raw Heist inspect before the 113 registered rows; must parse.',
                'sha256': {str(p.resolve()): digest(p) for p in files},
                'historical_sha256': {str(p.resolve()): digest(p) for p in historical},
                'policies': ['Same 113 baseline pairs, including every failure and duplicate-source variant.',
                             'Case normalization, problem requirements, complete type graph, explicit constant contracts.',
                             'Object quantifiers and native axioms exported with source-local membership and activity guards.',
                             'Binding-safe substitution; quantified effects and axiom-source actions retained rather than fused.',
                             'Constants completed only from unanimous explicit declarations across all registered tasks for that domain.',
                             'One stable source identifier and reusable domain artifact per domain path; each source world mapped separately.',
                             'Raw native parsing repeated; no source repair, pooled facts, model calls, search or plan replay.',
                             'Exported parse success is admission evidence only, not semantic or plan-preservation evidence.'],
                'model_calls': 0, 'search_calls': 0, 'plan_replay_calls': 0}
    save(output / 'protocol.json', protocol)
    (output / 'PROTOCOL.sha256').write_text(digest(output / 'protocol.json') + '\n', encoding='utf-8')
    rows = []
    for case in pairs:
        target = output / case['id']
        target.mkdir()
        contract = contracts[case['domain']]
        row = {**case, 'source_id': contract['source_id'], 'constant_contract': contract['constant_contract'],
               'contract_status': contract['status']}
        row['features'] = feature_inventory(read_tree(COLLECTION / case['domain']), read_tree(COLLECTION / case['problem']))
        try:
            source = Source(contract['source_id'], COLLECTION / case['domain'], COLLECTION / case['problem'],
                            constant_contract=contract['constant_contract'])
            save(target / 'normalization.json', source.normalization)
            meta = build([source], target / 'model')
            map_problem([source], source.id, meta, target / 'model/problem.pddl')
            row.update(conversion='exported', normalization=source.normalization,
                       exported_domain_sha256=digest(target / 'model/domain.pddl'),
                       canonical_source_sha256=hashlib.sha256(serialize(source.root).encode('utf-8')).hexdigest(),
                       domain_name=source.domain.name)
        except (ValueError, TypeError, IndexError, KeyError) as exc:
            row.update(conversion='rejected', error_type=type(exc).__name__, reason=str(exc))
        rows.append(row)
    save(output / 'conversion.json', {'rows': rows, 'counts': dict(Counter(r['conversion'] for r in rows))})
    generated = [p for p in output.glob('case_*/*/*') if p.is_file()]
    generated += [output / 'conversion.json', *output.glob('case_*/normalization.json')]
    save(output / 'conversion_hashes.json', {str(p.resolve()): digest(p) for p in generated})
    verify(protocol['sha256'])
    verify(protocol['historical_sha256'])
    return {'pairs': len(rows), 'counts': dict(Counter(r['conversion'] for r in rows)),
            'reasons': dict(Counter(r.get('reason', 'exported') for r in rows))}


def execute(output):
    if (output / 'report.json').exists() or (output / 'progress.json').exists():
        raise ValueError('Execution already started; use a fresh run for any retry')
    if digest(output / 'protocol.json') != (output / 'PROTOCOL.sha256').read_text(encoding='utf-8').strip():
        raise ValueError('Protocol changed')
    p = read(output / 'protocol.json')
    generated = read(output / 'conversion_hashes.json')
    verify(p['sha256']); verify(p['historical_sha256']); verify(generated)
    rows = read(output / 'conversion.json')['rows']
    control = next(r for r in rows if r['id'] == 'case_017')
    preflight = invoke(Path(p['jar']), COLLECTION / control['domain'], COLLECTION / control['problem'],
                       output / 'runtime_preflight', mode='inspect', seconds=p['inspect_seconds'], classes=Path(p['classes']))
    if preflight['status'] != 'parsed':
        raise ValueError('Runtime preflight failed; registered parser matrix not started')
    for row in rows:
        target = output / row['id']
        row['native'] = invoke(Path(p['jar']), COLLECTION / row['domain'], COLLECTION / row['problem'],
                               target / 'native_inspect', mode='inspect', seconds=p['inspect_seconds'], classes=Path(p['classes']))
        if row['conversion'] == 'exported':
            row['converted_native'] = invoke(Path(p['jar']), target / 'model/domain.pddl', target / 'model/problem.pddl',
                                             target / 'converted_inspect', mode='inspect', seconds=p['inspect_seconds'], classes=Path(p['classes']))
        row['single_domain_pass'] = row['conversion'] == 'exported' and row.get('converted_native', {}).get('status') == 'parsed'
        print(row['id'], row['collection'], row['conversion'], row['native']['status'],
              row.get('converted_native', {}).get('status'), flush=True)
        save(output / 'progress.json', {'completed': sum('single_domain_pass' in r for r in rows), 'rows': rows})
    previous = {r['id']: r for r in read(Path(p['baseline']) / 'report.json')['rows']}
    domains = []
    for name in sorted({r['domain'] for r in rows}):
        cases = [r for r in rows if r['domain'] == name]
        passed = [r for r in cases if r['single_domain_pass']]
        exported = [r for r in cases if r['conversion'] == 'exported']
        domains.append({'domain': name, 'collection': cases[0]['collection'],
                        'raw_sha256': digest(COLLECTION / name), 'registered_pairs': len(cases),
                        'passed_pairs': len(passed), 'all_pairs_passed': len(passed) == len(cases),
                        'baseline_passed_pairs': sum(previous[r['id']]['single_domain_pass'] for r in cases),
                        'source_id': cases[0]['source_id'], 'constant_contract': cases[0]['constant_contract'],
                        'canonical_source_sha256': passed[0]['canonical_source_sha256'] if passed else None,
                        'domain_name': passed[0]['domain_name'] if passed else None,
                        'reusable_export_identical': len({r['exported_domain_sha256'] for r in exported}) == 1 if exported else None,
                        'cases': [r['id'] for r in cases]})
    admitted = [d for d in domains if d['passed_pairs']]
    report = {'status': 'complete', 'pairs': len(rows), 'rows': rows,
              'inputs_unchanged': verify(p['sha256']), 'historical_outputs_unchanged': verify(p['historical_sha256']),
              'exports_unchanged': verify(generated),
              'counts': {'exported': sum(r['conversion'] == 'exported' for r in rows),
                         'passed': sum(r['single_domain_pass'] for r in rows),
                         'not_passed': sum(not r['single_domain_pass'] for r in rows)},
              'comparison': {'baseline_passed': sum(r['single_domain_pass'] for r in previous.values()),
                             'newly_passed': [r['id'] for r in rows if r['single_domain_pass'] and not previous[r['id']]['single_domain_pass']],
                             'regressed': [r['id'] for r in rows if not r['single_domain_pass'] and previous[r['id']]['single_domain_pass']]},
              'domain_counts': {'registered_files': len(domains), 'baseline_admitted_files': sum(d['baseline_passed_pairs'] > 0 for d in domains),
                                'admitted_files': len(admitted), 'all_problems_passed_files': sum(d['all_pairs_passed'] for d in admitted),
                                'admitted_unique_raw_hashes': len({d['raw_sha256'] for d in admitted}),
                                'admitted_unique_canonical_syntax': len({d['canonical_source_sha256'] for d in admitted}),
                                'independent_family_count': 'not_established_by_syntax_deduplication'},
              'by_collection': {c: {'pairs': sum(r['collection'] == c for r in rows),
                                    'exported': sum(r['collection'] == c and r['conversion'] == 'exported' for r in rows),
                                    'baseline_passed': sum(r['collection'] == c and r['single_domain_pass'] for r in previous.values()),
                                    'passed': sum(r['collection'] == c and r['single_domain_pass'] for r in rows),
                                    'admitted_domain_files': sum(d['collection'] == c for d in admitted)}
                                for c in sorted({r['collection'] for r in rows})},
              'rejection_reasons': dict(Counter(r.get('reason', 'exported_' + r.get('converted_native', {}).get('status', 'not_run'))
                                                for r in rows if not r['single_domain_pass'])),
              'domains': domains, 'all_exported_domains_reusable': all(d['reusable_export_identical'] is not False for d in domains),
              'model_calls': 0, 'search_calls': 0, 'plan_replay_calls': 0, 'semantic_validation': 'not_performed'}
    save(output / 'report.json', report)
    save(output / 'admitted_domains.json', {'scope': 'Single-domain parse admission only; preserve original explicit worlds', 'domains': admitted})
    lines = ['# 单域语言兼容性复查（2026-11-05）', '',
             '比较基线：' + p['baseline'],
             '固定沿用全部 113 个配对。原始文件和历史输出哈希核对通过。每次解析 10 秒、一次尝试、单 worker；本解析矩阵无模型调用、搜索或计划回放。', '',
             '支持范围：大小写、problem requirements、多父类型、显式常量补全、来源范围内的对象量词与原生 Glaive 公理。带公理的来源保留原动作，未扩展动作融合证明。', '',
             '| 来源 | 配对 | 导出 | 上轮解析通过 | 本轮解析通过 | 通过的 domain 文件 |', '|---|---:|---:|---:|---:|---:|']
    for c, x in report['by_collection'].items():
        lines.append(f"| {c} | {x['pairs']} | {x['exported']} | {x['baseline_passed']} | {x['passed']} | {x['admitted_domain_files']} |")
    lines.extend(['', f"合计：{report['counts']}；领域计数：{report['domain_counts']}。",
                  f"新增通过 {len(report['comparison']['newly_passed'])} 个配对；旧通过项退化 {len(report['comparison']['regressed'])} 个。",
                  '', '## 可进入后续合并准入检查的领域', ''])
    for d in admitted:
        lines.append(f"- `{d['domain']}`：{d['passed_pairs']}/{d['registered_pairs']}；常量补全 `{d['constant_contract']}`；同域多问题导出一致 `{d['reusable_export_identical']}`。")
    lines.extend(['', '## 剩余首个失败原因', ''])
    lines.extend(f'- {reason}: {count}' for reason, count in report['rejection_reasons'].items())
    lines.extend(['', '## 边界与复用', '',
                  '解析通过只表明可进入后续合并流程，不证明源计划、意图语义保持或跨源动作可融合。不同 problem、同源副本和同题材变体不计作独立领域证据。',
                  'admitted_domains.json 给出 source_id、原始路径和 constant_contract；创建 Source 时显式传入该契约。constant_contracts.json 保留每个域全部登记问题与契约检查结果。',
                  '每个 case 的 model/mapping.json 保留大小写映射、多父类型图、常量映射和原始哈希。相同域的全部成功导出使用稳定 source_id，并检查 domain.pddl 字节一致。',
                  '常量补声明是对原始不完整模型的显式解释；仅从对象声明取证，不搬入其他世界的初始事实。后续仍需源行为与计划验证。'])
    (output / 'README.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    return {k: report[k] for k in ('status', 'counts', 'domain_counts', 'by_collection', 'rejection_reasons')}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['prepare', 'execute'])
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--baseline', type=Path, default=BASELINE)
    args = parser.parse_args()
    result = prepare(args.output.resolve(), args.baseline) if args.mode == 'prepare' else execute(args.output.resolve())
    print(json.dumps(result, ensure_ascii=False, indent=2))

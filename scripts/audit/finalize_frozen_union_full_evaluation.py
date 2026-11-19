"""Read-only statistical review after the registered local campaign finishes.

Adds explicit initial-goal strata, physical contradictions and selection-method
contrasts. Does not alter the execution protocol or invoke a planner/model.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import time


def read(p):
    return json.loads(Path(p).read_text(encoding='utf-8'))


def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def write(p, data):
    p.parent.mkdir(parents=True, exist_ok=True)
    with p.open('x', encoding='utf-8') as stream:
        json.dump(data, stream, ensure_ascii=False, indent=2)
        stream.write('\n')


def classify(row):
    if row is None:
        return 'not_recorded'
    if row.get('valid'):
        return 'dual_validated'
    replay = row.get('replay', {})
    physical = replay.get('physical', {})
    if physical.get('status') == 'inapplicable' or (physical.get('status') == 'replayed' and physical.get('goal') is False):
        return 'physical_violation'
    if replay.get('status') == 'replayed' and (replay.get('goal') is False or replay.get('unexplained_steps', 0) > 0):
        return 'intentional_or_goal_violation'
    if row.get('native_valid'):
        return 'native_valid_physical_unknown'
    search = row.get('search', {}).get('status', row.get('status', 'unknown'))
    return 'replay_' + replay.get('status', 'not_recorded') if search in ('solved', 'not_a_search') else search


def summarize(rows, registered):
    physical = [r.get('replay', {}).get('physical', {}) for r in rows if r.get('valid')]
    return {'registered': registered, 'recorded': len(rows), 'not_recorded': registered-len(rows),
        'dual_validated': len(physical), 'native_validated': sum(r.get('native_valid', False) for r in rows),
        'dual_initial_goal_already_true': sum(p.get('initial_goal') is True for p in physical),
        'dual_goal_achieved_from_initial_false': sum(p.get('initial_goal') is False for p in physical),
        'dual_initial_goal_unknown': sum(p.get('initial_goal') not in (True, False) for p in physical),
        'dual_zero_steps': sum(r.get('valid') and r.get('replay', {}).get('steps') == 0 for r in rows),
        'outcomes': dict(Counter(classify(r) for r in rows))}


def review(root, output):
    if output.exists():
        raise ValueError('Fresh review output required')
    report = read(root / 'evaluation/report.json')
    groups = read(root / 'selected_groups.json')['groups']
    worlds = read(root / 'worlds.json')['worlds']
    sources = {r['id']: r for r in read(root / 'sources.json')['sources']}
    compfile = root / 'repeat_01/compilation_report.json'
    compiled = {r['group']['id']: r for r in read(compfile)['rows']} if compfile.exists() else {}
    stage_reports, by_stage = {}, {}
    for stage in ('native', 'transport', 'anchor', 'composition'):
        f = root / 'repeat_01' / (stage + '_report.json')
        stage_reports[stage] = read(f)['rows'] if f.exists() else []
        by_stage[stage] = {}
        for row in stage_reports[stage]:
            key = (row.get('group'), row.get('world'), row['condition'])
            if key in by_stage[stage]:
                raise ValueError('Duplicate result identity')
            by_stage[stage][key] = row
    group_rows = []
    for g in groups:
        c = compiled.get(g['id'], {})
        counts = c.get('model_counts', {})
        row = {k: g[k] for k in ('id', 'cohort', 'method', 'size', 'sources')}
        row.update(compile_status=c.get('status', 'not_recorded'), model_counts=counts,
            construction_status=c.get('construction', {}).get('status', 'not_recorded'),
            constructed_target_size=c.get('construction', {}).get('target_size'),
            candidate_statuses=c.get('candidate_statuses', {}),
            diagnostic_outcomes={condition: classify(by_stage['composition'].get((g['id'], None, condition)))
                                 for condition in ('union', 'full')})
        row['predicate_count_reduction'] = counts.get('union', {}).get('business_predicate_count', 0) - counts.get('full', {}).get('business_predicate_count', 0) if 'full' in counts else None
        row['action_count_reduction'] = counts.get('union', {}).get('action_count', 0) - counts.get('full', {}).get('action_count', 0) if 'full' in counts else None
        f = root / 'repeat_01/groups' / g['id'] / 'compilation.json'
        if f.exists():
            audits = read(f).get('audits', {})
            row['action_consensus_rejection_reasons'] = dict(Counter(x.get('reason', 'unknown')
                for x in audits.get('action', {}).get('checks', []) if x['status'] != 'eligible'))
        group_rows.append(row)
    cells = []
    for old in report['cells']:
        cohort, k, method = old['cohort'], old['k'], old['method']
        selected = [g for g in groups if (g['cohort'], g['size'], g['method']) == (cohort, k, method)]
        ids = {g['id'] for g in selected}
        gr = [r for r in group_rows if r['id'] in ids]
        cell = {'cohort': cohort, 'k': k, 'method': method, 'registered_groups': len(selected),
            'compile_statuses': dict(Counter(r['compile_status'] for r in gr)),
            'construction_statuses': dict(Counter(r['construction_status'] for r in gr)),
            'constructed_target_sizes': dict(Counter(str(r['constructed_target_size']) for r in gr)),
            'groups_with_predicate_reduction': sum((r['predicate_count_reduction'] or 0) > 0 for r in gr),
            'groups_with_action_reduction': sum((r['action_count_reduction'] or 0) > 0 for r in gr),
            'groups_with_missing_batch_results': sum(r['candidate_statuses'].get('batch_result_missing', 0) > 0 for r in gr),
            'conditions': {'union': {}, 'full': {}}, 'paired': {}}
        for stage in ('transport', 'anchor', 'composition'):
            keys = []
            for g in selected:
                gw = [w for w in worlds if w['source'] in g['sources']]
                if stage == 'anchor':
                    gw = [next(w for w in gw if w['source'] == sid) for sid in g['sources'][:2]]
                keys.extend([(g['id'], None)] if stage == 'composition' else [(g['id'], w['id']) for w in gw])
            for condition in ('union', 'full'):
                rr = [r for r in stage_reports[stage] if r['group'] in ids and r['condition'] == condition]
                cell['conditions'][condition][stage] = summarize(rr, len(keys))
                if stage == 'transport':
                    cell['conditions'][condition][stage]['reference_strata'] = old['conditions'][condition][stage].get('reference_strata', {})
            matrix = Counter((classify(by_stage[stage].get((*key, 'union'))),
                              classify(by_stage[stage].get((*key, 'full')))) for key in keys)
            cell['paired'][stage] = {'registered_pairs': len(keys),
                'both_dual_validated': matrix['dual_validated', 'dual_validated'],
                'full_only_dual_validated': sum(n for (u, f), n in matrix.items() if u != 'dual_validated' and f == 'dual_validated'),
                'union_only_dual_validated': sum(n for (u, f), n in matrix.items() if u == 'dual_validated' and f != 'dual_validated'),
                'outcome_matrix': [{'union': u, 'full': f, 'pairs': n} for (u, f), n in sorted(matrix.items())]}
        cells.append(cell)
    contrasts = []
    for pool in ('story', 'human', 'mixed'):
        for k in (2, 3, 4, 5):
            random = next(c for c in cells if (c['cohort'], c['k'], c['method']) == (pool, k, 'random'))
            causal = next(c for c in cells if (c['cohort'], c['k'], c['method']) == (pool, k, 'causal_link'))
            item = {'cohort': pool, 'k': k, 'groups_each': 50, 'conditions': {}}
            for condition in ('union', 'full'):
                item['conditions'][condition] = {}
                for stage in ('anchor', 'composition'):
                    a, b = random['conditions'][condition][stage], causal['conditions'][condition][stage]
                    item['conditions'][condition][stage] = {
                        'random_dual_validated': a['dual_validated'], 'causal_link_dual_validated': b['dual_validated'],
                        'causal_minus_random_count': b['dual_validated'] - a['dual_validated'],
                        'causal_minus_random_percentage_points': 100 * (b['dual_validated']/b['registered'] - a['dual_validated']/a['registered']),
                        'random_goal_achieved_from_initial_false': a['dual_goal_achieved_from_initial_false'],
                        'causal_goal_achieved_from_initial_false': b['dual_goal_achieved_from_initial_false']}
            contrasts.append(item)
    paths = [root / 'protocol.json', root / 'selected_groups.json', root / 'sources.json', root / 'worlds.json',
             root / 'evaluation/report.json', Path(__file__).resolve(), compfile]
    paths += [root / 'repeat_01' / (stage + '_report.json') for stage in stage_reports]
    result = {'status': 'reviewed_registered_comparison', 'experiment_status': report['experiment_status'],
        'created_utc': datetime.now(timezone.utc).isoformat(), 'registered_groups': 1200,
        'cells': cells, 'selection_method_contrasts': contrasts, 'groups': group_rows,
        'slot_accounting': report['slot_accounting'], 'new_api_requests': 0, 'new_planner_calls': 0,
        'independent_semantic_labels': 0, 'input_sha256': {str(p): sha(p) for p in paths if p.exists()},
        'limits': report['limits'] + [
            'Initial goal already satisfied, positive achievement from initially false, and unknown are separate strata.',
            'Physical contradictions are separated from native-valid but physically unsupported outcomes.',
            'Selection-method contrasts are descriptive differences on separate, correlated source-group samples; no IID significance claim.',
            'Diagnostic worlds use the same frozen post-alignment constructor in both methods, and may target fewer than k sources.']}
    write(output / 'report.json', result)
    lines = ['# union/full 最终配对复核', '', '实验状态：' + report['experiment_status'],
        '每格 50 组；所有缺失、未构造、不支持和资源限制保留。数值为双重回放通过数量。', '',
        '| 域池 | k | random 原始目标 U/F（各100） | causal link 原始目标 U/F（各100） | random 诊断 U/F（各50） | causal link 诊断 U/F（各50） |',
        '|---|---:|---:|---:|---:|---:|']
    for item in contrasts:
        values = []
        for stage, method in (('anchor', 'random'), ('anchor', 'causal_link'), ('composition', 'random'), ('composition', 'causal_link')):
            values.append('/'.join(str(item['conditions'][c][stage][method + '_dual_validated']) for c in ('union', 'full')))
        lines.append('| ' + item['cohort'] + ' | ' + str(item['k']) + ' | ' + ' | '.join(values) + ' |')
    lines += ['', 'U/F = union/full。原始目标查询、原始计划运输与人工构造的跨域诊断分别统计。',
        'report.json 保留逐组结果、初始目标已满足分层、每格配对矩阵、模型缺失和动作共识拒绝原因。',
        '超时或未返回计划不等于不可解；解析与规划通过不构成独立语义或叙事质量验证。',
        '没有新增 API 或规划请求。历史执行报告保留不改写。', '']
    (output / 'README.md').write_text('\n'.join(lines), encoding='utf-8')
    write(output / 'review_freeze.json', {'files': {p.name: sha(p) for p in output.iterdir() if p.is_file()}})
    return {'status': result['status'], 'experiment_status': result['experiment_status'], 'output': str(output)}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--wait', action='store_true')
    args = parser.parse_args()
    if args.wait:
        deadline = time.monotonic() + 8 * 86400
        while time.monotonic() < deadline:
            p = args.root / 'coordinator.json'
            if p.exists() and read(p).get('stage') == 'finished':
                break
            time.sleep(30)
        else:
            raise RuntimeError('Execution did not finish within monitor limit; no automatic retry')
    print(json.dumps(review(args.root.resolve(), args.output.resolve())), flush=True)


if __name__ == '__main__':
    main()

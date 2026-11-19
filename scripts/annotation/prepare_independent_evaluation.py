"""Prepare blind human packets, offline controls, and missing-task accounting."""
import argparse
from collections import Counter
import json
from pathlib import Path
import zipfile

from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.interface_annotation import build_packet, digest as json_digest
from rcnc.interface_evaluation import evaluate
from rcnc.prospective_evaluation import audit_task_registry, lexical_predictions
from scripts.annotation.build_annotation_viewer import build as build_viewer
from scripts.annotation.run_annotation_predictions import check_response


INSTRUCTIONS = '''独立接口试标：先阅读，再打开 index.html

本包是 Depot 与 Driverlog 的外部辅助域开发试标。不是未见故事家族测试。
源 PDDL 仅统一了大小写；未修改动作含义。页面没有接口预测、问题目标、计划或求解结果。

1. 两位标注者独立完成，不讨论答案，不查看协调者目录或另一人的文件。
2. 如参与过方法设计，或看过这些候选的模型判断/实验结果，请向协调者说明；对应判断单列为作者审阅。
3. equivalent：同一含义且参数顺序相同；permuted_equivalent：需明确交换参数。
   abstraction：一方更宽泛；complementary：有关联但不可互换；incompatible：不可共享。
   uncertain：证据不足。没有审阅仍保留 unreviewed，不要为了填满而猜测。
4. 先解释两侧每个参数的角色、对象范围，再引用两侧动作中的原文证据。
   名称相同不构成充分理由；可执行也不构成语义正确的理由。
5. 导出各自 JSON，保留原文件。页面不自动保存；下载失败可复制 JSON 另存。
6. 两份原始文件冻结后才讨论分歧；第三人裁决另存文件，不覆盖原标签。
7. 时间不够可只完成部分；保留缺失比强行给结论更有价值。

本轮不预填标注人编号、独立性声明、标签或参数映射。
'''


def prepare(protocol_path, casefold_root, original_snapshot, output):
    require_empty_output(output)
    read = lambda p: json.loads(p.read_text(encoding='utf-8'))
    protocol = read(protocol_path)
    output.mkdir(parents=True)
    inputs = casefold_root / 'domain_inputs'
    selection = read(original_snapshot / 'selection.json')
    metadata = {}
    for path in sorted(inputs.glob('*_domainfile.pddl')):
        source = path.name.removesuffix('_domainfile.pddl')
        record = next(r for r in selection['candidates'] if r['source'] == source)
        original = original_snapshot / record['provider'] / 'files' / record['domain']
        metadata[path.name] = {'domain_sha256': digest(path), 'original_domain_sha256': digest(original),
            'source_url': 'https://github.com/aibasel/downward-benchmarks/blob/'
                          + protocol['source_selection']['commit'] + '/' + record['domain'],
            'family': record['family'], 'source_role': 'external_classical_development_after_admission',
            'normalization': 'Identifier case only; source semantics unchanged.',
            'lineage': 'Related classical transport benchmark; not learned narrative or pristine heldout.'}
    packet_dir = output / 'coordinator' / 'new_interfaces'
    manifest = build_packet(inputs, packet_dir, protocol['annotation']['per_stratum'],
        protocol['annotation']['seed'], metadata,
        'Two external classical development domains, case-normalized after admission; no held-out narrative claim.')
    packet = read(packet_dir / 'packet.json')
    delivery = output / 'annotators'
    build_viewer(packet_dir / 'packet.json', delivery)
    (delivery / 'INSTRUCTIONS.txt').write_text(INSTRUCTIONS, encoding='utf-8')
    (delivery / 'annotation_template.json').write_bytes((packet_dir / 'annotation_template.json').read_bytes())
    bundles = []
    for who in ('a', 'b'):
        path = output / ('annotator_' + who + '.zip')
        with zipfile.ZipFile(path, 'x', zipfile.ZIP_DEFLATED) as archive:
            for name in ('index.html', 'INSTRUCTIONS.txt', 'annotation_template.json'):
                archive.write(delivery / name, name)
        with zipfile.ZipFile(path) as archive:
            if sorted(archive.namelist()) != ['INSTRUCTIONS.txt', 'annotation_template.json', 'index.html']:
                raise ValueError('Unexpected annotator bundle member')
        bundles.append({'path': str(path), 'sha256': digest(path)})
    packets = {
        'known_narrative': Path('data/annotation/interface_development_2026_10_15_v1/packet.json'),
        'known_external': Path('data/annotation/external_interface_pilot_2026_10_20_v1/coordinator/packet.json'),
        'new_external_development': packet_dir / 'packet.json'}
    evaluation_rows = []
    for cohort, path in packets.items():
        frozen_packet = read(path)
        target = output / 'coordinator' / cohort
        target.mkdir(parents=True)
        save(target / 'packet.json', frozen_packet)
        for condition in protocol['annotation']['offline_baselines']:
            predictions = lexical_predictions(frozen_packet, condition)
            for item, row in zip(frozen_packet['items'], predictions['rows']):
                errors = check_response(frozen_packet, item, row['response'])
                if errors:
                    raise ValueError('Invalid offline baseline: ' + str(errors))
            save(target / (condition + '_predictions.json'), predictions)
            save(target / (condition + '_manifest.json'), {'packet_sha256': json_digest(frozen_packet),
                'prediction_sha256': digest(target / (condition + '_predictions.json')),
                'source': 'deterministic_baseline_not_human', 'protocol_sha256': digest(protocol_path)})
            scoring = evaluate(frozen_packet, [], predictions, json_digest(frozen_packet))
            save(target / (condition + '_evaluation.json'), scoring)
            evaluation_rows.append({'id': cohort + '/' + condition, 'cohort': cohort,
                'condition': condition, 'candidate_count': len(frozen_packet['items']),
                'prediction_counts': dict(Counter(r['response']['label'] for r in predictions['rows'])),
                'status': scoring['status'], 'accuracy': None,
                'packet_sha256': json_digest(frozen_packet), 'original_packet_sha256': digest(path)})
    author = output / 'task_author'
    author.mkdir()
    hashes = {}
    for source in sorted({r['source'] for r in selection['candidates']}):
        normalized = inputs / (source + '_domainfile.pddl')
        record = next(r for r in selection['candidates'] if r['source'] == source)
        raw = original_snapshot / record['provider'] / 'files' / record['domain']
        hashes[source + '_domainfile.pddl'] = digest(normalized if normalized.exists() else raw)
        if normalized.exists():
            (author / normalized.name).write_bytes(normalized.read_bytes())
    tasks = []
    for pair in protocol['independent_cross_source_tasks']['source_pairs']:
        for index in range(protocol['independent_cross_source_tasks']['tasks_per_pair']):
            tasks.append({'id': '_'.join(pair) + '_' + str(index+1), 'sources': pair,
                'source_sha256': hashes, 'source_availability': 'unsupported_source' if 'LOGISTICS00' in pair else 'available',
                'query': None,
                'provenance': {'author_id': '', 'authored_at': '', 'goal_meaning': '',
                    'independent_of_method_development': None, 'unexposed_to_predictions_plans_outcomes': None}})
    registry = {'version': 1, 'task_count': len(tasks), 'tasks': tasks,
        'scope': 'Blank independent-author intake, not generated tasks. Four slots depend on unsupported Logistics; do not author those yet.'}
    save(author / 'tasks_template.json', registry)
    save(author / 'source_provenance.json', metadata)
    (author / 'INSTRUCTIONS.txt').write_text('''独立跨来源任务提供：当前先填写 DEPOT_DRIVERLOG_1 和 DEPOT_DRIVERLOG_2。
另外四个 Logistics 任务暂不可执行，保留空缺，不要补写或修补源模型。
请在未查看接口预测、求解结果和作者设计实例的情况下，依据两份源 domain 提供任务。
每个 query 必须显式写 objects、initial 和 goal；不要把两个源问题的初态直接相加。
objects 示例格式为 {"对象名": ["DEPOT:object", "DRIVERLOG:object"]}；这只是格式，不是身份建议。
initial 格式为 [["来源:谓词", "对象1", "对象2"]]；空列表只在你明确希望空初态时使用。
goal 格式为 {"positive": [["来源:谓词", "对象"]], "negative": []}；请另写自然语言含义。
共享人物/车辆/地点的身份与来源类型成员关系必须由你明确给出，不能由同名推断。
不必保证任务可解，也不要借助规划结果调整任务；不可解任务同样保留。
填写作者编号、日期和实际独立性/接触情况。先保存并冻结原始提交，再由协调者审阅映射。
本包没有预填世界、目标、计划、接口或成功答案。不要访问同级 coordinator 目录。
''', encoding='utf-8')
    intake = audit_task_registry(registry, hashes)
    for row, task in zip(intake['rows'], tasks):
        row['source_availability'] = task['source_availability']
    save(output / 'task_intake_report.json', intake)
    author_zip = output / 'task_author.zip'
    with zipfile.ZipFile(author_zip, 'x', zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(author.iterdir()):
            archive.write(path, path.name)
    implementation = snapshot_implementation(output, [Path(__file__), Path('rcnc/prospective_evaluation.py'),
        Path('rcnc/interface_annotation.py'), Path('rcnc/interface_evaluation.py'), Path('rcnc/annotation_agreement.py'),
        Path('scripts/annotation/run_annotation_predictions.py'), Path('scripts/annotation/build_annotation_viewer.py'),
        Path('templates/annotation_viewer.html')])
    result = {'status': 'prepared_pending_independent_humans', 'packet_count': len(packets),
        'new_packet_candidates': len(packet['items']), 'new_packet_sha256': json_digest(packet),
        'new_packet_sampling': manifest['strata'], 'evaluation_count': len(evaluation_rows), 'rows': evaluation_rows,
        'total_candidate_evaluations': sum(r['candidate_count'] for r in evaluation_rows),
        'actual_human_labels': 0, 'new_model_calls': 0, 'independent_tasks_received': 0,
        'registered_cross_source_tasks': len(tasks), 'registered_cross_source_slots': len(tasks)*6,
        'source_supported_task_slots': sum(t['source_availability'] == 'available' for t in tasks),
        'cross_source_planner_calls': 0, 'annotator_bundles': bundles,
        'task_author_bundle': {'path': str(author_zip), 'sha256': digest(author_zip)},
        'implementation_sha256': implementation, 'protocol_sha256': digest(protocol_path),
        'scope': 'Prepared blind development materials and offline baseline predictions. No semantic accuracy, unseen-narrative benefit, or independent-source claims.'}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    for name in ('protocol', 'casefold-root', 'original-snapshot', 'output'):
        p.add_argument('--' + name, type=Path, required=True)
    a = p.parse_args()
    result = prepare(a.protocol, a.casefold_root, a.original_snapshot, a.output)
    print(json.dumps({k: result[k] for k in ('status', 'new_packet_candidates', 'total_candidate_evaluations', 'registered_cross_source_tasks', 'actual_human_labels')}))

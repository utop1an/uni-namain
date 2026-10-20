"""Build two outcome-blind delivery bundles from predetermined admitted sources."""
import argparse
from collections import Counter
import json
from pathlib import Path
import zipfile

from rcnc.domain_building import require_empty_output, save
from rcnc.interface_annotation import build_packet, digest
from scripts.annotation.build_annotation_viewer import build as build_viewer
from scripts.audit.admit_external_pddl import sha


SCOPE = ('External auxiliary interface-annotation pilot, not a narrative-quality benchmark '
         'or pristine held-out test. Source roles and shared lineages remain explicit. '
         'No model predictions, plans, goals or solver outcomes are supplied.')


def prepare(reports, output, per_stratum=24, seed='external-screen-2026-10-20-v1'):
    require_empty_output(output)
    output.mkdir(parents=True, exist_ok=True)
    inputs = output / 'inputs'
    inputs.mkdir()
    metadata, report_hashes = {}, {}
    for path in reports:
        report = json.loads(path.read_text(encoding='utf-8'))
        if (report['status'] != 'complete' or len(report['rows']) != report['candidate_count']
                or dict(Counter(row['status'] for row in report['rows'])) != report['counts']
                or len({row['id'] for row in report['rows']}) != len(report['rows'])):
            raise ValueError('Complete unique admission report required')
        report_hashes[str(path)] = sha(path)
        for row in report['rows']:
            if row['status'] != 'admitted_compatibility_only' or not row['annotation_selected']:
                continue
            name = row['id'] + '_domainfile.pddl'
            if Path(name).name != name or name in metadata:
                raise ValueError('Duplicate or unsafe source id')
            source = path.parent / 'annotation_inputs' / name
            if sha(source) != row['domain_sha256']:
                raise ValueError('Admitted source changed')
            (inputs / name).write_bytes(source.read_bytes())
            metadata[name] = {'domain_sha256': row['domain_sha256'],
                'source_url': row['source_urls']['domain'], 'source_role': row['role'],
                'family': row['family'], 'lineage': row['lineage'],
                'learning_run_provenance': row['learning_run_provenance'],
                'evaluation_role': 'external_annotation_pilot_not_pristine_heldout'}
    if len(metadata) < 2:
        raise ValueError('At least two predetermined admitted sources required')
    save(output / 'source_metadata.json', metadata)
    packet_dir = output / 'coordinator'
    manifest = build_packet(inputs, packet_dir, per_stratum, seed, metadata, SCOPE)
    packet = json.loads((packet_dir / 'packet.json').read_text(encoding='utf-8'))
    if not packet['items']:
        raise ValueError('No eligible cross-source predicate pairs')
    delivery = output / 'delivery'
    build_viewer(packet_dir / 'packet.json', delivery)
    instructions = (
        '独立接口标注材料\n\n'
        '这是外部辅助域试标，不是叙事质量或未见故事家族测试。页面保留来源和材料角色。\n'
        '1. 两位标注者各自解压自己的包，打开 index.html，填写自己的编号。\n'
        '2. 独立判断；不要查看模型输出、规划结果或另一人的判断。\n'
        '3. 按页面六类标签判断，解释参数角色并引用两侧动作原文。证据不足选 uncertain。\n'
        '4. 未审阅不等于 uncertain；不要为了完成数量强行判断。\n'
        '5. 页面不联网、不自动保存。离开前导出 JSON；下载失败可复制完整 JSON 另存。\n'
        '6. 保留各自原始文件。协调者先冻结两份文件，再单独处理分歧；不要覆盖原始判断。\n'
        '7. 不要把一致意见或页面格式检查当作语义真值，也不要自动用于编译。\n'
        '每份包包含相同候选；未预填任何标签、映射或独立性声明。\n')
    (delivery / 'INSTRUCTIONS.txt').write_text(instructions, encoding='utf-8')
    (delivery / 'annotation_template.json').write_bytes((packet_dir / 'annotation_template.json').read_bytes())
    bundles = []
    allowed = ('index.html', 'INSTRUCTIONS.txt', 'annotation_template.json')
    for name in ('annotator_a.zip', 'annotator_b.zip'):
        path = output / name
        with zipfile.ZipFile(path, 'x', zipfile.ZIP_DEFLATED) as archive:
            for filename in allowed:
                archive.write(delivery / filename, filename)
        bundles.append({'path': name, 'sha256': sha(path), 'members': list(allowed)})
    result = {'status': 'prepared_no_human_labels', 'packet_sha256': digest(packet),
        'source_count': len(metadata), 'candidate_count': len(packet['items']),
        'sampling': {'seed': seed, 'per_stratum': per_stratum,
                     'policy': manifest['selection_policy'], 'strata': manifest['strata']},
        'admission_report_sha256': report_hashes, 'source_metadata_sha256': sha(output / 'source_metadata.json'),
        'bundles': bundles, 'independent_labels_created': 0, 'contacted_annotators': False,
        'implementation_sha256': {str(p): sha(p) for p in (Path(__file__),
            Path('rcnc/interface_annotation.py'), Path('scripts/annotation/build_annotation_viewer.py'),
            Path('templates/annotation_viewer.html'))},
        'scope': SCOPE, 'browser_visual_qa': 'not_performed_in_this_run',
        'limits': 'Sample-descriptive evaluation only; selected domains share some task concepts and are not evidence of independent narrative-model acquisition.'}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--admission-reports', type=Path, nargs='+', required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--per-stratum', type=int, default=24)
    parser.add_argument('--seed', default='external-screen-2026-10-20-v1')
    args = parser.parse_args()
    result = prepare(args.admission_reports, args.output, args.per_stratum, args.seed)
    print(json.dumps({k: v for k, v in result.items() if k not in ('sampling', 'implementation_sha256')}, indent=2))

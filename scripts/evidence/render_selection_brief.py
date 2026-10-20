"""Two-page Chinese meeting supplement from the verified selection comparison."""
import argparse
import hashlib
import json
from pathlib import Path
from xml.sax.saxutils import escape
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import SimpleDocTemplate, Paragraph, Table, TableStyle, PageBreak


def render(results, output):
    if output.exists():
        raise ValueError('Use a fresh PDF path')
    data = json.loads(results.read_text(encoding='utf-8'))
    if data['status'] != 'verified_complete_selection_comparison':
        raise ValueError('Verified results required')
    for path, digest in data['frozen_sha256'].items():
        if hashlib.sha256(Path(path).read_bytes()).hexdigest() != digest:
            raise ValueError('Evidence changed: ' + path)
    pdfmetrics.registerFont(TTFont('SelectionChinese', 'C:/Windows/Fonts/simsun.ttc', subfontIndex=0))
    body = ParagraphStyle('Body', fontName='SelectionChinese', fontSize=10, leading=15,
                          spaceAfter=7, wordWrap='CJK', textColor=colors.HexColor('#243346'))
    title = ParagraphStyle('Title', parent=body, fontSize=19, leading=26, spaceAfter=12)
    heading = ParagraphStyle('Heading', parent=body, fontSize=12, leading=18, spaceBefore=8, spaceAfter=7)
    small = ParagraphStyle('Small', parent=body, fontSize=8, leading=12, spaceAfter=5)
    cell = ParagraphStyle('Cell', parent=body, fontSize=9, leading=13, spaceAfter=0)
    def p(text, style=body):
        return Paragraph(escape(str(text)).replace('\n', '<br/>'), style)
    def table(rows, widths):
        result = Table([[p(v, cell) for v in row] for row in rows], colWidths=widths, repeatRows=1)
        result.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#e7eef7')),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#f4f6f9')]),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'), ('LEFTPADDING', (0, 0), (-1, -1), 7),
            ('RIGHTPADDING', (0, 0), (-1, -1), 7), ('TOPPADDING', (0, 0), (-1, -1), 5),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 5)]))
        return result
    names = {'source_isolated': '源模型（前批）', 'namespaced_union': '全池并集（前批）',
             'zero_merge_membership': '全池零接口（前批）', 'machine_interfaces': '全池机器接口（前批）',
             'graph_closure_control': '旧闭包选择（本批）', 'world_selected': '对象归属选择（本批）'}
    summaries = {s['representation']: s for s in data['summary']}
    order = list(names)
    rows = [['表示与测量批次', '成功 / 15', '不可解', '资源时限']]
    rows += [[names[rep], summaries[rep]['solved'], summaries[rep]['unsolvable'], summaries[rep]['resource_limits']]
             for rep in order]
    chic = {r['representation']: r for r in data['rows'] if r['source'] == 'CHIC_NP'}
    samples = {r['id']: r['sampling'] for r in data['diagnostics']['rows']}
    total = samples['graph_closure_CHIC_NP']['grounded_actions']
    hans = sum(v for k, v in samples['graph_closure_CHIC_NP']['grounded_actions_by_schema'].items()
               if k.startswith('d001__'))
    flow = [p('ICAPS 会议补充：选择优化与转译瓶颈', title),
        p('会议 2026-10-21 · 实验 2026-10-20 · 全部原始世界与失败行保留', small),
        p('新增 30 次求解：15 个原始世界，旧闭包选择与新选择逐源交替运行。新选择恢复 CHIC_NP 的有效解，整体达到原生源模型的 4/15 成功数。'),
        p('统一使用 Fast Downward 26.6 / lama-first；每任务配置 20 秒墙钟和 CPU、4096 MB、1 个 worker。编译与选择在求解预算外。前批 60 次结果单列，未当作本批重复测量。', small),
        table(rows, [244, 84, 78, 105]),
        p('CHIC_NP：直接恢复的一个原始目标', heading),
        p(f"旧选择保留 CHIC_NP＋HANS_NP，{chic['graph_closure_control']['elapsed_seconds']:.3f} 秒观测耗时后触及时限；新选择仅保留 CHIC_NP，{chic['world_selected']['elapsed_seconds']:.3f} 秒找到 {chic['world_selected']['plan_length']} 步计划，并通过独立计划验证。"),
        p('为什么两个来源仍然超时', heading),
        p(f'单独诊断记录 {total:,} 个实例化动作，其中 HANS_NP 为 {hans:,}（{hans / total:.2%}）；新 CHIC_NP 模型为 371 个。全池 CHIC_NP 为 294,157 个，HANS_NP 占 99.18%。前批全池机器接口的 7 个超时都未记录进入搜索。'),
        p('HANS_NP 的 collect_treasure 有 7² × 14² × 13 = 124,852 种绑定。abandon_children_in_forest 的两个未使用角色参数额外复制 49 倍；它没有前置条件，其他源域即使未导入叙事初始事实也会产生大量可实例化动作。实例化与逐动作 SAS 转换是观测到的主要开销。'),
        p('诊断采用独立的转译器采样，不计入 30 次求解。重跑版 5 份采样均保留；4 份在 20 秒停止采样，进程收尾触及 CPU 信号。初版 5 次诊断中 4 份采样丢失，完整保留并排除。', small),
        PageBreak(), p('逐源结果与论文解释边界', title)]
    matrix = [['原始世界', '旧闭包 / 本批', '对象归属 / 本批']]
    status = {'solved': '有效解', 'unsolvable': '不可解', 'wall_time_limit': '墙钟时限', 'time_limit': 'CPU 时限'}
    for row in data['matrix']:
        matrix.append([row['source'], status[row['graph_closure_control']], status[row['world_selected']]])
    flow += [table(matrix, [171, 170, 170]),
        p('选择规则与保持检查', heading),
        p('读取显式初始世界中的静态源对象成员关系。对于非零元接口，只有源对象宇宙有交集时才保留跨源依赖；零元接口始终保留依赖。按依赖分量选取完整源域，保留所有动作模板、映射与逐世界证书，不依据已找到的计划剪枝。'),
        p('4 条可用原生原始目标计划全部在新模型中验证通过：64 个状态、23,457 次源原子真值比较、0 差异；其余 11 个世界保留为没有该项计划证据。'),
        p('会议应明确的结论与下一步', heading),
        p('这 15 个世界都没有跨源共享对象身份，因此新模型均为单源分量。结果支持去除无关转译开销；跨故事动作组合、接口语义准确率与叙事质量仍缺少独立证据。HANS_NP、MUSI、SNOW 的时限问题仍在。'),
        p('下一步优先冻结含显式共享对象、跨源必需动作的组合任务，并保留不共享对象和零元接口控制；再研究 HANS_NP 等自身的实例化成本。独立接口标注继续与求解结果隔离。'),
        p('固定顺序、每条件单次测量；不作统计速度提升主张。观测耗时包含 WSL 启动、响应和超时终止宽限；新 SNOW 行观测 26.141 秒，配置时限仍为 20 秒。完整数据见 selection_results_2026_10_20_v2。', small)]
    output.parent.mkdir(parents=True, exist_ok=True)
    def footer(canvas, doc):
        canvas.setFont('SelectionChinese', 8)
        canvas.drawString(42, 25, 'ICAPS 2027 · 开发实验 / 原始目标回归 · 独立语义标注仍为 0')
        canvas.drawRightString(A4[0] - 42, 25, str(doc.page))
    SimpleDocTemplate(str(output), pagesize=A4, leftMargin=42, rightMargin=42,
                      topMargin=36, bottomMargin=40).build(flow, onFirstPage=footer, onLaterPages=footer)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--results', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    render(args.results, args.output)

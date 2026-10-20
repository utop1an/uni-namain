"""Render a compact Chinese meeting PDF from verified results, not live progress."""
import argparse
import hashlib
import json
from pathlib import Path
from xml.sax.saxutils import escape

from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak


NAMES = {'source_isolated': '源模型', 'namespaced_union': '命名空间并集',
         'zero_merge_membership': '对象归属编码\n零接口', 'machine_interfaces': '对象归属编码\n机器接口'}
STATUS = {'solved': '有效解', 'unsolvable': '不可解', 'time_limit': '时限',
          'wall_time_limit': '墙钟时限', 'memory_limit': '内存限', 'unsupported': '不支持',
          'input_error': '输入错误', 'invalid_plan': '无效计划', 'incomplete': '未完成',
          'wsl_observation_timeout': '观测时限', 'resource_killed': '资源终止'}


def render(results_path, output):
    if output.exists():
        raise ValueError('Use a fresh PDF path')
    data = json.loads(results_path.read_text(encoding='utf-8'))
    if data['status'] != 'verified_complete_meeting_results':
        raise ValueError('Verified completed results required')
    for path, expected in data['source_report_sha256'].items():
        if hashlib.sha256(Path(path).read_bytes()).hexdigest() != expected:
            raise ValueError('Source report changed: ' + path)
    pdfmetrics.registerFont(TTFont('MeetingChinese', 'C:/Windows/Fonts/simsun.ttc', subfontIndex=0))
    body = ParagraphStyle('Body', fontName='MeetingChinese', fontSize=10, leading=15,
                          textColor=colors.HexColor('#203044'), spaceAfter=7, wordWrap='CJK')
    small = ParagraphStyle('Small', parent=body, fontSize=8, leading=12, spaceAfter=5)
    title = ParagraphStyle('Title', parent=body, fontSize=20, leading=27, spaceAfter=12)
    heading = ParagraphStyle('Heading', parent=body, fontSize=13, leading=19, spaceBefore=9, spaceAfter=8)
    cell = ParagraphStyle('Cell', parent=body, fontSize=9, leading=13, spaceAfter=0, alignment=TA_LEFT)
    def p(text, style=body):
        return Paragraph(escape(str(text)).replace('\n', '<br/>'), style)
    def table(rows, widths, font=cell):
        result = Table([[p(v, font) for v in row] for row in rows], colWidths=widths, repeatRows=1, hAlign='LEFT')
        result.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#e7eef7')),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#f5f7fa')]),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'), ('LEFTPADDING', (0, 0), (-1, -1), 7),
            ('RIGHTPADDING', (0, 0), (-1, -1), 7), ('TOPPADDING', (0, 0), (-1, -1), 5),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
            ('LINEBELOW', (0, 0), (-1, 0), .6, colors.HexColor('#a9b9ca'))]))
        return result
    fresh = data['fresh_search']
    replay = data['new_machine_interface_replay']
    selection = data.get('exploratory_selection')
    original_replay = data.get('fresh_original_goal_replay')
    historical = data['historical_rechecked']['results']
    def metrics(key):
        return historical[key]['metrics']
    flow = [p('ICAPS 研究进度与实验结果', title),
            p('会议日期 2026 年 10 月 21 日    数据准备 2026 年 10 月 20 日', small),
            p('研究目标是在规划前构建可复用的合并域，并在显式初始世界中组合源动作。当前已补做原始目标的匹配求解和非零机器接口的源轨迹回放；接口语义正确性与叙事质量仍缺少独立评价。'),
            p('本轮新增匹配求解', heading),
            p(f"{fresh['unique_original_worlds']} 个不同原始世界 × 4 种表示，共 {fresh['solver_invocations']} 次新求解。四种条件保留相同初始事实、对象身份和目标含义，全部任务在搜索前冻结；这不是 60 个独立故事。"),
            p('Fast Downward 26.6，lama-first；每任务墙钟与 CPU 上限 20 秒，内存上限 4096 MB，1 个 worker。固定顺序和共享工作站限制了性能推断；耗时只作描述。', small)]
    summary = [['条件', '有效解 / 15', '不可解', '资源限制', '其他状态']]
    limits = {'time_limit', 'wall_time_limit', 'memory_limit', 'memory_time_limit', 'resource_killed', 'wsl_observation_timeout'}
    for group in fresh['summary']:
        counts = group['status_counts']
        other = {k: v for k, v in counts.items() if k not in limits | {'solved', 'unsolvable'}}
        summary.append([NAMES[group['representation']], str(counts.get('solved', 0)), str(counts.get('unsolvable', 0)),
            str(sum(v for k, v in counts.items() if k in limits)),
            '；'.join(STATUS.get(k, k) + ' ' + str(v) for k, v in other.items()) or '0'])
    flow += [table(summary, [126, 85, 65, 75, 156]), p('逐源结果', heading)]
    matrix = [['源', '源模型', '并集', '零接口', '机器接口']]
    for row in fresh['matrix']:
        matrix.append([row['source'], *[STATUS.get(row[k], row[k]) for k in NAMES]])
    flow += [table(matrix, [103, 101, 101, 101, 101], small),
             p('机器接口来自已有 100 对开发候选中的 7 条等价提议边，形成 5 个接口组和 10 个角色类型假设；尚未取得独立语义标签。', small), PageBreak()]
    flow += [p('探索性选择对照与轨迹保持', title)]
    if selection:
        selected_counts = selection['status_counts']
        pooled = next(g for g in fresh['summary'] if g['representation'] == 'machine_interfaces')
        flow += [p('另立的选择对照', heading),
            p('本对照是在观察到早期全池时限后设计的探索实验，单独冻结 15 项，未改写原 60 项设计。使用相同世界、目标、求解器和 20 秒预算；从原问题源出发，只保留完整接口组的源依赖闭包。'),
            table([['机器接口条件', '有效解 / 15', '不可解', '其他状态'],
                ['全部 15 域', str(pooled['status_counts'].get('solved', 0)), str(pooled['status_counts'].get('unsolvable', 0)),
                 '；'.join(STATUS.get(k,k) + ' ' + str(v) for k,v in pooled['status_counts'].items() if k not in ('solved','unsolvable')) or '0'],
                ['接口源依赖选择', str(selected_counts.get('solved', 0)), str(selected_counts.get('unsolvable', 0)),
                 '；'.join(STATUS.get(k,k) + ' ' + str(v) for k,v in selected_counts.items() if k not in ('solved','unsolvable')) or '0']],
                [160, 90, 70, 187]),
            p('相对全池机器接口条件，选择后恢复有效解的源：' + ('、'.join(selection['gained_solved_vs_all_pool_machine']) or '无') + '。不能据此宣称最优选择、独立泛化或叙事质量提升。'),
            p(f"全池机器接口条件有 {pooled['resource_limits_before_logged_search']} 项资源截断发生在日志尚未进入搜索时。此处按日志阶段分类，不是完整性能剖析。", small)]
    if original_replay:
        flow += [p('原始目标的可执行见证', heading),
            p(f"本轮源模型求解得到的 {original_replay['original_goal_plans']} 条原始目标计划中，{original_replay['valid_translations']} 条映射到固定机器接口模型后仍通过计划验证和状态比较。其源模型对应的原始目标没有被替换。"),
            p(f"其中 {original_replay['valid_plan_witness_despite_search_cutoff']} 条在机器接口模型的新搜索中触及时限，但已有有效映射计划证明这些具体目标仍可达。因此不能把搜索超时写成语义不保持或目标不可解。")]
    flow += [p('动作调用轨迹的新回放', heading),
             p(f"在完整 {replay['task_count']} 个动作调用任务分母上，回放已有可用源轨迹。结果为 {replay['counts'].get('PASS', 0)} 条通过、{replay['counts'].get('FAIL', 0)} 条失败；{replay['counts'].get('no_audited_source_trace', 0)} 项没有可用源轨迹证据，仍保留。"),
             p(f"比较 {replay['states_compared']:,} 个状态、{replay['truth_comparisons']:,} 次源原子真值，发现 {replay['mismatch_count']} 个差异。输入哈希保持不变。"),
             p('这里重用历史求解轨迹，新增的是机器接口模型上的映射、模拟和比较，不是又求解了 146 个新问题。通过只支持已访问源局部轨迹的保持，不能证明任意混合源执行等价，也不能证明接口含义合理。'),
             PageBreak(), p('历史实验量与证据边界', title), p('历史结果已重新核验', heading)]
    invocation = metrics('action_invocation_planning')
    coverage = metrics('action_invocation_coverage')
    schema = metrics('restored_schema_comparison')
    prior = [
        ['实验单位', '保存的数量结果', '支持范围'],
        ['原始目标', '15 个源；6 有效解、8 不可解、1 内存限', '历史 60 秒、4096 MB；与本轮 20 秒条件分开'],
        ['动作调用探针', f"{invocation['task_count']} 项；146 solved、50 不可解、38 墙钟限", '每个声明动作一个任务；不是原始目标成功率'],
        ['动作见证覆盖', f"{coverage['counts']['witnessed_reachable']} / 234 有执行见证；50 不可达报告、18 未解决", '合并三组轨迹后的动作覆盖；不改写探针的 146/50/38'],
        ['跨源开发世界', '3 个构造世界 × 2 接口条件 × 3 选择策略，共 18 条件；9 有解、9 不可解', '接口与世界是实验假设；不是 18 个独立故事或语义标签'],
        ['有限转移控制', '256 状态；4,352 次适用性、2,048 次转移；0 差异', '人工有限夹具；不代替一般证明'],
        ['输出格式对照', '相同 100 对候选；free 0 checked，coupled 52 checked', '一次格式协议对照；不是语义准确率'],
        ['外部源兼容性', '15 对候选文件；6 案例通过，涉及 4 个辅助家族', '无新增可直接准入的叙事家族'],
        ['人工标注准备', '原开发 100 对；新增辅助 48 对；独立标签仍为 0', '准备材料，不计作已完成评测']]
    flow += [table(prior, [87, 205, 215]),
             p(f"本次重新核验 {data['historical_rechecked']['report_count']} 份历史报告的固定哈希、终态及适用分母。不同实验单位不合并计算成功率。", small), PageBreak()]
    gains = fresh['changes']['machine_interfaces']['gained_solved_vs_isolated']
    losses = fresh['changes']['machine_interfaces']['lost_solved_vs_isolated']
    flow += [p('会议讨论与下一步决策', title), p('当前可以据此讨论的发现', heading),
        p(f"本轮机器接口条件相对源模型新增有效解的源为：{'、'.join(gains) or '无'}；丢失有效解的源为：{'、'.join(losses) or '无'}。具体变化必须结合逐源状态、资源限制和域表示解释，不能直接称为语义改进或退化。"),
        p('源行为保持与跨源接口语义是两个问题。已有人工反例表明，错误接口可以通过源轨迹回归与计划验证，因此即使新回放全部通过，仍需要独立接口标签和混合源任务评价。'),
        p('原始源目标用于测试保持和求解代价，通常没有显式共享对象；它们不等于跨域组合任务。跨域效用需要独立给定共享对象身份、初始世界和目标，不能靠汇总源初始事实制造成功。'),
        p('尚未完成的关键比较', heading),
        p('完整 fresh UniDomain 对照仍未完成。历史运行只得到 13 个中间融合节点，最终根域缺失；不能用中间节点替代完整基线。缓存续跑必须另列扩展预算条件。'),
        p('建议会议确定三项决定', heading),
        p('1. 主贡献是否收窄为“接口误合并、虚假可执行解及保持约束”，以独立语义标签和受控混合源任务作为主要证据。'),
        p('2. 落实两位独立标注者，先完成开发 100 对和外部辅助 48 对。辅助域试标用于验证协议；新增叙事家族与独立上游谱系仍需继续寻找。'),
        p('3. 在任何新增模型实验前冻结测试家族、共享身份、完整初始世界、目标、模型版本与总预算；再开展匹配 UniDomain、选择消融和叙事盲评。'),
        p('结果位置与复现', heading),
        p('逐任务 CSV 和完整 JSON 随简报提供。原始求解日志、冻结任务和模型保留在 data/validation/meeting_matched_2026_10_20_v1；回放、历史索引和所有失败均保留在各自版本目录。', small),
        p('结果 JSON SHA256  ' + hashlib.sha256(results_path.read_bytes()).hexdigest(), small),
        p('本文没有独立语义准确率、叙事质量提升或投稿就绪的结论。', small)]
    output.parent.mkdir(parents=True, exist_ok=True)
    def footer(canvas, doc):
        canvas.setFont('MeetingChinese', 8)
        canvas.setFillColor(colors.HexColor('#65758a'))
        canvas.drawString(44, 24, 'ICAPS 2027 研究讨论材料  ·  2026 年 10 月 21 日')
        canvas.drawRightString(A4[0] - 44, 24, str(doc.page))
    SimpleDocTemplate(str(output), pagesize=A4, leftMargin=44, rightMargin=44,
                      topMargin=38, bottomMargin=43, title='ICAPS 研究进度与实验结果',
                      author='Research progress').build(flow, onFirstPage=footer, onLaterPages=footer)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--results', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    render(args.results, args.output)

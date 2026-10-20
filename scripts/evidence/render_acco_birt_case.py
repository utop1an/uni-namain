"""Meeting-ready two-page case: causal bridge, matched controls, semantic risks."""
import argparse
import json
from pathlib import Path
from xml.sax.saxutils import escape
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import SimpleDocTemplate, Paragraph, Table, TableStyle, PageBreak
from scripts.experiments.run_downward_reference import sha


def render(audit, output):
    if output.exists():
        raise ValueError('Use a fresh output PDF')
    data = json.loads(audit.read_text(encoding='utf-8'))
    if data['status'] != 'complete' or not data['hashes_unchanged']:
        raise ValueError('Complete unchanged audit required')
    if any(sha(Path(path)) != digest for path, digest in data['frozen_sha256'].items()):
        raise ValueError('Audit inputs changed')
    pdfmetrics.registerFont(TTFont('CaseChinese', 'C:/Windows/Fonts/simsun.ttc', subfontIndex=0))
    body = ParagraphStyle('Body', fontName='CaseChinese', fontSize=10, leading=15, spaceAfter=8,
                          wordWrap='CJK', textColor=colors.HexColor('#243346'))
    title = ParagraphStyle('Title', parent=body, fontSize=19, leading=26, spaceAfter=12)
    heading = ParagraphStyle('Heading', parent=body, fontSize=12, leading=18, spaceBefore=8)
    small = ParagraphStyle('Small', parent=body, fontSize=8, leading=12, spaceAfter=6)
    cell = ParagraphStyle('Cell', parent=body, fontSize=9, leading=14, spaceAfter=0)
    def p(text, style=body):
        return Paragraph(escape(str(text)).replace('\n', '<br/>'), style)
    def table(rows, widths):
        result = Table([[p(value, cell) for value in row] for row in rows], colWidths=widths, repeatRows=1)
        result.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#e6eef7')),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#f4f6f9')]),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'), ('LEFTPADDING', (0, 0), (-1, -1), 7),
            ('RIGHTPADDING', (0, 0), (-1, -1), 7), ('TOPPADDING', (0, 0), (-1, -1), 6),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6)]))
        return result
    names = {'interface_pair': '共享接口＋双源动作', 'no_interface_pair': '无接口＋双源动作',
             'ACCO_actions_only': '共享接口＋仅 ACCO 动作', 'BIRT_actions_only': '共享接口＋仅 BIRT 动作',
             'no_shared_identity': '共享接口＋取消共享身份'}
    statuses = {'solved': '有效解', 'unsolvable': '不可解', 'wall_time_limit': '墙钟时限', 'time_limit': 'CPU 时限'}
    rows = [['条件', '结果', '计划长度', '观测耗时']]
    for row in data['rows']:
        rows.append([names[row['id']], statuses.get(row['status'], row['status']),
                     str(row.get('plan_length', '—')), f"{row['elapsed_seconds']:.3f} 秒"])
    flow = [p('ACCO＋BIRT：跨源接口成功案例', title),
        p('2026-10-21 会议 · 2026-10-20 新补跑 · 一个构造世界，五个条件', small),
        p('共享的“持有物品”接口，使 BIRT 的动作效果成为 ACCO 动作的前置条件。新实验在统一的 20 秒预算下得到四步有效计划；无接口和两个单源动作对照均不可解。'),
        p('同一个显式世界与目标', heading),
        p('对象：hero 同时属于两个来源的 entity；token 同时属于两个来源的 item；stage 属于 BIRT 的 location。初始叙事事实仅为 at(hero, stage)，没有初始持有、展览、声望或财富事实。目标为 ACCO:wealthy(hero)。'),
        p('作者指定接口：BIRT:has(entity,item) ↔ ACCO:has(entity,item)。共享对象身份也由请求显式提供；没有从源问题导入叙事初始事实。', small),
        table([['步骤 / 来源', '动作', '因果链上的效果'],
               ['1 · BIRT', 'turn_key_on_beech\n转动钥匙', 'at(hero,stage) → has(hero,token)'],
               ['2 · ACCO', 'arrange_exhibition\n筹备展览', 'has(hero,token) → exhibition_ready(hero)'],
               ['3 · ACCO', 'perform_show\n进行表演', '展览已就绪且持有物品 → performing_show(hero) 与全局声望'],
               ['4 · ACCO', 'receive_orders_from_nobility\n收到贵族订单', '全局声望 → wealthy(hero)']], [77, 190, 244]),
        p('同预算对照结果', heading), table(rows, [244, 88, 80, 99]),
        p('Fast Downward 26.6 / lama-first；每条件配置墙钟与 CPU 上限 20 秒、4096 MB、1 个 worker。观测耗时包括 WSL 启动与响应；固定顺序、每条件一次，不作统计速度提升主张。', small),
        p('前四个条件的世界和目标文件逐字节一致。单源对照保留共同词汇、对象及目标，仅限制可用动作来源；不是原生单源目标测试。最后一项仅移除 hero/token 的 BIRT 类型成员事实。', small),
        PageBreak(), p('成功链成立，动作语义仍需约束', title),
        p('计划验证证明它符合当前 PDDL。以下是代码审查和离线执行见证，不是独立人工语义标签；原始源动作没有修改。'),
        table([['动作', '形式模型中的问题', '对故事解释的影响'],
               ['BIRT\n转动钥匙', '只要求角色在某处；不要求事先持有钥匙，也不检查地点是否为山毛榉。任意 item 参数都会成为持有物品，并额外打开门、邀请树精。', '展示时应说“该动作在模型中产生持有事实”；不能据此认定得物情节合理。'],
               ['ACCO\n筹备展览', '赞助者参数未出现在条件或效果中；仅有持有物品就能筹备展览。', '赞助者身份无实际作用；物品是否适合展出没有编码。'],
               ['ACCO\n进行表演', '检查展览就绪及持有；没有物品适用性或观众约束，并设置全局声望。', '事件存在抽象化，声望没有绑定表演者。'],
               ['ACCO\n收到订单', '前置条件只有全局声望；任意 ACCO 实体都可因此变得富有。', '收益可能流向未参与表演的角色。']], [82, 249, 180]),
        p('额外执行检查', heading),
        p('更换第二步的赞助者为 hero 后，完整计划仍通过独立目标验证。执行真实前三步后，让未表演的 badger 收到订单也可执行，且 badger 变得富有。这两项只用于暴露规格偏宽，不计为新增求解成功。'),
        p('选择器检查：在显式共享对象的世界中，新规则保留 ACCO 和 BIRT；取消共享身份时，ACCO 的依赖分量不再包含 BIRT。不会因来源名称不同就一律删去外源动作。'),
        p('会议可直接使用的说明', heading),
        p('“我们在完整源动作模型上构造了一个共享角色和物品的任务。BIRT 先产生持有关系，ACCO 再消费这个关系完成展览、表演和致富目标。相同 20 秒配置下，连接接口得到四步有效解；不连接接口或只允许任一来源的动作都不可解。这个例子验证了接口和两个来源在该任务中的必要性，同时暴露了上游动作约束偏宽的问题。它是机制成功例，不代表自动接口准确率或叙事质量已经成立。”'),
        p('后续实验应把原模型结果与显式标注的语义约束敏感性条件分开；冻结共享对象任务、独立接口判断和故事质量评价。当前独立语义标签数仍为 0。', small)]
    output.parent.mkdir(parents=True, exist_ok=True)
    def footer(canvas, doc):
        canvas.setFont('CaseChinese', 8)
        canvas.drawString(42, 24, 'ICAPS 2027 · 人工指定接口与共享身份 · 形式有效性和叙事合理性分别报告')
        canvas.drawRightString(A4[0] - 42, 24, str(doc.page))
    SimpleDocTemplate(str(output), pagesize=A4, leftMargin=42, rightMargin=42,
                      topMargin=34, bottomMargin=40).build(flow, onFirstPage=footer, onLaterPages=footer)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--audit', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    render(args.audit, args.output)

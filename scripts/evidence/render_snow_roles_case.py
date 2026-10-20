"""Render the audited executable shared-role scenario as a meeting PDF."""
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
        raise ValueError('Use a fresh PDF path')
    data = json.loads(audit.read_text(encoding='utf-8'))
    if data['status'] != 'complete' or not data['hashes_unchanged']:
        raise ValueError('Complete unchanged audit required')
    if any(sha(Path(p)) != h for p, h in data['frozen_sha256'].items()):
        raise ValueError('Audit evidence changed')
    main = next(r for r in data['rows'] if r['id'] == 'role_safe')
    trace = main['execution_audit']
    if not main['scenario_contract_pass']:
        raise ValueError('Primary scenario failed its contract')
    pdfmetrics.registerFont(TTFont('SnowChinese', 'C:/Windows/Fonts/simsun.ttc', subfontIndex=0))
    body = ParagraphStyle('Body', fontName='SnowChinese', fontSize=10, leading=15, spaceAfter=7,
                          wordWrap='CJK', textColor=colors.HexColor('#243346'))
    title = ParagraphStyle('Title', parent=body, fontSize=19, leading=26, spaceAfter=11)
    heading = ParagraphStyle('Heading', parent=body, fontSize=12, leading=18, spaceBefore=8)
    small = ParagraphStyle('Small', parent=body, fontSize=8, leading=12, spaceAfter=6)
    cell = ParagraphStyle('Cell', parent=body, fontSize=9, leading=13, spaceAfter=0)
    def p(text, style=body):
        return Paragraph(escape(str(text)).replace('\n', '<br/>'), style)
    def table(rows, widths):
        result = Table([[p(value, cell) for value in row] for row in rows], colWidths=widths, repeatRows=1)
        result.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#e6eef7')),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#f4f6f9')]),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'), ('LEFTPADDING', (0, 0), (-1, -1), 7),
            ('RIGHTPADDING', (0, 0), (-1, -1), 7), ('TOPPADDING', (0, 0), (-1, -1), 5),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 5)]))
        return result
    labels = {'collect_treasure': ('收集梳子和宝石', '两名同伴；HANS 的持有事实供 SNOW 使用'),
        'stepmother_makes_poisonous_comb_and_visits_cottage': ('制成毒梳并到访小屋', '女巫参数＝同一个白雪公主'),
        'cut_beanstalk': ('砍断豆茎', '巨人参数＝白雪公主；死亡并停止下行'),
        'dwarfs_remove_comb_rescue_snow_white': ('拔去毒梳，救活白雪公主', '营救对象仍是同一个白雪公主')}
    plan_rows = [['步骤 / 来源', '实际动作', '绑定与跨源作用']]
    for step in trace['steps']:
        label, note = labels[step['action']]
        plan_rows.append([str(step['step']) + ' · ' + step['source'], label, note])
    watched = ['alive(snow_white)', 'dead(snow_white)', 'has(rescuer,comb)', 'poisoned(comb)', 'intact(beanstalk)', 'rescued_with_comb(snow_white)']
    state_rows = [['状态', '活着', '死亡', '持梳', '梳带毒', '豆茎完整', '复活记录']]
    for state in trace['states']:
        state_rows.append([state['index'], *[int(state['facts'][name]) for name in watched]])
    flow = [p('白雪公主同时是巨人和女巫', title),
        p('2026-10-21 会议 · 2026-10-20 实验 · 三来源、一个共享身份、可执行计划', small),
        p(f"主条件：{main['plan_length']} 步有效解，观测耗时 {main['elapsed_seconds']:.3f} 秒。HANS_NP、JACK_NP、SNOW 都有动作实际执行。全部 56 个源动作模板先导出，再施加显式角色许可和生死一致性场景约束。"),
        p('显式初态、共享身份与目标', heading),
        p('唯一角色对象 q__snow_white 同时具有 snow_white、giant、witch 三个静态角色，并具备三个来源的 entity 成员资格。两名同伴在小屋；四个角色均活着；豆茎完整，白雪公主正在下行。初始没有持梳、毒梳或复活记录。'),
        p('目标：豆茎被毁，白雪公主活着且无死亡状态，并且确实经历过“矮人拔梳复活”。最后一项是预先声明的事件观察目标；角色和完整动作序列不是从求解结果倒推。', small),
        table(plan_rows, [104, 188, 219]),
        p('逐状态验证（1＝真，0＝假）', heading),
        table(state_rows, [49, 64, 64, 64, 81, 95, 94]),
        p('4 次动作适用性与状态转移均通过，最终目标通过独立计划验证。5 个状态中，三种角色始终指向同一对象；全部角色均没有 alive 与 dead 同时为真的情况。', small),
        p('由实际计划得到的故事', heading)]
    story = (audit.parent / 'story_zh.txt').read_text(encoding='utf-8').split('\n\n说明：')[0]
    flow += [p(story), PageBreak(), p('同预算对照与解释边界', title),
        p('每条件配置 Fast Downward 26.6 / lama-first；墙钟及 CPU 20 秒，4096 MB，单 worker。一个作者构造世界 × 11 条件，不是 11 个独立故事。', small)]
    names = {'role_safe': '角色＋生死约束，三源接口', 'no_interfaces': '无接口',
        'no_possession_interface': '仅取消持有接口', 'no_death_interface': '仅取消死亡接口',
        'HANS_NP_only': '仅 HANS_NP 动作', 'JACK_NP_only': '仅 JACK_NP 动作', 'SNOW_only': '仅 SNOW 动作',
        'without_HANS_NP': '移除 HANS_NP，保留另两源', 'no_shared_identity': '取消共享身份成员资格',
        'without_life_adapter': '保留角色，去掉生死适配器', 'unrestricted_sources': '未加角色和生死约束的源模型'}
    results = [['条件', '求解器结果', '身份 / 生死检查', '观测耗时']]
    for row in data['rows']:
        status = {'solved': '有效计划', 'unsolvable': '不可解', 'wall_time_limit': '墙钟时限'}.get(row['status'], row['status'])
        check = '通过' if row['scenario_contract_pass'] is True else '失败：中间生死矛盾' if row['scenario_contract_pass'] is False else '无可审计计划'
        results.append([names[row['id']], status, check, f"{row['elapsed_seconds']:.3f} 秒"])
    flow += [table(results, [213, 85, 126, 87]),
        p('对照保留同一来源限定初态和目标；单源对照只限制动作来源，保留共同词汇。身份对照移除白雪公主的 SNOW/HANS 成员资格。未约束模型仍保留同一个复活事件观察目标。', small),
        p('为什么最终目标验证还不够', heading),
        p('去掉生死适配器后仍得到四步形式有效计划，但顺序变成“收集 → 砍断豆茎致死 → 死去的女巫继续制毒梳 → 复活”。第 2、3 步后的状态同时 alive 与 dead。额外的逐状态检查将其判为故事合同失败。'),
        p('哪些部分由作者明确加入', heading),
        p('角色许可：所有源动作参数都受静态角色约束，未分配的角色没有合法绑定。生死适配：共享死亡效果同时清除 alive；砍断豆茎后清除下行状态。事件观察：拔梳复活动作记录复活完成。源文件字节不改，但这些编译约束和效果扩展改变了可执行行为，已逐动作保存补丁。'),
        p('本例支持“明确约束下的身份一致跨源执行”。接口、角色分配和场景目标都是作者指定；不证明自动接口准确率、原始域无修改保持或故事质量提升。原源常量仍分别保留，三角色使用的是同一个显式请求对象。', small),
        p('剩余语义局限：持有关系不排他；拔梳复活不检查死亡原因或梳子是否附着；访问标志没有完整旅行与时间语义；砍树动作未要求实际持有斧头。独立语义标注仍为 0。观测耗时包含 WSL 启动、响应和终止宽限，只作描述。', small)]
    output.parent.mkdir(parents=True, exist_ok=True)
    def footer(canvas, doc):
        canvas.setFont('SnowChinese', 8)
        canvas.drawString(42, 24, 'ICAPS 2027 · 显式角色与状态合同下的可执行示范 · 自动语义与叙事质量尚未成立')
        canvas.drawRightString(A4[0] - 42, 24, str(doc.page))
    SimpleDocTemplate(str(output), pagesize=A4, leftMargin=42, rightMargin=42,
                      topMargin=33, bottomMargin=40).build(flow, onFirstPage=footer, onLaterPages=footer)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--audit', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    render(args.audit, args.output)

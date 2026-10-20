"""Three meeting pages: actual plan/story, necessity, and matched controls."""
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

def render(audit,delivery,output):
    if output.exists():raise ValueError('Use a fresh PDF path')
    data=json.loads(audit.read_text(encoding='utf-8'))
    if data['status']!='complete' or not data['hashes_unchanged'] or any(sha(Path(p))!=h for p,h in data['frozen_sha256'].items()):
        raise ValueError('Complete unchanged audit required')
    main=next(r for r in data['rows'] if r['id']=='role_safe');trace=main['execution_audit']
    steps=json.loads((delivery/'plan_steps.json').read_text(encoding='utf-8'))
    pdfmetrics.registerFont(TTFont('LongSnowChinese','C:/Windows/Fonts/simsun.ttc',subfontIndex=0))
    body=ParagraphStyle('Body',fontName='LongSnowChinese',fontSize=9.5,leading=14,spaceAfter=7,
        wordWrap='CJK',textColor=colors.HexColor('#243346'))
    title=ParagraphStyle('Title',parent=body,fontSize=18,leading=25,spaceAfter=11)
    heading=ParagraphStyle('Heading',parent=body,fontSize=12,leading=18,spaceBefore=8)
    small=ParagraphStyle('Small',parent=body,fontSize=8,leading=12,spaceAfter=6)
    cell=ParagraphStyle('Cell',parent=body,fontSize=8.5,leading=12,spaceAfter=0)
    def p(text,style=body):return Paragraph(escape(str(text)).replace('\n','<br/>'),style)
    def table(rows,widths):
        result=Table([[p(v,cell) for v in row] for row in rows],colWidths=widths,repeatRows=1)
        result.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#e6eef7')),
            ('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.white,colors.HexColor('#f4f6f9')]),
            ('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),6),
            ('RIGHTPADDING',(0,0),(-1,-1),6),('TOPPADDING',(0,0),(-1,-1),4),('BOTTOMPADDING',(0,0),(-1,-1),4)]))
        return result
    plan=[['步','来源 / 类型','实际事件','必要的因果贡献']]
    for s in steps:
        origin='源* '+s['source'] if s['origin_kind']=='source' else '新增场景规则'
        plan.append([s['step'],origin,s['label'],s['causal_purpose']])
    flow=[p('巨人女巫白雪公主：12 步可执行案例',title),
        p('2026-10-21 会议 · 2026-10-20 实验 · 一个显式共享身份世界',small),
        p(f"20 秒配置下生成 12 步计划，观测耗时 {main['elapsed_seconds']:.3f} 秒；4 步复用并增加情境条件的源动作，8 步为明确新增的场景规则。56 个源模板与 8 个新模板在搜索前导出。"),
        p('初态：白雪公主在小屋，两名同伴在屋外，杰克在工坊；四人活着，梳子在小屋架上，斧头在工坊架上，豆茎完整，尚未开始下行。唯一对象 q__snow_white 同时绑定白雪公主、巨人、女巫三种角色。'),
        p('目标：豆茎毁坏，白雪公主活着且没有死亡状态，并记录她确实经历过拔梳复活。事件目标与角色、库存、位置规则均在搜索前声明。',small),
        table(plan,[26,103,153,229]),
        p('源*表示复用原动作并增加位置、物品或准备条件；不是原域无修改运行。宝石是收集动作的附带效果，没有为它额外插入一步。',small),
        p('实际计划对应的故事',heading)]
    story=(delivery/'story_zh.txt').read_text(encoding='utf-8').split('\n\n说明：')[0]
    # Compact continuous prose keeps page one directly usable as a handout.
    paragraphs=story.split('\n\n')
    sentences=[line.split('．',1)[-1] for line in paragraphs[1].splitlines()]
    flow += [p(paragraphs[0]),p(''.join(sentences)),p(paragraphs[2],small),PageBreak(),
        p('逐步验证：每一步都能执行，也都有作用',title),
        p('独立计划验证通过；13 个离散状态中，三种角色身份保持一致，四人的场景位置各自唯一，白雪公主没有同时活着和死亡，梳子始终只在架上或由一个持有人持有。'),
        p('H＝小屋，O＝屋外，W＝工坊，T＝豆茎，L＝落地点；S＝白雪公主，R＝营救者。',small)]
    rows=[['状态','白雪位置','营救者位置','杰克位置','活 / 死','梳归属','带毒','树完整']]
    location=lambda value: 'H' if value=='q__hut' else 'O' if value=='q__outside' else 'W' if value=='q__workshop' else 'T' if value.endswith('__c_beanstalk') else 'L'
    for state in trace['states']:
        facts=state['facts'];pos=state['positions']
        owner='架上' if state['comb_on_shelf'] else 'S' if 'q__snow_white' in state['comb_owners'] else 'R'
        rows.append([state['index'],location(pos['q__snow_white'][0]),location(pos['q__rescuer'][0]),location(pos['q__jack'][0]),
            str(int(facts['alive']))+' / '+str(int(facts['dead'])),owner,int(facts['comb_poisoned']),int(facts['beanstalk_intact'])])
    flow += [table(rows,[39,72,81,72,67,62,55,65]),p('最终状态还满足复活事件记录；完整真值、场景位置、持有者与逐动作变化保存在证据包的状态表和执行轨迹中。',small),
        p('逐步删除回放',heading),p('从同一初态出发，仅删去对应步骤，保持其余动作顺序与绑定不变。以下结果说明返回的计划没有可直接删去的步骤。',small)]
    deletion=[['删去步骤','被阻断的原步骤','结果']]
    for d in trace['deletion_replays']:
        deletion.append([d['deleted_step'],d['failure']['first_inapplicable_original_step'] if d['failure'] else '最终目标',
                         '所需前置条件不成立' if d['failure'] else '复活记录等最终目标未达成'])
    flow += [table(deletion,[99,151,261]),p('11 次删除导致后续动作不可执行；删除最后一步则无法达成最终目标。每项缺失的具体 PDDL 条件均保存在 step_necessity.csv；这不是一般性的最短计划证明。',small),
        PageBreak(),p('同预算对照、动作移除与证据边界',title),
        p('Fast Downward 26.6 / lama-first；每条件墙钟和 CPU 配置 20 秒，4096 MB，单 worker。1 个构造世界 × 23 条件：11 个主/对照条件，加 12 个预先冻结的整类动作移除条件。',small)]
    names={'role_safe':'角色＋生死约束，完整接口','no_interfaces':'无接口','no_possession_interface':'取消持有接口',
        'no_death_interface':'取消死亡接口','HANS_NP_only':'仅 HANS_NP 源动作','JACK_NP_only':'仅 JACK_NP 源动作',
        'SNOW_only':'仅 SNOW 源动作','without_HANS_NP':'移除 HANS_NP 源动作','no_shared_identity':'取消共享身份成员资格',
        'without_life_adapter':'去掉生死适配器','unrestricted_sources':'无角色/生死约束（场景规则保留）'}
    results=[['条件','求解器结果','场景检查','观测耗时']]
    for row in data['rows']:
        if row['removed_schema']:continue
        status={'solved':str(row.get('plan_length'))+' 步有效计划','unsolvable':'不可解','wall_time_limit':'墙钟时限'}.get(row['status'],row['status'])
        check='通过' if row['scenario_contract_pass'] is True else '失败：生死矛盾' if row['scenario_contract_pass'] is False else '无可审计计划'
        results.append([names[row['id']],status,check,f"{row['elapsed_seconds']:.3f} 秒"])
    flow += [table(results,[226,101,105,79]),
        p('单源对照中，8 类新增场景规则仍然可用；只移除其他来源的源动作，保留共同词汇、世界与目标。“无角色/生死约束”条件也保留长版情境条件与事件观察目标，不能称为完全未改动的原始源域。',small),
        p('12 个整类动作移除对照',heading),
        p('在任何长计划搜索前，分别冻结了移除 8 类新增动作和 4 类骨干源动作的任务。12/12 都报告不可解。因此，在该场景与其角色许可下，现有其他模板没有绕过被移除动作的解。全部失败与时限行保留。'),
        p('生死反例仍被保留',heading),
        p('去掉生死适配器也得到 12 步形式有效计划，但第 9、10、11 步后的白雪公主同时 alive 与 dead，因此场景检查失败。未加角色/生死约束的条件本次超时；不能据此称其不可解。'),
        p('会议应如何表述',heading),
        p('“我们从显式初态生成了三来源共享身份的 12 步计划，区分了 4 步情境化源动作与 8 步新增场景动作。逐步删除和整类动作移除都没有发现凑数步骤。但长度和必要性成立于已声明的作者场景规则下；角色、工具、库存、旅行和魔法复活并非系统自动学出。”'),
        p('源文件未改，编译行为有显式扩展；独立语义标注仍为 0。梳子能令坠落者复活是魔法场景假设，尚无独立叙事质量评价。固定顺序、每条件一次，耗时包含 WSL 启动/响应/终止宽限，不作统计速度提升主张。',small)]
    output.parent.mkdir(parents=True,exist_ok=True)
    def footer(canvas,doc):
        canvas.setFont('LongSnowChinese',8)
        canvas.drawString(42,23,'ICAPS 2027 · 显式作者规则下的可执行长计划 · 源动作与新增场景规则分开记录')
        canvas.drawRightString(A4[0]-42,23,str(doc.page))
    SimpleDocTemplate(str(output),pagesize=A4,leftMargin=42,rightMargin=42,topMargin=31,bottomMargin=37).build(flow,onFirstPage=footer,onLaterPages=footer)

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ('audit','delivery','output'):parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args();render(args.audit,args.delivery,args.output)

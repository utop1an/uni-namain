"""Export a long-case story and causal tables from the audited actual plan."""
import argparse
import csv
import json
from pathlib import Path
from rcnc.domain_building import require_empty_output, save
from scripts.experiments.run_downward_reference import sha

LABELS={
    'enter_hut':('同伴进入小屋','让两名同伴到场，满足收集和交接的位置条件。'),
    'collect_treasure':('收集梳子和宝石','从架上取得唯一的梳子；宝石是源动作的附带效果。'),
    'take_axe':('杰克从工坊取斧','取得砍树工具，取走架上的斧头。'),
    'approach_beanstalk':('杰克携斧来到豆茎','让持斧者到达砍树位置。'),
    'hand_comb_to_witch':('把梳子交给白雪女巫','将梳子的持有权转给施法者。'),
    'stepmother_makes_poisonous_comb_and_visits_cottage':('白雪女巫制成毒梳','只有持梳且在场时才能施法，产生带毒状态。'),
    'take_comb_back':('营救者接回毒梳','恢复营救者的持梳状态，允许白雪公主离开。'),
    'begin_descent':('巨人白雪公主开始下行','将她移到豆茎上，产生砍树动作所需的下行状态。'),
    'cut_beanstalk':('杰克砍树，白雪公主坠落','毁坏豆茎，产生死亡状态，并记录落地点。'),
    'reach_fallen':('营救者携梳到达落地点','营救者与同一白雪公主到达同一位置。'),
    'apply_comb':('用毒梳完成施救准备','把梳子施用于目标，满足拔梳复活的接触条件。'),
    'dwarfs_remove_comb_rescue_snow_white':('拔梳复活并解除毒性','达成复活事件、最终活着和无死亡状态的目标。')}
STORY={
    'enter_hut':'两名同伴从屋外走进小屋。',
    'collect_treasure':'他们从架上取到唯一的一把梳子，并收集了一颗宝石。',
    'take_axe':'这时，杰克在工坊里取下斧头。',
    'approach_beanstalk':'他带着斧头来到豆茎旁。',
    'hand_comb_to_witch':'营救者把梳子交给白雪公主。',
    'stepmother_makes_poisonous_comb_and_visits_cottage':'身为女巫的白雪公主在小屋里把梳子变成毒梳。',
    'take_comb_back':'营救者从她手中接回毒梳。',
    'begin_descent':'确认梳子已经交还后，身为巨人的白雪公主离开小屋，开始沿豆茎下行。',
    'cut_beanstalk':'杰克砍断豆茎，白雪公主坠到下方，死亡状态取代了活着的状态。',
    'reach_fallen':'营救者拿着毒梳离开小屋，赶到白雪公主身旁。',
    'apply_comb':'他用毒梳接触目标，完成施救准备。',
    'dwarfs_remove_comb_rescue_snow_white':'随后，他拔去毒梳；同一个白雪公主复活，梳子的毒性也被清除。'}

def build(audit,output):
    require_empty_output(output)
    data=json.loads(audit.read_text(encoding='utf-8'))
    if data['status']!='complete' or not data['hashes_unchanged']:
        raise ValueError('Complete unchanged execution audit required')
    if any(sha(Path(p))!=h for p,h in data['frozen_sha256'].items()):
        raise ValueError('Audit source changed')
    main=next(r for r in data['rows'] if r['id']=='role_safe')['execution_audit']
    output.mkdir(parents=True)
    steps=[{**step,'label':LABELS[step['action']][0],'causal_purpose':LABELS[step['action']][1]} for step in main['steps']]
    save(output/'plan_steps.json',steps)
    story='白雪公主同时是巨人和女巫。故事开始时，她和梳子在小屋，两名同伴在屋外，杰克在工坊；豆茎完整，斧头还在架上。\n\n'
    story+='\n'.join(str(s['step'])+'．'+STORY[s['action']] for s in steps)
    story+='\n\n最后，豆茎已经毁坏；白雪公主活着、无死亡状态，并且实际经历了拔梳复活。\n\n'
    story+='说明：按实际求解计划逐步释义。4 步是增加情境约束的源动作，8 步是新增场景规则。角色、工具、持有权、移动和施救准备都是显式作者约束；梳子可令坠落者复活仍属于该魔法场景的假设，不是独立验证的叙事合理性结论。\n'
    (output/'story_zh.txt').write_text(story,encoding='utf-8')
    for name,rows in [
        ('comparison.csv',[{'condition':r['id'],'solver_status':r['status'],'plan_length':r.get('plan_length'),
            'scenario_contract_pass':r['scenario_contract_pass'],'observed_seconds':r['elapsed_seconds'],
            'removed_schema':r['removed_origin']} for r in data['rows']]),
        ('step_necessity.csv',[{'deleted_step':d['deleted_step'],'deleted_action':d['instance'],'outcome':d['outcome'],
            'first_broken_original_step':d['failure']['first_inapplicable_original_step'] if d['failure'] else None,
            'missing_conditions':json.dumps(d['failure']['unsatisfied_conditions'],ensure_ascii=False) if d['failure'] else 'final goal false'} for d in main['deletion_replays']]),
        ('causal_edges.csv',main['causal_edges']),
        ('primary_states.csv',[{'state':s['index'],**s['facts'],'positions':json.dumps(s['positions']),
            'comb_owners':json.dumps(s['comb_owners']),'comb_on_shelf':s['comb_on_shelf']} for s in main['states']])]:
        with (output/name).open('w',encoding='utf-8-sig',newline='') as file:
            writer=csv.DictWriter(file,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)
    save(output/'primary_execution.json',main)
    return data

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--audit',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();build(args.audit,args.output)

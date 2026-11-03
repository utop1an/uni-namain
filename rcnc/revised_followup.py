"""Explicit authored worlds for posthoc revised-domain mechanism checks.

No source-problem facts are pooled or used as implicit world defaults. Branch
witnesses are schema-derived engineering fixtures, not original-goal evidence.
"""
import copy
from pathlib import Path

from .glaive_merge import Source, Unsupported, action_fields, conjunction, rename_vars, rewrite, signed_effects
from .pddl import parse_sexpr, section, serialize, typed_symbols


def emit(path, expression):
    path=Path(path);path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(serialize(expression)+'\n',encoding='utf-8')


def unique(expressions):
    return list({serialize(x):x for x in expressions}.values())


def literals(expr):
    if expr and expr[0]=='and':
        return [literal for child in expr[1:] for literal in literals(child)]
    sign, atom = (False,expr[1]) if expr[0]=='not' and len(expr)==2 else (True,expr)
    if not atom or any(isinstance(v,list) for v in atom) or atom[0] in {'or','when','intends','exists','forall'}:
        raise Unsupported('Branch fixtures require conjunctive ordinary/equality preconditions')
    return [(sign,atom)]


def truth(expr, facts):
    if expr[0]=='and': return all(truth(x,facts) for x in expr[1:])
    if expr[0]=='or': return any(truth(x,facts) for x in expr[1:])
    if expr[0]=='not': return not truth(expr[1],facts)
    if expr[0]=='=': return expr[1]==expr[2]
    return tuple(expr) in facts


def branch_specs(source, name):
    """A fixed distinct-parameter binding, positive world and one-literal negatives."""
    f=action_fields(source.domain.actions[name]);params=typed_symbols(f[':parameters'])
    binding={v:'probe_v'+str(i) for i,v in enumerate(params)}
    objects={binding[v]:typ for v,typ in params.items()}
    pre=rename_vars(f[':precondition'],binding);effect=rename_vars(f[':effect'],binding)
    requirements=literals(pre)
    initial=[atom for sign,atom in requirements if sign and atom[0]!='=']
    facts={tuple(x) for x in initial}
    if not truth(pre,facts): raise Unsupported('Distinct witness binding does not satisfy preconditions')
    effects=signed_effects(effect)
    additions=sorted(atom for sign,atom in effects if sign)
    candidates=[list(atom) for atom in additions if atom not in facts]
    if not candidates: raise Unsupported('No new positive effect for a one-step intentional witness')
    goal=candidates[0]
    agents=sorted(set(rename_vars(f[':agents'],binding)))
    intentions=[['intends',agent,goal] for agent in agents]
    base={'id':'positive','objects':objects,'facts':initial,'intentions':intentions,'goal':goal,
          'call':[name,*[binding[v] for v in params]],'expected':'applicable',
          'precondition':pre,'effect':effect,'binding':binding,'parameters':params}
    results=[base]
    for i,(sign,atom) in enumerate(requirements):
        neg=copy.deepcopy(base);neg.update(id='precondition_'+str(i),expected='inapplicable',flipped_literal=[sign,atom])
        if atom[0]=='=':
            if sign: raise Unsupported('Positive equality needs a separately specified binding')
            left,right=atom[1:]
            if left not in objects or right not in objects or objects[left]!=objects[right]:
                raise Unsupported('Equality mutation needs compatible authored objects')
            substitution={right:left}
            for key in ('facts','intentions','goal','call','precondition','effect'):
                neg[key]=rename_vars(neg[key],substitution)
        elif sign:
            neg['facts']=[a for a in neg['facts'] if a!=atom]
        else:
            neg['facts'].append(atom)
        if truth(neg['precondition'],{tuple(x) for x in neg['facts']}):
            raise Unsupported('Negative fixture did not disable the source action')
        results.append(neg)
    return results


def write_native_fixture(source, spec, problem_path, plan_path):
    name=source.id+'_witness_'+spec['id']
    root=['define',['problem',name],[':domain',source.domain.name],
          [':objects',*[x for obj,typ in spec['objects'].items() for x in (obj,'-',typ)]],
          [':init',*unique(spec['facts']+spec['intentions'])],[':goal',spec['goal']]]
    emit(problem_path,root)
    emit(plan_path,['define',['plan',name+'_plan'],[':problem',name],[':steps',spec['call']]])
    return Source(source.id,source.domain_path,Path(problem_path))


def authored_problem(sources, meta, scenario, path, *, active_sources=None, separate_identity=False):
    """Export only an explicit scenario's facts, identity mapping and intentions."""
    if 'facts' not in scenario: raise ValueError('needs_initial_state')
    if 'objects' not in scenario or 'goal' not in scenario: raise ValueError('Explicit objects and goal required')
    sources={s.id:s for s in sources}
    active=set(sources) if active_sources is None else set(active_sources)
    if not active<=set(sources): raise ValueError('Unknown active source')
    terms={sid:dict(s.term_map) for sid,s in sources.items()}
    objects={};memberships=[]
    for obj,assignments in scenario['objects'].items():
        for sid,typ in assignments.items():
            s=sources[sid]
            if typ not in s.types: raise ValueError('Undeclared explicit source type')
            target=(sid+'_entity_'+obj) if separate_identity else obj
            if target in {c for other in sources.values() for c in other.term_map.values()}:
                raise ValueError('Authored object collides with source constant')
            terms[sid][obj]=target;objects[target]='object'
            memberships.extend(s.memberships(target,typ))
    def mapped(sid,formula):
        return rewrite(formula,sources[sid],meta['predicate_maps'][sid],terms[sid])
    initial=[[sid+'_active'] for sid in sorted(active)]
    initial+=memberships
    for sid,s in sources.items():
        for c,t in s.domain.constants.items():initial.extend(s.memberships(s.term_map[c],t))
    initial += [mapped(sid,formula) for sid,formula in scenario['facts']]
    # Each participant retains an explicit goal under the separate-identity control.
    for actor,goal_sid,goal in scenario['intentions']:
        actors={terms[sid][actor] for sid in sources if actor in terms[sid]}
        initial += [['intends',a,mapped(goal_sid,goal)] for a in sorted(actors)]
    goals=[mapped(sid,formula) for sid,formula in scenario['goal']]
    root=['define',['problem',scenario['id']],[':domain','revised_merged'],
          [':objects',*[x for obj in sorted(objects) for x in (obj,'-','object')]],
          [':init',*unique(initial)],[':goal',conjunction(goals)]]
    emit(path,root)
    return {'object_maps':terms,'active_sources':sorted(active),'separate_identity':separate_identity,
            'source_problem_facts_copied':0,'explicit_fact_count':len(scenario['facts'])}


def composition_scenarios():
    """Two declared diagnostic families; sizes are correlated instances."""
    result=[]
    for size in (1,3):
        left,right='tiny_stories__story_009','tiny_stories__story_089'
        objects={};facts=[];goals=[];intentions=[]
        for i in range(size):
            actor='probe_player_'+str(i);objects[actor]={left:'character',right:'character'}
            facts.append([right,['awake',actor]])
            goal=['sleeping',actor];goals.append([right,goal]);intentions.append([actor,right,goal])
        result.append({'id':'play_then_sleep_'+str(size),'family':'play_then_sleep','size':size,
            'pair':left+'__'+right,'sources':[left,right],'objects':objects,'facts':facts,'goal':goals,'intentions':intentions,
            'mechanism':'Source A can start playing without the energy precondition. Source B can end play to become tired and then sleep.',
            'limitation':'Retains source A missing energy precondition. Authored mechanical task, not an independent narrative-quality label.'})
        left,right='tiny_stories__story_070','writing_prompts__wp_060'
        actor,owner='probe_recipient','probe_owner'
        objects={actor:{left:'character',right:'character'},owner:{left:'character',right:'character'}}
        facts=[[right,['alive',actor]]];goals=[];intentions=[]
        for i in range(size):
            item='probe_garment_'+str(i);objects[item]={left:'item',right:'item'}
            facts.extend([[left,['has',owner,item]],[left,['steal-intention',actor,item]]])
            for goal in (['clean',item],['wearing',actor,item]):
                goals.append([right,goal]);intentions.append([actor,right,goal])
        result.append({'id':'transfer_clean_wear_'+str(size),'family':'transfer_clean_wear','size':size,
            'pair':left+'__'+right,'sources':[left,right],'objects':objects,'facts':facts,'goal':goals,'intentions':intentions,
            'mechanism':'Source A try-steal transfers possession; source B adjusts and wears the item. Both can clean under different preconditions.',
            'limitation':'The source operation is try-steal; no ethical or narrative-realism judgment is inferred. Original source formulas are unchanged.'})
    return result

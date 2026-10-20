"""Extend the frozen short case with explicit custody/travel/tool/rescue rules.

The twelve action-schema ablations are declared before any long-case search.
Source templates are retained, with documented additional contextual guards.
"""
import argparse
import copy
import json
from pathlib import Path
from unified_planning.io import PDDLReader
from rcnc.domain_building import require_empty_output, save
from rcnc.narrative_pipeline import map_problem
from rcnc.pddl import Predicate, parse_domain, parse_sexpr, section, serialize, write_domain
from scripts.experiments.run_downward_reference import sha

SCENE_NAMES = ['enter_hut', 'hand_comb_to_witch', 'take_comb_back', 'take_axe',
               'approach_beanstalk', 'begin_descent', 'reach_fallen', 'apply_comb']
SOURCE_BACKBONE = [('HANS_NP', 'collect_treasure'),
    ('SNOW', 'stepmother_makes_poisonous_comb_and_visits_cottage'),
    ('JACK_NP', 'cut_beanstalk'), ('SNOW', 'dwarfs_remove_comb_rescue_snow_white')]


def extend(domain, meta):
    """Return the augmented model plus an explicit action-origin registry."""
    pred = lambda s, p, *args: [meta['predicate_maps'][s][p], *args]
    role = lambda name, var: ['case_role_' + name, var]
    at = lambda actor, place: ['scene_at', actor, place]
    neg = lambda atom: ['not', atom]
    tree = meta['constant_maps']['JACK_NP']['beanstalk']
    landing = meta['constant_maps']['JACK_NP']['cottage']
    for name, arity in [('scene_at', 2), ('scene_comb_on_shelf', 2), ('scene_axe_racked', 2), ('scene_comb_applied', 2)]:
        domain.predicates[name] = Predicate(name, [('?x' + str(i), 'object') for i in range(arity)])
    for name in ('outside', 'workshop', 'tree', 'landing'):
        domain.predicates['case_role_' + name] = Predicate('case_role_' + name, [('?x', 'object')])
    registry = {target: {'kind': 'source', 'source': source, 'original_action': name,
                         'additional_context': []}
                for source, table in meta['action_maps'].items() for name, target in table.items()
                if target in domain.actions}
    for source, original in SOURCE_BACKBONE:
        target = meta['action_maps'][source][original]
        if target not in domain.actions:
            continue
        action = domain.actions[target]
        fields = dict(zip(action[2::2], action[3::2]))
        added_pre, added_eff = [], []
        if original == 'collect_treasure':
            added_pre = [at('?g', '?cottage'), at('?h', '?cottage'), ['scene_comb_on_shelf', '?pearl', '?cottage']]
            added_eff = [neg(['scene_comb_on_shelf', '?pearl', '?cottage'])]
        elif original == 'stepmother_makes_poisonous_comb_and_visits_cottage':
            added_pre = [at('?s', '?cottage'), pred('SNOW', 'has', '?s', '?comb')]
        elif original == 'cut_beanstalk':
            added_pre = [at('?mother', tree), pred('JACK_NP', 'has', '?mother', '?axe')]
            added_eff = [at('?giant', landing), neg(at('?giant', tree)),
                pred('JACK_NP', 'at', '?giant', landing), neg(pred('JACK_NP', 'at', '?giant', tree))]
        elif original == 'dwarfs_remove_comb_rescue_snow_white':
            added_pre = [at('?d', landing), at('?c', landing), ['scene_comb_applied', '?c', '?comb']]
            added_eff = [neg(['scene_comb_applied', '?c', '?comb'])]
        before = copy.deepcopy(action)
        fields[':precondition'] = ['and', fields[':precondition'], *added_pre]
        fields[':effect'] = ['and', fields[':effect'], *added_eff]
        domain.actions[target] = [':action', target, *[x for k, v in fields.items() for x in (k, v)]]
        registry[target]['additional_context'] = {'preconditions': added_pre, 'effects': added_eff,
                                                 'before': before, 'after': domain.actions[target]}
    def add(name, variables, pre, effects, meaning):
        key = 'scene__' + name
        domain.actions[key] = [':action', key, ':parameters', [x for v in variables for x in (v, '-', 'object')],
            ':precondition', ['and', *pre], ':effect', ['and', *effects]]
        registry[key] = {'kind': 'new_scenario_rule', 'source': 'SCENE', 'original_action': name, 'meaning': meaning}
    alive = lambda x: pred('SNOW', 'alive', x)
    has_r = lambda r, c: pred('HANS_NP', 'has', r, c)
    has_w = lambda s, c: pred('SNOW', 'has', s, c)
    add('enter_hut', ['?r', '?c', '?o', '?h'],
        [role('rescuer','?r'), role('companion','?c'), role('outside','?o'), role('hut','?h'),
         alive('?r'), alive('?c'), at('?r','?o'), at('?c','?o')],
        [at('?r','?h'), at('?c','?h'), neg(at('?r','?o')), neg(at('?c','?o')),
         pred('HANS_NP','at','?r','?h'), pred('HANS_NP','at','?c','?h'),
         neg(pred('HANS_NP','at','?r','?o')), neg(pred('HANS_NP','at','?c','?o'))], 'Two companions enter the hut before collecting objects.')
    add('hand_comb_to_witch', ['?r','?s','?c','?h'],
        [role('rescuer','?r'), role('witch','?s'), role('comb','?c'), role('hut','?h'),
         alive('?r'), alive('?s'), at('?r','?h'), at('?s','?h'), has_r('?r','?c')],
        [neg(has_r('?r','?c')), has_w('?s','?c')], 'Transfer the unique comb from rescuer to witch.')
    add('take_comb_back', ['?r','?s','?c','?h'],
        [role('rescuer','?r'), role('witch','?s'), role('comb','?c'), role('hut','?h'),
         alive('?r'), alive('?s'), at('?r','?h'), at('?s','?h'), has_w('?s','?c'), pred('SNOW','poisoned','?c')],
        [neg(has_w('?s','?c')), has_r('?r','?c')], 'Recover the poisoned comb before the witch departs.')
    add('take_axe', ['?j','?a','?w'],
        [role('cutter','?j'), role('axe','?a'), role('workshop','?w'), alive('?j'),
         at('?j','?w'), ['scene_axe_racked','?a','?w']],
        [pred('JACK_NP','has','?j','?a'), neg(['scene_axe_racked','?a','?w'])], 'Take the axe from the workshop rack.')
    add('approach_beanstalk', ['?j','?a','?w','?t'],
        [role('cutter','?j'),role('axe','?a'),role('workshop','?w'),role('tree','?t'),alive('?j'),
         at('?j','?w'),pred('JACK_NP','has','?j','?a')],
        [at('?j','?t'),neg(at('?j','?w')),pred('JACK_NP','at','?j','?t'),neg(pred('JACK_NP','at','?j','?w'))], 'Bring the axe to the beanstalk.')
    add('begin_descent', ['?s','?r','?c','?h','?t'],
        [role('snow_white','?s'),role('giant','?s'),role('witch','?s'),role('rescuer','?r'),
         role('comb','?c'),role('hut','?h'),role('tree','?t'),alive('?s'),at('?s','?h'),
         pred('SNOW','poisoned','?c'),pred('SNOW','has','?r','?c'),neg(has_w('?s','?c'))],
        [at('?s','?t'),neg(at('?s','?h')),pred('JACK_NP','climbing_down','?s'),
         pred('JACK_NP','at','?s','?t'),neg(pred('SNOW','at','?s','?h'))], 'After handing back the comb, the giant witch leaves the hut and starts descent.')
    add('reach_fallen', ['?r','?s','?c','?h','?l'],
        [role('rescuer','?r'),role('snow_white','?s'),role('comb','?c'),role('hut','?h'),role('landing','?l'),
         alive('?r'),at('?r','?h'),at('?s','?l'),pred('SNOW','dead','?s'),has_w('?r','?c')],
        [at('?r','?l'),neg(at('?r','?h')),neg(pred('HANS_NP','at','?r','?h'))], 'Carry the comb to the fallen Snow White.')
    add('apply_comb', ['?r','?s','?c','?l'],
        [role('rescuer','?r'),role('snow_white','?s'),role('comb','?c'),role('landing','?l'),
         alive('?r'),at('?r','?l'),at('?s','?l'),pred('SNOW','dead','?s'),has_w('?r','?c'),
         pred('SNOW','poisoned','?c'),neg(['scene_comb_applied','?s','?c'])],
        [['scene_comb_applied','?s','?c']], 'Prepare comb-based revival by applying the held comb to the fallen target.')
    return domain, registry


def prepare(short, output):
    require_empty_output(output)
    output.mkdir(parents=True)
    prior = json.loads((short / 'bundle/manifest.json').read_text(encoding='utf-8'))
    for name, digest in prior['source_sha256'].items():
        if sha(short / 'inputs' / name) != digest:
            raise ValueError('Short-case source snapshot drift')
    (output / 'inputs').mkdir()
    for p in (short / 'inputs').glob('*.pddl'):
        (output / 'inputs' / p.name).write_bytes(p.read_bytes())
    query = json.loads((short / 'query.json').read_text(encoding='utf-8'))
    query['objects'].update(outside='HANS_NP:location', workshop='JACK_NP:location')
    query['initial'] = [f for f in query['initial'] if f[0] not in ('HANS_NP:at','JACK_NP:climbing_down')]
    query['initial'] += [['HANS_NP:at','rescuer','outside'],['HANS_NP:at','companion','outside'],
                         ['SNOW:at','snow_white','hut'],['JACK_NP:at','jack','workshop']]
    save(output / 'query.json', query)
    short_contract = json.loads((short / 'scenario_contract.json').read_text(encoding='utf-8'))
    contract = {'status':'authored_before_search','base_contract':short_contract,
        'new_scenario_schemas': SCENE_NAMES,
        'source_schema_context_changes': ['Collect requires present actors and a comb on a shelf; consumes the shelf object.',
            'Poisoning requires possession and co-location.', 'Cutting requires the axe and cutter co-location; records the landing position.',
            'Revival requires co-location and an applied comb; clears the application marker.'],
        'initial_scene': {'snow_white':'hut','rescuer':'outside','companion':'outside','jack':'workshop',
                          'comb':'hut shelf','axe':'workshop rack','beanstalk':'intact','descent_started':False},
        'scope':'Authored long-form scenario; four contextualized source action types and eight new scenario rules. Not unchanged source behavior or an automatically discovered story.'}
    save(output / 'scenario_contract.json', contract)
    specifications = [(t['id'],t,None) for t in prior['tasks']]
    main = next(t for t in prior['tasks'] if t['id']=='role_safe')
    # Whole-schema removals frozen before seeing the generated long plan.
    remove_names = ['scene__'+n for n in SCENE_NAMES] + [s+':'+n for s,n in SOURCE_BACKBONE]
    specifications += [('remove_'+str(i+1).zfill(2),main,name) for i,name in enumerate(remove_names)]
    tasks=[]
    for name, old, removed in specifications:
        source_dir=short/'bundle/tasks'/old['id']
        for file,key in [('domain.pddl','domain_sha256'),('source_mapping.json','mapping_sha256')]:
            if sha(source_dir/file)!=old[key]:
                raise ValueError('Frozen short-case model drift')
        directory=output/'bundle/tasks'/name
        directory.mkdir(parents=True)
        domain=parse_domain(source_dir/'domain.pddl')
        meta=json.loads((source_dir/'source_mapping.json').read_text(encoding='utf-8'))
        domain,registry=extend(domain,meta)
        removed_target=None
        if removed:
            if ':' in removed:
                s,n=removed.split(':',1);removed_target=meta['action_maps'][s][n]
            else:
                removed_target=removed
            del domain.actions[removed_target]
            registry.pop(removed_target)
        write_domain(domain,directory/'meta_domain.pddl')
        save(directory/'meta_domain.json',meta)
        mapping=map_problem(query,directory,directory/'problem.pddl')
        root=parse_sexpr((directory/'problem.pddl').read_text(encoding='utf-8'))
        initial,goal=section(root,':init'),section(root,':goal')
        old_root=parse_sexpr((source_dir/'problem.pddl').read_text(encoding='utf-8'))
        initial.extend(f for f in section(old_root,':init')[1:] if f[0].startswith('case_role_'))
        tree=meta['constant_maps']['JACK_NP']['beanstalk'];landing=meta['constant_maps']['JACK_NP']['cottage']
        initial.extend([['case_role_outside','q__outside'],['case_role_workshop','q__workshop'],
            ['case_role_tree',tree],['case_role_landing',landing],
            ['scene_at','q__snow_white','q__hut'],['scene_at','q__rescuer','q__outside'],
            ['scene_at','q__companion','q__outside'],['scene_at','q__jack','q__workshop'],
            ['scene_comb_on_shelf','q__comb','q__hut'],['scene_axe_racked','q__axe','q__workshop']])
        goal[1].extend([['case_role_'+r,'q__snow_white'] for r in ('snow_white','giant','witch')])
        goal[1].append(['case_rescued_with_comb','q__snow_white'])
        if not old['shared_identity']:
            guards={meta['type_guards'][typ] for s in ('SNOW','HANS_NP') for typ in meta['namespaces'][s]['types'].values()}
            initial[1:]=[f for f in initial[1:] if not(len(f)==2 and f[0] in guards and f[1]=='q__snow_white')]
        (directory/'problem.pddl').write_text(serialize(root)+'\n',encoding='utf-8')
        (directory/'domain.pddl').write_bytes((directory/'meta_domain.pddl').read_bytes())
        save(directory/'action_registry.json',registry)
        save(directory/'source_mapping.json',meta)
        save(directory/'query_mapping.json',mapping)
        PDDLReader().parse_problem(str(directory/'domain.pddl'),str(directory/'problem.pddl'))
        tasks.append({'id':name,'source':'snow_white_long','representation':name,
            'base_condition':old['id'],'removed_schema':removed_target,'removed_origin':removed,
            'source_templates':sum(v['kind']=='source' for v in registry.values()),
            'new_scenario_templates':sum(v['kind']=='new_scenario_rule' for v in registry.values()),
            'domain_sha256':sha(directory/'domain.pddl'),'problem_sha256':sha(directory/'problem.pddl'),
            'registry_sha256':sha(directory/'action_registry.json'),'mapping_sha256':sha(directory/'source_mapping.json')})
    result={'status':'frozen_before_search','mode':'matched_source_representations','task_count':len(tasks),'tasks':tasks,
        'budget':{'seconds':20,'memory_mb':4096,'workers':1},'prior_manifest_sha256':sha(short/'bundle/manifest.json'),
        'query_sha256':sha(output/'query.json'),'contract_sha256':sha(output/'scenario_contract.json'),
        'implementation_sha256':{str(p):sha(p) for p in (Path(__file__),Path('rcnc/narrative_pipeline.py'),Path('rcnc/pddl.py'))},
        'scope':'One authored scene, 11 matched controls plus 12 whole-schema necessity ablations. Eight scenario rules stay available in single-source controls. All exported before search.'}
    save(output/'bundle/manifest.json',result)
    return result


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--short',type=Path,default=Path('data/validation/snow_roles_case_2026_10_20_v1'))
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    result=prepare(args.short,args.output)
    print(json.dumps({k:v for k,v in result.items() if k!='tasks'},indent=2))

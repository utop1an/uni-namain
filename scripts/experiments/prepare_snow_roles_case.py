"""Freeze an authored role-bound Snow White/giant/witch scenario and controls.

Complete source schemas are compiled first. The scenario overlay (static role
permissions, life consistency and a rescue observation goal) is explicit; it is
not claimed to preserve unrestricted source behavior.
"""
import argparse
import copy
import json
from pathlib import Path
from unified_planning.io import PDDLReader
from rcnc.aligned_domain import build
from rcnc.domain_building import require_empty_output, save
from rcnc.narrative_pipeline import map_problem
from rcnc.pddl import Predicate, parse_domain, parse_sexpr, section, serialize, typed_symbols, write_domain
from scripts.experiments.run_downward_reference import sha

SOURCES = ['HANS_NP', 'JACK_NP', 'SNOW']
ENTITY_ROLES = {
    'HANS_NP': {'?g': 'companion', '?h': 'rescuer', '?witch': 'witch', '?father': 'father',
                '?mother': 'mother', '?bird': 'bird', '?duck': 'duck'},
    'JACK_NP': {'?giant': 'giant', '?j': 'cutter', '?mother': 'cutter', '?wife': 'giant_wife',
                '?cow': 'cow', '?b': 'butcher'},
    'SNOW': {'?c': 'snow_white', '?s': 'witch', '?d': 'rescuer', '?q': 'queen', '?k': 'king',
             '?p': 'prince', '?h': 'huntsman', '?b': 'boar', '?old_woman': 'old_woman'}}
ITEM_ROLES = {'?comb': 'comb', '?pearl': 'comb', '?precious_stone': 'gem', '?axe': 'axe'}
ROLE_OBJECTS = {'snow_white': 'snow_white', 'giant': 'snow_white', 'witch': 'snow_white',
                'rescuer': 'rescuer', 'companion': 'companion', 'cutter': 'jack',
                'comb': 'comb', 'gem': 'gem', 'axe': 'axe', 'hut': 'hut'}


def variable_role(source, variable, typ):
    if typ == 'entity':
        return ENTITY_ROLES[source][variable]
    if typ == 'item':
        return ITEM_ROLES.get(variable, 'prop_' + variable[1:])
    if typ == 'location':
        return 'hut' if variable in ('?cottage', '?forest', '?room', '?home', '?path_loc', '?branch', '?stable', '?father_house', '?lake') else 'place_' + variable[1:]
    raise ValueError('Unsupported scenario parameter type: ' + typ)


def prepare(inputs, output):
    require_empty_output(output)
    output.mkdir(parents=True)
    snapshot = output / 'inputs'
    snapshot.mkdir()
    domains = {}
    for source in SOURCES:
        for suffix in ('domainfile', 'problemfile'):
            name = source + '_' + suffix + '.pddl'
            (snapshot / name).write_bytes((inputs / name).read_bytes())
        domains[source] = parse_domain(snapshot / (source + '_domainfile.pddl'))
    spec = {'version': 1, 'decision_basis': 'authored_assumption',
        'source_sha256': {p.name: sha(p) for p in snapshot.glob('*_domainfile.pddl')},
        'type_groups': [{'members': [s + ':entity' for s in SOURCES], 'evidence': 'Explicit shared character roles'},
                        {'members': ['HANS_NP:item', 'SNOW:item'], 'evidence': 'Explicit shared comb prop'}],
        'predicate_groups': [
            {'id': 'death', 'evidence': 'Authored Boolean death interface; life adapter separately declared',
             'members': [{'predicate': s + ':dead', 'order': [0]} for s in SOURCES]},
            {'id': 'possession', 'evidence': 'Authored shared entity-item possession, not independent gold',
             'members': [{'predicate': s + ':has', 'order': [0, 1]} for s in ('HANS_NP', 'SNOW')]}]}
    query = {'objects': {
        'snow_white': [s + ':entity' for s in SOURCES],
        'rescuer': ['HANS_NP:entity', 'SNOW:entity'],
        'companion': ['HANS_NP:entity', 'SNOW:entity'],
        'jack': ['JACK_NP:entity', 'SNOW:entity'],
        'comb': ['HANS_NP:item', 'SNOW:item'], 'gem': 'HANS_NP:item', 'axe': 'JACK_NP:item',
        'hut': ['HANS_NP:location', 'SNOW:location']},
        'initial': [['SNOW:alive', actor] for actor in ('snow_white', 'rescuer', 'companion', 'jack')]
            + [['HANS_NP:at', 'rescuer', 'hut'], ['HANS_NP:at', 'companion', 'hut'],
               ['JACK_NP:intact', 'JACK_NP:beanstalk'], ['JACK_NP:climbing_down', 'snow_white']],
        'goal': {'positive': [['SNOW:alive', 'snow_white']],
                 'negative': [['JACK_NP:dead', 'snow_white'], ['JACK_NP:intact', 'JACK_NP:beanstalk']]},
        'sources': SOURCES, 'alignment': spec}
    save(output / 'query.json', query)
    roles = {}
    for source, domain in domains.items():
        roles[source] = {}
        for name, action in domain.actions.items():
            params = typed_symbols(dict(zip(action[2::2], action[3::2])).get(':parameters', []))
            roles[source][name] = {var: variable_role(source, var, typ) for var, typ in params.items()}
    contract = {'status': 'authored_before_search', 'role_objects': ROLE_OBJECTS, 'parameter_roles': roles,
        'role_policy': 'Static parameter permissions on every source action. Uncast roles have no legal binding; all 56 source templates retained before source-removal controls.',
        'life_adapter': 'Positive writes to the predicate aligned with SNOW:dead also delete SNOW:alive for that object, preserving conditional contexts. JACK cut_beanstalk also ends climbing_down.',
        'rescue_observer': 'SNOW dwarfs_remove_comb_rescue_snow_white additionally sets case_rescued_with_comb(?c); required by the authored goal. No fixed complete action sequence is supplied.',
        'negative_controls': 'Same role contract and qualified world/goal; interfaces or action sources removed explicitly. Identity control removes SNOW/HANS membership of snow_white.',
        'scope': 'Authored role-constrained scenario, not unrestricted source preservation or automatically learned alignment. Source files remain unchanged; compiled permissions/effects are modified and versioned.'}
    save(output / 'scenario_contract.json', contract)
    conditions = [
        ('role_safe', {'death', 'possession'}, set(SOURCES), True, True, True),
        ('no_interfaces', set(), set(SOURCES), True, True, True),
        ('no_possession_interface', {'death'}, set(SOURCES), True, True, True),
        ('no_death_interface', {'possession'}, set(SOURCES), True, True, True),
        *[(s + '_only', {'death', 'possession'}, {s}, True, True, True) for s in SOURCES],
        ('without_HANS_NP', {'death', 'possession'}, {'JACK_NP', 'SNOW'}, True, True, True),
        ('no_shared_identity', {'death', 'possession'}, set(SOURCES), True, True, False),
        ('without_life_adapter', {'death', 'possession'}, set(SOURCES), True, False, True),
        ('unrestricted_sources', {'death', 'possession'}, set(SOURCES), False, False, True)]
    base_cache, tasks = {}, []
    for name, interfaces, retained, constrained, life_safe, identity in conditions:
        key = '_'.join(sorted(interfaces)) or 'none'
        if key not in base_cache:
            projected = copy.deepcopy(spec)
            projected['predicate_groups'] = [g for g in spec['predicate_groups'] if g['id'] in interfaces]
            base = output / 'base_models' / key
            build(snapshot, base, projected)
            mapping = map_problem(query, base, base / 'mapped_problem.pddl')
            save(base / 'query_mapping.json', mapping)
            base_cache[key] = base
        base = base_cache[key]
        domain = parse_domain(base / 'meta_domain.pddl')
        meta = json.loads((base / 'meta_domain.json').read_text(encoding='utf-8'))
        problem = parse_sexpr((base / 'mapped_problem.pddl').read_text(encoding='utf-8'))
        initial, goal = section(problem, ':init'), section(problem, ':goal')
        used_roles = {role for table in roles.values() for params in table.values() for role in params.values()}
        for role in sorted(used_roles):
            domain.predicates['case_role_' + role] = Predicate('case_role_' + role, [('?x', 'object')])
        initial.extend([['case_role_' + role, 'q__' + obj] for role, obj in ROLE_OBJECTS.items()])
        for role in ('snow_white', 'giant', 'witch'):
            goal[1].append(['case_role_' + role, 'q__snow_white'])
        domain.predicates['case_rescued_with_comb'] = Predicate('case_rescued_with_comb', [('?x', 'object')])
        goal[1].append(['case_rescued_with_comb', 'q__snow_white'])
        alive = meta['predicate_maps']['SNOW']['alive']
        dead = meta['predicate_maps']['SNOW']['dead']
        def consistent_effect(expr):
            if expr[0] == 'and':
                return ['and', *[consistent_effect(child) for child in expr[1:]]]
            if expr[0] == 'when':
                return ['when', expr[1], consistent_effect(expr[2])]
            if expr[0] == 'forall':
                return ['forall', expr[1], consistent_effect(expr[2])]
            if expr[0] == dead:
                return ['and', expr, ['not', [alive, *expr[1:]]]]
            return expr
        patches = []
        for source in SOURCES:
            for original_name, target in meta['action_maps'][source].items():
                if source not in retained:
                    del domain.actions[target]
                    continue
                action = domain.actions[target]
                fields = dict(zip(action[2::2], action[3::2]))
                added = []
                if constrained:
                    added = [['case_role_' + role, var] for var, role in roles[source][original_name].items()]
                    # Living agents collect/rescue/cut; victims are not forced alive.
                    agents = ('?g', '?h') if source == 'HANS_NP' else ('?mother', '?j') if source == 'JACK_NP' else ('?d',)
                    added.extend([[alive, var] for var in agents if var in roles[source][original_name]])
                    fields[':precondition'] = ['and', fields[':precondition'], *added]
                original_effect = fields[':effect']
                if life_safe:
                    fields[':effect'] = consistent_effect(fields[':effect'])
                    if source == 'JACK_NP' and original_name == 'cut_beanstalk':
                        fields[':effect'] = ['and', fields[':effect'], ['not', [meta['predicate_maps'][source]['climbing_down'], '?giant']]]
                if source == 'SNOW' and original_name == 'dwarfs_remove_comb_rescue_snow_white':
                    fields[':effect'] = ['and', fields[':effect'], ['case_rescued_with_comb', '?c']]
                domain.actions[target] = [':action', target, *[item for k, v in fields.items() for item in (k, v)]]
                patches.append({'source': source, 'action': original_name, 'parameter_guards': added,
                    'effect_before': original_effect, 'effect_after': fields[':effect']})
        if not identity:
            guards = {meta['type_guards'][typ] for s in ('SNOW', 'HANS_NP') for typ in meta['namespaces'][s]['types'].values()}
            initial[1:] = [fact for fact in initial[1:] if not (len(fact) == 2 and fact[0] in guards and fact[1] == 'q__snow_white')]
        directory = output / 'bundle/tasks' / name
        directory.mkdir(parents=True)
        write_domain(domain, directory / 'domain.pddl')
        (directory / 'problem.pddl').write_text(serialize(problem) + '\n', encoding='utf-8')
        PDDLReader().parse_problem(str(directory / 'domain.pddl'), str(directory / 'problem.pddl'))
        save(directory / 'source_mapping.json', meta)
        save(directory / 'scenario_patches.json', patches)
        tasks.append({'id': name, 'source': 'snow_white_giant_witch', 'representation': name,
            'retained_sources': sorted(retained), 'interfaces': sorted(interfaces), 'role_guards': constrained,
            'life_adapter': life_safe, 'shared_identity': identity, 'source_action_templates': len(domain.actions),
            'domain_sha256': sha(directory / 'domain.pddl'), 'problem_sha256': sha(directory / 'problem.pddl'),
            'mapping_sha256': sha(directory / 'source_mapping.json'), 'patches_sha256': sha(directory / 'scenario_patches.json')})
    result = {'status': 'frozen_before_search', 'mode': 'matched_source_representations', 'task_count': len(tasks),
        'tasks': tasks, 'budget': {'seconds': 20, 'memory_mb': 4096, 'workers': 1},
        'query_sha256': sha(output / 'query.json'), 'contract_sha256': sha(output / 'scenario_contract.json'),
        'implementation_sha256': {str(p): sha(p) for p in (Path(__file__), Path('rcnc/aligned_domain.py'), Path('rcnc/narrative_pipeline.py'))},
        'source_sha256': {p.name: sha(p) for p in snapshot.glob('*.pddl')},
        'scope': 'One authored shared-identity world with eleven conditions, not eleven independent stories. Role/life/event overlays explicitly differ from source models; no source problem facts imported.'}
    save(output / 'bundle/manifest.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inputs', type=Path, default=Path('data/validation/meeting_matched_2026_10_20_v1/inputs'))
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = prepare(args.inputs, args.output)
    print(json.dumps({k: v for k, v in result.items() if k != 'tasks'}, indent=2))

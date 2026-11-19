"""Frozen BIRT/SOUP/ACCO conditional-merge development comparison.

Sense cards are explicit agent-authored machine judgments made from source
names and formulas. No new model API call or independent semantic label is
implied. Selection is based on pre-search schema inspection, not solver success.
"""
import argparse
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import shutil

from rcnc.conditional_merge import build, fields, symbol_digest
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.narrative_pipeline import map_problem
from rcnc.pddl import parse_domain, serialize, write_domain


SOURCES = ('ACCO', 'BIRT', 'SOUP')
CONDITIONS = ('no_share', 'predicate_only', 'conditional', 'formal_only',
              'remove_ACCO', 'remove_BIRT', 'remove_SOUP')


def sense(value, concept, roles, description, evidence, scope):
    return {'concept': concept, 'roles': roles, 'description': description, 'evidence': evidence,
            'scope': scope, 'confidence': .95, 'symbol_sha256': symbol_digest(value),
            'judgment_origin': 'agent_authored_machine_analysis', 'independent_label': False}


def specification(inputs):
    ds = {s: parse_domain(inputs / f'{s}_domainfile.pddl') for s in SOURCES}
    def pred(source, name, concept, roles, description, scope, order=None):
        value = ds[source].predicates[name]
        usages = [serialize(a) for a in ds[source].actions.values() if f'({name} ' in serialize(a)]
        return {'predicate': source + ':' + name, 'order': order or list(range(value.arity)),
                'semantics': sense(value, concept, roles, description, usages, scope)}
    def action(source, name, concept, roles, description, scope):
        value = ds[source].actions[name]
        return {'action': source + ':' + name, 'order': list(range(len(roles))),
                'semantics': sense(value, concept, roles, description, [serialize(value)], scope)}
    return {'version': 1, 'decision_basis': 'machine_hypothesis', 'semantic_min_confidence': .9,
        'source_sha256': {p.name: digest(p) for p in inputs.glob('*_domainfile.pddl')},
        'judgment_scope': 'Development hypotheses from symbol meanings and source action context; not calibrated confidence or independent semantic evaluation',
        'type_groups': [{'members': [s + ':' + t for s in SOURCES],
                         'evidence': 'Common declared participant role, retaining each source membership guard'}
                        for t in ('entity', 'item', 'location')],
        'predicate_candidates': [
            {'id': 'custody', 'evidence': 'Both HAS relations track an entity holding an item; loss on handoff is retained', 'members': [
                pred('ACCO', 'has', 'holds_item', ['holder', 'item'], 'Entity possesses an item in the action model', 'physical_custody'),
                pred('BIRT', 'has', 'holds_item', ['holder', 'item'], 'Entity possesses the obtained key or other item', 'physical_custody')]},
            {'id': 'location', 'evidence': 'Entity location, with matched source/destination effects', 'members': [
                pred('BIRT', 'at', 'located_at', ['entity', 'place'], 'Entity is at a location', 'entity_location'),
                pred('SOUP', 'at', 'located_at', ['entity', 'place'], 'Entity is at a location', 'entity_location')]},
            {'id': 'state_bad_alias', 'evidence': 'Historical false common STATE candidate retained as a negative control', 'members': [
                pred('BIRT', 'shrunk', 'body_shrunken', ['entity'], 'Entity has become physically small', 'body_size'),
                pred('ACCO', 'performing_show', 'performing_entertainment', ['entity'], 'Entity is performing a show', 'ongoing_performance')]},
            {'id': 'ownership_bad_alias', 'evidence': 'Historical carried_item correspondence; ownership and carrying are different', 'members': [
                pred('ACCO', 'owned_by', 'owned_by', ['item', 'owner'], 'Item belongs to an owner', 'ownership', [1, 0]),
                pred('BIRT', 'lantern_carried', 'carrying_lantern', ['carrier', 'item'], 'Entity is carrying a lantern', 'physical_carrying')]}],
        'action_candidates': [
            {'id': 'travel', 'members': [
                action('BIRT', 'travel_to_trysting_place', 'relocate_entity', ['traveler', 'destination', 'origin'],
                       'Travel from origin to destination; remove old location and add new one', 'physical_relocation'),
                action('SOUP', 'travel_to', 'relocate_entity', ['traveler', 'destination', 'origin'],
                       'Travel with a held skewer; remove old location and add new one', 'physical_relocation')]},
            {'id': 'activation_bad_alias', 'members': [
                action('BIRT', 'turn_key_on_beech', 'activate_magic_entrance', ['actor', 'key', 'place'],
                       'Open a magical entrance and obtain invitation and possession', 'magic_entrance'),
                action('ACCO', 'tinker_carry_home', 'carry_item_home', ['carrier', 'item'],
                       'Carry a possessed item to Jhosiu', 'item_transport')]}]}


def remove_source(domain, meta, source):
    """Delete exactly this source's branches; retain other origins of a merge."""
    result = copy.deepcopy(domain)
    for name, origins in meta['action_origins'].items():
        kept = [o for o in origins if o['source'] != source]
        if not kept:
            del result.actions[name]
        elif len(kept) != len(origins):
            result.actions[name][result.actions[name].index(':precondition') + 1] = [
                'or', *[o['branch_precondition'] for o in kept]]
    return result


def queries():
    common = {'objects': {'hero': [s + ':entity' for s in SOURCES],
                          'token': [s + ':item' for s in SOURCES],
                          'start': [s + ':location' for s in SOURCES],
                          'dest': [s + ':location' for s in SOURCES]},
              'initial': [['BIRT:at', 'hero', 'start']]}
    goals = {'handoff': {'positive': [['ACCO:hanging', 'token']]},
             'wealth_and_understanding': {'positive': [['ACCO:wealthy', 'hero'], ['SOUP:has_understanding', 'hero']]},
             'relocation_and_wealth': {'positive': [['ACCO:wealthy', 'hero'], ['SOUP:has_understanding', 'hero'],
                                                   ['SOUP:at', 'hero', 'dest']],
                                      'negative': [['BIRT:at', 'hero', 'start']]}}
    return {name: {**copy.deepcopy(common), 'goal': goal} for name, goal in goals.items()}


def prepare(output):
    require_empty_output(output); output.mkdir(parents=True)
    inputs = output / 'inputs'; inputs.mkdir()
    for source in SOURCES:
        for kind in ('domain', 'problem'):
            name = f'{source}_{kind}file.pddl'
            shutil.copyfile(Path('data/narra-domains') / name, inputs / name)
    spec = specification(inputs)
    save(output / 'specification.json', spec)
    cases = queries(); save(output / 'queries.json', cases)
    protocol = {'status': 'frozen_before_build_and_search', 'registered_utc': datetime.now(timezone.utc).isoformat(),
        'sources': list(SOURCES), 'selection_basis': 'Pre-search schema inspection identifies same-effect relocation with different applicability; ACCO supplies custody consumers',
        'source_kind': 'Previously used learned narrative development domains',
        'semantic_judgments': 'Agent-authored machine hypotheses; zero external inference calls and zero independent labels',
        'original_conditions': ['native', *CONDITIONS[:4]], 'cross_conditions': list(CONDITIONS),
        'task_count': 38, 'budget': {'seconds': 20, 'memory_mb': 4096, 'workers': 1, 'attempts': 1},
        'world_policy': 'Original worlds separate and unchanged; three authored cross-source tasks share one explicit new world, no imported source initial facts',
        'expected_controls': 'Do not replace failures or enforce a merge rate. Equal-effect OR fusion should preserve predicate-only reachability, not create new transitions.',
        'specification_sha256': digest(output / 'specification.json'), 'queries_sha256': digest(output / 'queries.json')}
    trap = {'objects': copy.deepcopy(cases['handoff']['objects']),
            'initial': [['ACCO:exhibition_ready', 'hero'], ['ACCO:has', 'hero', 'token']],
            'goal': {'positive': [['BIRT:shrunk', 'hero']], 'negative': [['BIRT:pellet_eaten', 'hero']]}}
    protocol['semantic_trap'] = trap
    protocol['semantic_trap_conditions'] = ['conditional', 'formal_only']
    save(output / 'protocol.json', protocol)
    models = {}
    for condition in CONDITIONS[:4]:
        condition_spec = copy.deepcopy(spec)
        if condition == 'no_share':
            condition_spec['predicate_candidates'] = []; condition_spec['action_candidates'] = []
        folder = output / 'models' / condition
        build(inputs, folder, condition_spec, merge_actions=condition != 'predicate_only',
              semantic_mode='off_diagnostic' if condition == 'formal_only' else 'required')
        models[condition] = folder
    primary = models['conditional']
    primary_meta = json.loads((primary / 'meta_domain.json').read_text(encoding='utf-8'))
    primary_domain = parse_domain(primary / 'meta_domain.pddl')
    rows = []
    bundle = output / 'bundle'; bundle.mkdir()
    def task(case, condition, domain, problem, family):
        identifier = case + '__' + condition
        target = bundle / 'tasks' / identifier; target.mkdir(parents=True)
        shutil.copyfile(domain, target / 'domain.pddl'); shutil.copyfile(problem, target / 'problem.pddl')
        rows.append({'id': identifier, 'source': case, 'problem_id': case, 'family': family,
                     'representation': condition, 'admission_status': 'ready',
                     'domain_sha256': digest(target / 'domain.pddl'), 'problem_sha256': digest(target / 'problem.pddl')})
    for source in SOURCES:
        task(source, 'native', inputs / f'{source}_domainfile.pddl', inputs / f'{source}_problemfile.pddl', 'original')
        for condition, folder in models.items():
            task(source, condition, folder / 'meta_domain.pddl', folder / 'problems' / f'{source}_problemfile.pddl', 'original')
    for source in SOURCES:
        folder = output / 'models' / ('remove_' + source); folder.mkdir()
        write_domain(remove_source(primary_domain, primary_meta, source), folder / 'meta_domain.pddl')
    for case, query in cases.items():
        for condition in CONDITIONS:
            folder = models.get(condition, primary)
            problem = output / 'models' / condition / (case + '.pddl')
            map_problem(query, folder, problem)
            task(case, condition, output / 'models' / condition / 'meta_domain.pddl', problem, 'cross')
    for condition in protocol['semantic_trap_conditions']:
        folder = models[condition]; problem = folder / 'semantic_trap.pddl'
        map_problem(trap, folder, problem)
        task('semantic_trap', condition, folder / 'meta_domain.pddl', problem, 'semantic_control')
    assert len(rows) == protocol['task_count']
    save(bundle / 'manifest.json', {'status': 'frozen_before_search', 'mode': 'external_source_preservation',
                                  'task_count': len(rows), 'tasks': rows})
    code = [Path(p) for p in ('rcnc/conditional_merge.py', 'rcnc/aligned_domain.py', 'rcnc/domain_union.py',
            'rcnc/pddl.py', 'rcnc/pddl_checks.py', 'rcnc/domain_building.py', 'rcnc/narrative_pipeline.py',
            'rcnc/validation.py', 'scripts/experiments/run_union_regression.py',
            'scripts/experiments/run_conditional_merge.py', 'scripts/experiments/frozen_solver.py',
            'scripts/experiments/run_downward_reference.py', 'scripts/audit/audit_conditional_merge.py')]
    hashes = snapshot_implementation(output, code)
    frozen = [p for p in output.rglob('*') if p.is_file() and 'implementation' not in p.parts]
    save(output / 'manifest.json', {'status': 'frozen_before_search', 'task_count': len(rows), 'rows': rows,
         'budget': protocol['budget'], 'input_sha256': {p.as_posix(): digest(p) for p in frozen},
         'implementation_sha256': hashes})
    return {'status': 'prepared', 'tasks': len(rows), 'output': str(output)}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['prepare', 'execute'])
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    if args.mode == 'prepare': result = prepare(args.output)
    else:
        from scripts.experiments.frozen_solver import execute
        result = execute(args.output)
    print(json.dumps({k: result[k] for k in ('status', 'tasks', 'task_count', 'status_counts', 'output') if k in result}, indent=2))

"""Freeze automatic judgments and a seven-source conditional-merge matrix."""
import argparse
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import shutil

from prompts import prompt_sources

from rcnc.conditional_merge import build
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.model_semantics import prepare as prepare_model, run as run_model
from rcnc.narrative_pipeline import map_problem
from rcnc.pddl import parse_domain, parse_sexpr, section, serialize, write_domain
from scripts.experiments.run_conditional_merge import queries as anchor_queries, remove_source


BUNDLES = {'anchor': ['ACCO', 'BIRT', 'SOUP'], 'puss_woe': ['PUSS', 'WOE'], 'snow_pigs': ['SNOW', 'PIGS_NP']}
MODEL_DIGEST = 'a2af6cc3eb7fa8be8504abaf9b04e88f17a119ec3f04a3addf55f92841195f5a'


def read(path): return json.loads(path.read_text(encoding='utf-8'))


def pairs():
    values = {
        'anchor': [('custody', 'predicate', 'ACCO:has', 'BIRT:has'),
                   ('location', 'predicate', 'BIRT:at', 'SOUP:at'),
                   ('state_bad_alias', 'predicate', 'BIRT:shrunk', 'ACCO:performing_show'),
                   ('ownership_bad_alias', 'predicate', 'ACCO:owned_by', 'BIRT:lantern_carried'),
                   ('travel', 'action', 'BIRT:travel_to_trysting_place', 'SOUP:travel_to'),
                   ('activation_bad_alias', 'action', 'BIRT:turn_key_on_beech', 'ACCO:tinker_carry_home')],
        'puss_woe': [('custody', 'predicate', 'PUSS:has', 'WOE:has'),
                     ('location', 'predicate', 'PUSS:at', 'WOE:at'),
                     ('purchase_trade', 'action', 'PUSS:buy_boots', 'WOE:trade_assets_for_money'),
                     ('gift_payment', 'action', 'PUSS:give_bag_to_cat', 'WOE:receive_payment')],
        'snow_pigs': [('alive', 'predicate', 'SNOW:alive', 'PIGS_NP:alive'),
                      ('dead', 'predicate', 'SNOW:dead', 'PIGS_NP:dead'),
                      ('location', 'predicate', 'SNOW:at', 'PIGS_NP:at'),
                      ('custody', 'predicate', 'SNOW:has', 'PIGS_NP:has'),
                      ('fatal_item', 'action', 'SNOW:snow_white_eats_poisoned_apple_and_dies', 'PIGS_NP:wolf_falls_into_pot_and_is_boiled'),
                      ('receive_item', 'action', 'SNOW:queen_pricks_finger', 'PIGS_NP:receive_material')]}
    return [{'id': bundle + '_' + name, 'bundle': bundle, 'kind': kind, 'references': [left, right]}
            for bundle, items in values.items() for name, kind, left, right in items]


def worlds():
    result = {'anchor': anchor_queries()}
    def objects(sources, entities, items, locations):
        return {name: [s + ':' + typ for s in sources] for names, typ in
                ((entities, 'entity'), (items, 'item'), (locations, 'location')) for name in names}
    base = {'objects': objects(BUNDLES['puss_woe'], ['hero'], ['coin', 'coat', 'wine'], ['tavern']),
            'initial': [['WOE:at', 'hero', 'tavern']]}
    result['puss_woe'] = {
        'obtain_and_drink': {**copy.deepcopy(base), 'goal': {'positive': [['WOE:drunk', 'hero']]}},
        'drink_and_dress': {**copy.deepcopy(base), 'goal': {'positive': [['WOE:drunk', 'hero'], ['PUSS:wearing', 'hero', 'coat']],
                                                        'negative': [['PUSS:has', 'hero', 'coat']]}}}
    base = {'objects': objects(BUNDLES['snow_pigs'], ['hero'], ['poison', 'material'], ['home']),
            'initial': [['SNOW:dead', 'hero'], ['SNOW:poisoned', 'poison'], ['SNOW:at', 'hero', 'home']]}
    result['snow_pigs'] = {
        'revive_and_build': {**copy.deepcopy(base), 'goal': {'positive': [['PIGS_NP:house_intact', 'home']], 'negative': [['SNOW:dead', 'hero']]}},
        'revive_build_knock': {**copy.deepcopy(base), 'goal': {'positive': [['PIGS_NP:house_intact', 'home'], ['PIGS_NP:entry_requested', 'hero', 'home']],
                                                           'negative': [['SNOW:dead', 'hero']]}}}
    return result


def prepare(output, schema_policy='free_fields', *, model='gemma3:4b', model_digest=MODEL_DIGEST, num_predict=1400):
    require_empty_output(output); output.mkdir(parents=True)
    inputs = output / 'inputs'; inputs.mkdir()
    for source in sorted({s for ss in BUNDLES.values() for s in ss}):
        for kind in ('domain', 'problem'):
            name = f'{source}_{kind}file.pddl'; shutil.copyfile(Path('data/narra-domains') / name, inputs / name)
    protocol = {'status': 'frozen_before_model_and_solver', 'created_utc': datetime.now(timezone.utc).isoformat(),
                'bundles': BUNDLES, 'pairs': pairs(), 'queries': worlds(),
                'native_conditions': ['native', 'no_share', 'model_predicate', 'model_full'],
                'witness_goals': {'PUSS': ['has', 'puss', 'boots'], 'WOE': ['work_done', 'poor_brother', 'rich_brother'],
                                  'SNOW': ['fair', 'prince'], 'PIGS_NP': ['has', 'pig1', 'straw_bundle']},
                'solver_tasks': 70, 'budget': {'seconds': 20, 'memory_mb': 4096, 'workers': 1, 'attempts': 1},
                'semantic_threshold': .9, 'selection': 'Pre-search authored candidate list and seven explicit tasks. No outcome-based source or candidate replacement.',
                'scope': 'Seven known source domains; two additional source pairs, not independently authored or held-out families. Native unavailable plans stay unavailable; witness goals are separate units.'}
    if schema_policy in ('coupled_fields', 'semantic_facets'):
        protocol['solver_tasks'] = 72
        protocol['semantic_trap'] = {'objects': copy.deepcopy(worlds()['anchor']['handoff']['objects']),
            'initial': [['ACCO:exhibition_ready', 'hero'], ['ACCO:has', 'hero', 'token']],
            'goal': {'positive': [['BIRT:shrunk', 'hero']], 'negative': [['BIRT:pellet_eaten', 'hero']]}}
        protocol['comparison_scope'] = 'Same16candidate pairs and70primary solver tasks; two additional known semantic-trap probes are a separate diagnostic denominator.'
    protocol['schema_policy'] = schema_policy
    save(output / 'protocol.json', protocol)
    prepare_model(inputs, pairs(), output / 'judgments', model=model, model_digest=model_digest, total_seconds=900, request_seconds=120, schema_policy=schema_policy, num_predict=num_predict)
    return {'status': 'prepared', 'candidates': len(pairs()), 'solver_tasks': protocol['solver_tasks']}


def compile_tasks(output):
    if (output / 'manifest.json').exists(): raise ValueError('Tasks already frozen')
    protocol = read(output / 'protocol.json')
    judgments = read(output / 'judgments/report.json')
    if judgments['status'] != 'complete' or not judgments['inputs_unchanged'] or not judgments['implementation_unchanged']:
        raise ValueError('Completed stable model run required')
    groups = {g['id']: g for g in read(output / 'judgments/groups.json')['groups']}
    tasks = []; models = {}; admissions = []
    def task(identifier, family, source, representation, domain, problem, bundle):
        folder = output / 'bundle/tasks' / identifier; folder.mkdir(parents=True)
        shutil.copyfile(domain, folder / 'domain.pddl'); shutil.copyfile(problem, folder / 'problem.pddl')
        tasks.append({'id': identifier, 'family': family, 'problem_id': source, 'source': source,
                      'bundle': bundle, 'representation': representation, 'admission_status': 'ready',
                      'domain_sha256': digest(folder / 'domain.pddl'), 'problem_sha256': digest(folder / 'problem.pddl')})
    for bundle, sources in protocol['bundles'].items():
        inputs = output / 'bundle_inputs' / bundle; inputs.mkdir(parents=True)
        for source in sources:
            for kind in ('domain', 'problem'):
                name = f'{source}_{kind}file.pddl'; shutil.copyfile(output / 'inputs' / name, inputs / name)
        spec = {'version': 1, 'decision_basis': 'machine_hypothesis', 'semantic_min_confidence': protocol['semantic_threshold'],
                'source_sha256': {p.name: digest(p) for p in inputs.glob('*_domainfile.pddl')},
                'type_groups': [{'members': [s + ':' + t for s in sources], 'evidence': 'Explicit common declared type role, source guards retained'}
                                for t in ('entity', 'item', 'location')]}
        for kind in ('predicate', 'action'):
            spec[kind + '_candidates'] = [groups[p['id']] for p in protocol['pairs'] if p['bundle'] == bundle and p['kind'] == kind]
        for condition in ('no_share', 'model_predicate', 'model_full'):
            applied = copy.deepcopy(spec)
            if condition == 'no_share': applied.update(predicate_candidates=[], action_candidates=[])
            folder = output / 'models' / bundle / condition
            report = build(inputs, folder, applied, merge_actions=condition == 'model_full')
            models[bundle, condition] = folder
            admissions.append({'bundle': bundle, 'condition': condition, 'report': str(folder / 'validation.json'), 'counts': report['counts']})
        for source in sources:
            task(source + '__native', 'original', source, 'native', inputs / f'{source}_domainfile.pddl', inputs / f'{source}_problemfile.pddl', bundle)
            for condition in ('no_share', 'model_predicate', 'model_full'):
                folder = models[bundle, condition]
                task(source + '__' + condition, 'original', source, condition, folder / 'meta_domain.pddl', folder / 'problems' / f'{source}_problemfile.pddl', bundle)
        primary = models[bundle, 'model_full']; meta = read(primary / 'meta_domain.json')
        domain = parse_domain(primary / 'meta_domain.pddl')
        for source in sources:
            folder = output / 'models' / bundle / ('remove_' + source); folder.mkdir()
            write_domain(remove_source(domain, meta, source), folder / 'meta_domain.pddl')
        for case, query in protocol['queries'][bundle].items():
            for condition in ['no_share', 'model_predicate', 'model_full', *['remove_' + s for s in sources]]:
                folder = models.get((bundle, condition), primary)
                target = output / 'models' / bundle / condition
                problem = target / (case + '.pddl'); map_problem(query, folder, problem)
                task(bundle + '__' + case + '__' + condition, 'cross', case, condition, target / 'meta_domain.pddl', problem, bundle)
    for source, goal in protocol['witness_goals'].items():
        bundle = next(b for b, ss in BUNDLES.items() if source in ss)
        inputs = output / 'witness_inputs' / source; inputs.mkdir(parents=True)
        shutil.copyfile(output / 'inputs' / f'{source}_domainfile.pddl', inputs / f'{source}_domainfile.pddl')
        problem = parse_sexpr((output / 'inputs' / f'{source}_problemfile.pddl').read_text(encoding='utf-8'))
        section(problem, ':goal')[1] = goal
        (inputs / f'{source}_problemfile.pddl').write_text(serialize(problem), encoding='utf-8')
        task(source + '__witness', 'witness', source, 'native_witness', inputs / f'{source}_domainfile.pddl', inputs / f'{source}_problemfile.pddl', bundle)
    if 'semantic_trap' in protocol:
        for condition in ('no_share', 'model_full'):
            folder = models['anchor', condition]; problem = folder / 'semantic_trap.pddl'
            map_problem(protocol['semantic_trap'], folder, problem)
            task('anchor__semantic_trap__' + condition, 'semantic_control', 'semantic_trap', condition, folder / 'meta_domain.pddl', problem, 'anchor')
    assert len(tasks) == protocol['solver_tasks'], len(tasks)
    save(output / 'bundle/manifest.json', {'status': 'frozen_before_search', 'mode': 'external_source_preservation', 'task_count': len(tasks), 'tasks': tasks})
    save(output / 'compilation.json', {'status': 'complete', 'models': admissions})
    code = [Path(p) for p in [*prompt_sources(), 'rcnc/model_semantics.py', 'rcnc/model_semantics_schema.py', 'rcnc/model_semantics_facets.py', 'rcnc/conditional_merge.py', 'rcnc/aligned_domain.py', 'rcnc/domain_union.py',
            'rcnc/domain_building.py', 'rcnc/pddl.py', 'rcnc/pddl_checks.py', 'rcnc/narrative_pipeline.py', 'rcnc/validation.py',
            'scripts/experiments/run_automatic_merge.py', 'scripts/experiments/run_conditional_merge.py',
            'scripts/experiments/run_union_regression.py', 'scripts/experiments/run_downward_reference.py',
            'scripts/experiments/frozen_solver.py', 'scripts/audit/audit_automatic_merge.py']]
    hashes = snapshot_implementation(output, code)
    frozen = [p for p in output.rglob('*') if p.is_file() and 'implementation' not in p.parts]
    save(output / 'manifest.json', {'status': 'frozen_before_search', 'task_count': len(tasks), 'rows': tasks,
            'budget': protocol['budget'], 'input_sha256': {p.as_posix(): digest(p) for p in frozen}, 'implementation_sha256': hashes})
    return {'status': 'compiled', 'task_count': len(tasks)}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['prepare', 'judge', 'compile', 'execute']); parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--schema-policy', choices=['free_fields', 'coupled_fields', 'semantic_facets'], default='free_fields')
    parser.add_argument('--model', default='gemma3:4b')
    parser.add_argument('--model-digest', default=MODEL_DIGEST)
    parser.add_argument('--num-predict', type=int, default=1400)
    args = parser.parse_args()
    if args.mode == 'prepare': result = prepare(args.output, args.schema_policy, model=args.model, model_digest=args.model_digest, num_predict=args.num_predict)
    elif args.mode == 'judge': result = run_model(args.output / 'judgments')
    elif args.mode == 'compile': result = compile_tasks(args.output)
    else:
        from scripts.experiments.frozen_solver import execute
        result = execute(args.output)
    print(json.dumps({k: result[k] for k in ['status', 'candidates', 'solver_tasks', 'candidate_count', 'requests_attempted', 'status_counts', 'decision_counts', 'task_count'] if k in result}, indent=2))

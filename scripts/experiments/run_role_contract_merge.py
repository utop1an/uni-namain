"""Frozen GLM role-contract control and unequal-precondition merge cases."""
import argparse
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import shutil

from rcnc.conditional_merge import build, fields
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.model_semantics import prepare as prepare_model, run as run_model
from rcnc.model_semantics_contract import include_output_contract
from rcnc.narrative_pipeline import map_problem
from rcnc.pddl import Predicate, parse_domain, write_domain
from scripts.experiments.run_original_world_pipeline import convert_problem
from scripts.experiments.run_conditional_merge import remove_source
from scripts.experiments.run_transport_merge import (MODEL_DIGEST, CONDITIONS, pairs as transport_pairs,
    cross_worlds, witness, write_native_query, implementation_paths as transport_code)

PARENT = Path('data/validation/transport_merge_glm_2026_10_28_v1')
BUNDLES = {'transport': ['LOG98', 'DLOG'], 'clearance': ['LOG98', 'DLOGC'], 'narrative': ['BIRT', 'SOUP']}


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def candidates():
    result = [dict(p, bundle='transport') for p in transport_pairs()]
    result += [{'id': 'clearance_' + name.replace('-', '_'), 'bundle': 'clearance', 'kind': kind,
                'references': [s + ':' + name for s in BUNDLES['clearance']]}
               for kind, name in [('predicate', 'at'), ('predicate', 'in'), ('action', 'load-truck'), ('action', 'unload-truck')]]
    result += [{'id': 'narrative_at', 'bundle': 'narrative', 'kind': 'predicate', 'references': ['BIRT:at', 'SOUP:at']},
               {'id': 'narrative_travel', 'bundle': 'narrative', 'kind': 'action', 'references': ['BIRT:travel_to_trysting_place', 'SOUP:travel_to']}]
    return result


def clearance_variant(base):
    result = copy.deepcopy(base)
    result.name = 'driverlog_clearance_control'
    for action_name, predicate in [('load-truck', 'loading-cleared'), ('unload-truck', 'unloading-cleared')]:
        result.predicates[predicate] = Predicate(predicate, [('?cargo', 'object'), ('?vehicle', 'object'), ('?site', 'object')])
        action = result.actions[action_name]
        original = copy.deepcopy(fields(action)[':precondition'])
        action[action.index(':precondition') + 1] = ['and', original, [predicate, '?obj', '?truck', '?loc']]
    return result


def clearance_query(allowed):
    query, _ = witness('DLOG')
    # Source-object names are chosen before the run to avoid category collisions.
    names = {n: 'v_' + n for n in query['objects']}
    def fact(f):
        return [f[0].replace('DLOG:', 'DLOGC:'), *[names[a] for a in f[1:]]]
    result = {'objects': {v: 'DLOGC:object' for v in names.values()},
              'initial': [fact(f) for f in query['initial']],
              'goal': {k: [fact(f) for f in fs] for k, fs in query['goal'].items()}}
    if allowed:
        result['initial'].append(['DLOGC:loading-cleared', 'v_parcel', 'v_truck', 'v_a'])
    result['initial'].append(['DLOGC:unloading-cleared', 'v_parcel', 'v_truck', 'v_b'])
    return result


def queries():
    transport = cross_worlds()
    clearance = json.loads(json.dumps(transport).replace('DLOG:', 'DLOGC:'))
    for name, query in clearance.items():
        reverse = name == 'road_then_air'
        for goal in query['goal']['positive']:
            cargo = goal[1]
            query['initial'] += [['DLOGC:loading-cleared', cargo, 'truck', 'c' if reverse else 'b'],
                                 ['DLOGC:unloading-cleared', cargo, 'truck', 'b' if reverse else 'c']]
    denied = copy.deepcopy(clearance['air_then_road'])
    denied['initial'] = [f for f in denied['initial'] if f[0] != 'DLOGC:loading-cleared']
    clearance['loading_not_cleared'] = denied
    narrative = {'relocate_and_understand': {
        'objects': {'visitor': ['BIRT:entity', 'SOUP:entity'],
                    'start_site': ['BIRT:location', 'SOUP:location'], 'end_site': ['BIRT:location', 'SOUP:location']},
        'initial': [['BIRT:at', 'visitor', 'start_site']],
        'goal': {'positive': [['BIRT:at', 'visitor', 'end_site'], ['SOUP:has_understanding', 'visitor']],
                 'negative': [['BIRT:at', 'visitor', 'start_site']]}}}
    return {'transport': transport, 'clearance': clearance, 'narrative': narrative}


def code_paths():
    return [*transport_code(), Path(__file__), Path('rcnc/model_semantics_role_contract.py')]


def check_freeze(root):
    manifest = read(root / 'pre_model_freeze.json')
    for p, expected in {**manifest['input_sha256'], **manifest['implementation_sha256']}.items():
        if digest(Path(p)) != expected:
            raise ValueError('Frozen protocol/input/code changed: ' + p)


def prepare(root):
    require_empty_output(root)
    root.mkdir(parents=True)
    (root / 'inputs').mkdir()
    parent = read(PARENT / 'manifest.json')
    for p, expected in parent['input_sha256'].items():
        if digest(Path(p)) != expected:
            raise ValueError('Parent input changed')
    for source in ('LOG98', 'DLOG'):
        shutil.copyfile(PARENT / 'inputs' / (source + '_domainfile.pddl'), root / 'inputs' / (source + '_domainfile.pddl'))
    variant = clearance_variant(parse_domain(root / 'inputs/DLOG_domainfile.pddl'))
    write_domain(variant, root / 'inputs/DLOGC_domainfile.pddl')
    for source in ('BIRT', 'SOUP'):
        shutil.copyfile(Path('data/narra-domains') / (source + '_domainfile.pddl'), root / 'inputs' / (source + '_domainfile.pddl'))
    originals = []
    for old in read(PARENT / 'protocol.json')['originals']:
        folder = root / 'native' / ('transport__' + old['id'])
        folder.mkdir(parents=True)
        for key, name in [('raw_domain', 'domain.pddl'), ('raw_problem', 'problem.pddl')]:
            shutil.copyfile(old[key], folder / name)
        originals.append({'id': folder.name, 'bundle': 'transport', 'source': old['source'],
                          'unit': 'public_original', 'directory': folder.as_posix(), 'query': old['query']})
    repeated = copy.deepcopy(originals[0])
    repeated.update(id='clearance__log98_prob01', bundle='clearance', duplicate_of=originals[0]['id'])
    originals.append(repeated)
    for allowed in (True, False):
        name = 'clearance__' + ('allowed' if allowed else 'denied')
        folder = root / 'native' / name
        folder.mkdir(parents=True)
        shutil.copyfile(root / 'inputs/DLOGC_domainfile.pddl', folder / 'domain.pddl')
        query = clearance_query(allowed)
        write_native_query(query, folder / 'domain.pddl', folder / 'problem.pddl')
        originals.append({'id': name, 'bundle': 'clearance', 'source': 'DLOGC', 'unit': 'authored_variant',
                          'directory': folder.as_posix(), 'query': query})
    for source in ('BIRT', 'SOUP'):
        folder = root / 'native' / ('narrative__' + source.lower())
        folder.mkdir(parents=True)
        for kind in ('domain', 'problem'):
            shutil.copyfile(Path('data/narra-domains') / f'{source}_{kind}file.pddl', folder / (kind + '.pddl'))
        query = convert_problem(source, folder / 'domain.pddl', folder / 'problem.pddl')
        originals.append({'id': folder.name, 'bundle': 'narrative', 'source': source, 'unit': 'narrative_original',
                          'directory': folder.as_posix(), 'query': query})
    protocol = {'status': 'frozen_before_any_model_call', 'created_utc': datetime.now(timezone.utc).isoformat(),
        'parent': PARENT.as_posix(), 'bundles': BUNDLES, 'pairs': candidates(), 'originals': originals, 'queries': queries(),
        'conditions': list(CONDITIONS), 'primary_threshold': .9, 'predeclared_sensitivity_threshold': .8,
        'model_conditions': {'budget_only': {'pairs': 5, 'policy': 'semantic_facets'},
                             'optional_roles': {'pairs': 11, 'policy': 'semantic_facets_optional_roles'}},
        'model_limits': {'per_request_seconds': 240, 'num_predict': 16384, 'num_ctx': 32768, 'attempts': 1,
                         'budget_only_seconds': 1200, 'optional_roles_seconds': 2640},
        'acceptance': ['Complete valid response; no response repair or retries.',
            'Same specific relation/event and complete compatible participant bijection, no semantic counterexample, confidence at fixed threshold.',
            'Predicate source injectivity and explicit type correspondences with source guards.',
            'Identical signed action effects after accepted predicate and parameter maps; disjunction of every original guarded precondition.',
            'Unknown/different/invalid retains source variants. No source-specific semantic veto or automatic acceptance from expected labels.'],
        'control_hypotheses': {'transport_drive_truck': 'city and driver roles should not merge',
            'clearance_load_truck': 'same cargo/truck/site event with an extra static permission prerequisite',
            'clearance_unload_truck': 'same cargo/truck/site event with an extra static permission prerequisite',
            'narrative_travel': 'same actor/destination/origin relocation with SOUP skewer prerequisite'},
        'budget': {'seconds': 20, 'memory_mb': 4096, 'workers': 1, 'attempts': 1}, 'solver_tasks': 126,
        'variant_provenance': 'DLOGC is an authored Driverlog derivative: exactly two static clearance predicates and one added conjunct per load/unload; all effects and all other actions unchanged. It is not an independent public domain.',
        'planned_branch_probes': 'Replay existing 3-step SOUP witness on its exact original source world; test SOUP-only movement with and without the required skewer and DLOGC-only loading with and without clearance.',
        'scope': 'Adaptive development followup, including an output-contract comparison at fixed larger budget. Original transport failure remains historical. Clearance worlds are authored, BIRT/SOUP are known narrative models; no independent semantic labels, generalization or cost claims.'}
    save(root / 'protocol.json', protocol)
    control_inputs = root / 'budget_control/inputs'
    control_inputs.mkdir(parents=True)
    for source in ('LOG98', 'DLOG'):
        shutil.copyfile(root / 'inputs' / (source + '_domainfile.pddl'), control_inputs / (source + '_domainfile.pddl'))
    for folder, inputs, pairs, policy, seconds in [
        (root / 'budget_control/judgments', control_inputs, candidates()[:5], 'semantic_facets', 1200),
        (root / 'judgments', root / 'inputs', candidates(), 'semantic_facets_optional_roles', 2640)]:
        prepare_model(inputs, pairs, folder, model='glm-5.3:cloud', model_digest=MODEL_DIGEST,
                      total_seconds=seconds, request_seconds=240, schema_policy=policy, num_predict=16384, num_ctx=32768)
        include_output_contract(folder)
    code = snapshot_implementation(root / 'pre_model', code_paths())
    frozen = [p for p in root.rglob('*') if p.is_file() and 'implementation' not in p.parts]
    save(root / 'pre_model_freeze.json', {'status': 'frozen_before_model_calls',
        'input_sha256': {p.as_posix(): digest(p) for p in frozen}, 'implementation_sha256': code})
    return {'status': 'prepared', 'model_calls_planned': 16, 'solver_tasks': 126}


def compile_tasks(root):
    check_freeze(root)
    if (root / 'manifest.json').exists():
        raise ValueError('Already compiled')
    protocol = read(root / 'protocol.json')
    report = read(root / 'judgments/report.json')
    if report['status'] != 'complete' or not report['inputs_unchanged'] or not report['implementation_unchanged']:
        raise ValueError('Stable completed judgments required')
    groups = {g['id']: g for g in read(root / 'judgments/groups.json')['groups']}
    tasks, models = [], []
    def task(identifier, family, bundle, source, problem_id, condition, domain, problem, mapping=None):
        folder = root / 'bundle/tasks' / identifier
        folder.mkdir(parents=True)
        shutil.copyfile(domain, folder / 'domain.pddl')
        shutil.copyfile(problem, folder / 'problem.pddl')
        if mapping is not None:
            save(folder / 'query_mapping.json', mapping)
        tasks.append({'id': identifier, 'family': family, 'bundle': bundle, 'source': source, 'problem_id': problem_id,
            'representation': condition, 'admission_status': 'ready',
            'domain_sha256': digest(folder / 'domain.pddl'), 'problem_sha256': digest(folder / 'problem.pddl')})
    for bundle, sources in BUNDLES.items():
        inputs = root / 'bundle_inputs' / bundle
        inputs.mkdir(parents=True)
        for source in sources:
            shutil.copyfile(root / 'inputs' / (source + '_domainfile.pddl'), inputs / (source + '_domainfile.pddl'))
        types = ['entity', 'item', 'location'] if bundle == 'narrative' else ['object']
        for condition in CONDITIONS:
            spec = {'version': 1, 'decision_basis': 'machine_hypothesis',
                'semantic_min_confidence': .8 if condition.endswith('080') else .9,
                'source_sha256': {p.name: digest(p) for p in inputs.iterdir()},
                'type_groups': [{'members': [s + ':' + t for s in sources], 'evidence': 'Explicit type-role correspondence; distinct source membership retained'} for t in types]}
            for kind in ('predicate', 'action'):
                spec[kind + '_candidates'] = [groups[p['id']] for p in protocol['pairs'] if p['bundle'] == bundle and p['kind'] == kind] if condition != 'no_share' else []
            folder = root / 'models' / bundle / condition
            result = build(inputs, folder, spec, merge_actions=condition.startswith('full'))
            models.append({'bundle': bundle, 'condition': condition, 'counts': result['counts'],
                           'predicate_groups': result['merged_predicate_groups'], 'action_groups': result['merged_action_groups']})
        for case in [c for c in protocol['originals'] if c['bundle'] == bundle]:
            native = Path(case['directory'])
            task(case['id'] + '__native', case['unit'], bundle, case['source'], case['id'], 'native', native / 'domain.pddl', native / 'problem.pddl')
            for condition in CONDITIONS:
                model = root / 'models' / bundle / condition
                problem = model / (case['id'] + '.pddl')
                mapping = map_problem(case['query'], model, problem)
                task(case['id'] + '__' + condition, case['unit'], bundle, case['source'], case['id'], condition,
                     model / 'meta_domain.pddl', problem, mapping)
        for suffix in ('090', '080'):
            primary = root / 'models' / bundle / ('full' + suffix)
            domain, meta = parse_domain(primary / 'meta_domain.pddl'), read(primary / 'meta_domain.json')
            for source in sources:
                folder = root / 'models' / bundle / ('remove_' + source + suffix)
                folder.mkdir()
                write_domain(remove_source(domain, meta, source), folder / 'meta_domain.pddl')
        for name, query in protocol['queries'][bundle].items():
            for condition in [*CONDITIONS, *['remove_' + s + t for t in ('090', '080') for s in sources]]:
                folder = root / 'models' / bundle / condition
                primary = root / 'models' / bundle / ('full' + condition[-3:]) if condition.startswith('remove_') else folder
                problem = folder / (name + '.pddl')
                mapping = map_problem(query, primary, problem)
                family = 'clearance_control' if name == 'loading_not_cleared' else 'cross'
                task(bundle + '__' + name + '__' + condition, family, bundle, '+'.join(sources), name, condition,
                     folder / 'meta_domain.pddl', problem, mapping)
    if len(tasks) != protocol['solver_tasks']:
        raise ValueError('Task denominator differs: ' + str(len(tasks)))
    save(root / 'bundle/manifest.json', {'status': 'frozen_before_search', 'mode': 'external_source_preservation', 'task_count': len(tasks), 'tasks': tasks})
    save(root / 'compilation.json', {'status': 'complete', 'models': models})
    code = snapshot_implementation(root, code_paths())
    frozen = [p for p in root.rglob('*') if p.is_file() and 'implementation' not in p.parts]
    save(root / 'manifest.json', {'status': 'frozen_before_search', 'task_count': len(tasks), 'rows': tasks,
        'budget': protocol['budget'], 'input_sha256': {p.as_posix(): digest(p) for p in frozen}, 'implementation_sha256': code})
    return {'status': 'compiled', 'task_count': len(tasks), 'models': models}


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('mode', choices=['prepare', 'judge_control', 'judge', 'compile', 'execute'])
    p.add_argument('--output', required=True, type=Path)
    args = p.parse_args()
    if args.mode == 'prepare':
        result = prepare(args.output)
    elif args.mode in ('judge', 'judge_control'):
        check_freeze(args.output)
        result = run_model(args.output / ('judgments' if args.mode == 'judge' else 'budget_control/judgments'))
    elif args.mode == 'compile':
        result = compile_tasks(args.output)
    else:
        from scripts.experiments.frozen_solver import execute
        result = execute(args.output)
    print(json.dumps({k: result[k] for k in ('status', 'model_calls_planned', 'solver_tasks', 'task_count', 'models', 'requests_attempted', 'status_counts', 'decision_counts') if k in result}, indent=2))

"""Prospectively frozen GLM comparison on Logistics98 and Driverlog."""
import argparse
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import shutil

from rcnc.conditional_merge import build
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.model_semantics import prepare as prepare_model, run as run_model
from rcnc.model_semantics_contract import include_output_contract
from rcnc.narrative_pipeline import map_problem
from rcnc.pddl import parse_domain, parse_sexpr, serialize, write_domain
from scripts.experiments.prepare_casefold_followup import casefold_ast
from scripts.experiments.run_conditional_merge import remove_source
from scripts.experiments.run_original_world_pipeline import convert_problem

SOURCES = ('LOG98', 'DLOG')
CONDITIONS = ('no_share', 'predicate090', 'full090', 'predicate080', 'full080')
MODEL_DIGEST = '8477dab3e25bb0f93c468af220186f55394262ee5e9f39262af4b60b54a8c4ba'
COMMIT = 'e21d49c2cb61d147a46c5966f2581bf6fd422b9f'


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def pairs():
    return [{'id': 'transport_' + name.replace('-', '_'), 'kind': kind,
             'references': [s + ':' + name for s in SOURCES]}
            for kind, name in [('predicate', 'at'), ('predicate', 'in'),
                               ('action', 'load-truck'), ('action', 'unload-truck'),
                               ('action', 'drive-truck')]]


def cross_worlds():
    """Explicit composed worlds; never import a benchmark problem's facts."""
    result = {}
    for name, reverse, packages in [('air_then_road', False, 1), ('road_then_air', True, 1),
                                    ('two_packages', False, 2)]:
        names = ['a', 'b', 'c', 'plane', 'truck', 'driver'] + [f'p{i}' for i in range(packages)]
        objects = {n: [s + ':object' for s in SOURCES] for n in names}
        initial = [['LOG98:airplane', 'plane'], ['LOG98:at', 'plane', 'b' if reverse else 'a'],
                   ['DLOG:truck', 'truck'], ['DLOG:driver', 'driver'],
                   ['DLOG:driving', 'driver', 'truck'], ['DLOG:at', 'truck', 'c' if reverse else 'b'],
                   ['DLOG:link', 'c' if reverse else 'b', 'b' if reverse else 'c']]
        for loc in ('a', 'b'):
            initial += [['LOG98:location', loc], ['LOG98:airport', loc]]
        for loc in ('b', 'c'):
            initial.append(['DLOG:location', loc])
        for i in range(packages):
            initial += [[s + ':obj', f'p{i}'] for s in SOURCES]
            initial.append([('DLOG' if reverse else 'LOG98') + ':at', f'p{i}', 'c' if reverse else 'a'])
        goal_source, dest, origin_source, start = ('LOG98', 'a', 'DLOG', 'c') if reverse else ('DLOG', 'c', 'LOG98', 'a')
        result[name] = {'objects': objects, 'initial': initial,
            'goal': {'positive': [[goal_source + ':at', f'p{i}', dest] for i in range(packages)],
                     'negative': [[origin_source + ':at', f'p{i}', start] for i in range(packages)]}}
    return result


def witness(source):
    """Separate authored three-step trace, not an original benchmark solution."""
    fourth = 'city' if source == 'LOG98' else 'driver'
    objects = {n: source + ':object' for n in ('parcel', 'truck', 'a', 'b', fourth)}
    facts = [['obj', 'parcel'], ['truck', 'truck'], ['location', 'a'], ['location', 'b'],
             ['at', 'parcel', 'a'], ['at', 'truck', 'a']]
    facts += ([['city', 'city'], ['in-city', 'a', 'city'], ['in-city', 'b', 'city']] if source == 'LOG98'
              else [['driver', 'driver'], ['driving', 'driver', 'truck'], ['link', 'a', 'b']])
    return {'objects': objects, 'initial': [[source + ':' + f[0], *f[1:]] for f in facts],
            'goal': {'positive': [[source + ':at', 'parcel', 'b']],
                     'negative': [[source + ':at', 'parcel', 'a'], [source + ':in', 'parcel', 'truck']]}}, [
            ['load-truck', 'parcel', 'truck', 'a'], ['drive-truck', 'truck', 'a', 'b', fourth],
            ['unload-truck', 'parcel', 'truck', 'b']]


def write_native_query(query, domain_path, path):
    def atom(f):
        return [f[0].split(':')[1], *f[1:]]
    tree = ['define', ['problem', 'branch_witness'], [':domain', parse_domain(domain_path).name],
            [':objects', *query['objects']], [':init', *[atom(f) for f in query['initial']]],
            [':goal', ['and', *[atom(f) for f in query['goal']['positive']],
                       *[['not', atom(f)] for f in query['goal']['negative']]]]]
    path.write_text(serialize(tree) + '\n', encoding='utf-8')


def implementation_paths():
    return [Path(p) for p in [__file__, 'rcnc/conditional_merge.py', 'rcnc/aligned_domain.py',
        'rcnc/domain_union.py', 'rcnc/domain_building.py', 'rcnc/pddl.py', 'rcnc/pddl_checks.py',
        'rcnc/narrative_pipeline.py', 'rcnc/validation.py', 'rcnc/model_semantics.py',
        'rcnc/model_semantics_facets.py', 'rcnc/model_semantics_schema.py', 'rcnc/model_semantics_contract.py',
        'scripts/experiments/run_original_world_pipeline.py', 'scripts/experiments/prepare_casefold_followup.py',
        'scripts/experiments/run_conditional_merge.py', 'scripts/experiments/frozen_solver.py',
        'scripts/experiments/run_downward_reference.py']]


def check_freeze(root):
    frozen = read(root / 'pre_model_freeze.json')
    for path, expected in {**frozen['input_sha256'], **frozen['implementation_sha256']}.items():
        if digest(Path(path)) != expected:
            raise ValueError('Pre-model freeze changed: ' + path)


def prepare(root):
    require_empty_output(root)
    root.mkdir(parents=True)
    files = {
        'LOG98': [Path('data/external/action_merge_candidates_2026_10_28_v1/logistics98/domain.pddl'),
                  *[Path('data/external/transport_merge_2026_10_28_v1/logistics98') / f'prob0{i}.pddl' for i in (1, 2)]],
        'DLOG': [Path('data/external/prospective_sources_2026_10_26_v1/ipc/files/driverlog') / n
                 for n in ('domain.pddl', 'p01.pddl', 'p02.pddl')]}
    # Verify every raw source against the already pinned public Git tree.
    import hashlib
    tree = read(Path('data/external/prospective_sources_2026_10_26_v1/ipc/tree.json'))
    blobs = {r['path']: r['sha'] for r in tree['tree']}
    normalized, cases = [], []
    (root / 'inputs').mkdir()
    for source, paths in files.items():
        for i, path in enumerate(paths):
            raw = path.read_bytes()
            repository_path = ('logistics98/' if source == 'LOG98' else 'driverlog/') + path.name
            blob = hashlib.sha1(b'blob ' + str(len(raw)).encode() + b'\0' + raw).hexdigest()
            if blob != blobs[repository_path]:
                raise ValueError('Pinned public file differs: ' + str(path))
            archived = root / 'raw' / source / path.name
            archived.parent.mkdir(parents=True, exist_ok=True)
            archived.write_bytes(raw)
            target = root / 'inputs' / (source + '_domainfile.pddl') if i == 0 else root / 'originals' / source / path.name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(serialize(casefold_ast(parse_sexpr(raw.decode('utf-8')))) + '\n', encoding='utf-8')
            normalized.append({'original': archived.as_posix(), 'original_sha256': digest(archived),
                'normalized': target.as_posix(), 'normalized_sha256': digest(target),
                'git_blob_sha1': blob, 'source_url': f'https://raw.githubusercontent.com/aibasel/downward-benchmarks/{COMMIT}/{repository_path}'})
            if i:
                query = convert_problem(source, root / 'inputs' / (source + '_domainfile.pddl'), target)
                cases.append({'id': source.lower() + '_' + path.stem, 'source': source,
                    'raw_domain': (root / 'raw' / source / 'domain.pddl').as_posix(),
                    'raw_problem': archived.as_posix(), 'normalized_problem': target.as_posix(), 'query': query})
    save(root / 'normalization.json', {'status': 'case_only_adapter', 'rows': normalized})
    protocol = {'status': 'frozen_before_model_and_solver', 'created_utc': datetime.now(timezone.utc).isoformat(),
        'source_commit': COMMIT, 'sources': list(SOURCES), 'pairs': pairs(), 'originals': cases,
        'queries': cross_worlds(), 'witnesses': {s: dict(zip(('query', 'plan'), witness(s))) for s in SOURCES},
        'conditions': list(CONDITIONS), 'primary_threshold': .9, 'sensitivity_threshold': .8,
        'sensitivity_status': 'Predeclared on this new input before predictions; confidence remains uncalibrated.',
        'acceptance': ['Valid complete JSON and grounded citations; no manual response repair.',
            'Same relation/event, bijective matching participant roles, no meaning conflict or counterexample, confidence >= fixed threshold.',
            'Source-injective predicate mapping and explicit root-type correspondence; original static source membership guards retained.',
            'Action merge requires identical signed effects after accepted predicate maps and parameter bijections; retain OR of all original guarded preconditions.',
            'Unsupported, rejected or invalid judgments retain source variants; no outcome-based candidate replacement.'],
        'expected_controls': {'load-truck': 'same event and participants', 'unload-truck': 'same event and participants',
                              'drive-truck': 'fourth parameter city versus driver; should remain separate'},
        'formal_only_diagnostic': 'Check identical drive effects with identity roles without semantic gate; no planner calls and never deploy this candidate.',
        'solver_tasks': 51, 'budget': {'seconds': 20, 'memory_mb': 4096, 'workers': 1, 'attempts': 1},
        'model_budget': {'requests': 5, 'seconds': 900, 'per_request_seconds': 180, 'num_predict': 8192},
        'scope': 'Authored development controls on two public benchmark domains. Original worlds remain separate; three composed tasks are not held-out tasks or independent semantic labels. No isolated cost claim.'}
    save(root / 'protocol.json', protocol)
    prepare_model(root / 'inputs', pairs(), root / 'judgments', model='glm-5.3:cloud',
                  model_digest=MODEL_DIGEST, total_seconds=900, request_seconds=180,
                  schema_policy='semantic_facets', num_predict=8192)
    include_output_contract(root / 'judgments')
    code = snapshot_implementation(root / 'pre_model', implementation_paths())
    frozen = [p for p in root.rglob('*') if p.is_file() and 'implementation' not in p.parts]
    save(root / 'pre_model_freeze.json', {'status': 'frozen_before_model',
        'input_sha256': {p.as_posix(): digest(p) for p in frozen}, 'implementation_sha256': code})
    return {'status': 'prepared', 'candidates': 5, 'solver_tasks': 51}


def compile_tasks(root):
    check_freeze(root)
    if (root / 'manifest.json').exists():
        raise ValueError('Tasks already frozen')
    protocol = read(root / 'protocol.json')
    judgments = read(root / 'judgments/report.json')
    if judgments['status'] != 'complete' or not judgments['inputs_unchanged'] or not judgments['implementation_unchanged']:
        raise ValueError('Completed stable model run required')
    groups = read(root / 'judgments/groups.json')['groups']
    tasks, admissions = [], []
    for condition in CONDITIONS:
        spec = {'version': 1, 'decision_basis': 'machine_hypothesis',
            'semantic_min_confidence': .8 if condition.endswith('080') else .9,
            'source_sha256': {p.name: digest(p) for p in (root / 'inputs').glob('*_domainfile.pddl')},
            'type_groups': [{'members': [s + ':object' for s in SOURCES],
                             'evidence': 'Both are untyped PDDL universal object roles; source-specific membership guards remain distinct.'}],
            'predicate_candidates': [g for g, p in zip(groups, protocol['pairs']) if p['kind'] == 'predicate'],
            'action_candidates': [g for g, p in zip(groups, protocol['pairs']) if p['kind'] == 'action']}
        if condition == 'no_share':
            spec.update(predicate_candidates=[], action_candidates=[])
        result = build(root / 'inputs', root / 'models' / condition, spec, merge_actions=condition.startswith('full'))
        admissions.append({'condition': condition, 'counts': result['counts'],
                           'predicate_groups': result['merged_predicate_groups'], 'action_groups': result['merged_action_groups']})

    def task(identifier, family, case, source, condition, domain, problem, mapping=None):
        folder = root / 'bundle/tasks' / identifier
        folder.mkdir(parents=True)
        shutil.copyfile(domain, folder / 'domain.pddl')
        shutil.copyfile(problem, folder / 'problem.pddl')
        if mapping is not None:
            save(folder / 'query_mapping.json', mapping)
        tasks.append({'id': identifier, 'family': family, 'problem_id': case, 'source': source,
            'representation': condition, 'admission_status': 'ready',
            'domain_sha256': digest(folder / 'domain.pddl'), 'problem_sha256': digest(folder / 'problem.pddl')})

    for case in protocol['originals']:
        task(case['id'] + '__native', 'original', case['id'], case['source'], 'native', Path(case['raw_domain']), Path(case['raw_problem']))
        for condition in CONDITIONS:
            model = root / 'models' / condition
            problem = model / (case['id'] + '.pddl')
            mapping = map_problem(case['query'], model, problem)
            task(case['id'] + '__' + condition, 'original', case['id'], case['source'], condition,
                 model / 'meta_domain.pddl', problem, mapping)
    for suffix in ('090', '080'):
        primary = root / 'models' / ('full' + suffix)
        meta, domain = read(primary / 'meta_domain.json'), parse_domain(primary / 'meta_domain.pddl')
        for source in SOURCES:
            folder = root / 'models' / ('remove_' + source + suffix)
            folder.mkdir()
            write_domain(remove_source(domain, meta, source), folder / 'meta_domain.pddl')
    for case, query in protocol['queries'].items():
        for condition in [*CONDITIONS, *['remove_' + s + t for t in ('090', '080') for s in SOURCES]]:
            folder = root / 'models' / condition
            primary = root / 'models' / ('full' + condition[-3:]) if condition.startswith('remove_') else folder
            problem = folder / (case + '.pddl')
            mapping = map_problem(query, primary, problem)
            task(case + '__' + condition, 'cross', case, '+'.join(SOURCES), condition, folder / 'meta_domain.pddl', problem, mapping)
    for source, item in protocol['witnesses'].items():
        folder = root / 'witnesses' / source / 'native'
        folder.mkdir(parents=True)
        shutil.copyfile(root / 'inputs' / (source + '_domainfile.pddl'), folder / 'domain.pddl')
        write_native_query(item['query'], folder / 'domain.pddl', folder / 'problem.pddl')
        (folder / 'plan.txt').write_text('\n'.join('(' + ' '.join(a) + ')' for a in item['plan']) + '\n', encoding='utf-8')
        for condition in CONDITIONS:
            folder = root / 'witnesses' / source / condition
            folder.mkdir()
            model = root / 'models' / condition
            shutil.copyfile(model / 'meta_domain.pddl', folder / 'domain.pddl')
            mapping = map_problem(item['query'], model, folder / 'problem.pddl')
            save(folder / 'query_mapping.json', mapping)
    if len(tasks) != protocol['solver_tasks']:
        raise ValueError('Task denominator differs')
    save(root / 'bundle/manifest.json', {'status': 'frozen_before_search', 'mode': 'external_source_preservation', 'task_count': len(tasks), 'tasks': tasks})
    save(root / 'compilation.json', {'status': 'complete', 'models': admissions})
    hashes = snapshot_implementation(root, implementation_paths())
    frozen = [p for p in root.rglob('*') if p.is_file() and 'implementation' not in p.parts]
    save(root / 'manifest.json', {'status': 'frozen_before_search', 'task_count': len(tasks), 'rows': tasks,
        'budget': protocol['budget'], 'input_sha256': {p.as_posix(): digest(p) for p in frozen}, 'implementation_sha256': hashes})
    return {'status': 'compiled', 'task_count': len(tasks), 'models': admissions}


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('mode', choices=['prepare', 'judge', 'compile', 'execute'])
    p.add_argument('--output', required=True, type=Path)
    args = p.parse_args()
    if args.mode == 'prepare':
        result = prepare(args.output)
    elif args.mode == 'judge':
        check_freeze(args.output)
        result = run_model(args.output / 'judgments')
    elif args.mode == 'compile':
        result = compile_tasks(args.output)
    else:
        from scripts.experiments.frozen_solver import execute
        result = execute(args.output)
    print(json.dumps({k: result[k] for k in ('status', 'candidates', 'solver_tasks', 'task_count', 'models',
        'requests_attempted', 'status_counts', 'decision_counts') if k in result}, indent=2))

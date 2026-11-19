"""Offline continuation of the frozen three-pool Batch experiment.

Only orchestration is new. Compiler, selection consensus, world construction,
native runtime and replay code are imported from the immutable release.
No credentials, network requests, inference retries, or implicit resumption.
"""
import argparse
from collections import Counter, defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
import traceback

REPO = Path('C:/anu/uninamain')
RELEASE = REPO / 'data/research_release/narrative_baseline_priority1_2026_11_05_v1'
DATA = REPO / 'data/benchmarks/priority1_union_full_three_cohort_2026_11_05_v1'
PREP = REPO / 'data/validation/priority1_union_full_openai_preparation_2026_11_05_v1'
BATCH = REPO / 'data/validation/priority1_union_full_openai_batch_acceleration_2026_11_06_v2'
AUDIT = REPO / 'data/validation/priority1_union_full_openai_batch_final_audit_2026_11_06_v1'
CONDITIONS = ('union', 'full')
EXPECTED = {'native': 428, 'transport': 21056, 'anchor': 4800, 'composition': 2400}
C = None


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def write(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x', encoding='utf-8', newline='\n') as stream:
        json.dump(value, stream, ensure_ascii=False, indent=2)
        stream.write('\n')


def now():
    return datetime.now(timezone.utc).isoformat()


def offline_guard(event, args):
    if event in ('socket.connect', 'socket.connect_ex', 'socket.getaddrinfo', 'urllib.Request'):
        raise RuntimeError('Offline evaluation forbids network and inference requests')


def bind():
    global C
    sys.dont_write_bytecode = True
    code = RELEASE / 'code'
    for name, mod in list(sys.modules.items()):
        if name.split('.')[0] in ('rcnc', 'scripts', 'unidomain', 'archive'):
            file = getattr(mod, '__file__', None)
            if file and not Path(file).resolve().is_relative_to(code):
                raise ValueError('Non-frozen project import: ' + name)
    sys.path.insert(0, str(code))
    from scripts.experiments import run_selection_comparison as campaign
    C = campaign
    C.source_from = source_from
    C.CONDITIONS = CONDITIONS
    return C


def source_from(row, world=None):
    world = world or {}
    return C.Source(row['id'], Path(world.get('domain', row['domain'])),
                    Path(world.get('problem', row['representative_problem'])),
                    constant_contract=world.get('constant_contract', row.get('constant_contract')),
                    consent_policy=world.get('consent_policy', row.get('consent_policy')))


def progress(root, state, **updates):
    state.update(updates, updated_utc=now())
    C.durable_progress(root / 'coordinator.json', state)


def verify_hashes(hashes):
    for name, expected in hashes.items():
        if digest(name) != expected:
            raise ValueError('Frozen file changed: ' + name)


def verify(root):
    p = read(root / 'protocol.json')
    if digest(root / 'protocol.json') != (root / 'PROTOCOL.sha256').read_text(encoding='utf-8').strip():
        raise ValueError('Protocol changed')
    verify_hashes(p['input_sha256'])
    return p


def prepare(root):
    if root.exists():
        raise ValueError('Fresh versioned output required')
    root.mkdir(parents=True)
    state = {'status': 'preparing', 'stage': 'integrity', 'new_api_requests': 0}
    progress(root, state)
    manifest = RELEASE / 'manifest.json'
    if digest(manifest) != 'c294d6d2ab1a992915abe041628e7d33e34e28e318de3448be7ba42788c3ed98':
        raise ValueError('Unexpected release')
    hashes = {str(manifest): digest(manifest)}
    hashes.update({str(RELEASE / n): h for n, h in read(manifest)['files'].items()})
    for base, filename, key in ((DATA, 'freeze.json', 'artifact_sha256'),
                                (PREP, 'preparation_freeze.json', 'files'),
                                (AUDIT, 'audit_freeze.json', 'files')):
        f = base / filename
        if base == DATA and digest(f) != 'f8467a50f7c8a93d35d39b868ee1c178c699b189c39fd0ca0f632d1d0f38f0fa':
            raise ValueError('Unexpected selection freeze')
        if base == PREP and digest(f) != 'c7bbeb67d3f463b764111cf26d8ad209d018a119fc8d640ef5500ee348624a5e':
            raise ValueError('Unexpected preparation freeze')
        hashes[str(f)] = digest(f)
        hashes.update({str(base / n): h for n, h in read(f)[key].items()})
    hashes.update(read(AUDIT / 'evidence_sha256.json')['files'])
    for name in ('report.json', 'groups.json'):
        f = BATCH / 'judgments' / name
        if str(f) in hashes and hashes[str(f)] != digest(f):
            raise ValueError('Batch judgments changed after audit')
        hashes[str(f)] = digest(f)
    verify_hashes(hashes)
    progress(root, state, stage='registering_inputs', verified_files=len(hashes))
    groups = read(DATA / 'selected_groups.json')['groups']
    sources = read(DATA / 'sources.json')['sources']
    worlds = read(DATA / 'worlds.json')['worlds']
    cells = Counter((g['cohort'], g['method'], g['size']) for g in groups)
    if len(groups) != 1200 or len(cells) != 24 or set(cells.values()) != {50} or len(worlds) != 214:
        raise ValueError('Registered denominator changed')
    for name in ('selected_groups.json', 'sources.json', 'worlds.json'):
        shutil.copyfile(DATA / name, root / name)
    shutil.copyfile(__file__, root / 'implementation.py')
    all_judgments = {r['id']: r for r in read(BATCH / 'judgments/groups.json')['groups']}
    statuses = {r['id']: r['status'] for r in read(BATCH / 'judgments/report.json')['rows']}
    usage = read(DATA / 'candidate_usage.json')['groups_by_candidate']
    candidates = defaultdict(list)
    for cid, gids in usage.items():
        for gid in gids:
            candidates[gid].append(cid)
    unions = {r['group']: r for r in read(PREP / 'union_export_report.json')['rows']}
    for g in groups:
        ids = sorted(candidates[g['id']])
        write(root / 'group_inputs' / (g['id'] + '.json'), {
            'group': g, 'union': unions[g['id']], 'judgments': [all_judgments[i] for i in ids],
            'candidate_statuses': dict(Counter(statuses[i] for i in ids))})
    baseline = []
    by_source = {r['id']: r for r in sources}
    for sid, row in sorted(by_source.items()):
        source = source_from(row)
        folder = root / 'source_models' / sid
        meta = C.build([source], folder)
        for world in (w for w in worlds if w['source'] == sid):
            item = {**world, 'cohort': world['pool'],
                    'raw_domain': str(RELEASE / world['raw']['domain']['path']),
                    'raw_problem': str(RELEASE / world['raw']['problem']['path']),
                    'adapter_domain': str(folder / 'domain.pddl'),
                    'adapter_mapping': str(folder / 'mapping.json')}
            try:
                local = source_from(row, world)
                problem = folder / 'worlds' / (world['id'] + '.pddl')
                problem.parent.mkdir(parents=True, exist_ok=True)
                terms = C.map_problem([local], sid, meta, problem)
                item.update(adapter_status='ready', adapter_problem=str(problem), adapter_terms=terms)
            except (ValueError, KeyError, TypeError) as exc:
                item.update(adapter_status='unsupported', reason=str(exc))
            baseline.append(item)
    write(root / 'baseline_tasks.json', {'worlds': baseline})
    hashes.update({str(f): digest(f) for f in root.rglob('*') if f.is_file() and f.name != 'coordinator.json'})
    budgets = {'search_seconds': 15, 'replay_seconds': 15, 'planner_workers': 2,
               'planner_memory_mb_per_worker': 4096, 'compiler_workers': 2,
               'group_construction_seconds': 120, 'group_route_prefixes': 50000,
               'planning_worker_seconds': 55, 'planning_total_seconds': 604800,
               'model_requests': 0, 'attempts_per_slot': 1, 'registered_slots': EXPECTED}
    protocol = {'status': 'frozen_before_local_compilation_and_search', 'created_utc': now(),
        'condition': 'offline_local_evaluation_of_fixed_batch_results', 'release': str(RELEASE),
        'dataset': str(DATA), 'batch': str(BATCH), 'batch_audit': str(AUDIT),
        'conditions': list(CONDITIONS), 'groups': 1200, 'groups_per_cell': 50,
        'cohorts': ['story', 'human', 'mixed'], 'k': [2, 3, 4, 5],
        'methods': ['random', 'causal_link'], 'confidence_threshold': .9,
        'runtime_jar': str(RELEASE / 'runtime/glaive-language.jar'),
        'runtime_classes': str(RELEASE / 'runtime/classes'), 'budgets': budgets,
        'input_sha256': hashes, 'independent_semantic_labels': 0,
        'policies': [
            'Existing Batch only; all 128 missing and 1904 excluded candidates retained; no inference or retry.',
            'Frozen Nov5 compiler, world constructor, native runtime and physical validator. No live repair.',
            'Full action consensus must pass frozen mapped signed-effect and acting-role checks.',
            'Predicate mapping stage is an internal compiler intermediate, not an experiment arm.',
            'All parameterized models and explicit worlds frozen before main search.',
            'Original worlds stay separate; transport unavailable without a valid reference.',
            'Reference preference: dual raw, dual adapter, native-only raw, native-only adapter; strata separate.',
            'Two original-goal anchors per group: first registered world of each of first two source IDs.',
            'One schema-derived diagnostic world per group, no copied source-problem facts; same world in both arms.',
            'Deterministic k-to-2 route construction; 50000 route prefixes and 120 seconds per group.',
            'No source-removal or predicate-only experimental conditions in this requested comparison.',
            'Union/full paired within the same group and world. Selection methods are separate samples.',
            'Missing, unsupported, resource-limited and unexecuted rows remain explicit, not false failures.',
            'Frozen causal trace is retained as exploratory only; primary outcomes are replay validation.',
            'Seven-day local safety cap covers the registered per-slot bounds; no automatic restart.',
            'No independent semantic/narrative labels; correlated reuse of source domains remains.']}
    write(root / 'protocol.json', protocol)
    (root / 'PROTOCOL.sha256').write_text(digest(root / 'protocol.json') + '\n', encoding='utf-8')
    progress(root, state, status='prepared', stage='frozen')
    return {'status': 'prepared', 'groups': len(groups), 'slots': EXPECTED, 'new_api_requests': 0}


def base_task(g, condition, world):
    return {'id': g['id'] + '__' + condition + '__' + world['id'], 'group': g['id'],
            'cohort': g['cohort'], 'method': g['method'], 'size': g['size'],
            'condition': condition, 'source': world['source'], 'world': world['id']}


def group_worker(root, gid):
    item = read(root / 'group_inputs' / (gid + '.json'))
    g = item['group']
    rows = {r['id']: r for r in read(root / 'sources.json')['sources']}
    worlds = [w for w in read(root / 'worlds.json')['worlds'] if w['source'] in g['sources']]
    selected = [source_from(rows[s]) for s in g['sources']]
    folder = root / 'repeat_01/groups' / gid
    folder.mkdir(parents=True)
    models = {'union': read(Path(item['union']['domain']).with_name('mapping.json'))}
    full_status, audits = 'compiled', {}
    try:
        predicates, audits['predicate'] = C.select_groups(selected, item['judgments'], 'predicate', threshold=.9)
        intermediate = C.build(selected, folder / 'predicate_mapping_stage', groups=predicates)
        actions, audits['action'] = C.select_groups(selected, item['judgments'], 'action', threshold=.9,
                                                   predicate_maps=intermediate['predicate_maps'])
        models['full'] = C.build(selected, folder / 'full', groups=predicates + actions, merge_actions=True)
        if intermediate['predicate_maps'] != models['full']['predicate_maps']:
            raise ValueError('Predicate maps changed during full compilation')
        C.parse_sexpr((folder / 'full/domain.pddl').read_text(encoding='utf-8'))
    except (ValueError, KeyError, TypeError, IndexError) as exc:
        full_status = 'compilation_unsupported'
        audits['failure'] = str(exc)
    existing = {w['world']: w for w in item['union']['worlds']}
    tasks = []
    first_world = {s: next(w['id'] for w in worlds if w['source'] == s) for s in g['sources']}
    for condition in CONDITIONS:
        for world in worlds:
            task = base_task(g, condition, world)
            task['search_anchor'] = world['source'] in g['sources'][:2] and world['id'] == first_world[world['source']]
            if condition == 'union':
                old = existing[world['id']]
                task.update(status='ready', domain=item['union']['domain'], problem=old['problem'],
                            mapping=str(Path(item['union']['domain']).with_name('mapping.json')), terms=old['terms'])
            elif full_status != 'compiled':
                task.update(status='unavailable_compilation', reason=audits.get('failure'))
            else:
                try:
                    local = source_from(rows[world['source']], world)
                    problem = folder / condition / 'worlds' / (world['id'] + '.pddl')
                    problem.parent.mkdir(parents=True, exist_ok=True)
                    terms = C.map_problem([local if s.id == local.id else s for s in selected], local.id,
                                          models[condition], problem)
                    C.parse_sexpr(problem.read_text(encoding='utf-8'))
                    task.update(status='ready', domain=str(folder / condition / 'domain.pddl'),
                                mapping=str(folder / condition / 'mapping.json'), problem=str(problem), terms=terms)
                except (ValueError, KeyError, TypeError) as exc:
                    task.update(status='unsupported_world', reason=str(exc))
            tasks.append(task)
    receipt = {'group': g, 'status': full_status, 'source_tasks': tasks, 'candidate_statuses': item['candidate_statuses'],
               'model_counts': {c: {k: m.get(k) for k in ('source_action_count', 'action_count', 'business_predicate_count', 'axiom_count')}
                                for c, m in models.items()}, 'audits': audits}
    write(folder / 'models_ready.json', receipt)
    try:
        case = C.construct_case(g, {s.id: s for s in selected}, models['full']['predicate_maps'],
                                read(root / 'protocol.json')['budgets']['group_route_prefixes']) if full_status == 'compiled' else {'status': 'unavailable_compilation'}
    except (ValueError, KeyError, TypeError, IndexError) as exc:
        case = {'status': 'construction_unsupported_or_limit', 'reason': str(exc)}
    composition = []
    for condition in CONDITIONS:
        task = {'id': gid + '__composition__' + condition, 'group': gid, 'cohort': g['cohort'],
                'method': g['method'], 'size': g['size'], 'sources': g['sources'], 'condition': condition}
        if case['status'] != 'constructed':
            task.update(status=case['status'], reason=case.get('reason'))
        else:
            try:
                problem = folder / 'composition' / (condition + '.pddl')
                wr = C.authored_problem(selected, models[condition], case['scenario'], problem)
                if wr['source_problem_facts_copied'] != 0:
                    raise ValueError('Source problem facts copied')
                domain = Path(item['union']['domain']) if condition == 'union' else folder / 'full/domain.pddl'
                task.update(status='ready', domain=str(domain), mapping=str(domain.with_name('mapping.json')),
                            problem=str(problem), world_receipt=wr)
            except (ValueError, KeyError, TypeError) as exc:
                task.update(status='world_export_unsupported', reason=str(exc))
        composition.append(task)
    receipt.update(construction=case, composition_tasks=composition)
    write(folder / 'compilation.json', receipt)
    return receipt


def call_worker(root, mode, identifier, output, seconds, task=None):
    output.mkdir(parents=True, exist_ok=False)
    result_path = output / 'worker_result.json'
    if task is not None:
        write(output / 'task.json', task)
    cmd = [sys.executable, '-B', '-X', 'utf8', str(root / 'implementation.py'), mode,
           '--output', str(root), '--identifier', identifier, '--result', str(result_path)]
    started = time.monotonic()
    with (output / 'worker.log').open('xb') as log:
        try:
            proc = subprocess.run(cmd, cwd=REPO, stdout=log, stderr=subprocess.STDOUT, timeout=seconds,
                                  creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0))
        except subprocess.TimeoutExpired:
            result = {'status': 'worker_wall_time_limit', 'seconds': time.monotonic() - started}
            write(output / 'worker_timeout.json', result)
            return result
    return read(result_path) if result_path.exists() else {'status': 'worker_failed_without_result', 'returncode': proc.returncode}


def recover_compilation(root, g, failure):
    folder = root / 'repeat_01/groups' / g['id']
    checkpoint = folder / 'models_ready.json'
    if checkpoint.exists():
        result = read(checkpoint)
    else:
        item = read(root / 'group_inputs' / (g['id'] + '.json'))
        worlds = [w for w in read(root / 'worlds.json')['worlds'] if w['source'] in g['sources']]
        existing = {w['world']: w for w in item['union']['worlds']}
        tasks = []
        for c in CONDITIONS:
            for w in worlds:
                t = base_task(g, c, w)
                first = next(x['id'] for x in worlds if x['source'] == w['source'])
                t.update(status='unavailable_compilation', reason=failure,
                         search_anchor=w['source'] in g['sources'][:2] and first == w['id'])
                if c == 'union':
                    old = existing[w['id']]
                    t.update(status='ready', reason=None, domain=item['union']['domain'], problem=old['problem'],
                             mapping=str(Path(item['union']['domain']).with_name('mapping.json')), terms=old['terms'])
                tasks.append(t)
        result = {'status': failure['status'], 'group': g, 'source_tasks': tasks, 'candidate_statuses': item['candidate_statuses']}
    result.update(construction={'status': 'unavailable_construction', 'failure': failure},
        composition_tasks=[{'id': g['id'] + '__composition__' + c, 'group': g['id'], 'cohort': g['cohort'],
            'method': g['method'], 'size': g['size'], 'sources': g['sources'], 'condition': c,
            'status': 'unavailable_construction', 'reason': failure} for c in CONDITIONS])
    write(folder / 'failure_accounting.json', result)
    return result


def compile_all(root, state):
    groups = read(root / 'selected_groups.json')['groups']
    p = read(root / 'protocol.json')
    rows, original, composition = [], [], []
    with ThreadPoolExecutor(max_workers=p['budgets']['compiler_workers']) as pool:
        jobs = {pool.submit(call_worker, root, 'group-worker', g['id'],
            root / 'repeat_01/compile_workers' / g['id'], p['budgets']['group_construction_seconds']): g for g in groups}
        for future in as_completed(jobs):
            g = jobs[future]
            result = future.result()
            if 'source_tasks' not in result:
                result = recover_compilation(root, g, result)
            original.extend(result['source_tasks']); composition.extend(result['composition_tasks'])
            rows.append({k: v for k, v in result.items() if k not in ('source_tasks', 'composition_tasks', 'audits')})
            progress(root, state, stage='compilation', compiled_groups=len(rows), registered_groups=len(groups),
                     compilation_statuses=dict(Counter(r['status'] for r in rows)))
    original.sort(key=lambda t: (C.rank('original-slot-order-v1', t['group']), t['condition'], t['world']))
    composition.sort(key=lambda t: (C.rank('composition-slot-order-v1', t['group']), t['condition']))
    if (len(original), sum(t['search_anchor'] for t in original), len(composition)) != (21056, 4800, 2400):
        raise ValueError('Compiled task denominator mismatch')
    for name, value in (('original_tasks', {'tasks': original}), ('composition_tasks', {'tasks': composition}),
                        ('compilation_report', {'rows': sorted(rows, key=lambda r: r['group']['id'])})):
        write(root / 'repeat_01' / (name + '.json'), value)
    files = [f for f in (root / 'repeat_01/groups').rglob('*') if f.is_file()]
    files += [root / 'repeat_01' / (n + '.json') for n in ('original_tasks', 'composition_tasks', 'compilation_report')]
    write(root / 'repeat_01/compiled_freeze.json', {'status': 'frozen_before_main_search',
        'created_utc': now(), 'input_sha256': {str(f): digest(f) for f in files}})


def execute_jobs(root, tasks, label, state, deadline):
    p = read(root / 'protocol.json')
    write(root / 'repeat_01/jobs' / (label + '.json'), {'tasks': tasks})
    results = []
    def one(task):
        if task.get('status') != 'ready':
            return {**task, 'valid': False, 'native_valid': False,
                    'search': {'status': task['status'], 'search_calls': 0}}
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            return {**task, 'status': 'not_run_total_budget', 'valid': False, 'native_valid': False,
                    'search': {'status': 'not_run_total_budget', 'search_calls': 0}}
        value = call_worker(root, 'plan-worker', task['id'], root / 'repeat_01/plan_workers' / label / task['id'],
                            min(p['budgets']['planning_worker_seconds'], remaining), task=task)
        if value.get('status') != 'complete':
            value = {**task, **value, 'valid': False, 'native_valid': False,
                     'search': {'status': value['status'], 'search_calls': None, 'attempt_accounting': 'inspect_saved_invocation'}}
        return value
    with (root / 'repeat_01' / (label + '_events.jsonl')).open('x', encoding='utf-8') as stream:
        with ThreadPoolExecutor(max_workers=p['budgets']['planner_workers']) as pool:
            futures = [pool.submit(one, task) for task in tasks]
            for future in as_completed(futures):
                result = future.result(); results.append(result)
                stream.write(json.dumps(result, ensure_ascii=False) + '\n'); stream.flush()
                progress(root, state, stage=label, completed_stage_slots=len(results), registered_stage_slots=len(tasks),
                         stage_dual_validated=sum(r.get('valid', False) for r in results))
    write(root / 'repeat_01' / (label + '_report.json'), {'registered_slots': len(tasks), 'rows': sorted(results, key=lambda r: r['id'])})
    return results


def execute_all(root, state):
    p = read(root / 'protocol.json')
    verify_hashes(read(root / 'repeat_01/compiled_freeze.json')['input_sha256'])
    deadline = time.monotonic() + p['budgets']['planning_total_seconds']
    native = []
    for w in read(root / 'baseline_tasks.json')['worlds']:
        for c in ('raw', 'adapter'):
            native.append({'id': w['id'] + '__' + c, 'world': w['id'], 'source': w['source'], 'cohort': w['pool'],
                'condition': c, 'kind': 'native', 'domain': w['raw_domain'] if c == 'raw' else w['adapter_domain'],
                'problem': w['raw_problem'] if c == 'raw' else w.get('adapter_problem'),
                'status': 'ready' if c == 'raw' or w['adapter_status'] == 'ready' else 'unsupported_original_world'})
    native.sort(key=lambda t: C.rank('native-world-order-v1', t['id']))
    results = execute_jobs(root, native, 'native', state, deadline)
    references = C.make_references(root, results)
    original = read(root / 'repeat_01/original_tasks.json')['tasks']
    transports = []
    for task in original:
        ref = references[task['world']]
        t = {**task, 'kind': 'transport', 'reference': ref}
        if task['status'] == 'ready':
            if ref['status'] == 'available':
                t['source_plan'] = ref['source_plan']
            else:
                t['status'] = ref['status']
        transports.append(t)
    execute_jobs(root, transports, 'transport', state, deadline)
    execute_jobs(root, [{**t, 'kind': 'anchor'} for t in original if t['search_anchor']], 'anchor', state, deadline)
    execute_jobs(root, [{**t, 'kind': 'composition'} for t in read(root / 'repeat_01/composition_tasks.json')['tasks']],
                 'composition', state, deadline)


def outcome(row):
    if not row:
        return 'not_recorded'
    if row.get('valid'):
        return 'dual_validated'
    if row.get('native_valid'):
        return 'native_only'
    if row.get('search', {}).get('status') in ('solved', 'not_a_search'):
        replay = row.get('replay', {})
        physical = replay.get('physical', {})
        if physical.get('status') == 'inapplicable' or (physical.get('status') == 'replayed' and physical.get('goal') is False):
            return 'physical_violation'
        if replay.get('status') == 'replayed' and (replay.get('goal') is False or replay.get('unexplained_steps', 0) > 0):
            return 'intentional_or_goal_violation'
        return 'replay_' + replay.get('status', 'not_recorded')
    return row.get('search', {}).get('status', row.get('status', 'unknown'))


def paired(rows, key, identities=None):
    pairs = defaultdict(dict)
    for identity in identities or ():
        pairs[identity] = {}
    for row in rows:
        identity = tuple(row[k] for k in key)
        if row['condition'] in pairs[identity]:
            raise ValueError('Duplicate paired condition')
        pairs[identity][row['condition']] = row
    table = Counter()
    for values in pairs.values():
        table[(outcome(values.get('union')), outcome(values.get('full')))] += 1
    return {'registered_pairs': len(pairs),
            'both_dual_validated': table['dual_validated', 'dual_validated'],
            'full_only_dual_validated': sum(n for (a, b), n in table.items() if a != 'dual_validated' and b == 'dual_validated'),
            'union_only_dual_validated': sum(n for (a, b), n in table.items() if a == 'dual_validated' and b != 'dual_validated'),
            'outcome_matrix': [{'union': a, 'full': b, 'pairs': n} for (a, b), n in sorted(table.items())],
            'note': 'Only indicates observed validation asymmetry; unavailable/timeout is not a proved failure.'}


def evaluation(root, terminal):
    groups = read(root / 'selected_groups.json')['groups']
    worlds = read(root / 'worlds.json')['worlds']
    reports = {}
    for label in EXPECTED:
        path = root / 'repeat_01' / (label + '_report.json')
        events = root / 'repeat_01' / (label + '_events.jsonl')
        reports[label] = read(path)['rows'] if path.exists() else [json.loads(line) for line in events.read_text(encoding='utf-8').splitlines()] if events.exists() else []
    compiled = root / 'repeat_01/compilation_report.json'
    compilations = {r['group']['id']: r for r in read(compiled)['rows']} if compiled.exists() else {}
    cells = []
    for cohort in ('story', 'human', 'mixed'):
        for k in (2, 3, 4, 5):
            for method in ('random', 'causal_link'):
                gs = [g for g in groups if (g['cohort'], g['size'], g['method']) == (cohort, k, method)]
                ids = {g['id'] for g in gs}
                cell = {'cohort': cohort, 'k': k, 'method': method, 'registered_groups': len(gs),
                    'compile_statuses': dict(Counter(compilations.get(g['id'], {}).get('status', 'not_recorded') for g in gs)),
                    'construction_statuses': dict(Counter(compilations.get(g['id'], {}).get('construction', {}).get('status', 'not_recorded') for g in gs)),
                    'conditions': {c: {} for c in CONDITIONS}, 'paired': {}}
                for stage in ('transport', 'anchor', 'composition'):
                    rr = [r for r in reports[stage] if r['group'] in ids]
                    identities = []
                    for g in gs:
                        if stage == 'composition':
                            identities.append((g['id'],))
                        else:
                            chosen = [w for w in worlds if w['source'] in g['sources']]
                            if stage == 'anchor':
                                chosen = [next(w for w in chosen if w['source'] == sid) for sid in g['sources'][:2]]
                            identities.extend((g['id'], w['id']) for w in chosen)
                    cell['paired'][stage] = paired(rr, ('group', 'world') if stage != 'composition' else ('group',), identities)
                    for c in CONDITIONS:
                        selected = [r for r in rr if r['condition'] == c]
                        registered = len(identities)
                        values = {'registered': registered, 'recorded': len(selected), 'missing': registered - len(selected),
                                  'dual_validated': sum(r.get('valid', False) for r in selected),
                                  'native_validated': sum(r.get('native_valid', False) for r in selected),
                                  'outcomes': dict(Counter(outcome(r) for r in selected))}
                        if stage == 'transport':
                            strata = defaultdict(list)
                            for r in selected:
                                ref = r.get('reference', {})
                                strata[ref.get('condition', 'unavailable') + '__' + ref.get('validation_level', 'unavailable')].append(r)
                            values['reference_strata'] = {key: {'recorded': len(items), 'dual_validated': sum(x.get('valid', False) for x in items),
                                'native_validated': sum(x.get('native_valid', False) for x in items)} for key, items in strata.items()}
                        cell['conditions'][c][stage] = values
                cells.append(cell)
    integrity = True
    verify_hashes(read(root / 'protocol.json')['input_sha256'])
    if (root / 'repeat_01/compiled_freeze.json').exists():
        verify_hashes(read(root / 'repeat_01/compiled_freeze.json')['input_sha256'])
    report = {'status': 'complete_evaluation', 'experiment_status': terminal, 'created_utc': now(),
        'registered_groups': 1200, 'conditions': list(CONDITIONS), 'cells': cells,
        'inputs_unchanged': integrity, 'new_api_requests': 0, 'independent_semantic_labels': 0,
        'slot_accounting': {label: {'registered': count, 'recorded': len(reports[label]), 'missing': count-len(reports[label])} for label, count in EXPECTED.items()},
        'native_by_pool': [{'pool': pool, 'condition': c, 'recorded': len(rr),
            'dual_validated': sum(r.get('valid', False) for r in rr), 'outcomes': dict(Counter(outcome(r) for r in rr))}
            for pool in ('story', 'human') for c in ('raw', 'adapter')
            for rr in [[r for r in reports['native'] if r['cohort'] == pool and r['condition'] == c]]],
        'limits': read(root / 'protocol.json')['policies']}
    write(root / 'evaluation/report.json', report)
    lines = ['# 冻结版本 union/full 配对统计', '', '状态：' + terminal,
        '每格 50 组。原始目标每条件 100 个固定查询；跨域诊断每条件 50 个登记槽位。',
        '数字为原生意图回放与物理回放均通过的数量；缺失、不支持、未构造和超时保留在登记分母。', '',
        '| 域池 | k | 选取 | 原始目标 union/full | 跨域诊断 union/full | 两者诊断均通过 | 仅 full 通过 | 仅 union 通过 |',
        '|---|---:|---|---:|---:|---:|---:|---:|']
    for cell in cells:
        u, f = cell['conditions']['union'], cell['conditions']['full']; p = cell['paired']['composition']
        lines.append(f"| {cell['cohort']} | {cell['k']} | {cell['method']} | {u['anchor']['dual_validated']}/{f['anchor']['dual_validated']} | {u['composition']['dual_validated']}/{f['composition']['dual_validated']} | {p['both_dual_validated']} | {p['full_only_dual_validated']} | {p['union_only_dual_validated']} |")
    lines += ['', '单侧通过只表示观察到的验证差异，另一侧可能超时或不可用。不能称为不可解证明。',
        '固定来源被重复使用；random 与 causal link 为不同组样本，union/full 才是同组配对。',
        '原始计划运输、raw/adapter 和 native-only 分层见 report.json。没有独立语义或故事质量标注。',
        '本阶段 API 请求数：0。历史文件与冻结输入已重新核验。', '']
    (root / 'evaluation/README.md').write_text('\n'.join(lines), encoding='utf-8')
    write(root / 'evaluation/evidence_sha256.json', {str(f): digest(f) for f in (root / 'evaluation').iterdir() if f.is_file()})
    return {'status': 'complete_evaluation', 'experiment_status': terminal, 'slot_accounting': report['slot_accounting']}


def preflight(root):
    from tests.test_revised_multistory import fixture
    folder = root / 'preflight'
    folder.mkdir()
    inputs = folder / 'inputs'; inputs.mkdir()
    sources, raw = fixture(inputs, 5)
    predicates, _ = C.select_groups(sources, raw, 'predicate')
    inter = C.build(sources, folder / 'intermediate', groups=predicates)
    actions, _ = C.select_groups(sources, raw, 'action', predicate_maps=inter['predicate_maps'])
    full = C.build(sources, folder / 'full', groups=predicates + actions, merge_actions=True)
    if full['action_count'] != 1 or len(actions) != 1:
        raise ValueError('Five-source compiler control failed')
    source = sources[0]
    problem = folder / 'problem.pddl'
    terms = C.map_problem(sources, source.id, full, problem)
    native = folder / 'source_plan.pddl'
    native.write_text('(define (plan p) (:problem p) (:steps (travel alice home away)))', encoding='utf-8')
    common = {'source': source.id, 'domain': str(folder / 'full/domain.pddl'), 'problem': str(problem),
              'mapping': str(folder / 'full/mapping.json'), 'terms': terms, 'status': 'ready'}
    tasks = [{**common, 'id': 'synthetic_search', 'kind': 'anchor'},
             {**common, 'id': 'synthetic_transport', 'kind': 'transport', 'source_plan': str(native)}]
    state = {'status': 'preflight'}
    results = execute_jobs(root, tasks, 'preflight', state, time.monotonic() + 120)
    if not all(r.get('valid') for r in results):
        raise ValueError('Synthetic native/physical replay control failed')
    negative = C.parse_sexpr(problem.read_text(encoding='utf-8'))
    C.section(negative, ':init').remove([source.id + '_active'])
    bad = folder / 'inactive.pddl'; bad.write_text(C.serialize(negative), encoding='utf-8')
    transported = next(r for r in results if r['id'] == 'synthetic_transport')
    result = C.legacy.physical(Path(common['domain']), bad, Path(transported['plan']))
    if result.get('status') != 'inapplicable':
        raise ValueError('Inactive source negative control failed')
    write(folder / 'report.json', {'status': 'passed', 'k': 5, 'controls': results, 'negative': result, 'new_api_requests': 0})


def run(root):
    with (root / 'execution_started.json').open('x', encoding='utf-8') as stream:
        json.dump({'created_utc': now(), 'pid': os.getpid(), 'new_api_requests': 0}, stream)
    state = {'status': 'running', 'stage': 'integrity', 'new_api_requests': 0}
    terminal = 'complete'
    try:
        verify(root)
        preflight(root)
        compile_all(root, state)
        execute_all(root, state)
    except Exception:
        terminal = 'stopped_error'
        write(root / 'terminal_error.json', {'traceback': traceback.format_exc(), 'created_utc': now()})
    progress(root, state, stage='evaluation', status=terminal)
    result = evaluation(root, terminal)
    progress(root, state, stage='finished', status=terminal, evaluation=result)
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('mode', choices=('prepare', 'run', 'group-worker', 'plan-worker'))
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--identifier')
    parser.add_argument('--result', type=Path)
    args = parser.parse_args()
    sys.addaudithook(offline_guard)
    bind()
    root = args.output.resolve()
    if args.mode in ('group-worker', 'plan-worker'):
        try:
            result = group_worker(root, args.identifier) if args.mode == 'group-worker' else C.perform_plan(root, read(args.result.parent / 'task.json'))
        except Exception:
            result = {'status': 'worker_exception', 'traceback': traceback.format_exc()}
        write(args.result, result)
    else:
        print(json.dumps(prepare(root) if args.mode == 'prepare' else run(root), ensure_ascii=False), flush=True)


if __name__ == '__main__':
    main()

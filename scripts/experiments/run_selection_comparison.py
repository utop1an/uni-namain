"""One fresh, matched selection campaign, with automatic terminal evaluation.

The selected groups never change. Pair judgments are shared within this single
round; compilation and explicit diagnostic worlds precede all planning.
"""
import argparse
from collections import Counter, defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
from itertools import combinations, product
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
import traceback

from rcnc import model_semantics, model_semantics_parallel
from prompts import prompt_sources

from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.glaive_intake import casefold_tree
from rcnc.glaive_merge import Source, build, map_problem, translate_plan
from rcnc.glaive_runtime import invoke
from rcnc.model_semantics_contract import include_output_contract
from rcnc.parallel_progress_io import durable_progress
from rcnc.pddl import parse_sexpr, section, serialize
from rcnc.revised_followup import authored_problem
from rcnc.revised_multistory import select_groups
from rcnc.revised_sampling import rank
from scripts.audit.eval_revised_composition import causal_trace, profiles_for
from scripts.data.freeze_selection_comparison import verify as verify_dataset
from scripts.experiments import run_causal_chains as chain
from scripts.experiments import run_revised_multistory as legacy
from scripts.evidence.build_paper_results import build as build_inventory

REPO = Path(__file__).resolve().parents[2]
DATA = REPO / 'data/benchmarks/selection_comparison_k2345_n50_2026_11_05_v2'
CONDITIONS = ('union', 'predicate_only', 'full')
COHORTS = ('story_learned', 'human_authored')


def now():
    return datetime.now(timezone.utc).isoformat()


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def frozen_json(path, value):
    if path.exists():
        raise ValueError('Refusing to overwrite frozen artifact: ' + str(path))
    path.parent.mkdir(parents=True, exist_ok=True)
    save(path, value)


def source_from(row, world=None):
    return Source(row['id'], Path(row['domain']), Path((world or {}).get('problem', row['representative_problem'])),
                  constant_contract=row['constant_contract'])


def native_ok(result):
    return result.get('status') == 'replayed' and result.get('goal') is True and result.get('unexplained_steps') == 0


def replay_level(result):
    if legacy.valid(result):
        return 'dual_validated'
    if native_ok(result) and result.get('physical', {}).get('status') in ('unsupported', 'unsupported_or_invalid'):
        return 'native_only_physical_unknown'
    return 'unavailable_valid_reference'


def inverse_source_plan(source, mapping, terms, plan, output):
    """Invert a one-source union map; never guess ambiguous action origins."""
    reverse_actions = {}
    for ref, value in mapping['action_maps'].items():
        if ref.split(':')[0] != source.id or value['order'] != list(range(len(value['order']))):
            raise ValueError('Only one-source identity action maps can be inverted')
        if value['name'] in reverse_actions:
            raise ValueError('Ambiguous source action map')
        reverse_actions[value['name']] = ref.split(':', 1)[1]
    reverse_terms = {value: key for key, value in terms.items()}
    if len(reverse_terms) != len(terms):
        raise ValueError('Non-injective source object mapping')
    tree = casefold_tree(parse_sexpr(plan.read_text(encoding='utf-8')))
    steps = section(tree, ':steps')
    if steps is None:
        raise ValueError('Missing steps')
    calls = []
    for call in steps[1:]:
        if call[0] == 'non-executed':
            raise ValueError('Counterfactual plan outside transport fragment')
        calls.append([reverse_actions[call[0]], *[reverse_terms[x] for x in call[1:]]])
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(serialize(['define', ['plan', source.id + '_source_reference'],
        [':problem', source.id], [':steps', *calls]]) + '\n', encoding='utf-8')


def augment_axiom_context(stage, sources):
    """Add original axiom formulas before freezing the model requests."""
    from rcnc.model_semantics_compact import prompt, schema
    packet, requests = read(stage / 'packet.json'), read(stage / 'requests.json')
    def occurs(expr, symbol):
        return isinstance(expr, list) and (bool(expr) and expr[0] == symbol or any(occurs(x, symbol) for x in expr))
    added = 0
    for item in packet['items']:
        if item['kind'] == 'predicate':
            for side in item['sides']:
                sid, name = side['reference'].split(':', 1)
                for i, axiom in enumerate(sources[sid].axioms):
                    if occurs(axiom, name):
                        side['contexts'].append({'id': sid + ':axiom_' + str(i), 'text': serialize(axiom)})
                        added += 1
        visible = {key: item[key] for key in ('kind', 'sides')}
        requests[item['id']]['messages'][0]['content'] = prompt(item['kind']) + '\n' + json.dumps(visible)
        requests[item['id']]['format'] = schema(item)
    save(stage / 'packet.json', packet)
    save(stage / 'requests.json', requests)
    manifest = read(stage / 'manifest.json')
    manifest.update(packet_sha256=digest(stage / 'packet.json'), requests_sha256=digest(stage / 'requests.json'),
                    original_axiom_contexts_added=added)
    save(stage / 'manifest.json', manifest)
    include_output_contract(stage)


def preflight(root):
    """Native runtime controls, including a real five-source worker round trip."""
    from tests.test_revised_multistory import fixture
    if root.exists():
        raise ValueError('Fresh preflight directory required')
    root.mkdir(parents=True)
    old = legacy.preflight(root / 'k34_controls')
    runtime = read(legacy.RUNTIME / 'report.json')
    jar, classes = Path(runtime['jar']), REPO / '.tmp/glaive_classes_v1'
    folder = root / 'k5_controls'; folder.mkdir()
    sources, raw = fixture(folder, 5)
    predicates, _ = select_groups(sources, raw, 'predicate')
    pred = build(sources, folder / 'predicate_only', groups=predicates)
    actions, _ = select_groups(sources, raw, 'action', predicate_maps=pred['predicate_maps'])
    full = build(sources, folder / 'full', groups=predicates + actions, merge_actions=True)
    if full['action_count'] != 1 or len(actions) != 1 or len(actions[0]['members']) != 5:
        raise ValueError('Five-source fusion control failed')
    results, tasks = [], []
    for source in sources:
        problem = folder / (source.id + '_problem_mapped.pddl')
        terms = map_problem(sources, source.id, full, problem)
        native = folder / (source.id + '_native_plan.pddl')
        native.write_text('(define (plan p) (:problem p) (:steps (travel alice home away)))', encoding='utf-8')
        plan = folder / (source.id + '_mapped_plan.pddl')
        translate_plan(source.id, full, terms, native, plan)
        negative = parse_sexpr(problem.read_text(encoding='utf-8'))
        section(negative, ':init').remove([source.id + '_active'])
        bad = folder / (source.id + '_inactive.pddl')
        bad.write_text(serialize(negative), encoding='utf-8')
        for label, path in [('positive', problem), ('source_inactive', bad)]:
            result = legacy.replay_checked(jar, classes, folder / 'full/domain.pddl', path, plan,
                                          folder / 'execution' / (source.id + '_' + label), 10)
            passed = legacy.valid(result) if label == 'positive' else result.get('physical', {}).get('status') == 'inapplicable'
            results.append({'id': source.id + '_' + label, 'passed': passed, 'result': result})
        if source.id == 's0':
            common = {'domain': str(folder / 'full/domain.pddl'), 'problem': str(problem),
                      'source': source.id, 'terms': terms, 'mapping': str(folder / 'full/mapping.json'), 'status': 'ready'}
            tasks = [{**common, 'id': 'five_source_search', 'kind': 'anchor'},
                     {**common, 'id': 'five_source_transport', 'kind': 'transport', 'source_plan': str(native)}]
    frozen_json(root / 'protocol.json', {'runtime_jar': str(jar), 'runtime_classes': str(classes),
        'budgets': {'planner_workers': 2, 'planning_worker_seconds': 55, 'search_seconds': 15, 'replay_seconds': 15}})
    state = {'status': 'running', 'stage': 'preflight'}
    smoke = execute_jobs(root, tasks, 'smoke', state, time.monotonic() + 90)
    passed = old['status'] == 'passed' and all(r['passed'] for r in results) and all(r['valid'] for r in smoke)
    report = {'status': 'passed' if passed else 'failed', 'checks': old['checks'] + len(results) + len(smoke),
        'k34': old, 'k5': results, 'worker_smoke': smoke, 'model_calls': 0,
        'implementation_sha256': {str(Path(__file__).resolve()): digest(Path(__file__)),
                                  str(REPO / 'rcnc/glaive_merge.py'): digest(REPO / 'rcnc/glaive_merge.py')}}
    frozen_json(root / 'report.json', report)
    return {'status': report['status'], 'checks': report['checks'], 'model_calls': 0}


def prepare(root, gate):
    if root.exists():
        raise ValueError('Fresh campaign directory required')
    checked = verify_dataset(DATA)
    gate_report = read(gate / 'report.json')
    if gate_report['status'] != 'passed':
        raise ValueError('Preflight did not pass')
    for path, checksum in gate_report['implementation_sha256'].items():
        if digest(Path(path)) != checksum:
            raise ValueError('Implementation changed after preflight: ' + path)
    runtime = read(legacy.RUNTIME / 'report.json')
    if runtime['status'] != 'verified' or digest(Path(runtime['jar'])) != runtime['jar_sha256']:
        raise ValueError('Runtime changed')
    root.mkdir(parents=True)
    (root / 'runtime/classes').mkdir(parents=True)
    shutil.copyfile(runtime['jar'], root / 'runtime/glaive-corrected.jar')
    shutil.copyfile('.tmp/glaive_classes_v1/GlaiveProbe.class', root / 'runtime/classes/GlaiveProbe.class')
    frozen_json(root / 'dataset_audit.json', checked)
    frozen_json(root / 'preflight_report.json', gate_report)
    groups, sources, worlds, candidates, memberships = [], {}, [], [], defaultdict(list)
    for cohort in COHORTS:
        selected = read(DATA / cohort / 'groups.json')['groups']
        groups.extend(selected)
        cohort_worlds = read(DATA / cohort / 'worlds.json')['worlds']
        for row in read(DATA / cohort / 'sources.json')['sources']:
            sources[row['id']] = {**row, 'cohort': cohort,
                'domain': str(DATA / row['domain']), 'representative_problem': str(DATA / row['representative_problem'])}
        worlds.extend({**w, 'cohort': cohort, 'problem': str(DATA / w['problem'])} for w in cohort_worlds)
        pairs = read(DATA / cohort / 'pair_census.json')['pairs']
        used = {p for g in selected for p in combinations(g['sources'], 2)}
        for pair in pairs:
            if tuple(pair['sources']) in used:
                for c in pair['candidates']:
                    candidates.append(c)
                    memberships[c['id']] = [g['id'] for g in selected if set(pair['sources']) <= set(g['sources'])]
    candidates.sort(key=lambda c: rank('selection-round01-request-order-20261105', c['id']))
    if len(groups) != 800 or len(sources) != 72 or len(worlds) != 118 or len(candidates) != 8017:
        raise ValueError('Changed registered denominator')
    source_objects = {sid: source_from(row) for sid, row in sources.items()}
    inputs = root / 'semantic_inputs'
    inputs.mkdir()
    for sid, source in source_objects.items():
        # Canonical spelling only. Symbol digests match Source.domain used by the compiler.
        (inputs / (sid + '_domainfile.pddl')).write_text(serialize(source.root) + '\n', encoding='utf-8')
    stage = root / 'repeat_01/judgments'
    model_semantics.prepare(inputs, candidates, stage, model=legacy.MODEL, model_digest=legacy.MODEL_DIGEST,
        total_seconds=144000, request_seconds=240, schema_policy='compact_kind_specific', num_predict=16384, num_ctx=32768)
    augment_axiom_context(stage, source_objects)
    requests, manifest = read(stage / 'requests.json'), read(stage / 'manifest.json')
    for request in requests.values():
        request['options']['seed'] = 2026110501
    manifest['options']['seed'] = 2026110501
    manifest.update(workers=8, repeat_id='repeat_01',
        seed_note='Single requested seed; provider enforcement unverified; no repeated trials or best-run selection.')
    save(stage / 'requests.json', requests)
    manifest['requests_sha256'] = digest(stage / 'requests.json')
    save(stage / 'manifest.json', manifest)
    frozen_json(root / 'selected_groups.json', {'groups': groups})
    frozen_json(root / 'sources.json', {'sources': list(sources.values())})
    frozen_json(root / 'worlds.json', {'worlds': worlds})
    frozen_json(root / 'candidate_usage.json', {'groups_by_candidate': dict(memberships)})
    # Build each source-only adapter once, with every original problem separate.
    baselines = []
    for sid, source in sorted(source_objects.items()):
        folder = root / 'source_models' / sid
        meta = build([source], folder)
        for world in (w for w in worlds if w['source'] == sid):
            row = {**world, 'raw_domain': str(source.domain_path),
                   'adapter_domain': str(folder / 'domain.pddl'), 'adapter_mapping': str(folder / 'mapping.json')}
            try:
                current = source_from(sources[sid], world)
                problem = folder / 'worlds' / (world['id'] + '.pddl')
                problem.parent.mkdir(parents=True, exist_ok=True)
                terms = map_problem([current], sid, meta, problem)
                row.update(adapter_status='ready', adapter_problem=str(problem), adapter_terms=terms)
            except (ValueError, KeyError, TypeError) as exc:
                row.update(adapter_status='unsupported', reason=str(exc))
            baselines.append(row)
    frozen_json(root / 'baseline_tasks.json', {'worlds': baselines})
    implementation = [*prompt_sources(), *REPO.glob('prompts/unidomain/*.txt'), *REPO.glob('rcnc/*.py'), *REPO.glob('unidomain/*.py'),
                      *REPO.glob('scripts/**/*.py'), REPO / 'tests/test_selection_campaign.py']
    impl = snapshot_implementation(root, sorted(set(implementation)), root=REPO)
    inputs_sha = {str(p.resolve()): digest(p) for p in root.rglob('*') if p.is_file()}
    inputs_sha.update({str(DATA / rel): h for rel, h in read(DATA / 'freeze.json')['artifact_sha256'].items()})
    inputs_sha[str(DATA / 'freeze.json')] = digest(DATA / 'freeze.json')
    protocol = {'status': 'frozen_before_single_round_calls', 'created_utc': now(),
        'dataset': str(DATA), 'dataset_freeze_sha256': checked['freeze_sha256'],
        'repeats': 1, 'groups': 800, 'sources': 72, 'original_worlds': 118,
        'selected_sizes': [2, 3, 4, 5], 'groups_per_cell': 50,
        'conditions': list(CONDITIONS), 'confidence_threshold': .9,
        'model': legacy.MODEL, 'model_digest': legacy.MODEL_DIGEST,
        'runtime_jar': str(root / 'runtime/glaive-corrected.jar'), 'runtime_classes': str(root / 'runtime/classes'),
        'budgets': {'model_requests': len(candidates), 'model_workers': 8, 'model_seconds': 144000,
            'request_seconds': 240, 'attempts': 1, 'search_seconds': 15, 'replay_seconds': 15,
            'planner_memory_mb_per_worker': 4096, 'planner_workers': 2,
            'compiler_workers': 2, 'group_construction_seconds': 120, 'group_route_prefixes': 50000,
            'planning_worker_seconds': 55, 'planning_total_seconds': 259200,
            'original_transport_slots': 23817, 'anchor_search_slots': 4800,
            'raw_and_adapter_native_search_slots': 236, 'composition_search_slots': 6000},
        'policies': [
            'One fresh semantic round; shared same-pair judgments across methods/k within the round. No old predictions, retries or implicit continuation.',
            'Threshold .9, complete-link compatible role-consistent consensus. Same predicate maps for predicate-only/full.',
            'All 800 selected groups retained, including partial/zero-path selection and construction/compile failures.',
            'Every parameterized group model, source-world mapping and diagnostic world is frozen before main planning.',
            'Each original problem remains separate. Search raw and normalized one-source adapter baselines as separate conditions.',
            'Transport references prefer a dual-validated raw plan, then a dual-validated adapter plan; native-only references form a separately reported stratum.',
            'Adapter references are inverse-mapped to source symbols; adapter preservation is not raw-language semantic equivalence.',
            'Every source-world/group/condition transport slot retained; absent references remain unavailable.',
            'Original-goal search uses the first two canonical source IDs and first registered world for each; no success-based anchors.',
            'Same bounded post-merge chain construction for both selection methods: target k down to 2, canonical subsets, one first feasible explicit schema-derived world.',
            'Action paths have contiguous source blocks, no repeated schema, at most k+2 actions; 50000 visited prefixes per group.',
            'Constructed worlds do not copy original problem facts. Original-world and diagnostic-world units remain separate.',
            'Composition controls: union/predicate-only/full, separate_identity under predicate-only, and removing each selected source under predicate-only.',
            'All-k requires a goal-relevant directed causal path covering all selected sources. Ambiguous fused origins stay unknown.',
            'Native intentional replay and independent physical replay are separate. Axioms unsupported by physical validator remain explicitly unknown.',
            'No identical-input planner cache reuse; each registered runnable slot has at most one attempt.',
            'A model transport failure halts this single round and triggers partial evaluation. No automatic model switch, retry or quota repair.',
            'Budget limits, parser errors, invalid outputs, no-solution returns and unsupported evaluations are retained.',
            'Automatic evaluation runs on every terminal state; independent semantic/narrative labels remain zero.'],
        'input_sha256': inputs_sha, 'implementation_sha256': impl}
    frozen_json(root / 'protocol.json', protocol)
    (root / 'PROTOCOL.sha256').write_text(digest(root / 'protocol.json') + '\n', encoding='utf-8')
    return {'status': 'frozen_before_calls', 'groups': 800, 'model_requests': len(candidates),
            'oversize_requests_retained': sum(len(json.dumps(r)) > 60000 for r in requests.values()),
            'protocol_sha256': digest(root / 'protocol.json')}


def verify(root):
    p = read(root / 'protocol.json')
    if digest(root / 'protocol.json') != (root / 'PROTOCOL.sha256').read_text(encoding='utf-8').strip():
        raise ValueError('Protocol changed')
    for name, expected in {**p['input_sha256'], **p['implementation_sha256']}.items():
        if digest(Path(name)) != expected:
            raise ValueError('Frozen dependency changed: ' + name)
    return p


def bounded_routes(ids, profiles, mapping, budget):
    adds, needs, edges = defaultdict(list), defaultdict(list), defaultdict(list)
    for sid in sorted(ids):
        for name, profile in sorted(profiles[sid].items()):
            for key, index in [('effects', adds), ('preconditions', needs)]:
                for i, (positive, atom) in enumerate(profile[key]):
                    pred, order = mapping[sid][atom[0]]
                    if positive:
                        index[pred].append(((sid, name), i, [atom[1+j] for j in order]))
    for pred in sorted(adds.keys() & needs.keys()):
        for (a, i, left), (b, j, right) in product(adds[pred], needs[pred]):
            if a != b and (a[0] == b[0] or pred.startswith('shared_')):
                edges[a].append((b, i, j, list(zip(left, right))))
    def walk(nodes, links):
        budget['visited'] += 1
        if budget['visited'] > budget['limit']:
            raise ValueError('route_prefix_budget_exhausted')
        seen = {n[0] for n in nodes}
        if len(seen) == len(ids):
            yield nodes, links
            return
        if len(nodes) == len(ids) + 2:
            return
        for edge in sorted(edges.get(nodes[-1], [])):
            if edge[0] not in nodes and (edge[0][0] == nodes[-1][0] or edge[0][0] not in seen):
                yield from walk(nodes + [edge[0]], links + [edge])
    for node in sorted(edges):
        yield from walk([node], [])


def construct_case(group, sources, mapping, limit=50000):
    profiles, excluded = profiles_for(sources)
    for sid in profiles:
        profiles[sid] = {name: p for name, p in profiles[sid].items()
            if all(atom[0] in sources[sid].domain.predicates
                   for field in ('effects', 'preconditions') for _, atom in p[field])}
    budget = {'visited': 0, 'limit': limit}
    tried = 0
    for size in range(group['size'], 1, -1):
        for ids in combinations(sorted(group['sources']), size):
            for nodes, links in bounded_routes(ids, profiles, mapping, budget):
                tried += 1
                for world, handoffs in chain.worlds(group['id'], nodes, links, sources, profiles, mapping):
                    world.update(world_kind='explicit_schema_derived_diagnostic_fixture', source_problem_facts_copied=0)
                    return {'status': 'constructed', 'target_sources': list(ids), 'target_size': size,
                            'nodes': nodes, 'handoffs': handoffs, 'scenario': world,
                            'route_prefixes': budget['visited'], 'schema_routes_tried': tried,
                            'excluded_profiles': excluded}
    return {'status': 'no_supported_world', 'route_prefixes': budget['visited'],
            'schema_routes_tried': tried, 'excluded_profiles': excluded}


def group_worker(root, gid):
    protocol = read(root / 'protocol.json')
    group = next(g for g in read(root / 'selected_groups.json')['groups'] if g['id'] == gid)
    rows = {r['id']: r for r in read(root / 'sources.json')['sources']}
    worlds = read(root / 'worlds.json')['worlds']
    selected = [source_from(rows[s]) for s in group['sources']]
    sources = {s.id: s for s in selected}
    raw = read(root / 'repeat_01/judgments/groups.json')['groups']
    folder = root / 'repeat_01/groups' / gid
    models, source_tasks, cross_tasks = {}, [], []
    predicates, pa = select_groups(selected, raw, 'predicate', threshold=.9)
    models['union'] = build(selected, folder / 'union')
    models['predicate_only'] = build(selected, folder / 'predicate_only', groups=predicates)
    actions, aa = select_groups(selected, raw, 'action', threshold=.9, predicate_maps=models['predicate_only']['predicate_maps'])
    models['full'] = build(selected, folder / 'full', groups=predicates + actions, merge_actions=True)
    if models['predicate_only']['predicate_maps'] != models['full']['predicate_maps']:
        raise ValueError('Predicate maps differ between conditions')
    for condition, meta in models.items():
        model_folder = folder / condition
        for sid in group['sources']:
            source_worlds = [w for w in worlds if w['source'] == sid]
            for index, world in enumerate(source_worlds):
                task = {'id': gid + '__' + condition + '__' + world['id'], 'group': gid,
                    'cohort': group['cohort'], 'method': group['method'], 'size': group['size'],
                    'condition': condition, 'source': sid, 'world': world['id'],
                    'domain': str(model_folder / 'domain.pddl'), 'mapping': str(model_folder / 'mapping.json'),
                    'search_anchor': sid in group['sources'][:2] and index == 0}
                try:
                    local = source_from(rows[sid], world)
                    problem = model_folder / 'worlds' / (world['id'] + '.pddl')
                    problem.parent.mkdir(parents=True, exist_ok=True)
                    problem_sources = [local if s.id == sid else s for s in selected]
                    terms = map_problem(problem_sources, sid, meta, problem)
                    task.update(status='ready', problem=str(problem), terms=terms)
                except (ValueError, KeyError, TypeError) as exc:
                    task.update(status='unsupported_world', reason=str(exc))
                source_tasks.append(task)
    try:
        case = construct_case(group, sources, models['predicate_only']['predicate_maps'],
                              protocol['budgets']['group_route_prefixes'])
    except (ValueError, KeyError, TypeError, IndexError) as exc:
        case = {'status': 'construction_unsupported_or_limit', 'reason': str(exc)}
    conditions = [*CONDITIONS, 'separate_identity', *('without_' + s for s in group['sources'])]
    for condition in conditions:
        task = {'id': gid + '__composition__' + condition, 'group': gid, 'cohort': group['cohort'],
                'method': group['method'], 'size': group['size'], 'sources': group['sources'], 'condition': condition}
        if case['status'] != 'constructed':
            task.update(status=case['status'], reason=case.get('reason'))
        else:
            base_condition = condition if condition in CONDITIONS else 'predicate_only'
            model = folder / base_condition
            problem = folder / 'composition' / (condition + '.pddl')
            active = [s for s in group['sources'] if condition != 'without_' + s]
            try:
                receipt = authored_problem(selected, models[base_condition], case['scenario'], problem,
                    active_sources=active, separate_identity=condition == 'separate_identity')
                if receipt['source_problem_facts_copied'] != 0:
                    raise ValueError('Source facts were pooled')
                task.update(status='ready', domain=str(model / 'domain.pddl'), problem=str(problem),
                            mapping=str(model / 'mapping.json'), world_receipt=receipt)
            except (ValueError, KeyError, TypeError) as exc:
                task.update(status='world_export_unsupported', reason=str(exc))
        cross_tasks.append(task)
    result = {'status': 'compiled', 'group': group, 'models': models, 'source_tasks': source_tasks,
              'composition_tasks': cross_tasks, 'construction': case, 'predicate_audit': pa, 'action_audit': aa}
    frozen_json(folder / 'compilation.json', result)
    return result


def call_worker(root, mode, identifier, output, seconds, task=None):
    output.mkdir(parents=True, exist_ok=True)
    result_path = output / 'worker_result.json'
    if result_path.exists():
        raise ValueError('Worker result already exists')
    if task is not None:
        frozen_json(output / 'task.json', task)
    command = [sys.executable, '-m', 'scripts.experiments.run_selection_comparison', mode,
               '--output', str(root), '--identifier', identifier, '--result', str(result_path)]
    started = time.monotonic()
    with (output / 'worker.log').open('wb') as log:
        try:
            process = subprocess.run(command, cwd=REPO, stdout=log, stderr=subprocess.STDOUT,
                                     timeout=seconds, creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0))
        except subprocess.TimeoutExpired:
            result = {'status': 'worker_wall_time_limit', 'seconds': time.monotonic() - started}
            save(output / 'worker_timeout.json', result)
            return result
    if result_path.exists():
        return read(result_path)
    return {'status': 'worker_failed_without_result', 'returncode': process.returncode}


def compilation_failure_tasks(group, worlds, reason):
    source_tasks = []
    for condition in CONDITIONS:
        for sid in group['sources']:
            for index, world in enumerate(w for w in worlds if w['source'] == sid):
                source_tasks.append({'id': group['id'] + '__' + condition + '__' + world['id'],
                    'group': group['id'], 'cohort': group['cohort'], 'method': group['method'],
                    'size': group['size'], 'condition': condition, 'source': sid, 'world': world['id'],
                    'search_anchor': sid in group['sources'][:2] and index == 0,
                    'status': 'unavailable_compilation', 'reason': reason})
    cross_tasks = [{'id': group['id'] + '__composition__' + c, 'group': group['id'],
                   'cohort': group['cohort'], 'method': group['method'], 'size': group['size'],
                   'sources': group['sources'], 'condition': c, 'status': 'unavailable_compilation', 'reason': reason}
                  for c in [*CONDITIONS, 'separate_identity', *('without_' + s for s in group['sources'])]]
    return source_tasks, cross_tasks


def compile_all(root, state):
    p = verify(root)
    groups, worlds = read(root / 'selected_groups.json')['groups'], read(root / 'worlds.json')['worlds']
    results, originals, compositions = [], [], []
    with ThreadPoolExecutor(max_workers=p['budgets']['compiler_workers']) as pool:
        jobs = {pool.submit(call_worker, root, 'group-worker', g['id'],
                           root / 'repeat_01/compile_workers' / g['id'], p['budgets']['group_construction_seconds']): g for g in groups}
        for future in as_completed(jobs):
            g = jobs[future]
            result = future.result()
            if result['status'] == 'compiled':
                originals.extend(result['source_tasks'])
                compositions.extend(result['composition_tasks'])
                result = {k: v for k, v in result.items() if k not in ('source_tasks', 'composition_tasks', 'models', 'predicate_audit', 'action_audit')}
            else:
                a, b = compilation_failure_tasks(g, worlds, result)
                originals.extend(a); compositions.extend(b)
                result = {'group': g, 'status': result['status'], 'failure': result}
            results.append(result)
            state.update(compiled_groups=len(results), compilation_statuses=dict(Counter(r['status'] for r in results)))
            durable_progress(root / 'coordinator.json', state)
    originals.sort(key=lambda x: (rank('original-slot-order-v1', x['group']), x['condition'], x['world']))
    compositions.sort(key=lambda x: (rank('composition-slot-order-v1', x['group']), x['condition']))
    if len(originals) != p['budgets']['original_transport_slots'] or sum(t['search_anchor'] for t in originals) != 4800 or len(compositions) != 6000:
        raise ValueError('Compilation denominator mismatch')
    frozen_json(root / 'repeat_01/original_tasks.json', {'tasks': originals})
    frozen_json(root / 'repeat_01/composition_tasks.json', {'tasks': compositions})
    frozen_json(root / 'repeat_01/compilation_report.json', {'status': 'complete_compilation_census',
                'registered_groups': 800, 'rows': sorted(results, key=lambda r: r['group']['id'])})
    files = [f for f in (root / 'repeat_01/groups').rglob('*') if f.is_file()]
    files += [root / 'repeat_01' / n for n in ('original_tasks.json', 'composition_tasks.json', 'compilation_report.json')]
    frozen_json(root / 'repeat_01/compiled_freeze.json', {'status': 'frozen_before_all_main_search',
        'created_utc': now(), 'input_sha256': {str(f): digest(f) for f in files}})


def perform_plan(root, task):
    p = read(root / 'protocol.json')
    jar, classes = Path(p['runtime_jar']), Path(p['runtime_classes'])
    out = root / 'repeat_01/execution' / task['kind'] / task['id']
    result = {**task, 'status': 'complete', 'valid': False, 'native_valid': False}
    domain, problem = Path(task['domain']), Path(task['problem'])
    if task['kind'] == 'transport':
        plan = out / 'plan.pddl'
        plan.parent.mkdir(parents=True, exist_ok=True)
        translate_plan(task['source'], read(Path(task['mapping'])), task['terms'], Path(task['source_plan']), plan)
        result['search'] = {'status': 'not_a_search', 'search_calls': 0}
    else:
        result['search'] = invoke(jar, domain, problem, out / 'search', seconds=p['budgets']['search_seconds'])
        if result['search']['status'] != 'solved':
            return result
        plan = out / 'search/plan.pddl'
    result['plan'] = str(plan)
    result['replay'] = legacy.replay_checked(jar, classes, domain, problem, plan, out / 'replay', p['budgets']['replay_seconds'])
    result['valid'], result['native_valid'] = legacy.valid(result['replay']), native_ok(result['replay'])
    result['validation_level'] = replay_level(result['replay'])
    if task['kind'] == 'composition' and result['valid']:
        try:
            result['causal'] = causal_trace(domain, problem, plan, read(Path(task['mapping'])))
            result['all_k_path'] = chain.chain_path(result['causal'], task['sources'])
        except (ValueError, KeyError, TypeError, IndexError) as exc:
            result['causal'] = {'status': 'unknown', 'reason': str(exc)}
            result['all_k_path'] = []
    return result


def execute_jobs(root, tasks, label, state, deadline):
    """Register all jobs before execution; each job is isolated and bounded."""
    p = read(root / 'protocol.json')
    jobs_path = root / 'repeat_01/jobs' / (label + '.json')
    frozen_json(jobs_path, {'tasks': tasks})
    results = []
    def one(task):
        if task.get('status') not in (None, 'ready'):
            return {**task, 'valid': False, 'native_valid': False, 'search': {'status': task['status'], 'search_calls': 0}}
        if time.monotonic() >= deadline:
            return {**task, 'status': 'not_run_total_budget', 'valid': False,
                    'search': {'status': 'not_run_total_budget', 'search_calls': 0}}
        ident = label + ':' + task['id']
        value = call_worker(root, 'plan-worker', ident, root / 'repeat_01/plan_workers' / label / task['id'],
                            min(p['budgets']['planning_worker_seconds'], max(1, deadline - time.monotonic())), task=task)
        if value['status'] != 'complete':
            value = {**task, **value, 'valid': False,
                     'search': {'status': value['status'], 'search_calls': None, 'attempt_accounting': 'inspect_saved_invocation'}}
        return value
    with (root / 'repeat_01' / (label + '_events.jsonl')).open('x', encoding='utf-8') as stream:
        with ThreadPoolExecutor(max_workers=p['budgets']['planner_workers']) as pool:
            futures = {pool.submit(one, task): task['id'] for task in tasks}
            for future in as_completed(futures):
                result = future.result()
                results.append(result)
                stream.write(json.dumps(result) + '\n'); stream.flush()
                state.update(stage=label, completed_stage_slots=len(results), registered_stage_slots=len(tasks))
                durable_progress(root / 'coordinator.json', state)
    frozen_json(root / 'repeat_01' / (label + '_report.json'), {'status': 'complete_registered_slots',
                'registered_slots': len(tasks), 'rows': sorted(results, key=lambda r: r['id'])})
    return results


def make_references(root, native_results):
    by_id = {r['id']: r for r in native_results}
    sources = {r['id']: r for r in read(root / 'sources.json')['sources']}
    references = {}
    for world in read(root / 'baseline_tasks.json')['worlds']:
        wid, selected = world['id'], None
        # Prefer independent physical validation over a native-only fallback.
        for level in ('dual_validated', 'native_only_physical_unknown'):
            for condition in ('raw', 'adapter'):
                candidate = by_id[wid + '__' + condition]
                if candidate.get('validation_level') == level:
                    selected = (condition, candidate, level)
                    break
            if selected:
                break
        row = {'world': wid, 'source': world['source'], 'status': 'unavailable_valid_reference'}
        if selected:
            condition, result, level = selected
            plan = Path(result['plan'])
            if condition == 'adapter':
                source = source_from(sources[world['source']], world)
                plan = root / 'repeat_01/references' / (wid + '.pddl')
                inverse_source_plan(source, read(Path(world['adapter_mapping'])), world['adapter_terms'], Path(result['plan']), plan)
            row.update(status='available', condition=condition, validation_level=level,
                       source_plan=str(plan), source_plan_sha256=digest(plan))
        references[wid] = row
    frozen_json(root / 'repeat_01/references.json', {'worlds': references})
    return references


def execute_all(root, state):
    p = verify(root)
    for path, checksum in read(root / 'repeat_01/compiled_freeze.json')['input_sha256'].items():
        if digest(Path(path)) != checksum:
            raise ValueError('Compiled artifact changed')
    deadline = time.monotonic() + p['budgets']['planning_total_seconds']
    native = []
    for world in read(root / 'baseline_tasks.json')['worlds']:
        for condition in ('raw', 'adapter'):
            ready = condition == 'raw' or world['adapter_status'] == 'ready'
            native.append({'id': world['id'] + '__' + condition, 'world': world['id'], 'source': world['source'],
                'cohort': world['cohort'], 'condition': condition, 'kind': 'native',
                'domain': world['raw_domain'] if condition == 'raw' else world['adapter_domain'],
                'problem': world['problem'] if condition == 'raw' else world.get('adapter_problem'),
                'status': 'ready' if ready else 'unsupported_original_world'})
    native.sort(key=lambda t: rank('native-world-order-v1', t['id']))
    native_results = execute_jobs(root, native, 'native', state, deadline)
    references = make_references(root, native_results)
    original = read(root / 'repeat_01/original_tasks.json')['tasks']
    anchors = [{**t, 'kind': 'anchor'} for t in original if t['search_anchor']]
    transports = []
    for task in original:
        ref = references[task['world']]
        row = {**task, 'kind': 'transport', 'reference': ref}
        if task['status'] == 'ready':
            if ref['status'] == 'available':
                row['source_plan'] = ref['source_plan']
            else:
                row['status'] = ref['status']
        transports.append(row)
    execute_jobs(root, transports, 'transport', state, deadline)
    execute_jobs(root, anchors, 'anchor', state, deadline)
    composition = [{**t, 'kind': 'composition'} for t in read(root / 'repeat_01/composition_tasks.json')['tasks']]
    execute_jobs(root, composition, 'composition', state, deadline)


def evaluation(root, terminal_status):
    """Keep 800 group rows and all planned denominators even after a stopped run."""
    output = root / 'evaluation'
    if output.exists():
        raise ValueError('Evaluation already exists')
    output.mkdir()
    p = read(root / 'protocol.json')
    groups = read(root / 'selected_groups.json')['groups']
    reports = {}
    for label in ('native', 'transport', 'anchor', 'composition'):
        path = root / 'repeat_01' / (label + '_report.json')
        if path.exists():
            reports[label] = read(path)['rows']
        else:
            events = root / 'repeat_01' / (label + '_events.jsonl')
            data = events.read_bytes() if events.exists() else b''
            lines = data.splitlines() if data.endswith(b'\n') else data.splitlines()[:-1]
            reports[label] = [json.loads(line) for line in lines]
    comp_path = root / 'repeat_01/compilation_report.json'
    compilations = {r['group']['id']: r for r in read(comp_path)['rows']} if comp_path.exists() else {}
    rows = []
    for group in groups:
        result = {**{k: group[k] for k in ('id', 'cohort', 'method', 'size')},
                  'compile_status': compilations.get(group['id'], {}).get('status', 'not_run'),
                  'construction_status': compilations.get(group['id'], {}).get('construction', {}).get('status', 'not_run'),
                  'conditions': {}}
        for condition in CONDITIONS:
            values = [r for r in reports['composition'] if r['group'] == group['id'] and r['condition'] == condition]
            item = values[0] if values else {}
            causal = item.get('causal', {})
            result['conditions'][condition] = {'status': item.get('search', {}).get('status', item.get('status', 'not_run')),
                'valid': item.get('valid', False), 'native_valid': item.get('native_valid', False),
                'cross': item.get('valid', False) and causal.get('status') == 'cross_source_composition',
                'all_k': item.get('valid', False) and bool(item.get('all_k_path')),
                'origin_unknown': item.get('valid', False) and causal.get('status') == 'unknown',
                'causal_unknown_reason': causal.get('reason')}
        removal = [r for r in reports['composition'] if r['group'] == group['id'] and r['condition'].startswith('without_')]
        result['source_removal'] = {'registered': group['size'], 'recorded': len(removal),
            'valid_alternative_plans': sum(r.get('valid', False) for r in removal),
            'statuses': dict(Counter(r.get('search', {}).get('status', r['status']) for r in removal)),
            'scope': 'No returned plan under a budget is not an unsolvability proof.'}
        rows.append(result)
    cells = []
    for cohort, method, size in product(COHORTS, ('random', 'causal_path'), (2, 3, 4, 5)):
        selected = [r for r in rows if (r['cohort'], r['method'], r['size']) == (cohort, method, size)]
        cell = {'cohort': cohort, 'method': method, 'k': size, 'registered_groups': 50,
                'compile_statuses': dict(Counter(r['compile_status'] for r in selected)),
                'construction_statuses': dict(Counter(r['construction_status'] for r in selected)),
                'conditions': {}}
        for condition in CONDITIONS:
            values = [r['conditions'][condition] for r in selected]
            preserved = [r for r in reports['transport'] if (r['cohort'], r['method'], r['size'], r['condition']) == (cohort, method, size, condition)]
            strata = {}
            for origin in ('raw', 'adapter'):
                for level in ('dual_validated', 'native_only_physical_unknown'):
                    rr = [r for r in preserved if r.get('reference', {}).get('condition') == origin
                          and r['reference'].get('validation_level') == level]
                    strata[origin + '__' + level] = {'available_reference_slots': len(rr),
                        'dual_validated_transports': sum(r.get('valid', False) for r in rr),
                        'native_validated_transports': sum(r.get('native_valid', False) for r in rr)}
            cell['conditions'][condition] = {key: sum(v[key] for v in values)
                for key in ('valid', 'native_valid', 'cross', 'all_k', 'origin_unknown')}
            cell['conditions'][condition].update(composition_statuses=dict(Counter(v['status'] for v in values)),
                transport_recorded_slots=len(preserved), transport_reference_strata=strata,
                transport_statuses=dict(Counter(r.get('validation_level', r['status']) for r in preserved)))
            searched = [r for r in reports['anchor'] if (r['cohort'], r['method'], r['size'], r['condition']) == (cohort, method, size, condition)]
            cell['conditions'][condition]['original_goal_search'] = {
                'registered': 100, 'recorded': len(searched),
                'dual_validated': sum(r.get('valid', False) for r in searched),
                'statuses': dict(Counter(r.get('search', {}).get('status', r['status']) for r in searched))}
        cells.append(cell)
    judgments_path = root / 'repeat_01/judgments/report.json'
    judgments = read(judgments_path) if judgments_path.exists() else {}
    integrity = all(digest(Path(name)) == checksum for name, checksum in p['input_sha256'].items())
    compiled_path = root / 'repeat_01/compiled_freeze.json'
    if compiled_path.exists():
        integrity = integrity and all(digest(Path(name)) == checksum for name, checksum in read(compiled_path)['input_sha256'].items())
    expected = {'native': 236, 'transport': 23817, 'anchor': 4800, 'composition': 6000}
    report = {'status': 'complete_evaluation', 'experiment_status': terminal_status, 'created_utc': now(),
        'experiment_condition': p.get('condition', 'fresh_single_round'),
        'continuation': p.get('continuation'),
        'registered_groups': 800, 'rows': rows, 'cells': cells, 'inputs_unchanged': integrity,
        'slot_accounting': {label: {'registered': expected[label], 'recorded': len(rr), 'not_run': expected[label] - len(rr)}
                            for label, rr in reports.items()},
        'judgments': {k: judgments.get(k) for k in ('execution_status', 'candidate_count', 'requests_attempted', 'status_counts', 'stop_reason',
            'condition', 'retained_parent_outputs', 'parent_requests_attempted', 'new_requests_attempted', 'new_retry_attempts',
            'candidate_requests_attempted', 'parent_elapsed_seconds', 'elapsed_seconds')},
        'native_by_cohort_condition': [{
            'cohort': cohort, 'condition': condition, 'recorded': len(selected),
            'dual_validated': sum(r.get('valid', False) for r in selected),
            'native_validated': sum(r.get('native_valid', False) for r in selected),
            'search_statuses': dict(Counter(r.get('search', {}).get('status', r['status']) for r in selected))}
            for cohort, condition in product(COHORTS, ('raw', 'adapter'))
            for selected in [[r for r in reports['native'] if r['cohort'] == cohort and r['condition'] == condition]]],
        'independent_semantic_labels': 0,
        'limits': ['Known sources and correlated group reuse; no independent story/semantic labels.',
                   'Raw references and explicitly normalized adapter references are separate strata.',
                   'Structural candidates, feasible authored worlds, valid plans, Cross and All-k have distinct denominators.',
                   'Native-only replay is not promoted to dual validation. Physical axiom support remains unknown.',
                   'No returned plan or timeout is not proof of unsolvability.']}
    frozen_json(output / 'report.json', report)
    lines = ['# 单轮选择实验 Evaluation', '', '实验状态：' + terminal_status,
        '', '实验条件：' + p.get('condition', 'fresh_single_round'),
        '若为 continuation，则包含中断前缓存与有限重试，不能报告为原始无重试 fresh round。',
        '', '| 来源 | 选择 | k | 登记组 | 构造成功 | 条件 | Valid | Cross | All-k | Origin? |',
        '|---|---|---:|---:|---:|---|---:|---:|---:|---:|']
    for cell in cells:
        for condition, values in cell['conditions'].items():
            lines.append(f"| {cell['cohort']} | {cell['method']} | {cell['k']} | 50 | {cell['construction_statuses'].get('constructed', 0)} | {condition} | {values['valid']} | {values['cross']} | {values['all_k']} | {values['origin_unknown']} |")
    lines += ['', 'Valid 要求原生意图回放与独立物理回放均通过。Cross 要求与目标相关的跨源因果边；All-k 要求同一条路径覆盖全部 k 个来源。',
        '原始计划保持详见 report.json 中 transport_reference_strata；raw 与 adapter 分开，native-only 不计为独立物理验证通过。',
        '未构造、未运行、不支持、超时和归属未知均保留；表中零值不将未运行或未知改称失败。',
        '槽位统计：' + json.dumps(report['slot_accounting'], ensure_ascii=False), '']
    (output / 'README.md').write_text('\n'.join(lines), encoding='utf-8')
    index = {'reports': {'selection_round01_evaluation': {'path': str(output / 'report.json'),
        'sha256': digest(output / 'report.json'), 'terminal_status': 'complete_evaluation',
        'scope': 'One registered development round; retain incomplete and unsupported units.',
        'metrics': ['experiment_status', 'experiment_condition', 'continuation', 'registered_groups', 'cells', 'slot_accounting', 'judgments'],
        'denominator': 'registered_groups', 'row_id': 'id', 'required_true': ['inputs_unchanged']}},
        'excluded_pending': [] if terminal_status == 'complete' else ['unexecuted_registered_slots']}
    frozen_json(output / 'evidence_index.json', index)
    build_inventory(output / 'evidence_index.json', output / 'verified_inventory')
    return {'status': 'complete_evaluation', 'experiment_status': terminal_status,
            'registered_groups': 800, 'slot_accounting': report['slot_accounting'], 'inputs_unchanged': integrity}


def pipeline(root):
    p = verify(root)
    if (root / 'coordinator.json').exists():
        raise ValueError('Fresh execution required; no implicit continuation')
    state = {'status': 'running', 'stage': 'judgments', 'started_utc': now(), 'pid': os.getpid(),
             'protocol_sha256': digest(root / 'protocol.json'), 'registered_repeats': 1, 'completed_repeats': 0}
    durable_progress(root / 'coordinator.json', state)
    old_writer = model_semantics_parallel.atomic_save
    try:
        model_semantics_parallel.atomic_save = durable_progress
        judgments = model_semantics_parallel.run(root / 'repeat_01/judgments')
        if judgments['execution_status'] != 'complete':
            state.update(status='stopped_model_stage_incomplete', reason=judgments['stop_reason'])
        else:
            state['stage'] = 'compilation'; durable_progress(root / 'coordinator.json', state)
            compile_all(root, state)
            state['stage'] = 'planning'; durable_progress(root / 'coordinator.json', state)
            execute_all(root, state)
            state.update(status='complete', completed_repeats=1)
    except Exception as exc:
        state.update(status='failed', error=str(exc), traceback=traceback.format_exc())
    finally:
        model_semantics_parallel.atomic_save = old_writer
        state.update(ended_utc=now(), stage='evaluation')
        durable_progress(root / 'coordinator.json', state)
        try:
            state['evaluation'] = evaluation(root, state['status'])
        except Exception as exc:
            state['evaluation'] = {'status': 'failed', 'error': str(exc), 'traceback': traceback.format_exc()}
        state['stage'] = 'terminal'
        durable_progress(root / 'coordinator.json', state)
        save(root / 'report.json', state)
    return state


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument('mode', choices=('preflight', 'prepare', 'verify', 'pipeline', 'group-worker', 'plan-worker', 'evaluate'))
    cli.add_argument('--output', type=Path, required=True)
    cli.add_argument('--gate', type=Path)
    cli.add_argument('--identifier')
    cli.add_argument('--result', type=Path)
    args = cli.parse_args()
    root = args.output.resolve()
    try:
        if args.mode == 'preflight':
            result = preflight(root)
        elif args.mode == 'prepare':
            result = prepare(root, args.gate.resolve())
        elif args.mode == 'verify':
            p = verify(root); result = {'status': 'verified', 'groups': p['groups'], 'repeats': p['repeats']}
        elif args.mode == 'pipeline':
            result = pipeline(root)
        elif args.mode == 'group-worker':
            result = group_worker(root, args.identifier)
        elif args.mode == 'plan-worker':
            task = read(args.result.parent / 'task.json')
            if args.identifier.split(':', 1)[1] != task['id']:
                raise ValueError('Worker task ID mismatch')
            result = perform_plan(root, task)
        else:
            result = evaluation(root, read(root / 'coordinator.json')['status'])
    except Exception as exc:
        if not args.result:
            raise
        result = {'status': 'worker_failed', 'error': str(exc), 'traceback': traceback.format_exc()}
    if args.result:
        save(args.result, result)
    else:
        print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()

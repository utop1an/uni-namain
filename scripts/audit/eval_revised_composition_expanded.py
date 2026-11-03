"""Exhaustive, fresh evaluation of the existing 70 supported composition fixtures.

No model calls, source repairs, new world construction, or outcome selection.
The previous 18-task diagnostic remains byte-preserved.
"""
import argparse
from collections import Counter, defaultdict
from pathlib import Path
import json
import shutil

from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.revised_followup import authored_problem
from rcnc.revised_sampling import rank
from scripts.audit import eval_revised_composition as original
from scripts.experiments import run_revised_multistory as base

SEED = 'composition-exhaustive-70-2026-11-03-v1'
WORLD_FIELDS = ('objects', 'facts', 'goal', 'intentions')


def world_key(scenario):
    """Keep the original study's exact-world deduplication, not isomorphism."""
    return json.dumps({k: scenario[k] for k in WORLD_FIELDS}, sort_keys=True)


def select_cases(census, groups):
    by_id = {g['id']: g for g in groups}
    cases = []
    for row in census['candidates']:
        if row['status'] != 'supported':
            continue
        gid = row['group']
        case_id = gid + '__candidate_' + row['rank'][:20]
        cases.append({**row, 'group': by_id[gid], 'case_id': case_id,
                      'world_id': original.value_digest(world_key(row['scenario']))})
    if len({c['case_id'] for c in cases}) != len(cases):
        raise ValueError('Duplicate candidate identity')
    cases.sort(key=lambda c: rank(SEED, c['case_id']))
    worlds = defaultdict(list)
    for case in cases:
        worlds[case['world_id']].append(case)
    registry = []
    for wid, members in sorted(worlds.items()):
        # Fixed before search; no best-of-outcomes selection for the 37-world table.
        representative = min(members, key=lambda c: (c['group']['size'],
                                                    rank(SEED, c['case_id'])))
        registry.append({'world_id': wid,
            'representative_case_id': representative['case_id'],
            'case_ids': [c['case_id'] for c in members],
            'input_group_sizes': sorted({c['group']['size'] for c in members})})
    return cases, registry


def prepare(previous, output):
    if output.exists():
        raise ValueError('Fresh output directory required')
    old = base.verify(previous)
    campaign = Path(old['parent_campaign'])
    main = base.verify(campaign)
    census = base.read(previous / 'census.json')
    groups = base.read(campaign / 'selected_groups.json')['groups']
    cases, registry = select_cases(census, groups)
    sizes = Counter(c['group']['size'] for c in cases)
    if (len(cases), len(registry), len({c['group']['id'] for c in cases})) != (70, 37, 35):
        raise ValueError('Changed expansion denominator')
    if sizes != Counter({2: 8, 3: 26, 4: 36}):
        raise ValueError('Changed size distribution')
    compilation = base.read(campaign / 'repeat_01/compilation.json')
    # This validates the archived parameterized domains, not just new fixtures.
    for path, expected in compilation['input_sha256'].items():
        if digest(Path(path)) != expected:
            raise ValueError('Parent compiled artifact changed: ' + path)
    output.mkdir(parents=True)
    registration = {'created_utc': base.now(), 'seed': SEED,
        'selection': 'Every supported descriptor in the pre-existing 300-group census; no search-result filtering or replacement.',
        'condition': 'fresh_expanded_composition_on_saved_interrupted_repeat01_domains',
        'parent_diagnostic': str(previous), 'parent_campaign': str(campaign),
        'budgets': {'max_tasks': 70, 'max_searches': 420, 'max_replays': 420,
            'seconds_per_call': 15, 'execution_seconds': 14400, 'workers': 1,
            'memory_mb': 4096, 'new_llm_calls': 0, 'retry_calls': 0},
        'conditions': original.CONDITIONS,
        'scope': 'Exhaustive within the old generator fragment and accepted interfaces. Posthoc development diagnostic, not an unseen-source or all-300-group success rate. Two-action producer-consumer fixtures, not three/four-source chains.',
        'worlds': 'Existing explicit schema-derived identities/types/initial facts/intentions/goals retained without source-problem fact pooling; no inferred initial states.',
        'world_deduplication': 'Exact JSON of objects, facts, goal, intentions, matching the previous paper analysis; source/object names remain significant. Distinct worlds are not independent samples.',
        'world_primary_selection': 'One fixed representative per world: smallest input-group size, then seeded hash of case ID. Other contexts are retained as secondary consistency diagnostics.',
        'failure_policy': 'Keep every timeout, no-plan return, runtime/validation/causal unknown, and uncovered group. No retries or replacements.',
        'prior_results_policy': 'All 420 searches are fresh. Old execution results are not reused or pooled as additional samples.',
        'authorization': 'User agreed to start the proposed 70-task, six-condition expansion in the current conversation.'}
    save(output / 'registration_before_export.json', registration)
    shutil.copy2(previous / 'census.json', output / 'census.json')
    for name in ('preservation_snapshot.json', 'parent_compilation.json',
                 'parent_consensus_audit.json', 'parent_judgments_report.json'):
        shutil.copy2(previous / name, output / name)
    save(output / 'selected_cases.json', {'cases': cases})
    save(output / 'world_registry.json', {'worlds': registry})
    sources = base.load_sources(main)
    folders = {}
    model_receipts = []
    for gid in sorted({c['group']['id'] for c in cases}):
        for condition in base.CONDITIONS:
            src = campaign / 'repeat_01/models' / gid / condition
            dst = output / 'models' / gid / condition
            dst.mkdir(parents=True)
            for name in ('domain.pddl', 'mapping.json'):
                shutil.copy2(src / name, dst / name)
                if digest(src / name) != digest(dst / name):
                    raise ValueError('Copied model differs')
                model_receipts.append({'parent': str(src / name),
                    'copy': str(dst / name), 'sha256': digest(dst / name)})
            folders[gid, condition] = dst
    save(output / 'model_copy_receipts.json', {'files': model_receipts})
    tasks = []
    for case in cases:
        group = case['group']; gid = group['id']; cid = case['case_id']
        selected_sources = [sources[sid] for sid in group['sources']]
        for condition in original.CONDITIONS:
            folder = folders[gid, condition if condition in base.CONDITIONS else 'full']
            active = set(group['sources'])
            if condition == 'without_producer':
                active.remove(case['candidate']['producer'])
            if condition == 'without_consumer':
                active.remove(case['candidate']['consumer'])
            problem = output / 'problems' / cid / (condition + '.pddl')
            problem.parent.mkdir(parents=True, exist_ok=True)
            receipt = authored_problem(selected_sources, base.read(folder / 'mapping.json'),
                case['scenario'], problem, active_sources=active,
                separate_identity=condition == 'separate_identity')
            if receipt['source_problem_facts_copied'] != 0:
                raise ValueError('Source initial facts were pooled')
            tasks.append({'id': cid + '__' + condition, 'case_id': cid,
                'group': gid, 'size': group['size'], 'world_id': case['world_id'],
                'condition': condition, 'domain': str(folder / 'domain.pddl'),
                'problem': str(problem), 'mapping': str(folder / 'mapping.json'),
                'world_receipt': receipt})
    tasks.sort(key=lambda t: (rank(SEED, t['case_id']), rank(SEED, t['case_id'], t['condition'])))
    if len(tasks) != 420 or len({t['id'] for t in tasks}) != 420:
        raise ValueError('Search denominator mismatch')
    save(output / 'tasks.json', {'tasks': tasks})
    shutil.copytree(previous / 'runtime', output / 'runtime')
    dependencies = {str(p) for p in [Path(__file__), Path(original.__file__),
        Path('rcnc/composition_probes.py'), Path('rcnc/revised_followup.py'),
        Path('tests/test_revised_composition_expanded.py'), *base.IMPLEMENTATION]}
    # Normalize paths before snapshotting; original.__file__ is absolute.
    paths = sorted({Path(p).resolve() for p in dependencies}, key=str)
    implementation = snapshot_implementation(output, paths)
    inputs = {str(p): digest(p) for p in output.rglob('*') if p.is_file()}
    protocol = {**registration, 'frozen_utc': base.now(),
        'status': 'frozen_before_composition_search', 'task_count': 70,
        'distinct_worlds': 37, 'groups': 35, 'search_slots': 420,
        'by_size': dict(sizes), 'runtime_jar': str(output / 'runtime/glaive-corrected.jar'),
        'runtime_classes': str(output / 'runtime/classes'),
        'repeat_condition': registration['condition'],
        'input_sha256': inputs, 'implementation_sha256': implementation}
    save(output / 'protocol.json', protocol)
    (output / 'PROTOCOL.sha256').write_text(digest(output / 'protocol.json') + '  protocol.json\n', encoding='utf-8')
    return {'status': protocol['status'], 'tasks': 70, 'worlds': 37,
            'groups': 35, 'search_slots': 420, 'new_llm_calls': 0,
            'protocol_sha256': digest(output / 'protocol.json')}


def counts(rows):
    return {'registered': len(rows), 'valid': sum(r['valid_plan'] for r in rows),
        'cross_source': sum(r['causal']['status'] == 'cross_source_composition' for r in rows),
        'search_status': dict(Counter(r['search']['status'] for r in rows)),
        'causal_status': dict(Counter(r['causal']['status'] for r in rows))}


def summarize(root):
    protocol = base.verify(root)
    report = base.read(root / 'report.json')
    registry = base.read(root / 'world_registry.json')['worlds']
    representatives = {w['representative_case_id'] for w in registry}
    rows = report['rows']
    if len(rows) != 420 or report['calls'].get('search') != 420:
        raise ValueError('Incomplete expanded search matrix')
    results = {'status': 'complete_expanded_composition_diagnostic',
        'created_utc': base.now(), 'protocol_sha256': digest(root / 'protocol.json'),
        'tasks': 70, 'worlds': 37, 'groups': 35,
        'all_tasks': {c: counts([r for r in rows if r['condition'] == c]) for c in original.CONDITIONS},
        'fixed_world_representatives': {c: counts([r for r in rows if r['condition'] == c and r['case_id'] in representatives]) for c in original.CONDITIONS},
        'by_size': report['by_size_condition'],
        'calls': report['calls'], 'elapsed_seconds': report['elapsed_seconds'],
        'inputs_unchanged': report['input_hashes_unchanged'],
        'new_llm_calls': 0, 'independent_semantic_labels': 0,
        'scope': protocol['scope'],
        'historical_preservation': 'Copied original-world preservation snapshot is historical and separate; no new Native plan searches or preservation claims.',
        'known_semantic_risk': 'The existing lightbox/bike identity concern is retained. Formal validation does not establish semantic plausibility or narrative quality.',
        'plan_lengths': dict(Counter(len(r['causal'].get('steps', [])) for r in rows if r['condition'] == 'full' and r['causal']['status'] == 'cross_source_composition')),
        'goal_relevant_source_counts': dict(Counter(r['causal'].get('goal_relevant_source_count') for r in rows if r['condition'] == 'full' and r['causal']['status'] == 'cross_source_composition'))}
    save(root / 'expanded_summary.json', results)
    return results


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=('prepare', 'execute', 'summarize'))
    parser.add_argument('--previous', type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    if args.mode == 'prepare':
        result = prepare(args.previous, args.output)
    elif args.mode == 'execute':
        original.execute(args.output)
        result = summarize(args.output)
    else:
        result = summarize(args.output)
    print(json.dumps(result, ensure_ascii=False, indent=2))

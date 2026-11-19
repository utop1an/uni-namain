"""One fresh There and Back Again k=2/3/4 campaign, ranked by causal opportunity."""
import argparse
from collections import Counter
from itertools import combinations
import json
import os
from pathlib import Path
import shutil
import time
import traceback

from rcnc import model_semantics, model_semantics_parallel
from rcnc.causal_domain_selection import census_pairs, select_top_groups, SCORE_FIELDS, group_score
from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.glaive_merge import Source
from rcnc.glaive_runtime import invoke
from rcnc.model_semantics_contract import include_output_contract
from rcnc.parallel_progress_io import durable_progress
from rcnc.revised_followup import authored_problem
from scripts.audit import eval_revised_composition as composition
from scripts.data.freeze_revised_multistory import verify_frozen
from scripts.evidence.build_paper_results import build as build_inventory
from scripts.experiments import run_revised_multistory as base


EXTRA_IMPLEMENTATION = [Path(__file__), Path('rcnc/causal_domain_selection.py'),
    Path('rcnc/model_semantics_parallel.py'), Path('rcnc/parallel_progress_io.py'),
    Path('rcnc/composition_probes.py'), Path('rcnc/revised_followup.py'),
    Path('scripts/experiments/continue_revised_multistory.py'),
    Path('scripts/audit/eval_revised_composition.py'),
    Path('scripts/evidence/build_paper_results.py'), Path('tests/test_causal_domain_selection.py')]


def prepare(root, gate, *, groups_per_size=100, workers=8):
    root = root.resolve()
    if root.exists():
        raise ValueError('Fresh campaign directory required')
    if not 1 <= workers <= 10:
        raise ValueError('Invalid bounded worker count')
    dataset_audit = verify_frozen(base.DATA)
    gate_report = base.read(gate / 'report.json')
    if gate_report['status'] != 'passed' or gate_report['passed'] != 14:
        raise ValueError('Current multistory preflight failed')
    for name, h in base.read(gate / 'protocol.json')['implementation_sha256'].items():
        if digest(Path(name)) != h:
            raise ValueError('Preflight implementation changed: ' + name)
    rows = [r for r in base.read(base.DATA / 'cohort.json')['sources'] if r['included']]
    sources = {r['id']: Source(r['id'],
        base.DATA / r['files']['revised-domain.pddl']['frozen_path'],
        base.DATA / r['files']['revised-problem.pddl']['frozen_path']) for r in rows}
    print('Scoring source-only interfaces across', len(sources), 'sources', flush=True)
    pairs, exclusions = census_pairs(sources)
    groups, coverage = select_top_groups(sources, pairs, groups_per_size=groups_per_size)
    used_pairs = {tuple(sorted(p)) for g in groups for p in combinations(g['sources'], 2)}
    candidates = [c for pair in pairs if tuple(pair['sources']) in used_pairs for c in pair['candidates']]
    candidates.sort(key=lambda c: (c['source_pair'], c['kind'], c['references']))
    selected_ids = {sid for g in groups for sid in g['sources']}
    selected_rows = [r for r in rows if r['id'] in selected_ids]
    root.mkdir(parents=True)
    (root / 'inputs').mkdir()
    (root / 'runtime/classes').mkdir(parents=True)
    for row in selected_rows:
        # Absolute paths also make base.load_sources independent of its legacy DATA constant.
        for name in ('revised-domain.pddl', 'revised-problem.pddl'):
            original = base.DATA / row['files'][name]['frozen_path']
            suffix = '_domainfile.pddl' if name == 'revised-domain.pddl' else '_problem.pddl'
            target = root / 'inputs' / (row['id'] + suffix)
            shutil.copyfile(original, target)
            row['files'][name] = {**row['files'][name], 'frozen_path': str(target), 'original': str(original)}
    runtime = base.read(base.RUNTIME / 'report.json')
    if runtime['status'] != 'verified' or digest(Path(runtime['jar'])) != runtime['jar_sha256']:
        raise ValueError('Runtime hash mismatch')
    shutil.copyfile(runtime['jar'], root / 'runtime/glaive-corrected.jar')
    shutil.copyfile('.tmp/glaive_classes_v1/GlaiveProbe.class', root / 'runtime/classes/GlaiveProbe.class')
    save(root / 'dataset_audit.json', dataset_audit)
    save(root / 'pair_census.json', {'pairs': pairs, 'excluded_scoring_actions': exclusions})
    save(root / 'selected_groups.json', {'groups': groups})
    save(root / 'selected_candidates.json', {'candidates': candidates})
    pair_index = {tuple(p['sources']): p for p in pairs}
    old_groups = [g for g in base.read(base.DATA / 'groups.json')['groups'] if g['size'] in (2, 3, 4)]
    selection = {'status': 'verified_source_only_selection', 'groups': len(groups),
        'rows': groups, 'coverage': coverage, 'source_pool': len(sources), 'source_pairs': len(pairs),
        'selected_sources': len(selected_ids), 'selected_source_pairs': len(used_pairs),
        'candidates': len(candidates), 'repeats': 1, 'random_sampling': False,
        'selection_order': list(SCORE_FIELDS), 'model_calls': 0, 'planner_calls': 0,
        'historical_groups_rescored_without_outcomes': [{'id': g['id'], 'size': g['size'],
            'score': dict(zip(SCORE_FIELDS, group_score(g['sources'], pair_index)))} for g in old_groups],
        'limits': ['Positive STRIPS variable-only fragment; arity at most six for role-permutation retrieval.',
            'Requires lexical overlap and potentially compatible type names; differently named synonyms can be missed.',
            'Source graph connectivity is potential only; different actions in an intermediate domain need not form a reachable chain.',
            'Selection is targeted and correlated, not a random-population success estimate or independent semantic labels.']}
    save(root / 'selection_report.json', selection)
    stage = root / 'repeat_01/judgments'
    model_semantics.prepare(root / 'inputs', candidates, stage, model=base.MODEL,
        model_digest=base.MODEL_DIGEST, total_seconds=144000, request_seconds=240,
        schema_policy='compact_kind_specific', num_predict=16384, num_ctx=32768)
    include_output_contract(stage)
    requests, manifest = base.read(stage / 'requests.json'), base.read(stage / 'manifest.json')
    for request in requests.values():
        request['options']['seed'] = 2026110401
    manifest['options']['seed'] = 2026110401
    manifest.update(workers=workers, repeat_id='repeat_01',
        seed_note='Single requested seed; provider enforcement unverified. No repeated trials or best-run selection.')
    save(stage / 'requests.json', requests)
    manifest['requests_sha256'] = digest(stage / 'requests.json')
    added = snapshot_implementation(root, [*base.IMPLEMENTATION, *EXTRA_IMPLEMENTATION])
    manifest['implementation_sha256'].update(added)
    save(stage / 'manifest.json', manifest)
    inputs = {str(p): digest(p) for p in root.rglob('*') if p.is_file()}
    inputs.update({str(base.DATA / rel): h for rel, h in base.read(base.DATA / 'freeze.json')['artifact_sha256'].items()})
    inputs[str(gate / 'report.json')] = digest(gate / 'report.json')
    protocol = {'status': 'frozen_before_single_round_calls', 'created_utc': base.now(),
        'dataset': str(base.DATA), 'dataset_freeze_sha256': dataset_audit['freeze_sha256'],
        'condition': 'fresh_single_round_causal_opportunity_selection',
        'selected_sizes': [2, 3, 4], 'groups_per_size': groups_per_size, 'groups': len(groups),
        'sources': len(selected_rows), 'source_pool': len(sources), 'source_rows': selected_rows,
        'repeats': [{'id': 'repeat_01', 'path': str(root / 'repeat_01'), 'seed': 2026110401}],
        'conditions': ['native', *base.CONDITIONS], 'model': base.MODEL, 'model_digest': base.MODEL_DIGEST,
        'runtime_jar': str(root / 'runtime/glaive-corrected.jar'), 'runtime_classes': str(root / 'runtime/classes'),
        'confidence_threshold': .9, 'random_sampling': False,
        'selection': {'rank_fields_descending': list(SCORE_FIELDS), 'tie_break': 'source IDs ascending',
            'universe': 'All unordered k=2/3/4 combinations in the unchanged 60-source admitted pool',
            'candidate_caps_per_source_pair': {'predicate': 8, 'action': 4},
            'predicate_retrieval': 'Causal opportunity first, distinct directed action pairs, lexical score, canonical references',
            'anchor_selection': 'Highest-scoring pair within each group, then source IDs'},
        'budgets': {'model_total_requests': len(candidates), 'model_seconds': 144000,
            'model_request_seconds': 240, 'model_workers': workers, 'attempts_per_request_or_search': 1,
            'search_seconds': 15, 'replay_seconds': 15, 'planner_memory_mb': 4096, 'planner_workers': 1,
            'native_searches': len(selected_rows), 'merged_searches': len(groups) * 6,
            'transport_slots': sum(g['size'] * 3 for g in groups),
            'composition_cases_per_group': 1, 'composition_search_slots_max': len(groups) * 6,
            'composition_execution_seconds': len(groups) * 6 * 30},
        'composition_policy': 'Census all selected groups after fixed semantic decisions. First supported descriptor in canonical producer/consumer/action/literal order per group; six controls. No random selection, outcome-based replacement or source-problem fact pooling. Explicit schema-derived worlds frozen before composition search. This tests pairwise handoffs, not all-k participation.',
        'policy': ['Exactly one fresh semantic round. No old judgments, resampling, model retries or cache continuation.',
            'Complete-link semantic agreement at .9 plus unchanged role/effect/agent checks; causal scores never authorize merging.',
            'Build and hash all parameterized union/predicate-only/full models before main search.',
            'Original source initial states and goals remain separate. All failures, unavailable plans and resource limits retained.',
            'A transport failure stops dispatch; undelivered requests remain explicit. No automatic reruns.',
            'Targeted development sample; no population generalization, independent semantics or narrative-quality claim.'],
        'input_sha256': inputs, 'implementation_sha256': added}
    save(root / 'protocol.json', protocol)
    (root / 'PROTOCOL.sha256').write_text(digest(root / 'protocol.json') + '  protocol.json\n', encoding='utf-8')
    return {k: selection[k] for k in ('status', 'groups', 'selected_sources', 'selected_source_pairs', 'candidates', 'repeats')}


def descriptor_order(record):
    c = record['candidate']
    return tuple(c[k] for k in ('producer', 'consumer', 'producer_action', 'consumer_action',
        'producer_literal_index', 'consumer_literal_index', 'goal_effect_index', 'group'))


def prepare_composition(root):
    p = base.verify(root)
    repeat, output = root / 'repeat_01', root / 'composition'
    if output.exists():
        raise ValueError('Fresh composition output required')
    compilation = base.read(repeat / 'compilation.json')
    for path, h in compilation['input_sha256'].items():
        if digest(Path(path)) != h:
            raise ValueError('Compiled model changed')
    output.mkdir()
    sources = base.load_sources(p)
    profiles, excluded = composition.profiles_for(sources)
    consensuses = {r['group']: r['consensus_groups'] for r in base.read(repeat / 'consensus_audit.json')['rows']}
    census, cases, tasks = [], [], []
    for group in base.read(root / 'selected_groups.json')['groups']:
        records = composition.group_candidates(group, consensuses[group['id']], sources, profiles)
        eligible = sorted((r for r in records if r['status'] == 'supported'), key=descriptor_order)
        census.append({'id': group['id'], 'size': group['size'], 'candidates': len(records),
            'supported': len(eligible), 'status': 'selected' if eligible else 'no_supported_probe',
            'excluded_reasons': dict(Counter(r['reason'] for r in records if r['status'] == 'excluded'))})
        if not eligible:
            continue
        case = {'group': group, **eligible[0]}
        cases.append(case)
        chosen = [sources[s] for s in group['sources']]
        for condition in composition.CONDITIONS:
            folder = repeat / 'models' / group['id'] / (condition if condition in base.CONDITIONS else 'full')
            active = set(group['sources'])
            if condition == 'without_producer':
                active.remove(case['candidate']['producer'])
            if condition == 'without_consumer':
                active.remove(case['candidate']['consumer'])
            problem = output / 'problems' / group['id'] / (condition + '.pddl')
            problem.parent.mkdir(parents=True, exist_ok=True)
            receipt = authored_problem(chosen, base.read(folder / 'mapping.json'), case['scenario'], problem,
                active_sources=active, separate_identity=condition == 'separate_identity')
            if receipt['source_problem_facts_copied'] != 0:
                raise ValueError('Source initial facts pooled')
            tasks.append({'id': group['id'] + '__' + condition, 'group': group['id'], 'size': group['size'],
                'condition': condition, 'domain': str(folder / 'domain.pddl'), 'problem': str(problem),
                'mapping': str(folder / 'mapping.json'), 'world_receipt': receipt})
    save(output / 'census.json', {'groups': census, 'excluded_profiles': excluded})
    save(output / 'selected_cases.json', {'cases': cases})
    save(output / 'tasks.json', {'tasks': tasks})
    protocol = {'status': 'frozen_before_composition_search', 'created_utc': base.now(),
        'parent_protocol_sha256': digest(root / 'protocol.json'), 'groups_censused': len(census),
        'cases': len(cases), 'search_slots': len(tasks), 'conditions': composition.CONDITIONS,
        'policy': p['composition_policy'], 'execution_seconds': p['budgets']['composition_execution_seconds'],
        'input_sha256': {**compilation['input_sha256'],
            **{str(f): digest(f) for f in output.rglob('*') if f.is_file()}}}
    save(output / 'protocol.json', protocol)
    (output / 'PROTOCOL.sha256').write_text(digest(output / 'protocol.json'), encoding='utf-8')
    return protocol


def execute_composition(root):
    main = base.verify(root)
    output = root / 'composition'
    p = base.read(output / 'protocol.json')
    if digest(output / 'protocol.json') != (output / 'PROTOCOL.sha256').read_text(encoding='utf-8'):
        raise ValueError('Changed composition protocol')
    if (output / 'execution_progress.json').exists():
        raise ValueError('Fresh composition execution required')
    for path, h in p['input_sha256'].items():
        if digest(Path(path)) != h:
            raise ValueError('Changed composition input')
    tasks = base.read(output / 'tasks.json')['tasks']
    start, rows = time.monotonic(), []
    jar, classes = Path(main['runtime_jar']), Path(main['runtime_classes'])
    for task in tasks:
        row = dict(task)
        folder = output / 'execution' / task['id']
        domain, problem = Path(task['domain']), Path(task['problem'])
        remaining = p['execution_seconds'] - (time.monotonic() - start)
        if remaining < 1:
            row['search'] = {'status': 'not_run_total_budget', 'search_calls': 0}
        else:
            row['search'] = invoke(jar, domain, problem, folder / 'search', seconds=min(15, max(1, int(remaining))))
        row['valid_plan'] = False
        row['causal'] = {'status': 'unavailable_valid_plan'}
        if row['search']['status'] == 'solved':
            plan = folder / 'search/plan.pddl'
            row['replay'] = base.replay_checked(jar, classes, domain, problem, plan, folder / 'replay')
            row['valid_plan'] = base.valid(row['replay'])
            if row['valid_plan']:
                row['causal'] = composition.causal_trace(domain, problem, plan, base.read(Path(task['mapping'])))
        rows.append(row)
        with (output / 'execution_events.jsonl').open('a', encoding='utf-8') as stream:
            stream.write(json.dumps(row) + '\n')
        durable_progress(output / 'execution_progress.json', {'completed': len(rows), 'registered': len(tasks),
            'elapsed_seconds': time.monotonic() - start})
    census = base.read(output / 'census.json')['groups']
    report = {'status': 'complete_registered_composition_diagnostic', 'rows': rows,
        'groups_censused': len(census), 'cases': p['cases'], 'registered_rows': len(tasks),
        'no_supported_probe': sum(r['status'] == 'no_supported_probe' for r in census),
        'search_calls': sum(r['search'].get('search_calls', 0) for r in rows),
        'by_size_condition': {str(k): {c: {'registered': sum(r['size'] == k and r['condition'] == c for r in rows),
            'search_status': dict(Counter(r['search']['status'] for r in rows if r['size'] == k and r['condition'] == c)),
            'valid': sum(r['valid_plan'] for r in rows if r['size'] == k and r['condition'] == c),
            'causal_status': dict(Counter(r['causal']['status'] for r in rows if r['size'] == k and r['condition'] == c))}
            for c in composition.CONDITIONS} for k in (2, 3, 4)},
        'inputs_unchanged': all(digest(Path(path)) == h for path, h in p['input_sha256'].items()),
        'scope': main['composition_policy'], 'independent_semantic_labels': 0}
    save(output / 'report.json', report)
    return {k: v for k, v in report.items() if k != 'rows'}


def evidence_inventory(root):
    reports = {}
    for label, relative, metrics, denominator, checks in [
        ('selection', 'selection_report.json', ['groups', 'coverage', 'candidates', 'random_sampling', 'repeats'], 'groups', []),
        ('judgments', 'repeat_01/judgments/report.json', ['candidate_count', 'requests_attempted', 'status_counts'], 'candidate_count', ['inputs_unchanged', 'implementation_unchanged']),
        ('original_worlds', 'repeat_01/report.json', ['sources', 'groups', 'search_calls', 'by_size_condition', 'gate_violations', 'invalid_returned_plans'], 'source_query_slots', ['inputs_unchanged']),
        ('composition', 'composition/report.json', ['groups_censused', 'cases', 'no_supported_probe', 'by_size_condition'], 'registered_rows', ['inputs_unchanged'])]:
        path = root / relative
        if not path.exists():
            continue
        report = base.read(path)
        reports[label] = {'path': str(path), 'sha256': digest(path), 'terminal_status': report['status'],
            'scope': 'Single targeted development round; heterogeneous units kept separate.',
            'metrics': metrics, 'denominator': denominator, 'row_id': 'id', 'required_true': checks}
    index = root / 'result_sources.json'
    save(index, {'reports': reports, 'excluded_pending': [label for label in
        ('selection', 'judgments', 'original_worlds', 'composition') if label not in reports]})
    return build_inventory(index, root / 'verified_results')['status']


def pipeline(root):
    root = root.resolve()
    p = base.verify(root)
    if len(p['repeats']) != 1:
        raise ValueError('Exactly one round required')
    path, repeat = root / 'coordinator.json', root / 'repeat_01'
    if path.exists():
        raise ValueError('Fresh pipeline required; no implicit continuation')
    state = {'status': 'running', 'stage': 'judgments', 'started_utc': base.now(), 'pid': os.getpid(),
        'registered_repeats': 1, 'completed_repeats': 0, 'protocol_sha256': digest(root / 'protocol.json')}
    durable_progress(path, state)
    previous_writer = model_semantics_parallel.atomic_save
    try:
        model_semantics_parallel.atomic_save = durable_progress
        judgments = model_semantics_parallel.run(repeat / 'judgments')
        if judgments['execution_status'] != 'complete':
            state.update(status='stopped_model_stage_incomplete', reason=judgments['stop_reason'])
        else:
            state['stage'] = 'compilation'; durable_progress(path, state)
            state['compilation'] = base.compile_models(root, repeat)
            state['stage'] = 'original_world_execution'; durable_progress(path, state)
            summary = base.execute(root, repeat, state, path)
            state['original_worlds'] = summary
            state['completed_repeats'] = 1
            if summary['gate_violations'] or summary['invalid_returned_plans']:
                state['status'] = 'stopped_validation_gate'
            else:
                state['stage'] = 'composition_preparation'; durable_progress(path, state)
                prepare_composition(root)
                state['stage'] = 'composition_execution'; durable_progress(path, state)
                state['composition'] = execute_composition(root)
                state.update(status='complete', stage='complete')
        state['evidence_inventory'] = evidence_inventory(root)
        save(root / 'report.json', state)
    except Exception as exc:
        state.update(status='failed', error=str(exc), traceback=traceback.format_exc())
        raise
    finally:
        model_semantics_parallel.atomic_save = previous_writer
        state['ended_utc'] = base.now()
        durable_progress(path, state)
    return state


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=('preflight', 'prepare', 'verify', 'pipeline'))
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--gate', type=Path)
    parser.add_argument('--groups-per-size', type=int, default=100)
    parser.add_argument('--workers', type=int, default=8)
    args = parser.parse_args()
    if args.mode == 'preflight':
        result = base.preflight(args.output)
    elif args.mode == 'prepare':
        result = prepare(args.output, args.gate, groups_per_size=args.groups_per_size, workers=args.workers)
    elif args.mode == 'verify':
        p = base.verify(args.output)
        result = {'status': 'verified', 'groups': p['groups'], 'repeats': len(p['repeats']), 'random_sampling': p['random_sampling']}
    else:
        result = pipeline(args.output)
    print(json.dumps(result, ensure_ascii=False, indent=2))

"""Posthoc composition evaluation of frozen, completed model artifacts.

Worlds are explicit schema-derived diagnostic fixtures. They are not pooled
source stories, inferred worlds for a user goal, or independent semantic gold.
The original parameterized merged domains are copied byte for byte.
"""
import argparse
from collections import Counter
from itertools import permutations, product
from pathlib import Path
import json
import shutil
import time

from rcnc.composition_probes import construct, digest as value_digest, literals
from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.glaive_merge import action_fields
from rcnc.glaive_runtime import invoke
from rcnc.pddl import parse_sexpr, section, typed_symbols
from rcnc.revised_followup import authored_problem
from rcnc.revised_probe_validation import changes, ground, holds
from rcnc.revised_sampling import rank
from scripts.experiments import run_revised_multistory as base

SEED = 'composition-interim-2026-11-02-v1'
CONDITIONS = ('union', 'predicate_only', 'full', 'without_producer',
              'without_consumer', 'separate_identity')


def profiles_for(sources):
    profiles, exclusions = {}, []
    for sid, source in sources.items():
        profiles[sid] = {}
        for name, action in source.domain.actions.items():
            try:
                f = action_fields(action)
                pre, eff = literals(f[':precondition']), literals(f[':effect'])
                # Keep constants outside this small explicit-identity fixture
                # generator; do not silently identify constants across stories.
                if any(not t.startswith('?') for _, atom in pre + eff for t in atom[1:]):
                    raise ValueError('constant_binding_outside_fixture_scope')
                if any(not x.startswith('?') for x in f[':agents']):
                    raise ValueError('constant_actor_outside_fixture_scope')
                profiles[sid][name] = {'parameters': typed_symbols(f[':parameters']),
                    'preconditions': pre, 'effects': eff, 'agents': f[':agents']}
            except ValueError as exc:
                exclusions.append({'source': sid, 'action': name, 'reason': str(exc)})
    return profiles, exclusions


def group_candidates(group, consensus, sources, profiles):
    predicates = [g for g in consensus if 'predicate' in g['members'][0]]
    specification = {'predicate_groups': predicates}
    domains = {s: sources[s].domain for s in group['sources']}
    records = []
    for interface in predicates:
        members = {m['predicate'].split(':')[0]: m for m in interface['members']}
        for a, b in permutations(sorted(members), 2):
            pa, pb = (members[s]['predicate'].split(':')[1] for s in (a, b))
            for an, bn in product(sorted(profiles[a]), sorted(profiles[b])):
                ap, bp = profiles[a][an], profiles[b][bn]
                ai = [i for i, (sign, atom) in enumerate(ap['effects']) if sign and atom[0] == pa]
                bi = [i for i, (sign, atom) in enumerate(bp['preconditions']) if sign and atom[0] == pb]
                gi = [i for i, (sign, atom) in enumerate(bp['effects']) if sign and atom[0] != pb]
                for i, j, k in product(ai, bi, gi):
                    descriptor = {'seed': SEED, 'group': interface['id'], 'producer': a,
                        'consumer': b, 'producer_action': an, 'consumer_action': bn,
                        'producer_literal_index': i, 'consumer_literal_index': j, 'goal_effect_index': k}
                    row = {'candidate': descriptor, 'rank': value_digest(descriptor)}
                    try:
                        query, provenance = construct(descriptor, domains, profiles, specification, members)
                        objects = {obj: dict(t.split(':', 1) for t in types) for obj, types in query['objects'].items()}
                        def qualified(atom):
                            sid, symbol = atom[0].split(':', 1)
                            return [sid, [symbol, *atom[1:]]]
                        goals = [qualified(x) for x in query['goal']['positive']]
                        actors = sorted({provenance['bindings'][role][v]
                            for role, data in [('producer', ap), ('consumer', bp)] for v in data['agents']})
                        scenario = {'id': group['id'] + '_composition', 'sources': group['sources'],
                            'objects': objects, 'facts': [qualified(x) for x in query['initial']],
                            'goal': goals, 'intentions': [[actor, sid, goal] for actor in actors for sid, goal in goals],
                            'construction': provenance, 'source_problem_facts_copied': 0,
                            'world_kind': 'explicit_schema_derived_diagnostic_fixture'}
                        row.update(status='supported', scenario=scenario)
                    except ValueError as exc:
                        row.update(status='excluded', reason=str(exc))
                    records.append(row)
    return sorted(records, key=lambda r: r['rank'])


def causal_trace(domain, problem, plan, mapping):
    """Conservative positive-fact causal slice, after independent replay.

    Ambiguous fused provenance is unknown, never counted as multiple sources.
    Redundant re-addition of an already true fact is not a causal producer.
    """
    d = parse_sexpr(Path(domain).read_text(encoding='utf-8'))
    p = parse_sexpr(Path(problem).read_text(encoding='utf-8'))
    q = parse_sexpr(Path(plan).read_text(encoding='utf-8'))
    actions = {a[1]: a for a in d if isinstance(a, list) and a and a[0] == ':action'}
    reverse = {}
    for ref, value in mapping['action_maps'].items():
        reverse.setdefault(value['name'], set()).add(ref.split(':')[0])
    state = {tuple(x) for x in section(p, ':init')[1:] if x[0] != 'intends'}
    if any(x[0] == 'not' for x in state):
        return {'status': 'unknown', 'reason': 'explicit_negative_initial_outside_trace_fragment'}
    owners, edges, steps = {}, [], []
    try:
        for index, call in enumerate(section(q, ':steps')[1:]):
            if call[0] == 'non-executed': raise ValueError('counterfactual_step')
            origins = reverse[call[0]]
            if len(origins) != 1: raise ValueError('ambiguous_fused_source_attribution')
            source = next(iter(origins))
            f = action_fields(actions[call[0]])
            binding = dict(zip(typed_symbols(f[':parameters']), call[1:]))
            pre = ground(f[':precondition'], binding)
            if not holds(pre, state): raise ValueError('inapplicable_trace')
            for sign, atom in literals(pre):
                fact = tuple(atom)
                if sign and fact in owners:
                    edges.append({'from': owners[fact], 'to': index, 'fact': list(fact)})
            add, delete = changes(ground(f[':effect'], binding), state)
            for fact in delete: owners.pop(fact, None)
            for fact in add - state: owners[fact] = index
            state = (state - delete) | add
            steps.append({'index': index, 'source': source, 'call': call})
        goal = section(p, ':goal')[1]
        if not holds(goal, state): raise ValueError('goal_not_reached')
        goals = literals(goal)
        if any(not sign for sign, _ in goals): raise ValueError('negative_goal_outside_causal_slice')
        relevant = {owners[tuple(atom)] for _, atom in goals if tuple(atom) in owners}
        while True:
            expanded = relevant | {e['from'] for e in edges if e['to'] in relevant}
            if expanded == relevant: break
            relevant = expanded
        causal = [e for e in edges if e['to'] in relevant]
        cross = [e for e in causal if e['fact'][0].startswith('shared_')
                 and steps[e['from']]['source'] != steps[e['to']]['source']]
        return {'status': 'cross_source_composition' if cross else 'no_goal_relevant_cross_source_link',
            'steps': steps, 'causal_edges': causal, 'cross_source_edges': cross,
            'actual_source_count': len({s['source'] for s in steps}),
            'goal_relevant_source_count': len({steps[i]['source'] for i in relevant})}
    except (KeyError, ValueError) as exc:
        return {'status': 'unknown', 'reason': str(exc)}


def prepare(campaign, output):
    if output.exists(): raise ValueError('Fresh evaluation directory required')
    main = base.verify(campaign)
    repeat = campaign / 'repeat_01'
    judgments = base.read(repeat / 'judgments/report.json')
    if judgments['status'] != 'complete': raise ValueError('Requires a complete frozen judgment stage')
    compilation = base.read(repeat / 'compilation.json')
    for path, h in compilation['input_sha256'].items():
        if digest(Path(path)) != h: raise ValueError('Changed compiled model')
    output.mkdir(parents=True)
    registration = {'created_utc': base.now(), 'seed': SEED,
        'selection': 'All 300 groups censused; first supported descriptor by hash per group; first six generated groups by fixed hash within each size. No search or replay outcome selection.',
        'budgets': {'groups_per_size_cap': 6, 'max_tasks': 18, 'max_searches': 108,
                    'seconds_per_call': 15, 'execution_seconds': 900, 'workers': 1, 'new_llm_calls': 0},
        'scope': 'Posthoc diagnostic conditional on accepted interfaces; not a random-test success estimate or semantic/narrative validation. Pairwise handoff within 2/3/4-source merged domains; do not claim all k sources participate.',
        'worlds': 'Explicit schema-derived fixtures; zero original problem facts copied or pooled. Identities/types/intentions/facts/goals frozen before planning.',
        'conditions': CONDITIONS}
    save(output / 'registration_before_generation.json', registration)
    sources = base.load_sources(main)
    profiles, excluded = profiles_for(sources)
    groups = base.read(campaign / 'selected_groups.json')['groups']
    consensus = {r['group']: r for r in base.read(repeat / 'consensus_audit.json')['rows']}
    census, candidates, generated = [], [], []
    for group in groups:
        records = group_candidates(group, consensus[group['id']]['consensus_groups'], sources, profiles)
        eligible = [r for r in records if r['status'] == 'supported']
        candidates.extend({'group': group['id'], **r} for r in records)
        row = {'group': group['id'], 'size': group['size'], 'candidate_count': len(records),
            'supported_count': len(eligible), 'status': 'generated' if eligible else 'no_supported_probe',
            'selected_for_execution': False}
        census.append(row)
        if eligible: generated.append({'group': group, **eligible[0]})
    selected = [g for k in (2, 3, 4) for g in sorted((g for g in generated if g['group']['size'] == k),
                key=lambda g: rank(SEED, g['group']['id']))[:6]]
    ids = {g['group']['id'] for g in selected}
    for row in census: row['selected_for_execution'] = row['group'] in ids
    save(output / 'census.json', {'groups': census, 'candidates': candidates, 'unsupported_profiles': excluded})
    save(output / 'selected_cases.json', {'cases': selected})
    tasks = []
    for case in selected:
        g = case['group']; selected_sources = [sources[s] for s in g['sources']]
        folders = {}
        for condition in base.CONDITIONS:
            src = repeat / 'models' / g['id'] / condition
            dst = output / 'models' / g['id'] / condition
            dst.mkdir(parents=True)
            for filename in ('domain.pddl', 'mapping.json'): shutil.copy2(src / filename, dst / filename)
            folders[condition] = dst
        for condition in CONDITIONS:
            base_condition = condition if condition in base.CONDITIONS else 'full'
            folder = folders[base_condition]
            active = set(g['sources'])
            if condition == 'without_producer': active.remove(case['candidate']['producer'])
            if condition == 'without_consumer': active.remove(case['candidate']['consumer'])
            problem = output / 'problems' / g['id'] / (condition + '.pddl')
            receipt = authored_problem(selected_sources, base.read(folder / 'mapping.json'),
                case['scenario'], problem, active_sources=active, separate_identity=condition == 'separate_identity')
            tasks.append({'id': g['id'] + '__' + condition, 'group': g['id'], 'size': g['size'],
                'condition': condition, 'domain': str(folder / 'domain.pddl'), 'problem': str(problem),
                'mapping': str(folder / 'mapping.json'), 'world_receipt': receipt})
    tasks.sort(key=lambda t: (rank(SEED, t['group']), rank(SEED, t['group'], t['condition'])))
    save(output / 'tasks.json', {'tasks': tasks})
    # Existing source preservation is a separate snapshot, never replaced by
    # the new synthetic initial worlds.
    data = (repeat / 'execution_events.jsonl').read_bytes()
    lines = data.splitlines()
    if data and not data.endswith(b'\n'): lines = lines[:-1]
    events = [json.loads(line) for line in lines]
    save(output / 'preservation_snapshot.json', {'cutoff_utc': base.now(), 'events': events,
        'registered_source_slots': 2700, 'parent': str(repeat), 'policy': 'All completed rows retained; unfinished slots remain pending.'})
    for name in ('protocol.json',): shutil.copy2(campaign / name, output / ('parent_' + name))
    for name in ('judgments/report.json', 'consensus_audit.json', 'compilation.json'):
        shutil.copy2(repeat / name, output / ('parent_' + Path(name).name.replace('report', 'judgments_report')))
    shutil.copytree(campaign / 'runtime', output / 'runtime')
    dependencies = [Path(__file__), Path('tests/test_revised_composition_eval.py'),
        Path('rcnc/composition_probes.py'), Path('rcnc/revised_followup.py'), *base.IMPLEMENTATION]
    impl = snapshot_implementation(output, list({str(p): p for p in dependencies}.values()))
    inputs = {str(p): digest(p) for p in output.rglob('*') if p.is_file()}
    protocol = {**registration, 'frozen_utc': base.now(), 'status': 'frozen_before_composition_search',
        'parent_campaign': str(campaign), 'repeat_condition': 'interrupted_first_repeat_continuation',
        'judgment_counts': judgments['status_counts'], 'task_count': len(selected), 'search_slots': len(tasks),
        'runtime_jar': str(output / 'runtime/glaive-corrected.jar'), 'runtime_classes': str(output / 'runtime/classes'),
        'input_sha256': inputs, 'implementation_sha256': impl}
    save(output / 'protocol.json', protocol)
    (output / 'PROTOCOL.sha256').write_text(digest(output / 'protocol.json') + '  protocol.json\n', encoding='utf-8')
    return {'status': protocol['status'], 'groups_censused': len(census), 'generated': len(generated),
        'selected': len(selected), 'search_slots': len(tasks),
        'by_size': {k: dict(Counter(r['status'] for r in census if r['size'] == k)) for k in (2, 3, 4)}}


def execute(root):
    p = base.verify(root)
    if (root / 'execution_progress.json').exists(): raise ValueError('Fresh execution required')
    tasks = base.read(root / 'tasks.json')['tasks']; start = time.monotonic(); rows = []; counts = Counter()
    jar, classes = Path(p['runtime_jar']), Path(p['runtime_classes'])
    def remaining(): return p['budgets']['execution_seconds'] - (time.monotonic() - start)
    def progress():
        save(root / 'execution_progress.json', {'completed': len(rows), 'registered': len(tasks),
            'calls': dict(counts), 'elapsed_seconds': time.monotonic() - start})
    progress()
    for task in tasks:
        row = dict(task); out = root / 'execution' / task['id']
        d, problem = Path(task['domain']), Path(task['problem'])
        if remaining() < 1:
            row['search'] = {'status': 'not_run_audit_budget'}
        else:
            counts['search'] += 1
            row['search'] = invoke(jar, d, problem, out / 'search', seconds=max(1, min(15, int(remaining()))))
        if row['search']['status'] == 'solved':
            plan = out / 'search/plan.pddl'
            if remaining() >= 1:
                counts['replay'] += 1
                row['replay'] = base.replay_checked(jar, classes, d, problem, plan, out / 'replay', seconds=max(1, min(15, int(remaining()))))
            else: row['replay'] = {'status': 'not_run_audit_budget', 'physical': base.physical(d, problem, plan)}
            row['valid_plan'] = base.valid(row['replay'])
            row['causal'] = causal_trace(d, problem, plan, base.read(Path(task['mapping']))) if row['valid_plan'] else {'status': 'unavailable_valid_plan'}
        else:
            row['valid_plan'] = False; row['causal'] = {'status': 'unavailable_valid_plan'}
        rows.append(row)
        with (root / 'execution_events.jsonl').open('a', encoding='utf-8') as stream: stream.write(json.dumps(row) + '\n')
        progress()
    saved = base.read(root / 'preservation_snapshot.json')
    preserved = [x['row'] for x in saved['events'] if x['kind'] == 'source_query']
    report = {'status': 'complete_posthoc_composition_diagnostic', 'rows': rows,
        'scope': p['scope'], 'cases': p['task_count'], 'calls': dict(counts), 'new_llm_calls': 0,
        'elapsed_seconds': time.monotonic() - start,
        'by_size_condition': {str(k): {c: {
            'registered': sum(r['size'] == k and r['condition'] == c for r in rows),
            'search': dict(Counter(r['search']['status'] for r in rows if r['size'] == k and r['condition'] == c)),
            'valid': sum(r['valid_plan'] for r in rows if r['size'] == k and r['condition'] == c),
            'causal': dict(Counter(r['causal']['status'] for r in rows if r['size'] == k and r['condition'] == c))}
            for c in CONDITIONS} for k in (2, 3, 4)},
        'preservation_snapshot': {'cutoff_utc': saved['cutoff_utc'], 'registered': 2700, 'completed': len(preserved),
            'pending': 2700 - len(preserved), 'transport': dict(Counter(r['transport']['status'] for r in preserved)),
            'validated': sum(base.valid(r['transport']) for r in preserved),
            'violations': [r['id'] for r in preserved if base.replay_evidence(r['transport']) not in ('valid', 'unknown')]},
        'input_hashes_unchanged': all(digest(Path(path)) == h for path, h in p['input_sha256'].items()),
        'independent_semantic_labels': 0}
    save(root / 'report.json', report)
    return {k: v for k, v in report.items() if k not in ('rows', 'by_size_condition')}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['prepare', 'execute'])
    parser.add_argument('--campaign', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = prepare(args.campaign, args.output) if args.mode == 'prepare' else execute(args.output)
    print(json.dumps(result, ensure_ascii=False, indent=2))

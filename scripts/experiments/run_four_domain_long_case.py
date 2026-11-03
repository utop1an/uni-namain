"""A frozen authored long-plan case in an unchanged four-source merged domain.

All worlds are explicitly declared below. No original-problem facts are pooled,
no actions are repaired, and no model calls or hand-written solution plans occur.
"""
import argparse
from itertools import combinations
from pathlib import Path
import json
import shutil
import time

from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.glaive_merge import action_fields
from rcnc.glaive_runtime import invoke
from rcnc.pddl import parse_sexpr, section, typed_symbols
from rcnc.revised_followup import authored_problem
from rcnc.revised_probe_validation import ground, holds, changes
from rcnc.composition_probes import literals
from scripts.experiments import run_revised_multistory as base

GROUP = 'k04_0218ded14bc9db22'
SOURCES = ['tiny_stories__story_028', 'tiny_stories__story_085',
           'tiny_stories__story_063', 'writing_prompts__wp_060']
CONDITIONS = ('full', 'union', 'without_A', 'without_B', 'without_C', 'without_D', 'separate_identity')


def dynamic_literals(expression):
    """Static object equalities constrain applicability but do not create links."""
    if expression[0] == 'and':
        return [item for child in expression[1:] for item in dynamic_literals(child)]
    if expression[0] == '=' or (expression[0] == 'not' and expression[1][0] == '='):
        return []
    return literals(expression)


def trace_case(domain, problem, plan, mapping):
    """Case-specific extension for grounded equality; historical tracer unchanged."""
    d = parse_sexpr(domain.read_text(encoding='utf-8'))
    p = parse_sexpr(problem.read_text(encoding='utf-8'))
    calls = section(parse_sexpr(plan.read_text(encoding='utf-8')), ':steps')[1:]
    actions = {a[1]: action_fields(a) for a in d if isinstance(a, list) and a and a[0] == ':action'}
    reverse = {}
    for reference, value in mapping['action_maps'].items():
        reverse.setdefault(value['name'], set()).add(reference.split(':')[0])
    state = {tuple(f) for f in section(p, ':init')[1:] if f[0] != 'intends'}
    owners, edges, steps = {}, [], []
    try:
        for index, call in enumerate(calls):
            if call[0] == 'non-executed': raise ValueError('counterfactual_step')
            origins = reverse[call[0]]
            if len(origins) != 1: raise ValueError('ambiguous_source_attribution')
            source = next(iter(origins)); action = actions[call[0]]
            bindings = dict(zip(typed_symbols(action[':parameters']), call[1:]))
            pre = ground(action[':precondition'], bindings)
            if not holds(pre, state): raise ValueError('inapplicable_step')
            for positive, atom in dynamic_literals(pre):
                if positive and tuple(atom) in owners:
                    edges.append({'from': owners[tuple(atom)], 'to': index, 'fact': atom})
            add, delete = changes(ground(action[':effect'], bindings), state)
            for fact in delete: owners.pop(fact, None)
            for fact in add - state: owners[fact] = index
            state = (state - delete) | add
            steps.append({'index': index, 'source': source, 'call': call})
        goal = section(p, ':goal')[1]
        if not holds(goal, state): raise ValueError('goal_not_reached')
        atoms = dynamic_literals(goal)
        if any(not sign for sign, _ in atoms): raise ValueError('negative_goal_outside_case_scope')
        relevant = {owners[tuple(atom)] for _, atom in atoms if tuple(atom) in owners}
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
            'goal_relevant_source_count': len({steps[i]['source'] for i in relevant}),
            'goal_relevant_step_indices': sorted(relevant), 'all_steps_goal_relevant': len(relevant) == len(steps)}
    except (ValueError, KeyError) as exc:
        return {'status': 'unknown', 'reason': str(exc)}


def scenario():
    a, b, c, d = SOURCES
    goals = [[b, ['cleaned', 'mira']], [b, ['forgiven', 'noah', 'mira']],
             [c, ['eaten', 'walnut']], [c, ['helping', 'emma', 'noah']],
             [d, ['wearing', 'mira', 'coat']]]
    return {'id': 'four_domain_long_independent_branches', 'sources': SOURCES,
        'objects': {'mira': {a: 'character', b: 'character', d: 'character'},
            'noah': {b: 'character', c: 'character'}, 'emma': {c: 'character'},
            'toy': {a: 'item', b: 'item'}, 'walnut': {c: 'object'}, 'coat': {d: 'item'}},
        'facts': [[a, ['reads', 'mira']], [c, ['hard', 'walnut']],
                  [d, ['alive', 'mira']], [d, ['has', 'mira', 'coat']]],
        'goal': goals,
        'intentions': [[actor, sid, goal] for actor in ('mira', 'noah', 'emma') for sid, goal in goals],
        'source_problem_facts_copied': 0,
        'scope': 'Authored case with a cross-source chain plus independent goal-relevant branches. Not an automatically sampled benchmark or a four-source causal chain.'}


def prepare(output):
    if output.exists():
        raise ValueError('Fresh output directory required')
    campaign = Path('data/validation/revised_multistory_k234_parallel10_iofix_2026_11_02_v1')
    parent = base.read(campaign / 'protocol.json')
    compilation = base.read(campaign / 'repeat_01/compilation.json')
    srcs = base.load_sources(parent)
    output.mkdir(parents=True)
    world = scenario(); save(output / 'explicit_scenario.json', world)
    registration = {'status': 'registered_before_problem_export', 'created_utc': base.now(),
        'group': GROUP, 'sources': SOURCES, 'case_kind': 'authored_development_demonstration',
        'selection_basis': 'Existing accepted possession interface, distinct source action families, explicit meaningful subgoals; selected before this new search, with earlier source/schema knowledge.',
        'requirements': {'minimum_plan_steps': 11, 'actual_sources': 4,
            'goal_relevant_sources': 4, 'at_least_one_goal_relevant_cross_source_link': True,
            'at_least_one_independent_action_pair': True},
        'budgets': {'max_searches': 7, 'max_replays': 7, 'full_search_seconds': 60,
            'control_search_seconds': 15, 'seconds_per_replay': 15,
            'execution_seconds': 600, 'memory_mb': 4096, 'workers': 1,
            'model_calls': 0, 'retry_calls': 0},
        'conditions': CONDITIONS,
        'interpretation': 'Independent actions means separate goal branches with no read/write conflict or causal path; it does not mean unexplained filler actions.',
        'expected_length_basis': 'Toy acquisition/play/break/clean (4), apology/forgiveness (2), help/break/eat (3), adjust/wear (2): 11 actions using unmodified source rules. This is a pre-search structural expectation, not a claimed result.'}
    save(output / 'registration_before_export.json', registration)
    receipts = []
    for condition in ('full', 'union'):
        src = campaign / 'repeat_01/models' / GROUP / condition
        dst = output / 'models' / condition; dst.mkdir(parents=True)
        for name in ('domain.pddl', 'mapping.json'):
            source = src / name
            if digest(source) != compilation['input_sha256'][str(source)]:
                raise ValueError('Parent model differs from frozen compilation')
            shutil.copy2(source, dst / name)
            receipts.append({'parent': str(source), 'copy': str(dst / name), 'sha256': digest(source)})
    save(output / 'model_copy_receipts.json', {'files': receipts})
    tasks = []
    selected = [srcs[sid] for sid in SOURCES]
    for condition in CONDITIONS:
        folder = output / 'models' / ('union' if condition == 'union' else 'full')
        active = set(SOURCES)
        if condition.startswith('without_'):
            active.remove(SOURCES['ABCD'.index(condition[-1])])
        problem = output / 'problems' / (condition + '.pddl'); problem.parent.mkdir(exist_ok=True)
        receipt = authored_problem(selected, base.read(folder / 'mapping.json'), world, problem,
            active_sources=active, separate_identity=condition == 'separate_identity')
        tasks.append({'id': condition, 'condition': condition, 'domain': str(folder / 'domain.pddl'),
            'problem': str(problem), 'mapping': str(folder / 'mapping.json'), 'world_receipt': receipt,
            'seconds': 60 if condition == 'full' else 15})
    save(output / 'tasks.json', {'tasks': tasks})
    old_runtime = Path('data/validation/revised_multistory_composition_eval_2026_11_02_v1/runtime')
    shutil.copytree(old_runtime, output / 'runtime')
    paths = {Path(__file__).resolve(), Path('scripts/audit/eval_revised_composition.py').resolve(),
        Path('tests/test_four_domain_long_case.py').resolve(),
        Path('rcnc/composition_probes.py').resolve(), Path('rcnc/revised_followup.py').resolve(),
        *[p.resolve() for p in base.IMPLEMENTATION]}
    implementations = snapshot_implementation(output, sorted(paths, key=str))
    inputs = {str(p): digest(p) for p in output.rglob('*') if p.is_file()}
    protocol = {**registration, 'status': 'frozen_before_case_search', 'frozen_utc': base.now(),
        'input_sha256': inputs, 'implementation_sha256': implementations,
        'runtime_jar': str(output / 'runtime/glaive-corrected.jar'),
        'runtime_classes': str(output / 'runtime/classes')}
    save(output / 'protocol.json', protocol)
    (output / 'PROTOCOL.sha256').write_text(digest(output / 'protocol.json') + '  protocol.json\n', encoding='utf-8')
    return {'status': protocol['status'], 'search_slots': len(tasks), 'model_calls': 0,
            'protocol_sha256': digest(output / 'protocol.json')}


def independent_pairs(domain, plan, trace):
    actions = {a[1]: action_fields(a) for a in parse_sexpr(domain.read_text(encoding='utf-8'))
               if isinstance(a, list) and a and a[0] == ':action'}
    steps = section(parse_sexpr(plan.read_text(encoding='utf-8')), ':steps')[1:]
    footprints = []
    for call in steps:
        action = actions[call[0]]
        binding = dict(zip(typed_symbols(action[':parameters']), call[1:]))
        reads = {tuple(atom) for _, atom in dynamic_literals(ground(action[':precondition'], binding))}
        writes = {tuple(atom) for _, atom in literals(ground(action[':effect'], binding))}
        footprints.append((reads, writes))
    edges = {(e['from'], e['to']) for e in trace['causal_edges']}
    reach = set(edges)
    while True:
        expanded = reach | {(a, d) for a, b in reach for c, d in reach if b == c}
        if expanded == reach: break
        reach = expanded
    pairs = []
    for i, j in combinations(range(len(steps)), 2):
        ri, wi = footprints[i]; rj, wj = footprints[j]
        if (i, j) not in reach and (j, i) not in reach and not wi & (rj | wj) and not wj & ri:
            pairs.append({'first': i, 'second': j, 'reason': 'no causal path and disjoint read/write interference'})
    return pairs


def execute(root):
    protocol = base.verify(root)
    if (root / 'execution_progress.json').exists():
        raise ValueError('Fresh execution required')
    rows = []; started = time.monotonic(); calls = {'search': 0, 'replay': 0}
    jar = Path(protocol['runtime_jar']); classes = Path(protocol['runtime_classes'])
    save(root / 'execution_progress.json', {'completed': 0, 'registered': 7})
    for task in base.read(root / 'tasks.json')['tasks']:
        domain, problem = Path(task['domain']), Path(task['problem'])
        out = root / 'execution' / task['id']; row = dict(task)
        calls['search'] += 1
        row['search'] = invoke(jar, domain, problem, out / 'search', seconds=task['seconds'])
        row['valid_plan'] = False
        if row['search']['status'] == 'solved':
            plan = out / 'search/plan.pddl'; calls['replay'] += 1
            row['replay'] = base.replay_checked(jar, classes, domain, problem, plan, out / 'replay', seconds=15)
            row['valid_plan'] = base.valid(row['replay'])
            if row['valid_plan']:
                row['causal'] = trace_case(domain, problem, plan, base.read(Path(task['mapping'])))
                if row['causal']['status'] != 'unknown':
                    row['independent_pairs'] = independent_pairs(domain, plan, row['causal'])
        rows.append(row)
        with (root / 'execution_events.jsonl').open('a', encoding='utf-8') as f:
            f.write(json.dumps(row) + '\n')
        save(root / 'execution_progress.json', {'completed': len(rows), 'registered': 7,
            'calls': calls, 'elapsed_seconds': time.monotonic() - started})
    full = rows[0]; trace = full.get('causal', {})
    meets = (full['valid_plan'] and full['replay'].get('steps', 0) >= 11
        and trace.get('actual_source_count') == 4 and trace.get('goal_relevant_source_count') == 4
        and trace.get('all_steps_goal_relevant')
        and bool(trace.get('cross_source_edges')) and bool(full.get('independent_pairs')))
    unchanged = all(digest(Path(p)) == expected for p, expected in protocol['input_sha256'].items())
    report = {'status': 'complete_authored_long_case', 'requirements_met': meets,
        'rows': rows, 'calls': calls, 'new_model_calls': 0,
        'inputs_unchanged': unchanged, 'elapsed_seconds': time.monotonic() - started,
        'scope': 'One authored world in a previously saved parameterized four-domain model; not a benchmark success rate or a single causal chain through all four domains.'}
    save(root / 'report.json', report)
    return {'status': report['status'], 'requirements_met': meets, 'calls': calls,
        'full_search': full['search']['status'], 'full_steps': full.get('replay', {}).get('steps'),
        'actual_sources': trace.get('actual_source_count'), 'goal_relevant_sources': trace.get('goal_relevant_source_count'),
        'cross_source_edges': trace.get('cross_source_edges'),
        'independent_action_pairs': len(full.get('independent_pairs', [])), 'inputs_unchanged': unchanged}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=('prepare', 'execute'))
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    result = prepare(args.output) if args.mode == 'prepare' else execute(args.output)
    print(json.dumps(result, ensure_ascii=False, indent=2))

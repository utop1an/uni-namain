"""Freeze and run typed compilation controls on the existing rescue world."""
import argparse
from collections import Counter, defaultdict
from copy import deepcopy
import json
from pathlib import Path
import subprocess
import sys

from rcnc.conditional_merge import symbol_digest
from rcnc.domain_building import digest, save
from rcnc.glaive_merge import Source, build, map_problem
from rcnc.pddl import parse_sexpr, section, serialize
from rcnc.revised_followup import authored_problem
from rcnc.shared_types import SharedTypes
from rcnc.shared_type_cli import run as shared_search, physical_inputs
from rcnc.validation import validate_artifacts
from scripts.experiments.run_matched_unidomain_rule import physical_domain, physical_problem

ROOT = Path(__file__).resolve().parents[2]
IDS = {'A': 'human_72bec7307b121ea5', 'B': 'human_62959785b3ec220a', 'R': 'human_281c51d26d5d4ff3'}


def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def emit(path, root):
    path.write_text(serialize(root) + '\n', encoding='utf-8')


def imported_groups(sources, mapping):
    groups = defaultdict(list)
    for source in sources:
        for name, (target, order) in mapping['predicate_maps'][source.id].items():
            if target.startswith('shared_'):
                groups[target].append((source, name, order))
    return [group(target.removeprefix('shared_'), members,
                  'Reused frozen accepted interface; not a new model judgment') for target, members in groups.items()]


def group(name, members, evidence):
    return {'id': name, 'model_judgment': {'decision': 'compatible', 'basis': 'authored_assumption'},
            'members': [{'predicate': s.id + ':' + pred, 'order': order,
                         'semantics': {'concept': name, 'scope': 'physical', 'roles': ['arg' + str(i) for i in order],
                                       'confidence': 1.0, 'evidence': [evidence],
                                       'symbol_sha256': symbol_digest(s.domain.predicates[pred])}}
                        for s, pred, order in members]}


def prepare(output, research):
    output.mkdir(parents=True, exist_ok=False)
    inputs = output / 'inputs'; inputs.mkdir()
    old = ROOT / 'paper/results/rescue_problem_contract_2026_11_18_v2/controls/inputs/full'
    mapping = read(old / 'mapping.json')
    baseline = research / 'validation/priority1_red_arthur_batman_2026_11_08_v1'
    world = read(baseline / 'scenario.json')
    assert digest(baseline / 'scenario.json') == read(baseline / 'protocol.json')['scenario_sha256']
    sources = []
    for sid, hashes in mapping['source_sha256'].items():
        for kind, expected in hashes.items():
            path = research / 'research_release/narrative_baseline_priority1_2026_11_05_v1/inputs' / (expected + '.pddl')
            assert digest(path) == expected
            (inputs / (sid + '_' + kind + '.pddl')).write_bytes(path.read_bytes())
        sources.append(Source(sid, inputs / (sid + '_domain.pddl'), inputs / (sid + '_problem.pddl')))
    save(inputs / 'sources.json', [{'id': s.id, 'domain': s.domain_path.name, 'problem': s.problem_path.name} for s in sources])
    spec = {'version': 1, 'decision_basis': 'authored_assumption',
            'evidence': ['Characters share the actor type; human roles retain their source subtyping.',
                         'Arthur item and Little Red thing denote portable items. Batman thing includes characters and locations and maps to entity.',
                         'Little Red house is a location subtype. Arthur thing, used by is(item,thing), remains attribute.',
                         'These are explicit case assumptions, not independently labeled or name-only automatic alignments.'],
            'source_sha256': {s.id: digest(s.domain_path) for s in sources},
            'types': {'entity': 'object', 'character': 'entity', 'human': 'character', 'worker': 'human',
                      'hunter': 'worker', 'blacksmith': 'human', 'allworker': 'human', 'girl': 'human',
                      'grandmother': 'human', 'beast': 'character', 'wolf': 'beast', 'fox': 'beast',
                      'item': 'entity', 'axe': 'item', 'cake': 'item', 'book': 'item', 'sword': 'item',
                      'ring': 'item', 'location': 'entity', 'house': 'location', 'attribute': 'object'},
            'mappings': {s.id: {t: ('attribute' if s.id == IDS['A'] else 'entity' if s.id == IDS['B'] else 'item')
                              if t == 'thing' else t for t in s.types} for s in sources}}
    types = SharedTypes.from_sources(sources, spec)
    save(inputs / 'types.json', spec)
    canonical = deepcopy(world)
    canonical['objects'] = {o: types.object_type(t) for o, t in world['objects'].items()}
    save(inputs / 'world.json', canonical)
    save(inputs / 'legacy_world.json', world)
    groups = imported_groups(sources, mapping)
    save(inputs / 'alignments.json', groups)
    expanded = [g for g in groups if not any(m['predicate'].split(':')[1] == 'at' for m in g['members'])]
    expanded.append(group('shared_location', [(s, 'at', [0, 1]) for s in sources],
                          'Additional authored location alignment, separate from the type-only intervention. No world facts added.'))
    save(inputs / 'alignments_with_shared_at.json', expanded)
    models = output / 'models'; models.mkdir()
    for arm, alignment in [('legacy_scoped', None), ('native_types', spec), ('native_types_shared_at', spec)]:
        meta = build(sources, models / arm, groups=expanded if arm.endswith('shared_at') else groups, type_alignment=alignment)
        if arm == 'legacy_scoped':
            # Preserve the entire original transition model, not just the trace.
            actual = physical_domain(parse_sexpr((models / arm / 'domain.pddl').read_text(encoding='utf-8')))
            expected = parse_sexpr((old / 'domain.pddl').read_text(encoding='utf-8'))
            actions = lambda d: {x[1]: x for x in d if isinstance(x, list) and x[:1] == [':action']}
            assert actions(actual) == actions(expected)
            authored_problem(sources, meta, world, models / arm / 'authored_problem.pddl')
            emit(models / arm / 'physical_domain.pddl', actual)
            emit(models / arm / 'physical_problem.pddl', physical_problem(parse_sexpr((models / arm / 'authored_problem.pddl').read_text(encoding='utf-8'))))
    probe = {'id': 'batman_can_pick_up', 'objects': {'batman': 'hunter', 'axe': 'axe', 'forge': 'house'},
             'facts': [[IDS['A'], ['at', 'batman', 'forge']], [IDS['A'], ['at', 'axe', 'forge']]],
             'goal': [[IDS['A'], ['has', 'batman', 'axe']]]}
    save(inputs / 'pickup_world.json', probe)
    blocked = deepcopy(probe); blocked['id'] = 'enchanted_pickup_blocked'
    blocked['facts'].append([IDS['A'], ['enchanted', 'axe']])
    save(inputs / 'enchanted_pickup_world.json', blocked)
    references = research / 'validation/rescue_original_plan_comparison_2026_11_10_v1'
    rows = read(references / 'comparison_evidence.json')['original_cases']
    for row in rows:
        p = references / row['path']; assert digest(p) == row['sha256']
        (inputs / (row['source'] + '_reference.pddl')).write_bytes(p.read_bytes())
    protocol = {'status': 'frozen_before_search', 'seconds': 30,
                'budget': {'max_states': 20000, 'max_depth': 20, 'max_ground_actions': 100000, 'max_ground_fluents': 100000},
                'tasks': [
                    {'id': 'legacy_scoped', 'model': 'legacy_scoped', 'world': 'legacy_world.json'},
                    {'id': 'native_types', 'model': 'native_types', 'world': 'world.json'},
                    {'id': 'native_types_shared_at', 'model': 'native_types_shared_at', 'world': 'world.json'},
                    {'id': 'native_types_shared_at_without_b', 'model': 'native_types_shared_at', 'world': 'world.json',
                     'active_sources': [IDS['A'], IDS['R']]},
                    {'id': 'foreign_pickup', 'model': 'native_types', 'world': 'pickup_world.json'},
                    {'id': 'enchanted_pickup', 'model': 'native_types', 'world': 'enchanted_pickup_world.json'}],
                'input_sha256': {str(p.relative_to(output)): digest(p) for p in sorted(output.rglob('*')) if p.is_file()},
                'implementation_sha256': {str(p.relative_to(ROOT)): digest(p) for p in [Path(__file__), *sorted((ROOT / 'rcnc').glob('*.py'))]},
                'scope': 'Post-hoc development controls. Native type alignment and added location alignment are separate interventions. No benchmark updates.'}
    save(output / 'protocol.json', protocol)
    print('Prepared six search conditions; no searches or model requests issued.', flush=True)


def run(output):
    protocol = read(output / 'protocol.json')
    for base, key in [(output, 'input_sha256'), (ROOT, 'implementation_sha256')]:
        for p, h in protocol[key].items(): assert digest(base / p) == h, p
    rows = []
    executions = output / 'execution'; executions.mkdir(exist_ok=False)
    for task in protocol['tasks']:
        model = output / 'models' / task['model']; target = executions / task['id']
        try:
            if task['id'] == 'legacy_scoped':
                target.mkdir()
                command = [sys.executable, '-m', 'rcnc', 'plan', '--worker', '--mode', 'initial_goal', '--solver', 'state_projected',
                           '--domain', str(model / 'physical_domain.pddl'), '--problem', str(model / 'physical_problem.pddl'),
                           '--output', str(target / 'search'), '--budget', json.dumps({**protocol['budget'], 'correlated_parameter_tuples': True})]
                with (target / 'worker.log').open('w', encoding='utf-8') as log:
                    try:
                        process = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, timeout=protocol['seconds'], cwd=ROOT)
                        search = read(target / 'search/search.json') if (target / 'search/search.json').exists() else {'status': 'worker_error', 'returncode': process.returncode}
                    except subprocess.TimeoutExpired:
                        search = {'status': 'wall_time_limit'}
            else:
                search = shared_search(model, read(output / 'inputs' / task['world']), target,
                                       seconds=protocol['seconds'], **protocol['budget'], active_sources=task.get('active_sources'))['search']
            row = {**task, **search}
        except Exception as exc:
            row = {**task, 'status': 'error', 'reason': type(exc).__name__ + ': ' + str(exc)}
        rows.append(row)
        save(executions / (task['id'] + '.json'), row)
        print(task['id'], row['status'], row.get('length'), row.get('reason', ''), flush=True)
    # Three original-world physical trace replays, not search outcomes.
    sources = [Source(row['id'], output / 'inputs' / row['domain'], output / 'inputs' / row['problem'])
               for row in read(output / 'inputs/sources.json')]
    meta = read(output / 'models/native_types/mapping.json')
    replay_rows = []
    for label, sid in [('arthur', IDS['A']), ('batman', IDS['B']), ('red', IDS['R'])]:
        target = output / 'replays' / label; target.mkdir(parents=True)
        terms = map_problem(sources, sid, meta, target / 'original_problem.pddl')
        domain, problem, type_renaming = physical_inputs(
            parse_sexpr((output / 'models/native_types/domain.pddl').read_text(encoding='utf-8')),
            parse_sexpr((target / 'original_problem.pddl').read_text(encoding='utf-8')))
        emit(target / 'domain.pddl', domain)
        emit(target / 'problem.pddl', problem)
        save(target / 'physical_type_renaming.json', type_renaming)
        saved = (output / 'inputs' / (label + '_reference.pddl')).read_text(encoding='utf-8')
        if label == 'arthur':
            calls = section(parse_sexpr(saved), ':steps')[1:]
            calls = [[meta['action_maps'][sid + ':' + a[0]]['name'], *[terms[x] for x in a[1:]]] for a in calls]
        else:
            calls = [parse_sexpr(line.split(';')[0].strip()) for line in saved.splitlines() if line.split(';')[0].strip()]
        (target / 'plan.txt').write_text('\n'.join(serialize(c) for c in calls) + '\n', encoding='utf-8')
        try:
            validation = validate_artifacts(target)
        except Exception as exc:
            validation = {'status': 'error', 'reason': type(exc).__name__ + ': ' + str(exc)}
        replay_rows.append({'source': sid, 'steps': len(calls), 'validation': validation})
    assert all(digest(output / p) == h for p, h in protocol['input_sha256'].items())
    assert all(digest(ROOT / p) == h for p, h in protocol['implementation_sha256'].items())
    save(output / 'report.json', {'status': 'complete', 'task_count': len(rows), 'status_counts': dict(Counter(r['status'] for r in rows)),
                                'rows': rows, 'original_replays': replay_rows, 'model_calls': 0,
                                'inputs_unchanged': True, 'implementation_unchanged': True,
                                'protocol_sha256': digest(output / 'protocol.json'), 'scope': protocol['scope']})


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('phase', choices=['prepare', 'run'])
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--research-root', type=Path, default=Path('archive/research-data-v1/data'))
    args = parser.parse_args()
    prepare(args.output.resolve(), args.research_root.resolve()) if args.phase == 'prepare' else run(args.output.resolve())

"""Independent execution plus explicit identity/life checks for the authored case."""
import argparse
from collections import Counter
import json
from pathlib import Path
from unified_planning.io import PDDLReader
from unified_planning.shortcuts import SequentialSimulator
from rcnc.domain_building import require_empty_output, save
from rcnc.validation import validate_artifacts
from scripts.experiments.run_downward_reference import sha


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def replay(directory, contract):
    meta = read(directory / 'source_mapping.json')
    reader = PDDLReader()
    problem = reader.parse_problem(str(directory / 'domain.pddl'), str(directory / 'problem.pddl'))
    plan = reader.parse_plan(problem, str(directory / 'plan.txt'))
    origin = {v.lower(): (s, name) for s, table in meta['action_maps'].items() for name, v in table.items()}
    def fluent(source, name, *objects):
        return problem.fluent(meta['predicate_maps'][source][name].lower())(*[problem.object('q__' + obj) for obj in objects])
    snow = problem.object('q__snow_white')
    watched = {'alive(snow_white)': fluent('SNOW', 'alive', 'snow_white'),
        'dead(snow_white)': fluent('SNOW', 'dead', 'snow_white'),
        'has(rescuer,comb)': fluent('SNOW', 'has', 'rescuer', 'comb'),
        'poisoned(comb)': fluent('SNOW', 'poisoned', 'comb'),
        'climbing_down(snow_white)': fluent('JACK_NP', 'climbing_down', 'snow_white'),
        'rescued_with_comb(snow_white)': problem.fluent('case_rescued_with_comb')(snow),
        'intact(beanstalk)': problem.fluent(meta['predicate_maps']['JACK_NP']['intact'].lower())(
            problem.object(meta['constant_maps']['JACK_NP']['beanstalk'].lower()))}
    for role in ('snow_white', 'giant', 'witch'):
        watched['role_' + role + '(snow_white)'] = problem.fluent('case_role_' + role)(snow)
    def snapshot(state):
        return {name: state.get_value(expr).bool_constant_value() for name, expr in watched.items()}
    states, steps, violations = [], [], []
    with SequentialSimulator(problem) as sim:
        state = sim.get_initial_state()
        for index in range(len(plan.actions) + 1):
            values = snapshot(state)
            states.append({'index': index, 'facts': values})
            for actor in ('snow_white', 'rescuer', 'companion', 'jack'):
                alive = state.get_value(fluent('SNOW', 'alive', actor)).bool_constant_value()
                dead = state.get_value(fluent('SNOW', 'dead', actor)).bool_constant_value()
                if alive and dead:
                    violations.append({'state': index, 'actor': actor, 'violation': 'alive_and_dead'})
            if not all(values['role_' + role + '(snow_white)'] for role in ('snow_white', 'giant', 'witch')):
                violations.append({'state': index, 'violation': 'identity_role_lost'})
            if index == len(plan.actions):
                break
            instance = plan.actions[index]
            if not sim.is_applicable(state, instance):
                raise ValueError('Inapplicable action at step ' + str(index + 1))
            source, name = origin[instance.action.name.lower()]
            parameters = ['?' + p.name.lstrip('?') for p in instance.action.parameters]
            bound = dict(zip(parameters, [p.object().name for p in instance.actual_parameters]))
            role_checks = []
            for parameter, role in contract['parameter_roles'][source][name].items():
                role_checks.append({'parameter': parameter, 'role': role, 'object': bound[parameter],
                    'holds': state.get_value(problem.fluent('case_role_' + role)(problem.object(bound[parameter]))).bool_constant_value()})
            following = sim.apply(state, instance)
            if following is None:
                raise ValueError('Failed state transition')
            steps.append({'step': index + 1, 'source': source, 'action': name, 'instance': str(instance),
                'bindings': bound, 'role_checks': role_checks, 'applicable': True,
                'before': values, 'after': snapshot(following)})
            state = following
        goal_reached = sim.is_goal(state)
    validation = validate_artifacts(directory)
    return {'validation': validation, 'goal_reached': goal_reached, 'states': states, 'steps': steps,
        'life_identity_violations': violations, 'role_checks_pass': all(c['holds'] for s in steps for c in s['role_checks']),
        'sources_used': dict(Counter(s['source'] for s in steps)),
        'scope': 'PDDL execution and declared scenario contracts; not independent narrative/semantic assessment'}


def run(case, output):
    require_empty_output(output)
    manifest, report = read(case / 'bundle/manifest.json'), read(case / 'solver/report.json')
    solver = read(case / 'solver/manifest.json')
    contract = read(case / 'scenario_contract.json')
    if report['status'] != 'complete' or not report['binary_unchanged'] or not report['runner_unchanged']:
        raise ValueError('Complete unchanged solver block required')
    if solver['budget'] != {'wall_seconds': 20, 'overall_cpu_seconds': 20, 'memory_mb': 4096}:
        raise ValueError('Budget mismatch')
    if len(report['rows']) != 11 or {r['id'] for r in report['rows']} != {t['id'] for t in manifest['tasks']}:
        raise ValueError('Incomplete or duplicate denominator')
    if sha(case / 'solver/manifest.json') != report['manifest_sha256']:
        raise ValueError('Solver manifest drift')
    if sha(case / 'query.json') != manifest['query_sha256'] or sha(case / 'scenario_contract.json') != manifest['contract_sha256']:
        raise ValueError('Authored contract drift')
    for path, digest in manifest['implementation_sha256'].items():
        if sha(Path(path)) != digest:
            raise ValueError('Construction implementation drift')
    for name, digest in manifest['source_sha256'].items():
        if sha(case / 'inputs' / name) != digest:
            raise ValueError('Source snapshot drift')
    frozen = {str(p): sha(p) for p in (case / 'bundle/manifest.json', case / 'solver/manifest.json',
        case / 'solver/report.json', case / 'query.json', case / 'scenario_contract.json',
        Path(__file__), Path('rcnc/validation.py'))}
    rows = []
    for task in manifest['tasks']:
        original = case / 'bundle/tasks' / task['id']
        directory = case / 'solver/tasks' / task['id']
        for kind in ('domain', 'problem'):
            path = directory / (kind + '.pddl')
            if sha(path) != task[kind + '_sha256']:
                raise ValueError('Solver inputs changed')
            frozen[str(path)] = sha(path)
        for filename, key in [('source_mapping.json', 'mapping_sha256'), ('scenario_patches.json', 'patches_sha256')]:
            if sha(original / filename) != task[key]:
                raise ValueError('Scenario provenance changed')
            frozen[str(original / filename)] = sha(original / filename)
        row = next(copy for copy in report['rows'] if copy['id'] == task['id']).copy()
        row.update(interfaces=task['interfaces'], retained_sources=task['retained_sources'],
            role_guards=task['role_guards'], life_adapter=task['life_adapter'], shared_identity=task['shared_identity'])
        if row['status'] == 'solved':
            # Solver directories intentionally contain only executable inputs;
            # give the auditor the pinned mapping from the frozen task bundle.
            reader_dir = output / 'replay_inputs' / task['id']
            reader_dir.mkdir(parents=True)
            for name in ('domain.pddl', 'problem.pddl', 'plan.txt'):
                (reader_dir / name).write_bytes((directory / name).read_bytes())
                frozen[str(directory / name)] = sha(directory / name)
            (reader_dir / 'source_mapping.json').write_bytes((original / 'source_mapping.json').read_bytes())
            row['execution_audit'] = replay(reader_dir, contract)
            checked = row['execution_audit']
            row['scenario_contract_pass'] = checked['validation']['status'] == 'VALID' and checked['goal_reached'] and checked['role_checks_pass'] and not checked['life_identity_violations']
        else:
            row['scenario_contract_pass'] = None
        rows.append(row)
    main = next(r for r in rows if r['id'] == 'role_safe')['execution_audit']
    if not next(r for r in rows if r['id'] == 'role_safe')['scenario_contract_pass']:
        raise ValueError('Primary scenario failed execution/identity/life audit')
    expected_sources = {'HANS_NP', 'JACK_NP', 'SNOW'}
    if set(main['sources_used']) != expected_sources:
        raise ValueError('Primary scenario does not actually use all three sources')
    output.mkdir(parents=True, exist_ok=True)
    story_steps = {
        'collect_treasure': '两名同伴在小屋里收集了一把梳子和一颗宝石。',
        'stepmother_makes_poisonous_comb_and_visits_cottage': '白雪公主以女巫的身份制成毒梳，并到访小屋。',
        'cut_beanstalk': '杰克砍断豆茎；正在下行的巨人白雪公主死亡，下行状态随之结束。',
        'dwarfs_remove_comb_rescue_snow_white': '矮人营救者拔去毒梳，使同一个白雪公主复活，毒性也被清除。'}
    story = '白雪公主既是巨人，也是女巫。开始时，她活着，正在沿完整的豆茎下行；两名同伴在小屋中，梳子尚未带毒。\n\n'
    story += '\n'.join(str(step['step']) + '．' + story_steps[step['action']] for step in main['steps'])
    story += '\n\n最终：豆茎已毁；白雪公主活着，死亡状态已清除，并且确实经历了拔梳复活。\n\n'
    story += '说明：这是实际计划的逐步中文释义。角色许可、生死适配器和拔梳复活观察目标均为显式作者约束。物品持有非排他，源复活动作不检查死亡原因或梳子附着，位置与旅行时间没有完整建模；独立故事质量评价尚未进行。\n'
    (output / 'story_zh.txt').write_text(story, encoding='utf-8')
    result = {'status': 'complete', 'task_count': len(rows), 'rows': rows,
        'status_counts': dict(Counter(r['status'] for r in rows)),
        'scenario_contract_pass_count': sum(r['scenario_contract_pass'] is True for r in rows),
        'scenario_contract_fail_count': sum(r['scenario_contract_pass'] is False for r in rows),
        'source_count': 3, 'primary_plan_length': len(main['steps']), 'primary_trace_states': len(main['states']),
        'role_identity': {'single_object': 'q__snow_white', 'roles': ['snow_white', 'giant', 'witch'],
                          'immutable_facts_checked_in_every_primary_state': True},
        'source_action_templates_before_controls': 56,
        'compiled_source_behavior_modified': True, 'modification_contract': str(case / 'scenario_contract.json'),
        'independent_semantic_labels': 0, 'source_problem_facts_imported': False,
        'semantic_limits': ['Role guards are authored and make uncast roles unavailable; not automatically learned role equivalences.',
            'Life synchronization and ending descent are authored changes to compiled effects; unrestricted source preservation is not claimed.',
            'The goal explicitly observes a comb rescue, rather than only asking for final alive status.',
            'Source has is non-exclusive; recovery does not check cause of death or physical comb attachment.',
            'Visited is an abstract historical flag, with no complete travel/time model. No independently evaluated narrative quality.'],
        'frozen_sha256': frozen, 'hashes_unchanged': all(sha(Path(p)) == h for p, h in frozen.items())}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--case', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = run(args.case, args.output)
    print(json.dumps({k: result[k] for k in ('status', 'task_count', 'status_counts', 'scenario_contract_pass_count', 'scenario_contract_fail_count', 'primary_plan_length', 'hashes_unchanged')}, indent=2))

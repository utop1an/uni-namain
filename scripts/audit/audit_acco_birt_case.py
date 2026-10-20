"""Audit frozen controls, source use, executable causal trace and semantic risks."""
import argparse
import json
from pathlib import Path
from collections import Counter
from unified_planning.io import PDDLReader, PDDLWriter
from unified_planning.plans import SequentialPlan, ActionInstance
from unified_planning.shortcuts import SequentialSimulator
from rcnc.domain_building import require_empty_output, save
from rcnc.pddl import parse_domain, parse_sexpr
from rcnc.validation import validate_artifacts
from rcnc.world_source_selection import select_component
from scripts.experiments.run_downward_reference import sha


def run(case, output):
    require_empty_output(output)
    report = json.loads((case / 'solver/report.json').read_text(encoding='utf-8'))
    manifest = json.loads((case / 'bundle/manifest.json').read_text(encoding='utf-8'))
    solver_manifest = json.loads((case / 'solver/manifest.json').read_text(encoding='utf-8'))
    if report['status'] != 'complete' or not report['binary_unchanged'] or not report['runner_unchanged']:
        raise ValueError('Complete unchanged solver comparison required')
    if solver_manifest['budget'] != {'wall_seconds': 20, 'overall_cpu_seconds': 20, 'memory_mb': 4096}:
        raise ValueError('Changed budget')
    if report['manifest_sha256'] != sha(case / 'solver/manifest.json') or len(report['rows']) != 5:
        raise ValueError('Incomplete or changed solver evidence')
    if {r['id'] for r in report['rows']} != {t['id'] for t in manifest['tasks']}:
        raise ValueError('Control denominator mismatch')
    for path, digest in manifest['implementation_sha256'].items():
        if sha(Path(path)) != digest:
            raise ValueError('Construction implementation changed')
    frozen = {str(p): sha(p) for p in [case / 'bundle/manifest.json', case / 'solver/manifest.json',
        case / 'solver/report.json', Path(__file__), Path('rcnc/world_source_selection.py'), Path('rcnc/validation.py')]}
    for task in manifest['tasks']:
        for kind in ('domain', 'problem'):
            path = case / 'solver/tasks' / task['id'] / (kind + '.pddl')
            if sha(path) != task[kind + '_sha256']:
                raise ValueError('Frozen control changed')
            frozen[str(path)] = sha(path)
    # The first four conditions must have byte-identical explicit worlds/goals.
    if len({t['problem_sha256'] for t in manifest['tasks'] if t['id'] != 'no_shared_identity'}) != 1:
        raise ValueError('Primary controls changed the world/goal')
    output.mkdir(parents=True)
    original = case / 'solver/tasks/interface_pair'
    reader = PDDLReader()
    problem = reader.parse_problem(str(original / 'domain.pddl'), str(original / 'problem.pddl'))
    plan = reader.parse_plan(problem, str(original / 'plan.txt'))
    frozen[str(original / 'plan.txt')] = sha(original / 'plan.txt')
    meta = json.loads((case / 'models/interface_pair/meta_domain.json').read_text(encoding='utf-8'))
    source_actions = {v.lower(): (s, k) for s, table in meta['action_maps'].items() for k, v in table.items()}
    predicate = lambda s, p: problem.fluent(meta['predicate_maps'][s][p].lower())
    constant = lambda s, p: problem.object(next(v for k, v in meta['constant_maps'][s].items() if k.lower() == p.lower()).lower())
    hero, token, stage = [problem.object('q__' + p) for p in ('hero', 'token', 'stage')]
    badger = constant('ACCO', 'badger')
    watched = {'BIRT:at(hero,stage)': predicate('BIRT', 'at')(hero, stage),
        'shared:has(hero,token)': predicate('ACCO', 'has')(hero, token),
        'ACCO:exhibition_ready(hero)': predicate('ACCO', 'exhibition_ready')(hero),
        'ACCO:performing_show(hero)': predicate('ACCO', 'performing_show')(hero),
        'ACCO:reputation_widespread': predicate('ACCO', 'reputation_widespread')(),
        'ACCO:wealthy(hero)': predicate('ACCO', 'wealthy')(hero)}
    snapshot = lambda state: {name: state.get_value(expr).bool_constant_value() for name, expr in watched.items()}
    trace = []
    with SequentialSimulator(problem) as sim:
        state = sim.get_initial_state()
        initial = snapshot(state)
        for index, action in enumerate(plan.actions):
            before = snapshot(state)
            applicable = sim.is_applicable(state, action)
            after = sim.apply(state, action)
            if not applicable or after is None:
                raise ValueError('Plan replay failed')
            source, name = source_actions[action.action.name.lower()]
            trace.append({'step': index + 1, 'source': source, 'action': name,
                'instance': str(action), 'applicable': applicable, 'before': before, 'after': snapshot(after),
                'compiled_preconditions': [str(p) for p in action.action.preconditions]})
            state = after
            if index == 2:
                # Executable one-step witness of the global-reputation risk.
                orders = problem.action(meta['action_maps']['ACCO']['receive_orders_from_nobility'].lower())
                alternate = ActionInstance(orders, (problem.environment.expression_manager.ObjectExp(badger),))
                alternative_state = sim.apply(state, alternate)
                actor_witness = {'instance': str(alternate), 'applicable': sim.is_applicable(state, alternate),
                    'badger_performing_before': state.get_value(predicate('ACCO', 'performing_show')(badger)).bool_constant_value(),
                    'badger_wealthy_after': alternative_state.get_value(predicate('ACCO', 'wealthy')(badger)).bool_constant_value()
                    if alternative_state is not None else None,
                    'scope': 'One-step semantic-risk witness after the real prefix; not an additional original-goal success'}
    # Replacing the unused sponsor still yields an independently valid goal plan.
    alternate_plan = list(plan.actions)
    sponsor_step = next(i for i, a in enumerate(plan.actions) if source_actions[a.action.name.lower()][1] == 'arrange_exhibition')
    action = alternate_plan[sponsor_step]
    alternate_plan[sponsor_step] = ActionInstance(action.action,
        (problem.environment.expression_manager.ObjectExp(hero), *action.actual_parameters[1:]))
    witness_dir = output / 'unused_sponsor_witness'
    witness_dir.mkdir()
    for name in ('domain.pddl', 'problem.pddl'):
        (witness_dir / name).write_bytes((original / name).read_bytes())
    PDDLWriter(problem).write_plan(SequentialPlan(alternate_plan), str(witness_dir / 'plan.txt'))
    sponsor_witness = validate_artifacts(witness_dir)
    selected_spec, certificate = select_component(meta, parse_domain(original / 'domain.pddl'),
        parse_sexpr((original / 'problem.pddl').read_text(encoding='utf-8')), 'ACCO')
    save(output / 'selection_certificate.json', certificate)
    if certificate['selected_sources'] != ['ACCO', 'BIRT']:
        raise ValueError('Selector incorrectly dropped the bridge source')
    sources = sorted({r['source'] for r in trace})
    result = {'status': 'complete', 'task_count': 5, 'rows': report['rows'],
        'status_counts': dict(Counter(r['status'] for r in report['rows'])),
        'budget': solver_manifest['budget'], 'primary_problem_bytes_identical': True,
        'native_single_source_goal_test': False, 'single_source_control': 'Common vocabulary/world/goal; only source action availability changes',
        'initial_trace_state': initial, 'trace': trace, 'plan_sources': sources,
        'original_plan_validation': validate_artifacts(original), 'unused_sponsor_witness': sponsor_witness,
        'global_reputation_actor_witness': actor_witness, 'selector_keeps_both_sources': True,
        'semantic_review': [
            {'action': 'BIRT:turn_key_on_beech', 'risk': 'Only at is required; key possession and beech identity are not checked. Any item-typed argument becomes possessed. Door/dryad side effects also occur.', 'status': 'author_code_review_risk_not_independent_label'},
            {'action': 'ACCO:arrange_exhibition', 'risk': 'Sponsor parameter is unused; any held item can support an exhibition.', 'status': 'author_code_review_risk_not_independent_label'},
            {'action': 'ACCO:perform_show', 'risk': 'Requires exhibition_ready and possession, but does not encode suitability of the item or audience; sets global reputation.', 'status': 'author_code_review_risk_not_independent_label'},
            {'action': 'ACCO:receive_orders_from_nobility', 'risk': 'Global reputation permits any ACCO entity to become wealthy, including an entity that did not perform.', 'status': 'author_code_review_risk_not_independent_label'}],
        'source_model_repaired': False, 'independent_semantic_labels': 0,
        'interpretation': 'Authored interface and explicit shared identities enable an executable cross-source causal chain under these source models. Narrative plausibility and automatically inferred interface correctness remain unestablished.',
        'frozen_sha256': frozen, 'hashes_unchanged': all(sha(Path(p)) == h for p, h in frozen.items())}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--case', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = run(args.case, args.output)
    print(json.dumps({k: result[k] for k in ['status', 'status_counts', 'plan_sources', 'selector_keeps_both_sources', 'hashes_unchanged']}, indent=2))

"""Audit real transport merges, exact source-plan transport and cross controls."""
import argparse
from collections import Counter
import copy
import json
from pathlib import Path
import shutil

from unified_planning.io import PDDLReader, PDDLWriter
from unified_planning.plans import ActionInstance, SequentialPlan
from unified_planning.shortcuts import SequentialSimulator

from rcnc.bidirectional_replay import atom_projection
from rcnc.conditional_merge import canonical_action, certify_replacement, fields
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.pddl import parse_domain, parse_sexpr, section, serialize, typed_symbols
from rcnc.validation import validate_artifacts
from scripts.audit.audit_semantic_facets_comparison import verify_model
from scripts.experiments.prepare_casefold_followup import casefold_ast
from scripts.experiments.run_transport_merge import CONDITIONS, SOURCES, check_freeze


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def transport(source, native_dir, target_dir, model, mapping, output):
    """One-way transport with full object and parameter maps, including false atoms."""
    reader = PDDLReader()
    native = reader.parse_problem(str(native_dir / 'domain.pddl'), str(native_dir / 'problem.pddl'))
    target = reader.parse_problem(str(target_dir / 'domain.pddl'), str(target_dir / 'problem.pddl'))
    meta = read(model / 'meta_domain.json')
    fold = lambda d: {k.lower(): v.lower() for k, v in d.items()}
    objects = fold({**meta['constant_maps'][source], **mapping['objects']})
    actions = fold(meta['action_maps'][source])
    predicates = fold(meta['predicate_maps'][source])
    orders = {k.lower(): v for k, v in meta['predicate_orders'][source].items()}
    parameters = {k.lower(): v for k, v in meta['action_parameter_maps'][source].items()}
    pairs = atom_projection(native, target, predicates, objects, orders, 200000)
    plan = reader.parse_plan(native, str(native_dir / 'plan.txt'))
    mapped, uses = [], Counter()
    for action in plan.actions:
        old_args = [target.object(objects[p.object().name]) for p in action.actual_parameters]
        permutation = parameters[action.action.name]
        if sorted(permutation) != list(range(len(old_args))):
            raise ValueError('Incomplete action parameter bijection')
        args = [None] * len(old_args)
        for old_index, new_index in enumerate(permutation):
            args[new_index] = old_args[old_index]
        name = actions[action.action.name]
        mapped.append(ActionInstance(target.action(name), tuple(args)))
        if len(meta['action_origins'][name]) > 1:
            uses[action.action.name] += 1
    output.mkdir(parents=True)
    for name in ('domain.pddl', 'problem.pddl'):
        shutil.copyfile(target_dir / name, output / name)
    mapped = SequentialPlan(mapped)
    PDDLWriter(target).write_plan(mapped, str(output / 'plan.txt'))
    verdict = validate_artifacts(output)
    if verdict['status'] != 'VALID':
        raise ValueError('Mapped plan invalid: ' + str(verdict))
    checks = 0
    with SequentialSimulator(native) as left, SequentialSimulator(target) as right:
        a, b = left.get_initial_state(), right.get_initial_state()
        for step in range(len(plan.actions) + 1):
            for translated, original in pairs.items():
                if a.get_value(original) != b.get_value(translated):
                    raise ValueError(f'Complete source truth differs at step {step}: {original}')
            checks += len(pairs)
            if step < len(plan.actions):
                x, y = plan.actions[step], mapped.actions[step]
                if not left.is_applicable(a, x.action, x.actual_parameters) or not right.is_applicable(b, y.action, y.actual_parameters):
                    raise ValueError('Transported applicability differs')
                a, b = left.apply(a, x.action, x.actual_parameters), right.apply(b, y.action, y.actual_parameters)
        if not left.is_goal(a) or not right.is_goal(b):
            raise ValueError('Source or target goal not achieved')
    return {'status': 'PASS', 'steps': len(plan.actions), 'source_atoms': len(pairs),
            'states': len(plan.actions) + 1, 'truth_checks': checks, 'merged_source_calls': dict(uses),
            'validation': verdict, 'full_source_projection_equal': True}


def adapt_witness(directory, output):
    """Bijectively rename witness objects in new copies, preserving raw failure.

    UP confuses truck/city/driver objects with predicates in these authored
    witnesses. The separate posthoc adapter changes object identifiers only;
    it is not an edit to original benchmark problems or frozen model inputs.
    """
    strict = validate_artifacts(directory)
    original = parse_sexpr((directory / 'problem.pddl').read_text(encoding='utf-8'))
    names = typed_symbols(section(original, ':objects')[1:])
    renaming = {n: 'witness__' + n for n in names}
    def rewrite(tree, table):
        def expression(value):
            return [value[0], *[expression(x) if isinstance(x, list) else table.get(x, x) for x in value[1:]]]
        tree = copy.deepcopy(tree)
        declarations = section(tree, ':objects')
        declarations[1:] = [table.get(x, x) for x in declarations[1:]]
        initial = section(tree, ':init')
        initial[1:] = [expression(f) for f in initial[1:]]
        goal = section(tree, ':goal')
        goal[1] = expression(goal[1])
        return tree
    adapted = rewrite(original, renaming)
    inverse = {v: k for k, v in renaming.items()}
    if len(inverse) != len(names) or rewrite(adapted, inverse) != original:
        raise ValueError('Witness object renaming is not reversible')
    calls = [parse_sexpr(line) for line in (directory / 'plan.txt').read_text(encoding='utf-8').splitlines() if line.strip()]
    renamed_calls = [[a[0], *[renaming[x] for x in a[1:]]] for a in calls]
    if [[a[0], *[inverse[x] for x in a[1:]]] for a in renamed_calls] != calls:
        raise ValueError('Witness plan renaming is not reversible')
    output.mkdir(parents=True)
    shutil.copyfile(directory / 'domain.pddl', output / 'domain.pddl')
    (output / 'problem.pddl').write_text(serialize(adapted) + '\n', encoding='utf-8')
    (output / 'plan.txt').write_text('\n'.join('(' + ' '.join(a) + ')' for a in renamed_calls) + '\n', encoding='utf-8')
    return {'strict_default': strict, 'adapted_validation': validate_artifacts(output),
            'object_renaming': renaming, 'roundtrip_exact': True,
            'policy': 'Separate posthoc object-name adapter; original frozen witness and error retained; zero new planner/model calls.'}


def trace(directory, meta):
    path = directory / 'plan.txt'
    if not path.exists():
        return []
    result = []
    for line in path.read_text(encoding='utf-8').splitlines():
        line = line.split(';')[0].strip()
        if not line:
            continue
        call = parse_sexpr(line)
        result.append({'action': call[0], 'arguments': call[1:],
                       'possible_origins': meta['action_origins'][call[0]]})
    return result


def audit(root, output):
    require_empty_output(output)
    output.mkdir(parents=True)
    check_freeze(root)
    manifest, report, protocol = read(root / 'manifest.json'), read(root / 'report.json'), read(root / 'protocol.json')
    if report['status'] != 'complete' or report['manifest_sha256'] != digest(root / 'manifest.json'):
        raise ValueError('Incomplete or changed run')
    for key in ('inputs_unchanged', 'implementation_unchanged', 'solver_integrity'):
        if report[key] is not True:
            raise ValueError('Runtime integrity failed: ' + key)
    for path, value in manifest['input_sha256'].items():
        if digest(Path(path)) != value:
            raise ValueError('Frozen input changed: ' + path)
    if len(report['rows']) != protocol['solver_tasks'] or [r['id'] for r in report['rows']] != [r['id'] for r in manifest['rows']]:
        raise ValueError('Task denominator differs')
    model_report = verify_model(root)
    normalization = read(root / 'normalization.json')['rows']
    for row in normalization:
        raw, normalized = Path(row['original']), Path(row['normalized'])
        if digest(raw) != row['original_sha256'] or digest(normalized) != row['normalized_sha256']:
            raise ValueError('Normalization bytes changed')
        if casefold_ast(parse_sexpr(raw.read_text(encoding='utf-8'))) != parse_sexpr(normalized.read_text(encoding='utf-8')):
            raise ValueError('Adapter changed more than identifier case')
    validations, replays, violations, witness_checks = [], [], [], []
    indexed = {r['id']: r for r in report['rows']}
    for row in report['rows']:
        directory = root / 'solver/tasks' / row['id']
        if row['status'] == 'solved':
            verdict = validate_artifacts(directory)
            validations.append({'id': row['id'], **verdict})
            if verdict['status'] != 'VALID':
                violations.append('invalid solved plan: ' + row['id'])
    for unit, cases in [('original', protocol['originals']),
                        ('authored_witness', [{'id': s, 'source': s} for s in SOURCES])]:
        for case in cases:
            source = case['source']
            native = root / 'solver/tasks' / (case['id'] + '__native') if unit == 'original' else root / 'witnesses' / source / 'native'
            available = indexed[case['id'] + '__native']['status'] == 'solved' if unit == 'original' else True
            if unit == 'authored_witness':
                adapted = output / 'adapted_witnesses' / source
                witness_check = {'source': source, **adapt_witness(native, adapted)}
                witness_checks.append(witness_check)
                if witness_check['adapted_validation']['status'] != 'VALID':
                    raise ValueError('Authored native witness invalid after reversible object renaming')
                native = adapted
            for condition in CONDITIONS:
                row = {'id': unit + '/' + case['id'] + '/' + condition, 'unit': unit, 'source': source, 'condition': condition}
                if not available:
                    row.update(status='unavailable_no_original_goal_plan')
                else:
                    folder = root / 'bundle/tasks' / (case['id'] + '__' + condition) if unit == 'original' else root / 'witnesses' / source / condition
                    try:
                        mapping = read(folder / 'query_mapping.json')
                        if unit == 'authored_witness':
                            mapping['objects'] = {witness_check['object_renaming'][k]: v for k, v in mapping['objects'].items()}
                        row.update(transport(source, native, folder, root / 'models' / condition,
                                             mapping, output / 'transports' / row['id']))
                    except Exception as exc:
                        row.update(status='FAIL', reason=f'{type(exc).__name__}: {exc}')
                        violations.append(row['id'])
                replays.append(row)
    merges, crosses, formal_only = [], [], []
    for condition in CONDITIONS:
        folder = root / 'models' / condition
        domain, meta, result = parse_domain(folder / 'meta_domain.pddl'), read(folder / 'meta_domain.json'), read(folder / 'validation.json')
        accepted = [d for d in result['decisions'] if d['kind'] == 'action' and d['status'] == 'accepted']
        for decision in accepted:
            target = decision['target']
            if target not in domain.actions or len(meta['action_origins'][target]) != 2:
                raise ValueError('Accepted action was not replaced by a two-origin schema')
            for reference in decision['members']:
                source, action = reference.split(':')
                if meta['action_maps'][source][action] != target:
                    raise ValueError('Actual action map differs from decision')
        merges.append({'condition': condition, 'source_actions': result['source_actions'], 'actions': len(domain.actions),
            'source_predicates': result['source_predicates'], 'logical_predicates': len(domain.predicates) - len(meta['type_guards']),
            'membership_predicates': len(meta['type_guards']), 'accepted_action_groups': [a['id'] for a in accepted],
            'drive_actions_separate': meta['action_maps']['LOG98']['drive-truck'] != meta['action_maps']['DLOG']['drive-truck'],
            'decisions': result['decisions']})
    for suffix in ('090', '080'):
        full, pred = 'full' + suffix, 'predicate' + suffix
        meta = read(root / 'models' / full / 'meta_domain.json')
        domain = parse_domain(root / 'models' / pred / 'meta_domain.pddl')
        pm = read(root / 'models' / pred / 'meta_domain.json')
        originals = [canonical_action(domain.actions[pm['action_maps'][s]['drive-truck']], [0, 1, 2, 3]) for s in SOURCES]
        unsafe = copy.deepcopy(originals[0])
        unsafe[unsafe.index(':precondition') + 1] = ['or', *[fields(a)[':precondition'] for a in originals]]
        formal_only.append({'condition': pred, 'candidate': 'identity-role drive merge with city/driver collapsed',
                            'certificate': certify_replacement(originals, unsafe), 'deployed': False})
        for case in protocol['queries']:
            conditions = ['no_share', pred, full, *['remove_' + s + suffix for s in SOURCES]]
            statuses = {c: indexed[case + '__' + c]['status'] for c in conditions}
            steps = trace(root / 'solver/tasks' / (case + '__' + full), meta)
            crosses.append({'id': case + '/' + suffix, 'case': case, 'threshold': float('.' + suffix[1:]),
                'statuses': statuses, 'plan_steps': steps, 'plan_length': len(steps) if statuses[full] == 'solved' else None,
                'uses_merged_action': any(len(s['possible_origins']) > 1 for s in steps),
                'benefit_over_no_share': statuses[full] == 'solved' and statuses['no_share'] == 'unsolvable',
                'both_sources_necessary': statuses[full] == 'solved' and all(statuses['remove_' + s + suffix] == 'unsolvable' for s in SOURCES),
                'predicate_only_already_solves': statuses[pred] == 'solved'})
    result = {'status': 'verified' if not violations else 'audit_failed', 'integrity_verified': True,
        'raw_predictions_verified': True, 'case_only_records_verified': len(normalization),
        'model_calls': model_report['requests_attempted'], 'model_status_counts': model_report['status_counts'],
        'model_decisions': [{'id': r['id'], 'status': r['status'], 'response': r.get('response'), 'facets': r.get('semantic_facets')} for r in model_report['rows']],
        'task_count': len(report['rows']), 'planner_calls': report['actual_solver_calls'], 'solver_status_counts': report['status_counts'],
        'returned_plans': validations, 'replay_count': len(replays), 'rows': replays,
        'witness_parser_diagnostics': witness_checks,
        'replay_status_counts': dict(Counter(r['status'] for r in replays)),
        'replay_by_unit': {u: dict(Counter(r['status'] for r in replays if r['unit'] == u)) for u in ('original', 'authored_witness')},
        'replayed_steps': sum(r.get('steps', 0) for r in replays), 'truth_checks': sum(r.get('truth_checks', 0) for r in replays),
        'merges': merges, 'cross_source': crosses, 'formal_only_drive_diagnostic': formal_only, 'violations': violations,
        'parent_reports': {str(p): digest(p) for p in (root / 'report.json', root / 'judgments/report.json', root / 'manifest.json', root / 'pre_model_freeze.json')},
        'scope': protocol['scope'] + ' Threshold views reuse five predictions and the same three cross tasks; not six independent cross tasks. Predicate sharing and action compression have distinct causal roles. Two authored witnesses require a separate posthoc reversible object-name adapter, retained alongside their strict-parser failures and separately from the 20 original-goal transports. No original problem edits or additional planner calls.'}
    result['implementation_sha256'] = snapshot_implementation(output, [Path(__file__), Path('rcnc/bidirectional_replay.py'),
        Path('scripts/audit/audit_semantic_facets_comparison.py'), Path('rcnc/validation.py')])
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--root', required=True, type=Path)
    p.add_argument('--output', required=True, type=Path)
    args = p.parse_args()
    r = audit(args.root, args.output)
    print(json.dumps({k: r[k] for k in ('status', 'model_calls', 'planner_calls', 'replay_by_unit', 'replayed_steps', 'truth_checks', 'violations')}, indent=2))

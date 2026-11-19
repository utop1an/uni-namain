"""Audit the frozen action-policy contrast and mechanically validate its traces."""
import argparse
from collections import Counter
import copy
import json
from pathlib import Path
import shutil

from rcnc.domain_building import archived_implementation, digest, require_empty_output, save, snapshot_implementation
from rcnc.namespace_export import transform
from rcnc.pddl import parse_sexpr, section, serialize, typed_symbols
from rcnc.source_action_variants import ast, fields, literals
from rcnc.validation import validate_artifacts
from scripts.experiments.run_downward_reference import linux_path


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def expected_registry(protocol):
    expected = []
    for index, source in enumerate(protocol['sources']):
        choices = protocol['original_conditions']
        for c in choices[index:] + choices[:index]: expected.append((source + '__' + c, source, c, 'original_goal'))
    for index, probe in enumerate(protocol['probes']):
        choices = protocol['probe_conditions']
        for c in choices[index:] + choices[:index]: expected.append((probe['id'] + '__' + c, probe['id'], c, 'authored_probe'))
    return expected


def check_registry(protocol, manifest, report):
    expected = expected_registry(protocol)
    if len(expected) != protocol['budget']['maximum_solver_calls']: raise ValueError('Protocol denominator differs')
    for records, count in [(manifest['slots'], manifest['task_count']), (report['rows'], report['task_count'])]:
        if count != len(expected) or [(r['id'], r['case'], r['condition'], r['unit']) for r in records] != expected:
            raise ValueError('Missing, duplicate, reordered or changed slots')
    if report['status_counts'] != dict(Counter(r['status'] for r in report['rows'])):
        raise ValueError('Summary counts differ from rows')
    ready = sum(r['admission_status'] == 'ready' for r in manifest['slots'])
    if report['actual_solver_calls'] != ready: raise ValueError('Actual call denominator differs')
    for slot, row in zip(manifest['slots'], report['rows']):
        if any(row.get(k) != v for k, v in slot.items()): raise ValueError('Result identity differs')
        if slot['admission_status'] != 'ready' and row['status'] != slot['admission_status']:
            raise ValueError('Unavailable slot promoted')


def grounded_trace(directory, ownership):
    """Independent exact STRIPS replay and last-establishing-writer evidence."""
    domain, problem = ast(directory / 'domain.pddl'), ast(directory / 'problem.pddl')
    actions = {a[1]: a for a in domain[1:] if a[0] == ':action'}
    state = {atom for expr in section(problem, ':init')[1:] for positive, atom in literals(expr) if positive}
    writers, dependencies, steps = {}, [], []
    for line in (directory / 'plan.txt').read_text(encoding='utf-8').splitlines():
        line = line.split(';', 1)[0].strip().lower()
        if not line: continue
        call = parse_sexpr(line)
        action = actions[call[0]]; data = fields(action)
        parameters = list(typed_symbols(data[':parameters']))
        if len(parameters) != len(call) - 1: raise ValueError('Truncated or extended plan arguments')
        substitutions = dict(zip(parameters, call[1:]))
        grounded = lambda expr: [(p, tuple(substitutions.get(t, t) for t in atom)) for p, atom in literals(expr)]
        owner = ownership[call[0]]
        step = len(steps) + 1
        for positive, atom in grounded(data[':precondition']):
            if (atom in state) != positive: raise ValueError('STRIPS replay precondition failed')
            writer = writers.get(atom)
            if positive and writer and writer['source'] != owner['source']:
                dependencies.append({'consumer_step': step, 'consumer_source': owner['source'], 'consumer_action': call[0],
                                     'atom': list(atom), 'producer': writer})
        effects = grounded(data[':effect'])
        deleted = {a for p, a in effects if not p}; added = {a for p, a in effects if p}
        for atom in deleted: writers.pop(atom, None)
        for atom in added:
            if atom not in state or atom in deleted:
                writers[atom] = {'step': step, 'source': owner['source'], 'action': call[0]}
        state = (state - deleted) | added
        steps.append({'step': step, 'source': owner['source'], 'source_action': owner['source_action'],
                      'action': call[0], 'arguments': call[1:]})
    if any((atom in state) != positive for positive, atom in literals(section(problem, ':goal')[1])):
        raise ValueError('STRIPS replay final goal failed')
    return {'status': 'verified_strips_trace', 'steps': steps, 'source_counts': dict(Counter(s['source'] for s in steps)),
            'cross_source_dependencies': dependencies,
            'birt_to_acco_has': [d for d in dependencies if d['consumer_source'] == 'ACCO'
                and d['producer']['source'] == 'BIRT' and d['atom'][0] == 'pred__has']}


def audit(root, output):
    require_empty_output(output)
    protocol, manifest, report = [read(root / p) for p in ('protocol.json', 'manifest.json', 'report.json')]
    if report['status'] != 'complete' or report['manifest_sha256'] != digest(root / 'manifest.json'):
        raise ValueError('Matching completed experiment required')
    for key in ('inputs_unchanged', 'implementation_unchanged', 'planner_unchanged', 'solver_integrity'):
        if report.get(key) is not True: raise ValueError('Runtime integrity failed: ' + key)
    check_registry(protocol, manifest, report)
    if manifest['budget'] != protocol['budget']: raise ValueError('Budget drift')
    for name, h in manifest['input_sha256'].items():
        if digest(root / name) != h: raise ValueError('Frozen input changed: ' + name)
    for name, h in manifest['implementation_sha256'].items():
        if digest(archived_implementation(root, name)) != h: raise ValueError('Archived implementation changed')
    for name, h in protocol['parent_sha256'].items():
        if digest(root / 'parent' / name) != h or digest(Path(protocol['parent']) / name) != h:
            raise ValueError('Historical parent differs')
    solver, sm = read(root / 'solver/report.json'), read(root / 'solver/manifest.json')
    expected_budget = {'wall_seconds': protocol['budget']['seconds_wall_and_cpu'],
                       'overall_cpu_seconds': protocol['budget']['seconds_wall_and_cpu'], 'memory_mb': protocol['budget']['memory_mb']}
    ready = [r['id'] for r in manifest['slots'] if r['admission_status'] == 'ready']
    if solver['status'] != 'complete' or [r['id'] for r in solver['rows']] != ready or sm['budget'] != expected_budget:
        raise ValueError('Actual solver matrix or budgets differ')
    if solver['manifest_sha256'] != digest(root / 'solver/manifest.json') or sm['task_count'] != len(ready):
        raise ValueError('Solver manifest differs')
    for key in ('binary_unchanged', 'runner_unchanged', 'implementation_unchanged', 'validator_unchanged'):
        if solver.get(key) is not True: raise ValueError('Actual solver integrity missing')
    actual = {r['id']: r for r in solver['rows']}
    output.mkdir(parents=True)
    source_roots = {s: ast(root / 'parent/inputs' / (s + '_domainfile.pddl')) for s in protocol['sources']}
    model_metadata, action_checks = {}, []
    for condition in sorted({r['condition'] for r in manifest['slots'] if r['condition'].startswith('variants_')}):
        if manifest['model_admissions'][condition]['status'] != 'ready': continue
        folder = root / 'models' / condition
        meta = read(folder / 'metadata.json'); model_metadata[condition] = meta
        domain = folder / ('domain.pddl' if 'remove_' in condition else 'planning/domain.pddl')
        compiled = ast(domain)
        actions = {a[1]: a for a in compiled[1:] if a[0] == ':action'}
        wanted = {}
        for source, original in source_roots.items():
            if source == meta.get('removed_source'): continue
            mapping = meta['source_maps'][source]
            for action in [p for p in original[1:] if p[0] == ':action']:
                mapped = transform(['define', section(original, 'domain'), action], mapping)[2]
                wanted[mapped[1]] = mapped
        if actions != wanted or set(actions) != set(meta['action_ownership']):
            raise ValueError('Source action omitted, changed or invented')
        if condition.startswith('variants_remove_'):
            parent_header = [p for p in ast(root / 'models/variants_all/planning/domain.pddl')[1:] if p[0] != ':action']
            if [p for p in compiled[1:] if p[0] != ':action'] != parent_header: raise ValueError('Removal changed universe')
        action_checks.append({'condition': condition, 'complete_mapped_actions': len(actions), 'all_equal': True})
    plan_checks, pins = [], {}
    for row in report['rows']:
        if row['admission_status'] != 'ready':
            plan_checks.append({'id': row['id'], 'validation': {'status': 'NO_PLAN'}}); continue
        child = actual[row['id']]
        if row['status'] != child['status'] or child.get('inputs_unchanged') is not True:
            raise ValueError('Child result mismatch')
        directory = root / 'solver/tasks' / row['id']
        frozen = root / 'bundle/tasks' / row['id']
        for kind in ('domain', 'problem'):
            if digest(directory / (kind + '.pddl')) != row[kind + '_sha256'] or digest(frozen / (kind + '.pddl')) != row[kind + '_sha256']:
                raise ValueError('Actual task differs from frozen task')
        command = read(directory / 'command.json')
        flags = {'--cd': linux_path(directory), '--alias': 'lama-first', '--plan-file': 'plan.txt',
                 '--overall-time-limit': str(expected_budget['wall_seconds']) + 's',
                 '--overall-memory-limit': str(expected_budget['memory_mb']) + 'M'}
        if any(command.count(k) != 1 or command[command.index(k) + 1] != v for k, v in flags.items()):
            raise ValueError('Actual solver command changed')
        if command[-2:] != ['domain.pddl', 'problem.pddl'] or command[command.index('timeout'):command.index('timeout') + 4] != ['timeout', '--signal=TERM', '--kill-after=5', str(expected_budget['wall_seconds'])]:
            raise ValueError('Actual process deadline or inputs differ')
        if row['condition'] == 'native':
            for kind in ('domain', 'problem'):
                if (directory / (kind + '.pddl')).read_bytes() != (root / 'parent/inputs' / (row['source'] + '_' + kind + 'file.pddl')).read_bytes():
                    raise ValueError('Native task changed')
        else:
            condition = row['condition']
            model = (root / 'parent/fusion/planning_export/domain.pddl') if condition == 'rewrite' else root / 'models' / condition / ('domain.pddl' if 'remove_' in condition else 'planning/domain.pddl')
            if digest(model) != row['domain_sha256']: raise ValueError('Task-specific model replacement')
            if condition != 'rewrite':
                mapping = model_metadata[condition]['source_maps'][row['source']]
                expected = transform(ast(root / 'parent/inputs' / (row['source'] + '_problemfile.pddl')), mapping, problem=True)
                if row['unit'] == 'authored_probe':
                    probe = next(p for p in protocol['probes'] if p['id'] == row['case'])
                    additions = [[model_metadata[condition]['source_maps'][s]['predicates'][p], *[mapping['objects'][a] for a in args]] for s, p, args in probe['goals']]
                    goal = section(expected, ':goal'); old = copy.deepcopy(goal[1])
                    goal[1] = ['and', *([old] if probe['retain_original_goal'] else []), *additions]
                if ast(directory / 'problem.pddl') != expected: raise ValueError('Initial state, objects or goal changed')
        entry = {'id': row['id'], 'validation': {'status': 'NO_PLAN'}}
        if (directory / 'plan.txt').exists():
            dest = output / 'plans' / row['id']; dest.mkdir(parents=True)
            for name in ('domain.pddl', 'problem.pddl', 'plan.txt'):
                shutil.copyfile(directory / name, dest / name); pins[str(directory / name)] = digest(directory / name)
            entry['validation'] = validate_artifacts(dest)
            if entry['validation']['status'] == 'VALID' and row['condition'].startswith('variants_'):
                entry['trace'] = grounded_trace(dest, model_metadata[row['condition']]['action_ownership'])
        if row['status'] == 'solved' and entry['validation']['status'] != 'VALID': raise ValueError('Claimed plan failed revalidation')
        plan_checks.append(entry)
    for case in [*protocol['sources'], *[p['id'] for p in protocol['probes']]]:
        pair = [r for r in report['rows'] if r['case'] == case and r['condition'] in ('rewrite', 'variants_all')]
        if all(r['admission_status'] == 'ready' for r in pair) and len(pair) == 2:
            if pair[0]['problem_sha256'] != pair[1]['problem_sha256']: raise ValueError('Unmatched action-policy world')
    native_replays = []
    for source in protocol['sources']:
        native = output / 'native_validation' / source; native.mkdir(parents=True)
        for kind in ('domain', 'problem'): shutil.copyfile(root / 'parent/inputs' / (source + '_' + kind + 'file.pddl'), native / (kind + '.pddl'))
        plan = root / 'native_plans' / (source + '.plan')
        if digest(plan) != protocol['prior_plan_sha256'][source]: raise ValueError('Historical native plan differs')
        shutil.copyfile(plan, native / 'plan.txt')
        if validate_artifacts(native)['status'] != 'VALID': raise ValueError('Historical native plan no longer validates')
        for condition, meta in model_metadata.items():
            if meta.get('removed_source') == source: continue
            dest = output / 'native_replays' / (source + '__' + condition); dest.mkdir(parents=True)
            model = root / 'models' / condition / ('domain.pddl' if 'remove_' in condition else 'planning/domain.pddl')
            shutil.copyfile(model, dest / 'domain.pddl')
            mapping = meta['source_maps'][source]
            problem = transform(ast(native / 'problem.pddl'), mapping, problem=True)
            (dest / 'problem.pddl').write_text(serialize(problem) + '\n', encoding='utf-8')
            translated = []
            for line in plan.read_text(encoding='utf-8').splitlines():
                line = line.split(';', 1)[0].strip().lower()
                if not line: continue
                call = parse_sexpr(line)
                translated.append(serialize([mapping['actions'][call[0]], *[mapping['objects'][a] for a in call[1:]]]))
            (dest / 'plan.txt').write_text('\n'.join(translated) + '\n', encoding='utf-8')
            verdict = validate_artifacts(dest)
            if verdict['status'] != 'VALID': raise ValueError('Original source plan lost in variants')
            trace = grounded_trace(dest, meta['action_ownership'])
            native_replays.append({'source': source, 'condition': condition, 'validation': verdict['status'], 'steps': len(trace['steps'])})
    rows = {r['id']: r for r in report['rows']}; checks = {r['id']: r for r in plan_checks}
    benefits = []
    for probe in protocol['probes']:
        prefix = probe['id'] + '__'
        outcome = {c: rows[prefix + c]['status'] for c in protocol['probe_conditions']}
        primary = protocol.get('benefit_condition', 'variants_all')
        trace = checks[prefix + primary].get('trace', {})
        proven = (outcome[primary] == 'solved' and all(outcome[c] == 'unsolvable' for c in
                  ('variants_no_share', 'variants_without_has', 'variants_remove_ACCO', 'variants_remove_BIRT'))
                  and bool(trace.get('birt_to_acco_has')))
        benefits.append({'case': probe['id'], 'primary_condition': primary, 'outcomes': outcome, 'mechanical_cross_source_benefit_verified': proven,
                         'birt_to_acco_has_dependencies': trace.get('birt_to_acco_has', [])})
    result = {'status': 'verified_action_policy_comparison', 'task_count': len(report['rows']),
        'actual_solver_calls': report['actual_solver_calls'], 'status_counts': report['status_counts'],
        'by_unit_condition': report['by_unit_condition'], 'action_checks': action_checks, 'plans': plan_checks,
        'plan_validation_counts': dict(Counter(p['validation']['status'] for p in plan_checks)),
        'native_replays': native_replays, 'authored_probe_results': benefits,
        'mechanical_benefit_cases': sum(b['mechanical_cross_source_benefit_verified'] for b in benefits),
        'source_plan_artifacts_unchanged': all(digest(Path(p)) == h for p, h in pins.items()),
        'manifest_sha256': digest(root / 'manifest.json'), 'experiment_sha256': digest(root / 'report.json'),
        'model_calls': 0, 'independent_semantic_labels': 0, 'scope': protocol['outcome_boundary']}
    snapshot_implementation(output, [Path(__file__), Path('rcnc/source_action_variants.py'),
        Path('rcnc/namespace_export.py'), Path('rcnc/validation.py'), Path('rcnc/pddl.py'), Path('rcnc/domain_building.py')])
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = audit(args.run, args.output)
    print(json.dumps({k: result[k] for k in ('status', 'task_count', 'actual_solver_calls', 'plan_validation_counts', 'mechanical_benefit_cases')}, indent=2))

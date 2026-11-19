"""Audit all paired slots and revalidate every saved plan without new search."""
import argparse
from collections import Counter
import json
from pathlib import Path
import shutil

from unified_planning.io import PDDLReader

from rcnc.domain_building import archived_implementation, digest, require_empty_output, save, snapshot_implementation
from rcnc.validation import validate_artifacts
from scripts.audit.export_namespace_diagnostic import candidate_path


VARIANTS = ('cartesian_projection', 'positive_tuple_join')
STRATEGIES = {'correlated_parameter_tuples':VARIANTS,
              'precondition_witness_representatives':('cartesian_projection', 'precondition_witness')}


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def expected_inputs(protocol):
    expected = {}
    for cohort in protocol['cohorts']:
        origin = Path(cohort['path'])
        if digest(origin / 'manifest.json') != cohort['manifest_sha256']:
            raise ValueError('Original input registry changed')
        manifest = read(origin / 'manifest.json')
        for task in manifest.get('conditions', manifest.get('tasks')):
            if task['condition'] not in cohort['conditions'] or task.get('admission_status', 'ready') != 'ready':
                continue
            identifier = cohort['name'] + '__' + task['id']
            if identifier in expected: raise ValueError('Duplicate original input')
            expected[identifier] = {'origin': origin, 'task': task, 'cohort': cohort['name']}
    if len(expected) != 24 or len({r['task']['pair_id'] for r in expected.values()}) != 6:
        raise ValueError('Expected complete24-input/six-world original cohort')
    if any(sum(r['task']['pair_id'] == pair for r in expected.values()) != 4
           for pair in {r['task']['pair_id'] for r in expected.values()}):
        raise ValueError('Each original world requires four conditions')
    return expected


def audit(root, output):
    require_empty_output(output)
    manifest, report, protocol = [read(root / name) for name in ('manifest.json', 'report.json', 'protocol.json')]
    field = protocol.get('strategy_field', 'correlated_parameter_tuples')
    if field not in STRATEGIES: raise ValueError('Unknown registered binding strategy')
    variants = STRATEGIES[field]
    if (field in protocol['budget']['search']
            or protocol['budget']['search'].get('inert_parameter_representatives', False)
            or any(protocol['budget']['search'].get(other, False) for other in STRATEGIES if other != field)):
        raise ValueError('More than the registered strategy switch changed')
    if report['status'] != 'complete' or report['manifest_sha256'] != digest(root / 'manifest.json'):
        raise ValueError('Matching complete terminal report required')
    if (manifest['protocol_sha256'] != digest(root / 'protocol.json') or manifest['budget'] != protocol['budget']
            or protocol['variants'] != list(variants) or manifest['variants'] != list(variants)
            or manifest.get('strategy_field', 'correlated_parameter_tuples') != field
            or report.get('strategy_field', 'correlated_parameter_tuples') != field
            or any(report.get(k) is not True for k in ('inputs_unchanged', 'implementation_unchanged'))):
        raise ValueError('Protocol, strategy or runtime integrity differs')
    for name, expected in manifest['implementation_sha256'].items():
        if digest(archived_implementation(root, name)) != expected:
            raise ValueError('Archived implementation differs')
    inputs = expected_inputs(protocol)
    expected = {}
    for index, (identifier, original) in enumerate(inputs.items()):
        order = variants if index % 2 == 0 else variants[::-1]
        for variant in order:
            expected[identifier + '__' + variant] = {**original, 'input_id': identifier, 'variant': variant}
    tasks = {r['id']:r for r in manifest['tasks']}
    rows = {r['id']:r for r in report['rows']}
    if (len(tasks) != len(manifest['tasks']) or len(rows) != len(report['rows'])
            or list(expected) != list(tasks) or list(expected) != list(rows)
            or manifest['task_count'] != 48 or report['task_count'] != 48
            or report['world_count'] != 6 or report['unique_pddl_inputs'] != 24):
        raise ValueError('Incomplete, duplicate or reordered48-slot denominator')
    counts = dict(Counter(r['status'] for r in rows.values()))
    by_variant = {v:dict(Counter(r['status'] for r in rows.values() if r['variant'] == v)) for v in variants}
    if counts != report['status_counts'] or by_variant != report['by_variant']:
        raise ValueError('Reported summary differs from complete rows')
    not_run = all(r['status'] == 'not_run_due_goal_budget' for r in rows.values())
    if report['actual_search_processes'] != (0 if not_run else 48) or (not not_run and any(r['status'] == 'not_run_due_goal_budget' for r in rows.values())):
        raise ValueError('Partial matrix cannot be reported as whole execution')
    output.mkdir(parents=True, exist_ok=True)
    checked, failures = [], []
    source_hashes = {}
    for identifier, original in expected.items():
        task, row = tasks[identifier], rows[identifier]
        predecessor = original['task']
        expected_fields = {'input_id':original['input_id'], 'variant':original['variant'],
            field:original['variant'] == variants[1],
            'pair_id':predecessor['pair_id'], 'condition':predecessor['condition'],
            'cohort':original['cohort'], 'origin_task':predecessor['id']}
        if any(task.get(k) != v or row.get(k) != v for k,v in expected_fields.items()):
            raise ValueError('Paired input/strategy identity differs')
        source = candidate_path(root / 'tasks', original['input_id'])
        actual = candidate_path(root / 'searches', identifier)
        for name in ('domain', 'problem'):
            wanted = predecessor[name + '_sha256']
            previous = candidate_path(original['origin'] / 'bundle/tasks', predecessor['id']) / (name + '.pddl')
            if (digest(source / (name + '.pddl')) != wanted or digest(previous) != wanted
                    or task[name + '_sha256'] != wanted or row[name + '_sha256'] != wanted):
                raise ValueError('Actual registered input differs from original')
            if (actual / (name + '.pddl')).exists() and digest(actual / (name + '.pddl')) != wanted:
                raise ValueError('Worker model/world differs from frozen input')
        result = {**row, 'fresh_validation': {'status':'NO_PLAN'}}
        if not not_run:
            command = read(actual / 'command.json')
            budget = json.loads(command[command.index('--budget') + 1])
            if budget != {**protocol['budget']['search'], field:expected_fields[field]}:
                raise ValueError('Actual worker strategy or search budget differs')
            for key, path in (('--domain', source / 'domain.pddl'), ('--problem', source / 'problem.pddl'), ('--output', actual)):
                if Path(command[command.index(key) + 1]).resolve() != path.resolve():
                    raise ValueError('Actual worker input/output path differs')
            if command[command.index('--solver') + 1] != 'state_projected':
                raise ValueError('Actual worker backend differs')
            if (actual / 'search.json').exists():
                search = read(actual / 'search.json')
                if any(row.get(k) != v for k,v in search.items()):
                    raise ValueError('Worker terminal result/report disagree')
            if 'last_progress' in row and read(actual / 'progress.json') != row['last_progress']:
                raise ValueError('Last progress differs from timeout receipt')
            result['stage_observation'] = 'progress_recorded' if (actual / 'progress.json').exists() else 'no_progress_recorded'
        plan = actual / 'plan.txt'
        if plan.exists():
            copied = output / 'plans' / identifier; copied.mkdir(parents=True)
            for name in ('domain.pddl', 'problem.pddl', 'plan.txt'):
                shutil.copyfile(actual / name, copied / name)
                source_hashes[str(actual / name)] = digest(actual / name)
            result['plan_sha256'] = digest(copied / 'plan.txt')
            result['fresh_validation'] = validate_artifacts(copied)
            try:
                reader = PDDLReader()
                parsed = reader.parse_problem(str(copied / 'domain.pddl'), str(copied / 'problem.pddl'))
                actions = reader.parse_plan(parsed, str(copied / 'plan.txt')).actions
                if any(len(a.actual_parameters) != len(a.action.parameters) for a in actions):
                    raise ValueError('Incomplete action arguments')
                result.update(plan_steps=len(actions), full_actual_parameters=sum(len(a.actual_parameters) for a in actions))
                if row['status'] == 'solved' and row.get('length') != len(actions):
                    failures.append({'id':identifier, 'reason':'reported plan length differs'})
            except Exception as exc:
                failures.append({'id':identifier, 'reason':f'full parameter audit failed: {type(exc).__name__}: {exc}'})
        elif row['status'] == 'solved':
            result['fresh_validation'] = {'status':'MISSING_PLAN'}
        if row['status'] == 'solved' and result['fresh_validation']['status'] != 'VALID':
            failures.append({'id':identifier, 'reason':'claimed solved plan did not revalidate'})
        checked.append(result)
    implementation = snapshot_implementation(output, [Path(__file__), Path('rcnc/domain_building.py'),
        Path('rcnc/validation.py'), Path('scripts/audit/export_namespace_diagnostic.py')])
    result = {'status':'verified_correlated_projection' if not failures else 'audited_with_violations',
        'task_count':48, 'world_count':6, 'unique_pddl_inputs':24, 'actual_search_processes':report['actual_search_processes'],
        'strategy_field':field,
        'rows':checked, 'status_counts':counts, 'by_variant':by_variant,
        'fresh_validation_counts':dict(Counter(r['fresh_validation']['status'] for r in checked)),
        'audit_failures':failures, 'original_statuses_preserved':True,
        'source_plan_artifacts_unchanged':all(digest(Path(n)) == h for n,h in source_hashes.items()),
        'manifest_sha256':digest(root / 'manifest.json'), 'report_sha256':digest(root / 'report.json'),
        'implementation_sha256':implementation, 'scope':manifest['scope']}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = audit(args.root, args.output)
    print(json.dumps({k:v for k,v in result.items() if k not in ('rows','implementation_sha256')}, indent=2))
    raise SystemExit(0 if result['status'] == 'verified_correlated_projection' else 1)

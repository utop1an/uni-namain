"""Verify original worlds/goals and transport available source-local API plans.

World checks start from the frozen source PDDL, not the producer's converted
query or its reported no-import flag. Replay is mechanical, never semantic gold.
"""
import argparse
from collections import Counter
import json
from pathlib import Path

from unified_planning.io import PDDLReader, PDDLWriter
from unified_planning.plans import ActionInstance, SequentialPlan
from rcnc.domain_building import require_empty_output, save, archived_implementation, planning_domain_path
from rcnc.pddl import parse_domain, parse_sexpr, section, serialize, typed_symbols
from rcnc.validation import validate_artifacts
from scripts.experiments.run_downward_reference import sha


def lookup(table, name):
    return {key.lower(): value for key, value in table.items()}[name.lower()]


def goal_atoms(value):
    if value[0] == 'and':
        return [entry for child in value[1:] for entry in goal_atoms(child)]
    if value[0] == 'not':
        if len(value) != 2 or not isinstance(value[1], list):
            raise ValueError('Unsupported goal negation')
        return [(False, value[1])]
    return [(True, value)]


def check_world(source, original, domains, metadata, mapped, mapping):
    original_objects = section(original, ':objects')
    original_objects = typed_symbols(original_objects[1:]) if original_objects else {}
    object_names = {name.lower(): 'q__' + name.lower() for name in original_objects}

    def atom(value):
        predicate = lookup(metadata['predicate_maps'][source], value[0])
        terms = [object_names[term.lower()] if term.lower() in object_names
                 else lookup(metadata['constant_maps'][source], term) for term in value[1:]]
        order = lookup(metadata['predicate_orders'][source], value[0])
        return [predicate, *[terms[i] for i in order]]

    technical = []
    def membership(source_name, entity, typ):
        seen = set()
        while True:
            if typ.lower() in seen:
                raise ValueError('Source type cycle')
            seen.add(typ.lower())
            compiled_type = lookup(metadata['namespaces'][source_name]['types'], typ)
            technical.append([metadata['type_guards'][compiled_type], entity])
            if typ.lower() == 'object':
                break
            typ = lookup(domains[source_name].types, typ)
    for source_name, domain in domains.items():
        for entity, typ in domain.constants.items():
            membership(source_name, lookup(metadata['constant_maps'][source_name], entity), typ)
    for entity, typ in original_objects.items():
        membership(source, object_names[entity.lower()], typ)
    technical = list({serialize(fact): fact for fact in technical}.values())
    narrative = [atom(value) for value in section(original, ':init')[1:]]
    expected_goals = sorted((polarity, serialize(atom(value))) for polarity, value in goal_atoms(section(original, ':goal')[1]))
    actual_goals = sorted((polarity, serialize(value)) for polarity, value in goal_atoms(section(mapped, ':goal')[1]))
    declared = section(mapped, ':objects')
    declared = typed_symbols(declared[1:]) if declared else {}
    expected_objects = {name: 'object' for name in object_names.values()}
    return {'original_narrative_initial_preserved': sorted(map(serialize, narrative)) == sorted(map(serialize, mapping['initial'])),
        'pddl_initial_exactly_narrative_plus_declared_membership':
            sorted(map(serialize, section(mapped, ':init')[1:])) == sorted(map(serialize, narrative + technical)),
        'original_goal_preserved': actual_goals == expected_goals,
        'original_problem_objects_preserved': declared == expected_objects and mapping['objects'] == object_names,
        'original_initial_fact_count': len(narrative), 'technical_membership_fact_count': len(technical),
        'positive_goal_count': sum(polarity for polarity, _ in expected_goals),
        'negative_goal_count': sum(not polarity for polarity, _ in expected_goals)}


def native_transport(source, inputs, run, metadata, mapping, output):
    reader = PDDLReader()
    compiled = reader.parse_problem(str(run / 'planning/domain.pddl'), str(run / 'planning/problem.pddl'))
    plan = reader.parse_plan(compiled, str(run / 'planning/plan.txt'))
    native = reader.parse_problem(str(inputs / (source + '_domainfile.pddl')), str(inputs / (source + '_problemfile.pddl')))
    actions = {target.lower(): name.lower() for name, target in metadata['action_maps'][source].items()}
    terms = {target.lower(): name.lower() for name, target in metadata['constant_maps'][source].items()}
    terms.update({target.lower(): name.lower() for name, target in mapping['objects'].items()})
    native_actions = {action.name.lower(): action for action in native.actions}
    native_objects = {obj.name.lower(): obj for obj in native.all_objects}
    transported = []
    for step in plan.actions:
        if step.action.name.lower() not in actions:
            return {'status': 'not_source_local', 'reason': 'Plan includes foreign source action; no source-only subplan inferred'}
        action = native_actions[actions[step.action.name.lower()]]
        parameters = [native.environment.expression_manager.ObjectExp(native_objects[terms[param.object().name.lower()]])
                      for param in step.actual_parameters]
        if len(action.parameters) != len(parameters):
            raise ValueError('Changed action parameter arity')
        transported.append(ActionInstance(action, tuple(parameters)))
    output.mkdir(parents=True)
    for name, suffix in [('domain.pddl', '_domainfile.pddl'), ('problem.pddl', '_problemfile.pddl')]:
        (output / name).write_bytes((inputs / (source + suffix)).read_bytes())
    PDDLWriter(native).write_plan(SequentialPlan(transported), str(output / 'plan.txt'))
    validation = validate_artifacts(output)
    return {'status': 'valid' if validation['status'] == 'VALID' else 'invalid', 'validation': validation,
            'plan_length': len(transported), 'compiled_plan_sha256': sha(run / 'planning/plan.txt'),
            'scope': 'Positional source-action/constant inverse mapping; independently validated against unchanged original problem'}


def audit(root, output):
    require_empty_output(output)
    read = lambda path: json.loads(path.read_text(encoding='utf-8'))
    protocol, report = read(root / 'frozen_queries.json'), read(root / 'report.json')
    if report['status'] != 'complete' or report['frozen_queries_sha256'] != sha(root / 'frozen_queries.json'):
        raise ValueError('Complete unchanged API matrix required')
    tasks = {task['id']: task for task in protocol['tasks']}
    rows = {row['id']: row for row in report['rows']}
    if (len(tasks) != 30 or len(protocol['tasks']) != 30 or len(rows) != 30 or len(report['rows']) != 30
            or set(tasks) != set(rows) or protocol['task_count'] != 30 or report['task_count'] != 30):
        raise ValueError('Incomplete or duplicate 30-condition denominator')
    for directory, key in [('inputs', 'source_sha256'), ('domain_inputs', 'domain_input_sha256')]:
        for name, digest in protocol[key].items():
            if sha(root / directory / name) != digest:
                raise ValueError('Frozen benchmark input drift')
    if list((root / 'domain_inputs').glob('*_problemfile.pddl')):
        raise ValueError('Pipeline input directory contains source problem files')
    for path, digest in protocol['implementation_sha256'].items():
        if sha(archived_implementation(root, path)) != digest:
            raise ValueError('Archived implementation drift')
    if dict(Counter(row['status'] for row in rows.values())) != report['status_counts']:
        raise ValueError('API summary drift')
    domains = {p.name.removesuffix('_domainfile.pddl'): parse_domain(p) for p in (root / 'inputs').glob('*_domainfile.pddl')}
    if len(domains) != 15:
        raise ValueError('Expected all original sources')
    output.mkdir(parents=True)
    verified = []
    required = ('original_narrative_initial_preserved', 'pddl_initial_exactly_narrative_plus_declared_membership',
                'original_goal_preserved', 'original_problem_objects_preserved')
    for task_id, task in tasks.items():
        row = dict(rows[task_id])
        source = task['source']
        if sha(root / 'inputs' / (source + '_problemfile.pddl')) != task['source_problem_sha256']:
            raise ValueError('Original problem provenance drift')
        if task['admission_status'] != 'supported':
            if row['status'] != 'unsupported_input' or row['planner_called']:
                raise ValueError('Unsupported condition was not retained correctly')
            row['native_plan_transport'] = {'status': 'no_plan'}
            verified.append(row)
            continue
        run = root / 'runs' / task_id
        manifest, result = read(run / 'manifest.json'), read(run / 'result.json')
        domain, problem = planning_domain_path(run, manifest), run / 'mapped_problem.pddl'
        if (read(run / 'query.json') != task['query'] or result['status'] != row['status']
                or sha(domain) != manifest['domain_sha256'] or sha(domain) != row['domain_sha256']
                or sha(problem) != manifest['problem_sha256'] or sha(problem) != row['problem_sha256']):
            raise ValueError('Executed API query/artifact drift')
        metadata, mapping = read(run / 'union/meta_domain.json'), read(run / 'query_mapping.json')
        original = parse_sexpr((root / 'inputs' / (source + '_problemfile.pddl')).read_text(encoding='utf-8'))
        row['world_checks'] = check_world(source, original, domains, metadata,
                                          parse_sexpr(problem.read_text(encoding='utf-8')), mapping)
        row['native_plan_transport'] = {'status': 'no_plan'}
        if row['status'] == 'solved':
            row['fresh_plan_validation'] = validate_artifacts(run / 'planning')
            if row['fresh_plan_validation']['status'] != 'VALID':
                raise ValueError('Solved API plan fails independent validation')
            try:
                row['native_plan_transport'] = native_transport(source, root / 'inputs', run, metadata, mapping,
                    output / 'native_plan_replays' / task_id)
            except Exception as exc:
                row['native_plan_transport'] = {'status': 'mapping_error', 'reason': f'{type(exc).__name__}: {exc}'}
        verified.append(row)
    for source in domains:
        pair = [task for task in tasks.values() if task['source'] == source]
        if len(pair) != 2 or {task['policy'] for task in pair} != {'all_domains', 'static_universe_components'}:
            raise ValueError('Incomplete per-world selection comparison')
        queries = [{k: v for k, v in task['query'].items() if k != 'selection'} for task in pair if task['query'] is not None]
        if queries and (len(queries) != 2 or queries[0] != queries[1]):
            raise ValueError('Paired queries changed beyond selection')
        if all(rows[task['id']].get('problem_sha256') for task in pair):
            if len({rows[task['id']]['problem_sha256'] for task in pair}) != 1:
                raise ValueError('Selection changed the supplied world/goal PDDL')
    world_failures = [row['id'] for row in verified if 'world_checks' in row and not all(row['world_checks'][key] for key in required)]
    transports = dict(Counter(row['native_plan_transport']['status'] for row in verified))
    regressions = any(transports.get(key, 0) for key in ('invalid', 'mapping_error'))
    summary = {policy: dict(Counter(row['status'] for row in verified if row['policy'] == policy))
               for policy in ('all_domains', 'static_universe_components')}
    result = {'status': 'verified_original_world_api_regression' if not world_failures and not regressions else 'verified_with_regressions',
        'task_count': 30, 'source_count': 15, 'rows': verified, 'status_counts': report['status_counts'],
        'summary': summary, 'world_failures': world_failures, 'native_plan_transport_counts': transports,
        'hashes_unchanged': True, 'protocol_sha256': sha(root / 'frozen_queries.json'),
        'source_report_sha256': sha(root / 'report.json'), 'auditor_sha256': sha(Path(__file__)),
        'scope': protocol['scope'], 'world_origin': protocol['world_origin'],
        'limits': 'Known original worlds, fixed unreviewed interfaces, mechanical replay only. Concurrent workload; no statistical timing or independent semantic/narrative claim.'}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    report = audit(args.root, args.output)
    print(json.dumps({k: v for k, v in report.items() if k != 'rows'}, indent=2))

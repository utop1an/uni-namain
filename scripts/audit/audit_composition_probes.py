"""Audit all preregistered composition slots, controls and actual plan sources."""
import argparse
from collections import Counter
import json
from pathlib import Path

from unified_planning.io import PDDLReader
from unified_planning.shortcuts import SequentialSimulator
from rcnc.composition_probes import digest
from rcnc.domain_building import require_empty_output, save, archived_implementation, snapshot_implementation
from rcnc.pddl import parse_domain, parse_sexpr, section, serialize, typed_symbols
from rcnc.validation import validate_artifacts
from scripts.audit.audit_action_removal import compare_domain
from scripts.audit.audit_original_world_pipeline import lookup, goal_atoms
from scripts.experiments.run_downward_reference import sha


def world_checks(query, metadata, domains, mapped, mapping):
    objects = {name: 'q__' + name for name in query['objects']}
    def atom(value):
        source, predicate = value[0].split(':', 1)
        terms = []
        for term in value[1:]:
            if term in objects:
                terms.append(objects[term])
            else:
                owner, name = term.split(':', 1)
                terms.append(lookup(metadata['constant_maps'][owner], name))
        order = lookup(metadata['predicate_orders'][source], predicate)
        return [lookup(metadata['predicate_maps'][source], predicate), *[terms[index] for index in order]]
    technical = []
    def membership(source, entity, typ):
        seen = set()
        while True:
            if typ.lower() in seen:
                raise ValueError('Source type cycle')
            seen.add(typ.lower())
            compiled = lookup(metadata['namespaces'][source]['types'], typ)
            technical.append([metadata['type_guards'][compiled], entity])
            if typ.lower() == 'object':
                break
            typ = lookup(domains[source].types, typ)
    for source, domain in domains.items():
        for name, typ in domain.constants.items():
            membership(source, lookup(metadata['constant_maps'][source], name), typ)
    for name, references in query['objects'].items():
        for reference in references if isinstance(references, list) else [references]:
            source, typ = reference.split(':', 1)
            membership(source, objects[name], typ)
    technical = list({serialize(value): value for value in technical}.values())
    initial = [atom(value) for value in query['initial']]
    goals = [(True, serialize(atom(value))) for value in query['goal'].get('positive', [])]
    goals += [(False, serialize(atom(value))) for value in query['goal'].get('negative', [])]
    declared = section(mapped, ':objects')
    declared = typed_symbols(declared[1:]) if declared else {}
    return {'request_objects_preserved': mapping['objects'] == objects and declared == {name: 'object' for name in objects.values()},
        'narrative_initial_preserved': sorted(map(serialize, mapping['initial'])) == sorted(map(serialize, initial)),
        'pddl_initial_exact': sorted(map(serialize, section(mapped, ':init')[1:])) == sorted(map(serialize, initial + technical)),
        'goal_preserved': sorted(goals) == sorted((positive, serialize(value)) for positive, value in goal_atoms(section(mapped, ':goal')[1])),
        'narrative_fact_count': len(initial), 'technical_fact_count': len(technical)}


def necessity(aligned, zero, removed_producer, removed_consumer):
    if aligned != 'solved':
        return 'aligned_' + aligned
    if removed_producer == 'unsolvable' and removed_consumer == 'unsolvable':
        return 'both_action_sources_necessary'
    if removed_producer == 'solved' or removed_consumer == 'solved':
        return 'source_removal_still_solved'
    return 'inconclusive_source_removal'


def audit(root, output):
    require_empty_output(output)
    read = lambda path: json.loads(path.read_text(encoding='utf-8'))
    manifest, report, protocol = read(root / 'manifest.json'), read(root / 'report.json'), read(root / 'protocol.json')
    generation, pair_models = read(root / 'generation.json'), read(root / 'pair_models.json')
    conditions = {row['id']: row for row in manifest['conditions']}
    rows = {row['id']: row for row in report['rows']}
    expected_pairs = protocol['cohort']['ordered_source_pair_conditions']
    expected_slots = protocol['budget']['max_conditions']
    if expected_slots != expected_pairs * len(protocol['conditions']):
        raise ValueError('Registered pair/condition budget is inconsistent')
    if (report['status'] != 'complete' or report['manifest_sha256'] != sha(root / 'manifest.json')
            or manifest['task_count'] != expected_slots or report['task_count'] != expected_slots or len(conditions) != expected_slots
            or len(manifest['conditions']) != expected_slots or len(rows) != expected_slots or len(report['rows']) != expected_slots or set(rows) != set(conditions)):
        raise ValueError('Complete unique preregistered-slot registry required')
    for path, expected in manifest['input_sha256'].items():
        if sha(root / path) != expected:
            raise ValueError('Frozen input drift: ' + path)
    for path, expected in manifest['implementation_sha256'].items():
        if sha(archived_implementation(root, path)) != expected:
            raise ValueError('Archived implementation drift: ' + path)
    if not all(report[key] is True for key in ('inputs_unchanged', 'implementation_unchanged', 'solver_integrity')):
        raise ValueError('Runtime integrity failed')
    if dict(Counter(row['status'] for row in rows.values())) != report['status_counts']:
        raise ValueError('Condition summary drift')
    pairs = {pair['id']: pair for pair in generation['pairs']}
    if len(pairs) != expected_pairs or len(generation['pairs']) != expected_pairs:
        raise ValueError('Complete preregistered-pair cohort required')
    candidates = generation['candidates']
    if len(candidates) != manifest['candidate_count'] or dict(Counter(c['status'] for c in candidates)) != manifest['candidate_counts']:
        raise ValueError('Candidate denominator drift')
    if len({(c['pair_id'], c['rank_sha256']) for c in candidates}) != len(candidates):
        raise ValueError('Duplicate candidate descriptor')
    for candidate in candidates:
        if digest(candidate['candidate']) != candidate['rank_sha256'] or candidate['pair_id'] not in pairs:
            raise ValueError('Candidate rank/provenance drift')
    domains = {p.name.removesuffix('_domainfile.pddl'): parse_domain(p) for p in (root / 'inputs').glob('*.pddl')}
    if len(domains) != 15 or list((root / 'inputs').glob('*_problemfile.pddl')):
        raise ValueError('Expected domain-only fixed source inputs')
    profiles = {(row['source'], row['action']) for row in generation['action_profiles']}
    if len(profiles) != len(generation['action_profiles']) or profiles != {(s, a) for s, domain in domains.items() for a in domain.actions}:
        raise ValueError('Incomplete source-action profile inventory')
    for pair in pairs.values():
        subset = [c for c in candidates if c['pair_id'] == pair['id']]
        schema_pairs = {(c['candidate']['producer_action'], c['candidate']['consumer_action']) for c in subset}
        if schema_pairs != {(a, b) for a in domains[pair['producer']].actions for b in domains[pair['consumer']].actions}:
            raise ValueError('Generator dropped a source-schema pair')
        supported = [c for c in subset if c['status'] == 'supported']
        if pair['candidate_count'] != len(subset) or pair['supported_candidate_count'] != len(supported):
            raise ValueError('Pair generation count drift')
        if pair['status'] == 'generated':
            if not supported or pair['selected_rank_sha256'] != min(c['rank_sha256'] for c in supported) or digest(pair['query']) != next(c['query_sha256'] for c in supported if c['rank_sha256'] == pair['selected_rank_sha256']):
                raise ValueError('Probe was not selected by the frozen pre-search ranking')
        elif supported:
            raise ValueError('Supported pair silently excluded')
    executable = {key for key, condition in conditions.items() if condition['admission_status'] == 'ready'}
    if report['actual_solver_calls'] != len(executable):
        raise ValueError('Executable condition count drift')
    solver_rows = {}
    if executable:
        solver_manifest, solver_report = read(root / 'solver/manifest.json'), read(root / 'solver/report.json')
        solver_rows = {row['id']: row for row in solver_report['rows']}
        if (solver_report['status'] != 'complete' or solver_report['manifest_sha256'] != sha(root / 'solver/manifest.json')
                or solver_manifest['task_bundle_manifest_sha256'] != sha(root / 'bundle/manifest.json')
                or set(solver_rows) != executable or len(solver_report['rows']) != len(executable)):
            raise ValueError('Incomplete solver subset')
        if solver_manifest['budget'] != {'wall_seconds': 20, 'overall_cpu_seconds': 20, 'memory_mb': 4096}:
            raise ValueError('Changed search budget')
    metadata = {name: read(root / 'models' / name / 'meta_domain.json') for name in ('machine', 'zero_merge')}
    full_domains = {name: parse_sexpr((root / 'models' / name / 'meta_domain.pddl').read_text(encoding='utf-8')) for name in metadata}
    output.mkdir(parents=True)
    checked, failures = [], []
    for key, row in rows.items():
        condition = conditions[key]
        pair = pairs[condition['pair_id']]
        result = dict(row)
        if condition['admission_status'] != 'ready':
            if row['status'] != condition['admission_status']:
                raise ValueError('Non-executable condition relabeled')
            checked.append(result)
            continue
        if row['status'] != solver_rows[key]['status']:
            raise ValueError('API status differs from solver row')
        directory = root / 'solver/tasks' / key
        for kind in ('domain', 'problem'):
            if sha(directory / (kind + '.pddl')) != condition[kind + '_sha256']:
                raise ValueError('Solver input drift')
        model = 'zero_merge' if condition['condition'].startswith('zero_merge') else 'machine'
        selected = set(condition['selected_sources'])
        if condition['condition'] == 'aligned_remove_producer_actions':
            selected.discard(pair['producer'])
        if condition['condition'] == 'aligned_remove_consumer_actions':
            selected.discard(pair['consumer'])
        retained = {name for source in selected for name in metadata[model]['action_maps'][source].values()}
        all_names = {name for table in metadata[model]['action_maps'].values() for name in table.values()}
        actual = parse_domain(directory / 'domain.pddl')
        result['whole_source_actions_and_other_sections_preserved'] = compare_domain(full_domains[model],
            parse_sexpr((directory / 'domain.pddl').read_text(encoding='utf-8')), all_names - retained)
        result['no_query_bindings_embedded_in_domain'] = not any('q__' + obj in actual.constants for obj in pair['query']['objects'])
        probe = root / 'probes' / pair['id']
        if read(probe / 'query.json') != pair['query'] or digest(pair['query']) != condition['query_sha256']:
            raise ValueError('Explicit generated world changed')
        result['world_checks'] = world_checks(pair['query'], metadata[model], domains,
            parse_sexpr((directory / 'problem.pddl').read_text(encoding='utf-8')), read(probe / (model + '_mapping.json')))
        reader = PDDLReader()
        problem = reader.parse_problem(str(directory / 'domain.pddl'), str(directory / 'problem.pddl'))
        with SequentialSimulator(problem) as simulator:
            result['goal_initially_false'] = not simulator.is_goal(simulator.get_initial_state())
        if row['status'] == 'solved':
            result['fresh_plan_validation'] = validate_artifacts(directory)
            plan = reader.parse_plan(problem, str(directory / 'plan.txt'))
            owners = {name.lower(): source for source, table in metadata[model]['action_maps'].items() for name in table.values()}
            result['actual_plan_source_counts'] = dict(Counter(owners[step.action.name.lower()] for step in plan.actions))
            result['actual_plan_length'] = len(plan.actions)
        required = ['whole_source_actions_and_other_sections_preserved', 'no_query_bindings_embedded_in_domain', 'goal_initially_false']
        valid = all(result[field] for field in required) and all(result['world_checks'][field] for field in
            ('request_objects_preserved', 'narrative_initial_preserved', 'pddl_initial_exact', 'goal_preserved'))
        if row['status'] == 'solved':
            valid = valid and result['fresh_plan_validation']['status'] == 'VALID'
        if not valid:
            failures.append(key)
        checked.append(result)
    indexed = {row['id']: row for row in checked}
    pair_results = []
    for pair in pairs.values():
        group = {condition: indexed[pair['id'] + '__' + condition] for condition in protocol['conditions']}
        result = {key: pair[key] for key in ('id', 'producer', 'consumer', 'status', 'candidate_count', 'supported_candidate_count')}
        if any(row['admission_status'] != 'ready' for row in group.values()):
            result['source_necessity'] = 'not_generated_or_admitted'
        else:
            statuses = {condition: row['status'] for condition, row in group.items()}
            result.update(condition_statuses=statuses,
                source_necessity=necessity(*(statuses[condition] for condition in protocol['conditions'])),
                actual_aligned_plan_sources=group['aligned_selected_sources'].get('actual_plan_source_counts'),
                interface_required_for_goal_under_models=statuses['aligned_selected_sources'] == 'solved'
                    and statuses['zero_merge_same_source_action_sets'] == 'unsolvable')
            machine = [group[c]['problem_sha256'] for c in protocol['conditions'] if not c.startswith('zero_merge')]
            if len(set(machine)) != 1:
                raise ValueError('Source-removal controls changed world/goal bytes')
            if result['source_necessity'] == 'both_action_sources_necessary':
                if not {pair['producer'], pair['consumer']} <= set(result['actual_aligned_plan_sources']):
                    raise ValueError('Necessity controls contradict actual plan source use')
        pair_results.append(result)
    summary = {condition: dict(Counter(row['status'] for row in checked if row['condition'] == condition)) for condition in protocol['conditions']}
    implementation = snapshot_implementation(output, [Path(__file__), Path('scripts/audit/audit_action_removal.py'),
        Path('scripts/audit/audit_original_world_pipeline.py'), Path('rcnc/composition_probes.py'),
        Path('rcnc/pddl.py'), Path('rcnc/domain_building.py'), Path('rcnc/validation.py')])
    result = {'status': 'verified_composition_probe_snapshot' if not failures else 'audited_with_violations',
        'task_count': expected_slots, 'ordered_pair_count': expected_pairs, 'generated_probe_count': manifest['generated_probe_count'],
        'actual_solver_calls': len(executable), 'candidate_count': len(candidates), 'rows': checked,
        'status_counts': report['status_counts'], 'summary': summary, 'pair_results': pair_results,
        'source_necessity_counts': dict(Counter(pair['source_necessity'] for pair in pair_results)),
        'pair_model_count': len(pair_models), 'models_used_by_multiple_probes': sum(len(model['probes']) > 1 for model in pair_models.values()),
        'audit_failures': failures, 'hashes_unchanged': True, 'manifest_sha256': sha(root / 'manifest.json'),
        'report_sha256': sha(root / 'report.json'), 'implementation_sha256': implementation,
        'scope': protocol['construction']['interpretation'], 'independent_semantic_labels': 0,
        'limits': f"{expected_pairs} planned ordered source pairs, {manifest['generated_probe_count']} constructed worlds; all unsupported pairs retained. Model-derived tasks, unreviewed interfaces, observed local sources and concurrent workloads; no narrative-quality, unseen-family or statistical timing claim."}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    report = audit(args.root, args.output)
    print(json.dumps({key: value for key, value in report.items() if key not in ('rows', 'pair_results', 'implementation_sha256')}, indent=2))

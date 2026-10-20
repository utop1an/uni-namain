"""Audit completed matched-world results from actual exported artifacts."""
import argparse
from collections import Counter, defaultdict
import hashlib
import json
from pathlib import Path

from rcnc.pddl import parse_sexpr, section, serialize
from rcnc.validation import validate_artifacts


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def world_contract(query):
    return {key: query.get(key) for key in ('objects', 'initial', 'goal', 'state_semantics', 'solver', 'seconds')}


def check_design(manifest, report):
    errors = []
    tasks = manifest['tasks']
    ids = [task['id'] for task in tasks]
    result_ids = [row['id'] for row in report['rows']]
    if len(ids) != len(set(ids)) or len(tasks) != manifest['task_count']:
        errors.append('duplicate_or_wrong_frozen_denominator')
    if len(result_ids) != len(set(result_ids)) or set(result_ids) != set(ids):
        errors.append('result_denominator_mismatch')
    if report.get('status') != 'complete':
        errors.append('run_not_complete')
    worlds = defaultdict(list)
    for task in tasks:
        worlds[task['world']].append(task)
    if set(worlds) != {'bridge_needed', 'source_ready_control', 'empty_world_control'}:
        errors.append('world_denominator_mismatch')
    for world, rows in worlds.items():
        reference = world_contract(rows[0]['query'])
        if any(world_contract(row['query']) != reference for row in rows[1:]):
            errors.append('unmatched_world_goal_or_budget:' + world)
        expected = {(method, policy) for method in ('zero_merge_membership', 'authored_possession_interface')
                    for policy in ('explicit_pair', 'all_domains', 'goal_dependencies')}
        actual = [(row['method'], row['policy']) for row in rows]
        if len(actual) != len(expected) or set(actual) != expected:
            errors.append('incomplete_factorial_conditions:' + world)
    return errors


def audit(directory, output):
    if output.exists():
        raise ValueError('Use a new audit file')
    manifest = read(directory/'frozen_tasks.json')
    report = read(directory/'report.json')
    errors = check_design(manifest, report)
    if report.get('status') != 'complete':
        raise ValueError('Wait for the full run to finish before auditing')
    if sha(directory/'frozen_tasks.json') != report['frozen_tasks_sha256']:
        errors.append('frozen_tasks_hash_mismatch')
    for filename, expected in manifest['source_sha256'].items():
        if sha(directory/'inputs'/filename) != expected:
            errors.append('source_hash_mismatch:' + filename)
    rows = []
    model_hashes = defaultdict(set)
    for task in manifest['tasks']:
        run = directory/'runs'/task['id']
        row = {key: task[key] for key in ('id', 'world', 'method', 'policy')}
        failures = []
        try:
            actual_query = read(run/'query.json')
            if actual_query != task['query']:
                failures.append('run_query_differs_from_frozen_query')
            result = read(run/'result.json')
            row['status'] = result['status']
            if result['status'] in ('rejected', 'error', 'worker_error', 'artifact_changed', 'running'):
                failures.append('pipeline_did_not_produce_a_stable_search_result')
            frozen = read(run/'manifest.json')
            domain, problem = run/'union/meta_domain.pddl', run/'mapped_problem.pddl'
            if sha(domain) != frozen['domain_sha256'] or sha(problem) != frozen['problem_sha256']:
                failures.append('export_hash_mismatch')
            model_hashes[(task['method'], task['policy'])].add(sha(domain))
            mapping = read(run/'query_mapping.json')
            if mapping['source_problem_facts_imported'] is not False:
                failures.append('source_problem_facts_imported')
            parsed = parse_sexpr(problem.read_text(encoding='utf-8'))
            actual_init = {serialize(atom) for atom in section(parsed, ':init')[1:]}
            # Read actual PDDL, not the reported validation boolean. Technical
            # memberships are separately identified and may not hide story facts.
            technical = mapping.get('type_encoding_facts', [])
            meta = read(run/'union/meta_domain.json')
            if any(atom[0] not in set(meta['type_guards'].values()) for atom in technical):
                failures.append('non_membership_fact_hidden_as_technical_encoding')
            expected_init = {serialize(atom) for atom in mapping['initial'] + technical}
            if actual_init != expected_init:
                failures.append('exported_initial_facts_do_not_match_recorded_mapping')
            actual_goal = section(parsed, ':goal')[1]
            expected_goal = ['and', *mapping['goal']['positive'],
                             *[['not', atom] for atom in mapping['goal']['negative']]]
            if actual_goal != expected_goal:
                failures.append('exported_goal_does_not_match_recorded_mapping')
            row.update(narrative_initial_fact_count=len(mapping['initial']),
                       technical_membership_fact_count=len(technical), domain_sha256=sha(domain))
            if result['status'] == 'solved':
                planning = run/'planning'
                if (planning/'domain.pddl').read_bytes() != domain.read_bytes() or (planning/'problem.pddl').read_bytes() != problem.read_bytes():
                    failures.append('validated_plan_model_differs_from_presearch_export')
                row['independent_validation'] = validate_artifacts(planning)
                if row['independent_validation']['status'] != 'VALID':
                    failures.append('plan_failed_fresh_independent_validation')
                meta = read(run/'union/meta_domain.json')
                owners = defaultdict(list)
                for source, table in meta['action_maps'].items():
                    for name in table.values():
                        owners[name.lower()].append(source)
                steps = []
                for text in (planning/'plan.txt').read_text(encoding='utf-8').splitlines():
                    text = text.strip()
                    if not text or text.startswith(';'):
                        continue
                    expression = parse_sexpr(text)
                    steps.append({'action': text, 'sources': owners.get(expression[0].lower(), [])})
                row['steps'] = steps
                row['plan_sources'] = sorted({source for step in steps for source in step['sources']})
                row['source_necessity_claim'] = False
                if any(len(step['sources']) != 1 for step in steps):
                    failures.append('action_source_attribution_not_unique')
        except Exception as exc:
            failures.append(f'artifact_audit_error:{type(exc).__name__}:{exc}')
        row['audit_errors'] = failures
        rows.append(row)
        errors.extend(task['id']+':'+failure for failure in failures)
    groups = []
    for key, hashes in sorted(model_hashes.items()):
        groups.append({'method': key[0], 'policy': key[1], 'domain_hash_count_across_worlds': len(hashes)})
        if len(hashes) != 1:
            errors.append('domain_changed_across_worlds:' + '/'.join(key))
    result = {'status': 'PASS' if not errors else 'FAIL', 'errors': errors,
        'total': len(rows), 'status_counts': dict(Counter(row.get('status', 'missing') for row in rows)),
        'freshly_validated_plans': sum(row.get('independent_validation', {}).get('status') == 'VALID' for row in rows),
        'matched_input_audit': 'Explicit world, goal and search budget compared across all methods within each world',
        'domain_reuse_groups': groups, 'rows': rows,
        'limitations': ['Authored interfaces and worlds on observed source models',
            'Incomplete search and timeouts do not establish unsolvability',
            'Mixed-source plans do not prove every used source is necessary',
            'Concurrent workloads; wall-clock durations are descriptive only',
            'No independent narrative quality or semantic accuracy labels'],
        'implementation_sha256': sha(Path(__file__))}
    output.write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = audit(args.run, args.output)
    print(json.dumps({k: v for k, v in result.items() if k != 'rows'}, indent=2))
    raise SystemExit(0 if result['status'] == 'PASS' else 1)

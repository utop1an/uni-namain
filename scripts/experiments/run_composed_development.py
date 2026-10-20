"""Matched explicit-world development comparisons on intact real source domains.

Worlds and the possession interface are authored assumptions, not independent
semantic annotations. All 18 conditions are frozen before the first search.
"""
import argparse
from collections import Counter
import copy
import hashlib
import json
from pathlib import Path
import time

from rcnc.narrative_pipeline import run as run_query

ROOT = Path(__file__).resolve().parents[2]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8')


def freeze(inputs, output, seconds=60):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    if type(seconds) not in (int, float) or not 0 < seconds <= 3600:
        raise ValueError('Invalid seconds budget')
    snapshot = output/'inputs'
    snapshot.mkdir(parents=True)
    for path in sorted(inputs.glob('*_domainfile.pddl')):
        (snapshot/path.name).write_bytes(path.read_bytes())
    hashes = {p.name: sha(p) for p in sorted(snapshot.glob('*.pddl'))}
    if not {'ACCO_domainfile.pddl', 'BIRT_domainfile.pddl'} <= set(hashes):
        raise ValueError('Requires unchanged ACCO and BIRT source models')
    # Deliberately no source problem files in this frozen task bundle.
    base = {'objects': {'hero': ['ACCO:entity', 'BIRT:entity'],
                        'token': ['ACCO:item', 'BIRT:item'], 'stage': 'BIRT:location'},
            'goal': {'positive': [['ACCO:wealthy', 'hero']]}, 'solver': 'pyperplan', 'seconds': seconds}
    worlds = {'bridge_needed': [['BIRT:at', 'hero', 'stage']],
              'source_ready_control': [['ACCO:has', 'hero', 'token']], 'empty_world_control': []}
    tasks = []
    for world, initial in worlds.items():
        for method in ('zero_merge_membership', 'authored_possession_interface'):
            for policy in ('explicit_pair', 'all_domains', 'goal_dependencies'):
                query = copy.deepcopy(base)
                query['initial'] = copy.deepcopy(initial)
                spec = {'version': 1, 'decision_basis': 'authored_assumption', 'source_sha256': hashes,
                        'type_groups': [], 'predicate_groups': []}
                if method == 'authored_possession_interface':
                    spec['type_groups'] = [{'members': ['ACCO:'+typ, 'BIRT:'+typ],
                        'evidence': 'Explicit experiment-author role correspondence; independent review pending'} for typ in ('entity', 'item')]
                    spec['predicate_groups'] = [{'id': 'possession',
                        'evidence': 'Experiment-author hypothesis: ACCO has and BIRT has denote the same entity-item possession relation; not gold',
                        'members': [{'predicate': source+':has', 'order': [0, 1]} for source in ('ACCO', 'BIRT')]}]
                query['alignment'] = spec
                if policy == 'explicit_pair':
                    query['sources'] = ['ACCO', 'BIRT']
                else:
                    query['selection'] = policy
                tasks.append({'id': f'{world}__{method}__{policy}', 'world': world,
                              'method': method, 'policy': policy, 'query': query})
    implementation = {p.relative_to(ROOT).as_posix(): sha(p) for p in
        [ROOT/'scripts/experiments/run_composed_development.py', ROOT/'rcnc/aligned_domain.py', ROOT/'rcnc/domain_union.py',
         ROOT/'rcnc/pddl.py', ROOT/'rcnc/pddl_checks.py', ROOT/'run_narrative_pipeline.py',
         *sorted((ROOT/'rcnc').glob('*.py'))]}
    manifest = {'version': 1, 'status': 'frozen_before_search', 'task_count': len(tasks),
        'scope': 'Authored matched-world development cases using observed source domains; not independent test or narrative-quality evaluation',
        'source_sha256': hashes, 'implementation_sha256': implementation,
        'solver': 'pyperplan', 'budget_seconds_per_search': seconds,
        'input_world_policy': 'Explicit author-supplied initial facts only; no source problem files read or copied',
        'interface_status': 'author_hypothesis_not_independently_supported',
        'baseline': 'Zero predicate merges with same membership representation and explicitly shared entities',
        'source_model_caveat': 'BIRT turn_key_on_beech can create possession of arbitrary typed items; this observed source generality is retained, not repaired or claimed narratively plausible',
        'semantic_accuracy': 'not_measured', 'tasks': tasks}
    save(output/'frozen_tasks.json', manifest)
    return manifest


def run(inputs, output, seconds=60):
    manifest = freeze(inputs, output, seconds)
    frozen_hash = sha(output/'frozen_tasks.json')
    report = {'status': 'running', 'task_count': manifest['task_count'], 'frozen_tasks_sha256': frozen_hash,
              'rows': [], 'scope': manifest['scope']}
    save(output/'report.json', report)
    for task in manifest['tasks']:
        directory = output/'runs'/task['id']
        start = time.monotonic()
        result = run_query(task['query'], output/'inputs', directory)
        row = {k: task[k] for k in ('id', 'world', 'method', 'policy')}
        row.update(status=result['status'], elapsed_seconds=round(time.monotonic()-start, 3),
                   validation=result.get('search', {}).get('validation', {}).get('status'),
                   plan_length=result.get('search', {}).get('length'),
                   domain_unchanged=result.get('domain_unchanged'),
                   selected=result.get('selection', {}).get('selected'),
                   reason=result.get('reason'))
        mapping_path = directory/'query_mapping.json'
        if mapping_path.exists():
            mapping = json.loads(mapping_path.read_text())
            row['source_problem_facts_imported'] = mapping['source_problem_facts_imported']
        report['rows'].append(row)
        report['status_counts'] = dict(Counter(r['status'] for r in report['rows']))
        save(output/'report.json', report)
        print(json.dumps(row), flush=True)
    report.update(status='complete', frozen_tasks_unchanged=sha(output/'frozen_tasks.json') == frozen_hash,
        implementation_unchanged=all(sha(ROOT/name) == value for name, value in manifest['implementation_sha256'].items()),
        sources_unchanged=all(sha(output/'inputs'/name) == value for name, value in manifest['source_sha256'].items()),
        limit='Matched inputs support mechanical comparison only; authored hypotheses and observed sources are not semantic gold')
    save(output/'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inputs', type=Path, default=Path('data/narra-domains'))
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--seconds', type=float, default=60)
    args = parser.parse_args()
    result = run(args.inputs, args.output, args.seconds)
    print(json.dumps({k: v for k, v in result.items() if k != 'rows'}, indent=2))

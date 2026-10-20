"""Initial-only development runs derived explicitly from frozen authored worlds."""
import argparse
from collections import Counter
import copy
import json
from pathlib import Path

from rcnc.narrative_pipeline import run as run_query
from run_composed_development import sha, save


def run(previous, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    parent = json.loads((previous/'frozen_tasks.json').read_text(encoding='utf-8'))
    snapshot = output/'inputs'
    snapshot.mkdir(parents=True)
    for name, expected in parent['source_sha256'].items():
        source = previous/'inputs'/name
        if sha(source) != expected:
            raise ValueError('Changed source snapshot')
        (snapshot/name).write_bytes(source.read_bytes())
    tasks = []
    for original in parent['tasks']:
        if original['policy'] != 'explicit_pair':
            continue
        task = copy.deepcopy(original)
        query = task['query']
        del query['goal']
        query.update(solver='typed_cartesian', seconds=60, max_depth=3,
                     max_states=5000, max_ground_actions=100000,
                     max_ground_fluents=100000, max_outcomes=3)
        tasks.append(task)
    implementations = ['run_initial_only_development.py', 'rcnc/outcome_planning.py',
        'rcnc/narrative_pipeline.py', 'rcnc/grounding.py', 'rcnc/state_grounding.py', 'build_aligned_domain.py',
        'build_narrative_union.py', 'run_narrative_pipeline.py', 'rcnc/validation.py']
    manifest = {'parent_manifest_sha256': sha(previous/'frozen_tasks.json'),
                'source_sha256': parent['source_sha256'], 'tasks': tasks,
                'implementation_sha256': {p: sha(Path(p)) for p in implementations},
                'scope': 'Six authored development worlds/interfaces without goals; generated outcomes are not task success or narrative quality'}
    implementation = output/'implementation'
    implementation.mkdir()
    for name in implementations:
        destination = implementation/name
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(Path(name).read_bytes())
    save(output/'frozen_tasks.json', manifest)
    frozen = sha(output/'frozen_tasks.json')
    report = {'status': 'running', 'task_count': len(tasks), 'rows': [], 'scope': manifest['scope']}
    save(output/'report.json', report)
    for task in tasks:
        result = run_query(task['query'], snapshot, output/'runs'/task['id'])
        search = result.get('search', {})
        row = {k: task[k] for k in ('id', 'world', 'method')}
        row.update(status=result['status'], stop_reason=search.get('stop_reason'),
            outcome_count=len(search.get('outcomes', [])), domain_unchanged=result.get('domain_unchanged'),
            ground_fluents_tracked=search.get('ground_fluents_tracked'),
            ground_candidates=search.get('ground_candidates'),
            validations=[o['validation']['status'] for o in search.get('outcomes', [])])
        report['rows'].append(row)
        save(output/'report.json', report)
        print(json.dumps(row), flush=True)
    report.update(status='complete', counts=dict(Counter(r['status'] for r in report['rows'])),
        frozen_tasks_unchanged=sha(output/'frozen_tasks.json') == frozen,
        implementation_unchanged=all(sha(Path(p)) == h for p, h in manifest['implementation_sha256'].items()),
        sources_unchanged=all(sha(snapshot/p) == h for p, h in manifest['source_sha256'].items()))
    save(output/'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--previous', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    run(args.previous, args.output)

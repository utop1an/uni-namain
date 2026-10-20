"""Freeze an exploratory selection follow-up, separate from the original 60 cases."""
import argparse
import hashlib
import json
from pathlib import Path

from rcnc.aligned_domain import build
from rcnc.domain_catalog import project_alignment
from rcnc.domain_building import require_empty_output, save
from scripts.experiments.run_downward_reference import sha


def closure(source, specification):
    chosen = {source}
    while True:
        previous = set(chosen)
        for group in specification['predicate_groups']:
            members = {row['predicate'].split(':', 1)[0] for row in group['members']}
            if members & chosen:
                chosen.update(members)
        if chosen == previous:
            return sorted(chosen)


def prepare(matched, output):
    require_empty_output(output)
    output.mkdir(parents=True, exist_ok=True)
    inputs = matched / 'inputs'
    specification = json.loads((matched / 'alignment.json').read_text(encoding='utf-8'))
    sources = sorted(path.name.removesuffix('_domainfile.pddl') for path in inputs.glob('*_domainfile.pddl'))
    policy = {'status': 'fixed_before_followup_search',
        'label': 'Exploratory follow-up motivated by early all-pool time limits; not part of original 60-case design',
        'selection_policy': 'Start from original problem source; retain complete predicate-interface source groups to a fixed point. Not minimal or reachability-optimal.',
        'source_worlds_and_goals': 'Exact snapshots from original matched experiment; no new facts or object identities',
        'seconds_per_task': 20, 'memory_mb': 4096, 'workers': 1,
        'all_sources_retained_in_denominator': sources,
        'selected_sources': {source: closure(source, specification) for source in sources},
        'origin_alignment_sha256': sha(matched / 'alignment.json')}
    save(output / 'policy.json', policy)
    model_cache, tasks = {}, []
    for source in sources:
        selected = policy['selected_sources'][source]
        key = hashlib.sha256(json.dumps(selected).encode()).hexdigest()[:12]
        if key not in model_cache:
            directory = output / 'models' / key
            snapshot = directory / 'inputs'
            snapshot.mkdir(parents=True)
            for chosen in selected:
                for suffix in ('domainfile', 'problemfile'):
                    name = chosen + '_' + suffix + '.pddl'
                    (snapshot / name).write_bytes((inputs / name).read_bytes())
            projected, omitted = project_alignment(specification, selected)
            save(directory / 'alignment.json', projected)
            validation = build(snapshot, directory / 'compiled', projected)
            if not validation['valid']:
                raise ValueError('Selected compiled problem failed parsing')
            model_cache[key] = {'sources': selected, 'omitted_interfaces': omitted,
                                'validation': validation}
        compiled = output / 'models' / key / 'compiled'
        task_id = source + '__machine_interfaces_selected'
        directory = output / 'bundle/tasks' / task_id
        directory.mkdir(parents=True)
        (directory / 'domain.pddl').write_bytes((compiled / 'meta_domain.pddl').read_bytes())
        (directory / 'problem.pddl').write_bytes((compiled / 'problems' / (source + '_problemfile.pddl')).read_bytes())
        tasks.append({'id': task_id, 'source': source, 'representation': 'machine_interfaces_selected',
            'selected_sources': selected, 'domain_sha256': sha(directory / 'domain.pddl'),
            'problem_sha256': sha(directory / 'problem.pddl')})
    manifest = {'status': 'frozen_before_search', 'mode': 'matched_source_representations',
        'task_count': len(tasks), 'tasks': tasks, 'policy_sha256': sha(output / 'policy.json'),
        'source_count': len(sources), 'unique_selected_models': len(model_cache),
        'origin_bundle_sha256': sha(matched / 'bundle/manifest.json'),
        'implementation_sha256': {str(p): sha(p) for p in (Path(__file__), Path('rcnc/aligned_domain.py'),
            Path('rcnc/domain_catalog.py'), Path('rcnc/domain_union.py'), Path('rcnc/pddl.py'))},
        'scope': policy['label']}
    save(output / 'bundle/manifest.json', manifest)
    save(output / 'models.json', model_cache)
    return manifest


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--matched', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = prepare(args.matched, args.output)
    print(json.dumps({k: v for k, v in result.items() if k != 'tasks'}, indent=2))

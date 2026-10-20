"""Remove only source actions from frozen explicit-pair development exports."""
import argparse
import json
from pathlib import Path

from rcnc.pddl import parse_sexpr, serialize
from scripts.experiments.run_downward_reference import sha, save
from unified_planning.io import PDDLReader


def remove_actions(root, names):
    present = {x[1] for x in root if isinstance(x, list) and x and x[0] == ':action'}
    if not names <= present:
        raise ValueError('Action map contains absent names')
    return [x for x in root if not (isinstance(x, list) and x and x[0] == ':action' and x[1] in names)]


def freeze(origin, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    frozen = json.loads((origin/'frozen_tasks.json').read_text(encoding='utf-8'))
    report = json.loads((origin/'report.json').read_text(encoding='utf-8'))
    if report['status'] != 'complete' or report['frozen_tasks_sha256'] != sha(origin/'frozen_tasks.json'):
        raise ValueError('Complete unchanged originating run required')
    tasks = [t for t in frozen['tasks'] if t['policy'] == 'explicit_pair']
    if len(tasks) != 6 or len({(t['world'], t['method']) for t in tasks}) != 6:
        raise ValueError('Expected six distinct original explicit-pair conditions')
    output.mkdir(parents=True, exist_ok=True)
    rows = []
    for task in tasks:
        source = origin/'runs'/task['id']
        meta_path = source/'union/meta_domain.json'
        metadata = json.loads(meta_path.read_text(encoding='utf-8'))
        manifest = json.loads((source/'manifest.json').read_text(encoding='utf-8'))
        domain, problem = source/'union/meta_domain.pddl', source/'mapped_problem.pddl'
        if sha(domain) != manifest['domain_sha256'] or sha(problem) != manifest['problem_sha256']:
            raise ValueError('Origin exported task changed')
        if set(metadata['action_maps']) != {'ACCO', 'BIRT'}:
            raise ValueError('Expected exactly the two declared sources')
        root = parse_sexpr(domain.read_text(encoding='utf-8'))
        all_names = [name for table in metadata['action_maps'].values() for name in table.values()]
        actual_names = [x[1] for x in root if isinstance(x, list) and x and x[0] == ':action']
        if len(set(all_names)) != len(all_names) or set(all_names) != set(actual_names):
            raise ValueError('Source-action ownership must be complete and disjoint')
        for removed in (None, 'ACCO', 'BIRT'):
            key = task['id']+'__remove_'+(removed or 'none')
            directory = output/'tasks'/key
            directory.mkdir(parents=True)
            names = set(metadata['action_maps'][removed].values()) if removed else set()
            edited = remove_actions(root, names)
            (directory/'domain.pddl').write_bytes((serialize(edited)+'\n').encode() if removed else domain.read_bytes())
            (directory/'problem.pddl').write_bytes(problem.read_bytes())
            # Removing all actions must leave every other section unchanged.
            parsed = parse_sexpr((directory/'domain.pddl').read_text(encoding='utf-8'))
            remaining = set(actual_names)-names
            if remove_actions(parsed, remaining) != remove_actions(root, set(actual_names)):
                raise ValueError('Non-action domain sections changed')
            PDDLReader().parse_problem(str(directory/'domain.pddl'), str(directory/'problem.pddl'))
            rows.append({'id': key, 'origin_id': task['id'], 'world': task['world'],
                'method': task['method'], 'removed_source': removed, 'removed_actions': sorted(names),
                'retained_action_count': len(remaining), 'domain_sha256': sha(directory/'domain.pddl'),
                'problem_sha256': sha(directory/'problem.pddl'), 'origin_domain_sha256': sha(domain),
                'origin_metadata_sha256': sha(meta_path), 'only_actions_changed': True})
    manifest = {'status': 'frozen_before_search', 'mode': 'source_action_removal',
        'origin': str(origin), 'origin_frozen_tasks_sha256': sha(origin/'frozen_tasks.json'),
        'task_count': len(rows), 'tasks': rows, 'producer_sha256': sha(Path(__file__)),
        'scope': 'Six authored explicit-pair conditions crossed with no removal, ACCO action removal, BIRT action removal',
        'interpretation': 'Re-solving tests action-source necessity for these worlds and goals; '
                          'vocabulary, entities, initial facts, goals and interfaces stay fixed. '
                          'Not narrative quality, general source necessity, or independent evaluation.'}
    save(output/'manifest.json', manifest)
    (output/'producer.py').write_bytes(Path(__file__).read_bytes())
    return manifest


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--origin', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    result = freeze(args.origin, args.output)
    print(json.dumps({k: v for k, v in result.items() if k != 'tasks'}, indent=2))

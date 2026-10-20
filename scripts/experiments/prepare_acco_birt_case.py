"""Freeze the ACCO+BIRT bridge and matched interface/source-removal controls."""
import argparse
import copy
import json
from pathlib import Path
from unified_planning.io import PDDLReader
from rcnc.aligned_domain import build
from rcnc.domain_building import require_empty_output, save
from rcnc.narrative_pipeline import map_problem
from rcnc.pddl import parse_domain, parse_sexpr, section, serialize, write_domain
from scripts.experiments.run_downward_reference import sha


def prepare(matched, historical, output):
    require_empty_output(output)
    output.mkdir(parents=True)
    query_path = historical / 'runs/bridge_needed__authored_possession_interface__explicit_pair/query.json'
    query = json.loads(query_path.read_text(encoding='utf-8'))
    # Domain snapshots include source problems for construction checks only;
    # map_problem imports no narrative facts from those source problems.
    inputs = output / 'inputs'
    inputs.mkdir()
    for source in ('ACCO', 'BIRT'):
        for suffix in ('domainfile', 'problemfile'):
            name = source + '_' + suffix + '.pddl'
            (inputs / name).write_bytes((matched / 'inputs' / name).read_bytes())
    query['seconds'] = 20
    save(output / 'query.json', query)
    tasks = []
    for name, interface in [('interface_pair', True), ('no_interface_pair', False)]:
        spec = copy.deepcopy(query['alignment'])
        if not interface:
            spec['predicate_groups'] = []
        directory = output / 'models' / name
        build(inputs, directory, spec)
        mapping = map_problem(query, directory, directory / 'mapped_problem.pddl')
        save(directory / 'query_mapping.json', mapping)
    pair = output / 'models/interface_pair'
    meta = json.loads((pair / 'meta_domain.json').read_text(encoding='utf-8'))
    for name in ('interface_pair', 'no_interface_pair', 'ACCO_actions_only', 'BIRT_actions_only', 'no_shared_identity'):
        task_dir = output / 'bundle/tasks' / name
        task_dir.mkdir(parents=True)
        model = output / 'models' / ('no_interface_pair' if name == 'no_interface_pair' else 'interface_pair')
        domain = parse_domain(model / 'meta_domain.pddl')
        problem = parse_sexpr((model / 'mapped_problem.pddl').read_text(encoding='utf-8'))
        if name.endswith('_actions_only'):
            retained = name.split('_')[0]
            keep = set(meta['action_maps'][retained].values())
            domain.actions = {key: action for key, action in domain.actions.items() if key in keep}
        if name == 'no_shared_identity':
            # Keep all objects, initial narrative atoms and the goal. Remove
            # only BIRT memberships for hero/token: initial BIRT:at remains a
            # factual assertion, but it cannot grant BIRT action membership.
            guards = {meta['type_guards'][typ] for typ in meta['namespaces']['BIRT']['types'].values()}
            initial = section(problem, ':init')
            initial[1:] = [fact for fact in initial[1:] if not (
                len(fact) == 2 and fact[0] in guards and fact[1] in ('q__hero', 'q__token'))]
        write_domain(domain, task_dir / 'domain.pddl')
        (task_dir / 'problem.pddl').write_text(serialize(problem) + '\n', encoding='utf-8')
        PDDLReader().parse_problem(str(task_dir / 'domain.pddl'), str(task_dir / 'problem.pddl'))
        tasks.append({'id': name, 'source': 'ACCO+BIRT_explicit_bridge', 'representation': name,
            'domain_sha256': sha(task_dir / 'domain.pddl'), 'problem_sha256': sha(task_dir / 'problem.pddl'),
            'action_templates': len(domain.actions),
            'control_scope': 'Single-source controls retain the common vocabulary, objects and goal; restrict action availability only. Not native-source goal tests.'})
    manifest = {'status': 'frozen_before_search', 'mode': 'matched_source_representations',
        'task_count': len(tasks), 'tasks': tasks, 'budget': {'seconds': 20, 'memory_mb': 4096, 'workers': 1},
        'original_query_sha256': sha(query_path), 'query_sha256': sha(output / 'query.json'),
        'initial': query['initial'], 'goal': query['goal'], 'objects': query['objects'],
        'source_problem_facts_imported': False, 'decision_basis': 'authored_assumption',
        'implementation_sha256': {str(p): sha(p) for p in [Path(__file__), Path('rcnc/aligned_domain.py'), Path('rcnc/narrative_pipeline.py')]},
        'scope': 'One authored bridge world and 4 matched controls; not 5 independent narrative cases; domains exported before search'}
    save(output / 'bundle/manifest.json', manifest)
    return manifest


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--matched', type=Path, default=Path('data/validation/meeting_matched_2026_10_20_v1'))
    parser.add_argument('--historical', type=Path, default=Path('data/validation/composed_development_2026_10_15_v1'))
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(prepare(args.matched, args.historical, args.output), indent=2))

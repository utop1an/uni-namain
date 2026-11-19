"""Reusable parameterized interface-chain domains and longer native-goal runs.

Chains are authored scalability controls, not new narrative families. Every
token must traverse every edge; no loops or no-op padding create long plans.
"""
import argparse
import json
from pathlib import Path

from scripts.experiments.frozen_solver import execute

from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def build_models(root, count):
    from rcnc.aligned_domain import build
    from rcnc.pddl import parse_sexpr, serialize
    inputs = root / 'inputs'
    inputs.mkdir(parents=True)
    names = [f'S{i:02d}' for i in range(count)]
    for name in names:
        text = f'''(define (domain {name}) (:requirements :strips :typing)
        (:types token stage) (:predicates (position ?t - token ?s - stage) (edge ?a - stage ?b - stage))
        (:action advance :parameters (?t - token ?a ?b - stage)
         :precondition (and (position ?t ?a) (edge ?a ?b))
         :effect (and (not (position ?t ?a)) (position ?t ?b))))\n'''
        (inputs / (name + '_domainfile.pddl')).write_text(text, encoding='utf-8')
    spec = {'version': 1, 'decision_basis': 'authored_assumption',
        'source_sha256': {p.name: digest(p) for p in inputs.glob('*.pddl')},
        'type_groups': [{'members': [n + ':' + typ for n in names], 'evidence': 'Explicit synthetic common role'}
                        for typ in ('token', 'stage')],
        'predicate_groups': [{'id': 'position_interface', 'members': [{'predicate': n + ':position', 'order': [0, 1]} for n in names],
                              'evidence': 'Authored token position relation, shared before any world is constructed'}]}
    models = {}
    for condition in ('shared', 'no_share'):
        local = {**spec, 'predicate_groups': spec['predicate_groups'] if condition == 'shared' else []}
        model = root / condition
        result = build(inputs, model, local)
        if not result['valid']:
            raise ValueError('Synthetic parameterized model did not parse')
        models[condition] = model
    model = root / 'remove_source'
    model.mkdir()
    metadata = read(models['shared'] / 'meta_domain.json')
    removed = set(metadata['action_maps'][names[0]].values())
    domain = parse_sexpr((models['shared'] / 'meta_domain.pddl').read_text(encoding='utf-8'))
    domain = [part for part in domain if not (isinstance(part, list) and part[0] == ':action' and part[1] in removed)]
    (model / 'meta_domain.pddl').write_text(serialize(domain) + '\n', encoding='utf-8')
    save(model / 'meta_domain.json', metadata)
    save(model / 'removal.json', {'removed_source': names[0], 'removed_actions': sorted(removed),
                                 'parent_sha256': digest(models['shared'] / 'meta_domain.pddl')})
    models['remove_source'] = model
    return models


def chain_query(count, tokens, length):
    names = [f'S{i:02d}' for i in range(count)]
    objects = {f't{i}': [n + ':token' for n in names] for i in range(tokens)}
    objects.update({f'p{i}': [n + ':stage' for n in names] for i in range(length + 1)})
    initial = [[names[0] + ':position', f't{i}', 'p0'] for i in range(tokens)]
    initial.extend([names[i % count] + ':edge', f'p{i}', f'p{i+1}'] for i in range(length))
    return {'objects': objects, 'initial': initial,
            'goal': {'positive': [[names[(length - 1) % count] + ':position', f't{i}', f'p{length}'] for i in range(tokens)]}}


def prepare(protocol_path, output):
    from rcnc.narrative_pipeline import map_problem
    from scripts.experiments.run_original_world_pipeline import convert_problem
    protocol = read(protocol_path)
    require_empty_output(output)
    output.mkdir(parents=True)
    save(output / 'protocol.json', protocol)
    tasks = []

    def task(identifier, domain, query, model, source, family, fields):
        folder = output / 'bundle/tasks' / identifier
        folder.mkdir(parents=True)
        row = {'id': identifier, 'source': source, 'representation': fields['condition'], 'family': family, **fields}
        tasks.append(row)
        try:
            (folder / 'domain.pddl').write_bytes(domain.read_bytes())
            if model:
                save(folder / 'query.json', query)
                mapped = map_problem(query, model, folder / 'problem.pddl')
                save(folder / 'query_mapping.json', mapped)
            else:
                (folder / 'problem.pddl').write_bytes(query.read_bytes())
            row.update(admission_status='ready', domain_sha256=digest(folder / 'domain.pddl'), problem_sha256=digest(folder / 'problem.pddl'))
        except Exception as exc:
            row.update(admission_status='admission_failed', reason=f'{type(exc).__name__}: {exc}')

    for count in protocol['source_counts']:
        models = build_models(output / 'models' / f'n{count}', count)
        for tokens in protocol['token_counts']:
            for length in protocol['chain_lengths']:
                query = chain_query(count, tokens, length)
                for condition in protocol['chain_conditions']:
                    model = models[condition]
                    task(f'chain_n{count}_t{tokens}_l{length}__{condition}', model / 'meta_domain.pddl', query, model,
                         'authored_chain', 'synthetic_scalability', {'condition': condition, 'source_count': count,
                         'tokens': tokens, 'chain_length': length, 'necessary_steps': tokens * length})
    source_root = Path(protocol['native_inputs'])
    for filename, expected in protocol['source_sha256'].items():
        if digest(source_root / filename) != expected:
            raise ValueError('Native input drift')
    for filename in sorted(protocol['source_sha256']):
        if not filename.endswith('_domainfile.pddl'):
            continue
        source = filename.removesuffix('_domainfile.pddl')
        domain, problem = source_root / filename, source_root / (source + '_problemfile.pddl')
        query = convert_problem(source, domain, problem)
        for condition in protocol['native_conditions']:
            if condition == 'native':
                task(source + '__native', domain, problem, None, source, 'original_goal', {'condition': condition})
            else:
                registered = protocol['native_models'][condition]
                model = Path(registered['path'])
                for name, expected in registered['sha256'].items():
                    if digest(model / name) != expected:
                        raise ValueError('Native comparison model drift')
                task(source + '__' + condition, model / 'meta_domain.pddl', query, model, source,
                     'original_goal', {'condition': condition})
    ready = [r for r in tasks if r['admission_status'] == 'ready']
    save(output / 'bundle/manifest.json', {'status': 'frozen_before_search', 'mode': 'matched_source_representations',
                                        'task_count': len(ready), 'tasks': ready})
    implementation = snapshot_implementation(output, [Path(__file__), *Path('rcnc').glob('*.py'),
        Path('scripts/experiments/run_original_world_pipeline.py'), Path('scripts/experiments/run_downward_reference.py'),
        Path('scripts/experiments/frozen_solver.py')])
    pins = {str(p): digest(p) for p in output.rglob('*') if p.is_file()}
    manifest = {'status': 'frozen_before_search', 'task_count': len(tasks), 'rows': tasks, 'input_sha256': pins,
                'implementation_sha256': implementation, 'budget': protocol['budget']}
    save(output / 'manifest.json', manifest)
    return manifest



if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--protocol', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--execute', action='store_true')
    args = parser.parse_args()
    result = execute(args.output) if args.execute else prepare(args.protocol, args.output)
    print(json.dumps({'status': result['status'], 'task_count': result['task_count']}))

"""Freeze synthetic positive-effect probes without altering source worlds."""
import argparse
import hashlib
import json
from pathlib import Path
import random

from rcnc.pddl import parse_domain, parse_sexpr, section, serialize, typed_symbols


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def positive_effects(expr):
    if expr[0] == 'and':
        return [atom for child in expr[1:] for atom in positive_effects(child)]
    if expr[0] == 'when':
        return positive_effects(expr[2])
    if expr[0] in ('not', 'forall'):
        return []
    return [expr]


def prepare(inputs, output, per_source=3, seed=20261015):
    if type(per_source) is not int or per_source < 1:
        raise ValueError('per_source must be positive')
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    output.mkdir(parents=True)
    tasks, coverage = [], []
    for path in sorted(inputs.glob('*_domainfile.pddl')):
        source = path.name.removesuffix('_domainfile.pddl')
        problem_path = inputs/(source+'_problemfile.pddl')
        domain = parse_domain(path)
        problem = parse_sexpr(problem_path.read_text(encoding='utf-8'))
        initial = section(problem, ':init')
        initial_atoms = {serialize(atom).lower() for atom in initial[1:]}
        objects = dict(domain.constants)
        object_section = section(problem, ':objects')
        if object_section:
            objects.update(typed_symbols(object_section[1:]))
        def compatible(actual, expected):
            visited = set()
            while actual != expected and actual != 'object':
                if actual in visited:
                    raise ValueError('Cyclic source type hierarchy')
                visited.add(actual)
                actual = domain.types[actual]
            return actual == expected
        candidates = {}
        omitted = []
        for name, action in sorted(domain.actions.items()):
            fields = {action[i]: action[i+1] for i in range(2, len(action), 2)}
            parameters = typed_symbols(fields.get(':parameters', []))
            generator = random.Random(int(hashlib.sha256(f'{seed}:{source}:{name}'.encode()).hexdigest(), 16))
            bindings = {}
            for variable, typ in parameters.items():
                choices = sorted(obj for obj, actual in objects.items() if compatible(actual, typ))
                if not choices:
                    omitted.append({'action': name, 'reason': 'empty_parameter_type'}); break
                bindings[variable] = generator.choice(choices)
            else:
                for atom in positive_effects(fields.get(':effect', ['and'])):
                    goal = [atom[0], *[bindings.get(term, term) for term in atom[1:]]]
                    if any(not isinstance(term, str) or term.startswith('?') for term in goal):
                        omitted.append({'action': name, 'reason': 'unbound_or_nested_effect'}); continue
                    key = serialize(goal).lower()
                    if key not in initial_atoms:
                        candidates.setdefault(key, {'goal': goal, 'producer_action': name, 'binding': bindings})
        ranked = sorted(candidates, key=lambda key: hashlib.sha256(f'{seed}:{source}:{key}'.encode()).hexdigest())
        chosen = ranked[:per_source]
        coverage.append({'source': source, 'candidate_goals': len(ranked), 'selected': len(chosen),
                         'omitted_candidates': len(ranked)-len(chosen), 'unsupported_or_empty_actions': omitted})
        for index, key in enumerate(chosen):
            candidate = candidates[key]
            task_id = source+'__probe_'+str(index)
            directory = output/'tasks'/task_id
            directory.mkdir(parents=True)
            (directory/'domain.pddl').write_bytes(path.read_bytes())
            (directory/'original_problem.pddl').write_bytes(problem_path.read_bytes())
            goal_section = section(problem, ':goal')
            original_goal = goal_section[1]
            goal_section[1] = ['and', candidate['goal']]
            (directory/'problem.pddl').write_text(serialize(problem)+'\n', encoding='utf-8')
            goal_section[1] = original_goal
            tasks.append({'id': task_id, 'source': source, 'goal': candidate['goal'],
                'producer_action_for_candidate_only': candidate['producer_action'], 'sampled_binding': candidate['binding'],
                'domain_sha256': sha(directory/'domain.pddl'), 'problem_sha256': sha(directory/'problem.pddl'),
                'original_problem_sha256': sha(problem_path), 'initial_ast_sha256': hashlib.sha256(serialize(initial).encode()).hexdigest()})
    manifest = {'version': 1, 'status': 'frozen_before_search', 'tasks': tasks, 'task_count': len(tasks),
        'seed': seed, 'per_source': per_source, 'coverage': coverage,
        'scope': 'Synthetic development probes from observed models; original goals remain separately evaluated',
        'candidate_policy': 'One seeded typed binding per action; positive non-universal effects; remove initially true targets; hash-ranked unique targets',
        'world_policy': 'Preserve original initial-state AST, objects, constants and complete source actions; replace only goal',
        'limit': 'Candidate producer may be unreachable; a solved probe is not original-goal success or independent generalization',
        'implementation_sha256': sha(Path(__file__))}
    (output/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
    return manifest


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inputs', type=Path, default=Path('data/narra-domains'))
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--per-source', type=int, default=3)
    args = parser.parse_args()
    result = prepare(args.inputs, args.output, args.per_source)
    print(json.dumps({k: v for k, v in result.items() if k != 'tasks'}, indent=2))

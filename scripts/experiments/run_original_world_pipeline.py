"""Frozen API regression on each original source world, never pooled worlds.

The benchmark adapter explicitly supplies one original problem's facts/goals.
The pipeline itself receives domain-only inputs and cannot import problem facts.
"""
import argparse
from collections import Counter
import copy
import json
from pathlib import Path
import re
import time

from rcnc.domain_building import require_empty_output, save, snapshot_implementation
from rcnc.narrative_pipeline import run as run_query
from rcnc.pddl import parse_domain, parse_sexpr, section, typed_symbols
from scripts.experiments.run_downward_reference import sha


def convert_problem(source, domain_path, problem_path):
    domain = parse_domain(domain_path)
    problem = parse_sexpr(problem_path.read_text(encoding='utf-8'))
    if not isinstance(problem, list) or not problem or problem[0] != 'define':
        raise ValueError('Expected an original PDDL problem definition')
    allowed = {'problem', ':domain', ':objects', ':init', ':goal', ':requirements'}
    if any(not isinstance(part, list) or not part or part[0] not in allowed for part in problem[1:]):
        raise ValueError('Unsupported problem section; do not strip semantics')
    initial, goal = section(problem, ':init'), section(problem, ':goal')
    if initial is None or goal is None or len(goal) != 2:
        raise ValueError('Explicit original initial state and goal required')
    declarations = section(problem, ':objects')
    objects = typed_symbols(declarations[1:]) if declarations is not None else {}
    object_names = {name.lower(): source + ':' + typ for name, typ in objects.items()}
    if len(object_names) != len(objects) or any(not re.fullmatch(r'[a-z][a-z0-9_-]*', n) for n in object_names):
        raise ValueError('Ambiguous or unsupported request object names')
    constants = {name.lower() for name in domain.constants}
    predicates = {name.lower() for name in domain.predicates}
    if constants & set(object_names):
        raise ValueError('Problem objects collide with source constants')

    def atom(value):
        if (not isinstance(value, list) or not value or not isinstance(value[0], str)
                or value[0].lower() not in predicates or any(not isinstance(term, str) for term in value[1:])):
            raise ValueError('Only explicit ground predicate atoms are supported')
        terms = []
        for term in value[1:]:
            if term.lower() in object_names:
                terms.append(term.lower())
            elif term.lower() in constants:
                terms.append(source + ':' + term)
            else:
                raise ValueError('Unknown original-world term: ' + term)
        return [source + ':' + value[0], *terms]

    positive, negative = [], []
    def clauses(value):
        if isinstance(value, list) and value and value[0] == 'and':
            for child in value[1:]:
                clauses(child)
        elif isinstance(value, list) and len(value) == 2 and value[0] == 'not':
            negative.append(atom(value[1]))
        else:
            positive.append(atom(value))
    clauses(goal[1])
    return {'objects': object_names, 'initial': [atom(fact) for fact in initial[1:]],
            'goal': {'positive': positive, 'negative': negative}}


def freeze(inputs, alignment_path, output):
    require_empty_output(output)
    domains = sorted(inputs.glob('*_domainfile.pddl'))
    if len(domains) != 15:
        raise ValueError('This development protocol requires the fixed 15-source pool')
    alignment = json.loads(alignment_path.read_text(encoding='utf-8'))
    output.mkdir(parents=True)
    snapshots, domain_inputs = output / 'inputs', output / 'domain_inputs'
    snapshots.mkdir()
    domain_inputs.mkdir()
    save(output / 'alignment.json', alignment)
    tasks = []
    for path in domains:
        source = path.name.removesuffix('_domainfile.pddl')
        if alignment['source_sha256'].get(path.name) != sha(path):
            raise ValueError('Alignment/source freeze mismatch')
        (snapshots / path.name).write_bytes(path.read_bytes())
        (domain_inputs / path.name).write_bytes(path.read_bytes())
        problem = inputs / (source + '_problemfile.pddl')
        if problem.is_file():
            (snapshots / problem.name).write_bytes(problem.read_bytes())
        try:
            base = convert_problem(source, snapshots / path.name, snapshots / problem.name)
            admission, reason = 'supported', None
        except Exception as exc:
            base, admission, reason = None, 'unsupported_input', f'{type(exc).__name__}: {exc}'
        for policy in ('all_domains', 'static_universe_components'):
            query = copy.deepcopy(base)
            if query is not None:
                query.update(alignment=alignment, selection=policy, solver='fast_downward', seconds=20, memory_mb=4096)
            tasks.append({'id': source + '__' + policy, 'source': source, 'policy': policy,
                'admission_status': admission, 'admission_reason': reason, 'query': query,
                'source_problem_sha256': sha(snapshots / problem.name) if problem.is_file() else None})
    code = [Path(__file__), Path('rcnc/__main__.py'), Path('scripts/experiments/run_downward_reference.py'),
            *sorted(Path('rcnc').glob('*.py'))]
    implementation = snapshot_implementation(output, code)
    manifest = {'status': 'frozen_before_search', 'task_count': 30, 'source_count': 15, 'tasks': tasks,
        'source_sha256': {p.name: sha(p) for p in sorted(snapshots.glob('*.pddl'))},
        'domain_input_sha256': {p.name: sha(p) for p in sorted(domain_inputs.glob('*.pddl'))},
        'implementation_sha256': implementation, 'alignment_sha256': sha(output / 'alignment.json'),
        'budget': {'seconds_per_search': 20, 'memory_mb': 4096, 'workers': 1},
        'world_origin': 'One original benchmark problem per instance, explicitly converted into request facts/goal. No pooling or inferred facts; domain-only pipeline input directory.',
        'interface_status': 'Fixed existing machine hypotheses; not independent semantic labels',
        'scope': 'Known 15-source development regression; original goals and all admission/search failures retained, not independent-family generalization'}
    save(output / 'frozen_queries.json', manifest)
    return manifest


def run(inputs, alignment, output):
    manifest = freeze(inputs, alignment, output)
    frozen_hash = sha(output / 'frozen_queries.json')
    report = {'status': 'running', 'task_count': 30, 'frozen_queries_sha256': frozen_hash, 'rows': []}
    save(output / 'report.json', report)
    for task in manifest['tasks']:
        row = {k: task[k] for k in ('id', 'source', 'policy', 'admission_status')}
        if task['admission_status'] != 'supported':
            row.update(status='unsupported_input', reason=task['admission_reason'], planner_called=False)
        else:
            directory = output / 'runs' / task['id']
            start = time.perf_counter()
            result = run_query(task['query'], output / 'domain_inputs', directory)
            search = result.get('search', {})
            row.update(status=result['status'], elapsed_seconds=time.perf_counter() - start,
                planner_called=result['planner_called'], reason=result.get('reason'),
                domain_unchanged=result.get('domain_unchanged'),
                selected_sources=result.get('selection', {}).get('selected'),
                validation=search.get('validation', {}).get('status'), plan_length=search.get('length'))
            if (directory / 'manifest.json').is_file():
                run_manifest = json.loads((directory / 'manifest.json').read_text(encoding='utf-8'))
                row.update(planning_domain=run_manifest['planning_domain'],
                    domain_sha256=run_manifest['domain_sha256'], problem_sha256=run_manifest['problem_sha256'])
        report['rows'].append(row)
        report['status_counts'] = dict(Counter(r['status'] for r in report['rows']))
        save(output / 'report.json', report)
        print(json.dumps(row), flush=True)
    report.update(status='complete', sources_unchanged=all(sha(output / 'inputs' / p) == h for p, h in manifest['source_sha256'].items()),
        domain_inputs_unchanged=all(sha(output / 'domain_inputs' / p) == h for p, h in manifest['domain_input_sha256'].items()),
        implementation_unchanged=all(sha(Path(p)) == h for p, h in manifest['implementation_sha256'].items()),
        frozen_queries_unchanged=sha(output / 'frozen_queries.json') == frozen_hash, scope=manifest['scope'])
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inputs', type=Path, default=Path('data/narra-domains'))
    parser.add_argument('--alignment', type=Path, default=Path('data/validation/meeting_matched_2026_10_20_v1/alignment.json'))
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    report = run(args.inputs, args.alignment, args.output)
    print(json.dumps({k: v for k, v in report.items() if k != 'rows'}, indent=2))

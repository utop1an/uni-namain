"""Conditionally freeze all original worlds against one completed cached root.

Never fills the unavailable fresh-construction comparison slots. Each source
world stays explicit and separate; only the reference's recorded renaming is used.
"""
import argparse
from collections import Counter
import copy
from datetime import datetime, timezone
import json
from pathlib import Path

from unified_planning.io import PDDLReader
from rcnc.domain_building import require_empty_output, save, snapshot_implementation
from rcnc.pddl import parse_domain, parse_sexpr, section
from scripts.experiments.run_downward_reference import run as run_solver, sha


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def renaming_injectivity(predicates, constants):
    """Keep source distinctions in an original-world comparison, modulo case."""
    result = {}
    for category, mapping in (('predicate',predicates),('constant',constants)):
        if not isinstance(mapping,dict) or any(not isinstance(value,str) for value in mapping.values()):
            raise ValueError('Explicit string symbol maps required')
        result['source_' + category + '_map_injective'] = len({value.lower() for value in mapping.values()}) == len(mapping)
    return result


def renamed_world(raw, target_name, predicates, constants):
    """Check all source sections with changes restricted to exporter renaming."""
    expected = copy.deepcopy(raw)
    declaration = section(expected, ':domain')
    if declaration is None or section(expected, ':init') is None or section(expected, ':goal') is None:
        raise ValueError('Explicit source domain, initial state and goal required')
    if not all(renaming_injectivity(predicates,constants).values()):
        raise ValueError('Non-injective source mappings require a separate world-abstraction condition')
    declaration[1] = target_name
    def formula(expr):
        if not isinstance(expr, list) or not expr:
            return expr
        head = expr[0]
        if head in ('and', 'or', 'not', 'imply', 'when'):
            return [head, *[formula(child) for child in expr[1:]]]
        if head in ('forall', 'exists'):
            return [head, copy.deepcopy(expr[1]), formula(expr[2])]
        return [predicates.get(head, head),
                *[constants.get(term, term) if isinstance(term, str) else formula(term) for term in expr[1:]]]
    for key in (':init', ':goal'):
        part = section(expected, key)
        part[1:] = [formula(expr) for expr in part[1:]]
    return expected


def prepare(protocol_path, output):
    require_empty_output(output)
    protocol = read(protocol_path)
    reference = Path(protocol['parent'])
    parent, terminal = read(reference / 'manifest.json'), read(reference / 'report.json')
    required = ('source_snapshot_unchanged', 'implementation_unchanged', 'imported_cache_unchanged',
                'predecessor_cache_unchanged', 'predecessor_report_unchanged')
    if (parent['status'] != 'complete' or terminal['status'] != 'complete'
            or not all(terminal.get(key) is True for key in required)):
        raise ValueError('Only an intact completed cached-root condition is admissible')
    validation = read(reference / 'fusion/validation.json')
    if validation.get('valid') is not True or terminal.get('validation') != validation:
        raise ValueError('Matching successful final validation required')
    if parent['source_sha256'] != protocol['source_sha256']:
        raise ValueError('Registered source world inventory changed')
    for name, expected in protocol['source_sha256'].items():
        if sha(reference / 'inputs' / name) != expected:
            raise ValueError('Frozen source input changed')
    model = reference / 'fusion'
    metadata = read(model / 'meta_domain.json')
    sources = sorted(name.removesuffix('_domainfile.pddl') for name in protocol['source_sha256'] if name.endswith('_domainfile.pddl'))
    if len(sources) != protocol['source_count'] or set(metadata['sources']) != set(sources):
        raise ValueError('Complete registered source cohort required')
    target = parse_domain(model / 'meta_domain.pddl')
    PDDLReader().parse_problem(str(model / 'meta_domain.pddl'))
    output.mkdir(parents=True)
    (output / 'protocol.json').write_bytes(protocol_path.read_bytes())
    for name in ('manifest.json', 'report.json'):
        (output / ('parent_' + name)).write_bytes((reference / name).read_bytes())
    (output / 'parent_validation.json').write_bytes((model / 'validation.json').read_bytes())
    snapshot = output / 'model'; snapshot.mkdir()
    for name in ('meta_domain.pddl', 'meta_domain.json'):
        (snapshot / name).write_bytes((model / name).read_bytes())
    inputs = output / 'inputs'; inputs.mkdir()
    for name in protocol['source_sha256']:
        (inputs / name).write_bytes((reference / 'inputs' / name).read_bytes())
    slots, tasks = [], []
    for source in sources:
        slot = {'id': source, 'source': source, 'admission_status': 'ready'}
        try:
            original = parse_domain(inputs / (source + '_domainfile.pddl'))
            predicates = metadata['predicate_maps'][source]
            constants = metadata['constant_maps'][source]
            if set(predicates) != set(original.predicates) or set(constants) != set(original.constants):
                raise ValueError('Complete source predicate/constant transport required')
            if any(name not in target.predicates or original.predicates[p].arity != target.predicates[name].arity for p, name in predicates.items()):
                raise ValueError('No complete arity-preserving positional predicate transport')
            if set(constants.values()) - set(target.constants):
                raise ValueError('Mapped source constant missing')
            raw = parse_sexpr((inputs / (source + '_problemfile.pddl')).read_text(encoding='utf-8'))
            exported = model / 'problems' / (source + '_problemfile.pddl')
            actual = parse_sexpr(exported.read_text(encoding='utf-8'))
            if actual != renamed_world(raw, target.name, predicates, constants):
                raise ValueError('Exported source world differs beyond recorded positional renaming')
            PDDLReader().parse_problem(str(snapshot / 'meta_domain.pddl'), str(exported))
            directory = output / 'bundle/tasks' / source; directory.mkdir(parents=True)
            (directory / 'domain.pddl').write_bytes((snapshot / 'meta_domain.pddl').read_bytes())
            (directory / 'problem.pddl').write_bytes(exported.read_bytes())
            slot.update(domain_sha256=sha(directory / 'domain.pddl'), problem_sha256=sha(directory / 'problem.pddl'))
            tasks.append({**slot, 'representation': 'cached_final_model_original_goal'})
        except Exception as exc:
            slot.update(admission_status='unsupported_transport', reason=f'{type(exc).__name__}: {exc}')
        slots.append(slot)
    bundle = output / 'bundle'; bundle.mkdir(exist_ok=True)
    save(bundle / 'manifest.json', {'status': 'frozen_before_search', 'mode': 'matched_source_representations',
        'task_count': len(tasks), 'tasks': tasks})
    code = snapshot_implementation(output, [Path(__file__), Path('scripts/experiments/run_downward_reference.py'),
        Path('rcnc/domain_building.py'), Path('rcnc/pddl.py'), Path('rcnc/validation.py')])
    files = [p for p in output.rglob('*') if p.is_file() and 'implementation' not in p.relative_to(output).parts]
    manifest = {'status': 'frozen_before_search', 'task_count': len(slots), 'slots': slots,
        'input_sha256': {p.relative_to(output).as_posix(): sha(p) for p in files}, 'implementation_sha256': code,
        'protocol_sha256': sha(output / 'protocol.json'), 'budget': protocol['budget'], 'deadline': protocol['deadline'],
        'scope': protocol['comparison_boundary']}
    save(output / 'manifest.json', manifest)
    return manifest


def execute(output):
    manifest = read(output / 'manifest.json')
    if manifest['status'] != 'frozen_before_search' or (output / 'report.json').exists() or (output / 'solver').exists():
        raise ValueError('Only an unexecuted frozen source-world registry may run')
    for name, expected in manifest['input_sha256'].items():
        if sha(output / name) != expected: raise ValueError('Frozen input changed')
    for name, expected in manifest['implementation_sha256'].items():
        if sha(Path(name)) != expected: raise ValueError('Implementation changed after freeze')
    budget = manifest['budget']
    deadline = datetime.fromisoformat(manifest['deadline'].replace('Z', '+00:00'))
    enough = (deadline - datetime.now(timezone.utc)).total_seconds() >= manifest['task_count'] * (budget['seconds_wall_and_cpu'] + budget['supervisor_grace_seconds_each']) + 600
    ready = sum(slot['admission_status'] == 'ready' for slot in manifest['slots'])
    solver = run_solver(Path('.'), None, output / 'solver', Path('.tmp/fast-downward-26.6'),
        budget['seconds_wall_and_cpu'], budget['memory_mb'], task_bundle=output / 'bundle') if enough and ready else None
    indexed = {r['id']: r for r in solver['rows']} if solver else {}
    rows = [{**slot, **(indexed[slot['id']] if slot['id'] in indexed else {
        'status': slot['admission_status'] if enough else 'not_run_due_goal_budget'})} for slot in manifest['slots']]
    report = {'status': 'complete', 'task_count': len(rows), 'rows': rows,
        'actual_solver_calls': len(indexed), 'status_counts': dict(Counter(r['status'] for r in rows)),
        'manifest_sha256': sha(output / 'manifest.json'),
        'inputs_unchanged': all(sha(output / n) == h for n, h in manifest['input_sha256'].items()),
        'implementation_unchanged': all(sha(Path(n)) == h for n, h in manifest['implementation_sha256'].items()),
        'solver_integrity': (solver['status'] == 'complete'
            and set(indexed) == {s['id'] for s in manifest['slots'] if s['admission_status'] == 'ready'}
            and all(solver.get(k) is True for k in ('binary_unchanged', 'runner_unchanged', 'implementation_unchanged', 'validator_unchanged'))
            and all(r.get('inputs_unchanged') is True for r in solver['rows'])) if solver else True,
        'scope': manifest['scope']}
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--protocol', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--execute-frozen', action='store_true')
    args = parser.parse_args()
    result = execute(args.output) if args.execute_frozen else prepare(args.protocol, args.output)
    print(json.dumps({k: v for k, v in result.items() if k not in ('rows', 'slots', 'input_sha256', 'implementation_sha256')}, indent=2))

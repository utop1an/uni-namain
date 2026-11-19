"""Compile shared typed domains and solve separately supplied physical worlds."""
import argparse
from copy import deepcopy
import json
from pathlib import Path
import subprocess
import sys

from .domain_building import digest, save
from .glaive_merge import Source, build
from .pddl import parse_sexpr, serialize, section, typed_symbols
from .shared_types import map_world


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8-sig'))


def physical_inputs(domain, problem):
    """Checked physical projection, with type-only alpha-renaming for UP.

    PDDL types and objects can share a spelling; UP's default namespace cannot.
    Rename conflicting type declarations and references, never object terms.
    Keep the reusable native domain untouched and return the explicit map.
    """
    from scripts.experiments.run_matched_unidomain_rule import physical_domain, physical_problem
    domain, problem = physical_domain(deepcopy(domain)), physical_problem(deepcopy(problem))
    # Glaive exports repeat requirements in the problem; UP expects them only
    # in the unchanged domain requirements section.
    problem = [x for x in problem if not (isinstance(x, list) and x[:1] == [':requirements'])]
    types = set(typed_symbols((section(domain, ':types') or [':types'])[1:]))
    names = set(typed_symbols((section(problem, ':objects') or [':objects'])[1:]))
    names.update(typed_symbols((section(domain, ':constants') or [':constants'])[1:]))
    names.update(x[1] for x in domain if isinstance(x, list) and x[:1] == [':action'])
    names.update(p[0] for p in section(domain, ':predicates')[1:])
    renaming = {}; occupied = types | names
    for name in sorted(types & names):
        target = 'type_' + name
        while target in occupied:
            target = 'type_' + target
        renaming[name] = target; occupied.add(target)

    def declaration(tokens):
        for i in range(1, len(tokens)):
            if tokens[i - 1] == '-':
                tokens[i] = renaming.get(tokens[i], tokens[i])

    def walk(expr):
        if not isinstance(expr, list) or not expr:
            return
        if expr[0] in ('forall', 'exists'):
            declaration(expr[1])
        for child in expr:
            walk(child)

    for root in (domain, problem):
        for expr in root:
            if not isinstance(expr, list) or not expr:
                continue
            if expr[0] == ':types':
                expr[1:] = [renaming.get(x, x) for x in expr[1:]]
            elif expr[0] in (':objects', ':constants'):
                declaration(expr)
            elif expr[0] == ':predicates':
                for predicate in expr[1:]:
                    declaration(predicate)
            elif expr[0] in (':action', ':axiom'):
                for field in (':parameters', ':vars'):
                    if field in expr:
                        declaration(expr[expr.index(field) + 1])
            walk(expr)
    return domain, problem, renaming


def build_main(argv=None, *, prog=None):
    parser = argparse.ArgumentParser(prog=prog, description='Compile a reusable domain with native shared PDDL types, before search.')
    parser.add_argument('--sources', type=Path, required=True, help='JSON list of {id, domain, problem}, paths relative to this manifest')
    parser.add_argument('--types', type=Path, required=True, help='Versioned type hierarchy, source maps, evidence and hashes')
    parser.add_argument('--alignments', type=Path, help='Existing predicate/action judgment groups as a JSON list')
    parser.add_argument('--merge-actions', action='store_true')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args(argv)
    sources = []
    for row in read(args.sources):
        source = Source(row['id'], (args.sources.parent / row['domain']).resolve(),
                        (args.sources.parent / row['problem']).resolve(),
                        constant_contract=row.get('constant_contract'), consent_policy=row.get('consent_policy'))
        if any(s.id == source.id for s in sources):
            raise ValueError('Duplicate source id: ' + source.id)
        sources.append(source)
    if not sources:
        raise ValueError('At least one source is required')
    groups = read(args.alignments) if args.alignments else []
    meta = build(sources, args.output, groups=groups, merge_actions=args.merge_actions, type_alignment=read(args.types))
    save(args.output / 'build_inputs.json', {
        'source_manifest': str(args.sources.resolve()), 'source_manifest_sha256': digest(args.sources),
        'types_sha256': digest(args.types), 'alignments_sha256': digest(args.alignments) if args.alignments else None,
        'domain_sha256': digest(args.output / 'domain.pddl'), 'mapping_sha256': digest(args.output / 'mapping.json'),
        'planner_called': False, 'type_encoding': meta['type_encoding']})
    print(json.dumps({'status': 'compiled', 'type_encoding': meta['type_encoding'], 'action_count': meta['action_count'],
                      'output': str(args.output)}, indent=2))


def run(compiled, world, output, *, seconds=25, max_states=5000, max_depth=20,
        max_ground_actions=100000, max_ground_fluents=100000, active_sources=None):
    compiled, output = Path(compiled), Path(output)
    if output.exists():
        raise ValueError('Use a fresh shared-type planning output directory')
    if not isinstance(world, dict):
        raise ValueError('World must be a JSON object')
    if 'facts' not in world or world['facts'] is None:
        return {'status': 'needs_initial_state', 'planner_called': False}
    if type(seconds) not in (int, float) or not 0 < seconds <= 3600:
        raise ValueError('seconds must be positive and at most 3600')
    budget = {'max_states': max_states, 'max_depth': max_depth, 'max_ground_actions': max_ground_actions,
              'max_ground_fluents': max_ground_fluents}
    if any(type(v) is not int or v < (0 if k == 'max_depth' else 1) for k, v in budget.items()):
        raise ValueError('Invalid search budget')
    meta = read(compiled / 'mapping.json')
    if meta.get('type_encoding') != 'native_shared':
        raise ValueError('Use build-shared to compile this domain first')
    if meta.get('compiled_domain_sha256') != digest(compiled / 'domain.pddl'):
        raise ValueError('Compiled domain differs from its saved metadata')
    if meta.get('axiom_count', 0):
        raise ValueError('This physical search adapter does not execute native axioms; use a compatible native executor')
    output.mkdir(parents=True)
    save(output / 'world.json', world)
    mapped = map_world(meta, world, output / 'authored_problem.pddl', active_sources=active_sources)
    save(output / 'world_mapping.json', mapped)
    # The existing adapter checks that intentions do not occur in physical
    # preconditions or goals. It retains conditional and quantified effects.
    domain, problem, type_renaming = physical_inputs(
        parse_sexpr((compiled / 'domain.pddl').read_text(encoding='utf-8')),
        parse_sexpr((output / 'authored_problem.pddl').read_text(encoding='utf-8')))
    for name, value in [('domain.pddl', domain), ('problem.pddl', problem)]:
        (output / name).write_text(serialize(value) + '\n', encoding='utf-8')
    from unified_planning.io import PDDLReader
    PDDLReader().parse_problem(str(output / 'domain.pddl'), str(output / 'problem.pddl'))
    solver = 'state_projected' if mapped['mode'] == 'initial_goal' else 'typed_cartesian'
    if solver == 'state_projected':
        budget['correlated_parameter_tuples'] = True
    else:
        budget['max_outcomes'] = 3
    manifest = {
        'status': 'frozen_before_search', 'compiled_domain_sha256': digest(compiled / 'domain.pddl'),
        'mapping_sha256': digest(compiled / 'mapping.json'),
        'input_sha256': {name: digest(output / name) for name in
                         ['domain.pddl', 'problem.pddl', 'world.json', 'world_mapping.json', 'authored_problem.pddl']},
        'mode': mapped['mode'], 'solver': solver, 'budget': budget, 'seconds': seconds,
        'physical_type_renaming': type_renaming,
        'scope': 'Physical search in the shared-type model; no intention or independent semantic validation.'}
    root = Path(__file__).resolve().parents[1]
    manifest['implementation_sha256'] = {str(p.relative_to(root)): digest(p) for p in sorted((root / 'rcnc').glob('*.py'))}
    save(output / 'manifest.json', manifest)
    command = [sys.executable, '-m', 'rcnc', 'plan', '--worker', '--mode', mapped['mode'], '--solver', solver,
               '--domain', str((output / 'domain.pddl').resolve()), '--problem', str((output / 'problem.pddl').resolve()),
               '--output', str((output / 'search').resolve()), '--budget', json.dumps(budget)]
    with (output / 'worker.log').open('w', encoding='utf-8') as log:
        try:
            process = subprocess.run(command, cwd=root, stdout=log, stderr=subprocess.STDOUT, timeout=seconds)
            path = output / 'search/search.json'
            result = read(path) if path.exists() else {'status': 'worker_error', 'returncode': process.returncode}
        except subprocess.TimeoutExpired:
            result = {'status': 'wall_time_limit'}
    unchanged = all(digest(output / name) == h for name, h in manifest['input_sha256'].items())
    unchanged &= digest(compiled / 'domain.pddl') == manifest['compiled_domain_sha256']
    unchanged &= digest(compiled / 'mapping.json') == manifest['mapping_sha256']
    implementation_unchanged = all(digest(root / name) == h for name, h in manifest['implementation_sha256'].items())
    result = {'status': result['status'] if unchanged and implementation_unchanged else 'artifact_changed', 'search': result,
              'planner_called': True, 'inputs_unchanged': unchanged, 'type_encoding': 'native_shared',
              'implementation_unchanged': implementation_unchanged,
              'source_problem_facts_copied': 0, 'scope': manifest['scope']}
    save(output / 'result.json', result)
    return result


def plan_main(argv=None, *, prog=None):
    parser = argparse.ArgumentParser(prog=prog, description='Plan in a saved shared-type domain from an explicit world.')
    parser.add_argument('--compiled', type=Path, required=True)
    parser.add_argument('--world', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--seconds', type=float, default=25)
    parser.add_argument('--max-states', type=int, default=5000)
    parser.add_argument('--max-depth', type=int, default=20)
    parser.add_argument('--max-ground-actions', type=int, default=100000)
    parser.add_argument('--max-ground-fluents', type=int, default=100000)
    args = parser.parse_args(argv)
    result = run(args.compiled, read(args.world), args.output, seconds=args.seconds, max_states=args.max_states,
                 max_depth=args.max_depth, max_ground_actions=args.max_ground_actions, max_ground_fluents=args.max_ground_fluents)
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result['status'] in {'solved', 'outcomes_generated'} else 1)

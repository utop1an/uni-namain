"""Finite exhaustive controls for static-universe source-component selection.

These authored finite models test an engineering boundary, not independent
semantic correctness, source provenance, or a general preservation theorem.
"""
import argparse
from collections import Counter, deque
import itertools
import json
from pathlib import Path

from unified_planning.io import PDDLReader
from unified_planning.engines.compilers.grounder import GrounderHelper
from unified_planning.shortcuts import SequentialSimulator
from rcnc.aligned_domain import build
from rcnc.component_selection import restrict
from rcnc.domain_building import require_empty_output, save, snapshot_implementation
from rcnc.grounding import StaticSafeGrounding
from rcnc.narrative_pipeline import map_problem
from rcnc.pddl import parse_domain, write_domain
from scripts.experiments.run_downward_reference import sha


def reachable(problem, max_states=1024):
    grounder = StaticSafeGrounding(problem)
    simplifier = GrounderHelper(problem, prune_actions=True)
    candidates = [(action, params) for action in problem.actions for params in grounder.parameters(action)
                  if simplifier.ground_action(action, params) is not None]
    if len(candidates) > 1000:
        return {'status': 'ground_action_limit', 'ground_actions': len(candidates)}
    with SequentialSimulator(problem) as simulator:
        start = simulator.get_initial_state()
        queue, seen = deque([start]), {start}
        while queue:
            state = queue.popleft()
            if simulator.is_goal(state):
                return {'status': 'reachable', 'states': len(seen)}
            for action, params in candidates:
                after = simulator.apply(state, action, params)
                if after is None or after in seen:
                    continue
                if len(seen) >= max_states:
                    return {'status': 'state_limit', 'states': len(seen)}
                seen.add(after)
                queue.append(after)
        return {'status': 'unreachable', 'states': len(seen)}


def freeze(output):
    require_empty_output(output)
    output.mkdir(parents=True)
    cases = []
    for scenario in ('unary_disjoint', 'unary_shared', 'nullary_disjoint'):
        arity = 0 if scenario.startswith('nullary') else 1
        directory = output / 'models' / scenario
        inputs = directory / 'inputs'
        inputs.mkdir(parents=True)
        predicate = '(signal)' if arity == 0 else '(signal ?p - person)'
        occurrence = '(signal)' if arity == 0 else '(signal ?p)'
        texts = {'A': f'(:predicates {predicate} (done ?p - person)) '
                    f'(:action finish :parameters (?p - person) :precondition {occurrence} :effect (done ?p))',
                 'B': f'(:predicates {predicate} (ready ?p - person)) '
                    f'(:action emit :parameters (?p - person) :precondition (ready ?p) :effect {occurrence})',
                 'C': '(:predicates (done ?p - person)) '
                    '(:action distract :parameters (?p - person) :precondition (and) :effect (done ?p))'}
        for source, text in texts.items():
            (inputs / (source + '_domainfile.pddl')).write_text(
                f'(define (domain {source}) (:requirements :strips :typing) (:types person - object) {text})', encoding='utf-8')
        specification = {'version': 1, 'decision_basis': 'authored_assumption',
            'source_sha256': {p.name: sha(p) for p in inputs.glob('*.pddl')},
            'type_groups': [{'members': ['A:person', 'B:person'], 'evidence': 'Synthetic role by construction'}],
            'predicate_groups': [{'id': 'signal', 'evidence': 'Synthetic shared signal by construction',
                'members': [{'predicate': s + ':signal', 'order': list(range(arity))} for s in ('A', 'B')]}]}
        compiled = directory / 'compiled'
        build(inputs, compiled, specification)
        meta = json.loads((compiled / 'meta_domain.json').read_text(encoding='utf-8'))
        for composed in (False, True):
            label = 'multi_goal' if composed else 'single_goal'
            case = directory / label
            case.mkdir()
            query = {'alignment': specification,
                'objects': {'x': ['A:person', 'B:person'] if scenario == 'unary_shared' else 'A:person',
                            'y': 'B:person', 'z': 'C:person'},
                'initial': [], 'goal': {'positive': [['A:done', 'x']] + ([['C:done', 'z']] if composed else [])}}
            save(case / 'query.json', query)
            map_problem(query, compiled, case / 'problem.pddl')
            certificate = restrict(query, compiled, case / 'problem.pddl', case / 'selected.pddl')
            save(case / 'certificate.json', certificate)
            # Freeze a known-bad seed-only policy before any valuation search.
            mutant = parse_domain(compiled / 'meta_domain.pddl')
            seeds = {'A', 'C'} if composed else {'A'}
            keep = {name for source in seeds for name in meta['action_maps'][source].values()}
            mutant.actions = {name: action for name, action in mutant.actions.items() if name in keep}
            write_domain(mutant, case / 'seed_only_mutant.pddl')
            dynamic = [[meta['predicate_maps']['A']['done'], 'q__x'],
                       [meta['predicate_maps']['C']['done'], 'q__z'],
                       [meta['predicate_maps']['B']['ready'], 'q__y']]
            if scenario == 'unary_shared':
                dynamic.append([meta['predicate_maps']['B']['ready'], 'q__x'])
            if arity:
                dynamic += [[meta['predicate_maps']['A']['signal'], 'q__' + obj] for obj in ('x', 'y', 'z')]
            else:
                dynamic.append([meta['predicate_maps']['A']['signal']])
            cases.append({'id': scenario + '__' + label, 'scenario': scenario,
                'directory': case.relative_to(output).as_posix(),
                'full_domain': (compiled / 'meta_domain.pddl').relative_to(output).as_posix(),
                'dynamic_atoms': dynamic, 'valuation_count': 2 ** len(dynamic),
                'selected_sources': certificate['selected_sources'],
                'mutant_must_be_detected': scenario != 'unary_disjoint'})
    files = [p for p in output.rglob('*') if p.is_file()]
    code = [Path(__file__), Path('rcnc/component_selection.py'), Path('rcnc/world_source_selection.py'),
            Path('rcnc/aligned_domain.py'), Path('rcnc/grounding.py'), Path('rcnc/pddl.py'), Path('rcnc/domain_building.py')]
    implementation = snapshot_implementation(output, code)
    manifest = {'status': 'frozen_before_search', 'cases': cases, 'case_count': len(cases),
        'valuation_count': sum(c['valuation_count'] for c in cases),
        'input_sha256': {p.relative_to(output).as_posix(): sha(p) for p in files},
        'implementation_sha256': implementation,
        'budget': {'workers': 1, 'max_states_per_search': 1024, 'max_ground_actions': 1000},
        'scope': 'Exhaustive Boolean valuations of listed dynamic atoms in six authored finite cases; all other facts fixed by the supplied world. Not all PDDL models or independent semantics.'}
    save(output / 'manifest.json', manifest)
    return manifest


def run(output):
    manifest = freeze(output)
    report = {'status': 'running', 'manifest_sha256': sha(output / 'manifest.json'), 'rows': []}
    save(output / 'report.json', report)
    for case in manifest['cases']:
        directory = output / case['directory']
        originals = [PDDLReader().parse_problem(str(domain), str(directory / 'problem.pddl')) for domain in
                     (output / case['full_domain'], directory / 'selected.pddl', directory / 'seed_only_mutant.pddl')]
        for valuation, bits in enumerate(itertools.product((False, True), repeat=len(case['dynamic_atoms']))):
            outcomes = []
            for original in originals:
                problem = original.clone()
                for atom, value in zip(case['dynamic_atoms'], bits):
                    arguments = [problem.object(obj) for obj in atom[1:]]
                    problem.set_initial_value(problem.fluent(atom[0])(*arguments), value)
                outcomes.append(reachable(problem))
            definite = all(row['status'] in ('reachable', 'unreachable') for row in outcomes)
            report['rows'].append({'case': case['id'], 'valuation': valuation, 'bits': list(bits),
                'full': outcomes[0], 'selected': outcomes[1], 'mutant': outcomes[2],
                'definite': definite,
                'selection_mismatch': definite and outcomes[0]['status'] != outcomes[1]['status'],
                'mutation_detected': definite and outcomes[0]['status'] != outcomes[2]['status']})
        save(output / 'report.json', report)
        print(json.dumps({'case': case['id'], 'completed_valuations': case['valuation_count']}), flush=True)
    counts = Counter(r['case'] for r in report['rows'] if r['mutation_detected'])
    report.update(status='complete', valuation_count=len(report['rows']),
        selection_mismatches=sum(r['selection_mismatch'] for r in report['rows']),
        inconclusive=sum(not r['definite'] for r in report['rows']), mutation_mismatches_by_case=dict(counts),
        expected_mutations_detected=all(counts[c['id']] > 0 for c in manifest['cases'] if c['mutant_must_be_detected']),
        inputs_unchanged=all(sha(output / p) == h for p, h in manifest['input_sha256'].items()),
        implementation_unchanged=all(sha(Path(p)) == h for p, h in manifest['implementation_sha256'].items()),
        scope=manifest['scope'])
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    report = run(args.output)
    print(json.dumps({k: v for k, v in report.items() if k != 'rows'}, indent=2))

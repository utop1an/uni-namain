"""Deliberately malformed mapped-world control for constant-scope admission."""
import argparse
import json
from pathlib import Path

from unified_planning.io import PDDLReader

from rcnc.aligned_domain import build, membership_facts
from rcnc.component_selection import restrict
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.narrative_pipeline import map_problem
from rcnc.pddl import parse_sexpr, section, serialize
from scripts.validation.validate_component_reachability import reachable


def run(output):
    require_empty_output(output)
    inputs = output / 'inputs'
    inputs.mkdir(parents=True)
    texts = {'A': '(:constants a - item) (:predicates (signal ?x - item) (done ?x - item)) '
        '(:action finish :parameters (?x - item) :precondition (signal ?x) :effect (done ?x))',
        'B': '(:constants b - item) (:predicates (signal ?x - item)) '
        '(:action emit :parameters () :precondition (and) :effect (signal b))'}
    for source, text in texts.items():
        (inputs / (source + '_domainfile.pddl')).write_text(f'(define (domain {source.lower()}) '
            f'(:requirements :typing :strips) (:types item) {text})', encoding='utf-8')
    spec = {'version': 1, 'decision_basis': 'authored_assumption',
        'source_sha256': {path.name: digest(path) for path in inputs.glob('*.pddl')},
        'type_groups': [{'members': ['A:item', 'B:item'], 'evidence': 'Finite contract control'}],
        'predicate_groups': [{'id': 'signal', 'members': [{'predicate': 'A:signal', 'order': [0]},
            {'predicate': 'B:signal', 'order': [0]}], 'evidence': 'Finite contract control'}]}
    compiled = output / 'compiled'
    build(inputs, compiled, spec)
    meta = json.loads((compiled / 'meta_domain.json').read_text(encoding='utf-8'))
    valid_query = {'objects': {}, 'initial': [], 'goal': {'positive': [['A:done', 'A:a']]}}
    map_problem(valid_query, compiled, output / 'valid_problem.pddl')
    problem = parse_sexpr((output / 'valid_problem.pddl').read_text(encoding='utf-8'))
    target = meta['constant_maps']['B']['b']
    guards_b = {meta['type_guards'][typ] for typ in meta['namespaces']['B']['types'].values()}
    initial = section(problem, ':init')
    removed = [fact for fact in initial[1:] if fact[0] in guards_b and fact[1] == target]
    initial[1:] = [fact for fact in initial[1:] if fact not in removed]
    initial.extend(membership_facts(target, meta['namespaces']['A']['types']['item'],
        meta['source_type_parents'], meta['type_guards']))
    section(problem, ':goal')[1] = [meta['predicate_maps']['A']['done'], target]
    (output / 'malformed_problem.pddl').write_text(serialize(problem) + '\n', encoding='utf-8')
    query = {'goal': {'positive': [['A:done', 'B:b']]}}
    save(output / 'query_seed.json', query)
    implementation = snapshot_implementation(output, [Path(__file__), Path('rcnc/component_selection.py'),
        Path('rcnc/world_source_selection.py'), Path('rcnc/domain_catalog.py'), Path('rcnc/grounding.py'),
        Path('scripts/validation/validate_component_reachability.py'), Path('rcnc/pddl.py'), Path('rcnc/domain_building.py')])
    save(output / 'manifest.json', {'status': 'frozen_before_contract_and_reachability_checks',
        'domain_sha256': digest(compiled / 'meta_domain.pddl'), 'problem_sha256': digest(output / 'malformed_problem.pddl'),
        'implementation_sha256': implementation, 'removed_membership_facts': removed,
        'budget': {'max_states': 1024, 'max_ground_actions': 1000},
        'scope': 'Deliberately violates compiler constant-membership contract; not a valid supplied-world or semantic benchmark. Tests rejection, never repairs/pools a real world.'})
    full = PDDLReader().parse_problem(str(compiled / 'meta_domain.pddl'), str(output / 'malformed_problem.pddl'))
    result = {'full_reachability': reachable(full), 'scope': 'Malformed mapped-world admission control only',
        'manifest_sha256': digest(output / 'manifest.json')}
    try:
        certificate = restrict(query, compiled, output / 'malformed_problem.pddl', output / 'selected.pddl')
        selected = PDDLReader().parse_problem(str(output / 'selected.pddl'), str(output / 'malformed_problem.pddl'))
        result.update(status='accepted_malformed_world', certificate=certificate, selected_reachability=reachable(selected))
        result['reachability_mismatch'] = result['full_reachability']['status'] != result['selected_reachability']['status']
    except ValueError as exc:
        result.update(status='rejected_malformed_world', reason=str(exc), reachability_mismatch=None)
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(run(args.output), indent=2))

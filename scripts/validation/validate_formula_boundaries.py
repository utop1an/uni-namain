"""Finite authored controls for Boolean, equality and empty-type quantifier semantics."""
import argparse
from pathlib import Path

from rcnc.aligned_domain import build
from scripts.experiments.run_downward_reference import sha, save
from scripts.validation.validate_transition_preservation import audit


CONDITIONS = {
    'negated_all': '(not (forall (?y - person) (p ?y)))',
    'negated_exists': '(not (exists (?y - person) (p ?y)))',
    'implication': '(imply (p ?x) (exists (?y - person) (r ?x ?y)))',
    'disjunction': '(or (p ?x) (not (r ?x ?x)))',
    'equality': '(= ?x a)',
    'inequality': '(not (= ?x a))',
    'all_exists': '(forall (?y - person) (exists (?z - person) (r ?y ?z)))',
    'exists_all': '(exists (?y - person) (forall (?z - person) (r ?y ?z)))',
    'shadowed_parameter': '(forall (?x - person) (or (p ?x) (r ?x a)))',
    'shadowed_nested': '(exists (?y - person) (and (p ?y) (forall (?y - person) (r ?y a))))',
    'vacuous_all': '(forall (?y - vacant) (e ?y))',
    'empty_exists': '(exists (?y - vacant) (e ?y))',
    'negative_empty_exists': '(not (exists (?y - vacant) (e ?y)))',
    'negative_vacuous_all': '(not (forall (?y - vacant) (e ?y)))',
}


def run(output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use a fresh output directory')
    inputs = output/'inputs'
    inputs.mkdir(parents=True)
    actions = '\n'.join(f'(:action {name} :parameters (?x - person) :precondition {condition} :effect (done))'
                        for name, condition in CONDITIONS.items())
    domain = f'''(define (domain formula_a) (:requirements :adl :typing :equality)
    (:types person vacant - object) (:constants a - person)
    (:predicates (p ?x - person) (r ?x ?y - person) (e ?x - vacant) (done)) {actions})'''
    problem = '''(define (problem formula_problem) (:domain formula_a) (:objects b - person) (:init)
    (:goal (and (forall (?x - person) (exists (?y - person) (= ?x ?y)))
                (not (exists (?v - vacant) (e ?v))) (done))))'''
    (inputs/'A_domainfile.pddl').write_text(domain, encoding='utf-8')
    (inputs/'A_problemfile.pddl').write_text(problem, encoding='utf-8')
    (inputs/'B_domainfile.pddl').write_text('''(define (domain foreign_b) (:requirements :strips :typing)
    (:types foreign - object) (:constants outsider - foreign) (:predicates (other))
    (:action touch :parameters () :precondition (and) :effect (other)))''', encoding='utf-8')
    (inputs/'B_problemfile.pddl').write_text('(define (problem other) (:domain foreign_b) (:init) (:goal (other)))', encoding='utf-8')
    specification = {'version': 1, 'decision_basis': 'authored_assumption',
        'source_sha256': {p.name: sha(p) for p in inputs.glob('*_domainfile.pddl')}, 'type_groups': [], 'predicate_groups': []}
    save(output/'manifest.json', {'status': 'frozen_before_audit', 'conditions': CONDITIONS,
         'expected_source_atoms': 7, 'expected_states': 128, 'expected_ground_actions': 28,
         'source_sha256': {p.name: sha(p) for p in inputs.glob('*.pddl')},
         'scope': 'Authored finite formula controls, including an empty declared source type; no semantic-interface assessment'})
    build(inputs, output/'compiled', specification)
    frozen = {str(p): sha(p) for p in [*inputs.glob('*.pddl'), output/'manifest.json', output/'compiled/meta_domain.pddl',
              output/'compiled/meta_domain.json', output/'compiled/problems/A_problemfile.pddl', Path(__file__),
              Path('scripts/validation/validate_transition_preservation.py'), Path('rcnc/aligned_domain.py'), Path('rcnc/domain_union.py'), Path('rcnc/domain_building.py')]}
    result = audit(inputs, output/'compiled')
    result['frozen_sha256'] = frozen
    result['hashes_unchanged'] = all(sha(Path(p)) == h for p, h in frozen.items())
    result['condition_count'] = len(CONDITIONS)
    save(output/'report.json', result)
    (output/Path(__file__).name).write_bytes(Path(__file__).read_bytes())
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = run(args.output)
    print({k: v for k, v in result.items() if k not in ('frozen_sha256', 'state_atoms')})

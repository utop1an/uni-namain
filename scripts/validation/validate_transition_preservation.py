"""Exhaustive finite-state compilation audit on authored engineering fixtures.

Compares action applicability, complete projected successor states, goals, and
the frame outside the source image. This is not narrative semantic evaluation.
"""
import argparse
import hashlib
from itertools import product
import json
from pathlib import Path
import time

from unified_planning.io import PDDLReader
from unified_planning.model.fluent import get_all_fluent_exp
from unified_planning.model.state import UPState
from unified_planning.shortcuts import SequentialSimulator

from rcnc.aligned_domain import build


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def fixture(inputs):
    inputs.mkdir(parents=True)
    (inputs / 'A_domainfile.pddl').write_text('''(define (domain source_a)
      (:requirements :adl :typing) (:types person - object apprentice - person)
      (:constants a - apprentice)
      (:predicates (ready ?p - person) (done ?p - person) (rel ?p ?q - person))
      (:action prepare :parameters (?p - person) :precondition (not (ready ?p)) :effect (ready ?p))
      (:action conditional :parameters (?p - person) :precondition (exists (?q - person) (ready ?q))
       :effect (when (ready ?p) (done ?p)))
      (:action clear_all :parameters () :precondition (forall (?p - person) (done ?p))
       :effect (forall (?p - person) (not (ready ?p))))
      (:action finish_all :parameters () :precondition (forall (?p - person) (ready ?p))
       :effect (forall (?p - person) (done ?p)))
      (:action link :parameters (?p ?q - person) :precondition (ready ?p) :effect (rel ?p ?q))
      (:action follow :parameters (?p ?q - person) :precondition (rel ?p ?q) :effect (done ?q))
      (:action absent :parameters (?p - person) :precondition (not (exists (?q - person) (rel ?p ?q))) :effect (done ?p))
      (:action apprentice_step :parameters (?p - apprentice) :precondition (ready ?p) :effect (done ?p)))''', encoding='utf-8')
    (inputs / 'A_problemfile.pddl').write_text('''(define (problem source_a_problem) (:domain source_a)
      (:objects b - person) (:init) (:goal (and (forall (?p - person) (done ?p)) (not (rel b a)))))''', encoding='utf-8')
    (inputs / 'B_domainfile.pddl').write_text('''(define (domain source_b) (:requirements :strips :typing)
      (:types person - object) (:constants outsider - person)
      (:predicates (reverse_rel ?q ?p - person))
      (:action foreign :parameters (?q ?p - person) :precondition (and) :effect (reverse_rel ?q ?p)))''', encoding='utf-8')
    (inputs / 'B_problemfile.pddl').write_text('''(define (problem source_b_problem) (:domain source_b)
      (:init) (:goal (reverse_rel outsider outsider)))''', encoding='utf-8')
    return {'version': 1, 'decision_basis': 'authored_assumption',
            'source_sha256': {p.name: digest(p) for p in inputs.glob('*_domainfile.pddl')},
            'type_groups': [{'members': ['A:person', 'B:person'], 'evidence': 'Synthetic role type correspondence'}],
            'predicate_groups': [{'id': 'relation', 'evidence': 'Synthetic reversed-role correspondence',
                                  'members': [{'predicate': 'A:rel', 'order': [1, 0]},
                                              {'predicate': 'B:reverse_rel', 'order': [0, 1]}]}]}


def audit(inputs, compiled, source='A', max_states=65536):
    reader = PDDLReader()
    original = reader.parse_problem(str(inputs / f'{source}_domainfile.pddl'), str(inputs / f'{source}_problemfile.pddl'))
    target = reader.parse_problem(str(compiled / 'meta_domain.pddl'), str(compiled / 'problems' / f'{source}_problemfile.pddl'))
    meta = json.loads((compiled / 'meta_domain.json').read_text(encoding='utf-8'))
    source_atoms = [atom for fluent in original.fluents for atom in get_all_fluent_exp(original, fluent)]
    if any(not fluent.type.is_bool_type() for fluent in original.fluents):
        raise ValueError('Exhaustive audit requires Boolean state variables')
    expected_states = 2 ** len(source_atoms)
    if expected_states > max_states:
        return {'status': 'state_space_limit', 'expected_states': expected_states, 'max_states': max_states}
    terms = {**meta['constant_maps'][source], **meta['namespaces'][source].get('objects', {})}
    terms = {k.lower(): v.lower() for k, v in terms.items()}
    orders = {k.lower(): v for k, v in meta['predicate_orders'][source].items()}
    predicates = {k.lower(): v for k, v in meta['predicate_maps'][source].items()}
    actions = {k.lower(): v for k, v in meta['action_maps'][source].items()}
    em = target.environment.expression_manager

    def mapped_term(arg):
        return em.ObjectExp(target.object(terms[arg.object().name.lower()]))

    def mapped_atom(atom):
        name = atom.fluent().name.lower()
        args = [mapped_term(arg) for arg in atom.args]
        return target.fluent(predicates[name])(*[args[i] for i in orders[name]])

    pairs = [(atom, mapped_atom(atom)) for atom in source_atoms]
    image = {mapped for _, mapped in pairs}
    frame = [atom for fluent in target.fluents for atom in get_all_fluent_exp(target, fluent) if atom not in image]
    bindings = [(action, tuple(params)) for action in original.actions
                for params in product(*[[original.environment.expression_manager.ObjectExp(obj) for obj in original.objects(p.type)]
                                         for p in action.parameters])]
    counts = {'states': 0, 'ground_action_instances': len(bindings), 'applicability_checks': 0,
              'applicable_transitions': 0, 'goal_checks': 0, 'mismatches': 0}
    examples = []

    def mismatch(kind, mask, action=None, detail=None):
        counts['mismatches'] += 1
        if len(examples) < 20:
            examples.append({'kind': kind, 'state_mask': mask, 'action': action, 'detail': detail})

    with SequentialSimulator(original) as sim, SequentialSimulator(target) as mapped_sim:
        base_values = dict(target.explicit_initial_values)
        for mask in range(expected_states):
            values = {atom: original.environment.expression_manager.Bool(bool(mask & (1 << i))) for i, atom in enumerate(source_atoms)}
            mapped_values = dict(base_values)
            for atom, mapped in pairs:
                mapped_values[mapped] = em.Bool(values[atom].bool_constant_value())
            state = UPState(values, original)
            mapped_state = UPState(mapped_values, target)
            counts['states'] += 1
            counts['goal_checks'] += 1
            if sim.is_goal(state) != mapped_sim.is_goal(mapped_state):
                mismatch('goal', mask)
            for action, params in bindings:
                mapped_action = target.action(actions[action.name.lower()])
                mapped_params = tuple(mapped_term(p) for p in params)
                applies = sim.is_applicable(state, action, params)
                mapped_applies = mapped_sim.is_applicable(mapped_state, mapped_action, mapped_params)
                counts['applicability_checks'] += 1
                label = action.name + '(' + ','.join(map(str, params)) + ')'
                if applies != mapped_applies:
                    mismatch('applicability', mask, label)
                    continue
                if not applies:
                    continue
                after = sim.apply(state, action, params)
                mapped_after = mapped_sim.apply(mapped_state, mapped_action, mapped_params)
                counts['applicable_transitions'] += 1
                if after is None or mapped_after is None:
                    mismatch('applicable_but_no_successor', mask, label)
                    continue
                changed = [str(atom) for atom, mapped in pairs if after.get_value(atom) != mapped_after.get_value(mapped)]
                if changed:
                    mismatch('projected_successor', mask, label, changed)
                changed_frame = [str(atom) for atom in frame if mapped_state.get_value(atom) != mapped_after.get_value(atom)]
                if changed_frame:
                    mismatch('foreign_or_membership_frame', mask, label, changed_frame)
    return {'status': 'PASS' if counts['mismatches'] == 0 else 'FAIL', 'counts': counts,
            'state_atoms': [str(a) for a in source_atoms], 'counterexamples': examples,
            'scope': 'Exhaustive states of one finite authored fixture; not a proof for all domains or semantic-alignment evaluation'}


def run(output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    started = time.monotonic()
    inputs = output / 'input'
    spec = fixture(inputs)
    build(inputs, output / 'compiled', spec)
    frozen = digest(output / 'compiled/meta_domain.pddl')
    result = audit(inputs, output / 'compiled')
    result.update(elapsed_seconds=round(time.monotonic() - started, 3),
                  compiled_domain_unchanged=frozen == digest(output / 'compiled/meta_domain.pddl'),
                  implementation_sha256={p.name: digest(p) for p in [Path(__file__), (Path(__file__).resolve().parents[2] / 'rcnc/aligned_domain.py'), Path('rcnc/domain_union.py'), Path('rcnc/domain_building.py')]})
    (output / 'report.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    return result


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    result = run(a.output)
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result['status'] == 'PASS' and result['compiled_domain_unchanged'] else 1)

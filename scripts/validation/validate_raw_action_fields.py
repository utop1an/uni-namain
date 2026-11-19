"""Negative source-admission control for repeated PDDL action fields.

This authored ambiguous input is not a valid-domain preservation experiment.
"""
import argparse
from collections import Counter
from pathlib import Path

from unified_planning.io import PDDLReader
from rcnc.aligned_domain import build
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.pddl import parse_domain


SOURCE = '''(define (domain ambiguous) (:requirements :strips :typing)
    (:types item) (:constants token - item)
    (:predicates (first ?x - item) (second ?x - item))
    (:action change :parameters (?x - item) :precondition (and)
        :effect (first ?x) :effect (second ?x)))'''


def run(output):
    require_empty_output(output)
    output.mkdir(parents=True)
    inputs = output / 'inputs'; inputs.mkdir()
    source = inputs / 'A_domainfile.pddl'; source.write_text(SOURCE, encoding='utf-8')
    specification = {'version': 1, 'decision_basis': 'authored_assumption', 'predicate_groups': [], 'type_groups': []}
    save(output / 'alignment.json', specification)
    implementation = snapshot_implementation(output, [Path(__file__), Path('rcnc/aligned_domain.py'),
        Path('rcnc/domain_union.py'), Path('rcnc/domain_building.py'), Path('rcnc/pddl.py'), Path('rcnc/pddl_checks.py')])
    original_hash = digest(source)
    save(output / 'manifest.json', {'status': 'frozen_before_compiler_control', 'source_sha256': original_hash,
        'implementation_sha256': implementation, 'scope': 'Authored ambiguous repeated-effect field; no model/planner calls or valid-world preservation claim.'})
    try:
        PDDLReader().parse_problem(str(source))
        source_parse = {'status': 'PARSED'}
    except Exception as exc:
        source_parse = {'status': 'ERROR', 'reason': f'{type(exc).__name__}: {exc}'}
    result = {'status': 'starting', 'original_independent_parse': source_parse, 'source_action_fields': {'effect': 2}}
    try:
        compiled = build(inputs, output / 'compiled', specification)
        model = parse_domain(output / 'compiled/meta_domain.pddl')
        action = next(iter(model.actions.values()))
        fields = Counter(action[2::2])
        result.update(status='accepted_repeated_action_fields', compiler_valid=compiled['valid'],
            compiled_field_counts=dict(fields), compiled_action=action)
        PDDLReader().parse_problem(str(output / 'compiled/meta_domain.pddl'))
        result['compiled_independent_parse'] = 'PARSED'
    except ValueError as exc:
        duplicate = 'duplicate action field' in str(exc) or 'duplicate fields' in str(exc)
        result.update(status='rejected_repeated_action_fields' if duplicate else 'other_rejection', reason=str(exc))
    except Exception as exc:
        result.update(status='error', reason=f'{type(exc).__name__}: {exc}')
    result.update(source_unchanged=digest(source) == original_hash,
        compiled_model_exists=(output / 'compiled/meta_domain.pddl').exists(),
        implementation_unchanged=all(digest(Path(p)) == h for p, h in implementation.items()),
        manifest_sha256=digest(output / 'manifest.json'), model_calls=0, planner_calls=0,
        scope='Invalid/ambiguous source-admission control only; source data unchanged, no semantic accuracy or valid-domain preservation failure established.')
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    print(run(args.output))

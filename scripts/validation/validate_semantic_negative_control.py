"""Show that source-plan preservation is not a semantic-alignment oracle.

The incompatible correspondence is deliberately authored for this control.
It is never proposed as a valid real-domain alignment or used as gold data.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path

from rcnc.merged_planning import solve
from rcnc.narrative_pipeline import run as run_pipeline
from scripts.experiments.run_union_regression import translate_plan


def run(output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    inputs = output / 'input'; inputs.mkdir(parents=True)
    (inputs / 'CAPTURE_domainfile.pddl').write_text('''(define (domain capture)
      (:requirements :strips :typing) (:types person - object) (:constants prisoner - person)
      (:predicates (alive ?p - person) (captured ?p - person))
      (:action capture_alive :parameters (?p - person) :precondition (alive ?p) :effect (captured ?p)))''', encoding='utf-8')
    (inputs / 'CAPTURE_problemfile.pddl').write_text('''(define (problem capture_problem) (:domain capture)
      (:init (alive prisoner)) (:goal (captured prisoner)))''', encoding='utf-8')
    (inputs / 'BURIAL_domainfile.pddl').write_text('''(define (domain burial)
      (:requirements :strips :typing) (:types person - object) (:constants corpse - person)
      (:predicates (dead ?p - person) (buried ?p - person))
      (:action bury :parameters (?p - person) :precondition (dead ?p) :effect (buried ?p)))''', encoding='utf-8')
    (inputs / 'BURIAL_problemfile.pddl').write_text('''(define (problem burial_problem) (:domain burial)
      (:init (dead corpse)) (:goal (buried corpse)))''', encoding='utf-8')
    spec = {'version': 1, 'decision_basis': 'authored_assumption',
            'source_sha256': {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs.glob('*_domainfile.pddl')},
            'type_groups': [{'members': ['CAPTURE:person', 'BURIAL:person'], 'evidence': 'Synthetic shared participant type'}],
            'predicate_groups': []}
    query = {'alignment': spec, 'objects': {'hero': ['CAPTURE:person', 'BURIAL:person']},
             'initial': [['CAPTURE:alive', 'hero']], 'goal': {'positive': [['BURIAL:buried', 'hero']]}, 'seconds': 30}
    baseline = run_pipeline(query, inputs, output / 'distinct_predicates')
    corrupted = copy.deepcopy(query)
    corrupted['alignment']['predicate_groups'] = [{
        'id': 'captured_is_dead',
        'evidence': 'DELIBERATELY FALSE experimental assumption: captured alive does not imply dead in the authored control',
        'members': [{'predicate': 'CAPTURE:captured', 'order': [0]}, {'predicate': 'BURIAL:dead', 'order': [0]}]}]
    bad = run_pipeline(corrupted, inputs, output / 'incompatible_alignment')
    source_rows = []
    for source in ('CAPTURE', 'BURIAL'):
        original = output / 'sources' / source
        result = solve(inputs / f'{source}_domainfile.pddl', inputs / f'{source}_problemfile.pddl', original)
        row = {'source': source, 'source_search': result}
        if result['status'] == 'solved':
            row['translated'] = translate_plan(source, inputs, output / 'incompatible_alignment/union', original,
                                               output / 'translated' / source)
        source_rows.append(row)
    preserved = all(row.get('translated', {}).get('validation', {}).get('status') == 'VALID' for row in source_rows)
    observed = baseline['status'] == 'unsolvable' and bad['status'] == 'solved' and bad['search']['validation']['status'] == 'VALID' and preserved
    report = {'status': 'PASS' if observed else 'FAIL',
              'scope': 'Authored semantic-negative control, not independent human annotation or real-domain failure prevalence',
              'semantic_oracle': {'relation': 'incompatible', 'basis': 'The authored source vocabulary distinguishes captured-alive from dead; capture has no death effect'},
              'same_narrative_initial_and_goal': query['initial'] == corrupted['initial'] and query['goal'] == corrupted['goal'],
              'distinct_predicates_status': baseline['status'], 'incompatible_alignment_status': bad['status'],
              'incompatible_alignment_plan': bad.get('search', {}), 'source_plans': source_rows,
              'all_available_source_plans_preserved': preserved,
              'conclusion': 'An explicitly wrong cross-source correspondence can preserve both source plans and produce a valid composed plan; neither check establishes semantic alignment correctness',
              'implementation_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
    (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    return report


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    result = run(a.output)
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result['status'] == 'PASS' else 1)

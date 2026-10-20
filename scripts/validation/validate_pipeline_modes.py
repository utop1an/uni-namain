"""Persist synthetic end-to-end request-mode checks, not benchmark results."""
import argparse
import copy
import json
from pathlib import Path

from rcnc.narrative_pipeline import run, save


def validate(output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    inputs = output / 'input'
    inputs.mkdir(parents=True)
    for name, before, after, action in [('HEAR', 'messenger_present', 'rumor_known', 'hear_report'),
                                       ('WARN', 'rumor_known', 'warning_delivered', 'warn_village')]:
        (inputs / f'{name}_domainfile.pddl').write_text(f'''(define (domain {name.lower()})
          (:requirements :strips :typing) (:types person - object)
          (:predicates ({before} ?p - person) ({after} ?p - person))
          (:action {action} :parameters (?p - person) :precondition ({before} ?p)
           :effect ({after} ?p)))\n''', encoding='utf-8')
    base = {'objects': {'hero': 'HEAR:person'},
            'initial': [['HEAR:messenger_present', 'hero']],
            'goal': {'positive': [['HEAR:rumor_known', 'hero']]}, 'seconds': 30}
    cases = [('initial_goal', base, 'solved')]
    query = copy.deepcopy(base); del query['goal']
    cases.append(('initial_only', query, 'outcomes_generated'))
    query = copy.deepcopy(base); del query['initial']
    cases.append(('goal_only', query, 'needs_initial_state'))
    query = copy.deepcopy(base); query['initial'] = []
    cases.append(('empty_initial', query, 'unsolvable'))
    query = copy.deepcopy(base); query['objects'] = {'helper': 'HEAR:person'}
    query['initial'][0][1] = 'helper'; query['goal']['positive'][0][1] = 'helper'
    cases.append(('second_object', query, 'solved'))
    query = copy.deepcopy(base); query['sources'] = ['HEAR']
    cases.append(('selected_source', query, 'solved'))
    rows = []
    for name, query, expected in cases:
        result = run(query, inputs, output / name)
        rows.append({'case': name, 'expected': expected, 'actual': result['status'],
                     'pass': expected == result['status'], 'planner_called': result['planner_called']})
    hashes = [json.loads((output / name / 'manifest.json').read_text())['domain_sha256']
              for name in ('initial_goal', 'initial_only', 'empty_initial', 'second_object')]
    report = {'scope': 'Synthetic engineering fixtures; no learned-domain generalization or semantic-alignment evidence',
              'cases': rows, 'same_domain_for_multiple_problems': len(set(hashes)) == 1,
              'all_statuses_expected': all(r['pass'] for r in rows)}
    report['status'] = 'PASS' if report['all_statuses_expected'] and report['same_domain_for_multiple_problems'] else 'FAIL'
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = validate(args.output)
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result['status'] == 'PASS' else 1)

"""Recheck the frozen quantified-action-effect cohort of the November 9 run."""

import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import sys

from rcnc.saved_plan_validation import replay_saved
from scripts.audit.recheck_glaive_axiom_transports import IMPLEMENTATION, _offline, _sha, _write


def recheck(previous, output):
    if output.exists():
        raise FileExistsError(output)
    hashes = {}
    repo = Path(__file__).resolve().parents[2]

    def pin(path, expected=None):
        path = Path(path).resolve()
        if path not in hashes:
            hashes[path] = _sha(path)
        if expected is not None and hashes[path] != expected:
            raise ValueError(f'Frozen input mismatch: {path}')
        return path

    def read(path, expected=None):
        return json.loads(pin(path, expected).read_text(encoding='utf-8'))

    inventory = read(previous / 'verified_inventory/results.json')
    if inventory['status'] != 'verified_snapshot' or inventory['excluded_pending']:
        raise ValueError('Previous Table 4 is not verified')

    def archived(role, filename):
        entry = inventory['results'][role]
        path = previous / filename
        if Path(entry['path']).resolve() != path.resolve():
            raise ValueError(f'Unexpected archived report path: {role}')
        return read(path, entry['sha256'])

    prior = archived('goal_recheck', 'report.json')
    gap = archived('quantified_effect_gap', 'unconfirmed_quantified_effects.json')
    prior_protocol = read(previous / 'protocol.json', prior['protocol_sha256'])
    if (prior['status'] != 'complete_independent_axiom_goal_recheck'
            or gap['status'] != 'confirmed_quantified_action_effect_coverage_gap'
            or gap['source_report_sha256'] != hashes[(previous / 'report.json').resolve()]):
        raise ValueError('Missing binding to the prior goal recheck')
    expected = {Path(path).resolve(): digest for path, digest in prior_protocol['input_sha256'].items()}
    known_cases = {r['id']: r for r in gap['rows']}
    candidates = [r for r in prior['rows'] if not r['dual_pass_with_retained_native']]
    if ({r['id'] for r in candidates} != known_cases.keys() or len(candidates) != len(known_cases)
            or Counter(r['condition'] for r in candidates) != {'union': 22, 'full': 22}):
        raise ValueError('Unexpected quantified-effect recheck cohort')

    tasks = []
    for row in candidates:
        case = known_cases[row['id']]
        if (case['condition'] != row['condition'] or case['world'] != row['world']
                or row['new_physical']['reason'] != 'Undeclared or malformed physical predicate: forall'):
            raise ValueError(f'Quantified-effect receipt mismatch: {row["id"]}')
        paths = {key: Path(row[key]).resolve() for key in ('domain', 'problem', 'plan', 'mapping')}
        for path in paths.values():
            pin(path, expected[path])
        receipt_path = Path(row['historical_native_replay']).resolve()
        receipt = read(receipt_path, expected[receipt_path])
        replay_inputs = {pin(path, digest) for path, digest in receipt['input_sha256'].items()}
        if (not {paths[key] for key in ('domain', 'problem', 'plan')} <= replay_inputs
                or receipt['steps'] != row['historical_native_steps'] or receipt['status'] != 'replayed'
                or receipt['goal'] is not True or receipt['unexplained_steps'] != 0 or receipt['search_calls'] != 0):
            raise ValueError(f'Historical native pass differs: {row["id"]}')
        tasks.append({'id': row['id'], 'condition': row['condition'], 'world': row['world'],
                      **{k: str(v) for k, v in paths.items()}, 'historical_native_replay': str(receipt_path),
                      'historical_native_steps': receipt['steps'], 'previous_physical': row['new_physical'],
                      'actions_with_quantified_effects': case['actions_with_quantified_effects']})

    output.mkdir(parents=True)
    for relative in (*IMPLEMENTATION, 'scripts/audit/recheck_glaive_quantified_effects.py'):
        code = pin(repo / relative)
        snapshot = output / 'implementation' / relative
        snapshot.parent.mkdir(parents=True, exist_ok=True)
        snapshot.write_bytes(code.read_bytes())
        pin(snapshot, hashes[code])
    protocol = {'status': 'frozen_before_quantified_effect_recheck',
                'created_utc': datetime.now(timezone.utc).isoformat(),
                'registered': len(tasks), 'tasks': tasks, 'input_sha256': {str(p): h for p, h in hashes.items()},
                'validator': {'native_axioms': True, 'quantified_action_effects': True},
                'search_calls': 0, 'new_native_replay_calls': 0, 'model_requests': 0}
    _write(output / 'protocol.json', protocol)
    protocol_path = pin(output / 'protocol.json')

    results = []
    for task in tasks:
        try:
            physical = replay_saved(*(Path(task[key]) for key in ('domain', 'problem', 'plan')),
                                    native_axioms=True, quantified_action_effects=True)
        except (ValueError, TypeError, KeyError) as exc:
            physical = {'status': 'unsupported_or_invalid_input', 'reason': str(exc)}
        if physical['status'] == 'replayed' and physical['steps'] != task['historical_native_steps']:
            physical = {'status': 'step_count_mismatch', 'result': physical}
        passed = physical['status'] == 'replayed' and physical['goal'] is True
        results.append({**task, 'new_physical': physical, 'dual_pass_with_retained_native': passed})

    if any(_sha(path) != expected_digest for path, expected_digest in hashes.items()):
        raise ValueError('Frozen input changed during quantified-effect recheck')

    table = {check: dict(values) for check, values in prior['table4'].items()}
    goals = table['original_goal_search_dual']
    summary = {}
    for arm in ('union', 'full'):
        cases = [r for r in results if r['condition'] == arm]
        restored = sum(r['dual_pass_with_retained_native'] for r in cases)
        old = prior['summary'][arm]
        before = goals[arm]
        if before != old['updated_dual_pass'] or before + restored > goals['denominator']:
            raise ValueError(f'Inconsistent prior goal total: {arm}')
        goals[arm] = before + restored
        outcomes = dict(old['outcomes'])
        outcomes['dual_pass'] += restored
        outcomes['returned_plan_without_dual_pass'] -= restored
        if sum(outcomes.values()) != goals['denominator']:
            raise ValueError(f'Incomplete updated original-goal denominator: {arm}')
        summary[arm] = {'targeted': len(cases), 'new_dual_pass': restored,
                        'previous_dual_pass': before, 'updated_dual_pass': goals[arm],
                        'recheck_statuses': dict(Counter(r['new_physical']['status'] for r in cases)),
                        'outcomes': outcomes}
    report = {'status': 'complete_independent_quantified_effect_recheck', 'registered': len(results),
              'rows': results, 'summary': summary, 'table4': table, 'distinct_goal_worlds': prior['distinct_goal_worlds'],
              'protocol_sha256': hashes[protocol_path], 'inputs_unchanged': True,
              'search_calls': 0, 'new_native_replay_calls': 0, 'model_requests': 0,
              'scope': 'Only the 44 unresolved quantified-action-effect plans were rechecked. The prior Table 4 outcomes and the original native checks are carried forward. Source values retain their historical validation conditions.'}
    _write(output / 'report.json', report)
    print(json.dumps({key: value for key, value in report.items() if key != 'rows'}, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--previous', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    sys.addaudithook(_offline)
    recheck(args.previous.resolve(), args.output.resolve())

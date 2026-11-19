"""Verify frozen transport plans with an independent native-axiom checker."""

import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import sys

from rcnc.saved_plan_validation import replay_saved


UNSUPPORTED = 'Derived predicates/axioms require a separate validator'
IMPLEMENTATION = (
    'rcnc/saved_plan_validation.py', 'rcnc/native_axiom_replay.py',
    'rcnc/revised_probe_validation.py', 'rcnc/glaive_intake.py', 'rcnc/pddl.py',
    'scripts/audit/recheck_glaive_axiom_transports.py', 'tests/test_saved_plan_validation.py',
)


def _sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _write(path, value):
    with path.open('x', encoding='utf-8') as stream:
        json.dump(value, stream, ensure_ascii=False, indent=2)
        stream.write('\n')


def _offline(event, args):
    if event in ('socket.connect', 'socket.connect_ex', 'socket.getaddrinfo',
                 'urllib.Request', 'subprocess.Popen', 'os.system'):
        raise RuntimeError(f'Replay audit forbids network and external execution: {event}')


def recheck(run, output):
    if output.exists():
        raise FileExistsError(output)
    repo = Path(__file__).resolve().parents[2]
    hashes = {}

    def pin(path, expected=None):
        path = Path(path).resolve()
        if path not in hashes:
            hashes[path] = _sha(path)
        if expected is not None and hashes[path] != expected:
            raise ValueError(f'Pinned input mismatch: {path}')
        return path

    def read(path, expected=None):
        return json.loads(pin(path, expected).read_text(encoding='utf-8'))

    inventory = read(run / 'comparison_v1' / 'verified_inventory' / 'result_sources.json')
    source = run / 'repeat_01' / 'transport_report.json'
    entry = inventory['reports']['current_transport']
    if Path(entry['path']).resolve() != source.resolve():
        raise ValueError('Verified report does not bind this transport stage')
    report = read(source, entry['sha256'])
    original = report['rows']
    if len(original) != report['registered_slots'] or len(original) != 21056:
        raise ValueError('Incomplete full-run transport registry')
    if len({row['id'] for row in original}) != len(original):
        raise ValueError('Duplicate historical task ID')

    tasks = []
    paired = {'union': set(), 'full': set()}
    for row in original:
        if row['reference'].get('validation_level') != 'dual_validated':
            continue
        old = row['replay']
        if (not row['native_valid'] or old['status'] != 'replayed' or old['goal'] is not True
                or old['unexplained_steps'] != 0 or old.get('search_calls') != 0):
            raise ValueError(f'Historical native pass is unbound: {row["id"]}')
        if row['valid']:
            cohort = 'old_dual_control'
            if old['physical']['status'] != 'replayed' or old['physical']['goal'] is not True:
                raise ValueError(f'Invalid historical positive control: {row["id"]}')
        elif old['physical']['status'] == 'unsupported' and old['physical']['reason'] == UNSUPPORTED:
            cohort = 'axiom_recheck'
        else:
            raise ValueError(f'Unexpected outcome in the dual-reference cohort: {row["id"]}')

        plan = Path(row['plan'])
        folder = plan.parent / 'replay'
        invocation = read(folder / 'invocation.json')
        checked = read(folder / 'checked_result.json')
        if (checked != old or invocation['mode'] != 'replay'
                or invocation['input_sha256'] != old['input_sha256']):
            raise ValueError(f'Archived replay receipt differs: {row["id"]}')
        replay_inputs = {pin(path, expected) for path, expected in old['input_sha256'].items()}
        inputs = {key: pin(row[key]) for key in ('domain', 'problem', 'plan', 'mapping')}
        if not {inputs[k] for k in ('domain', 'problem', 'plan')} <= replay_inputs:
            raise ValueError(f'Archived replay ran different inputs: {row["id"]}')
        reference = row['reference']
        pin(reference['source_plan'], reference['source_plan_sha256'])
        paired[row['condition']].add((row['group'], row['source'], row['world'], cohort,
                                      reference['source_plan_sha256']))
        tasks.append({'id': row['id'], 'condition': row['condition'], 'cohort': cohort,
                      **{key: str(path) for key, path in inputs.items()},
                      'historical_native_replay': str(folder / 'checked_result.json'),
                      'historical_native_steps': old['steps'], 'historical_physical': old['physical'],
                      'historical_dual_pass': bool(row['valid'])})

    expected = {(condition, cohort): count for condition in ('union', 'full')
                for cohort, count in [('axiom_recheck', 566), ('old_dual_control', 784)]}
    if paired['union'] != paired['full'] or Counter((r['condition'], r['cohort']) for r in tasks) != expected:
        raise ValueError('Transport cases differ across conditions or frozen cohorts')

    output.mkdir(parents=True)
    for relative in IMPLEMENTATION:
        path = pin(repo / relative)
        snapshot = output / 'implementation' / relative
        snapshot.parent.mkdir(parents=True, exist_ok=True)
        snapshot.write_bytes(path.read_bytes())
        pin(snapshot, hashes[path])
    protocol = {'status': 'frozen_before_independent_saved_plan_recheck',
                'created_utc': datetime.now(timezone.utc).isoformat(), 'source': str(source),
                'registered': len(tasks), 'tasks': tasks, 'input_sha256': {str(p): h for p, h in hashes.items()},
                'search_calls': 0, 'new_native_replay_calls': 0, 'model_requests': 0,
                'scope': 'Both arms of the 1,350 dual-reference transport trials. A new independent physical check pairs with the archived native pass. No change to the original evidence batch or plan bytes.'}
    _write(output / 'protocol.json', protocol)
    pin(output / 'protocol.json')

    results = []
    for task in tasks:
        try:
            check = replay_saved(*(Path(task[k]) for k in ('domain', 'problem', 'plan')), native_axioms=True)
        except (ValueError, KeyError, TypeError) as exc:
            check = {'status': 'unsupported_or_invalid_input', 'reason': str(exc)}
        if check['status'] == 'replayed' and check['steps'] != task['historical_native_steps']:
            check = {'status': 'step_count_mismatch', 'result': check}
        passed = check['status'] == 'replayed' and check['goal'] is True
        # Replay returns tuples for atoms. The archived receipt stores JSON arrays.
        check = json.loads(json.dumps(check))
        results.append({**task, 'new_physical': check, 'dual_pass_with_retained_native': passed,
                        'control_identical': task['cohort'] != 'old_dual_control' or check == task['historical_physical']})

    if any(_sha(p) != digest for p, digest in hashes.items()):
        raise ValueError('Inputs changed during replay audit')
    summary = {}
    for condition in ('union', 'full'):
        all_rows = [r for r in results if r['condition'] == condition]
        cohort = [r for r in all_rows if r['cohort'] == 'axiom_recheck']
        summary[condition] = {
            'dual_reference_trials': len(all_rows), 'historical_dual_pass': sum(r['historical_dual_pass'] for r in all_rows),
            'verified_dual_pass': sum(r['dual_pass_with_retained_native'] for r in all_rows),
            'targeted': len(cohort), 'new_dual_pass': sum(r['dual_pass_with_retained_native'] for r in cohort),
            'targeted_statuses': dict(Counter(r['new_physical']['status'] for r in cohort)),
            'targeted_goal_failures': sum(r['new_physical']['status'] == 'replayed' and not r['new_physical']['goal'] for r in cohort),
            'no_grounded_physical_axioms': sum(r['new_physical'].get('grounded_physical_axioms') == 0 for r in cohort),
            'all_axioms_disabled_by_source': sum(r['new_physical'].get('axiom_templates', 0) > 0
                                                 and r['new_physical']['source_disabled_axiom_templates']
                                                 == r['new_physical']['axiom_templates'] for r in cohort),
            'any_axiom_state_update': sum(any(r['new_physical'].get('axiom_closure_rounds', [])) for r in cohort),
        }
    controls_passed = all(r['control_identical'] for r in results)
    result = {'status': 'complete_independent_axiom_transport_recheck' if controls_passed else 'control_discrepancy',
              'registered': len(results), 'summary': summary, 'rows': results,
              'historical_positive_controls': 1568, 'controls_identical': controls_passed,
              'protocol_sha256': hashes[(output / 'protocol.json').resolve()], 'inputs_unchanged': True,
              'search_calls': 0, 'new_native_replay_calls': 0, 'model_requests': 0,
              'scope': protocol['scope'],
              'limits': ['Native finite state-update axioms only. PDDL derived predicates remain outside this checker.',
                         'Order-sensitive effects, inconsistent updates, and nonconvergent closure remain unverified.',
                         'Physical replay checks applicability and goal satisfaction. Archived native intention checks are retained.']}
    _write(output / 'report.json', result)
    print(json.dumps({key: value for key, value in result.items() if key != 'rows'}, indent=2))
    return controls_passed


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    sys.addaudithook(_offline)
    sys.exit(0 if recheck(args.run.resolve(), args.output.resolve()) else 1)

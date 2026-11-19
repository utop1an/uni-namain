"""Recheck saved original-goal plans and assemble the November 9 Table 4."""

import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import sys

from rcnc.saved_plan_validation import replay_saved
from scripts.audit.recheck_glaive_axiom_transports import (
    IMPLEMENTATION, UNSUPPORTED, _offline, _sha, _write,
)


ARMS = ('union', 'full')


def recheck(run, transport_recheck, output):
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

    inventory = read(run / 'comparison_v1/verified_inventory/result_sources.json')['reports']

    def historical_stage(name):
        path = run / 'repeat_01' / f'{name}_report.json'
        entry = inventory['current_' + name]
        if Path(entry['path']).resolve() != path.resolve():
            raise ValueError(f'Historical inventory points to a different {name} report')
        report = read(path, entry['sha256'])
        rows = report['rows']
        if len(rows) != report['registered_slots'] or len({r['id'] for r in rows}) != len(rows):
            raise ValueError(f'Incomplete or duplicate {name} records')
        return rows

    anchors = historical_stage('anchor')
    native = {(r['world'], r['condition']): r for r in historical_stage('native')}
    transports = historical_stage('transport')
    transport_inventory = read(transport_recheck / 'verified_inventory/results.json')
    if transport_inventory['status'] != 'verified_snapshot' or transport_inventory['excluded_pending']:
        raise ValueError('Transport recheck is not a verified evidence snapshot')
    transport_entry = transport_inventory['results']['final_axiom_recheck']
    transport_report_path = transport_recheck / 'report.json'
    if Path(transport_entry['path']).resolve() != transport_report_path.resolve():
        raise ValueError('Transport evidence points to a different report')
    transport_report = read(transport_report_path, transport_entry['sha256'])
    transport_protocol = read(transport_recheck / 'protocol.json', transport_report['protocol_sha256'])
    if (transport_report['status'] != 'complete_independent_axiom_transport_recheck'
            or not transport_report['controls_identical']
            or Path(transport_protocol['source']).resolve() != (run / 'repeat_01/transport_report.json').resolve()):
        raise ValueError('Transport recheck must use the same full-run inputs')

    checker_files = IMPLEMENTATION[:5]
    for relative in checker_files:
        sealed = pin(transport_recheck / 'implementation' / relative)
        pin(repo / relative, hashes[sealed])

    by_arm = {arm: [r for r in anchors if r['condition'] == arm] for arm in ARMS}
    keys = lambda rows: {(r['group'], r['source'], r['world']) for r in rows}
    if len(anchors) != 4800 or len(keys(by_arm['union'])) != 2400 or keys(by_arm['union']) != keys(by_arm['full']):
        raise ValueError('Unmatched original-goal registry')

    tasks = []
    for row in anchors:
        old = row.get('replay', {})
        physical = old.get('physical', {})
        if (row['valid'] or not row['native_valid'] or physical.get('status') != 'unsupported'
                or physical.get('reason') != UNSUPPORTED):
            continue
        if (row['search']['status'] != 'solved' or old['status'] != 'replayed' or old['goal'] is not True
                or old['unexplained_steps'] != 0 or old['search_calls'] != 0):
            raise ValueError(f'Archived native pass is not bound: {row["id"]}')
        plan = Path(row['plan'])
        folder = plan.parent.parent / 'replay'
        invocation = read(folder / 'invocation.json')
        checked = read(folder / 'checked_result.json')
        if checked != old or invocation['mode'] != 'replay' or invocation['input_sha256'] != old['input_sha256']:
            raise ValueError(f'Archived native replay differs: {row["id"]}')
        inputs = {key: pin(row[key]) for key in ('domain', 'problem', 'plan', 'mapping')}
        archived_inputs = {pin(path, digest) for path, digest in old['input_sha256'].items()}
        if not {inputs[key] for key in ('domain', 'problem', 'plan')} <= archived_inputs:
            raise ValueError(f'Replay ran a different saved input: {row["id"]}')
        tasks.append({'id': row['id'], 'condition': row['condition'], 'world': row['world'],
                      'group': row['group'], **{k: str(v) for k, v in inputs.items()},
                      'historical_native_replay': str(folder / 'checked_result.json'),
                      'historical_native_steps': old['steps'], 'historical_physical': physical})
    if Counter(t['condition'] for t in tasks) != {'union': 436, 'full': 435}:
        raise ValueError('Unexpected archived axiom-unsupported goal denominator')

    output.mkdir(parents=True)
    for relative in (*checker_files, 'scripts/audit/recheck_glaive_axiom_transports.py',
                     'scripts/audit/recheck_glaive_axiom_goals.py'):
        source = pin(repo / relative)
        destination = output / 'implementation' / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(source.read_bytes())
        pin(destination, hashes[source])
    protocol = {'status': 'frozen_before_independent_saved_goal_recheck',
                'created_utc': datetime.now(timezone.utc).isoformat(), 'registered': len(tasks),
                'tasks': tasks, 'input_sha256': {str(path): digest for path, digest in hashes.items()},
                'search_calls': 0, 'new_native_replay_calls': 0, 'model_requests': 0,
                'scope': 'The frozen native-axiom checker from the transport recheck is applied to archived original-goal plans whose previous physical check rejected axioms.'}
    _write(output / 'protocol.json', protocol)
    protocol_path = pin(output / 'protocol.json')

    results = []
    for task in tasks:
        try:
            physical = replay_saved(*(Path(task[k]) for k in ('domain', 'problem', 'plan')), native_axioms=True)
        except (ValueError, KeyError, TypeError) as exc:
            physical = {'status': 'unsupported_or_invalid_input', 'reason': str(exc)}
        if physical['status'] == 'replayed' and physical['steps'] != task['historical_native_steps']:
            physical = {'status': 'step_count_mismatch', 'result': physical}
        passed = physical['status'] == 'replayed' and physical['goal'] is True
        results.append({**task, 'new_physical': physical, 'dual_pass_with_retained_native': passed})

    if any(_sha(path) != expected for path, expected in hashes.items()):
        raise ValueError('Frozen input changed during recheck')

    source_search = {variant: sum(bool(native[r['world'], variant]['valid']) for r in by_arm['union'])
                     for variant in ('raw', 'adapter')}
    distinct_worlds = len({r['world'] for r in by_arm['union']})
    summaries = {}
    table = {'plan_replay_native': {'denominator': 2081}, 'plan_replay_dual': {'denominator': 1350},
             'original_goal_search_dual': {'denominator': 2400, 'historical_source_search': source_search}}
    for arm in ARMS:
        targeted = [r for r in results if r['condition'] == arm]
        history = by_arm[arm]
        old_pass = {r['id'] for r in history if r['valid']}
        promoted = {r['id'] for r in targeted if r['dual_pass_with_retained_native']}
        if old_pass & promoted:
            raise ValueError('Duplicate dual pass in revised totals')
        final = old_pass | promoted
        summary = {
            'registered': len(history), 'historical_dual_pass': len(old_pass),
            'targeted': len(targeted), 'new_dual_pass': len(promoted), 'updated_dual_pass': len(final),
            'recheck_statuses': dict(Counter(r['new_physical']['status'] for r in targeted)),
            'recheck_goal_failures': sum(r['new_physical']['status'] == 'replayed' and not r['new_physical']['goal'] for r in targeted),
            'unconfirmed_recheck_reasons': dict(Counter(r['new_physical'].get('reason', r['new_physical']['status'])
                                                       for r in targeted if not r['dual_pass_with_retained_native'])),
            'cases_with_axiom_state_updates': sum(any(r['new_physical'].get('axiom_closure_rounds', [])) for r in targeted),
            'outcomes': dict(Counter('dual_pass' if r['id'] in final else 'returned_plan_without_dual_pass'
                                     if r.get('search', {}).get('status') == 'solved'
                                     else r.get('search', {}).get('status', r['status']) for r in history)),
        }
        summaries[arm] = summary
        available = [r for r in transports if r['condition'] == arm and r['reference']['status'] == 'available']
        if len(available) != table['plan_replay_native']['denominator']:
            raise ValueError('Transport reference coverage differs')
        table['plan_replay_native'][arm] = sum(bool(r['native_valid']) for r in available)
        table['plan_replay_dual'][arm] = transport_report['summary'][arm]['verified_dual_pass']
        table['original_goal_search_dual'][arm] = summary['updated_dual_pass']

    report = {'status': 'complete_independent_axiom_goal_recheck', 'registered': len(results),
              'rows': results, 'summary': summaries, 'table4': table, 'distinct_goal_worlds': distinct_worlds,
              'protocol_sha256': hashes[protocol_path], 'inputs_unchanged': True,
              'search_calls': 0, 'new_native_replay_calls': 0, 'model_requests': 0,
              'scope': 'November 9 full-run outcomes with separate saved-plan physical rechecks. Source-side values retain their archived validation conditions. All other outcomes are carried forward.'}
    _write(output / 'report.json', report)
    print(json.dumps({k: v for k, v in report.items() if k != 'rows'}, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for argument in ('run', 'transport-recheck', 'output'):
        parser.add_argument('--' + argument, type=Path, required=True)
    args = parser.parse_args()
    sys.addaudithook(_offline)
    recheck(args.run.resolve(), args.transport_recheck.resolve(), args.output.resolve())

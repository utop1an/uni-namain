"""Audit the remaining saved original-goal plans without a search."""

import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import sys

from rcnc.pddl import parse_sexpr, section, serialize
from rcnc.saved_plan_validation import replay_saved
from scripts.audit.recheck_glaive_axiom_transports import IMPLEMENTATION, _offline, _sha, _write


def executed_projection(plan_path):
    """Keep the problem identity and order, omitting only explicit hypothetical steps."""
    tree = parse_sexpr(plan_path.read_text(encoding='utf-8'))
    steps = section(tree, ':steps')
    if steps is None:
        raise ValueError('Missing plan step list')
    kept, omitted = [], []
    for index, call in enumerate(steps[1:]):
        if not isinstance(call, list) or not call or not isinstance(call[0], str):
            raise ValueError('Malformed plan step')
        if call[0] == 'non-executed':
            if (len(call) != 2 or not isinstance(call[1], list) or not call[1]
                    or not all(isinstance(term, str) for term in call[1])):
                raise ValueError('Malformed non-executed annotation')
            omitted.append({'step_index': index, 'call': call})
        else:
            kept.append(call)
    if not omitted:
        raise ValueError('Expected a counterfactual plan')
    steps[1:] = kept
    return serialize(tree) + '\n', omitted, len(kept)


def recheck(run, previous, output):
    if output.exists():
        raise FileExistsError(output)
    repo = Path(__file__).resolve().parents[2]
    hashes = {}

    def pin(path, expected=None):
        path = Path(path).resolve()
        if path not in hashes:
            hashes[path] = _sha(path)
        if expected is not None and hashes[path] != expected:
            raise ValueError(f'Archived input hash mismatch: {path}')
        return path

    def read(path, expected=None):
        return json.loads(pin(path, expected).read_text(encoding='utf-8'))

    stages = read(run / 'comparison_v1/verified_inventory/result_sources.json')['reports']
    anchors_path = run / 'repeat_01/anchor_report.json'
    comparison_path = run / 'comparison_v1/report.json'
    for role, path in [('current_anchor', anchors_path), ('current_complete_comparison', comparison_path)]:
        if Path(stages[role]['path']).resolve() != path.resolve():
            raise ValueError(f'Wrong historical stage: {role}')
    anchors = read(anchors_path, stages['current_anchor']['sha256'])['rows']
    comparison = read(comparison_path, stages['current_complete_comparison']['sha256'])
    original_hashes = comparison['input_sha256']
    prior_index = read(previous / 'verified_inventory/results.json')
    if prior_index['status'] != 'verified_snapshot' or prior_index['excluded_pending']:
        raise ValueError('Previous Table 4 evidence has unresolved audit gates')
    indexed = prior_index['results']
    prior_path = previous / 'report.json'
    if Path(indexed['quantified_effect_recheck']['path']).resolve() != prior_path.resolve():
        raise ValueError('Previous report does not match its verified index')
    prior = read(prior_path, indexed['quantified_effect_recheck']['sha256'])
    first = read(indexed['prior_axiom_recheck']['path'], indexed['prior_axiom_recheck']['sha256'])
    if (prior['status'] != 'complete_independent_quantified_effect_recheck'
            or first['status'] != 'complete_independent_axiom_goal_recheck'
            or len(anchors) != 4800 or len({r['id'] for r in anchors}) != 4800):
        raise ValueError('Unexpected prior evidence or anchor denominator')
    read(previous / 'protocol.json', prior['protocol_sha256'])
    already_passed = {r['id'] for r in anchors if r['valid']}
    for report in (first, prior):
        new_ids = {r['id'] for r in report['rows'] if r['dual_pass_with_retained_native']}
        if already_passed & new_ids:
            raise ValueError('Duplicate pass in prior Table 4')
        already_passed |= new_ids
    for arm in ('union', 'full'):
        count = sum(r['condition'] == arm and r['id'] in already_passed for r in anchors)
        if count != prior['table4']['original_goal_search_dual'][arm]:
            raise ValueError(f'Prior Table 4 does not reconcile: {arm}')

    tasks = []
    for row in anchors:
        if row.get('search', {}).get('status') != 'solved' or row['id'] in already_passed:
            continue
        paths = {key: pin(row[key]) for key in ('domain', 'problem', 'plan', 'mapping')}
        search_result = paths['plan'].parent / 'result.json'
        search = read(search_result, original_hashes[str(search_result)])
        if search != row['search']:
            raise ValueError(f'Archived search receipt differs: {row["id"]}')
        search_inputs = {pin(path, expected) for path, expected in search['input_sha256'].items()}
        if not {paths[key] for key in ('domain', 'problem')} <= search_inputs:
            raise ValueError(f'Archived search inputs differ: {row["id"]}')
        old = row['replay']
        reason = old.get('physical', {}).get('reason', '')
        if row['native_valid'] and reason.startswith('Unbound variable: '):
            kind = 'quantified_scope'
            receipt_path = paths['plan'].parent.parent / 'replay/checked_result.json'
            receipt = read(receipt_path)
            receipt_inputs = {pin(path, digest) for path, digest in receipt['input_sha256'].items()}
            if (receipt != old or receipt['status'] != 'replayed' or receipt['goal'] is not True
                    or receipt['unexplained_steps'] != 0 or receipt['search_calls'] != 0
                    or not {paths[k] for k in ('domain', 'problem', 'plan')} <= receipt_inputs):
                raise ValueError(f'Native pass cannot be bound: {row["id"]}')
            evidence = {'native_replay_receipt': str(receipt_path), 'native_steps': receipt['steps'],
                        'plan_binding': 'archived_native_replay_input_sha256'}
        elif not row['native_valid'] and old['status'] == 'unavailable_counterfactual_plan_format':
            kind = 'counterfactual_projection'
            evidence = {'plan_binding': 'saved_path_in_archived_search_row_and_fresh_input_sha256'}
        else:
            raise ValueError(f'Unexpected unresolved plan: {row["id"]}')
        tasks.append({'id': row['id'], 'condition': row['condition'], 'world': row['world'],
                      'cohort': kind, **{k: str(v) for k, v in paths.items()}, **evidence,
                      'search_receipt': str(search_result), 'previous_replay_status': old['status'],
                      'previous_physical_reason': reason})
    denominators = {('union', 'quantified_scope'): 76, ('full', 'quantified_scope'): 75,
                    ('union', 'counterfactual_projection'): 41, ('full', 'counterfactual_projection'): 41}
    if Counter((t['condition'], t['cohort']) for t in tasks) != denominators:
        raise ValueError('Unexpected unresolved cohort sizes')

    output.mkdir(parents=True)
    for relative in (*IMPLEMENTATION, 'scripts/audit/recheck_glaive_remaining_goal_plans.py'):
        source = pin(repo / relative)
        destination = output / 'implementation' / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(source.read_bytes())
        pin(destination, hashes[source])
    protocol = {'status': 'frozen_before_remaining_saved_goal_recheck',
                'created_utc': datetime.now(timezone.utc).isoformat(), 'registered': len(tasks), 'tasks': tasks,
                'input_sha256': {str(path): digest for path, digest in hashes.items()},
                'search_calls': 0, 'new_native_replay_calls': 0, 'model_requests': 0,
                'scope': 'Full original-plan physical replay for archived native passes. Executed-path-only physical replay for annotated counterfactual plans.'}
    _write(output / 'protocol.json', protocol)
    protocol_path = pin(output / 'protocol.json')

    results = []
    for task in tasks:
        projected = task['cohort'] == 'counterfactual_projection'
        plan_path = Path(task['plan'])
        projection = None
        try:
            expected_steps = task.get('native_steps')
            if projected:
                text, omitted, expected_steps = executed_projection(plan_path)
                plan_path = output / 'projections' / (task['id'] + '.pddl')
                plan_path.parent.mkdir(exist_ok=True)
                with plan_path.open('x', encoding='utf-8') as stream:
                    stream.write(text)
                projection = {'path': str(plan_path), 'sha256': _sha(plan_path),
                              'omitted_nonexecuted': omitted, 'executed_steps': expected_steps}
            physical = replay_saved(Path(task['domain']), Path(task['problem']), plan_path,
                                    native_axioms=True, quantified_action_effects=True)
        except (ValueError, TypeError, KeyError) as exc:
            physical = {'status': 'unsupported_or_invalid_input', 'reason': str(exc)}
        if physical['status'] == 'replayed' and physical['steps'] != expected_steps:
            physical = {'status': 'step_count_mismatch', 'result': physical}
        passed = physical['status'] == 'replayed' and physical['goal'] is True
        results.append({**task, 'projection': projection, 'new_physical': physical,
                        'physical_pass': passed, 'dual_pass_with_retained_native': passed and not projected})
    if any(_sha(path) != digest for path, digest in hashes.items()):
        raise ValueError('Frozen inputs changed during replay')

    table = {check: dict(values) for check, values in prior['table4'].items()}
    goals = table['original_goal_search_dual']
    summary = {}
    for arm in ('union', 'full'):
        rows = [r for r in results if r['condition'] == arm]
        added = sum(r['dual_pass_with_retained_native'] for r in rows)
        before = goals[arm]
        goals[arm] = before + added
        outcomes = dict(prior['summary'][arm]['outcomes'])
        outcomes['dual_pass'] += added
        outcomes['returned_plan_without_dual_pass'] -= added
        if sum(outcomes.values()) != goals['denominator']:
            raise ValueError(f'Incomplete updated denominator: {arm}')
        summary[arm] = {'targeted': len(rows), 'new_dual_pass': added,
                        'previous_dual_pass': before, 'updated_dual_pass': goals[arm],
                        'counterfactual_executed_path_pass': sum(r['physical_pass'] for r in rows if r['projection']),
                        'recheck_statuses': dict(Counter(r['new_physical']['status'] for r in rows)), 'outcomes': outcomes}
    report = {'status': 'complete_remaining_saved_goal_recheck', 'registered': len(results), 'rows': results,
              'summary': summary, 'table4': table, 'distinct_goal_worlds': prior['distinct_goal_worlds'],
              'protocol_sha256': hashes[protocol_path], 'inputs_unchanged': True,
              'search_calls': 0, 'new_native_replay_calls': 0, 'model_requests': 0,
              'limits': ['Counterfactual plans are saved as a flat step list. Their physical executed path is checked separately from complete narrative intention explanations.',
                         'For the counterfactual cohort the archived search receipts bind the saved output path. The plan bytes are pinned at recheck registration; the historical search receipt did not include a plan output hash.']}
    _write(output / 'report.json', report)
    print(json.dumps({key: value for key, value in report.items() if key != 'rows'}, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for argument in ('run', 'previous', 'output'):
        parser.add_argument('--' + argument, required=True, type=Path)
    args = parser.parse_args()
    sys.addaudithook(_offline)
    recheck(args.run.resolve(), args.previous.resolve(), args.output.resolve())

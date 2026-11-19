"""Authorized continuation of the single selection round; retain its frozen history."""
import argparse
import ast
import copy
import math
import os
from pathlib import Path
import shutil
import traceback

from rcnc import model_semantics_retry as retry
from rcnc.domain_building import digest, save
from rcnc.parallel_progress_io import durable_progress
from scripts.experiments import run_selection_comparison as base

CONDITION = 'interrupted_cache_continuation_with_bounded_retries'


def verify_parent(parent):
    p = base.read(parent / 'protocol.json')
    if digest(parent / 'protocol.json') != (parent / 'PROTOCOL.sha256').read_text(encoding='utf-8').strip():
        raise ValueError('Parent protocol changed')
    for name, expected in p['input_sha256'].items():
        if digest(Path(name)) != expected: raise ValueError('Parent input changed: ' + name)
    for name, expected in p['implementation_sha256'].items():
        path = Path(name) if Path(name).is_absolute() else parent / 'implementation' / name
        if digest(path) != expected: raise ValueError('Parent implementation changed: ' + name)
    return p


def only_evaluation_changed(original, current):
    def signature(path):
        tree = ast.parse(path.read_text(encoding='utf-8'))
        tree.body = [n for n in tree.body if not isinstance(n, ast.FunctionDef) or n.name != 'evaluation']
        return ast.dump(tree, include_attributes=False)
    return signature(original) == signature(current)


def prepare(parent, output):
    if output.exists(): raise ValueError('Fresh versioned continuation directory required')
    p = verify_parent(parent)
    state = base.read(parent / 'coordinator.json')
    if state['status'] != 'stopped_model_stage_incomplete' or state['stage'] != 'terminal' or state['completed_repeats'] != 0:
        raise ValueError('Expected terminated first-round semantic interruption')
    if {x.name for x in (parent / 'repeat_01').iterdir()} != {'judgments'}:
        raise ValueError('Cannot rerun prior compilation or planning')
    j = parent / 'repeat_01/judgments'
    old = base.read(j / 'report.json'); original_manifest = base.read(j / 'manifest.json')
    items = base.read(j / 'packet.json')['items']; requests = base.read(j / 'requests.json')
    retained, pending, previous = retry.partition(items, old['rows'])
    if not old['inputs_unchanged'] or not old['implementation_unchanged']:
        raise ValueError('Parent run failed integrity checks')
    if set(requests) != {i['id'] for i in items} or len(items) != 8017:
        raise ValueError('Changed original requests')
    for row in old['rows']:
        if row['request_attempted']:
            folder = j / 'responses' / row['id']
            if base.read(folder / 'attempt.json')['request'] != requests[row['id']] or base.read(folder / 'result.json') != row:
                raise ValueError('Parent attempt provenance differs')
    remaining = p['budgets']['model_seconds'] - math.ceil(old['elapsed_seconds'])
    if remaining <= 0 or not pending: raise ValueError('No remaining registered work/budget')
    source_root = Path(__file__).resolve().parents[2]
    base_relative = Path('scripts/experiments/run_selection_comparison.py')
    if not only_evaluation_changed(parent / 'implementation' / base_relative, source_root / base_relative):
        raise ValueError('Compiler/planner changed since original freeze')
    inherited = {str(f): digest(f) for f in sorted(parent.rglob('*')) if f.is_file() and '__pycache__' not in f.parts}
    output.mkdir(parents=True)
    implementation = output / 'implementation'
    overlays = {base_relative, Path('rcnc/model_semantics_retry.py'), Path('scripts/experiments/continue_selection_comparison.py')}
    for name in sorted(set(p['implementation_sha256']) | {n.as_posix() for n in overlays}):
        rel = Path(name)
        if rel.is_absolute() or '..' in rel.parts: raise ValueError('Unexpected original snapshot path')
        source = source_root / rel if rel in overlays else parent / 'implementation' / rel
        target = implementation / rel; target.parent.mkdir(parents=True, exist_ok=True); shutil.copy2(source, target)
    impl = {str(f): digest(f) for f in sorted(implementation.rglob('*.py'))}
    for name in ('selected_groups.json', 'sources.json', 'worlds.json', 'baseline_tasks.json', 'candidate_usage.json',
                 'dataset_audit.json', 'preflight_report.json'):
        shutil.copy2(parent / name, output / name)
    target = output / 'repeat_01/judgments'; target.mkdir(parents=True)
    for name in ('packet.json', 'requests.json'): shutil.copy2(j / name, target / name)
    history = {'parent': str(parent), 'parent_protocol_sha256': digest(parent / 'protocol.json'),
        'parent_report': str(j / 'report.json'), 'parent_report_sha256': digest(j / 'report.json'),
        'parent_status_counts': old['status_counts'], 'retained_parent_outputs': len(retained),
        'retained_parent_ids': sorted(retained), 'pending_candidates': len(pending),
        'prior_attempts_for_pending': previous, 'parent_active_model_seconds': old['elapsed_seconds'],
        'remaining_active_model_seconds': remaining, 'wall_clock_interruption_excluded_from_active_budget': True,
        'original_fresh_round_completed': False,
        'authorization': 'User requested continuing existing results with limited retries for temporary errors, then evaluation.'}
    base.frozen_json(output / 'continuation.json', history)
    local = {str(f): digest(f) for f in output.rglob('*') if f.is_file()}
    manifest = copy.deepcopy(original_manifest)
    manifest.update(status='frozen_authorized_continuation', created_utc=base.now(), condition=CONDITION,
        scope='Authorized cache continuation, identical requests, bounded retries of transient errors only; invalid outputs retained.',
        total_seconds=remaining, attempts_per_candidate=3, retry_policy=copy.deepcopy(retry.POLICY),
        parent_report=str(j / 'report.json'), pending_candidates=len(pending), retained_parent_outputs=len(retained),
        frozen_sha256={**inherited, **p['input_sha256'], **local}, implementation_sha256=impl)
    base.frozen_json(target / 'manifest.json', manifest)
    protocol = copy.deepcopy(p)
    protocol.update(status='frozen_authorized_continuation', created_utc=base.now(), condition=CONDITION,
        continuation=history, retry_policy=copy.deepcopy(retry.POLICY),
        implementation_sha256=impl,
        input_sha256={**inherited, **p['input_sha256'], **local, str(target / 'manifest.json'): digest(target / 'manifest.json')})
    protocol['budgets'].update(model_seconds=remaining, attempts=3, new_candidate_requests=len(pending),
        maximum_new_retry_attempts=retry.POLICY['maximum_new_retry_attempts'],
        maximum_new_transport_attempts=len(pending) - sum(previous.values()) + retry.POLICY['maximum_new_retry_attempts'])
    protocol['policies'][0] = 'Authorized cache continuation of the interrupted single round. Preserve checked AND invalid outputs byte-for-byte in the parent; no new independent repeat.'
    protocol['policies'][16] = 'Temporary transport errors only: at most three total attempts per candidate including parent; 30/60-second backoff, at most 200 new retry attempts globally. Exhausted temporary failures remain unavailable; permanent errors or global budget exhaustion stop dispatch and trigger evaluation.'
    protocol['policies'].append('Prompts, model, thresholds, groups, compiler, planner and search budgets are unchanged. Aggregate results must be labeled continuation, never fresh-run completion.')
    base.frozen_json(output / 'protocol.json', protocol)
    (output / 'PROTOCOL.sha256').write_text(digest(output / 'protocol.json') + '\n', encoding='utf-8')
    return {'status': protocol['status'], 'condition': CONDITION, 'retained': len(retained),
            'pending': len(pending), 'remaining_active_model_seconds': remaining,
            'maximum_new_transport_attempts': protocol['budgets']['maximum_new_transport_attempts'],
            'protocol_sha256': digest(output / 'protocol.json')}


def pipeline(root):
    p = base.verify(root)
    if p.get('condition') != CONDITION or (root / 'coordinator.json').exists():
        raise ValueError('Fresh explicitly authorized continuation only')
    state = {'status': 'running', 'stage': 'judgments', 'condition': CONDITION, 'started_utc': base.now(),
        'pid': os.getpid(), 'protocol_sha256': digest(root / 'protocol.json'), 'registered_repeats': 1,
        'completed_repeats': 0, 'original_fresh_round_completed': False, 'parent': p['continuation']['parent']}
    durable_progress(root / 'coordinator.json', state)
    try:
        judgments = retry.run(root / 'repeat_01/judgments')
        if judgments['execution_status'] != 'complete' or judgments['status_counts'].get('not_requested', 0):
            state.update(status='stopped_model_stage_incomplete', reason=judgments['stop_reason'] or 'unrequested_candidates')
        else:
            state['stage'] = 'compilation'; durable_progress(root / 'coordinator.json', state)
            base.compile_all(root, state)
            state['stage'] = 'planning'; durable_progress(root / 'coordinator.json', state)
            base.execute_all(root, state)
            state.update(status='complete', completed_repeats=1)
    except Exception as exc:
        state.update(status='failed', error=str(exc), traceback=traceback.format_exc())
    finally:
        state.update(ended_utc=base.now(), stage='evaluation'); durable_progress(root / 'coordinator.json', state)
        try:
            state['evaluation'] = base.evaluation(root, state['status'])
        except Exception as exc:
            state['evaluation'] = {'status': 'failed', 'error': str(exc), 'traceback': traceback.format_exc()}
        state['stage'] = 'terminal'; durable_progress(root / 'coordinator.json', state)
        save(root / 'report.json', state)
    return state


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=('prepare', 'verify', 'pipeline'))
    parser.add_argument('--parent', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args(); root = args.output.resolve()
    if args.mode == 'prepare': result = prepare(args.parent.resolve(), root)
    elif args.mode == 'verify':
        p = base.verify(root); result = {'status': 'verified', 'condition': p['condition'], 'groups': p['groups']}
    else: result = pipeline(root)
    import json
    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()

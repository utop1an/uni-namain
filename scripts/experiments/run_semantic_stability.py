"""Three predeclared repeated requests per known candidate; never pick a winner."""
import argparse
from collections import Counter
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import shutil

from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.model_semantics import prepare as prepare_model, run as run_model
from rcnc.model_semantics_contract import include_output_contract
from scripts.experiments.run_role_contract_merge import check_freeze, code_paths, compile_tasks, read
from scripts.experiments.run_transport_merge import MODEL_DIGEST


def prepare(parent, output):
    require_empty_output(output)
    before = read(parent / 'pre_model_freeze.json')
    for p, h in before['input_sha256'].items():
        if digest(Path(p)) != h:
            raise ValueError('Historical input changed: ' + p)
    output.mkdir(parents=True)
    paths = [*code_paths(), Path(__file__), Path('rcnc/model_semantics_compact.py')]
    for repeat in range(1, 4):
        root = output / f'repeat_{repeat:02d}'
        root.mkdir()
        for name in ('inputs', 'native'):
            shutil.copytree(parent / name, root / name)
        protocol = copy.deepcopy(read(parent / 'protocol.json'))
        for case in protocol['originals']:
            case['directory'] = (root / Path(case['directory']).relative_to(parent)).as_posix()
        for key in ('reused_budget_control', 'followup_parent'):
            protocol.pop(key, None)
        protocol.update(created_utc=datetime.now(timezone.utc).isoformat(), stability_repeat=repeat,
            parent=parent.as_posix(), model_conditions={'compact_kind_specific': {'pairs': 11}},
            planned_solver_calls=126 if repeat == 1 else 0,
            scope='Known development candidates, three identical-request repeats; same seed and temperature, not independent seeds or held-out semantic accuracy. Repeat 1 is selected for 126 planning calls BEFORE model output; repeats 2/3 only compile. No retries, answer pooling, voting or best-repeat selection.')
        save(root / 'protocol.json', protocol)
        prepare_model(root / 'inputs', protocol['pairs'], root / 'judgments', model='glm-5.3:cloud',
            model_digest=MODEL_DIGEST, total_seconds=2640, request_seconds=240,
            schema_policy='compact_kind_specific', num_predict=16384, num_ctx=32768)
        include_output_contract(root / 'judgments')
        if read(root / 'judgments/packet.json') != read(parent / 'judgments/packet.json'):
            raise ValueError('Source contexts changed')
        code = snapshot_implementation(root / 'pre_model', paths)
        files = [p for p in root.rglob('*') if p.is_file() and 'implementation' not in p.parts]
        save(root / 'pre_model_freeze.json', {'status': 'frozen_before_model_calls',
            'input_sha256': {p.as_posix(): digest(p) for p in files}, 'implementation_sha256': code})
    requests = [read(output / f'repeat_{r:02d}/judgments/requests.json') for r in range(1, 4)]
    if not requests[0] == requests[1] == requests[2]:
        raise ValueError('Repeated model requests differ')
    protocol = {'status': 'frozen_before_model_calls', 'created_utc': datetime.now(timezone.utc).isoformat(),
        'parent': parent.as_posix(), 'repeats': 3, 'candidates_per_repeat': 11, 'model_requests_planned': 33,
        'planner_calls_planned': 126, 'planning_repeat': 1, 'attempts_per_candidate_repeat': 1,
        'workers': 1, 'same_seed_repeats': True, 'total_request_budget_seconds': 7920,
        'primary_threshold': .9, 'sensitivity_threshold': .8,
        'compiler_acceptance': read(parent / 'protocol.json')['acceptance'],
        'gate': {'formal_unseen_run': 'Freeze only after reporting all repeated response/merge outcomes; do not launch held-out runs automatically on this development block.',
                 'semantic_failures': 'Unknown and invalid remain source variants. No answer substitution, retries or winner selection.',
                 'transport_failure': 'Stop subsequent remote requests across all repeats; retain all not_requested rows.'},
        'metrics': ['valid_response_fraction', 'decision_agreement_all_candidates', 'parameter_correspondence_agreement',
                    'primary_acceptance_agreement', 'actual_compilation_agreement', 'original_plan_transport', 'cross_source_controls'],
        'scope': 'Development reliability regression; candidate selection and prior inputs are known. No independent semantic labels or efficiency claim.'}
    save(output / 'protocol.json', protocol)
    files = [p for p in output.rglob('*') if p.is_file() and 'implementation' not in p.parts]
    save(output / 'manifest.json', {'status': 'frozen_before_model_calls',
        'input_sha256': {p.as_posix(): digest(p) for p in files},
        'implementation_sha256': snapshot_implementation(output, paths)})
    return protocol


def check(root):
    manifest = read(root / 'manifest.json')
    for p, h in {**manifest['input_sha256'], **manifest['implementation_sha256']}.items():
        if digest(Path(p)) != h:
            raise ValueError('Frozen stability input/code changed: ' + p)


def judge(root):
    check(root)
    if any((root / f'repeat_{r:02d}/judgments/progress.json').exists() for r in range(1, 4)):
        raise ValueError('Fresh block only; no resume')
    stopped = False
    def unavailable(*args, **kwargs):
        raise RuntimeError('Earlier repeat transport failure; no new connection attempted')
    for r in range(1, 4):
        folder = root / f'repeat_{r:02d}'
        check_freeze(folder)
        report = run_model(folder / 'judgments', **({'transport': unavailable} if stopped else {}))
        stopped = stopped or report['status_counts'].get('request_failed', 0) > 0
        print(json.dumps({'repeat': r, 'attempts': report['requests_attempted'], 'statuses': report['status_counts']}), flush=True)
    return summarize(root, compiled=False)


def correspondence(response):
    if response.get('decision') != 'compatible':
        return None
    # Canonical role ordering and prose may vary without changing the bijection.
    return sorted(zip(*response['orders']))


def summarize(root, *, compiled):
    from scripts.audit.audit_semantic_facets_comparison import verify_model
    check(root)
    reports = [verify_model(root / f'repeat_{r:02d}') for r in range(1, 4)]
    packets = [read(root / f'repeat_{r:02d}/judgments/packet.json') for r in range(1, 4)]
    if not packets[0] == packets[1] == packets[2]:
        raise ValueError('Candidate contexts differ')
    rows = []
    for i, item in enumerate(packets[0]['items']):
        rs = [report['rows'][i] for report in reports]
        decisions = [r.get('response', {}).get('decision', r['status']) for r in rs]
        accepted = [r['status'] == 'checked' and r['response']['decision'] == 'compatible' and r['response']['confidence'] >= .9 for r in rs]
        maps = [correspondence(r.get('response', {})) for r in rs]
        rows.append({'id': item['id'], 'kind': item['kind'], 'decisions': decisions,
            'confidences': [r.get('response', {}).get('confidence') for r in rs],
            'statuses': [r['status'] for r in rs], 'primary_semantic_acceptance': accepted,
            'decision_agrees': len(set(decisions)) == 1,
            'primary_acceptance_agrees': len(set(accepted)) == 1,
            'correspondence_agrees': maps[0] == maps[1] == maps[2], 'correspondences': maps})
    comparisons = []
    if compiled:
        for bundle in read(root / 'repeat_01/protocol.json')['bundles']:
            for condition in ('no_share', 'predicate090', 'full090', 'predicate080', 'full080'):
                models = [read(root / f'repeat_{r:02d}/models' / bundle / condition / 'validation.json') for r in range(1, 4)]
                summaries = [{'predicate_groups': m['merged_predicate_groups'], 'action_groups': m['merged_action_groups'],
                    'accepted': sorted((d['kind'], d['id']) for d in m['decisions'] if d['status'] == 'accepted')} for m in models]
                comparisons.append({'bundle': bundle, 'condition': condition, 'repeats': summaries,
                    'agreement': summaries[0] == summaries[1] == summaries[2]})
    counts = Counter()
    for r in reports:
        counts.update(r['status_counts'])
    result = {'status': 'verified', 'candidate_count': 11, 'repeated_slots': 33,
        'requests_attempted': sum(r['requests_attempted'] for r in reports), 'status_counts': dict(counts),
        'valid_responses': counts['checked'], 'rows': rows,
        'decision_agreement': sum(r['decision_agrees'] for r in rows),
        'primary_acceptance_agreement': sum(r['primary_acceptance_agrees'] for r in rows),
        'correspondence_agreement': sum(r['correspondence_agrees'] for r in rows),
        'compilation_comparisons': comparisons, 'planning_repeat_preselected': 1,
        'raw_predictions_verified': True, 'frozen_inputs_verified': True,
        'parent_reports': {str(root / f'repeat_{r:02d}/judgments/report.json'): digest(root / f'repeat_{r:02d}/judgments/report.json') for r in range(1, 4)},
        'manifest_sha256': digest(root / 'manifest.json'), 'scope': read(root / 'protocol.json')['scope']}
    target = root / ('compilation_stability.json' if compiled else 'response_stability.json')
    if target.exists():
        raise ValueError('Do not overwrite completed stability report')
    save(target, result)
    return result


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('mode', choices=['prepare', 'judge', 'compile', 'execute'])
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--parent', type=Path, default=Path('data/validation/role_identity_merge_2026_10_28_v1'))
    args = p.parse_args()
    if args.mode == 'prepare':
        result = prepare(args.parent, args.output)
    elif args.mode == 'judge':
        result = judge(args.output)
    elif args.mode == 'compile':
        check(args.output)
        for r in range(1, 4):
            compile_tasks(args.output / f'repeat_{r:02d}')
        result = summarize(args.output, compiled=True)
    else:
        from scripts.experiments.frozen_solver import execute
        check(args.output)
        result = execute(args.output / 'repeat_01')
    print(json.dumps({k: v for k, v in result.items() if k not in ('rows', 'parent_reports', 'compilation_comparisons', 'compiler_acceptance')}, indent=2))

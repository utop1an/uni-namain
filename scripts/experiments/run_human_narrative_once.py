"""One fresh repeat of the revised multistory design on three authored domains."""
import argparse
from itertools import combinations
from pathlib import Path
import shutil

from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.glaive_merge import Source, candidate_pairs
from rcnc import model_semantics
from rcnc.model_semantics_contract import include_output_contract
from scripts.experiments import run_revised_multistory as base

COLLECTION = Path('data/human_narrative_domains_2026_11_04_v1')
ADMISSION = Path('data/validation/human_single_domain_2026_11_04_v3/report.json')


def prepare(root, gate):
    if root.exists():
        raise ValueError('Fresh output required')
    if base.read(gate/'report.json')['status'] != 'passed':
        raise ValueError('Preflight failed')
    admission = base.read(ADMISSION)
    chosen = {'case_009': 'rooms', 'case_017': 'heist', 'case_029': 'batman'}
    selected = [r for r in admission['rows'] if r['id'] in chosen]
    if len(selected) != 3 or not all(r['single_domain_pass'] for r in selected):
        raise ValueError('Admission mismatch')
    root.mkdir(parents=True)
    (root/'inputs').mkdir()
    (root/'runtime/classes').mkdir(parents=True)
    rows, sources = [], []
    for r in selected:
        sid = chosen[r['id']]
        files = {}
        for key, name in [('domain', 'revised-domain.pddl'), ('problem', 'revised-problem.pddl')]:
            original = COLLECTION/r[key]
            target = root/'inputs'/(sid+('_domainfile.pddl' if key == 'domain' else '_problem.pddl'))
            shutil.copyfile(original, target)
            files[name] = {'frozen_path': str(target.resolve()), 'sha256': digest(target), 'original': str(original)}
        rows.append({'id': sid, 'files': files, 'raw_parse_status': r['native']['status']})
        sources.append(Source(sid, Path(files['revised-domain.pddl']['frozen_path']), Path(files['revised-problem.pddl']['frozen_path'])))
    groups = []
    for k in (2, 3):
        for ids in combinations(sorted(chosen.values()), k):
            gid = '__'.join(ids)
            groups.append({'id': gid, 'size': k, 'chain_id': gid, 'sources': list(ids), 'anchor_sources': list(ids[:2])})
    candidates = [c for pair in candidate_pairs(sources) for c in pair['candidates']]
    save(root/'selected_groups.json', {'groups': groups})
    save(root/'selected_candidates.json', {'candidates': candidates})
    runtime = base.read(base.RUNTIME/'report.json')
    if runtime['status'] != 'verified' or digest(Path(runtime['jar'])) != runtime['jar_sha256']:
        raise ValueError('Runtime verification failed')
    shutil.copyfile(runtime['jar'], root/'runtime/glaive-corrected.jar')
    shutil.copyfile('.tmp/glaive_classes_v1/GlaiveProbe.class', root/'runtime/classes/GlaiveProbe.class')
    repeat = root/'repeat_01'
    judgments = repeat/'judgments'
    model_semantics.prepare(root/'inputs', candidates, judgments, model=base.MODEL, model_digest=base.MODEL_DIGEST,
        total_seconds=max(240, len(candidates)*240), request_seconds=240,
        schema_policy='compact_kind_specific', num_predict=16384, num_ctx=32768)
    include_output_contract(judgments)
    requests = base.read(judgments/'requests.json')
    manifest = base.read(judgments/'manifest.json')
    for request in requests.values():
        request['options']['seed'] = 2026110401
    manifest['options']['seed'] = 2026110401
    save(judgments/'requests.json', requests)
    manifest['requests_sha256'] = digest(judgments/'requests.json')
    save(judgments/'manifest.json', manifest)
    implementations = snapshot_implementation(root, [*base.IMPLEMENTATION, Path(__file__)])
    files = [p for p in root.rglob('*') if p.is_file()] + [ADMISSION, gate/'report.json']
    for r in selected:
        files.extend([COLLECTION/r['domain'], COLLECTION/r['problem']])
    protocol = {'status': 'frozen_before_calls', 'created_utc': base.now(),
        'design_reference': 'scripts/experiments/run_revised_multistory.py',
        'sources': 3, 'groups': len(groups), 'selected_sizes': [2, 3], 'source_rows': rows,
        'repeats': [{'id': 'repeat_01', 'path': str(repeat), 'seed': 2026110401}],
        'conditions': ['native', *base.CONDITIONS], 'model': base.MODEL,
        'runtime_jar': str(root/'runtime/glaive-corrected.jar'), 'runtime_classes': str(root/'runtime/classes'),
        'input_sha256': {str(p): digest(p) for p in files}, 'implementation_sha256': implementations,
        'budgets': {'model_requests': len(candidates), 'request_seconds': 240, 'search_slots': 27,
                    'search_seconds': 15, 'replay_seconds': 15, 'transport_slots': 27, 'attempts': 1},
        'policy': ['All three pairs and the triple; first two lexically sorted sources are search anchors.',
                   'One fresh repeat, no retry, replacement, fallback or continuation.',
                   'Raw native sources retained including Rooms parse failure; no syntax repairs.',
                   'Separate source worlds; no pooled initial states; no invented cross-domain goals.',
                   'Fresh model judgments with threshold 0.9, no independent semantic or narrative labels.',
                   'No k=4 group because only three distinct domains are available.']}
    save(root/'protocol.json', protocol)
    (root/'PROTOCOL.sha256').write_text(digest(root/'protocol.json')+'  protocol.json\n', encoding='utf-8')
    return {'sources': 3, 'groups': len(groups), 'candidates': len(candidates), 'search_slots': 27, 'repeats': 1}


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('mode', choices=['preflight', 'prepare', 'pipeline'])
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--gate', type=Path)
    args = parser.parse_args()
    if args.mode == 'prepare':
        result = prepare(args.output.resolve(), args.gate)
    elif args.mode == 'preflight':
        result = base.preflight(args.output)
    else:
        result = base.pipeline(args.output.resolve())
    print(result)

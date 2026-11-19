"""Bind composition results to source-plan preservation in the same full models."""
import argparse
from collections import Counter
from pathlib import Path
import json
import shutil
import time

from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.glaive_merge import translate_plan
from scripts.experiments import run_revised_multistory as base


def prepare(evaluation, output):
    if output.exists(): raise ValueError('Fresh output directory required')
    p = base.verify(evaluation)
    campaign = Path(p['parent_campaign']); parent = base.read(campaign / 'protocol.json')
    sources = base.load_sources(parent)
    snapshot = base.read(evaluation / 'preservation_snapshot.json')
    native = {e['row']['source']: e['row'] for e in snapshot['events'] if e['kind'] == 'native'}
    cases = base.read(evaluation / 'selected_cases.json')['cases']
    output.mkdir(parents=True)
    tasks = []
    for case in cases:
        group = case['group']
        for sid in group['sources']:
            row = {'id': group['id'] + '__' + sid, 'group': group['id'], 'source': sid, 'size': group['size']}
            result = native[sid]
            if not base.valid(result.get('replay', {})):
                row.update(status='unavailable_valid_native_plan', native_status=result['status'])
            else:
                folder = output / 'inputs' / row['id']; folder.mkdir(parents=True)
                source = sources[sid]
                original = campaign / 'repeat_01/execution/native' / sid / 'plan.pddl'
                if result['replay']['input_sha256'].get(str(original.resolve())) != digest(original):
                    raise ValueError('Native plan differs from validated snapshot')
                shutil.copy2(original, folder / 'native_plan.pddl')
                problem_source = campaign / 'repeat_01/models' / group['id'] / 'full' / (sid + '.pddl')
                expected = base.read(evaluation / 'parent_compilation.json')['input_sha256'][str(problem_source)]
                if digest(problem_source) != expected: raise ValueError('Changed original-world problem')
                shutil.copy2(problem_source, folder / 'original_world.pddl')
                model = evaluation / 'models' / group['id'] / 'full'
                meta = base.read(model / 'mapping.json')
                terms = {**source.term_map, **{o: sid + '_o_' + o for o in source.objects}}
                translate_plan(sid, meta, terms, folder / 'native_plan.pddl', folder / 'transport.pddl')
                row.update(status='ready', domain=str(model / 'domain.pddl'),
                    problem=str(folder / 'original_world.pddl'), plan=str(folder / 'transport.pddl'))
            tasks.append(row)
    save(output / 'tasks.json', {'tasks': tasks})
    shutil.copy2(evaluation / 'report.json', output / 'composition_report.json')
    inputs = {str(f): digest(f) for f in output.rglob('*') if f.is_file()}
    for row in tasks:
        if row['status'] == 'ready': inputs[row['domain']] = digest(Path(row['domain']))
    for f in (evaluation / 'runtime').rglob('*'):
        if f.is_file(): inputs[str(f)] = digest(f)
    impl = snapshot_implementation(output, [Path(__file__), *base.IMPLEMENTATION])
    protocol = {'status': 'frozen_before_same_model_plan_replay', 'created_utc': base.now(),
        'evaluation': str(evaluation), 'runtime_jar': p['runtime_jar'], 'runtime_classes': p['runtime_classes'],
        'input_sha256': inputs, 'implementation_sha256': impl,
        'budgets': {'new_llm_calls': 0, 'new_search_calls': 0, 'slots': len(tasks),
            'replays': sum(r['status'] == 'ready' for r in tasks), 'seconds_per_replay': 15, 'wall_seconds': 600},
        'scope': 'All source slots in the 18 selected full models. Reuse frozen validated native plans; unavailable plans remain unknown. This verifies available plans, not all possible source traces or joint-world preservation.'}
    save(output / 'protocol.json', protocol)
    (output / 'PROTOCOL.sha256').write_text(digest(output / 'protocol.json') + '  protocol.json\n', encoding='utf-8')
    return protocol['budgets']


def execute(root):
    p = base.verify(root)
    if (root / 'execution_progress.json').exists(): raise ValueError('Fresh execution required')
    tasks = base.read(root / 'tasks.json')['tasks']; start = time.monotonic(); rows = []
    for task in tasks:
        row = dict(task)
        remain = p['budgets']['wall_seconds'] - (time.monotonic() - start)
        if task['status'] == 'ready':
            if remain < 1: row['replay'] = {'status': 'not_run_audit_budget'}
            else: row['replay'] = base.replay_checked(Path(p['runtime_jar']), Path(p['runtime_classes']),
                Path(task['domain']), Path(task['problem']), Path(task['plan']), root / 'execution' / task['id'],
                seconds=max(1, min(15, int(remain))))
            row['status'] = base.replay_evidence(row['replay'])
        rows.append(row)
        save(root / 'execution_progress.json', {'completed': len(rows), 'registered': len(tasks)})
    report = {'status': 'complete_same_model_preservation_check', 'rows': rows, 'scope': p['scope'],
        'counts': dict(Counter(r['status'] for r in rows)),
        'by_size': {str(k): dict(Counter(r['status'] for r in rows if r['size'] == k)) for k in (2, 3, 4)},
        'by_group': {g: dict(Counter(r['status'] for r in rows if r['group'] == g)) for g in sorted({r['group'] for r in rows})},
        'elapsed_seconds': time.monotonic() - start,
        'inputs_unchanged': all(digest(Path(path)) == h for path, h in p['input_sha256'].items())}
    save(root / 'report.json', report)
    return {k: v for k, v in report.items() if k not in ('rows', 'by_group')}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['prepare', 'execute']); parser.add_argument('--evaluation', type=Path)
    parser.add_argument('--output', type=Path, required=True); args = parser.parse_args()
    print(json.dumps(prepare(args.evaluation, args.output) if args.mode == 'prepare' else execute(args.output), indent=2))

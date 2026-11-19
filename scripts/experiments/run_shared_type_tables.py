"""Fresh shared-type re-evaluation of the frozen Tables 2--4 registry.

No model requests, world construction, or search occurs during preparation.
Source judgements, groups, facts, goals, and reference traces remain frozen.
"""
import argparse
from collections import Counter, defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import random
import shutil
import subprocess
import sys
import time
import traceback

from rcnc.causal_attribution import recover_branch_provenance
from rcnc.domain_building import digest
from rcnc.glaive_merge import Source, build, map_problem, translate_plan
from rcnc.revised_multistory import select_groups
from rcnc.shared_types import SharedTypes, map_world
from scripts.experiments.run_table4_goal_rerun import invoke

ROOT = Path(os.environ.get('NARRAFUSE_REPO', Path(__file__).resolve().parents[2]))
ARCHIVE = ROOT / 'archive/research-data-v1/data'
OLD = ARCHIVE / 'validation/priority1_union_full_evaluation_2026_11_06_v1'
JAVA = Path(r'C:\Program Files (x86)\HBuilderX\plugins\amazon-corretto\bin\java.exe')
JAR = ARCHIVE / 'validation/priority1_union_full_initialization_capped8_continuation_2026_11_09_v1/runtime/glaive-initialization.jar'


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def write(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix('.tmp')
    tmp.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    tmp.replace(path)


def relocate(path):
    path = Path(path)
    if path.is_file():
        return path.resolve()
    candidate = ARCHIVE / path.relative_to(ROOT / 'data')
    if not candidate.is_file():
        raise FileNotFoundError(candidate)
    return candidate.resolve()


def source(row, world=None):
    return Source(row['id'], relocate(row['domain']),
                  relocate((world or {}).get('problem', row['representative_problem'])),
                  constant_contract=row['constant_contract'], consent_policy=row.get('consent_policy'))


def catalog(sources):
    # Authored semantic senses, never derived from plans or success labels.
    aliases = {'actor': 'character', 'person': 'character', 'human': 'character',
               'humanoid': 'character', 'creature': 'character', 'place': 'location',
               'canmarry': 'marriage_eligible', 'ismagic': 'magical_entity'}
    senses = {
        'human_62959785b3ec220a': {'thing': 'entity'},
        'human_87bbd0acdf4611c5': {'thing': 'entity'},
        'human_4d95b598471c21ee': {'thing': 'attribute'},
        'human_72bec7307b121ea5': {'thing': 'attribute'},
        # This source explicitly models these entities as inhabitable places.
        'human_cf10335d299ae37f': {'creature': 'inhabitable_creature', 'ship': 'inhabitable_ship'},
    }
    maps = {s.id: {t: senses.get(s.id, {}).get(t, 'item' if t == 'thing' else aliases.get(t, t))
                   for t in s.types} for s in sources}
    parents = defaultdict(set)
    for s in sources:
        for child, ps in s.type_parents.items():
            c = maps[s.id][child]
            if c == 'object':
                continue
            for parent in ps:
                p = maps[s.id][parent]
                if p != c:
                    parents[c].add(p)
            parents[c]  # Retain alias-collapsed declarations.
    for name in ('character', 'location', 'item'):
        parents[name].add('entity')
    parents['entity'].add('object')
    # Place specialisations retain their original narrower type.
    for name in ('room', 'house'):
        if name in parents:
            parents[name].add('location')
    for name in parents:
        if not parents[name]:
            parents[name].add('object')
        if len(parents[name]) > 1:
            parents[name].discard('object')
    spec = {
        'version': 1, 'decision_basis': 'authored_assumption',
        'evidence': [
            'Source-only authored ontology for this rerun; not independent semantic gold. Frozen before any benchmark search.',
            'Actor/person/human/humanoid/ordinary creature are aligned to the broad narrative participant type character. This is an explicit coarsening assumption, not a preservation theorem.',
            'Place aligns to location; room and house remain narrower locations. Unaliased role and object kinds retain their named type and all mapped source inheritance edges.',
            'thing senses are separated using source declarations and predicate roles: Batman entity; Arthur attribute (is item attribute); portable-thing sources item.',
            'The inhabitable-creature source declares creature/ship below place; these are distinct from participant creatures and ordinary ships.',
            'Repeated native Glaive type declarations preserve multiple inheritance, including animal as both living and item. No per-object origin guard is introduced.',
            'Same unambiguous role/kind names across these source models are authored correspondences. All mappings and source hashes are available for review; replay success does not validate them.',
        ],
        'source_sha256': {s.id: digest(s.domain_path) for s in sources},
        'types': {t: sorted(ps)[0] if len(ps) == 1 else sorted(ps) for t, ps in sorted(parents.items())},
        'mappings': maps,
    }
    SharedTypes.from_sources(sources, spec)
    return spec


def subset(spec, ids):
    return {**spec, 'mappings': {s: spec['mappings'][s] for s in ids},
            'source_sha256': {s: spec['source_sha256'][s] for s in ids}}


def prepare(output, *, limit=None):
    if output.exists():
        raise ValueError('A fresh output directory is required')
    output.mkdir(parents=True)
    inputs = output / 'inputs'
    inputs.mkdir()
    files = [OLD / f for f in ('sources.json', 'worlds.json', 'selected_groups.json',
                               'repeat_01/compilation_report.json', 'repeat_01/references.json',
                               'repeat_01/original_tasks.json')]
    frozen = {str(p): digest(p) for p in files}
    rows = read(files[0])['sources']
    sources = {r['id']: source(r) for r in rows}
    by_id = {r['id']: r for r in rows}
    worlds = {w['id']: w for w in read(files[1])['worlds']}
    groups = read(files[2])['groups']
    if limit is not None:
        groups = groups[:limit]
    elif len(groups) != 1200:
        raise ValueError('Expected all 1,200 frozen groups')
    prior = {r['group']['id']: r for r in read(files[3])['rows']}
    references = read(files[4])['worlds']
    originals = defaultdict(list)
    for t in read(files[5])['tasks']:
        if t['condition'] == 'full':
            originals[t['group']].append(t)
    spec = catalog(list(sources.values()))
    write(inputs / 'types.json', spec)
    write(inputs / 'groups.json', groups)
    for s in sources.values():
        frozen[str(s.domain_path)] = digest(s.domain_path)
        frozen[str(s.problem_path)] = digest(s.problem_path)
    cached_worlds = {}
    for wid, w in worlds.items():
        cached_worlds[wid] = source(by_id[w['source']], w)
        frozen[str(cached_worlds[wid].problem_path)] = digest(cached_worlds[wid].problem_path)
    tasks, compilation = [], []
    for n, group in enumerate(groups, 1):
        gid = group['id']
        selected = [sources[s] for s in group['sources']]
        path = output / 'groups' / gid
        path.mkdir(parents=True)
        old = prior[gid]
        inp = OLD / 'group_inputs' / (gid + '.json')
        frozen[str(inp)] = digest(inp)
        judgments = read(inp)['judgments']
        write(path / 'frozen_judgments.json', judgments)
        construction = old['construction']
        write(path / 'frozen_construction.json', construction)
        record = {'group': group, 'status': 'compiled', 'construction_status': construction['status']}
        metas = {}
        try:
            types = subset(spec, group['sources'])
            preds, pa = select_groups(selected, judgments, 'predicate')
            variant = build(selected, path / 'predicate_only', groups=preds, type_alignment=types)
            acts, aa = select_groups(selected, judgments, 'action', predicate_maps=variant['predicate_maps'])
            metas['full'] = build(selected, path / 'full', groups=preds + acts,
                                  merge_actions=True, type_alignment=types)
            metas['union'] = build(selected, path / 'union', type_alignment=types)
            write(path / 'alignment_audit.json', {'predicate': pa, 'action': aa})
            for arm, meta in metas.items():
                provenance = recover_branch_provenance(path / arm / 'domain.pddl', meta,
                    path / ('predicate_only' if arm == 'full' else 'union') / 'domain.pddl',
                    variant if arm == 'full' else meta)
                write(path / arm / 'provenance.json', provenance)
        except Exception as exc:
            record.update(status='compilation_failed', reason=type(exc).__name__ + ': ' + str(exc))
        for arm in ('union', 'full'):
            base = {'group': gid, 'cohort': group['cohort'], 'method': group['method'],
                    'size': group['size'], 'sources': group['sources'], 'condition': arm,
                    'domain': str(path / arm / 'domain.pddl'), 'mapping': str(path / arm / 'mapping.json'),
                    'provenance': str(path / arm / 'provenance.json')}
            common_status = 'ready' if record['status'] == 'compiled' else 'compilation_failed'
            task = {**base, 'id': gid + '__composition__' + arm, 'kind': 'composition',
                    'status': common_status, 'problem': str(path / arm / 'composition.pddl')}
            if task['status'] == 'ready':
                if construction['status'] != 'constructed':
                    task['status'] = 'frozen_world_unavailable'
                    task['reason'] = construction['status']
                else:
                    scenario = {k: v for k, v in construction['scenario'].items()
                                if k in {'id', 'objects', 'facts', 'goal', 'intentions'}}
                    try:
                        task['world_receipt'] = map_world(metas[arm], scenario, Path(task['problem']))
                    except Exception as exc:
                        task.update(status='world_type_incompatible', reason=str(exc))
            tasks.append(task)
            for oldtask in originals[gid]:
                wid, sid = oldtask['world'], oldtask['source']
                task = {**base, 'id': gid + '__' + arm + '__' + wid, 'world': wid, 'source': sid,
                        'status': common_status, 'search_anchor': oldtask['search_anchor'],
                        'problem': str(path / arm / 'worlds' / (wid + '.pddl')),
                        'kind': 'original_world', 'reference_status': references[wid]['status']}
                if task['status'] == 'ready':
                    try:
                        world_sources = [cached_worlds[wid] if s.id == sid else s for s in selected]
                        terms = map_problem(world_sources, sid, metas[arm], task['problem'])
                        if references[wid]['status'] == 'available':
                            ref = relocate(references[wid]['source_plan'])
                            if digest(ref) != references[wid]['source_plan_sha256']:
                                raise ValueError('Frozen reference plan hash mismatch')
                            frozen[str(ref)] = digest(ref)
                            task['plan'] = str(path / arm / 'worlds' / (wid + '.plan.pddl'))
                            translate_plan(sid, metas[arm], terms, ref, task['plan'])
                    except Exception as exc:
                        task.update(status='world_mapping_failed', reason=type(exc).__name__ + ': ' + str(exc))
                tasks.append(task)
        compilation.append(record)
        if n % 25 == 0 or n == len(groups):
            write(output / 'preparation_progress.json', {'groups_completed': n, 'registered_groups': len(groups),
                'compilation_status': dict(Counter(r['status'] for r in compilation))})
            print(f'Prepared {n}/{len(groups)} groups', flush=True)
    write(output / 'compilation.json', compilation)
    write(output / 'registry.json', tasks)
    # Copy executable code; subsequent workspace edits cannot alter an active run.
    for folder in ('rcnc', 'scripts'):
        for f in (ROOT / folder).rglob('*.py'):
            target = output / 'code' / f.relative_to(ROOT)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(f, target)
    if digest(JAR) != '18fe40166ef5ea3bddd58395f5e8739232a1cf6a1b8ec808a9c1e37fd5a94041':
        raise ValueError('Unexpected Glaive runtime')
    frozen.update({str(p): digest(p) for p in (JAVA, JAR)})
    frozen.update({str(p): digest(p) for p in output.rglob('*') if p.is_file()})
    counts = {'groups': len(groups), 'composition_per_arm': len(groups),
              'original_worlds_per_arm': len([t for t in tasks if t['kind'] == 'original_world' and t['condition'] == 'full']),
              'goal_queries_per_arm': sum(t.get('search_anchor', False) for t in tasks if t['condition'] == 'full'),
              'reference_replays_per_arm': sum(t.get('reference_status') == 'available' for t in tasks if t['condition'] == 'full')}
    if limit is None and counts != {'groups': 1200, 'composition_per_arm': 1200, 'original_worlds_per_arm': 10528,
                                   'goal_queries_per_arm': 2400, 'reference_replays_per_arm': 2081}:
        raise ValueError('Frozen denominator mismatch: ' + str(counts))
    write(output / 'protocol.json', {
        'version': 1, 'condition': 'fresh_native_shared_types', 'development_preflight': limit is not None,
        'frozen_at': datetime.now(timezone.utc).isoformat(), 'counts': counts,
        'java': str(JAVA), 'jar': str(JAR), 'search_seconds': 60, 'native_replay_seconds': 60,
        'independent_check_seconds': 60, 'attribution_seconds': 60, 'heap_mb': 4096, 'workers': 3,
        'max_interpretations': 4096, 'max_supports': 256, 'shuffle_seed': 20261119,
        'input_sha256': frozen, 'registry': str(output / 'registry.json'),
        'policy': 'Fresh searches only; no automatic continuation. Retain every registered failure. Reuse frozen source judgments and worlds; never pool source facts. Type mapping is an authored assumption, not independently validated semantics.',
        'baseline_scope': 'Union and NarraFuse rerun under the same ontology. Official UniDomain matched physical comparison requires a separately frozen compatibility assessment; no old matched count is transferred to this condition.',
    })
    print(json.dumps({'status': 'prepared', 'counts': counts}), flush=True)


def check(spec):
    for p, h in spec['input_sha256'].items():
        if digest(Path(p)) != h:
            raise ValueError('Frozen input changed: ' + p)


def worker(request, output):
    from rcnc.saved_plan_validation import replay_saved
    task = read(request)
    if task['mode'] == 'physical':
        result = replay_saved(Path(task['domain']), Path(task['problem']), Path(task['plan']),
                              native_axioms=True, quantified_action_effects=True)
    else:
        from rcnc.causal_attribution_axioms import causal_trace_with_axioms
        result = causal_trace_with_axioms(Path(task['domain']), Path(task['problem']), Path(task['plan']),
                read(task['mapping']), provenance=read(task['provenance']), selected_sources=task['sources'],
                max_interpretations=task['max_interpretations'], max_supports=task['max_supports'])
    write(output, result)


def isolated(spec, task, folder, mode):
    req, out = folder / (mode + '_request.json'), folder / (mode + '.json')
    write(req, {**task, 'mode': mode, 'max_interpretations': spec['max_interpretations'], 'max_supports': spec['max_supports']})
    seconds = spec['independent_check_seconds' if mode == 'physical' else 'attribution_seconds']
    cmd = [sys.executable, '-X', 'utf8', '-m', 'scripts.experiments.run_shared_type_tables', 'worker',
           '--request', str(req), '--output', str(out)]
    with (folder / (mode + '.log')).open('xb') as log:
        try:
            p = subprocess.run(cmd, stdout=log, stderr=subprocess.STDOUT, timeout=seconds,
                               creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0))
        except subprocess.TimeoutExpired:
            return {'status': 'wall_time_limit'}
    return read(out) if out.is_file() and p.returncode == 0 else {'status': 'checker_error', 'returncode': p.returncode}


def run_task(spec, task, folder):
    folder.mkdir(parents=True)
    result = {**task, 'dual_pass': False, 'native_pass': False}
    if task['status'] != 'ready':
        write(folder / 'result.json', result)
        return result
    plan = Path(task['plan']) if task['kind'] == 'reference' else folder / 'plan.pddl'
    if task['kind'] != 'reference':
        result['search'] = invoke(spec, task, folder, 'search', plan)
        if result['search']['status'] != 'solved':
            result['status'] = result['search']['status']
            write(folder / 'result.json', result)
            return result
    result['plan'] = str(plan)
    result['plan_sha256'] = digest(plan)
    result['native'] = invoke(spec, task, folder, 'replay', plan)
    n = result['native']
    result['native_pass'] = n['status'] == 'replayed' and n.get('goal') is True and n.get('unexplained_steps') == 0
    # Physical validity is reported independently, even if intentional replay fails.
    p = isolated(spec, {**task, 'plan': str(plan)}, folder, 'physical')
    result['physical'] = {k: p[k] for k in ('status', 'goal', 'steps', 'reason') if k in p}
    result['physical_pass'] = p.get('status') == 'replayed' and p.get('goal') is True
    result['dual_pass'] = result['native_pass'] and result['physical_pass'] and p.get('steps') == n.get('steps')
    result['status'] = 'dual_validated' if result['dual_pass'] else 'validation_failed_or_unknown'
    if task['kind'] == 'composition' and result['dual_pass']:
        result['attribution'] = isolated(spec, {**task, 'plan': str(plan)}, folder, 'attribution')
    if digest(plan) != result['plan_sha256']:
        raise ValueError('Plan changed during replay')
    write(folder / 'result.json', result)
    return result


def summarize(rows):
    summary = {}
    for kind in ('composition', 'reference', 'original_goal'):
        summary[kind] = {}
        for arm in ('union', 'full'):
            rr = [r for r in rows if r['kind'] == kind and r['condition'] == arm]
            summary[kind][arm] = {'completed': len(rr), 'dual_pass': sum(r['dual_pass'] for r in rr),
                'native_pass': sum(r['native_pass'] for r in rr),
                'statuses': dict(Counter(r['status'] for r in rr))}
    return summary


def table_metrics(rows):
    """Every registered row remains in the published denominators."""
    cells = defaultdict(list)
    depths = defaultdict(list)
    for row in rows:
        if row['kind'] == 'composition':
            cells[(row['cohort'], row['method'], row['size'], row['condition'])].append(row)
            depths[(row['size'], row['condition'])].append(row)
    def counts(rr):
        result = {'registered': len(rr), 'dual_validated': sum(r['dual_pass'] for r in rr)}
        for depth in range(2, 6):
            status = Counter()
            for row in rr:
                if row['dual_pass']:
                    profile = row.get('attribution', {}).get('source_count_profile', {})
                    status[profile.get('at_least', {}).get(str(depth), {}).get('status', 'unknown')] += 1
            result['C_at_least_' + str(depth)] = dict(status)
        return result
    return {
        'table_2': [dict(zip(('cohort', 'selection', 'k', 'method'), key), **counts(rr)) for key, rr in sorted(cells.items())],
        'table_3_depth': [dict(zip(('k', 'method'), key), **counts(rr)) for key, rr in sorted(depths.items())],
        'table_4': {k: v for k, v in summarize(rows).items() if k != 'composition'},
        'official_unidomain': 'Separate matched physical compatibility assessment required; historical counts are not current shared-type results.',
    }


def run(output):
    spec = read(output / 'protocol.json')
    protocol_hash = digest(output / 'protocol.json')
    check(spec)
    if digest(output / 'protocol.json') != protocol_hash:
        raise ValueError('Protocol changed during execution')
    # Exclusive marker prevents silently treating a resumed cache as a fresh run.
    with (output / 'started.json').open('x', encoding='utf-8') as f:
        json.dump({'started_at': datetime.now(timezone.utc).isoformat(), 'pid': os.getpid()}, f)
    tasks = []
    for t in read(spec['registry']):
        if t['kind'] == 'composition':
            tasks.append(t)
        else:
            if t['reference_status'] == 'available':
                tasks.append({**t, 'kind': 'reference', 'id': t['id'] + '__reference'})
            if t['search_anchor']:
                tasks.append({**t, 'kind': 'original_goal', 'id': t['id'] + '__goal'})
    pairs = defaultdict(dict)
    for t in tasks:
        pairs[(t['kind'], t['group'], t.get('world'))][t['condition']] = t
    ordered = sorted(pairs.items())
    random.Random(spec['shuffle_seed']).shuffle(ordered)
    rows = []
    def pair_job(index, pair):
        result = []
        for arm in (('union', 'full') if index % 2 == 0 else ('full', 'union')):
            t = pair[arm]
            folder = output / 'runs' / t['kind'] / t['id']
            try:
                result.append(run_task(spec, t, folder))
            except Exception as exc:
                r = {**t, 'status': 'runner_error', 'reason': type(exc).__name__ + ': ' + str(exc),
                     'traceback': traceback.format_exc(), 'dual_pass': False, 'native_pass': False}
                write(folder / 'result.json', r)
                result.append(r)
        return result
    with ThreadPoolExecutor(max_workers=spec['workers']) as pool:
        futures = [pool.submit(pair_job, i, pair) for i, (_, pair) in enumerate(ordered)]
        for future in as_completed(futures):
            rows.extend(future.result())
            done = len(rows)
            if done == 2 or done % 20 == 0 or done == len(tasks):
                progress = {'status': 'running', 'updated_at': datetime.now(timezone.utc).isoformat(),
                            'completed': done, 'registered': len(tasks), 'summary': summarize(rows)}
                write(output / 'progress.json', progress)
                print(json.dumps(progress), flush=True)
    check(spec)
    if len(rows) != len(tasks) or len({r['id'] for r in rows}) != len(tasks):
        raise ValueError('Incomplete registry')
    if digest(output / 'protocol.json') != protocol_hash:
        raise ValueError('Protocol changed during execution')
    report = {'status': 'complete_shared_type_rerun', 'inputs_unchanged': True,
              'protocol_sha256': protocol_hash, 'registered': len(tasks), 'summary': summarize(rows),
              'tables': table_metrics(rows), 'rows': sorted(rows, key=lambda r: r['id'])}
    write(output / 'report.json', report)
    write(output / 'tables_2_3_4.json', report['tables'])
    write(output / 'evidence_index.json', {'reports': {'shared_type_tables': {
        'path': str(output / 'report.json'), 'sha256': digest(output / 'report.json'),
        'terminal_status': report['status'], 'metrics': ['registered', 'summary', 'tables'],
        'scope': 'Fresh native shared-type Union/NarraFuse rerun. Authored ontology. Official UniDomain not included.'}},
        'excluded_pending': {'official_unidomain': 'New shared-type matched physical assessment pending.'}})
    write(output / 'progress.json', {k: v for k, v in report.items() if k != 'rows'})


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('mode', choices=('prepare', 'run', 'worker'))
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--request', type=Path)
    p.add_argument('--limit', type=int)
    a = p.parse_args()
    if a.mode == 'prepare':
        prepare(a.output.resolve(), limit=a.limit)
    elif a.mode == 'run':
        run(a.output.resolve())
    else:
        worker(a.request, a.output)


if __name__ == '__main__':
    main()

"""Fresh three-cohort union/full campaign using an immutable released compiler.

The live checkout supplies only this experiment adapter. Imports of the compiler,
selection features and judgment validation must come from the release's code/.
"""
import argparse
from collections import Counter, defaultdict
from datetime import datetime, timezone
import hashlib
import heapq
from itertools import combinations
import json
from math import comb
from pathlib import Path
import sys

COHORTS = ('story', 'human', 'mixed')
SIZES = (2, 3, 4, 5)
SEED = 'priority1-three-cohort-union-full-20261105-v1'
BASELINE_SHA256 = 'c294d6d2ab1a992915abe041628e7d33e34e28e318de3448be7ba42788c3ed98'


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def write(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x', encoding='utf-8', newline='\n') as stream:
        json.dump(value, stream, ensure_ascii=False, indent=2)
        stream.write('\n')


def bind_release(release):
    release = Path(release).resolve()
    code = release / 'code'
    for name, module in list(sys.modules.items()):
        if name.split('.')[0] in ('rcnc', 'unidomain', 'scripts', 'archive'):
            filename = getattr(module, '__file__', None)
            if filename and not Path(filename).resolve().is_relative_to(code):
                raise ValueError('Live implementation already imported: ' + name)
    sys.dont_write_bytecode = True
    sys.path.insert(0, str(code))
    from rcnc import causal_path_selection as selection
    from rcnc.glaive_merge import Source
    return selection, Source


def verify_release(release):
    if digest(release / 'manifest.json') != BASELINE_SHA256:
        raise ValueError('Unexpected baseline manifest')
    manifest = read(release / 'manifest.json')
    for name, checksum in manifest['files'].items():
        if digest(release / name) != checksum:
            raise ValueError('Frozen baseline changed: ' + name)
    return {'manifest_sha256': BASELINE_SHA256, 'verified_files': len(manifest['files'])}


def load_sources(release, Source):
    catalog = read(release / 'source_catalog.json')
    by_id = {r['id']: r for r in catalog['rows']}
    sources, rows, worlds = {}, [], []
    models = read(release / 'model_catalog.json')['models']
    for model in sorted(models, key=lambda r: r['id']):
        if model['pool'] not in ('human', 'learned_revised'):
            continue
        admitted = [by_id[i] for i in sorted(model['admitted_pair_ids'])]
        contracts = {json.dumps([r['constant_contract'], r.get('consent_policy')], sort_keys=True)
                     for r in admitted}
        if len(contracts) != 1:
            raise ValueError('Canonical model has different interpretation contracts')
        first = admitted[0]
        sid = ('human_' + model['canonical_domain_sha256'][:16] if model['pool'] == 'human'
               else first['story_id'])
        row = {'id': sid, 'pool': 'human' if model['pool'] == 'human' else 'story',
               'baseline_model_id': model['id'], 'baseline_pair_ids': model['admitted_pair_ids'],
               'canonical_domain_sha256': model['canonical_domain_sha256'],
               'domain': str(release / first['source_inputs']['domain']['path']),
               'representative_problem': str(release / first['source_inputs']['problem']['path']),
               'constant_contract': first['constant_contract'],
               'consent_policy': first.get('consent_policy'), 'world_ids': []}
        for original in admitted:
            if not original['single_domain_pass']:
                raise ValueError('Unadmitted model in admitted catalog')
            wid = original['id']
            row['world_ids'].append(wid)
            worlds.append({'id': wid, 'source': sid, 'pool': row['pool'],
                'domain': str(release / original['source_inputs']['domain']['path']),
                'problem': str(release / original['source_inputs']['problem']['path']),
                'raw': original['raw'], 'constant_contract': original['constant_contract'],
                'consent_policy': original.get('consent_policy'),
                'explicit_initial_state': True, 'source_problem_facts_pooled': False})
        sources[sid] = Source(sid, Path(row['domain']), Path(row['representative_problem']),
                             constant_contract=row['constant_contract'], consent_policy=row['consent_policy'])
        rows.append(row)
    if Counter(r['pool'] for r in rows) != {'story': 127, 'human': 17} or len(worlds) != 214:
        raise ValueError('Changed frozen pool denominator')
    return sources, rows, worlds


def mixed_size(human, story, k):
    return sum(comb(len(human), h) * comb(len(story), k-h)
               for h in range(1, k) if h <= len(human) and k-h <= len(story))


def mixed_unrank(human, story, k, rank, unrank):
    """Bijection over all mixed unordered subsets; composition is not balanced."""
    human, story = sorted(human), sorted(story)
    if not 0 <= rank < mixed_size(human, story, k):
        raise ValueError('Mixed combination rank out of range')
    for h in range(1, k):
        if h > len(human) or k-h > len(story):
            continue
        right = comb(len(story), k-h)
        block = comb(len(human), h) * right
        if rank < block:
            return tuple(sorted((*unrank(human, h, rank // right),
                                 *unrank(story, k-h, rank % right))))
        rank -= block
    raise AssertionError('Unreachable rank')


def mixed_random(human, story, k, count, seed, selection):
    total = mixed_size(human, story, k)
    if total < count:
        raise ValueError('Insufficient mixed combinations')
    rng, chosen = selection.HashRandom(seed), set()
    for j in range(total-count, total):
        draw = rng.below(j+1)
        chosen.add(j if draw in chosen else draw)
    return [(r, mixed_unrank(human, story, k, r, selection.unrank_combination))
            for r in sorted(chosen)]


def choose(rows, pairs, paths, selection, count=50):
    pools = {r['id']: r['pool'] for r in rows}
    by_pair = {tuple(p['sources']): p for p in pairs}
    by_path = {tuple(p['sources']): p for p in paths['records']}
    groups, cells = [], []
    human = sorted(s for s in pools if pools[s] == 'human')
    story = sorted(s for s in pools if pools[s] == 'story')
    for cohort in COHORTS:
        ids = human if cohort == 'human' else story if cohort == 'story' else sorted(pools)
        eligible = lambda members: (len({pools[s] for s in members}) == 2 if cohort == 'mixed'
                                    else all(pools[s] == cohort for s in members))
        for k in SIZES:
            seed = f'{SEED}|{cohort}|k={k}'
            random = (mixed_random(human, story, k, count, seed, selection) if cohort == 'mixed'
                      else selection.random_groups(ids, k, count, seed))
            complete = [key for key in by_path if len(key) == k and eligible(key)]
            universe = complete if len(complete) >= count else (
                m for m in combinations(ids, k) if eligible(m))
            ranked = heapq.nsmallest(count,
                ((m, selection.describe_group(m, by_pair, by_path)) for m in universe),
                key=lambda x: selection.ranking_key(*x))
            for method, selected in (
                ('random', [(m, selection.describe_group(m, by_pair, by_path), rank) for rank, m in random]),
                ('causal_link', [(m, d, None) for m, d in ranked])):
                if len(selected) != count:
                    raise ValueError('Incomplete selection cell')
                cell_rows = []
                for i, (members, description, rank) in enumerate(selected, 1):
                    row = {'id': f'{cohort}__{method}__k{k:02d}__{i:03d}', 'cohort': cohort,
                           'method': method, 'size': k, 'selection_index': i, 'sources': list(members),
                           'combination_rank': rank, 'path_features': description,
                           'source_pool_counts': dict(Counter(pools[s] for s in members)),
                           'semantic_relation_label': None}
                    groups.append(row)
                    cell_rows.append(row)
                cells.append({'cohort': cohort, 'method': method, 'k': k, 'groups': len(cell_rows),
                    'universe_combinations': mixed_size(human, story, k) if cohort == 'mixed' else comb(len(ids), k),
                    'full_k_path_groups_in_universe': len(complete),
                    'selected_full_k_path_groups': sum(r['path_features']['full_k_path_candidate'] for r in cell_rows),
                    'source_frequencies': dict(sorted(Counter(s for r in cell_rows for s in r['sources']).items())),
                    'human_sources_per_group': dict(Counter(r['source_pool_counts'].get('human', 0) for r in cell_rows))})
            print('selected', cohort, k, 'full_path_universe', len(complete), flush=True)
    return groups, cells


def select(release, root):
    if root.exists():
        raise ValueError('Fresh versioned output required')
    verified = verify_release(release)
    selection, Source = bind_release(release)
    root.mkdir(parents=True)
    policy = {'status': 'registered_before_selection', 'release': str(release), **verified,
        'created_utc': datetime.now(timezone.utc).isoformat(), 'seed': SEED,
        'cohorts': list(COHORTS), 'conditions': ['union', 'full'], 'sizes': list(SIZES),
        'methods': ['random', 'causal_link'], 'groups_per_cell': 50, 'registered_groups': 1200,
        'registered_group_conditions': 2400, 'path_limits': {'max_sources': 5, 'max_local_hops': 2,
                                                           'max_visits': 20_000_000},
        'candidate_caps_per_pair': {'predicate': 8, 'action': 4},
        'random_policy': 'Uniform unordered subsets without replacement per cell; mixed conditioned on at least one of each pool, without a composition quota.',
        'causal_policy': 'Frozen action-continuous path ranking; no initial states, goals, model judgments or planning outcomes used.',
        'ranking_fields': list(selection.RANK_FIELDS),
        'deduplication': 'Frozen normalized syntax within pool, not independent semantic families.',
        'world_policy': 'All 214 admitted original problems kept separately; full 512-row intake retained in release.',
        'failure_policy': 'Keep all selected groups and failed or unsupported execution rows; no replacements.',
        'no_history_resume': True, 'model_calls': 0, 'planner_calls': 0,
        'adapter_sha256': digest(__file__)}
    write(root / 'selection_policy.json', policy)
    sources, rows, worlds = load_sources(release, Source)
    write(root / 'sources.json', {'sources': rows})
    write(root / 'worlds.json', {'worlds': worlds})
    print('loaded', len(sources), 'models', len(worlds), 'separate worlds', flush=True)
    pairs, excluded = selection.census_pairs(sources)
    pairs = json.loads(json.dumps(pairs))
    write(root / 'pair_census.json', {'pairs': pairs, 'excluded_scoring_actions': excluded})
    print('pair census', len(pairs), flush=True)
    graph = selection.action_graph(sources, pairs)
    write(root / 'action_graph.json', graph)
    print('graph', len(graph['edges']), 'edges; enumerating paths', flush=True)
    try:
        paths = selection.path_inventory(graph, **policy['path_limits'])
    except ValueError as exc:
        write(root / 'selection_failure.json', {'status': 'incomplete_no_frozen_selection', 'reason': str(exc)})
        raise
    write(root / 'path_inventory.json', paths)
    print('paths', paths['visited_prefixes'], 'prefixes', len(paths['records']), 'source sets', flush=True)
    groups, cells = choose(rows, pairs, paths, selection)
    write(root / 'selected_groups.json', {'groups': groups})
    memberships = defaultdict(list)
    for group in groups:
        for pair in combinations(group['sources'], 2):
            memberships[pair].append(group['id'])
    candidates, usage = [], {}
    for pair in pairs:
        key = tuple(pair['sources'])
        if key in memberships:
            candidates.extend(pair['candidates'])
            for c in pair['candidates']:
                usage[c['id']] = memberships[key]
    candidates.sort(key=lambda c: hashlib.sha256((SEED + '|request|' + c['id']).encode()).hexdigest())
    if len({c['id'] for c in candidates}) != len(candidates):
        raise ValueError('Duplicate candidate identity')
    write(root / 'candidates.json', {'candidates': candidates})
    write(root / 'candidate_usage.json', {'groups_by_candidate': usage})
    overlaps = [{'cohort': cohort, 'k': k, 'same_group_in_both_methods': len(
        {tuple(g['sources']) for g in groups if g['cohort'] == cohort and g['size'] == k and g['method'] == 'random'} &
        {tuple(g['sources']) for g in groups if g['cohort'] == cohort and g['size'] == k and g['method'] == 'causal_link'})}
        for cohort in COHORTS for k in SIZES]
    summary = {'status': 'selection_complete_model_calls_not_started', 'groups': len(groups),
        'group_conditions': len(groups)*2, 'sources': len(sources), 'original_worlds': len(worlds),
        'unique_source_pairs_for_judgment': len(memberships), 'model_requests': len(candidates),
        'candidate_kinds': dict(Counter(c['kind'] for c in candidates)),
        'cells': cells, 'method_overlap': overlaps, 'independent_semantic_labels': 0}
    write(root / 'selection_report.json', summary)
    hashes = {p.relative_to(root).as_posix(): digest(p) for p in sorted(root.rglob('*')) if p.is_file()}
    write(root / 'freeze.json', {'status': 'frozen_selection', 'release': str(release),
                              **verified, 'artifact_sha256': hashes})
    (root / 'FREEZE.sha256').write_text(digest(root / 'freeze.json') + '\n', encoding='utf-8')
    print(json.dumps({k: v for k, v in summary.items() if k not in ('cells', 'method_overlap')}, indent=2), flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['select'])
    parser.add_argument('--release', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    select(args.release.resolve(), args.output.resolve())


if __name__ == '__main__':
    main()

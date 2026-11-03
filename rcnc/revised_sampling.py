"""Outcome-blind balanced nested sampling and descriptive source-only features.

The sampler receives IDs, not domains, model judgments, plans, or feature scores.
Its constrained randomized design is not IID uniform subset sampling.
"""
from collections import Counter
from hashlib import sha256
from itertools import combinations
from math import comb

from .glaive_merge import action_fields
from .pddl import typed_symbols


def rank(seed, *values):
    return sha256(('|'.join([seed, *map(str, values)])).encode('utf-8')).hexdigest()


def balanced_chains(source_ids, *, chain_count=100, max_size=10, seed,
                    max_attempts=256, pair_cap=12):
    ids=sorted(source_ids)
    if len(ids)!=len(set(ids)):raise ValueError('Duplicate source IDs')
    if not 2<=max_size<=len(ids):raise ValueError('Invalid maximum group size')
    if not 1<=chain_count<=comb(len(ids),2):raise ValueError('Too many unique two-source prefixes')
    if pair_cap<1:raise ValueError('Invalid pair recurrence cap')
    chains=[[] for _ in range(chain_count)];counts=Counter();trace=[]
    for column in range(max_size):
        k=column+1;low,extra=divmod(chain_count*k,len(ids))
        accepted=None
        for attempt in range(max_attempts):
            extras=set(sorted(ids,key=lambda s:rank(seed,'quota',k,attempt,s))[:extra])
            target={s:low+int(s in extras) for s in ids}
            capacity={s:target[s]-counts[s] for s in ids}
            if min(capacity.values())<0:continue
            slots=[(s,i) for s in ids for i in range(capacity[s])]
            if len(slots)!=chain_count:raise AssertionError('Incorrect assignment capacity')
            options={row:sorted((j for j,(s,_) in enumerate(slots) if s not in chains[row]),
                key=lambda j:rank(seed,'edge',k,attempt,row,*slots[j])) for row in range(chain_count)}
            occupied={}
            def match(row,visited):
                for slot in options[row]:
                    if slot in visited:continue
                    visited.add(slot)
                    if slot not in occupied or match(occupied[slot],visited):
                        occupied[slot]=row;return True
                return False
            order=sorted(range(chain_count),key=lambda row:rank(seed,'row',k,attempt,row))
            if not all(match(row,set()) for row in order):continue
            assigned={row:slots[slot][0] for slot,row in occupied.items()}
            trial=[chain+[assigned[row]] for row,chain in enumerate(chains)]
            sets=[frozenset(c) for c in trial]
            if k>=2 and len(set(sets))!=chain_count:continue
            pair_counts=Counter(pair for c in trial for pair in combinations(sorted(c),2))
            if pair_counts and max(pair_counts.values())>pair_cap:continue
            accepted=trial;break
        if accepted is None:
            raise ValueError('No feasible frozen sampling assignment at size '+str(k))
        chains=accepted;counts=Counter(s for c in chains for s in c)
        trace.append({'size':k,'accepted_attempt_index':attempt,'source_min':min(counts.get(s,0) for s in ids),
            'source_max':max(counts.get(s,0) for s in ids),'maximum_pair_recurrence':max(pair_counts.values(),default=0)})
    return [{'id':'chain_'+str(i+1).zfill(3),'sources':c,'anchor_sources':c[:2]} for i,c in enumerate(chains)],trace


def materialize_groups(chains, *, min_size=2, max_size=10):
    rows=[];seen=set()
    for chain in chains:
        for k in range(min_size,max_size+1):
            prefix=chain['sources'][:k]
            if len(prefix)!=k or len(set(prefix))!=k:raise ValueError('Malformed source sequence')
            key=tuple(sorted(prefix))
            if key in seen:raise ValueError('Duplicate unordered group')
            seen.add(key)
            rows.append({'id':'k'+str(k).zfill(2)+'_'+rank('group-v1',*key)[:16],
                'chain_id':chain['id'],'size':k,'sources':list(key),'prefix_order':prefix,
                'anchor_sources':chain['sources'][:2],'sampling_stratum':'balanced_random',
                'semantic_relation_label':None})
    return rows


def pair_features(pair, sources):
    left,right=[sources[s] for s in pair['sources']]
    shared_predicates=sorted(set(left.domain.predicates)&set(right.domain.predicates))
    shared_actions=sorted(set(left.domain.actions)&set(right.domain.actions))
    arity_mismatch=[]
    for name in shared_predicates:
        if left.domain.predicates[name].arity!=right.domain.predicates[name].arity:arity_mismatch.append(name)
    action_parameter_mismatch=[];action_effect_text_difference=[]
    for name in shared_actions:
        a,b=[action_fields(s.domain.actions[name]) for s in (left,right)]
        if len(typed_symbols(a[':parameters']))!=len(typed_symbols(b[':parameters'])):action_parameter_mismatch.append(name)
        if a[':effect']!=b[':effect']:action_effect_text_difference.append(name)
    return {'id':pair['id'],'sources':pair['sources'],
        'same_arity_predicate_pairs':pair['predicate_opportunities'],
        'coarse_action_shape_pairs':pair['action_opportunities'],
        'retained_candidate_count':len(pair['candidates']),
        'same_name_predicates':shared_predicates,'same_name_predicate_arity_mismatches':arity_mismatch,
        'same_name_actions':shared_actions,'same_name_action_parameter_count_mismatches':action_parameter_mismatch,
        'same_name_action_raw_effect_ast_differences':action_effect_text_difference,
        'semantic_relation_label':None}


def validate_sampling(chains,groups,source_ids,*,chain_count,max_size,pair_cap):
    ids=set(source_ids);by_chain={c['id']:c for c in chains}
    if len(chains)!=chain_count or len(by_chain)!=chain_count:raise ValueError('Chain denominator mismatch')
    for c in chains:
        if len(c['sources'])!=max_size or len(set(c['sources']))!=max_size or not set(c['sources'])<=ids:
            raise ValueError('Invalid chain membership')
        if c['anchor_sources']!=c['sources'][:2]:raise ValueError('Changed anchors')
    if len(groups)!=chain_count*(max_size-1):raise ValueError('Group denominator mismatch')
    seen=set();seen_chain_sizes=set();seen_group_ids=set();summary=[]
    for row in groups:
        c=by_chain[row['chain_id']];k=row['size'];key=tuple(sorted(row['sources']))
        if not 2<=k<=max_size or len(key)!=k or len(set(key))!=k:raise ValueError('Invalid group size')
        if key in seen or row['id'] in seen_group_ids:raise ValueError('Duplicate group')
        seen.add(key);seen_group_ids.add(row['id'])
        if (row['chain_id'],k) in seen_chain_sizes:raise ValueError('Duplicate chain-size cell')
        seen_chain_sizes.add((row['chain_id'],k))
        if row['prefix_order']!=c['sources'][:k] or list(key)!=sorted(c['sources'][:k]):raise ValueError('Broken nesting')
        if row['anchor_sources']!=c['sources'][:2]:raise ValueError('Changed group anchors')
        if row['sampling_stratum']!='balanced_random' or row['semantic_relation_label'] is not None:
            raise ValueError('Unexpected semantic label or sampling stratum')
    for k in range(2,max_size+1):
        rows=[g for g in groups if g['size']==k]
        if len(rows)!=chain_count:raise ValueError('Per-size denominator mismatch')
        counts=Counter(s for g in rows for s in g['sources']);lo=chain_count*k//len(ids);hi=-(-chain_count*k//len(ids))
        if any(not lo<=counts.get(s,0)<=hi for s in ids):raise ValueError('Unbalanced source coverage')
        pairs=Counter(p for g in rows for p in combinations(g['sources'],2))
        if max(pairs.values(),default=0)>pair_cap:raise ValueError('Excessive pair recurrence')
        summary.append({'size':k,'groups':len(rows),'unique_sources':len(counts),
            'source_frequency_min':min(counts.get(s,0) for s in ids),'source_frequency_max':max(counts.get(s,0) for s in ids),
            'unique_source_pairs':len(pairs),'maximum_pair_recurrence':max(pairs.values(),default=0),
            'source_frequencies':dict(sorted(counts.items()))})
    return summary

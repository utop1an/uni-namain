"""Conservative multi-source consensus over frozen pair judgments.

No transitive semantic closure: every pair in a cluster must be accepted, and
all role maps and semantic cards must agree. Selection is deterministic.
"""
import copy
from hashlib import sha256
from itertools import combinations

from .glaive_merge import accepted,action_fields,group_kind,rewrite,rename_vars,signed_effects
from .pddl import typed_symbols


def _consensus(refs,edges,kind):
    anchor=refs[0];first=edges[tuple(sorted(refs[:2]))]
    cards={m[kind]:m for m in first['members']};arity=len(cards[anchor]['order'])
    orders={anchor:list(range(arity))};all_cards={r:[] for r in refs}
    def mapping(group,left,right):
        ms={m[kind]:m for m in group['members']}
        return dict(zip(ms[left]['order'],ms[right]['order']))
    for ref in refs[1:]:
        m=mapping(edges[tuple(sorted((anchor,ref)))],anchor,ref)
        orders[ref]=[m[i] for i in range(arity)]
    pair_ids=[]
    for left,right in combinations(refs,2):
        edge=edges[left,right];pair_ids.append(edge['id']);m=mapping(edge,left,right)
        if any(m[orders[left][i]]!=orders[right][i] for i in range(arity)):
            raise ValueError('inconsistent_role_cycle')
        for member in edge['members']:all_cards[member[kind]].append(member['semantics'])
    signatures={(s['concept'],s.get('scope'),tuple(s['roles'][j] for j in orders[ref]))
        for ref in refs for s in all_cards[ref]}
    if len(signatures)!=1:raise ValueError('inconsistent_pairwise_concept_scope_or_roles')
    confidence=min(s['confidence'] for cards in all_cards.values() for s in cards)
    members=[]
    for ref in refs:
        sem=copy.deepcopy(all_cards[ref][0]);sem['confidence']=confidence
        sem['evidence']=[e for card in all_cards[ref] for e in card['evidence']]
        sem['judgment_origin']='complete_pairwise_consensus';sem['independent_label']=False
        members.append({kind:ref,'order':orders[ref],'semantics':sem})
    gid=kind[0]+'_consensus_'+sha256('|'.join(refs).encode('utf-8')).hexdigest()[:16]
    return {'id':gid,'members':members,'model_judgment':{'decision':'compatible',
        'rationale':'All pair judgments, roles, concepts and scopes agree; no semantic transitive closure.'},
        'pair_judgment_ids':sorted(pair_ids),'minimum_confidence':confidence,
        'evidence':'Consensus of automatic judgments, not independent semantic labels'}


def physical_action_check(group,sources,predicate_maps):
    effects=[];agents=[]
    for member in group['members']:
        sid,name=member['action'].split(':');s=sources[sid];fields=action_fields(s.domain.actions[name])
        variables=list(typed_symbols(fields[':parameters']));vm={variables[j]:'?m'+str(i) for i,j in enumerate(member['order'])}
        effects.append(signed_effects(rename_vars(rewrite(fields[':effect'],s,predicate_maps[sid],s.term_map),vm)))
        agents.append(set(rename_vars([s.term_map.get(a,a) for a in fields[':agents']],vm)))
    if any(e!=effects[0] for e in effects):raise ValueError('different_mapped_signed_effects')
    if any(a!=agents[0] for a in agents):raise ValueError('different_acting_roles')


def select_groups(sources,pair_groups,kind,*,threshold=.9,predicate_maps=None,max_cliques=50000):
    sources={s.id:s for s in sources};edges={};adj={};rejected_pairs=[]
    for group in sorted(pair_groups,key=lambda g:g['id']):
        if group_kind(group)!=kind or len(group['members'])!=2:continue
        refs=tuple(sorted(m[kind] for m in group['members']))
        if any(r.split(':')[0] not in sources for r in refs):continue
        if refs[0].split(':')[0]==refs[1].split(':')[0]:continue
        if not accepted(group,kind,sources,threshold):
            rejected_pairs.append(group['id']);continue
        if refs in edges:raise ValueError('Duplicate pair judgment')
        edges[refs]=group
        for left,right in (refs,refs[::-1]):adj.setdefault(left,set()).add(right)
    options=[];checks=[];enumerated=0
    def visit(prefix,candidates):
        nonlocal enumerated
        for pos,ref in enumerate(candidates):
            if ref.split(':')[0] in {r.split(':')[0] for r in prefix}:continue
            refs=prefix+[ref]
            if len(refs)>=2:
                enumerated+=1
                if enumerated>max_cliques:raise ValueError('consensus_clique_budget_exhausted')
                try:
                    group=_consensus(refs,edges,kind)
                    if kind=='action':
                        if predicate_maps is None:raise ValueError('Missing predicate mapping')
                        physical_action_check(group,sources,predicate_maps)
                    options.append(group);checks.append({'references':refs,'status':'eligible','group':group['id']})
                except (ValueError,KeyError) as exc:
                    checks.append({'references':refs,'status':'retained_separate','reason':str(exc)})
            visit(refs,[r for r in candidates[pos+1:] if r in adj[ref]])
    visit([],sorted(adj))
    options.sort(key=lambda g:(-len(g['members']),-g['minimum_confidence'],tuple(m[kind] for m in g['members'])))
    selected=[];occupied=set();blocked=[]
    for group in options:
        refs={m[kind] for m in group['members']}
        if refs&occupied:blocked.append(group['id']);continue
        selected.append(group);occupied.update(refs)
    return selected,{'kind':kind,'positive_pair_judgments':len(edges),'nonaccepted_pair_ids':rejected_pairs,
        'enumerated_cliques':enumerated,'checks':checks,'selected_groups':[g['id'] for g in selected],
        'covered_or_overlapping_group_ids':blocked,'semantic_gold_labels':0}

"""Expand k=4 retrieval beyond the previous top 100 using frozen judgments."""
from collections import defaultdict, Counter
from itertools import product
from pathlib import Path
import sys

from rcnc.domain_building import digest, save
from rcnc.revised_followup import authored_problem
from rcnc.revised_multistory import select_groups
from scripts.experiments import run_causal_chains as chain
from scripts.experiments import run_revised_multistory as base


def prepare(parent, output):
    p = chain.verify_parent(parent)
    import importlib.util
    spec = importlib.util.spec_from_file_location('rcnc.archived_chain_merge',
        parent/'implementation/rcnc/glaive_merge.py')
    archived = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = archived
    spec.loader.exec_module(archived)
    sources = {row['id']: archived.Source(row['id'],
        Path(row['files']['revised-domain.pddl']['frozen_path']),
        Path(row['files']['revised-problem.pddl']['frozen_path'])) for row in p['source_rows']}
    profiles, excluded = chain.profiles_for(sources)
    producers, consumers = defaultdict(set), defaultdict(set)
    for sid, actions in profiles.items():
        for name, profile in list(actions.items()):
            if any(atom[0] not in sources[sid].domain.predicates
                   for field in ('effects','preconditions') for _,atom in profile[field]):
                del actions[name]
                continue
            for field, index in [('effects', producers), ('preconditions', consumers)]:
                for positive, atom in profile[field]:
                    if positive:
                        index[sid+':'+atom[0]].add((sid,name))
    raw_path = parent/'repeat_01/judgments/groups.json'
    receipt = base.read(parent/'repeat_01/compilation.json')
    if digest(raw_path) != receipt['groups_sha256']:
        raise ValueError('Changed judgment groups')
    raw = base.read(raw_path)['groups']
    adj = defaultdict(set)
    def connect(left, right):
        for a,b in product(producers[left], consumers[right]):
            if a != b:
                adj[a].add(b)
    for ref in sorted(producers.keys() | consumers.keys()):
        connect(ref,ref)
    for group in raw:
        if archived.group_kind(group) == 'predicate' and archived.accepted(group, 'predicate', sources, .9):
            a,b = (m['predicate'] for m in group['members'])
            connect(a,b)
            connect(b,a)
    previous = {tuple(sorted(g['sources'])) for g in base.read(parent/'selected_groups.json')['groups'] if g['size']==4}
    candidates = Counter()
    def walk(nodes):
        ids = {n[0] for n in nodes}
        if len(ids) == 4:
            key = tuple(sorted(ids))
            if key not in previous:
                candidates[key] += 1
            return
        if len(nodes) == 6:
            return
        for n in sorted(adj.get(nodes[-1], ())):
            if n not in nodes and (n[0] == nodes[-1][0] or n[0] not in ids):
                walk(nodes+[n])
    for n in sorted(adj):
        walk([n])
    output.mkdir(parents=True)
    tasks, census, inputs = [], [], {str(raw_path): digest(raw_path)}
    for i, ids in enumerate(sorted(candidates, key=lambda k: (-candidates[k],k)), 1):
        gid = f'expanded_k04_{i:03d}'
        selected = [sources[s] for s in ids]
        pred,_ = select_groups(selected,raw,'predicate',threshold=.9)
        folder = output/'models'/gid
        meta = archived.build(selected,folder/'predicate_only',groups=pred)
        chosen = None
        count = 0
        for nodes, links in chain.routes(ids, profiles, meta['predicate_maps']):
            count += 1
            if chosen is None:
                for world, handoffs in chain.worlds(gid,nodes,links,sources,profiles,meta['predicate_maps']):
                    chosen = (nodes,world,handoffs)
                    break
        census.append({'id':gid,'k':4,'sources':ids,'retrieval_routes':candidates[ids],
                       'schema_routes':count,'selected':chosen is not None})
        if chosen is None:
            continue
        nodes, scenario, handoffs = chosen
        act,_ = select_groups(selected,raw,'action',threshold=.9,predicate_maps=meta['predicate_maps'])
        full = archived.build(selected,folder/'full',groups=pred+act,merge_actions=True)
        if full['predicate_maps'] != meta['predicate_maps']:
            raise ValueError('Predicate map differs across conditions')
        archived.build(selected,folder/'union')
        for c in ('union','predicate_only','full','separate_identity',*('without_'+s for s in ids)):
            model = folder/(c if c in ('union','predicate_only','full') else 'predicate_only')
            d,m = model/'domain.pddl',model/'mapping.json'
            problem = output/'problems'/gid/(c+'.pddl')
            problem.parent.mkdir(parents=True,exist_ok=True)
            authored_problem(selected,base.read(m),scenario,problem,
                active_sources=[s for s in ids if c!='without_'+s],separate_identity=c=='separate_identity')
            for f in (d,m,problem):
                inputs[str(f)] = digest(f)
            tasks.append({'id':gid+'__'+c,'group':gid,'k':4,'sources':ids,'nodes':nodes,
                          'handoffs':handoffs,'condition':c,'domain':str(d),'mapping':str(m),'problem':str(problem)})
    inputs[str(Path(__file__).resolve())] = digest(Path(__file__))
    save(output/'protocol.json', {'status':'frozen_before_search','parent':str(parent),
        'parent_sha256':digest(parent/'protocol.json'),'implementation_sha256':digest(Path(chain.__file__)),
        'input_sha256':inputs,'tasks':tasks,'census':census,'excluded_profiles':excluded,
        'selection':'Deterministic retrieval by count of routes over previously accepted pair judgments, then full consensus compilation and grounded witness check. Excludes previous 100 k=4 groups.',
        'seconds_per_search_and_replay':15,'attempts':1,'new_model_calls':0})
    print('Candidate groups',len(census),'eligible',sum(r['selected'] for r in census),'planner slots',len(tasks))


if __name__ == '__main__':
    prepare(Path(sys.argv[1]).resolve(),Path(sys.argv[2]).resolve())

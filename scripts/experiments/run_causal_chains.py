"""Single-pass k-source chain diagnostics on frozen There and Back Again models."""
from collections import Counter, defaultdict
from itertools import product
import argparse
from pathlib import Path

from rcnc.domain_building import digest, save
from rcnc.glaive_runtime import invoke
from rcnc.pddl import is_type_compatible
from rcnc.revised_followup import authored_problem
from scripts.audit.eval_revised_composition import causal_trace, profiles_for
from scripts.experiments import run_revised_multistory as base


def routes(ids, profiles, mapping):
    adds, needs, edges = defaultdict(list), defaultdict(list), defaultdict(list)
    for sid in ids:
        for name, profile in sorted(profiles[sid].items()):
            for key, index in [('effects', adds), ('preconditions', needs)]:
                for i, (positive, atom) in enumerate(profile[key]):
                    pred, order = mapping[sid][atom[0]]
                    if positive:
                        index[pred].append(((sid, name), i, [atom[1+j] for j in order]))
    for pred in sorted(adds.keys() & needs.keys()):
        for (a, i, left), (b, j, right) in product(adds[pred], needs[pred]):
            if a != b and (a[0] == b[0] or pred.startswith('shared_')):
                edges[a].append((b, i, j, list(zip(left, right))))

    def walk(nodes, links):
        if len({node[0] for node in nodes}) == len(ids):
            yield nodes, links
            return
        if len(nodes) == len(ids) + 2:
            return
        for edge in sorted(edges.get(nodes[-1], [])):
            if edge[0] not in nodes and (edge[0][0] == nodes[-1][0] or edge[0][0] not in {node[0] for node in nodes}):
                yield from walk(nodes + [edge[0]], links + [edge])

    for start in sorted(edges):
        yield from walk([start], [])


def worlds(gid, nodes, links, sources, profiles, mapping):
    actions = [profiles[s][a] for s, a in nodes]
    parent = {(i, v): (i, v) for i, p in enumerate(actions) for v in p['parameters']}

    def find(key):
        while parent[key] != key:
            key = parent[key]
        return key

    for i, (_, _, _, bindings) in enumerate(links):
        for a, b in bindings:
            parent[find((i+1, b))] = find((i, a))
    names, objects, terms = {}, {}, {}
    for i, var in sorted(parent):
        root = find((i, var))
        obj = names.setdefault(root, 'r' + str(len(names)))
        sid = nodes[i][0]
        typ = actions[i]['parameters'][var]
        assigned = objects.setdefault(obj, {})
        old = assigned.get(sid, typ)
        types = sources[sid].domain.types
        if is_type_compatible(typ, old, types):
            assigned[sid] = typ
        elif is_type_compatible(old, typ, types):
            assigned[sid] = old
        else:
            return
        terms[i, var] = obj

    def grounded(i, atom):
        return nodes[i][0], [atom[0], *(terms[i, v] for v in atom[1:])]

    def canonical(fact):
        sid, atom = fact
        pred, order = mapping[sid][atom[0]]
        return (pred, *(atom[1+j] for j in order))

    pres = [[(sign, grounded(i, atom)) for sign, atom in p['preconditions']] for i,p in enumerate(actions)]
    effects = [[(sign, grounded(i, atom)) for sign, atom in p['effects']] for i,p in enumerate(actions)]
    handoffs = [canonical(effects[i][edge[1]][1]) for i,edge in enumerate(links)]
    facts, modified, state = {}, set(), set()
    for i, (pre, eff) in enumerate(zip(pres, effects)):
        for sign, fact in pre:
            key = canonical(fact)
            if sign and key not in state and key not in modified and key not in handoffs:
                facts[key] = fact
                state.add(key)
        for sign, fact in eff:
            key = canonical(fact)
            modified.add(key)
            if sign:
                state.add(key)
            else:
                state.discard(key)

    # Verify the complete grounded witness with all initial facts present,
    # including negative requirements and exact most-recent fact producers.
    state = set(facts)
    owners = {}
    for i, (pre, eff) in enumerate(zip(pres, effects)):
        if any((canonical(fact) in state) != sign for sign, fact in pre):
            return
        if i and owners.get(handoffs[i-1]) != i-1:
            return
        adds = {canonical(fact) for sign, fact in eff if sign}
        deletes = {canonical(fact) for sign, fact in eff if not sign}
        if adds & deletes:
            return
        for key in deletes:
            owners.pop(key, None)
        for key in adds - state:
            owners[key] = i
        state = (state - deletes) | adds
    actors = sorted({terms[i, v] for i,p in enumerate(actions) for v in p['agents']})
    for sign, goal in effects[-1]:
        key = canonical(goal)
        if sign and key not in facts and owners.get(key) == len(nodes)-1:
            yield {'id': gid, 'objects': objects, 'facts': list(facts.values()), 'goal': [goal],
                   'intentions': [(a, *goal) for a in actors]}, handoffs
            

def chain_path(trace, sources):
    """Require one directed path, with a shared fact at every source change."""
    paths = defaultdict(dict)
    incoming = defaultdict(list)
    for edge in trace.get('causal_edges', []):
        incoming[edge['to']].append(edge)
    for step in trace.get('steps', []):
        i, sid = step['index'], step['source']
        if sid not in sources:
            continue
        paths[i][frozenset([sid])] = [i]
        for edge in incoming[i]:
            prev = edge['from']
            other = trace['steps'][prev]['source']
            if sid != other and not edge['fact'][0].startswith('shared_'):
                continue
            for seen, path in paths[prev].items():
                paths[i][seen | {sid}] = path + [i]
        if frozenset(sources) in paths[i]:
            return paths[i][frozenset(sources)]
    return []


def verify_parent(parent):
    p = base.read(parent/'protocol.json')
    if digest(parent/'protocol.json') != (parent/'PROTOCOL.sha256').read_text(encoding='utf-8').split()[0]:
        raise ValueError('Changed parent protocol')
    for name, h in p['input_sha256'].items():
        if digest(Path(name)) != h:
            raise ValueError('Changed parent input: '+name)
    for name, h in p['implementation_sha256'].items():
        if digest(parent/'implementation'/name) != h:
            raise ValueError('Changed archived implementation: '+name)
    return p


def prepare(parent, output):
    p = verify_parent(parent)
    import importlib.util
    import sys
    spec = importlib.util.spec_from_file_location('rcnc.archived_chain_merge',
        parent/'implementation/rcnc/glaive_merge.py')
    archived = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = archived
    spec.loader.exec_module(archived)
    sources = {row['id']: archived.Source(row['id'],
        Path(row['files']['revised-domain.pddl']['frozen_path']),
        Path(row['files']['revised-problem.pddl']['frozen_path'])) for row in p['source_rows']}
    profiles, excluded = profiles_for(sources)
    # Only ordinary predicate literals are supported by this constructor.
    for sid in profiles:
        profiles[sid] = {name: profile for name, profile in profiles[sid].items()
                         if all(atom[0] in sources[sid].domain.predicates
                                for field in ('effects', 'preconditions') for _, atom in profile[field])}
    groups = base.read(parent/'selected_groups.json')['groups']
    compiled = base.read(parent/'repeat_01/compilation.json')
    output.mkdir(parents=True)
    tasks, census, inputs = [], [], {}
    for g in groups:
        gid, ids = g['id'], g['sources']
        if len(ids) not in (3, 4):
            continue
        folder = parent/'repeat_01/models'/gid
        meta = base.read(folder/'predicate_only/mapping.json')
        mapping = meta['predicate_maps']
        count, chosen = 0, None
        for nodes, links in routes(ids, profiles, mapping):
            count += 1
            if chosen is None:
                for scenario, handoffs in worlds(gid, nodes, links, sources, profiles, mapping):
                    chosen = (nodes, scenario, handoffs)
                    break
        census.append({'id': gid, 'k': len(ids), 'schema_routes': count, 'selected': chosen is not None})
        if chosen is None:
            continue
        nodes, scenario, handoffs = chosen
        for condition in ('union', 'predicate_only', 'full', 'separate_identity', *('without_'+s for s in ids)):
            model = folder/(condition if condition in ('union','predicate_only','full') else 'predicate_only')
            domain, mapping_file = model/'domain.pddl', model/'mapping.json'
            for f in (domain, mapping_file):
                h = digest(f)
                if compiled['input_sha256'][str(f.resolve())] != h:
                    raise ValueError('Changed compiled model: '+str(f))
                inputs[str(f)] = h
            problem = output/'problems'/gid/(condition+'.pddl')
            problem.parent.mkdir(parents=True, exist_ok=True)
            active = [s for s in ids if condition != 'without_'+s]
            authored_problem([sources[s] for s in ids], base.read(mapping_file), scenario, problem,
                             active_sources=active, separate_identity=condition=='separate_identity')
            inputs[str(problem)] = digest(problem)
            tasks.append({'id': gid+'__'+condition, 'group': gid, 'k': len(ids), 'sources': ids,
                          'nodes': nodes, 'handoffs': handoffs, 'condition': condition,
                          'domain': str(domain), 'mapping': str(mapping_file), 'problem': str(problem)})
    save(output/'protocol.json', {'status': 'frozen_before_search', 'parent': str(parent),
        'parent_sha256': digest(parent/'protocol.json'), 'implementation_sha256': digest(Path(__file__)),
        'input_sha256': inputs, 'tasks': tasks, 'census': census, 'excluded_profiles': excluded,
        'selection': 'First canonical feasible grounded witness per group. Contiguous source blocks with distinct action schemas and at most k+2 actions.',
        'seconds_per_search_and_replay': 15, 'attempts': 1, 'new_model_calls': 0})
    print(Counter((r['k'],r['selected']) for r in census), len(tasks), flush=True)


def execute(output):
    protocol = output/'protocol.json'
    p = base.read(protocol)
    parent = Path(p['parent'])
    prior = verify_parent(parent)
    if digest(parent/'protocol.json') != p['parent_sha256'] or digest(Path(__file__)) != p['implementation_sha256']:
        raise ValueError('Changed experiment inputs')
    for file, h in p['input_sha256'].items():
        if digest(Path(file)) != h:
            raise ValueError('Changed task input')
    events = output/'events.jsonl'
    jar, classes = Path(prior['runtime_jar']), Path(prior['runtime_classes'])
    rows = []
    import json
    with events.open('x', encoding='utf-8') as stream:
        for task in p['tasks']:
            d, problem = Path(task['domain']), Path(task['problem'])
            folder = output/'execution'/task['id']
            search = invoke(jar, d, problem, folder/'search', seconds=15)
            row = {**task, 'search': search, 'valid': False, 'path': []}
            if search['status'] == 'solved':
                plan = folder/'search/plan.pddl'
                row['replay'] = base.replay_checked(jar, classes, d, problem, plan, folder/'replay')
                row['valid'] = base.valid(row['replay'])
                if row['valid']:
                    row['trace'] = causal_trace(d, problem, plan, base.read(task['mapping']))
                    row['path'] = chain_path(row['trace'], task['sources'])
            rows.append(row)
            stream.write(json.dumps(row)+'\n')
            stream.flush()
    save(output/'report.json', {'status': 'complete', 'rows': rows, 'registered_rows': len(p['tasks']),
         'protocol_sha256': digest(protocol), 'counts': [
             {'k': k, 'condition': c, 'search': dict(Counter(r['search']['status'] for r in group)),
              'valid': sum(r['valid'] for r in group), 'all_source_chain': sum(bool(r['path']) for r in group)}
             for k,c in sorted({(r['k'], r['condition'] if not r['condition'].startswith('without_') else 'source_removal') for r in rows})
             for group in [[r for r in rows if r['k']==k and (r['condition']==c or c=='source_removal' and r['condition'].startswith('without_'))]]]})
    

if __name__ == '__main__':
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument('mode', choices=['prepare','execute'])
    cli.add_argument('--output', type=Path, required=True)
    cli.add_argument('--parent', type=Path)
    args = cli.parse_args()
    if args.mode == 'prepare':
        prepare(args.parent.resolve(), args.output.resolve())
    else:
        execute(args.output.resolve())




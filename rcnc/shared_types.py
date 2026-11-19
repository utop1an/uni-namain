"""Explicit semantic type alignment into native PDDL types.

Type correspondences are frozen modeling assumptions, not inferred from a
successful plan. Source provenance never supplies an object permission.
"""
from copy import deepcopy
import re
from types import SimpleNamespace

from .domain_building import digest
from .pddl import serialize


def identifier(value):
    if not isinstance(value, str) or not re.fullmatch(r'[a-z][a-z0-9_-]*', value):
        raise ValueError('Expected lowercase PDDL identifier: ' + repr(value))
    return value


class SharedTypes:
    def __init__(self, parents, maps):
        self.parents = dict(parents)
        self.maps = deepcopy(maps)
        if 'object' in self.parents:
            raise ValueError('object is the implicit root; do not declare a parent')
        graph = {name: ([parents] if isinstance(parents, str) else parents)
                 for name, parents in self.parents.items()}
        for name, parents in graph.items():
            identifier(name)
            if not isinstance(parents, list) or not parents or len(set(parents)) != len(parents):
                raise ValueError('Shared parents must be a nonempty list of distinct types')
            for parent in parents:
                identifier(parent)
                if parent != 'object' and parent not in self.parents:
                    raise ValueError('Unknown shared parent: ' + parent)
        self.ancestors = {'object': ['object']}
        def visit(name, stack=()):
            if name in stack:
                raise ValueError('Cycle in shared type hierarchy: ' + name)
            if name not in self.ancestors:
                found = {name}
                for parent in graph[name]:
                    found.update(visit(parent, (*stack, name)))
                self.ancestors[name] = sorted(found)
            return self.ancestors[name]
        for name in graph:
            visit(name)
        for name, found in self.ancestors.items():
            self.ancestors[name] = sorted(found, key=lambda t: (-len(self.ancestors[t]), t))
        self.graph = graph
        for sid, mapping in self.maps.items():
            identifier(sid)
            if mapping.get('object') != 'object':
                raise ValueError('Source object must map to the universal object type')
            for target in mapping.values():
                if target not in self.ancestors:
                    raise ValueError('Unknown shared target type: ' + str(target))

    @classmethod
    def from_sources(cls, sources, specification):
        if specification.get('version') != 1 or specification.get('decision_basis') not in {
                'authored_assumption', 'reviewed_annotation', 'machine_hypothesis'}:
            raise ValueError('Shared types require version 1 and an explicit decision_basis')
        evidence = specification.get('evidence')
        if not isinstance(evidence, list) or not evidence or not all(isinstance(e, str) and e.strip() for e in evidence):
            raise ValueError('Shared types require nonempty evidence descriptions')
        if set(specification) - {'version', 'decision_basis', 'evidence', 'source_sha256', 'types', 'mappings'}:
            raise ValueError('Unknown shared type specification fields')
        expected = {s.id: digest(s.domain_path) for s in sources}
        if specification.get('source_sha256') != expected:
            raise ValueError('Shared type source hashes are missing, extra, or stale')
        maps = specification.get('mappings', {})
        if set(maps) != set(expected):
            raise ValueError('Shared type mappings must cover exactly the selected sources')
        result = cls(specification['types'], maps)
        for source in sources:
            if set(maps[source.id]) != source.types:
                raise ValueError('Incomplete or unknown source type mapping: ' + source.id)
            for child, parents in source.type_parents.items():
                for parent in parents:
                    if result.maps[source.id][parent] not in result.ancestors[result.maps[source.id][child]]:
                        raise ValueError('Shared hierarchy loses source inheritance: ' + source.id + ':' + child)
        return result

    @classmethod
    def from_metadata(cls, meta):
        if meta.get('type_encoding') != 'native_shared':
            raise ValueError('Expected a domain compiled with native shared types')
        return cls(meta['shared_type_parents'], meta['type_maps'])

    def declarations(self):
        return [x for typ in sorted(self.parents, key=lambda t: (len(self.ancestors[t]), t))
                for parent in self.graph[typ] for x in (typ, '-', parent)]

    def parameters(self, sid, params):
        return [x for var, typ in params.items() for x in (var, '-', self.maps[sid][typ])]

    def common_parent(self, types):
        types = list(types)
        if not types:
            raise ValueError('Empty type signature')
        return next(t for t in self.ancestors[types[0]] if all(t in self.ancestors[x] for x in types))

    def object_type(self, declaration):
        """One canonical type, or compatible legacy source-qualified typings."""
        if isinstance(declaration, str):
            if declaration not in self.ancestors:
                raise ValueError('Unknown object type: ' + declaration)
            return declaration
        if not isinstance(declaration, dict) or not declaration:
            raise ValueError('Declare an object with one shared type')
        try:
            targets = set(self.maps[sid][typ] for sid, typ in declaration.items())
        except (KeyError, TypeError) as exc:
            raise ValueError('Unknown source-qualified object type') from exc
        choices = [t for t in targets if targets <= set(self.ancestors[t])]
        if len(choices) != 1:
            raise ValueError('Object has incomparable shared types; declare a valid common subtype explicitly')
        return choices[0]


def map_world(meta, world, path, *, active_sources=None):
    """Map an explicit world without importing any source-world facts."""
    from .glaive_merge import rewrite
    if 'facts' not in world or world['facts'] is None:
        raise ValueError('needs_initial_state')
    if not isinstance(world['facts'], list) or not isinstance(world.get('objects'), dict):
        raise ValueError('Explicit objects and a list of initial facts are required')
    if set(world) - {'id', 'objects', 'facts', 'goal', 'intentions'}:
        raise ValueError('Unknown shared-world fields')
    types = SharedTypes.from_metadata(meta)
    sources = set(types.maps)
    active = sources if active_sources is None else set(active_sources)
    if not active <= sources:
        raise ValueError('Unknown active source')
    constants = set(meta.get('shared_constant_types', {}))
    objects = {}
    for name, declared in world['objects'].items():
        identifier(name)
        if name in constants:
            raise ValueError('Object collides with a compiled source constant: ' + name)
        objects[name] = types.object_type(declared)
    terms = {sid: {**meta['constant_maps'][sid], **{o: o for o in objects}} for sid in sources}
    contexts = {sid: SimpleNamespace(id=sid, type_parents=meta['normalization'][sid]['type_parents']) for sid in sources}

    def mapped(pair, *, ground=False):
        if not isinstance(pair, (list, tuple)) or len(pair) != 2 or pair[0] not in sources:
            raise ValueError('Facts and goals must be [source_id, formula] pairs')
        sid, formula = pair
        from .glaive_intake import formula_terms
        known = set(terms[sid])
        for term in formula_terms(formula, predicate_names=set(meta['predicate_maps'][sid])):
            if term not in known:
                raise ValueError('Undeclared world object or free variable: ' + term)
        if ground and (not isinstance(formula, list) or not formula or
                       formula[0] not in meta['predicate_maps'][sid] or any(isinstance(v, list) for v in formula)):
            raise ValueError('Initial facts must be positive ground atoms under closed-world semantics')
        return rewrite(formula, contexts[sid], meta['predicate_maps'][sid], terms[sid], type_maps=types.maps)

    initial = [[sid + '_active'] for sid in sorted(active)] + [mapped(f, ground=True) for f in world['facts']]
    for actor, sid, formula in world.get('intentions', []):
        if actor not in objects and actor not in constants:
            raise ValueError('Undeclared intention actor: ' + actor)
        initial.append(['intends', actor, mapped([sid, formula])])
    goals = world.get('goal')
    if goals is not None and not isinstance(goals, list):
        raise ValueError('Goal must be a list of source/formula pairs, or omitted for initial-only exploration')
    goal = ['and', *[mapped(g) for g in (goals or [])]]
    if len(goal) == 2:
        goal = goal[1]
    initial = list({serialize(atom): atom for atom in initial}.values())
    root = ['define', ['problem', identifier(world.get('id', 'shared_world'))], [':domain', 'revised_merged'],
            [':objects', *[x for obj, typ in objects.items() for x in (obj, '-', typ)]],
            [':init', *initial], [':goal', goal]]
    path.write_text(serialize(root) + '\n', encoding='utf-8')
    return {'object_types': objects, 'active_sources': sorted(active), 'source_problem_facts_copied': 0,
            'explicit_fact_count': len(world['facts']), 'type_encoding': 'native_shared',
            'mode': 'initial_only' if goals is None else 'initial_goal'}

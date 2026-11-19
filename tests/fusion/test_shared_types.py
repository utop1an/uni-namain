"""Native types admit compatible foreign actors without losing action rules."""
from copy import deepcopy
from pathlib import Path
import tempfile
import unittest

from rcnc.domain_building import digest
from rcnc.glaive_merge import Source, build, map_problem, rewrite
from rcnc.pddl import parse_sexpr, section, typed_symbols
from rcnc.shared_types import SharedTypes, map_world
from rcnc.shared_type_cli import run


def fixture(root):
    sources = []
    domains = {
        'a': '''(define (domain a) (:requirements :adl :typing)
          (:types character item location - object) (:constants token - item)
          (:predicates (at ?c - character ?l - location) (available ?i - item)
            (enchanted ?i - item) (has ?c - character ?i - item) (marked ?c - character) (complete))
          (:action take :parameters (?who - character ?what - item ?where - location)
            :precondition (and (at ?who ?where) (available ?what) (not (enchanted ?what)))
            :effect (and (has ?who ?what) (not (available ?what))))
          (:action mark-all :parameters () :effect (forall (?x - character) (marked ?x)))
          (:action finish :parameters () :precondition (forall (?x - character) (marked ?x)) :effect (complete)))''',
        'b': '''(define (domain b) (:requirements :adl :typing)
          (:types character location item - object hunter - character)
          (:predicates (trained ?x - hunter) (ready ?x - character))
          (:action train :parameters (?who - hunter) :effect (trained ?who)))'''}
    for sid, text in domains.items():
        d, p = root / (sid + '.pddl'), root / (sid + '_problem.pddl')
        d.write_text(text, encoding='utf-8')
        p.write_text(f'(define (problem {sid}) (:domain {sid}) (:objects) (:init) (:goal (and)))', encoding='utf-8')
        sources.append(Source(sid, d, p))
    specification = {
        'version': 1, 'decision_basis': 'authored_assumption', 'evidence': ['Synthetic types with the same defined roles'],
        'source_sha256': {s.id: digest(s.domain_path) for s in sources},
        'types': {'character': 'object', 'item': 'object', 'location': 'object', 'hunter': 'character'},
        'mappings': {s.id: {t: t for t in s.types} for s in sources}}
    world = {'id': 'foreign_actor', 'objects': {'batman': 'hunter', 'axe': 'item', 'forge': 'location'},
             'facts': [['a', ['at', 'batman', 'forge']], ['a', ['available', 'axe']]],
             'goal': [['a', ['has', 'batman', 'axe']]]}
    return sources, specification, world


def physical_problem(root, sources, specification, world):
    from scripts.experiments.run_matched_unidomain_rule import physical_domain, physical_problem
    from rcnc.pddl import serialize
    from unified_planning.io import PDDLReader
    meta = build(sources, root / 'compiled', type_alignment=specification)
    map_world(meta, world, root / 'world.pddl')
    domain = physical_domain(parse_sexpr((root / 'compiled/domain.pddl').read_text(encoding='utf-8')))
    problem = physical_problem(parse_sexpr((root / 'world.pddl').read_text(encoding='utf-8')))
    (root / 'physical_domain.pddl').write_text(serialize(domain), encoding='utf-8')
    (root / 'physical_problem.pddl').write_text(serialize(problem), encoding='utf-8')
    return PDDLReader().parse_problem(str(root / 'physical_domain.pddl'), str(root / 'physical_problem.pddl')), meta


class SharedTypeTests(unittest.TestCase):
    def test_unused_parameter_preserves_binding_without_origin_guard(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            d, p = root / 'd.pddl', root / 'p.pddl'
            d.write_text('(define (domain d) (:requirements :typing :intentionality) (:types character) (:predicates (done)) (:action finish :parameters (?who - character) :effect (done) :agents (?who)))', encoding='utf-8')
            p.write_text('(define (problem p) (:domain d) (:objects batman - character) (:init) (:goal (done)))', encoding='utf-8')
            s = Source('a', d, p)
            spec = {'version': 1, 'decision_basis': 'authored_assumption', 'evidence': ['Synthetic participant'],
                    'source_sha256': {'a': digest(d)}, 'types': {'character': 'object'},
                    'mappings': {'a': {'object': 'object', 'character': 'character'}}}
            meta = build([s], root / 'compiled', type_alignment=spec)
            text = (root / 'compiled/domain.pddl').read_text(encoding='utf-8')
            self.assertIn('(= ?who ?who)', text)
            self.assertNotIn('a_type_', text)
            self.assertEqual(meta['native_parameter_tautologies'], {'a_a_finish': ['?who']})

    def test_multiple_inheritance_retains_both_native_memberships(self):
        from rcnc.glaive_intake import type_graph, ancestors
        types = SharedTypes({'character': 'object', 'item': 'object',
                             'animal': ['character', 'item'], 'wolf': 'animal'},
                            {'a': {'object': 'object', 'animal': 'animal'}})
        graph = type_graph(['define', ['domain', 'test'], [':types', *types.declarations()]])
        self.assertEqual(ancestors('wolf', graph), {'wolf', 'animal', 'character', 'item', 'object'})
        self.assertEqual(types.common_parent(['wolf', 'character']), 'character')
        self.assertEqual(types.common_parent(['wolf', 'item']), 'item')
        self.assertEqual(types.object_type({'a': 'animal'}), 'animal')
        with self.assertRaisesRegex(ValueError, 'Cycle'):
            SharedTypes({'animal': ['item', 'character'], 'item': 'animal', 'character': 'object'}, {})

    def test_foreign_actor_uses_action_native_subtypes_and_constants(self):
        from unified_planning.shortcuts import SequentialSimulator
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); sources, spec, world = fixture(root)
            # Legacy source-qualified declarations need not list the action's source.
            world['objects']['batman'] = {'b': 'hunter'}
            problem, meta = physical_problem(root, sources, spec, world)
            take = problem.action('a_a_take')
            self.assertEqual(take.parameters[0].type.name, 'character')
            self.assertEqual(problem.object('batman').type.name, 'hunter')
            self.assertEqual(problem.object('a_o_token').type.name, 'item')
            self.assertFalse(any('_type_' in f.name for f in problem.fluents))
            args = [problem.object(x) for x in ['batman', 'axe', 'forge']]
            with SequentialSimulator(problem) as sim:
                state = sim.get_initial_state()
                self.assertTrue(sim.is_applicable(state, take, args))
                self.assertTrue(sim.is_goal(sim.apply(state, take, args)))

    def test_enchanted_item_still_blocks_pickup(self):
        from unified_planning.shortcuts import SequentialSimulator
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); sources, spec, world = fixture(root)
            world['facts'].append(['a', ['enchanted', 'axe']])
            problem, _ = physical_problem(root, sources, spec, world)
            with SequentialSimulator(problem) as sim:
                self.assertFalse(sim.is_applicable(sim.get_initial_state(), problem.action('a_a_take'),
                                 [problem.object(x) for x in ['batman', 'axe', 'forge']]))

    def test_wrong_actor_type_is_rejected_and_specialized_role_stays_narrow(self):
        from unified_planning.exceptions import UPTypeError
        from unified_planning.plans import ActionInstance
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); sources, spec, world = fixture(root)
            world['objects']['arthur'] = 'character'
            problem, _ = physical_problem(root, sources, spec, world)
            with self.assertRaises(UPTypeError):
                ActionInstance(problem.action('a_a_take'), tuple(problem.object(x) for x in ['axe', 'axe', 'forge']))
            with self.assertRaises(UPTypeError):
                ActionInstance(problem.action('b_a_train'), (problem.object('arthur'),))

    def test_quantifiers_range_over_shared_types_not_source_membership(self):
        from unified_planning.shortcuts import SequentialSimulator
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); sources, spec, world = fixture(root)
            problem, _ = physical_problem(root, sources, spec, world)
            with SequentialSimulator(problem) as sim:
                state = sim.get_initial_state()
                self.assertFalse(sim.is_applicable(state, problem.action('a_a_finish'), []))
                after = sim.apply(state, problem.action('a_a_mark-all'), [])
                self.assertTrue(after.get_value(problem.fluent('a_p_marked')(problem.object('batman'))).is_true())
                self.assertTrue(sim.is_applicable(after, problem.action('a_a_finish'), []))

    def test_type_hierarchy_and_source_evidence_are_checked(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); sources, spec, _ = fixture(root)
            for change in ['cycle', 'parent', 'hash', 'missing']:
                with self.subTest(change=change):
                    bad = deepcopy(spec)
                    if change == 'cycle': bad['types']['character'] = 'hunter'
                    elif change == 'parent': bad['mappings']['b']['hunter'] = 'item'
                    elif change == 'hash': bad['source_sha256']['a'] = '0' * 64
                    else: del bad['mappings']['b']['hunter']
                    with self.assertRaises(ValueError): SharedTypes.from_sources(sources, bad)
            types = SharedTypes.from_sources(sources, spec)
            with self.assertRaisesRegex(ValueError, 'incomparable'):
                types.object_type({'a': 'item', 'b': 'hunter'})

    def test_problem_mapping_does_not_pool_facts_and_requires_init(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); sources, spec, world = fixture(root)
            meta = build(sources, root / 'compiled', type_alignment=spec)
            world['facts'] = []
            map_world(meta, world, root / 'world.pddl')
            initial = section(parse_sexpr((root / 'world.pddl').read_text(encoding='utf-8')), ':init')
            self.assertEqual(initial, [':init', ['a_active'], ['b_active']])
            del world['facts']
            self.assertEqual(run(root / 'compiled', world, root / 'search')['status'], 'needs_initial_state')
            self.assertFalse((root / 'search').exists())

    def test_original_problem_maps_native_types(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); sources, spec, _ = fixture(root)
            sources[1].objects = {'bruce': 'hunter'}
            meta = build(sources, root / 'compiled', type_alignment=spec)
            map_problem(sources, 'b', meta, root / 'original.pddl')
            problem = parse_sexpr((root / 'original.pddl').read_text(encoding='utf-8'))
            self.assertEqual(section(problem, ':objects'), [':objects', 'b_o_bruce', '-', 'hunter'])
            self.assertEqual(section(problem, ':init'), [':init', ['b_active']])

    def test_existential_and_shadowed_quantifiers_keep_bindings(self):
        with tempfile.TemporaryDirectory() as tmp:
            sources, spec, _ = fixture(Path(tmp)); s = sources[0]
            expr = ['exists', ['?x', '-', 'character'], ['at', '?x', 'forge']]
            mapped = rewrite(expr, s, {'at': ('at', [0, 1])}, {'?x': 'wrong', 'forge': 'site'}, type_maps=spec['mappings'])
            self.assertEqual(mapped, ['exists', ['?x', '-', 'character'], ['at', '?x', 'site']])

    def test_public_search_uses_the_frozen_shared_domain(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); sources, spec, world = fixture(root)
            build(sources, root / 'compiled', type_alignment=spec)
            result = run(root / 'compiled', world, root / 'run', seconds=25)
            self.assertEqual(result['status'], 'solved')
            self.assertEqual(result['search']['length'], 1)
            self.assertTrue(result['inputs_unchanged'])
            self.assertEqual(result['search']['validation']['status'], 'VALID')

    def test_object_type_name_overlap_is_only_renamed_in_physical_types(self):
        from rcnc.shared_type_cli import physical_inputs
        from rcnc.glaive_merge import action_fields
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); sources, spec, world = fixture(root)
            spec['types']['axe'] = 'item'; world['objects']['axe'] = 'axe'
            build(sources, root / 'compiled', type_alignment=spec)
            result = run(root / 'compiled', world, root / 'run')
            self.assertEqual(result['status'], 'solved')
            self.assertEqual(result['search']['validation']['status'], 'VALID')
            self.assertEqual(result['search']['length'], 1)
            native = parse_sexpr((root / 'run/authored_problem.pddl').read_text(encoding='utf-8'))
            physical = parse_sexpr((root / 'run/problem.pddl').read_text(encoding='utf-8'))
            self.assertEqual(typed_symbols(section(native, ':objects')[1:])['axe'], 'axe')
            self.assertEqual(typed_symbols(section(physical, ':objects')[1:])['axe'], 'type_axe')
            domain = parse_sexpr('''(define (domain fixture) (:requirements :adl :typing)
              (:types axe - object) (:predicates (held ?x - axe))
              (:action mark :parameters (?x - axe) :effect (forall (?x - axe) (held ?x))))''')
            problem = parse_sexpr('''(define (problem fixture) (:domain fixture) (:requirements :adl)
              (:objects axe - axe) (:init) (:goal (held axe)))''')
            mapped, mapped_problem, names = physical_inputs(domain, problem)
            self.assertEqual(names, {'axe': 'type_axe'})
            self.assertEqual(action_fields(section(mapped, ':action'))[':effect'],
                             ['forall', ['?x', '-', 'type_axe'], ['held', '?x']])
            self.assertEqual(section(mapped_problem, ':goal'), [':goal', ['held', 'axe']])
            self.assertEqual(section(domain, ':types'), [':types', 'axe', '-', 'object'])

    def test_typed_action_fusion_respects_parameter_permutation(self):
        from tests.test_glaive_merge import fixture as fusion_fixture
        from rcnc.conditional_merge import symbol_digest
        from rcnc.glaive_merge import action_fields
        from rcnc.pddl import parse_domain
        for mismatch in [False, True]:
            with self.subTest(mismatch=mismatch), tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp); sources, groups = fusion_fixture(root)
                for s in sources:
                    text = s.domain_path.read_text(encoding='utf-8')
                    params = ('?who - person ?from ?to - place' if s.id == 'left' else
                              '?to - place ?who - person ?from - place')
                    if mismatch and s.id == 'right':
                        params = params.replace('?who - person', '?who - object')
                    old = '?who ?from ?to - object' if s.id == 'left' else '?to ?who ?from - object'
                    s.domain_path.write_text(text.replace(old, params), encoding='utf-8')
                sources = [Source(s.id, s.domain_path, s.problem_path) for s in sources]
                for s, member in zip(sources, groups[1]['members']):
                    member['semantics']['symbol_sha256'] = symbol_digest(s.domain.actions['travel'])
                spec = {'version': 1, 'decision_basis': 'authored_assumption', 'evidence': ['Typed fusion fixture'],
                        'source_sha256': {s.id: digest(s.domain_path) for s in sources},
                        'types': {'person': 'object', 'place': 'object'},
                        'mappings': {s.id: {t: t for t in s.types} for s in sources}}
                meta = build(sources, root / 'compiled', groups=groups, merge_actions=True, type_alignment=spec)
                self.assertEqual(meta['action_count'], 2 if mismatch else 1)
                if mismatch:
                    self.assertIn('Different shared parameter types', meta['decisions'][-1]['reason'])
                else:
                    fused = parse_domain(root / 'compiled/domain.pddl').actions['fused_action']
                    self.assertEqual(typed_symbols(action_fields(fused)[':parameters']),
                                     {'?m0': 'person', '?m1': 'place', '?m2': 'place'})
                    self.assertEqual(meta['action_maps']['right:travel']['order'], [1, 2, 0])

    def test_native_axiom_variables_retained_and_physical_adapter_rejects(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); sources, spec, world = fixture(root)
            source = sources[0]
            text = source.domain_path.read_text(encoding='utf-8')
            source.domain_path.write_text(text.rstrip()[:-1] +
                ' (:axiom :vars (?who - character) :context (marked ?who) :implies (complete)))', encoding='utf-8')
            sources[0] = Source(source.id, source.domain_path, source.problem_path)
            spec['source_sha256']['a'] = digest(source.domain_path)
            meta = build(sources, root / 'compiled', type_alignment=spec)
            domain = parse_sexpr((root / 'compiled/domain.pddl').read_text(encoding='utf-8'))
            axiom = section(domain, ':axiom')
            self.assertEqual(axiom[axiom.index(':vars') + 1], ['?who', '-', 'character'])
            self.assertEqual(meta['axiom_count'], 1)
            with self.assertRaisesRegex(ValueError, 'does not execute native axioms'):
                run(root / 'compiled', world, root / 'run')
            self.assertFalse((root / 'run').exists())

    def test_quantified_world_goal_and_free_variable_rejection(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); sources, spec, world = fixture(root)
            meta = build(sources, root / 'compiled', type_alignment=spec)
            world['goal'] = [['a', ['exists', ['?who', '-', 'character'], ['has', '?who', 'axe']]]]
            map_world(meta, world, root / 'world.pddl')
            goal = section(parse_sexpr((root / 'world.pddl').read_text(encoding='utf-8')), ':goal')[1]
            self.assertEqual(goal, ['exists', ['?who', '-', 'character'], ['a_p_has', '?who', 'axe']])
            world['goal'] = [['a', ['has', '?who', 'axe']]]
            with self.assertRaisesRegex(ValueError, 'free variable'):
                map_world(meta, world, root / 'bad.pddl')


if __name__ == '__main__':
    unittest.main()

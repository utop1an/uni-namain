import copy
from pathlib import Path
import tempfile
import unittest

from rcnc.glaive_merge import Source, Unsupported, build, map_problem, translate_plan, action_fields
from rcnc.conditional_merge import symbol_digest
from rcnc.pddl import parse_domain, parse_sexpr, section, serialize


def fixture(root):
    sources = []
    for sid, pred, params, pre in [('left', 'at', '?who ?from ?to', '(at ?who ?from)'),
                                    ('right', 'located', '?to ?who ?from', '(and (located ?who ?from) (ready ?who))')]:
        d, p = root / (sid + '.pddl'), root / (sid + '_problem.pddl')
        d.write_text(f'''(define (domain {sid}) (:requirements :adl :intentionality)
          (:types person place - object) (:constants home - place)
          (:predicates ({pred} ?p ?l - object) (ready ?p - object))
          (:action travel :parameters ({params} - object) :precondition {pre}
           :effect (and (not ({pred} ?who ?from)) ({pred} ?who ?to)) :agents (?who)))''', encoding='utf-8')
        p.write_text(f'''(define (problem {sid}) (:domain {sid}) (:objects alice - person away - place)
          (:init ({pred} alice home) (ready alice) (intends alice ({pred} alice away)))
          (:goal ({pred} alice away)))''', encoding='utf-8')
        sources.append(Source(sid, d, p))
    groups = []
    for kind, names, orders, concept in [('predicate', ['at', 'located'], [[0, 1], [0, 1]], 'location'),
                                         ('action', ['travel', 'travel'], [[0, 1, 2], [1, 2, 0]], 'relocate')]:
        members = []
        for s, name, order in zip(sources, names, orders):
            value = s.domain.predicates[name] if kind == 'predicate' else s.domain.actions[name]
            canonical_roles = ['actor', 'place'] if kind == 'predicate' else ['actor', 'origin', 'destination']
            roles = [None] * len(order)
            for i, j in enumerate(order): roles[j] = canonical_roles[i]
            members.append({kind: s.id + ':' + name, 'order': order,
                'semantics': {'concept': concept, 'scope': 'physical', 'roles': roles, 'confidence': 1.0,
                              'evidence': ['authored engineering fixture'], 'symbol_sha256': symbol_digest(value)}})
        groups.append({'id': kind, 'model_judgment': {'decision': 'compatible'}, 'members': members})
    return sources, groups


def environment_fixture(root):
    sources = []
    for sid in ('nature_left', 'nature_right'):
        d, p = root/(sid+'.pddl'), root/(sid+'_problem.pddl')
        d.write_text(f'(define (domain {sid}) (:requirements :adl :intentionality) (:types) (:predicates (done)) (:action happen :parameters () :effect (done)))', encoding='utf-8')
        p.write_text(f'(define (problem {sid}) (:domain {sid}) (:objects) (:init) (:goal (done)))', encoding='utf-8')
        sources.append(Source(sid,d,p))
    groups = []
    for kind, symbol in [('predicate','done'),('action','happen')]:
        members = []
        for s in sources:
            value = s.domain.predicates[symbol] if kind=='predicate' else s.domain.actions[symbol]
            members.append({kind:s.id+':'+symbol,'order':[], 'semantics':{'concept':'environment_completion','scope':'authored_fixture','roles':[],
                'confidence':1.,'evidence':['authored engineering fixture'],'symbol_sha256':symbol_digest(value)}})
        groups.append({'id':kind+'_environment','model_judgment':{'decision':'compatible'},'members':members})
    return sources,groups


class GlaiveMergeTests(unittest.TestCase):
    def test_environment_actions_omit_empty_agents_and_default_true(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td); sources,groups=environment_fixture(root)
            m=build(sources,root/'merged',groups=groups,merge_actions=True)
            self.assertEqual(m['action_count'],1)
            text=(root/'merged/domain.pddl').read_text()
            self.assertNotIn(':agents',text)
            self.assertNotIn('(and)',text)
            d=parse_domain(root/'merged/domain.pddl')
            self.assertEqual(action_fields(d.actions['fused_action_environment'])[':precondition'],
                             ['or',['nature_left_active'],['nature_right_active']])

    def test_intentions_separate_worlds_and_parameter_permutation(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); sources, groups = fixture(root)
            m = build(sources, root / 'merged', groups=groups, merge_actions=True)
            self.assertEqual(m['action_count'], 1)
            d = parse_domain(root / 'merged/domain.pddl')
            self.assertEqual(section(parse_sexpr((root / 'merged/domain.pddl').read_text()), ':types'), [':types'])
            f = action_fields(d.actions['fused_action'])
            self.assertEqual(f[':agents'], ['?m0'])
            self.assertEqual(f[':precondition'][0], 'or')
            terms = map_problem(sources, 'right', m, root / 'problem.pddl')
            p = parse_sexpr((root / 'problem.pddl').read_text())
            initial = section(p, ':init')
            self.assertIn(['right_active'], initial)
            self.assertNotIn(['left_active'], initial)
            self.assertIn(['intends', 'right_o_alice', ['shared_predicate', 'right_o_alice', 'right_o_away']], initial)
            self.assertNotEqual(sources[0].term_map['home'], sources[1].term_map['home'])
            (root / 'plan.pddl').write_text('(define (plan p) (:problem right) (:steps (travel away alice home)))')
            translate_plan('right', m, terms, root / 'plan.pddl', root / 'mapped.pddl')
            self.assertIn('(fused_action right_o_alice right_o_home right_o_away)', (root / 'mapped.pddl').read_text())

    def test_mismatching_effects_and_agent_roles_stay_separate(self):
        for mutation in ('effect', 'agents'):
            with self.subTest(mutation=mutation), tempfile.TemporaryDirectory() as td:
                root = Path(td); sources, groups = fixture(root)
                right = sources[1]
                a = right.domain.actions['travel']
                if mutation == 'agents': a[a.index(':agents') + 1] = ['?from']
                else: a[a.index(':effect') + 1].append(['ready', '?who'])
                groups[1]['members'][1]['semantics']['symbol_sha256'] = symbol_digest(a)
                m = build(sources, root / 'merged', groups=groups, merge_actions=True)
                self.assertEqual(m['action_count'], 2)
                self.assertEqual(m['decisions'][-1]['status'], 'retained_separate')

    def test_no_goal_only_and_no_silent_axiom_removal(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); sources, _ = fixture(root); s = sources[0]
            text = s.domain_path.read_text()
            s.domain_path.write_text(text[:-1] + ' (:axiom :vars () :context (and) :implies (ready home)))')
            with self.assertRaisesRegex(Unsupported, 'axioms'): Source(s.id, s.domain_path, s.problem_path)
            s.domain_path.write_text(text)
            p = parse_sexpr(s.problem_path.read_text()); p.remove(section(p, ':init'))
            s.problem_path.write_text(serialize(p))
            with self.assertRaisesRegex(Unsupported, 'needs_initial_state'): Source(s.id, s.domain_path, s.problem_path)

    def test_stale_semantic_card_and_threshold_do_not_merge(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); sources, groups = fixture(root)
            groups[0]['members'][0]['semantics']['confidence'] = .89
            groups[1]['members'][0]['semantics']['symbol_sha256'] = 'stale'
            m = build(sources, root / 'merged', groups=groups, merge_actions=True)
            self.assertFalse(any(d['status'] == 'accepted' for d in m['decisions']))


if __name__ == '__main__': unittest.main()

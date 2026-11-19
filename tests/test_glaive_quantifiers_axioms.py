from pathlib import Path
import tempfile
import unittest

from rcnc.glaive_intake import formula_terms, constant_contract, feature_inventory, read_tree
from rcnc.glaive_merge import Source, build, map_problem, rewrite, rename_vars, action_fields
from rcnc.pddl import parse_sexpr, parse_domain, section, serialize
from tests.test_glaive_merge import fixture


def evaluate(expr, facts, objects, env=None):
    """Small independent Boolean interpretation for finite authored fixtures."""
    env = env or {}
    h = expr[0]
    if h == 'and': return all(evaluate(e, facts, objects, env) for e in expr[1:])
    if h == 'or': return any(evaluate(e, facts, objects, env) for e in expr[1:])
    if h == 'not': return not evaluate(expr[1], facts, objects, env)
    if h == 'imply': return not evaluate(expr[1], facts, objects, env) or evaluate(expr[2], facts, objects, env)
    if h in ('forall', 'exists'):
        values = [evaluate(expr[2], facts, objects, {**env, expr[1][0]: obj}) for obj in objects]
        return all(values) if h == 'forall' else any(values)
    return tuple(env.get(t, t) for t in expr) in facts


class ScopedLanguageTests(unittest.TestCase):
    def setUp(self):
        self.root = Path(self.enterContext(tempfile.TemporaryDirectory()))

    def source(self, body='', goal='(done)', init='(marked alice)'):
        d, p = self.root / 'domain.pddl', self.root / 'problem.pddl'
        d.write_text('''(define (domain d) (:types person item)
          (:predicates (marked ?x - object) (done)) ''' + body + ')', encoding='utf-8')
        p.write_text(f'''(define (problem p) (:domain d) (:objects alice bob - person stone - item)
          (:init {init}) (:goal {goal}))''', encoding='utf-8')
        return Source('s', d, p)

    def test_free_variables_and_constants_respect_nested_shadowing(self):
        expr = parse_sexpr('(and (p ?x home) (forall (?x - person) (and (p ?x place) (exists (?y - item) (q ?x ?y ?free)))))')
        self.assertEqual(set(formula_terms(expr)), {'?x', 'home', 'place', '?free'})

    def test_alpha_renaming_avoids_capturing_parameters_or_inner_shadowing(self):
        expr = parse_sexpr('(and (p ?x) (forall (?m0 - object) (and (q ?x ?m0) (exists (?x - object) (r ?x ?m0)))))')
        transformed = rename_vars(expr, {'?x': '?m0'})
        self.assertEqual(set(formula_terms(transformed)), {'?m0'})
        self.assertEqual(transformed[2][1][0], '?bound0')
        self.assertEqual(transformed[2][2][1], ['q', '?m0', '?bound0'])
        self.assertEqual(transformed[2][2][2], ['exists', ['?x', '-', 'object'], ['r', '?x', '?bound0']])

    def test_universal_and_existential_conditions_do_not_range_over_foreign_objects(self):
        s = self.source()
        pm = {'marked': ('s_marked', [0])}
        facts = {('s_type_person', 'alice'), ('s_type_person', 'bob'), ('s_marked', 'alice'), ('s_marked', 'bob')}
        objects = ['alice', 'bob', 'foreign']
        forall = rewrite(parse_sexpr('(forall (?x - person) (marked ?x))'), s, pm, {})
        exists = rewrite(parse_sexpr('(exists (?x - person) (marked ?x))'), s, pm, {})
        self.assertTrue(evaluate(forall, facts, objects))
        self.assertFalse(evaluate(exists, {('s_marked', 'foreign')}, objects))
        self.assertTrue(evaluate(forall, set(), objects))
        self.assertFalse(evaluate(exists, set(), objects))

    def test_quantified_effects_have_when_guards_and_conditions_keep_implication(self):
        s = self.source('''(:action clear :parameters () :effect
          (forall (?x - person) (when (forall (?y - item) (marked ?y)) (not (marked ?x)))))''')
        m = build([s], self.root / 'out')
        eff = action_fields(parse_domain(self.root / 'out/domain.pddl').actions['s_a_clear'])[':effect']
        self.assertEqual(eff[:2], ['forall', ['?x', '-', 'object']])
        self.assertEqual(eff[2][0], 'when')
        self.assertIn(['s_type_person', '?x'], eff[2][1])
        self.assertIn('(or (not (s_type_item ?y))', serialize(eff[2][1]))
        self.assertNotIn('imply', serialize(eff[2][2]))
        self.assertEqual(m['axiom_count'], 0)

    def test_unknown_quantified_types_and_free_variables_fail(self):
        for expr, error in [
            ('(forall (?x - missing) (marked ?x))', 'Undeclared source type'),
            ('(forall (?x - person) (marked ?y))', 'Unbound action term'),
            ('(forall (?x - expression) (marked ?x))', 'Expression-valued'),
        ]:
            with self.subTest(expr=expr), self.assertRaisesRegex(ValueError, error):
                self.source('(:action a :parameters () :effect ' + expr + ')')
        s = self.source('(:action a :parameters () :effect (exists (?x - person) (marked ?x)))')
        with self.assertRaisesRegex(ValueError, 'Existential effects'):
            build([s], self.root / 'bad')

    def test_axioms_preserve_negative_and_intentional_consequences_and_source_gate(self):
        s = self.source('''(:axiom :vars (?x - person) :context (marked ?x)
                           :implies (and (not (marked ?x)) (intends ?x (done))))''')
        m = build([s], self.root / 'out')
        tree = parse_sexpr((self.root / 'out/domain.pddl').read_text(encoding='utf-8'))
        a = section(tree, ':axiom')
        fields = dict(zip(a[1::2], a[2::2]))
        self.assertIn(['s_active'], fields[':context'])
        self.assertIn(['s_type_person', '?x'], fields[':context'])
        self.assertEqual(fields[':implies'], ['and', ['not', ['s_p_marked', '?x']], ['intends', '?x', ['s_p_done']]])
        self.assertIn(':domain-axioms', section(tree, ':requirements'))
        self.assertEqual(m['axiom_maps'], [{'source': 's', 'source_index': 0, 'exported_index': 0}])
        self.assertFalse(evaluate(fields[':context'], {('s_type_person', 'alice'), ('s_p_marked', 'alice')}, ['alice'], {'?x': 'alice'}))

    def test_axiom_free_variables_and_unknown_fields_rejected(self):
        for body, message in [
            ('(:axiom :vars (?x - person) :context (marked ?y) :implies (done))', 'Unbound axiom'),
            ('(:axiom :vars () :mystery (done) :implies (done))', 'Unsupported or missing axiom'),
        ]:
            with self.subTest(body=body), self.assertRaisesRegex(ValueError, message):
                self.source(body)

    def test_constant_scanner_includes_axioms_but_not_bound_variables_or_types(self):
        s = self.source()
        text = s.domain_path.read_text(encoding='utf-8')
        s.domain_path.write_text(text[:-1] + ' (:axiom :vars () :context (forall (?x - person) (marked ?x)) :implies (marked alice)))', encoding='utf-8')
        c = constant_contract(s.domain_path, [s.problem_path])
        self.assertEqual(c, {'alice': 'person'})
        imported = Source('s', s.domain_path, s.problem_path, constant_contract=c)
        build([imported], self.root / 'out')

    def test_axiom_sources_do_not_receive_old_action_fusion_certificate(self):
        sources, groups = fixture(self.root)
        for s in sources:
            text = s.domain_path.read_text(encoding='utf-8')
            s.domain_path.write_text(text[:-1] + ' (:axiom :vars (?x - person) :context (ready ?x) :implies (ready ?x)))', encoding='utf-8')
        sources = [Source(s.id, s.domain_path, s.problem_path) for s in sources]
        m = build(sources, self.root / 'out', groups=groups, merge_actions=True)
        self.assertEqual(m['action_count'], 2)
        self.assertIn('certificate not extended', m['decisions'][-1]['reason'])

    def test_feature_inventory_reports_multiple_blockers(self):
        d = parse_sexpr('(define (domain d) (:predicates (p)) (:action a :parameters (?g - expression) :fail (p) :effect (forall (?x) (believes ?x (p)))))')
        features = feature_inventory(d)
        self.assertEqual(features['special_parameter_types'], ['expression'])
        self.assertEqual(features['construct_counts'], {':fail': 1, 'believes': 1, 'forall': 1})


if __name__ == '__main__': unittest.main()

from pathlib import Path
import tempfile
import unittest

from rcnc.glaive_intake import constant_contract, formula_terms, feature_inventory, read_tree
from rcnc.glaive_merge import Source, build, map_problem, rewrite
from rcnc.pddl import parse_sexpr, section


class ProblemLanguageTests(unittest.TestCase):
    def setUp(self):
        self.root = Path(self.enterContext(tempfile.TemporaryDirectory()))

    def source(self, extra='', init='(exists a)', goal='(exists a)', body='', sid='s'):
        domain = self.root / (sid + '_domain.pddl'); problem = self.root / (sid + '_problem.pddl')
        domain.write_text('''(define (domain d) (:types person)
          (:predicates (exists ?x - person) (done ?x - person)) ''' + body + ')', encoding='utf-8')
        problem.write_text(f'(define (problem p) (:domain d) (:objects a - person) (:init {init}) (:goal {goal}) {extra})', encoding='utf-8')
        return Source(sid, domain, problem)

    def test_declared_exists_atom_and_quantifier_have_distinct_roles(self):
        s = self.source(body='''(:action a :parameters (?x - person)
          :precondition (and (exists ?x) (exists (?y - person) (done ?y))) :effect (done ?x))''')
        meta = build([s], self.root/'out'); map_problem([s], s.id, meta, self.root/'out/problem.pddl')
        text = (self.root/'out/domain.pddl').read_text(encoding='utf-8')
        self.assertIn('(s_p_exists ?x)', text)
        self.assertIn('(exists (?y - object)', text)
        self.assertEqual(s.normalization['reserved_predicate_atoms'], ['exists'])
        self.assertEqual(feature_inventory(s.root, s.problem)['construct_counts']['exists'], 1)
        self.assertEqual(set(formula_terms(parse_sexpr('(exists a)'), predicate_names={'exists'})), {'a'})

    def test_undeclared_flat_exists_is_not_silently_accepted(self):
        with self.assertRaisesRegex(ValueError, 'Malformed quantifier'):
            list(formula_terms(['exists', 'a']))

    def test_constant_contract_respects_predicate_namespace(self):
        s = self.source()
        s.domain_path.write_text(s.domain_path.read_text(encoding='utf-8')[:-1] + ' (:action create :parameters () :effect (exists a)))', encoding='utf-8')
        self.assertEqual(constant_contract(s.domain_path, [s.problem_path]), {'a': 'person'})

    def test_explicit_problem_intentions_are_mapped_once_and_recorded(self):
        s = self.source(extra='(:intentionality (intends a (done a)) (intends a (exists a)))',
                        init='(exists a) (intends a (done a))')
        original = s.problem_path.read_bytes()
        meta = build([s], self.root/'out'); map_problem([s], s.id, meta, self.root/'out/problem.pddl')
        problem = read_tree(self.root/'out/problem.pddl'); init = section(problem, ':init')
        self.assertEqual(init.count(['intends','s_o_a',['s_p_done','s_o_a']]), 1)
        self.assertIn(['intends','s_o_a',['s_p_exists','s_o_a']], init)
        self.assertEqual(len(meta['normalization']['s']['problem_intentionality']['declarations']), 2)
        self.assertEqual(original, s.problem_path.read_bytes())

    def test_problem_intention_is_local_to_its_explicit_world(self):
        left = self.source(extra='(:intentionality (intends a (done a)))', sid='l')
        right = self.source(sid='r')
        meta = build([left, right], self.root/'out')
        map_problem([left, right], 'r', meta, self.root/'out/right.pddl')
        init = section(read_tree(self.root/'out/right.pddl'), ':init')
        self.assertFalse(any(x[0]=='intends' for x in init[1:]))

    def test_unknown_actor_contradiction_and_malformed_section_fail_closed(self):
        for extra, init, error in [
            ('(:intentionality (intends stranger (done a)))', '', 'Undeclared problem object'),
            ('(:intentionality (intends a (done a)))', '(not (intends a (done a)))', 'contradicts'),
            ('(:intentionality (done a))', '', 'explicit intends'),
            ('(:intentionality) (:intentionality)', '', 'Duplicate'),
        ]:
            with self.subTest(extra=extra), self.assertRaisesRegex(ValueError, error): self.source(extra=extra, init=init)

    def test_goal_only_requirements_survive_problem_export(self):
        s = self.source(goal='(and (not (done a)) (or (exists a) (done a)) (forall (?x - person) (exists ?x)))')
        meta = build([s], self.root/'out'); map_problem([s], s.id, meta, self.root/'out/problem.pddl')
        problem = read_tree(self.root/'out/problem.pddl')
        self.assertEqual(section(problem, ':requirements'), [':requirements', ':adl', ':intentionality'])
        self.assertEqual(section(problem, ':goal')[1][0], 'and')

    def test_complex_intention_stays_one_intention_with_whole_goal(self):
        s = self.source()
        expr = parse_sexpr('(intends a (or (exists a) (done a)))')
        mapped = rewrite(expr, s, {'exists':('s_exists',[0]),'done':('s_done',[0])}, {'a':'s_a'})
        self.assertEqual(mapped, ['intends','s_a',['or',['s_exists','s_a'],['s_done','s_a']]])


if __name__ == '__main__': unittest.main()

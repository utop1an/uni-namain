import copy
from pathlib import Path
import tempfile
import unittest

from scripts.audit.audit_fusion_mapping import inspect


class FusionMappingAuditTests(unittest.TestCase):
    def test_distinguishes_literal_rewrite_collisions_and_missing_targets(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp)
            (root/'A_domainfile.pddl').write_text('''(define (domain a) (:requirements :strips :typing)
             (:types item) (:constants a - item) (:predicates (p ?x - item) (q ?x - item))
             (:action first :parameters (?x - item) :precondition (and) :effect (p ?x))
             (:action second :parameters (?x - item) :precondition (q ?x) :effect (p ?x)))''',encoding='utf-8')
            (root/'merged.pddl').write_text('''(define (domain m) (:requirements :strips :typing)
             (:types item) (:constants mapped - item) (:predicates (shared ?x - item))
             (:action merged :parameters (?x - item) :precondition (and) :effect (shared ?x)))''',encoding='utf-8')
            meta={'sources':['A'],'predicate_maps':{'A':{'p':'shared','q':'shared'}},
                  'constant_maps':{'A':{'a':'mapped'}},'action_maps':{'A':{'first':'merged','second':'merged'}}}
            result=inspect(root,root/'merged.pddl',meta)
            self.assertEqual({'rename_only_ast_equal':1,'rewritten_ast_no_verified_parameter_map':1},result['action_counts'])
            self.assertEqual({'shared':['p','q']},result['sources'][0]['mapping_categories']['predicates']['within_source_collisions'])
            self.assertEqual('VALID',result['independent_domain_parse'])
            bad=copy.deepcopy(meta);bad['action_maps']['A']['first']='absent'
            result=inspect(root,root/'merged.pddl',bad)
            self.assertEqual(1,result['action_counts']['missing_mapping_or_target'])


if __name__=='__main__':
    unittest.main()

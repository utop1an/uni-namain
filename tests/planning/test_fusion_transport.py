import json
from pathlib import Path
import tempfile
import unittest

from scripts.experiments.probe_fusion_source_plans import transport


class FusionTransportTests(unittest.TestCase):
    def test_changed_formals_are_unknown_and_added_precondition_invalidates_trace(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp);original=root/'original';snapshot=root/'snapshot'
            original.mkdir();(snapshot/'inputs').mkdir(parents=True)
            source='''(define (domain a) (:requirements :strips :typing) (:types item)
             (:constants a - item) (:predicates (p ?x - item) (q ?x - item))
             (:action go :parameters (?x - item) :precondition (and) :effect (p ?x)))'''
            (original/'domain.pddl').write_text(source,encoding='utf-8')
            (snapshot/'inputs/A_domainfile.pddl').write_text(source,encoding='utf-8')
            (original/'problem.pddl').write_text('(define (problem p) (:domain a) (:init) (:goal (p a)))',encoding='utf-8')
            (original/'plan.txt').write_text('(go a)\n',encoding='utf-8')
            meta={'predicate_maps':{'A':{'p':'p','q':'q'}},'constant_maps':{'A':{'a':'a'}},'action_maps':{'A':{'go':'new'}}}
            (snapshot/'meta_domain.json').write_text(json.dumps(meta),encoding='utf-8')
            target=source.replace('(domain a)','(domain merged)').replace(':action go',':action new')
            (snapshot/'meta_domain.pddl').write_text(target.replace('?x','?z'),encoding='utf-8')
            result=transport('A',original,snapshot,root/'unknown')
            self.assertEqual('unverified_parameter_transport',result['status'])
            (snapshot/'meta_domain.pddl').write_text(target.replace(':precondition (and)',':precondition (q ?x)'),encoding='utf-8')
            result=transport('A',original,snapshot,root/'invalid')
            self.assertEqual('VALID',result['original_validation']['status'])
            self.assertEqual('INVALID',result['mapped_validation']['status'])


if __name__=='__main__':
    unittest.main()

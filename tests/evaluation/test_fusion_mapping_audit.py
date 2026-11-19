import copy
import json
from pathlib import Path
import tempfile
import unittest

from scripts.audit.audit_fusion_mapping import inspect, run
from scripts.experiments.run_downward_reference import sha


class FusionMappingAuditTests(unittest.TestCase):
    def failed_fixture(self, root):
        source = root/'inputs/A_domainfile.pddl'
        source.parent.mkdir()
        text='''(define (domain overlap) (:requirements :typing)
                (:types entity) (:predicates (entity ?x - entity)))'''
        source.write_text(text,encoding='utf-8')
        node=root/'fusion';node.mkdir()
        (node/'meta_domain.pddl').write_text(text,encoding='utf-8')
        meta={'sources':['A'],'predicate_maps':{'A':{'entity':'entity'}},
              'constant_maps':{'A':{}},'action_maps':{'A':{}}}
        (node/'meta_domain.json').write_text(json.dumps(meta),encoding='utf-8')
        validation={'valid':False,'errors':['authored namespace-policy failure fixture']}
        (node/'validation.json').write_text(json.dumps(validation),encoding='utf-8')
        (root/'manifest.json').write_text(json.dumps({'status':'worker_error',
            'source_sha256':{source.name:sha(source)}}),encoding='utf-8')
        terminal={'status':'worker_error','validation':validation,
                  'source_snapshot_unchanged':True,'implementation_unchanged':True}
        (root/'report.json').write_text(json.dumps(terminal),encoding='utf-8')
        return node,terminal

    def test_failed_root_requires_explicit_policy_and_remains_failed_candidate(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp);node,_=self.failed_fixture(root)
            with self.assertRaisesRegex(ValueError,'completed reference'):
                run(root,node,root/'default')
            result=run(root,node,root/'diagnostic',failed_final_candidate=True)
            self.assertEqual('failed_final_candidate_not_completed_reference',result['scope'])
            self.assertEqual('worker_error',result['failed_candidate_terminal_status'])
            self.assertEqual('ERROR',result['independent_domain_parse'])
            self.assertTrue((root/'diagnostic/failed_validation.json').is_file())
            self.assertTrue(result['snapshot_unchanged'])

    def test_active_mismatched_and_changed_candidates_are_rejected_before_snapshot(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp);node,terminal=self.failed_fixture(root)
            variants=[{**terminal,'status':'starting'},
                      {**terminal,'implementation_unchanged':False},
                      {**terminal,'validation':{'valid':True}}]
            for index,variant in enumerate(variants):
                (root/'report.json').write_text(json.dumps(variant),encoding='utf-8')
                output=root/str(index)
                with self.assertRaises(ValueError):
                    run(root,node,output,failed_final_candidate=True)
                self.assertFalse(output.exists())

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
            self.assertEqual({'unchanged_ordered_signature_only':2},result['parameter_transport_counts'])
            self.assertEqual({'shared':['p','q']},result['sources'][0]['mapping_categories']['predicates']['within_source_collisions'])
            self.assertEqual('VALID',result['independent_domain_parse'])
            bad=copy.deepcopy(meta);bad['action_maps']['A']['first']='absent'
            result=inspect(root,root/'merged.pddl',bad)
            self.assertEqual(1,result['action_counts']['missing_mapping_or_target'])

    def test_parameter_arity_and_formal_names_are_reported_without_inventing_a_binding(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp)
            source='''(define (domain a) (:types item) (:predicates (p ?x - item))
                (:action first :parameters (?x - item ?unused - item) :precondition (and) :effect (p ?x))
                (:action second :parameters (?x - item) :precondition (and) :effect (p ?x)))'''
            target='''(define (domain m) (:types item) (:predicates (p ?x - item))
                (:action first :parameters (?x - item) :precondition (and) :effect (p ?x))
                (:action second :parameters (?renamed - item) :precondition (and) :effect (p ?renamed)))'''
            (root/'A_domainfile.pddl').write_text(source,encoding='utf-8')
            (root/'target.pddl').write_text(target,encoding='utf-8')
            metadata={'sources':['A'],'predicate_maps':{'A':{'p':'p'}},
                'constant_maps':{'A':{}},'action_maps':{'A':{'first':'first','second':'second'}}}
            result=inspect(root,root/'target.pddl',metadata)
            self.assertEqual({'unverified_arity_change':1,'unverified_formal_name_or_order_change':1},result['parameter_transport_counts'])
            first=result['sources'][0]['actions'][0]
            self.assertEqual(2,first['source_parameter_count'])
            self.assertEqual(1,first['target_parameter_count'])
            self.assertNotIn('parameter_map',first)


if __name__=='__main__':
    unittest.main()

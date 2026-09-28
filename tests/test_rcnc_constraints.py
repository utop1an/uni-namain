import importlib.util
import json
import tempfile
import unittest
from pathlib import Path
from rcnc.constraints import allowed_parameters
from rcnc.lifting import run_lifted_query
from rcnc.planning import compile_query
from rcnc.validation import validate_artifacts

ROOT=Path(__file__).resolve().parents[1]
INPUT=ROOT/'data/narra-domains'
HAS_UP=importlib.util.find_spec('unified_planning') is not None

class ParameterConstraintTests(unittest.TestCase):
    def query(self):
        return {'actions':['PUSS:buy_boots'],'objects':{'hero':'entity','cloak':'item','shoe':'item'},
                'object_capabilities':{'shoe':['footwear']},'initial':[],
                'goal':{'positive':[['puss__has','hero','shoe']],'negative':[]},
                'parameter_constraints':{'PUSS:buy_boots':{'?boots':{
                    'required_capabilities':['footwear'],'evidence':'Explicit test assumption'}}}}

    def test_grounding_excludes_unsupported_object_without_changing_initial(self):
        q=self.query();actions,initial,*_=compile_query(q,INPUT)
        self.assertTrue(actions)
        self.assertEqual({'shoe'},{a.binding['?boots'] for a in actions})
        self.assertFalse(initial)
        q['object_capabilities']={}
        self.assertFalse(compile_query(q,INPUT)[0])

    def test_unknown_parameter_or_missing_evidence_is_rejected(self):
        q=self.query();q['parameter_constraints']['PUSS:buy_boots']['?typo']={'evidence':'test'}
        with self.assertRaisesRegex(ValueError,'Unknown constrained parameter'):allowed_parameters(q,INPUT)
        q=self.query();q['parameter_constraints']['PUSS:buy_boots']['?boots'].pop('evidence')
        with self.assertRaisesRegex(ValueError,'evidence'):allowed_parameters(q,INPUT)

    def test_allowed_objects_cannot_widen_types(self):
        q=self.query();q['parameter_constraints']['PUSS:buy_boots']['?boots']['allowed_objects']=['hero']
        with self.assertRaisesRegex(ValueError,'Ill-typed'):allowed_parameters(q,INPUT)

    @unittest.skipUnless(HAS_UP,'Install requirements-planning.txt')
    def test_parameterized_guard_blocks_semantically_disallowed_plan(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td)
            (root/'T_domainfile.pddl').write_text('''(define (domain t)
            (:requirements :strips :typing) (:types entity item - object)
            (:constants c - entity) (:predicates (ready ?e - entity) (has ?i - item) (done))
            (:action acquire :parameters (?i - item) :precondition (ready c) :effect (has ?i))
            (:action finish :parameters (?i - item) :precondition (has ?i) :effect (done)))''')
            q={'actions':['T:acquire','T:finish'],'objects':{'hero':'entity','good':'item','bad':'item'},
               'initial':[['t__ready','hero']],'goal':{'positive':[['t__done']],'negative':[]},
               'lifted_constants':{'T:c':{'role':'owner','allowed_objects':['hero'],'evidence':'Test owner'}},
               'object_capabilities':{'good':['key']},'source_removal_scope':'all_solved',
               'parameter_constraints':{'T:acquire':{'?i':{'required_capabilities':['key'],'evidence':'Test capability'}}},
               'require_external_validation':True}
            r=run_lifted_query(q,root,root/'out')
            self.assertEqual('solved',r['status'])
            self.assertEqual([{'source':'T','necessary_across_declared_assignments':True}],r['source_necessity_across_assignments'])
            folder=root/'out'/r['best']['directory']/'lifted'
            info=json.loads((folder/'lifting.json').read_text())
            self.assertEqual([['t__ready','hero']],info['narrative_initial'])
            self.assertTrue(any(f[0].startswith('rcnc_allowed_') for f in info['administrative_initial_facts']))
            text=(folder/'plan.txt').read_text().replace('good','bad')
            (folder/'plan.txt').write_text(text)
            self.assertEqual('INVALID',validate_artifacts(folder)['status'])

if __name__=='__main__':unittest.main()

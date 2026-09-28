import copy
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path
from rcnc.lifting import role_domains, run_lifted_query
from rcnc.validation import validate_artifacts
from merge_domains import parse_sexpr, section

ROOT=Path(__file__).resolve().parents[1]
INPUT=ROOT/'data/narra-domains'
HAS_UP=importlib.util.find_spec('unified_planning') is not None

class LiftingTests(unittest.TestCase):
    def query(self):
        return json.loads((ROOT/'data/rcnc/queries/lifting_smoke.json').read_text())

    def test_wrong_type_and_unproven_capability_rejected(self):
        q=self.query();q['lifted_constants']['BIRT:bench']['allowed_objects']=['hero']
        with self.assertRaisesRegex(ValueError,'Ill-typed'):role_domains(q,INPUT)
        q=self.query();q['object_capabilities']['helper']=[]
        with self.assertRaisesRegex(ValueError,'capabilities'):role_domains(q,INPUT)

    def test_fixed_and_lifted_identity_cannot_conflict(self):
        q=self.query();q['constant_bindings']['BIRT:bench']='bench'
        with self.assertRaisesRegex(ValueError,'both fixed and lifted'):role_domains(q,INPUT)

    def fixture(self,folder,consistent=False):
        (folder/'T_domainfile.pddl').write_text('''(define (domain test)
          (:requirements :strips :typing)
          (:types person - object) (:constants c d - person)
          (:predicates (p ?x - person) (q ?x - person) (ready) (done))
          (:action mark :parameters () :precondition (p c) :effect (ready))
          (:action finish :parameters () :precondition (and (ready) (q c)) :effect (done)))''')
        return {'actions':['T:mark','T:finish'],'objects':{'x':'person','y':'person'},
                'initial':[['t__p','x'],['t__q','x' if consistent else 'y']],
                'goal':{'positive':[['t__done']],'negative':[]},
                'lifted_constants':{'T:c':{'role':'person','allowed_objects':['x','y'],'evidence':'Test role'}},
                'require_external_validation':True}

    def test_global_identity_cannot_switch_between_steps(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);q=self.fixture(root)
            result=run_lifted_query(q,root,root/'out')
            self.assertEqual('unsolvable',result['status'])
            self.assertEqual(['unsolvable','unsolvable'],[x['status'] for x in result['attempts']])

    def test_assignment_budget_is_not_unsolvability(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);q=self.fixture(root);q['max_role_assignments']=1
            result=run_lifted_query(q,root,root/'out')
            self.assertEqual('inconclusive',result['status'])
            self.assertFalse(result['assignment_space_exhausted'])

    def test_distinct_roles_prevent_identity_collapse(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);q=self.fixture(root)
            q['lifted_constants']['T:c']['allowed_objects']=['x']
            q['lifted_constants']['T:d']={'role':'other','allowed_objects':['x'],'evidence':'Distinct character'}
            q['distinct_roles']=[['person','other']]
            result=run_lifted_query(q,root,root/'out')
            self.assertEqual('unsolvable',result['status'])
            self.assertEqual('constraint_rejected',result['attempts'][0]['status'])

    @unittest.skipUnless(HAS_UP,'Install requirements-planning.txt')
    def test_parameterized_pddl_preserves_initial_and_rejects_role_switch(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);q=self.fixture(root,consistent=True);original=copy.deepcopy(q)
            result=run_lifted_query(q,root,root/'out')
            self.assertEqual('solved',result['status'])
            self.assertEqual(q,original)
            selected=root/'out'/result['best']['directory']/'lifted'
            problem=parse_sexpr((selected/'problem.pddl').read_text())
            facts=section(problem,':init')[1:]
            narrative=[f for f in facts if not f[0].startswith('rcnc_role_')]
            self.assertEqual({tuple(f) for f in q['initial']},{tuple(f) for f in narrative})
            lines=(selected/'plan.txt').read_text().splitlines()
            self.assertIn(' x)',lines[1])
            lines[1]=lines[1].replace(' x)',' y)')
            (selected/'plan.txt').write_text('\n'.join(lines)+'\n')
            self.assertEqual('INVALID',validate_artifacts(selected)['status'])

if __name__=='__main__':unittest.main()

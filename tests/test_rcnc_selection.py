import copy
import importlib.util
import json
import random
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from rcnc.planning import GroundAction, solve, run_query
from rcnc.selection import relevant_actions, resolve_sources
from rcnc.validation import validate_artifacts

ROOT=Path(__file__).resolve().parents[1]
INPUT=ROOT/'data/narra-domains'
BASE=ROOT/'data/rcnc/queries/source_pool_smoke.json'
HAS_UP=importlib.util.find_spec('unified_planning') is not None

class SelectionTests(unittest.TestCase):
    def test_automatic_pool_includes_alternative_move(self):
        q=json.loads(BASE.read_text());original=copy.deepcopy(q)
        resolved,audit=resolve_sources(q,INPUT)
        self.assertIn('BIRT:travel_to_trysting_place',resolved['actions'])
        self.assertGreater(audit['source_actions'],len(resolved['actions']))
        self.assertEqual(q,original)

    def test_negative_precondition_requires_delete_support(self):
        p=frozenset({('p',)}); q=frozenset({('q',)});empty=frozenset()
        delete=GroundAction('d','A','delete',{},p,empty,empty,p)
        achieve=GroundAction('a','B','achieve',{},empty,p,q,empty)
        reduced,_=relevant_actions([delete,achieve],p,q,empty)
        status,plan,_=solve(reduced,p,q,empty)
        self.assertEqual('solved',status);self.assertEqual(2,len(plan))

    def test_initial_fact_achiever_retained_for_threat_repair(self):
        p=frozenset({('p',)});q=frozenset({('q',)});empty=frozenset()
        restore=GroundAction('r','A','restore',{},empty,empty,p,empty)
        use=GroundAction('u','B','use',{},p,empty,q,empty)
        reduced,_=relevant_actions([restore,use],p,q,empty)
        self.assertIn(restore,reduced)

    def test_relevance_preserves_small_signed_strips_optima(self):
        rng=random.Random(20260913);facts=[('p',),('q',),('r',)]
        for _ in range(60):
            def subset(): return frozenset(f for f in facts if rng.randrange(2))
            actions=[]
            for i in range(6):
                pos=subset();neg=subset()-pos;add=subset();delete=subset()-add
                actions.append(GroundAction(str(i),'S',str(i),{},pos,neg,add,delete))
            initial=subset();goal=subset();ng=subset()-goal
            reduced,_=relevant_actions(actions,initial,goal,ng)
            a=solve(actions,initial,goal,ng,max_depth=20);b=solve(reduced,initial,goal,ng,max_depth=20)
            self.assertEqual(a[0],b[0])
            if a[1] is not None:self.assertEqual(len(a[1]),len(b[1]))

    @unittest.skipUnless(HAS_UP,'Install requirements-planning.txt for independent validation')
    def test_external_validator_accepts_real_plan_and_rejects_missing_step(self):
        q=json.loads(BASE.read_text())
        with tempfile.TemporaryDirectory() as td:
            out=Path(td);r=run_query(q,INPUT,out)
            self.assertEqual('solved',r['status'])
            self.assertEqual('VALID',r['external_validation']['status'])
            self.assertEqual(3,r['plan_length'])
            lines=(out/'plan.txt').read_text().splitlines()
            (out/'plan.txt').write_text('\n'.join(lines[1:])+'\n')
            self.assertEqual('INVALID',validate_artifacts(out)['status'])

    def test_missing_required_validator_cannot_report_success(self):
        q=json.loads(BASE.read_text())
        with tempfile.TemporaryDirectory() as td, patch('rcnc.validation.validate_artifacts',return_value={'status':'UNAVAILABLE'}):
            r=run_query(q,INPUT,Path(td))
            self.assertEqual('external_validation_unavailable',r['status'])

if __name__=='__main__':unittest.main()

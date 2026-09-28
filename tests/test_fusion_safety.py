import copy,json,tempfile,unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch
from merge_domains import Domain,Predicate,parse_domain,validate_domain
from unidomain_ollama_fusion import fuse_pair
from rcnc.planning import run_query
from build_narrative_union import build
ROOT=Path(__file__).resolve().parents[1]

class FusionSafetyTests(unittest.TestCase):
 def domain(self,source,constant):
  return Domain(source,{':strips',':typing'},{'person':'object'},{constant:'person'},
   {'ready':Predicate('ready',[('?p','person')])},
   {'act':[':action','act',':parameters',['?p','-','person'],':precondition',['ready','?p'],':effect',['ready','?p']]},
   {source},{source:{'ready':'ready'}},{source:{constant:constant}},{source:{'act':'act'}})
 def runtime(self,operator=None,predicate=None):
  def call(task,prompt,schema,validator):
   if task=='check_merge_predicates':return predicate or {'merge_flag':False}
   if task=='update_action_string':return {'updated_action':'(:action act :parameters (?p - person) :precondition (joined ?missing) :effect (joined ?p))'}
   return operator or {'merge_flag':False}
  return SimpleNamespace(llm=SimpleNamespace(call=call,model='synthetic-test'),
    predicate_candidates=lambda p,others:[(name,1) for name in others],
    action_candidates=lambda n,others:[(name,1) for name in others])
 def test_case_collisions_and_rejected_same_names_preserve_both_sources(self):
  d=fuse_pair(self.domain('A','King'),self.domain('B','king'),self.runtime())
  self.assertEqual([],validate_domain(d));self.assertEqual(2,len(d.constants))
  self.assertEqual(2,len(d.actions));self.assertEqual(2,len(d.predicates))
  self.assertNotEqual(d.constant_maps['A']['King'].lower(),d.constant_maps['B']['king'].lower())
  self.assertNotEqual(d.action_maps['A']['act'],d.action_maps['B']['act'])
 def test_bad_operator_does_not_replace_sources(self):
  r={'merge_flag':True,'new_operator_name':'joined','new_operator':'(:action joined :parameters (?p - person) :precondition (ready ?missing) :effect (ready ?p))','reasoning':'test'}
  d=fuse_pair(self.domain('A','a'),self.domain('B','b'),self.runtime(operator=r))
  self.assertEqual(2,len(d.actions));self.assertEqual([],validate_domain(d))
  self.assertTrue(any(x['kind']=='rejected_operator_merge' for x in d.decisions))
 def test_bad_predicate_update_rolls_back_both_sides(self):
  r={'merge_flag':True,'new_predicate':['(joined ?q - person)','test'],'reasoning':'test'}
  left=self.domain('A','a');right=self.domain('B','b');before=copy.deepcopy(left)
  d=fuse_pair(left,right,self.runtime(predicate=r))
  self.assertEqual(before,left);self.assertEqual(2,len(d.predicates));self.assertEqual([],validate_domain(d))
  self.assertTrue(any(x['kind']=='rejected_predicate_merge' for x in d.decisions))
 def test_validator_rejects_historical_structural_failures(self):
  d=parse_domain(ROOT/'data/merged_strict/meta_domain.pddl',apply_reviewed_semantics=False)
  errors='\n'.join(validate_domain(d))
  for expected in ('case-insensitive duplicate king','undeclared symbol ?h','wrong arity dead','ill-typed captured'):
   self.assertIn(expected,errors)
 def test_quantified_source_actions_remain_supported(self):
  for p in (ROOT/'data/narra-domains').glob('*_domainfile.pddl'):
   self.assertEqual([],validate_domain(parse_domain(p,apply_reviewed_semantics=False)),p.name)
 def test_missing_initial_requests_input_without_compiling(self):
  with tempfile.TemporaryDirectory() as td,patch('rcnc.planning.compile_query',side_effect=AssertionError('must not compile')):
   r=run_query({'goal':{'positive':[]}},ROOT/'data/narra-domains',Path(td)/'out')
   self.assertEqual('needs_initial_state',r['status'])
 def test_constant_rename_does_not_rewrite_same_spelled_predicate(self):
  from merge_domains import rewrite_problem
  d=self.domain('A','ready');d.constant_maps={'A':{'ready':'a_object'}}
  with tempfile.TemporaryDirectory() as td:
   root=Path(td);p=root/'A_problemfile.pddl';p.write_text('(define (problem p) (:domain A) (:init (ready ready)) (:goal (ready ready)))')
   rewrite_problem(p,d,root/'out.pddl')
   text=(root/'out.pddl').read_text();self.assertIn('(ready a_object)',text);self.assertNotIn('(a_object a_object)',text)
 def test_union_keeps_case_distinct_source_identities(self):
  with tempfile.TemporaryDirectory() as td:
   root=Path(td);inputs=root/'in';inputs.mkdir()
   for name,constant in [('A','King'),('B','king')]:
    (inputs/f'{name}_domainfile.pddl').write_text(f'(define (domain {name}) (:requirements :strips :typing) (:types person - object) (:constants {constant} - person) (:predicates (ready ?p - person)) (:action act :parameters () :precondition (and) :effect (ready {constant})))')
    (inputs/f'{name}_problemfile.pddl').write_text(f'(define (problem p) (:domain {name}) (:init) (:goal (ready {constant})))')
   r=build(inputs,root/'out');self.assertTrue(r['valid']);self.assertEqual(2,r['counts']['operators']);self.assertEqual(2,r['counts']['constants'])
   from validate_narrative_pipeline import bounded_plan
   for name in ('A','B'):
    original=bounded_plan(inputs/f'{name}_domainfile.pddl',inputs/f'{name}_problemfile.pddl',root/(name+'_original'))
    mapped=bounded_plan(root/'out/meta_domain.pddl',root/'out/problems'/f'{name}_problemfile.pddl',root/(name+'_mapped'))
    self.assertEqual(original['length'],mapped['length'])
    self.assertEqual('VALID',mapped['validation']['status'])
   with self.assertRaisesRegex(ValueError,'empty'):build(inputs,root/'out')

if __name__=='__main__':unittest.main()

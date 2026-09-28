import copy,json,tempfile,unittest
from pathlib import Path
from rcnc.semantic_proposals import source_pack,check_proposal,evaluate_response,run_proposals,generation_schema
ROOT=Path(__file__).resolve().parents[1]

class SemanticProposalTests(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.pack=source_pack(ROOT/'data/narra-domains',['BIRT','PUSS'])
 def proposal(self):
  ref='PUSS:action:buy_boots'
  return {'kind':'parameter','refs':[ref],'parameter':'?boots','label':'footwear','confidence':'low',
   'rationale':'Name suggests footwear, but this is not entailed by the item type.',
   'evidence':[{'ref':ref,'quote':self.pack['records'][ref]['text']}]}
 def test_kind_specific_schema_excludes_other_record_kinds(self):
  schema=generation_schema(self.pack["records"],"interface")
  branches=schema["properties"]["proposals"]["items"]["anyOf"]
  self.assertEqual(1,len(branches))
  props=branches[0]["properties"]
  self.assertEqual(["interface"],props["kind"]["enum"])
  self.assertTrue(all(":predicate:" in ref for ref in props["refs"]["items"]["enum"]))
 def test_valid_proposal_remains_unverified(self):
  r=evaluate_response({'proposals':[self.proposal()]},self.pack)
  self.assertEqual(1,r['summary']['structurally_valid']);self.assertEqual(0,r['summary']['semantically_verified'])
  self.assertIn('?boots',r['draft_registry']['parameter_constraints']['PUSS:buy_boots'])
 def test_fabricated_quote_and_unknown_parameter_rejected(self):
  p=self.proposal();p['evidence'][0]['quote']='requires payment and footwear'
  self.assertIn('quote_not_in_source',check_proposal(p,self.pack['records']))
  p=self.proposal();p['parameter']='?unknown'
  self.assertIn('unknown_parameter',check_proposal(p,self.pack['records']))
 def test_incompatible_interface_or_missing_side_citation_rejected(self):
  refs=['BIRT:predicate:at','PUSS:predicate:has']
  p={'kind':'interface','refs':refs,'parameter':'','label':'shared','confidence':'high','rationale':'Test',
     'evidence':[{'ref':r,'quote':self.pack['records'][r]['text']} for r in refs]}
  self.assertIn('incompatible_ordered_types',check_proposal(p,self.pack['records']))
  p['evidence'].pop();self.assertIn('uncited_reference',check_proposal(p,self.pack['records']))
 def test_replay_has_explicit_provenance_and_no_planner_inputs(self):
  with tempfile.TemporaryDirectory() as td:
   root=Path(td);response=root/'response.json';response.write_text(json.dumps({'proposals':[self.proposal()]}))
   r=run_proposals(ROOT/'data/narra-domains',['BIRT','PUSS'],root/'out',response_path=response)
   self.assertEqual('completed',r['status']);self.assertEqual('replay',r['run']['mode'])
   self.assertEqual({'records','source_sha256'},set(self.pack))
   self.assertTrue((root/'out/draft_registry.json').exists())

if __name__=='__main__':unittest.main()

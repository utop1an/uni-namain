import copy
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from rcnc.interface_proposals import (build_candidates, pair_input, check_judgment,
    draft_interfaces, run_interfaces, write_json, response_schema)

ROOT = Path(__file__).resolve().parents[1]

class InterfaceProposalTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.manifest = build_candidates(ROOT/'data/narra-domains', ['BIRT','PUSS'], 8)
        cls.pair = cls.manifest['candidates'][0]
        cls.context = pair_input(cls.pair, cls.manifest['source_pack']['records'])

    def judgment(self):
        evidence = []
        for side in self.pair['sides']:
            ref = side['usage'][0]['record']
            evidence.append({'ref':ref, 'quote':self.context['records'][ref]['text']})
        return {'candidate_id':self.pair['id'], 'decision':'accept', 'relation':'equivalent',
                'alignment':'same_order', 'rationale':'Synthetic test judgment, not a gold annotation.',
                'evidence':evidence}

    def test_candidates_are_cross_source_typed_deterministic_and_budgeted(self):
        m = self.manifest
        self.assertEqual(m, build_candidates(ROOT/'data/narra-domains', ['PUSS','BIRT','BIRT'], 8))
        self.assertGreater(m['omitted_pairs'], 0)
        self.assertEqual(m['total_compatible_pairs'], len(m['candidates'])+m['omitted_pairs'])
        self.assertTrue(m['candidates'][0]['same_name'])
        for pair in m['candidates']:
            a,b = pair['refs']; records=m['source_pack']['records']
            self.assertNotEqual(a.split(':')[0],b.split(':')[0])
            self.assertEqual(records[a]['types'],records[b]['types'])

    def test_context_retains_argument_order_polarity_and_full_action(self):
        found = [u for side in self.pair['sides'] for u in side['usage']
                 if u['section']==':effect' and u['negated']]
        self.assertTrue(found)
        for u in found:
            self.assertIn(':precondition',self.context['records'][u['record']]['text'])
            self.assertEqual(2,len(u['arguments']))
        self.assertEqual({'candidate','records'},set(self.context))

    def test_direction_mismatch_cannot_be_accepted(self):
        r=self.judgment()
        self.assertEqual([],check_judgment(r,self.pair,self.context['records']))
        r['alignment']='different_order'
        self.assertIn('accept_requires_equivalence_and_same_order',check_judgment(r,self.pair,self.context['records']))
        r['decision']='reject'
        self.assertEqual([],check_judgment(r,self.pair,self.context['records']))

    def test_fabricated_or_one_sided_or_declaration_only_evidence_rejected(self):
        for mode in ('fabricated','one_side','declaration_only'):
            r=self.judgment()
            if mode=='fabricated':r['evidence'][0]['quote']='fabricated quotation'
            elif mode=='one_side':r['evidence'].pop()
            else:r['evidence']=[{'ref':ref,'quote':self.context['records'][ref]['text']} for ref in self.pair['refs']]
            self.assertTrue(check_judgment(r,self.pair,self.context['records']),mode)

    def test_abstention_and_malformed_response(self):
        r=self.judgment();r.update(decision='uncertain',relation='unknown',alignment='unknown',evidence=[])
        self.assertEqual([],check_judgment(r,self.pair,self.context['records']))
        for invalid in (None,[],{'decision':[]},{'evidence':[{'ref':[]}]}):
            self.assertTrue(check_judgment(invalid,self.pair,self.context['records']))

    def test_overlapping_acceptances_withheld_without_transitive_merge(self):
        a=copy.deepcopy(self.pair);b=copy.deepcopy(a);b['id']='other';b['refs'][1]='C:predicate:at'
        rows=[{'candidate_id':p['id'],'status':'checked','response':self.judgment()} for p in (a,b)]
        draft=draft_interfaces(rows,{p['id']:p for p in (a,b)})
        self.assertEqual({},draft['interfaces']);self.assertEqual(2,len(draft['withheld']))
        one=draft_interfaces(rows[:1],{a['id']:a})
        self.assertEqual(2,len(one['interfaces']))
        self.assertIn('not_semantically_validated',one['status'])

    def test_offline_replay_checks_source_identity_and_does_not_call_network(self):
        m=build_candidates(ROOT/'data/narra-domains',['BIRT','PUSS'],1)
        with tempfile.TemporaryDirectory() as td, patch('urllib.request.urlopen',side_effect=AssertionError('Network forbidden')):
            base=Path(td);old=base/'old';old.mkdir()
            write_json(old/'candidates.json',m);write_json(old/'report.json',{'run':{'model_digest':'original'}})
            sub=old/m['candidates'][0]['id'];sub.mkdir();write_json(sub/'response.json',self.judgment())
            r=run_interfaces(ROOT/'data/narra-domains',['BIRT','PUSS'],base/'out',max_pairs=1,replay_dir=old)
            self.assertEqual('completed',r['status']);self.assertEqual('replay',r['run']['mode'])
            self.assertEqual(1,r['summary']['draft_pairs']);self.assertEqual(0,r['summary']['semantically_verified'])
            m['source_pack']['source_sha256']['BIRT_domainfile.pddl']='changed'
            write_json(old/'candidates.json',m)
            bad=run_interfaces(ROOT/'data/narra-domains',['BIRT','PUSS'],base/'bad',max_pairs=1,replay_dir=old)
            self.assertEqual('failed',bad['status']);self.assertIn('mismatch',bad['error'])

    def test_generated_evidence_options_are_actual_candidate_literals(self):
        schema=response_schema(self.pair,self.context['records'])
        branches=schema['properties']['evidence']['items']['anyOf']
        for branch in branches:
            props=branch['properties']; ref=props['ref']['enum'][0]
            self.assertIn(':action:',ref)
            for quote in props['quote']['enum']:
                self.assertIn(quote,self.context['records'][ref]['text'])
        r=self.judgment();r['evidence'][0]['quote']=':parameters'
        self.assertIn('evidence_does_not_cover_candidate_literal',
                      check_judgment(r,self.pair,self.context['records']))

    def test_transport_failures_are_not_semantic_rejections(self):
        with tempfile.TemporaryDirectory() as td:
            # Avoid a network call: supply a matching replay manifest but no answer.
            base=Path(td);old=base/'old';old.mkdir()
            m=build_candidates(ROOT/'data/narra-domains',['BIRT','PUSS'],1)
            write_json(old/'candidates.json',m);write_json(old/'report.json',{'run':{}})
            with patch('urllib.request.urlopen',side_effect=AssertionError('Network forbidden')):
                r=run_interfaces(ROOT/'data/narra-domains',['BIRT','PUSS'],base/'out',max_pairs=1,replay_dir=old)
            self.assertEqual('partial_failure',r['status'])
            self.assertEqual(1,r['summary']['failed'])
            self.assertEqual({},r['summary']['decisions'])

    def test_unsupported_context_is_excluded_not_flattened(self):
        with tempfile.TemporaryDirectory() as td:
            folder=Path(td)
            for name in ('A','B'):
                (folder/f'{name}_domainfile.pddl').write_text('''(define (domain example)
                  (:requirements :strips :typing) (:types entity - object)
                  (:predicates (p ?a - entity) (q ?a - entity))
                  (:action forbidden :parameters (?x - entity)
                   :precondition (or (p ?x) (q ?x)) :effect (p ?x)))''',encoding='utf-8')
            m=build_candidates(folder,['A','B'],10)
            self.assertEqual(2,len(m['excluded_context_actions']))
            self.assertTrue(all(not side['usage'] for pair in m['candidates'] for side in pair['sides']))

if __name__=='__main__':unittest.main()

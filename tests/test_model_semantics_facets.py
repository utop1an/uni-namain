import copy
import json
from pathlib import Path
import tempfile
import unittest

from rcnc.model_semantics import context, prepare, run, to_group
from rcnc.model_semantics_facets import normalize
from rcnc.conditional_merge import build
from tests.test_conditional_merge import fixture


def response(item):
    n=len(item['sides'][0]['parameters'])
    return dict(left_meaning='Actor location or its change', right_meaning='Actor location or its change',
        concept='relocation' if n==3 else 'location',scope='physical_location',
        relation='same_event_variant' if item['kind']=='action' else 'same_relation',
        difference_kind='preconditions_only' if item['kind']=='action' else 'none',
        roles_correspond=True,counterexample_found=False,separating_example='none',
        canonical_roles=['actor','origin','destination'] if n==3 else ['actor','place'],
        left_order=list(range(n)),right_order=[1,2,0] if n==3 else list(range(n)),
        left_evidence=item['sides'][0]['contexts'][0]['id'],right_evidence=item['sides'][1]['contexts'][0]['id'],
        confidence=1,rationale='The roles and event correspond; applicability is separate.')


class SemanticFacetsTests(unittest.TestCase):
    def test_counterexample_vetoes_even_positive_relation(self):
        item={'kind':'predicate','sides':[{'parameters':[1],'contexts':[]},{'parameters':[1],'contexts':[]}]}
        r=response({**item,'sides':[{'parameters':[1],'contexts':[{'id':'a'}]},{'parameters':[1],'contexts':[{'id':'b'}]}]})
        r.update(counterexample_found=True,separating_example='One property can hold without the other.')
        self.assertEqual('different',normalize(item,r)['decision'])
        r['counterexample_found']='false'
        with self.assertRaises(ValueError):normalize(item,r)

    def test_applicability_difference_does_not_veto_same_event(self):
        with tempfile.TemporaryDirectory() as td:
            inputs,_,_=fixture(Path(td))
            item={'kind':'action','sides':[context(inputs,r,'action') for r in ['A:walk','B:travel']]}
            r=response(item)
            self.assertEqual('compatible',normalize(item,r)['decision'])
            r['roles_correspond']=False
            self.assertEqual('different',normalize(item,r)['decision'])

    def test_model_path_hides_control_ids_and_performs_real_merge(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td); inputs,spec,_=fixture(root)
            pairs=[{'id':'location_bad_alias','kind':'predicate','references':['A:at','B:located']},
                   {'id':'travel_positive','kind':'action','references':['A:walk','B:travel']}]
            prepare(inputs,pairs,root/'model',model_digest='fixed',schema_policy='semantic_facets')
            def transport(url,payload=None,timeout=None):
                if payload is None:return {'models':[{'name':'gemma3:4b','digest':'fixed'}]}
                content=payload['messages'][0]['content'];self.assertNotIn('bad_alias',content)
                item=json.loads(content.splitlines()[-1]);self.assertNotIn('id',item)
                return {'done':True,'done_reason':'stop','message':{'content':json.dumps(response(item))}}
            result=run(root/'model',transport=transport)
            self.assertEqual({'checked':2},result['status_counts'])
            groups=json.loads((root/'model/groups.json').read_text())['groups']
            spec.update(predicate_candidates=groups[:1],action_candidates=groups[1:])
            merged=build(inputs,root/'merged',spec)
            self.assertEqual(1,merged['merged_action_groups'])

    def test_unknown_or_inconsistent_predicate_does_not_merge(self):
        with tempfile.TemporaryDirectory() as td:
            inputs,_,_=fixture(Path(td))
            item={'kind':'predicate','sides':[context(inputs,r,'predicate') for r in ['A:at','B:located']]}
            for changes in [dict(relation='uncertain'),dict(difference_kind='preconditions_only')]:
                r=response(item);r.update(changes)
                self.assertEqual('uncertain',normalize(item,r)['decision'])


if __name__=='__main__':unittest.main()

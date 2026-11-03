import copy
from itertools import combinations
from pathlib import Path
import tempfile
import unittest

from rcnc.conditional_merge import symbol_digest
from rcnc.glaive_merge import Source,build,map_problem,translate_plan
from rcnc.revised_multistory import select_groups
from rcnc.saved_plan_validation import replay_saved


def fixture(root,n=4):
    sources=[]
    for i in range(n):
        sid='s'+str(i);d=root/(sid+'.pddl');p=root/(sid+'_problem.pddl')
        d.write_text(f'''(define (domain {sid}) (:requirements :adl :intentionality)
          (:types person place - object) (:predicates (at ?who - person ?where - place))
          (:action travel :parameters (?who - person ?from ?to - place)
           :precondition (at ?who ?from) :effect (and (not (at ?who ?from)) (at ?who ?to)) :agents (?who)))''',encoding='utf-8')
        p.write_text(f'''(define (problem {sid}) (:domain {sid}) (:objects alice - person home away - place)
          (:init (at alice home) (intends alice (at alice away))) (:goal (at alice away)))''',encoding='utf-8')
        sources.append(Source(sid,d,p))
    groups=[]
    for kind,name,roles in [('predicate','at',['actor','place']),('action','travel',['actor','origin','destination'])]:
        for a,b in combinations(sources,2):
            members=[]
            for s in (a,b):
                value=s.domain.predicates[name] if kind=='predicate' else s.domain.actions[name]
                members.append({kind:s.id+':'+name,'order':list(range(len(roles))),
                    'semantics':{'concept':'location' if kind=='predicate' else 'relocate','scope':'physical',
                        'roles':roles[:],'confidence':1.0,'evidence':[s.id+':travel'],'symbol_sha256':symbol_digest(value)}})
            groups.append({'id':kind+'_'+a.id+'_'+b.id,'members':members,'model_judgment':{'decision':'compatible'}})
    return sources,groups


class RevisedMultistoryTests(unittest.TestCase):
    def test_four_source_cluster_and_all_original_transports(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);sources,raw=fixture(root)
            predicates,_=select_groups(sources,raw,'predicate');self.assertEqual(len(predicates[0]['members']),4)
            pred=build(sources,root/'pred',groups=predicates)
            actions,_=select_groups(sources,raw,'action',predicate_maps=pred['predicate_maps'])
            self.assertEqual(len(actions[0]['members']),4)
            full=build(sources,root/'full',groups=predicates+actions,merge_actions=True)
            self.assertEqual(full['action_count'],1);self.assertEqual(full['predicate_maps'],pred['predicate_maps'])
            for s in sources:
                problem=root/(s.id+'_mapped.pddl');terms=map_problem(sources,s.id,full,problem)
                plan=root/(s.id+'_plan.pddl');plan.write_text(f'(define (plan p) (:problem {s.id}) (:steps (travel alice home away)))',encoding='utf-8')
                translated=root/(s.id+'_translated.pddl');translate_plan(s.id,full,terms,plan,translated)
                self.assertTrue(replay_saved(root/'full/domain.pddl',problem,translated)['goal'])

    def test_missing_edge_does_not_create_transitive_merge(self):
        with tempfile.TemporaryDirectory() as td:
            sources,raw=fixture(Path(td),3);raw=[g for g in raw if g['id']!='predicate_s0_s2']
            groups,_=select_groups(sources,raw,'predicate')
            self.assertEqual(max(len(g['members']) for g in groups),2)

    def test_role_cycle_conflict_rejects_triple(self):
        with tempfile.TemporaryDirectory() as td:
            sources,raw=fixture(Path(td),3)
            edge=next(g for g in raw if g['id']=='predicate_s0_s2')
            edge['members'][1]['order']=[1,0];edge['members'][1]['semantics']['roles']=['place','actor']
            groups,audit=select_groups(sources,raw,'predicate')
            self.assertTrue(all(len(g['members'])==2 for g in groups))
            self.assertIn('inconsistent_role_cycle',[c.get('reason') for c in audit['checks']])

    def test_conflicting_concepts_reject_triple(self):
        with tempfile.TemporaryDirectory() as td:
            sources,raw=fixture(Path(td),3)
            edge=next(g for g in raw if g['id']=='predicate_s0_s2')
            for m in edge['members']:m['semantics']['concept']='different_specific_concept'
            groups,_=select_groups(sources,raw,'predicate');self.assertTrue(all(len(g['members'])==2 for g in groups))

    def test_input_order_and_raw_judgments_unchanged(self):
        with tempfile.TemporaryDirectory() as td:
            sources,raw=fixture(Path(td));before=copy.deepcopy(raw)
            a=select_groups(sources,raw,'predicate');b=select_groups(sources[::-1],raw[::-1],'predicate')
            self.assertEqual(a,b);self.assertEqual(raw,before)

    def test_source_local_predicates_prevent_false_action_fusion(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);sources,raw=fixture(root,3);union=build(sources,root/'union')
            actions,audit=select_groups(sources,raw,'action',predicate_maps=union['predicate_maps'])
            self.assertEqual(actions,[])
            self.assertIn('different_mapped_signed_effects',[x.get('reason') for x in audit['checks']])

    def test_clique_budget_fails_closed(self):
        with tempfile.TemporaryDirectory() as td:
            sources,raw=fixture(Path(td))
            with self.assertRaisesRegex(ValueError,'budget_exhausted'):select_groups(sources,raw,'predicate',max_cliques=1)


if __name__=='__main__':unittest.main()

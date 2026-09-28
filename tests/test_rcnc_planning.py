import copy
import json
import tempfile
import unittest
from pathlib import Path
from rcnc.planning import GroundAction, compile_query, replay, solve, run_query
from rcnc.experiment import Literal, ActionFrame, build_causal_edges, unsupported_logic, extract_domain_frames, iter_raw_literals
from merge_domains import parse_domain, parse_sexpr, section

ROOT = Path(__file__).resolve().parents[1]
INPUT = ROOT/'data/narra-domains'
QUERY = ROOT/'data/rcnc/queries/fixed_initial_smoke.json'

class PlanningTests(unittest.TestCase):
    def query(self):
        return json.loads(QUERY.read_text(encoding='utf-8-sig'))

    def test_negative_precondition_is_not_supported_by_add(self):
        def literal(negative):
            return Literal('p', ('?x',), ('entity',), negative, 'attribute:p/1', 'attribute')
        producer = ActionFrame('a','make','X',{}, {}, [], [literal(False)], [])
        consumer = ActionFrame('b','use','X',{}, {}, [literal(True)], [], [])
        self.assertEqual([], build_causal_edges([producer, consumer]))

    def test_direct_literal_extraction_cannot_flatten_conditional_effects(self):
        with self.assertRaisesRegex(ValueError, 'Unsupported logic'):
            list(iter_raw_literals(['when',['p','?x'],['q','?x']]))
        self.assertTrue(unsupported_logic(['not', [['p']]]))

    def test_non_strips_quarantined(self):
        for op in ('when','or','exists','forall','='):
            self.assertTrue(unsupported_logic([op,['p','?x'],['q','?x']]))
        domain = parse_domain(INPUT/'HANS_NP_domainfile.pddl', apply_reviewed_semantics=False)
        _, actions, _ = extract_domain_frames(domain)
        self.assertLess(len(actions), len(domain.actions))

    def test_real_source_four_step_plan_and_fixed_initial_state(self):
        q = self.query(); original = copy.deepcopy(q)
        actions, initial, goal, negative, *_ = compile_query(q, INPUT)
        status, plan, _ = solve(actions, initial, goal, negative)
        self.assertEqual('solved', status)
        self.assertEqual(4, len(plan))
        self.assertEqual({'BIRT','CHIC_NP'}, {a.source for a in plan})
        self.assertTrue(replay(plan, initial, goal, negative)['valid'])
        self.assertEqual(original, q)
        self.assertEqual(initial, frozenset(tuple(f) for f in original['initial']))

    def test_missing_initial_fact_is_not_invented(self):
        q = self.query(); q['initial'] = q['initial'][:2]
        actions, initial, goal, negative, *_ = compile_query(q, INPUT)
        status, plan, _ = solve(actions, initial, goal, negative, max_depth=20)
        self.assertEqual('unsolvable', status)
        self.assertIsNone(plan)

    def test_wrong_type_and_missing_global_constant_binding_rejected(self):
        q = self.query(); q['constant_bindings']['BIRT:bench'] = 'hero'
        with self.assertRaisesRegex(ValueError, 'Invalid constant binding'):
            compile_query(q, INPUT)
        q = self.query(); del q['constant_bindings']['BIRT:bench']
        with self.assertRaisesRegex(ValueError, 'Missing explicit'):
            compile_query(q, INPUT)

    def test_unknown_initial_object_rejected(self):
        q = self.query(); q['initial'][0][1] = 'ghost'
        with self.assertRaisesRegex(ValueError, 'object'):
            compile_query(q, INPUT)

    def test_replay_detects_deletion_and_negative_preconditions(self):
        p = frozenset({('p',)})
        empty = frozenset()
        remove = GroundAction('a','A','remove',{},p,empty,empty,p)
        use = GroundAction('b','B','use',{},p,empty,empty,empty)
        result = replay([remove,use],p,empty,empty)
        self.assertFalse(result['valid']); self.assertEqual(1,result['failed_step'])
        forbid = GroundAction('c','C','forbid',{},empty,p,empty,empty)
        self.assertFalse(replay([forbid],p,empty,empty)['valid'])

    def test_limits_do_not_claim_unsolvability(self):
        actions, initial, goal, negative, *_ = compile_query(self.query(), INPUT)
        self.assertEqual('depth_limit', solve(actions,initial,goal,negative,max_depth=1)[0])
        self.assertEqual('state_limit', solve(actions,initial,goal,negative,max_states=1)[0])

    def test_artifacts_and_reuse_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            out=Path(td)
            result=run_query(self.query(),INPUT,out)
            self.assertEqual('solved',result['status'])
            domain=parse_domain(out/'domain.pddl',apply_reviewed_semantics=False)
            self.assertEqual(result['ground_actions'],len(domain.actions))
            problem=parse_sexpr((out/'problem.pddl').read_text(encoding='utf-8'))
            state={tuple(f) for f in section(problem, ':init')[1:]}
            self.assertEqual(state, {tuple(f) for f in self.query()['initial']})
            for line in (out/'plan.txt').read_text(encoding='utf-8').splitlines():
                action=domain.actions[parse_sexpr(line)[0]]
                pre=list(iter_raw_literals(action[action.index(':precondition')+1]))
                for pred,args,negated in pre:
                    self.assertEqual(not negated, (pred,*args) in state)
                effects=list(iter_raw_literals(action[action.index(':effect')+1]))
                state.difference_update((pred,*args) for pred,args,neg in effects if neg)
                state.update((pred,*args) for pred,args,neg in effects if not neg)
            for pred,args,negated in iter_raw_literals(section(problem, ':goal')[1]):
                self.assertEqual(not negated, (pred,*args) in state)
            with self.assertRaisesRegex(ValueError,'empty output'):
                run_query(self.query(),INPUT,out)

if __name__ == '__main__':
    unittest.main()

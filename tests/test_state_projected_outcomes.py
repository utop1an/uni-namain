from collections import deque
from itertools import product
from pathlib import Path
import tempfile
import unittest

from unified_planning.io import PDDLReader
from unified_planning.exceptions import UPInvalidActionError
from unified_planning.model.fluent import get_all_fluent_exp
from unified_planning.plans import ActionInstance, SequentialPlan
from unified_planning.shortcuts import SequentialSimulator
from rcnc.outcome_planning import explore


class StateProjectedOutcomesTests(unittest.TestCase):
    def test_complete_bfs_matches_unpruned_cartesian_with_add_delete_cycles(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            domain, problem = root/'domain.pddl', root/'problem.pddl'
            domain.write_text('''(define (domain t) (:requirements :adl :typing)
             (:types item) (:constants a b c - item)
             (:predicates (ready ?x - item) (done ?x - item) (edge ?x ?y - item))
             (:action seed :parameters (?x - item) :effect (ready ?x))
             (:action finish :parameters (?x - item) :precondition (ready ?x)
              :effect (and (not (ready ?x)) (done ?x)))
             (:action reset :parameters (?x - item) :precondition (done ?x) :effect (not (done ?x)))
             (:action pass :parameters (?x ?y - item) :precondition (and (done ?x) (edge ?x ?y))
              :effect (ready ?y)))''', encoding='utf-8')
            problem.write_text('(define (problem p) (:domain t) (:init (edge a b) (edge b c)) (:goal (and)))', encoding='utf-8')
            parsed = PDDLReader().parse_problem(str(domain), str(problem))
            fluents = sorted([f for schema in parsed.fluents for f in get_all_fluent_exp(parsed,schema)], key=str)
            candidates = [(act, params) for act in parsed.actions for params in
                product(*[[parsed.environment.expression_manager.ObjectExp(o) for o in parsed.objects(p.type)] for p in act.parameters])]
            expected = []
            with SequentialSimulator(parsed) as sim:
                initial = sim.get_initial_state()
                queue = deque([(initial,[])])
                visited = {initial}
                while queue:
                    state, plan = queue.popleft()
                    if len(plan) >= 4:
                        continue
                    for action, params in candidates:
                        try:
                            after = sim.apply(state,action,params)
                        except UPInvalidActionError:
                            continue
                        if after is None or after in visited:
                            continue
                        visited.add(after)
                        steps = plan+[ActionInstance(action,params)]
                        queue.append((after,steps))
                        changed = [(str(f),after.get_value(f).bool_constant_value()) for f in fluents
                                   if after.get_value(f) != initial.get_value(f)]
                        expected.append((str(SequentialPlan(steps)),changed))
            observed = explore(domain,problem,root/'out',max_depth=4,max_states=1000,max_outcomes=1000)
            actual = []
            for row in observed['outcomes']:
                changes = [(str(parsed.fluent(c['atom'][0])(*[parsed.object(a) for a in c['atom'][1:]])),c['value'])
                           for c in row['changes']]
                actual.append((row['plan'],changes))
                self.assertEqual('VALID',row['validation']['status'])
            self.assertGreater(len(expected),10)
            self.assertEqual(expected,actual)


if __name__ == '__main__':
    unittest.main()

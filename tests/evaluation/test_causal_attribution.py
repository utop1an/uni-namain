import copy
import json
from pathlib import Path
import tempfile
import unittest

from rcnc.causal_attribution import causal_trace_v2, recover_branch_provenance, file_digest
from rcnc.glaive_merge import build, map_problem
from tests.test_glaive_merge import fixture as compiler_fixture


class CausalAttributionTests(unittest.TestCase):
    def setUp(self):
        self.root = Path(self.enterContext(tempfile.TemporaryDirectory()))

    def write(self, name, text):
        path = self.root / name
        path.write_text(text, encoding='utf-8')
        return path

    def fixture(self, *, d_guard='(d_active)', tail=True, initial_extra=''):
        a = '(and (a_active) (not (blocked)))'
        d = '(and ' + d_guard + ' (ready))'
        effect = '(shared_awake)'
        def action(name, pre, eff):
            return f'(:action {name} :parameters () :precondition {pre} :effect {eff})'
        suffix = (action('move', '(and (a_active) (shared_awake))', '(shared_at)')
                  + action('find', '(and (b_active) (shared_at))', '(shared_has)')
                  + action('put', '(and (c_active) (shared_has))', '(goal)')) if tail else ''
        prefix = '(define (domain test) (:predicates (a_active) (b_active) (c_active) (d_active) (blocked) (ready) (shared_awake) (shared_at) (shared_has) (goal)) '
        full = self.write('full.pddl', prefix + action('wake', '(or ' + a + ' ' + d + ')', effect) + suffix + ')')
        variant = self.write('variant.pddl', prefix + action('a_wake', a, effect) + action('d_wake', d, effect) + suffix + ')')
        mapping = {'source_sha256': {'a': 'frozen-a', 'd': 'frozen-d'}, 'predicate_maps': {},
                   'action_maps': {'a:wake': {'name': 'wake', 'order': []}, 'd:wake': {'name': 'wake', 'order': []}}}
        if tail:
            for sid, name in [('a', 'move'), ('b', 'find'), ('c', 'put')]:
                mapping['action_maps'][sid + ':' + name] = {'name': name, 'order': []}
        vm = copy.deepcopy(mapping)
        vm['action_maps']['a:wake']['name'] = 'a_wake'
        vm['action_maps']['d:wake']['name'] = 'd_wake'
        provenance = recover_branch_provenance(full, mapping, variant, vm)
        problem = self.write('problem.pddl', '(define (problem p) (:domain test) (:init (a_active) (b_active) (c_active) (d_active) (ready) ' + initial_extra + ') (:goal ' + ('(goal)' if tail else '(shared_awake)') + '))')
        plan = self.write('plan.pddl', '(define (plan p-plan) (:problem p) (:steps (wake)' + (' (move) (find) (put)' if tail else '') + '))')
        return full, problem, plan, mapping, provenance

    def trace(self, parts, sources=('a', 'b', 'c', 'd'), **kwargs):
        return causal_trace_v2(*parts[:4], provenance=parts[4], selected_sources=list(sources), **kwargs)

    def test_cross_robust_but_all_four_ambiguous(self):
        result = self.trace(self.fixture())
        self.assertEqual(result['cross']['status'], 'confirmed')
        self.assertEqual(result['all_k']['status'], 'ambiguous')
        self.assertEqual(result['origin_ambiguous_steps'], [0])
        self.assertEqual(result['interpretations_examined'], 2)
        self.assertEqual(result['all_k']['positive_interpretations'], 1)
        self.assertEqual(result['witnesses']['all_k_positive']['steps'][0]['source'], 'd')
        self.assertEqual(result['witnesses']['all_k_negative']['steps'][0]['source'], 'a')

    def test_source_count_profile_retains_partial_chain_and_ambiguity(self):
        parts = self.fixture()
        original = self.trace(parts)
        result = self.trace(parts, source_count_profile=True)
        self.assertEqual(result['cross'], original['cross'])
        self.assertEqual(result['all_k'], original['all_k'])
        profile = result['source_count_profile']
        self.assertEqual(profile['minimum_over_interpretations'], 3)
        self.assertEqual(profile['maximum_over_interpretations'], 4)
        self.assertIsNone(profile['exact_count'])
        self.assertEqual(profile['at_least']['2']['status'], 'confirmed')
        self.assertEqual(profile['at_least']['3']['status'], 'confirmed')
        self.assertEqual(profile['at_least']['4']['status'], 'ambiguous')

    def test_source_count_profile_does_not_pool_goal_branches(self):
        domain = self.write('fork.pddl', '''(define (domain d) (:predicates (shared_x) (y) (z))
          (:action make :parameters () :precondition (and) :effect (shared_x))
          (:action left :parameters () :precondition (shared_x) :effect (y))
          (:action right :parameters () :precondition (shared_x) :effect (z)))''')
        problem = self.write('fork_problem.pddl', '(define (problem p) (:domain d) (:init) (:goal (and (y) (z))))')
        plan = self.write('fork_plan.pddl', '(define (plan q) (:problem p) (:steps (make) (left) (right)))')
        mapping = {'action_maps': {s+':'+a: {'name': a} for s,a in [('a','make'),('b','left'),('c','right')]}}
        result = causal_trace_v2(domain, problem, plan, mapping, selected_sources=['a','b','c'], source_count_profile=True)
        self.assertEqual(result['source_count_profile']['exact_count'], 2)
        self.assertEqual(result['source_count_profile']['at_least']['2']['status'], 'confirmed')
        self.assertEqual(result['source_count_profile']['at_least']['3']['status'], 'absent')

    def test_source_count_profile_never_adds_aliased_sources(self):
        result = self.trace(self.fixture(tail=False), sources=('a','d'), source_count_profile=True)
        self.assertEqual(result['source_count_profile']['exact_count'], 1)
        self.assertEqual(result['source_count_profile']['at_least']['2']['status'], 'absent')

    def test_source_count_profile_cap_is_unknown(self):
        result = self.trace(self.fixture(), source_count_profile=True, max_interpretations=1)
        self.assertEqual(result['source_count_profile']['status'], 'unknown')
        self.assertNotIn('exact_count', result['source_count_profile'])

    def test_disabled_branch_is_not_an_origin(self):
        parts = self.fixture()
        parts[1].write_text(parts[1].read_text(encoding='utf-8').replace('(d_active)', ''), encoding='utf-8')
        result = self.trace(parts)
        self.assertEqual(result['origin_ambiguous_steps'], [])
        self.assertEqual(result['cross']['status'], 'confirmed')
        self.assertEqual(result['all_k']['status'], 'absent')
        self.assertEqual(result['steps'][0]['applicable_sources'], ['a'])

    def test_source_choice_can_genuinely_change_cross(self):
        parts = self.fixture()
        parts[1].write_text(parts[1].read_text(encoding='utf-8').replace('(:goal (goal))', '(:goal (shared_at))'), encoding='utf-8')
        parts[2].write_text('(define (plan q) (:problem p) (:steps (wake) (move)))', encoding='utf-8')
        result = self.trace(parts, sources=('a', 'd'))
        self.assertEqual(result['cross']['status'], 'ambiguous')
        self.assertEqual(result['all_k']['status'], 'ambiguous')
        self.assertEqual(result['cross']['positive_interpretations'], 1)

    def test_applicability_is_checked_at_each_step_not_only_initially(self):
        parts = self.fixture()
        # D is initially inapplicable; a preceding action enables its branch.
        # Keep recorded branch conditions intact while adding that action.
        parts[1].write_text(parts[1].read_text(encoding='utf-8').replace('(ready)', ''), encoding='utf-8')
        for path in (parts[0], self.root / 'variant.pddl'):
            text = path.read_text(encoding='utf-8')
            path.write_text(text[:-1] + ' (:action prepare :parameters () :precondition (and) :effect (ready)))', encoding='utf-8')
        parts[3]['action_maps']['a:prepare'] = {'name': 'prepare', 'order': []}
        vm = copy.deepcopy(parts[3])
        vm['action_maps']['a:wake']['name'] = 'a_wake'
        vm['action_maps']['d:wake']['name'] = 'd_wake'
        provenance = recover_branch_provenance(parts[0], parts[3], self.root / 'variant.pddl', vm)
        parts[2].write_text('(define (plan q) (:problem p) (:steps (prepare) (wake) (move) (find) (put)))', encoding='utf-8')
        result = self.trace((*parts[:4], provenance))
        self.assertEqual(result['steps'][1]['applicable_sources'], ['a', 'd'])
        self.assertEqual(result['origin_ambiguous_steps'], [1])

    def test_complete_negative_precondition_disambiguates(self):
        result = self.trace(self.fixture(initial_extra='(blocked)'))
        self.assertEqual(result['steps'][0]['applicable_sources'], ['d'])
        self.assertEqual(result['all_k']['status'], 'confirmed')

    def test_aliases_never_count_as_simultaneous_sources(self):
        result = self.trace(self.fixture(tail=False), sources=('a', 'd'))
        self.assertEqual(result['cross']['status'], 'absent')
        self.assertEqual(result['all_k']['status'], 'absent')
        self.assertEqual(result['origin_ambiguous_steps'], [0])

    def test_cap_never_reports_partial_robust_verdict(self):
        result = self.trace(self.fixture(), max_interpretations=1)
        self.assertEqual(result['cross']['status'], 'unknown')
        self.assertEqual(result['all_k']['status'], 'unknown')
        self.assertEqual(result['reason'], 'interpretation_limit')

    def test_missing_and_stale_provenance_fail_closed(self):
        parts = self.fixture()
        missing = causal_trace_v2(*parts[:4])
        self.assertEqual(missing['reason'], 'missing_verified_branch_provenance')
        parts[0].write_text(parts[0].read_text(encoding='utf-8') + '\n', encoding='utf-8')
        self.assertEqual(self.trace(parts)['reason'], 'stale_branch_provenance')

    def test_corrupt_branch_record_fail_closed(self):
        parts = self.fixture()
        parts[4]['actions']['wake']['branches'][0]['source'] = 'd'
        self.assertEqual(self.trace(parts)['reason'], 'branch_provenance_mismatch')

    def test_disjunct_supports_remain_alternatives(self):
        domain = self.write('d.pddl', '''(define (domain d) (:predicates (shared_x) (free) (done))
          (:action make :parameters () :precondition (and) :effect (shared_x))
          (:action use :parameters () :precondition (or (shared_x) (free)) :effect (done)))''')
        problem = self.write('p.pddl', '(define (problem p) (:domain d) (:init (free)) (:goal (done)))')
        plan = self.write('q.pddl', '(define (plan q) (:problem p) (:steps (make) (use)))')
        mapping = {'action_maps': {'a:make': {'name': 'make'}, 'b:use': {'name': 'use'}}}
        result = causal_trace_v2(domain, problem, plan, mapping, selected_sources=['a', 'b'])
        self.assertEqual(result['origin_ambiguous_steps'], [])
        self.assertEqual(result['cross']['status'], 'ambiguous')
        self.assertEqual(result['all_k']['status'], 'ambiguous')
        problem.write_text(problem.read_text(encoding='utf-8').replace('(:init (free))', '(:init)'), encoding='utf-8')
        self.assertEqual(causal_trace_v2(domain, problem, plan, mapping)['cross']['status'], 'confirmed')

    def test_readding_initial_fact_is_not_a_producer(self):
        parts = self.fixture(initial_extra='(shared_awake)')
        result = self.trace(parts)
        self.assertEqual(result['all_k']['status'], 'absent')
        self.assertNotIn(0, result['witnesses']['cross_positive']['goal_relevant_steps'])

    def test_unrelated_goal_branches_are_not_an_all_k_path(self):
        domain = self.write('d.pddl', '''(define (domain d) (:predicates (x) (y))
          (:action first :parameters () :precondition (and) :effect (x))
          (:action second :parameters () :precondition (and) :effect (y)))''')
        problem = self.write('p.pddl', '(define (problem p) (:domain d) (:init) (:goal (and (x) (y))))')
        plan = self.write('q.pddl', '(define (plan q) (:problem p) (:steps (first) (second)))')
        mapping = {'action_maps': {'a:first': {'name': 'first'}, 'b:second': {'name': 'second'}}}
        result = causal_trace_v2(domain, problem, plan, mapping, selected_sources=['a', 'b'])
        self.assertEqual(result['cross']['status'], 'absent')
        self.assertEqual(result['all_k']['status'], 'absent')

    def test_conditional_effect_is_not_silently_missing_causal_guards(self):
        domain = self.write('d.pddl', '''(define (domain d) (:predicates (ready) (done))
          (:action use :parameters () :precondition (and) :effect (when (ready) (done))))''')
        problem = self.write('p.pddl', '(define (problem p) (:domain d) (:init (ready)) (:goal (done)))')
        plan = self.write('q.pddl', '(define (plan q) (:problem p) (:steps (use)))')
        result = causal_trace_v2(domain, problem, plan, {'action_maps': {'a:use': {'name': 'use'}}})
        self.assertEqual(result['cross']['status'], 'unknown')
        self.assertIn('unconditional', result['reason'])

    def test_compiler_parameter_permutation_and_unchanged_artifacts(self):
        sources, groups = compiler_fixture(self.root)
        full = self.root / 'full'
        pred = self.root / 'predicate_only'
        fm = build(sources, full, groups=groups, merge_actions=True)
        pm = build(sources, pred, groups=groups[:1])
        domain = full / 'domain.pddl'
        before = file_digest(domain)
        provenance = recover_branch_provenance(domain, fm, pred / 'domain.pddl', pm)
        action, entry = next(iter(provenance['actions'].items()))
        right = next(b for b in entry['branches'] if b['source'] == 'right')
        self.assertEqual(right['source_parameter_order'], [1, 2, 0])
        self.assertEqual(len(right['parameter_map']), 3)
        problem = self.root / 'p.pddl'
        terms = map_problem(sources, 'right', fm, problem)
        # The native plan is translated through the real compiler's mapping.
        from rcnc.glaive_merge import translate_plan
        source_plan = self.write('native.pddl', '(define (plan q) (:problem right) (:steps (travel away alice home)))')
        plan = self.root / 'translated.pddl'
        translate_plan('right', fm, terms, source_plan, plan)
        result = causal_trace_v2(domain, problem, plan, fm, provenance=provenance)
        self.assertEqual(result['status'], 'classified', result)
        self.assertEqual(result['steps'][0]['applicable_sources'], ['right'])
        self.assertEqual(file_digest(domain), before)

    def test_offline_audit_retains_failures_and_rejects_changed_inputs(self):
        from scripts.audit.audit_causal_attribution import audit_reports
        domain = self.write('domain.pddl', '(define (domain d) (:predicates (goal)) (:action finish :parameters () :precondition (and) :effect (goal)))')
        problem = self.write('problem.pddl', '(define (problem p) (:domain d) (:init) (:goal (goal)))')
        mapping = self.write('mapping.json', json.dumps({'action_maps': {'a:finish': {'name': 'finish', 'order': []}}}))
        plan = self.root / 'execution' / 'ok' / 'search' / 'plan.pddl'
        plan.parent.mkdir(parents=True)
        plan.write_text('(define (plan q) (:problem p) (:steps (finish)))', encoding='utf-8')
        rows = []
        for name, status in [('ok', 'solved'), ('none', 'no_solution_returned'), ('limit', 'wall_time_limit')]:
            rows.append({'id': name, 'group': name, 'condition': 'full', 'domain': str(domain),
                         'mapping': str(mapping), 'problem': str(problem), 'search': {'status': status},
                         'valid_plan': name == 'ok', 'replay': {'input_sha256': {str(plan): file_digest(plan)}} if name == 'ok' else {}})
        report = self.write('report.json', json.dumps({'rows': rows}))
        self.write('tasks.json', json.dumps({'tasks': rows}))
        self.write('protocol.json', json.dumps({'input_sha256': {str(domain): file_digest(domain)}}))
        result = audit_reports({'fixture': str(report)}, self.root / 'audit')
        counts = result['by_cohort_condition']['fixture/full']
        self.assertEqual(counts['slots'], 3)
        self.assertEqual(counts['valid'], 1)
        self.assertEqual(counts['search_wall_time_limit'], 1)
        self.assertEqual(counts['search_no_solution_returned'], 1)
        self.assertEqual(result['new_planner_calls'], 0)
        self.assertEqual(result['new_model_calls'], 0)
        with self.assertRaisesRegex(ValueError, 'Fresh audit directory'):
            audit_reports({'fixture': str(report)}, self.root / 'audit')
        domain.write_text(domain.read_text(encoding='utf-8') + '\n', encoding='utf-8')
        with self.assertRaisesRegex(ValueError, 'Frozen input changed'):
            audit_reports({'fixture': str(report)}, self.root / 'bad-audit')
        self.assertFalse((self.root / 'bad-audit').exists())


if __name__ == '__main__':
    unittest.main()

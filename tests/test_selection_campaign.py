from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from rcnc.domain_building import save
from rcnc.glaive_merge import build, map_problem, translate_plan
from rcnc.pddl import parse_sexpr, section
from rcnc.saved_plan_validation import replay_saved
from scripts.experiments import run_selection_comparison as campaign
from tests.test_revised_multistory import fixture


class SelectionCampaignTests(unittest.TestCase):
    def test_adapter_inverse_restores_source_plan_and_retransports_to_five_sources(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            sources, _ = fixture(root, 5)
            single = build([sources[0]], root / 'single')
            terms = map_problem([sources[0]], 's0', single, root / 'single/problem.pddl')
            native = root / 'native.pddl'
            native.write_text('(define (plan p) (:problem s0) (:steps (travel alice home away)))', encoding='utf-8')
            adapter = root / 'adapter.pddl'
            translate_plan('s0', single, terms, native, adapter)
            restored = root / 'restored.pddl'
            campaign.inverse_source_plan(sources[0], single, terms, adapter, restored)
            self.assertEqual(section(parse_sexpr(restored.read_text(encoding='utf-8')), ':steps'),
                             section(parse_sexpr(native.read_text(encoding='utf-8')), ':steps'))
            merged = build(sources, root / 'union')
            terms = map_problem(sources, 's0', merged, root / 'union/problem.pddl')
            translated = root / 'translated.pddl'
            translate_plan('s0', merged, terms, restored, translated)
            self.assertTrue(replay_saved(root / 'union/domain.pddl', root / 'union/problem.pddl', translated)['goal'])

    def test_native_only_validation_does_not_become_dual_validation(self):
        r = {'status': 'replayed', 'goal': True, 'unexplained_steps': 0,
             'physical': {'status': 'unsupported', 'reason': 'axioms'}}
        self.assertEqual(campaign.replay_level(r), 'native_only_physical_unknown')
        r['physical'] = {'status': 'inapplicable'}
        self.assertEqual(campaign.replay_level(r), 'unavailable_valid_reference')
        r['physical'] = {'status': 'replayed', 'goal': True}
        self.assertEqual(campaign.replay_level(r), 'dual_validated')

    def test_compile_failure_keeps_all_worlds_and_control_slots(self):
        group = {'id': 'test', 'sources': ['s0', 's1', 's2', 's3', 's4'],
                 'cohort': 'human_authored', 'method': 'random', 'size': 5}
        worlds = [{'id': s + str(i), 'source': s} for s in group['sources'] for i in range(2)]
        originals, cross = campaign.compilation_failure_tasks(group, worlds, 'failure')
        self.assertEqual(len(originals), 30)
        self.assertEqual(sum(t['search_anchor'] for t in originals), 6)
        self.assertEqual(len(cross), 9)
        self.assertTrue(all(t['status'] == 'unavailable_compilation' for t in originals + cross))

    def test_multiple_worlds_k5_and_unsupported_world_remain_registered(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            inputs = root / 'inputs'; inputs.mkdir()
            sources, raw = fixture(inputs, 5)
            group = {'id': 'fixture_k5', 'sources': [s.id for s in sources], 'size': 5,
                     'cohort': 'human_authored', 'method': 'causal_path'}
            save(root / 'protocol.json', {'budgets': {'group_route_prefixes': 1000}})
            save(root / 'selected_groups.json', {'groups': [group]})
            save(root / 'sources.json', {'sources': [{'id': s.id, 'domain': str(s.domain_path),
                 'representative_problem': str(s.problem_path), 'constant_contract': {}} for s in sources]})
            invalid = inputs / 'bad.pddl'; invalid.write_text('(define (problem bad) (:goal (at alice away)))', encoding='utf-8')
            worlds = [{'id': s.id + '_world', 'source': s.id, 'problem': str(s.problem_path)} for s in sources]
            worlds.append({'id': 's0_bad', 'source': 's0', 'problem': str(invalid)})
            save(root / 'worlds.json', {'worlds': worlds})
            (root / 'repeat_01/judgments').mkdir(parents=True)
            save(root / 'repeat_01/judgments/groups.json', {'groups': raw})
            result = campaign.group_worker(root, group['id'])
            self.assertEqual(result['status'], 'compiled')
            self.assertEqual(len(result['source_tasks']), 18)
            self.assertEqual(sum(t['status'] == 'unsupported_world' for t in result['source_tasks']), 3)
            self.assertEqual(len(result['composition_tasks']), 9)
            self.assertEqual(result['models']['full']['action_count'], 1)

    def test_route_prefix_budget_applies_even_without_a_complete_path(self):
        profiles = {'a': {'x': {'effects': [(True, ['p', '?v'])], 'preconditions': []}},
                    'b': {'y': {'effects': [], 'preconditions': [(True, ['p', '?v'])]}},
                    'c': {}}
        mapping = {s: {'p': ['shared_p', [0]]} for s in profiles}
        with self.assertRaisesRegex(ValueError, 'route_prefix_budget'):
            list(campaign.bounded_routes(['a', 'b', 'c'], profiles, mapping, {'visited': 0, 'limit': 1}))

    def test_stopped_model_stage_runs_evaluation_without_compilation(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / 'protocol.json').write_text('{}', encoding='utf-8')
            with patch.object(campaign, 'verify', return_value={}), \
                 patch.object(campaign.model_semantics_parallel, 'run', return_value={
                     'execution_status': 'stopped', 'stop_reason': 'quota'}), \
                 patch.object(campaign, 'compile_all') as compile_all, \
                 patch.object(campaign, 'evaluation', return_value={'status': 'complete_evaluation'}) as evaluate:
                result = campaign.pipeline(root)
                self.assertEqual(result['completed_repeats'], 0)
                self.assertEqual(result['status'], 'stopped_model_stage_incomplete')
                compile_all.assert_not_called()
                evaluate.assert_called_once_with(root, 'stopped_model_stage_incomplete')
                with self.assertRaisesRegex(ValueError, 'Fresh execution'):
                    campaign.pipeline(root)

    def test_incomplete_evaluation_keeps_full_group_and_slot_denominators(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            save(root / 'protocol.json', {'input_sha256': {}})
            groups = campaign.read(campaign.DATA / 'groups.json')['groups']
            save(root / 'selected_groups.json', {'groups': groups})
            result = campaign.evaluation(root, 'stopped_model_stage_incomplete')
            report = campaign.read(root / 'evaluation/report.json')
            self.assertEqual(len(report['rows']), 800)
            self.assertEqual(result['slot_accounting']['transport']['not_run'], 23817)
            self.assertTrue(all(c['registered_groups'] == 50 for c in report['cells']))
            self.assertTrue(all(c['conditions']['full']['composition_statuses'] == {'not_run': 50} for c in report['cells']))

    def test_evaluation_preserves_unsearchable_status_and_continuation_label(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            save(root / 'protocol.json', {'input_sha256': {}, 'condition': 'interrupted_cache_continuation_with_bounded_retries',
                                         'continuation': {'parent': 'historical'}})
            groups = [{'id': f'{cohort}_{method}_{k}_{i}', 'cohort': cohort, 'method': method, 'size': k}
                      for cohort in campaign.COHORTS for method in ('random','causal_path') for k in (2,3,4,5) for i in range(50)]
            save(root / 'selected_groups.json', {'groups': groups})
            (root / 'repeat_01').mkdir()
            save(root / 'repeat_01/composition_report.json', {'rows': [
                {'id':'unsupported', 'group': groups[0]['id'], 'cohort': groups[0]['cohort'],
                 'method': groups[0]['method'], 'size': 2, 'condition':'full', 'status':'world_export_unsupported'}]})
            campaign.evaluation(root, 'complete')
            report = campaign.read(root / 'evaluation/report.json')
            self.assertEqual(report['rows'][0]['conditions']['full']['status'], 'world_export_unsupported')
            self.assertEqual(report['experiment_condition'], 'interrupted_cache_continuation_with_bounded_retries')


if __name__ == '__main__':
    unittest.main()

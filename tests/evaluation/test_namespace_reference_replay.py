import copy
import json
from pathlib import Path
import shutil
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

from rcnc.domain_building import digest
from rcnc.pddl import parse_domain
from scripts.experiments.replay_namespace_reference import action_bindings, execute, prepare
from scripts.audit.audit_namespace_reference_replay import audit
from scripts.audit.audit_reference_prefix_diagnostic import plan_steps
from scripts.experiments.run_fusion_reference import freeze
from unidomain.pipeline import run


DOMAIN = '''(define (domain original) (:requirements :strips :typing)
    (:types item) (:constants c - item) (:predicates (ready ?x - item) (done ?x - item) (never))
    (:action finish :parameters (?x ?unused - item) :precondition (ready ?x) :effect (done ?x))
    (:action idle :parameters (?x - item) :precondition (never) :effect (ready ?x)))'''
PROBLEM = '(define (problem q) (:domain original) (:init (ready c)) (:goal (never)))'


def save(path, value):
    path.write_text(json.dumps(value), encoding='utf-8')


class NamespaceReferenceReplayTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(); self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name); self.parent = self.root / 'parent'
        inputs = self.parent / 'inputs'; inputs.mkdir(parents=True)
        (inputs / 'A_domainfile.pddl').write_text(DOMAIN,encoding='utf-8')
        (inputs / 'A_problemfile.pddl').write_text(PROBLEM,encoding='utf-8')
        frozen = self.root / 'freeze'
        self.parent_manifest = freeze(inputs,frozen,10,1,'fixture-no-model','category_qualified')
        self.parent_manifest.update(status='complete',model_digest='0' * 64)
        shutil.copytree(frozen / 'implementation',self.parent / 'implementation')
        runtime = SimpleNamespace(predicate_threshold=0.3,operator_threshold=0.3,embedding_model='fixture',
            llm=SimpleNamespace(model='fixture-no-model',network_calls=0,cache_hits=0,total_duration_seconds=0))
        run(inputs,self.parent / 'fusion',runtime=runtime,num_workers=1,namespace_policy='category_qualified')
        self.validation = json.loads((self.parent / 'fusion/validation.json').read_text(encoding='utf-8'))
        save(self.parent / 'manifest.json',self.parent_manifest)
        self.parent_report = {'status':'complete','source_snapshot_unchanged':True,'implementation_unchanged':True,
                              'validation':self.validation}
        save(self.parent / 'report.json',self.parent_report)
        self.historical = self.root / 'historical'; self.historical.mkdir()
        bundle, native = self.historical / 'bundle', self.historical / 'native'
        tasks, native_tasks, native_rows, audited = [], [], [], []
        for action in ('finish','idle'):
            identifier = 'A__' + action
            source = bundle / 'tasks' / identifier; source.mkdir(parents=True)
            actual = native / 'tasks' / identifier; actual.mkdir(parents=True)
            (source / 'source_domain.pddl').write_text(DOMAIN,encoding='utf-8')
            (source / 'source_problem.pddl').write_text(PROBLEM,encoding='utf-8')
            (actual / 'domain.pddl').write_text(DOMAIN,encoding='utf-8')
            world = PROBLEM.replace('(:goal (never))','(:goal (done c))') if action == 'finish' else PROBLEM
            (actual / 'problem.pddl').write_text(world,encoding='utf-8')
            task = {'id':identifier,'source':'A','target_action':action,
                'source_domain_sha256':digest(source / 'source_domain.pddl'),
                'source_problem_sha256':digest(source / 'source_problem.pddl'),
                'domain_sha256':digest(actual / 'domain.pddl'),'problem_sha256':digest(actual / 'problem.pddl')}
            tasks.append(task); native_tasks.append(task)
            status = 'solved' if action == 'finish' else 'unsolvable'
            native_rows.append({'id':identifier,'status':status})
            row = {'id':identifier,'source':'A','target_action':action,'solver_status':status,
                'status':'PASS' if action == 'finish' else 'NO_PLAN'}
            if action == 'finish':
                (actual / 'plan.txt').write_text('(finish c c)\n',encoding='utf-8')
                row.update(target_invoked=True,instrumentation_audit=True,instrumented_plan_validation='VALID',
                           plan_length=1,visited_actions=['finish'])
            audited.append(row)
        save(bundle / 'manifest.json',{'tasks':tasks,'task_count':2})
        save(native / 'manifest.json',{'tasks':native_tasks,'task_count':2})
        save(native / 'report.json',{'status':'complete','rows':native_rows,'task_count':2})
        audit = self.historical / 'audit.json'
        save(audit,{'status':'complete','hashes_unchanged':True,'task_count':2,'rows':audited})
        hashes = {p.name:digest(p) for p in inputs.iterdir()}
        build = self.root / 'build.json'
        save(build,{'model':'fixture-no-model','node_workers':1,'namespace_policy':'category_qualified',
                    'full_worker_budget_seconds':10,'full_input_sha256':hashes})
        self.protocol = {'historical_root':str(self.historical),'source_task_bundle':str(bundle),
            'native_solver_run':str(native),'native_prefix_audit':str(audit),
            'historical_input_sha256':{p.relative_to(self.historical).as_posix():digest(p) for p in self.historical.rglob('*') if p.is_file()},
            'task_count':2,'source_trace_availability':{'audited_prefixes':1,'no_audited_prefix':1},
            'parent':str(self.parent),'build_protocol':str(build),'build_protocol_sha256':digest(build),
            'sources':['A'],'world_count':1,'source_sha256':hashes,
            'budget':{'workers':1,'seconds_per_replay_process':8,'max_source_atoms':100,
                'max_mapping_arity':6,'max_mapping_permutations':720,'stop_validation_utc':'2000-01-01T00:00:00Z'},
            'scope':'Authored controller fixture, no model or planner calls; only supplied-prefix simulation'}
        self.protocol_path = self.root / 'protocol.json'; save(self.protocol_path,self.protocol)

    def test_all_slots_and_full_arguments_frozen_before_late_budget_starts_no_replay(self):
        output = self.root / 'out'; manifest = prepare(self.protocol_path,output)
        self.assertEqual(2,manifest['task_count']); self.assertEqual(1,manifest['ready_prefixes'])
        job = json.loads((output / 'cases/A__finish/job.json').read_text(encoding='utf-8'))
        self.assertEqual([0,1],job['actions']['finish']['positions'])
        self.assertEqual('public_is_applicable',job['applicability_policy'])
        self.assertEqual('(finish c c)\n',(output / 'cases/A__finish/source.plan').read_text(encoding='utf-8'))
        with patch('scripts.experiments.replay_namespace_reference.subprocess.run') as child:
            result = execute(output)
        child.assert_not_called()
        self.assertEqual(0,result['actual_replay_processes']); self.assertFalse(result['execution_complete'])
        self.assertEqual({'not_run_due_goal_budget':1,'no_audited_source_prefix':1},result['status_counts'])

    def test_real_child_prefix_pass_does_not_check_or_require_original_goal(self):
        self.protocol['budget']['stop_validation_utc'] = '2099-01-01T00:00:00Z'
        save(self.protocol_path,self.protocol)
        output = self.root / 'out'; prepare(self.protocol_path,output); result = execute(output)
        self.assertEqual('complete',result['status']); self.assertTrue(result['execution_complete'])
        self.assertEqual({'PASS':1,'no_audited_source_prefix':1},result['status_counts'])
        self.assertEqual(1,result['actual_replay_processes'])
        self.assertEqual(6,result['truth_comparisons'])
        self.assertTrue(result['historical_inputs_unchanged'])
        self.assertEqual('not_requested_source_prefix_only',result['rows'][0]['goal_evaluation'])

    def test_unverified_arity_cannot_be_truncated_and_renaming_needs_unique_structure(self):
        source = parse_domain(self.parent / 'inputs/A_domainfile.pddl')
        target = copy.deepcopy(source)
        target.actions['finish'][3] = ['?x','?unused','?extra','-','item']
        metadata = {'action_maps':{'A':{'finish':'finish','idle':'idle'}},
            'predicate_maps':{'A':{p:p for p in source.predicates}},'constant_maps':{'A':{'c':'c'}}}
        namespace = {'actions':{'finish':'act__finish','idle':'act__idle'}}
        allowed, inventory = action_bindings(source,target,'A',metadata,namespace,self.protocol['budget'])
        self.assertNotIn('finish',allowed)
        self.assertEqual('arity_change_not_inferred',inventory[0]['status'])
        target = copy.deepcopy(source); target.actions['finish'][3] = ['?x','?other','-','item']
        allowed, inventory = action_bindings(source,target,'A',metadata,namespace,self.protocol['budget'])
        self.assertEqual([0,1],allowed['finish']['positions'])
        self.assertEqual('unique_structural_map',inventory[0]['status'])
        source.actions['finish'][3] = ['?x','?unused','?unused2','-','item']
        target.actions['finish'][3] = ['?x','?other','?other2','-','item']
        allowed, inventory = action_bindings(source,target,'A',metadata,namespace,self.protocol['budget'])
        self.assertNotIn('finish',allowed)
        self.assertEqual('ambiguous_structural_maps',inventory[0]['status'])

    def test_missing_prefix_and_shared_parent_failure_remain_in_denominator(self):
        self.parent_manifest['status'] = self.parent_report['status'] = 'worker_error'
        save(self.parent / 'manifest.json',self.parent_manifest); save(self.parent / 'report.json',self.parent_report)
        output = self.root / 'out'; result = prepare(self.protocol_path,output)
        self.assertFalse(result['parent_admitted']); self.assertEqual(1,result['construction_failure_count'])
        self.assertEqual(2,len(result['slots'])); self.assertEqual(0,result['ready_prefixes'])
        with patch('scripts.experiments.replay_namespace_reference.subprocess.run') as child:
            report = execute(output)
        child.assert_not_called()
        self.assertEqual({'not_run_shared_parent_build_failure':2},report['status_counts'])

    def test_historical_or_job_drift_rejected_before_child_start(self):
        output = self.root / 'out'; prepare(self.protocol_path,output)
        job = output / 'cases/A__finish/job.json'; job.write_bytes(job.read_bytes() + b'\n')
        with patch('scripts.experiments.replay_namespace_reference.subprocess.run') as child:
            with self.assertRaisesRegex(ValueError,'Frozen prefix input changed'): execute(output)
        child.assert_not_called()
        original = self.historical / 'native/tasks/A__finish/plan.txt'; original.write_text('(finish c)\n',encoding='utf-8')
        with self.assertRaisesRegex(ValueError,'historical prefix evidence changed'):
            prepare(self.protocol_path,self.root / 'other')
        self.assertFalse((self.root / 'other').exists())

    def test_all_missing_prefixes_still_keep_full_action_mapping_inventory(self):
        audit_path = Path(self.protocol['native_prefix_audit'])
        audited = json.loads(audit_path.read_text(encoding='utf-8'))
        audited['rows'][0]['status'] = 'NO_PLAN'; save(audit_path,audited)
        relative = audit_path.relative_to(self.historical).as_posix()
        self.protocol['historical_input_sha256'][relative] = digest(audit_path)
        self.protocol['source_trace_availability'] = {'audited_prefixes':0,'no_audited_prefix':2}
        save(self.protocol_path,self.protocol)
        output = self.root / 'out'; manifest = prepare(self.protocol_path,output)
        self.assertEqual(0,manifest['ready_prefixes'])
        inventory = json.loads((output / 'action_mapping_inventory.json').read_text(encoding='utf-8'))
        self.assertEqual({'finish','idle'}, {r['source_action'] for r in inventory['rows']})

    def test_duplicate_slot_or_late_historical_drift_cannot_start_a_child(self):
        output = self.root / 'out'; manifest = prepare(self.protocol_path,output)
        original_slots = copy.deepcopy(manifest['slots'])
        manifest['slots'][1] = copy.deepcopy(manifest['slots'][0]); save(output / 'manifest.json',manifest)
        with patch('scripts.experiments.replay_namespace_reference.subprocess.run') as child:
            with self.assertRaisesRegex(ValueError,'unique source-prefix denominator'): execute(output)
        child.assert_not_called()
        manifest['slots'] = original_slots; save(output / 'manifest.json',manifest)
        path = self.historical / 'native/tasks/A__finish/plan.txt'; path.write_bytes(path.read_bytes() + b'\n')
        with patch('scripts.experiments.replay_namespace_reference.subprocess.run') as child:
            with self.assertRaisesRegex(ValueError,'historical prefix evidence changed before replay'): execute(output)
        child.assert_not_called()

    def finished(self):
        self.protocol['budget']['stop_validation_utc'] = '2099-01-01T00:00:00Z'
        save(self.protocol_path,self.protocol)
        output = self.root / 'finished'; prepare(self.protocol_path,output)
        result = execute(output)
        return output,result

    def test_static_audit_checks_full_parameters_and_reconciles_child_truth_without_new_search(self):
        output,report = self.finished()
        result = audit(output,self.root / 'audit')
        self.assertEqual('verified_fresh_reference_prefix_registry',result['status'])
        self.assertEqual(2,result['task_count']); self.assertEqual(1,result['actual_replay_processes'])
        self.assertEqual(1,result['mapped_prefix_steps']); self.assertEqual(2,result['full_actual_parameters'])
        self.assertEqual(report['truth_comparisons'],result['truth_comparisons_reconciled'])
        self.assertEqual(0,result['planner_calls'])

    def test_unrun_prefix_registry_is_not_promoted_to_completed_replays_by_audit(self):
        output = self.root / 'out'; prepare(self.protocol_path,output); execute(output)
        result = audit(output,self.root / 'audit')
        self.assertEqual('verified_fresh_reference_prefix_registry',result['status'])
        self.assertFalse(result['execution_complete']); self.assertEqual(0,result['actual_replay_processes'])
        self.assertEqual({'not_run_due_goal_budget':1,'no_audited_source_prefix':1},result['status_counts'])

    def test_incomplete_projection_cannot_be_promoted_to_pass_even_with_consistent_counters(self):
        output,report = self.finished()
        child_path = output / 'cases/A__finish/replay/report.json'
        child = json.loads(child_path.read_text(encoding='utf-8'))
        child.update(complete=False,truth_projection_complete=False,truth_comparisons=0,states_compared=0)
        save(child_path,child); report['rows'][0].update(child); report['truth_comparisons'] = 0
        save(output / 'report.json',report)
        with self.assertRaisesRegex(ValueError,'promoted to PASS'):
            audit(output,self.root / 'audit')

    def test_truncated_mapped_arguments_are_rejected_for_a_claimed_verified_prefix(self):
        output,report = self.finished()
        path = output / 'cases/A__finish/replay/mapped.plan'
        step = plan_steps(path)[0]
        path.write_text('(' + ' '.join(step[:-1]) + ')\n',encoding='utf-8')
        with self.assertRaisesRegex(ValueError,'argument bijection'):
            audit(output,self.root / 'audit')

    def test_partial_mapped_output_from_timed_out_child_remains_unverified(self):
        output,report = self.finished()
        case = output / 'cases/A__finish/replay'
        (case / 'report.json').unlink()
        (case / 'mapped.plan').write_text('(unfinished',encoding='utf-8')
        row = report['rows'][0]
        for key in tuple(row):
            if key not in ('id','source','target_action','original_solver_status','original_prefix_audit_status',
                           'admission_status','source_steps','job'):
                row.pop(key)
        row['status'] = 'diagnostic_time_limit'
        report.update(truth_comparisons=0,mismatch_count=0,status_counts={'diagnostic_time_limit':1,'no_audited_source_prefix':1})
        save(output / 'report.json',report)
        result = audit(output,self.root / 'audit')
        self.assertEqual('verified_fresh_reference_prefix_registry',result['status'])
        self.assertEqual(0,result['mapped_prefix_steps'])
        self.assertEqual(1,len(result['unverified_mapped_outputs']))

    def test_private_model_cannot_replace_the_fixed_reference_even_with_consistent_local_hashes(self):
        output,report = self.finished()
        job_path = output / 'cases/A__finish/job.json'; job = json.loads(job_path.read_text(encoding='utf-8'))
        private = output / 'cases/A__finish/private_domain.pddl'
        text = Path(job['target_domain']).read_text(encoding='utf-8')
        private.write_text(text.replace('(pred__ready ?x)','(and)'),encoding='utf-8')
        old_path = job['target_domain']; job['target_domain'] = str(private.resolve())
        job['input_sha256'].pop(old_path); job['input_sha256'][str(private.resolve())] = digest(private)
        save(job_path,job)
        manifest = json.loads((output / 'manifest.json').read_text(encoding='utf-8'))
        manifest['input_sha256'][job_path.relative_to(output).as_posix()] = digest(job_path)
        manifest['input_sha256'][private.relative_to(output).as_posix()] = digest(private)
        save(output / 'manifest.json',manifest); report['manifest_sha256'] = digest(output / 'manifest.json')
        save(output / 'report.json',report)
        with self.assertRaisesRegex(ValueError,'replaced the fixed world/model'):
            audit(output,self.root / 'audit')


if __name__ == '__main__':
    unittest.main()

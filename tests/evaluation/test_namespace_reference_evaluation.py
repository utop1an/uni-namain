import json
from pathlib import Path
import shutil
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

from rcnc.domain_building import digest
from scripts.experiments.evaluate_namespace_reference import REFERENCE, execute, prepare, registered_slots, reference_worlds
from rcnc.namespace_export import export_bundle
from unified_planning.io import PDDLReader
from scripts.experiments.run_fusion_reference import freeze
from unidomain.pipeline import run
from scripts.audit.audit_namespace_reference_worlds import audit
from scripts.experiments.run_downward_reference import linux_path


DOMAIN = '''(define (domain old) (:requirements :strips :typing)
    (:types item) (:constants c - item) (:predicates (p ?x - item))
    (:action finish :parameters (?x - item) :precondition (and) :effect (p ?x)))'''
PROBLEM = '(define (problem world) (:domain old) (:init) (:goal (p c)))'


def write(path, value):
    path.write_text(json.dumps(value), encoding='utf-8')


class NamespaceReferenceEvaluationTests(unittest.TestCase):
    def setUp(self):
        self.root = Path(self.enterContext(tempfile.TemporaryDirectory()))
        self.parent = self.root / 'parent'
        inputs = self.parent / 'inputs'; inputs.mkdir(parents=True)
        (inputs / 'A_domainfile.pddl').write_text(DOMAIN, encoding='utf-8')
        (inputs / 'A_problemfile.pddl').write_text(PROBLEM, encoding='utf-8')
        runtime = SimpleNamespace(predicate_threshold=0.3, operator_threshold=0.3,
            embedding_model='fixture-no-embedding', llm=SimpleNamespace(model='fixture-no-model',
                network_calls=0, cache_hits=0, total_duration_seconds=0))
        run(inputs, self.parent / 'fusion', runtime=runtime, num_workers=1, namespace_policy='category_qualified')
        validation = json.loads((self.parent / 'fusion/validation.json').read_text(encoding='utf-8'))
        hashes = {p.name:digest(p) for p in inputs.iterdir()}
        frozen = self.root / 'frozen_reference'
        self.manifest = freeze(inputs, frozen, 10, 1, 'fixture-no-model', 'category_qualified')
        shutil.copytree(frozen / 'implementation', self.parent / 'implementation')
        self.manifest.update(status='complete', model_digest='0' * 64)
        self.report = {'status': 'complete', 'validation': validation,
            'source_snapshot_unchanged': True, 'implementation_unchanged': True}
        write(self.parent / 'manifest.json', self.manifest)
        write(self.parent / 'report.json', self.report)
        controls = self.root / 'controls'; task_dir = controls / 'tasks/A__native_source'
        task_dir.mkdir(parents=True)
        (task_dir / 'domain.pddl').write_text(DOMAIN, encoding='utf-8')
        (task_dir / 'problem.pddl').write_text(PROBLEM, encoding='utf-8')
        task = {'id': 'A__native_source', 'source': 'A', 'representation': 'native_source',
                'domain_sha256': digest(task_dir / 'domain.pddl'), 'problem_sha256': digest(task_dir / 'problem.pddl')}
        write(controls / 'manifest.json', {'status': 'frozen_before_search', 'tasks': [task], 'task_count': 1})
        build = self.root / 'build.json'
        write(build, {'condition': 'authored fixture, no real inference', 'model':'fixture-no-model',
            'node_workers':1, 'namespace_policy':'category_qualified', 'full_worker_budget_seconds':10,
            'full_input_sha256':hashes})
        self.protocol = {'sources': ['A'], 'conditions': ['native_source', REFERENCE], 'world_count': 1,
            'slot_count': 2, 'build_protocol': str(build), 'build_protocol_sha256': digest(build),
            'parent': str(self.parent), 'source_sha256': hashes,
            'control_bundle': str(controls), 'control_manifest_sha256': digest(controls / 'manifest.json'),
            'control_file_sha256': {p.relative_to(controls).as_posix():digest(p) for p in task_dir.iterdir()},
            'budget': {'maximum_calls': 2, 'seconds_wall_and_cpu': 20, 'memory_mb': 4096,
                'supervisor_grace_seconds_each': 45, 'cleanup_reserve_seconds': 600,
                'whole_goal_stop_before_utc': '2000-01-01T00:00:00Z'},
            'limits': 'One authored admission fixture, no model/planner requests'}
        self.protocol_path = self.root / 'protocol.json'
        write(self.protocol_path, self.protocol)

    def test_actual_qualified_model_and_world_frozen_before_late_budget_keeps_all_slots(self):
        output = self.root / 'out'
        result = prepare(self.protocol_path, output)
        self.assertTrue(result['parent_admitted'])
        self.assertEqual(2, result['task_count'])
        self.assertTrue(all(row['admission_status'] == 'ready' for row in result['slots']))
        self.assertEqual((self.parent / 'fusion/planning_export/domain.pddl').read_bytes(),
            (output / 'bundle/tasks' / ('A__' + REFERENCE) / 'domain.pddl').read_bytes())
        self.assertEqual(PROBLEM, (output / 'original_inputs/A_problemfile.pddl').read_text(encoding='utf-8'))
        with patch('scripts.experiments.evaluate_namespace_reference.run_solver') as solver:
            result = execute(output)
        solver.assert_not_called()
        self.assertEqual(0, result['actual_solver_calls'])
        self.assertEqual({'not_run_due_goal_budget': 2}, result['status_counts'])
        self.assertTrue(result['inputs_unchanged'])

    def test_saved_legacy_entrypoint_is_admitted_but_its_hash_is_still_checked(self):
        legacy_name = 'unidomain_ollama_fusion.py'
        source = Path(__file__).resolve().parents[2] / 'archive/entrypoints' / legacy_name
        archived = self.parent / 'implementation' / legacy_name
        archived.write_bytes(source.read_bytes())
        implementation = self.manifest['implementation_sha256']
        # This archived entry point stored its templates under the original path.
        prompt_root = self.parent / 'implementation' / 'prompts'
        (prompt_root / 'unidomain').rename(prompt_root / 'domain_fusion')
        for path in (prompt_root / 'domain_fusion').glob('*.txt'):
            implementation['prompts/domain_fusion/' + path.name] = implementation.pop(
                'prompts/unidomain/' + path.name)
        implementation.pop('unidomain/__main__.py')
        implementation[legacy_name] = digest(archived)
        write(self.parent / 'manifest.json', self.manifest)
        self.assertTrue(prepare(self.protocol_path, self.root / 'legacy')['parent_admitted'])
        archived.write_bytes(archived.read_bytes() + b'\n# changed\n')
        with self.assertRaisesRegex(ValueError, 'Frozen artifact changed'):
            prepare(self.protocol_path, self.root / 'legacy_changed')
        self.assertFalse((self.root / 'legacy_changed').exists())

    def test_reference_archive_without_any_entrypoint_is_rejected(self):
        self.manifest['implementation_sha256'].pop('unidomain/__main__.py')
        write(self.parent / 'manifest.json', self.manifest)
        with self.assertRaisesRegex(ValueError, 'complete archived export implementation'):
            prepare(self.protocol_path, self.root / 'missing_entrypoint')
        self.assertFalse((self.root / 'missing_entrypoint').exists())

    def test_noninjective_projection_cannot_turn_original_goal_initially_true(self):
        for kind in ('predicate','constant'):
            with self.subTest(kind=kind):
                parent=self.root/kind; inputs=parent/'inputs'; model=parent/'fusion'
                inputs.mkdir(parents=True); (model/'problems').mkdir(parents=True)
                target=DOMAIN.replace('(domain old)','(domain target)')
                if kind=='predicate':
                    source=DOMAIN.replace('(p ?x - item)','(p ?x - item) (q ?x - item)').replace(':effect (p ?x)',':effect (q ?x)')
                    world=PROBLEM.replace('(:init)','(:init (p c))').replace('(:goal (p c))','(:goal (q c))')
                    predicates,constants={'p':'p','q':'p'},{'c':'c'}
                else:
                    source=DOMAIN.replace('(:constants c - item)','(:constants c d - item)')
                    world=PROBLEM.replace('(:init)','(:init (p c))').replace('(:goal (p c))','(:goal (p d))')
                    predicates,constants={'p':'p'},{'c':'c','d':'c'}
                (inputs/'A_domainfile.pddl').write_text(source,encoding='utf-8')
                (inputs/'A_problemfile.pddl').write_text(world,encoding='utf-8')
                (model/'meta_domain.pddl').write_text(target,encoding='utf-8')
                write(model/'meta_domain.json',{'sources':['A'],'predicate_maps':{'A':predicates},'constant_maps':{'A':constants}})
                raw_world=model/'problems/A_problemfile.pddl'
                raw_world.write_text('(define (problem world) (:domain target) (:init (p c)) (:goal (p c)))',encoding='utf-8')
                export_bundle(model/'meta_domain.pddl',[raw_world],model/'planning_export')
                validation={'planning_domain':'planning_export/domain.pddl','planning_problems':['planning_export/problems/A_problemfile.pddl']}
                native=PDDLReader().parse_problem(str(inputs/'A_domainfile.pddl'),str(inputs/'A_problemfile.pddl'))
                adapted=PDDLReader().parse_problem(str(model/'planning_export/domain.pddl'),str(model/'planning_export/problems/A_problemfile.pddl'))
                self.assertFalse(native.initial_value(native.goals[0]).is_true())
                self.assertTrue(adapted.initial_value(adapted.goals[0]).is_true())
                result=reference_worlds(parent,{'sources':['A']},validation)['A']
                self.assertEqual('unsupported_transport',result['admission_status'])
                self.assertIn('Non-injective',result['reason'])

    def test_active_parent_and_tampered_actual_export_rejected_before_output(self):
        self.manifest['status'] = 'running'; write(self.parent / 'manifest.json', self.manifest)
        self.report['status'] = 'starting'; write(self.parent / 'report.json', self.report)
        with self.assertRaisesRegex(ValueError, 'Active parent'):
            prepare(self.protocol_path, self.root / 'active')
        self.assertFalse((self.root / 'active').exists())
        self.manifest['status'] = self.report['status'] = 'complete'
        write(self.parent / 'manifest.json', self.manifest); write(self.parent / 'report.json', self.report)
        path = self.parent / 'fusion/planning_export/domain.pddl'
        path.write_bytes(path.read_bytes() + b'\n')
        with self.assertRaisesRegex(ValueError, 'Frozen artifact changed'):
            prepare(self.protocol_path, self.root / 'changed')
        self.assertFalse((self.root / 'changed').exists())

    def test_shared_failed_build_is_one_failure_and_no_control_only_rerun(self):
        self.manifest['status'] = self.report['status'] = 'worker_error'
        write(self.parent / 'manifest.json', self.manifest); write(self.parent / 'report.json', self.report)
        output = self.root / 'out'; prepare(self.protocol_path, output)
        with patch('scripts.experiments.evaluate_namespace_reference.run_solver') as solver:
            result = execute(output)
        solver.assert_not_called()
        self.assertEqual(1, result['construction_failure_count'])
        self.assertEqual(2, result['task_count'])
        self.assertEqual({'not_run_shared_parent_build_failure': 2}, result['status_counts'])

    def test_unrecorded_initial_fact_retained_as_unsupported_transport(self):
        raw = self.parent / 'fusion/problems/A_problemfile.pddl'
        raw.write_text(raw.read_text(encoding='utf-8').replace('(:init)', '(:init (p c))'), encoding='utf-8')
        output = self.root / 'out'; result = prepare(self.protocol_path, output)
        reference = next(row for row in result['slots'] if row['condition'] == REFERENCE)
        self.assertEqual('unsupported_transport', reference['admission_status'])
        self.assertIn('beyond recorded renaming', reference['reason'])
        with patch('scripts.experiments.evaluate_namespace_reference.run_solver') as solver:
            result = execute(output)
        solver.assert_not_called()
        self.assertEqual({'not_run_due_goal_budget': 1, 'unsupported_transport': 1}, result['status_counts'])

    def test_original_input_drift_and_missing_solver_rows_cannot_be_successful(self):
        output = self.root / 'out'; prepare(self.protocol_path, output)
        path = output / 'original_inputs/A_problemfile.pddl'
        path.write_bytes(path.read_bytes() + b'\n')
        with self.assertRaisesRegex(ValueError, 'Frozen artifact changed'):
            execute(output)
        self.protocol['budget']['whole_goal_stop_before_utc'] = '2099-01-01T00:00:00Z'
        write(self.protocol_path, self.protocol)
        other = self.root / 'other'; prepare(self.protocol_path, other)
        with patch('scripts.experiments.evaluate_namespace_reference.run_solver', return_value={'rows': []}):
            with self.assertRaisesRegex(ValueError, 'denominator differs'):
                execute(other)
        self.assertFalse((other / 'report.json').exists())

    def test_rotation_keeps_all_worlds_and_duplicate_or_escaping_ids_rejected(self):
        self.protocol.update(sources=['A', 'B'], world_count=2, slot_count=4)
        self.protocol['budget']['maximum_calls'] = 4
        rows = registered_slots(self.protocol)
        self.assertEqual(['native_source', REFERENCE, REFERENCE, 'native_source'], [r['condition'] for r in rows])
        self.protocol['sources'] = ['A', '../B']
        with self.assertRaisesRegex(ValueError, 'unique source/condition'):
            registered_slots(self.protocol)

    def test_wrong_build_budget_model_worker_count_or_archive_cannot_start_comparison(self):
        for index, (key,value) in enumerate((('budget_seconds',100), ('model','other-model'),
                ('node_workers',2), ('model_digest',None), ('condition','cache_continuation_extended_budget'))):
            current = dict(self.manifest); current[key] = value
            write(self.parent / 'manifest.json', current)
            with self.assertRaises(ValueError):
                prepare(self.protocol_path, self.root / ('bad' + str(index)))
            self.assertFalse((self.root / ('bad' + str(index))).exists())
        write(self.parent / 'manifest.json', self.manifest)
        incomplete = {**self.manifest, 'implementation_sha256':dict(self.manifest['implementation_sha256'])}
        incomplete['implementation_sha256'].pop('unidomain/models.py')
        write(self.parent / 'manifest.json', incomplete)
        with self.assertRaisesRegex(ValueError, 'complete archived'):
            prepare(self.protocol_path, self.root / 'missing_module')
        write(self.parent / 'manifest.json', self.manifest)
        archived = self.parent / 'implementation/unidomain/pipeline.py'
        archived.write_bytes(archived.read_bytes() + b'\n')
        with self.assertRaisesRegex(ValueError, 'Frozen artifact changed'):
            prepare(self.protocol_path, self.root / 'archive')
        self.assertFalse((self.root / 'archive').exists())

    def test_pilot_model_digest_must_match_full_build(self):
        build_path = Path(self.protocol['build_protocol'])
        build = json.loads(build_path.read_text(encoding='utf-8'))
        pilot = self.root / 'pilot'; pilot.mkdir()
        write(pilot / 'manifest.json', {'status':'complete', 'model_digest':'1' * 64})
        write(pilot / 'report.json', {'status':'complete', 'validation':{'valid':True}})
        build['pilot_output'] = str(pilot); write(build_path, build)
        self.protocol['build_protocol_sha256'] = digest(build_path); write(self.protocol_path, self.protocol)
        with self.assertRaisesRegex(ValueError, 'Parent/pilot model identity'):
            prepare(self.protocol_path, self.root / 'out')
        self.assertFalse((self.root / 'out').exists())

    def test_preflight_build_error_without_loaded_model_still_retains_shared_failure_slots(self):
        self.manifest['status'] = self.report['status'] = 'error'
        self.manifest.pop('model_digest')
        write(self.parent / 'manifest.json', self.manifest); write(self.parent / 'report.json', self.report)
        output = self.root / 'out'; result = prepare(self.protocol_path, output)
        self.assertFalse(result['parent_admitted'])
        self.assertEqual('error', result['parent_status'])
        self.assertEqual(1, result['construction_failure_count'])
        self.assertTrue(all(r['admission_status'] == 'not_run_shared_parent_build_failure' for r in result['slots']))

    def test_control_mapping_auxiliary_inputs_are_frozen_and_checked_before_preparation(self):
        auxiliary = self.root / 'auxiliary'; auxiliary.mkdir()
        path = auxiliary / 'provenance.json'; write(path, {'scope':'authored mapping fixture'})
        self.protocol.update(control_auxiliary_root=str(auxiliary),control_auxiliary_sha256={'provenance.json':digest(path)})
        write(self.protocol_path,self.protocol)
        output = self.root / 'out'; prepare(self.protocol_path,output)
        self.assertEqual(path.read_bytes(),(output / 'control_evidence/provenance.json').read_bytes())
        path.write_bytes(path.read_bytes() + b'\n')
        with self.assertRaisesRegex(ValueError,'Frozen artifact changed'):
            prepare(self.protocol_path,self.root / 'changed')
        self.assertFalse((self.root / 'changed').exists())

    def with_mock_solver(self):
        self.protocol['budget']['whole_goal_stop_before_utc'] = '2099-01-01T00:00:00Z'
        write(self.protocol_path,self.protocol)
        output = self.root / 'comparison'; prepare(self.protocol_path,output)
        def solver(inputs,composed,destination,planner,seconds,memory,task_bundle):
            destination.mkdir()
            tasks = json.loads((task_bundle / 'manifest.json').read_text(encoding='utf-8'))['tasks']
            rows = []
            for task in tasks:
                directory = destination / 'tasks' / task['id']; directory.mkdir(parents=True)
                for name in ('domain.pddl','problem.pddl'):
                    shutil.copyfile(task_bundle / 'tasks' / task['id'] / name,directory / name)
                plan = '(finish c)\n' if task['representation'] == 'native_source' else '(act__finish obj__c)\n'
                (directory / 'plan.txt').write_text(plan,encoding='utf-8')
                write(directory / 'command.json',['wsl','-d','Ubuntu','--cd',linux_path(directory),'--',
                    'timeout','--signal=TERM','--kill-after=5',str(seconds),'python3','/fixture/fast-downward.py',
                    '--alias','lama-first','--overall-time-limit',str(seconds)+'s',
                    '--overall-memory-limit',str(memory)+'M','--plan-file','plan.txt','domain.pddl','problem.pddl'])
                rows.append({'id':task['id'],'status':'solved','inputs_unchanged':True,'elapsed_seconds':0})
            write(destination / 'manifest.json',{'budget':{'wall_seconds':seconds,'overall_cpu_seconds':seconds,'memory_mb':memory}})
            result = {'status':'complete','rows':rows,'manifest_sha256':digest(destination / 'manifest.json'),
                **{key:True for key in ('binary_unchanged','runner_unchanged','implementation_unchanged','validator_unchanged')}}
            write(destination / 'report.json',result)
            return result
        with patch('scripts.experiments.evaluate_namespace_reference.run_solver',side_effect=solver):
            execute(output)
        return output

    def test_audit_validates_both_actual_plans_without_inventing_reference_native_inverse(self):
        output = self.with_mock_solver(); result = audit(output,self.root / 'audit')
        self.assertEqual('verified_fresh_reference_world_comparison',result['status'])
        self.assertEqual(2,result['actual_solver_calls'])
        self.assertEqual({'VALID':2},result['fresh_validation_counts'])
        self.assertEqual(1,result['native_replay_counts']['unverified_reference_action_inverse'])
        self.assertTrue(result['source_plan_artifacts_unchanged'])

    def test_audit_rejects_dropped_world_rows_and_actual_budget_override(self):
        output = self.with_mock_solver()
        report_path = output / 'report.json'; report = json.loads(report_path.read_text(encoding='utf-8'))
        original = copy_report = json.loads(json.dumps(report))
        report['rows'].pop(); write(report_path,report)
        with self.assertRaisesRegex(ValueError,'source-world denominator'):
            audit(output,self.root / 'missing')
        write(report_path,original)
        command_path = output / 'solver/tasks/A__native_source/command.json'
        command = json.loads(command_path.read_text(encoding='utf-8'))
        command[command.index('--overall-time-limit') + 1] = '200s'; write(command_path,command)
        with self.assertRaisesRegex(ValueError,'Actual solver command'):
            audit(output,self.root / 'budget')

    def test_audit_rejects_actual_reference_model_drift_even_if_plan_would_still_parse(self):
        output = self.with_mock_solver()
        model = output / 'solver/tasks' / ('A__' + REFERENCE) / 'domain.pddl'
        model.write_bytes(model.read_bytes() + b'\n')
        with self.assertRaisesRegex(ValueError,'Actual solver input changed'):
            audit(output,self.root / 'changed')

    def test_audit_keeps_shared_build_failure_separate_from_two_unavailable_world_slots(self):
        self.manifest['status'] = self.report['status'] = 'worker_error'
        write(self.parent / 'manifest.json',self.manifest); write(self.parent / 'report.json',self.report)
        output = self.root / 'out'; prepare(self.protocol_path,output); execute(output)
        result = audit(output,self.root / 'audit')
        self.assertEqual('verified_fresh_reference_world_comparison',result['status'])
        self.assertEqual(1,result['construction_failure_count']); self.assertEqual(0,result['actual_solver_calls'])
        self.assertEqual({'not_run_shared_parent_build_failure':2},result['status_counts'])


if __name__ == '__main__':
    unittest.main()

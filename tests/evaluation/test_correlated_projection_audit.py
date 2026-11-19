from collections import Counter
import json
from pathlib import Path
import shutil
import tempfile
import unittest

from rcnc.domain_building import digest
from scripts.audit.audit_correlated_projection import audit


DOMAIN = '''(define (domain d) (:requirements :typing :strips) (:types item)
    (:constants c - item) (:predicates (p ?x - item))
    (:action finish :parameters (?x - item) :precondition (and) :effect (p ?x)))'''
PROBLEM = '(define (problem q) (:domain d) (:init) (:goal (p c)))'
VARIANTS = ('cartesian_projection', 'positive_tuple_join')


def save(path, value):
    path.write_text(json.dumps(value), encoding='utf-8')


class CorrelatedProjectionAuditTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(); self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name); self.root = self.base / 'run'; self.root.mkdir()
        cohorts, inputs = [], []
        groups = [('full', ['aligned_selected_sources','zero_merge_same_source_action_sets']),
                  ('recompiled', ['aligned_selected_recompiled','zero_merge_selected_recompiled'])]
        for cohort, conditions in groups:
            origin = self.base / cohort; origin.mkdir()
            originals = []
            for index in range(6):
                for condition in conditions:
                    task = {'id':f'p{index}__{condition}', 'pair_id':f'p{index}', 'condition':condition}
                    source = origin / 'bundle/tasks' / task['id']; source.mkdir(parents=True)
                    local_id = cohort + '__' + task['id']
                    local = self.root / 'tasks' / local_id; local.mkdir(parents=True)
                    for name, text in (('domain',DOMAIN), ('problem',PROBLEM)):
                        (source / (name + '.pddl')).write_text(text, encoding='utf-8')
                        shutil.copyfile(source / (name + '.pddl'), local / (name + '.pddl'))
                        task[name + '_sha256'] = digest(local / (name + '.pddl'))
                    originals.append(task)
                    inputs.append({**task, 'id':local_id, 'origin_task':task['id'], 'cohort':cohort})
            save(origin / 'manifest.json', {'tasks':originals})
            cohorts.append({'name':cohort, 'path':str(origin), 'conditions':conditions,
                            'manifest_sha256':digest(origin / 'manifest.json')})
        self.protocol = {'cohorts':cohorts, 'variants':list(VARIANTS),
            'budget':{'search':{'max_states':5000}, 'wall_seconds_per_process':20}}
        save(self.root / 'protocol.json', self.protocol)
        archived = self.root / 'implementation/rcnc/validation.py'; archived.parent.mkdir(parents=True)
        shutil.copyfile('rcnc/validation.py', archived)
        tasks = []
        for index, task in enumerate(inputs):
            for variant in (VARIANTS if index % 2 == 0 else VARIANTS[::-1]):
                tasks.append({**task, 'input_id':task['id'], 'id':task['id'] + '__' + variant,
                    'variant':variant, 'correlated_parameter_tuples':variant == VARIANTS[1]})
        self.manifest = {'task_count':48, 'tasks':tasks, 'variants':list(VARIANTS), 'scope':'authored audit fixture',
            'budget':self.protocol['budget'], 'protocol_sha256':digest(self.root / 'protocol.json'),
            'implementation_sha256':{'rcnc/validation.py':digest(archived)}}
        save(self.root / 'manifest.json', self.manifest)
        self.report = {'status':'complete', 'manifest_sha256':digest(self.root / 'manifest.json'),
            'task_count':48, 'world_count':6, 'unique_pddl_inputs':24,
            'inputs_unchanged':True, 'implementation_unchanged':True, 'actual_search_processes':0,
            'rows':[{**task, 'status':'not_run_due_goal_budget'} for task in tasks]}
        self.write_report()

    def write_report(self):
        self.report['status_counts'] = dict(Counter(r['status'] for r in self.report['rows']))
        self.report['by_variant'] = {v:dict(Counter(r['status'] for r in self.report['rows'] if r['variant'] == v)) for v in self.protocol['variants']}
        save(self.root / 'report.json', self.report)

    def actual_processes(self):
        self.report['actual_search_processes'] = 48
        for row in self.report['rows']:
            row['status'] = 'time_limit'
            actual = self.root / 'searches' / row['id']; actual.mkdir(parents=True)
            source = self.root / 'tasks' / row['input_id']
            budget = {**self.protocol['budget']['search'], 'correlated_parameter_tuples':row['correlated_parameter_tuples']}
            save(actual / 'command.json', ['python','-m','rcnc','plan','--worker','--solver','state_projected',
                '--domain',str(source / 'domain.pddl'),'--problem',str(source / 'problem.pddl'),
                '--output',str(actual),'--budget',json.dumps(budget)])
        self.write_report()

    def test_zero_search_gate_is_verified_without_promoting_it_to_executed_matrix(self):
        result = audit(self.root, self.base / 'audit')
        self.assertEqual('verified_correlated_projection', result['status'])
        self.assertEqual(0, result['actual_search_processes'])
        self.assertEqual({'not_run_due_goal_budget':48}, result['status_counts'])

    def test_every_saved_plan_revalidated_and_missing_arguments_are_not_valid(self):
        self.actual_processes()
        row = self.report['rows'][0]; actual = self.root / 'searches' / row['id']
        source = self.root / 'tasks' / row['input_id']
        for name in ('domain.pddl','problem.pddl'): shutil.copyfile(source / name, actual / name)
        plan = actual / 'plan.txt'; plan.write_text('(finish c)\n', encoding='utf-8')
        search = {'status':'solved', 'length':1, 'budget':{**self.protocol['budget']['search'],
            'correlated_parameter_tuples':row['correlated_parameter_tuples']}}
        save(actual / 'search.json', search); row.update(search); self.write_report()
        first = audit(self.root, self.base / 'valid')
        self.assertEqual('verified_correlated_projection', first['status'])
        self.assertEqual({'VALID':1,'NO_PLAN':47}, first['fresh_validation_counts'])
        self.assertEqual(1, first['rows'][0]['full_actual_parameters'])
        self.assertTrue(first['source_plan_artifacts_unchanged'])
        plan.write_text('(finish)\n', encoding='utf-8')
        second = audit(self.root, self.base / 'truncated')
        self.assertEqual('audited_with_violations', second['status'])
        self.assertNotEqual('VALID', second['rows'][0]['fresh_validation']['status'])
        self.assertTrue(second['audit_failures'])

    def test_dropped_slot_forged_summary_and_partial_execution_are_rejected(self):
        self.report['rows'].pop(); self.write_report()
        with self.assertRaisesRegex(ValueError, '48-slot'):
            audit(self.root, self.base / 'missing')
        self.report['rows'].append({**self.manifest['tasks'][-1], 'status':'not_run_due_goal_budget'}); self.write_report()
        self.report['status_counts'] = {'solved':48}; save(self.root / 'report.json', self.report)
        with self.assertRaisesRegex(ValueError, 'summary differs'):
            audit(self.root, self.base / 'forged')
        self.report['rows'][0]['status'] = 'time_limit'; self.write_report()
        with self.assertRaisesRegex(ValueError, 'Partial matrix'):
            audit(self.root, self.base / 'partial')

    def test_actual_worker_budget_and_frozen_input_changes_are_rejected(self):
        self.actual_processes()
        row = self.report['rows'][0]; command_path = self.root / 'searches' / row['id'] / 'command.json'
        command = json.loads(command_path.read_text(encoding='utf-8'))
        command[-1] = json.dumps({'max_states':1, 'correlated_parameter_tuples':False})
        save(command_path, command)
        with self.assertRaisesRegex(ValueError, 'strategy or search budget'):
            audit(self.root, self.base / 'budget')
        command[-1] = json.dumps({**self.protocol['budget']['search'], 'correlated_parameter_tuples':False})
        save(command_path, command)
        path = self.root / 'tasks' / row['input_id'] / 'domain.pddl'
        path.write_bytes(path.read_bytes() + b'\n')
        with self.assertRaisesRegex(ValueError, 'registered input differs'):
            audit(self.root, self.base / 'input')

    def test_witness_registry_does_not_relabel_the_old_tuple_join_condition(self):
        field = 'precondition_witness_representatives'
        self.protocol.update(strategy_field=field, variants=['cartesian_projection','precondition_witness'])
        save(self.root / 'protocol.json', self.protocol)
        self.manifest.update(strategy_field=field, variants=self.protocol['variants'],
                             protocol_sha256=digest(self.root / 'protocol.json'))
        for tasks in (self.manifest['tasks'], self.report['rows']):
            for task in tasks:
                task[field] = task.pop('correlated_parameter_tuples')
                task['id'] = task['id'].replace('__positive_tuple_join','__precondition_witness')
                if task['variant'] == 'positive_tuple_join': task['variant'] = 'precondition_witness'
        save(self.root / 'manifest.json', self.manifest)
        self.report.update(strategy_field=field, manifest_sha256=digest(self.root / 'manifest.json'))
        self.write_report()
        result = audit(self.root, self.base / 'witness')
        self.assertEqual('verified_correlated_projection', result['status'])
        self.assertEqual(field, result['strategy_field'])
        self.assertEqual({'not_run_due_goal_budget':24}, result['by_variant']['precondition_witness'])


if __name__ == '__main__':
    unittest.main()

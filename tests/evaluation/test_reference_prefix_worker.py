import hashlib
import json
from pathlib import Path
import tempfile
import unittest

from scripts.experiments.reference_prefix_worker import run


class ReferencePrefixWorkerTests(unittest.TestCase):
    def test_executable_prefix_pass_does_not_require_or_claim_original_goal_attainment(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp)
            files={
                'source_domain.pddl':'''(define (domain s) (:requirements :strips :typing)
                    (:types prefix_t) (:constants a - prefix_t)
                    (:predicates (p ?x - prefix_t) (q ?x - prefix_t) (unreachable))
                    (:action finish :parameters (?x - prefix_t) :precondition (p ?x)
                        :effect (and (not (p ?x)) (q ?x))))''',
                'source_problem.pddl':'(define (problem s) (:domain s) (:init (p a)) (:goal (unreachable)))',
                'target_domain.pddl':'''(define (domain d) (:requirements :strips :typing)
                    (:types prefix_u) (:constants z - prefix_u)
                    (:predicates (rp ?x - prefix_u) (rq ?x - prefix_u) (runreachable))
                    (:action mapped :parameters (?x - prefix_u) :precondition (rp ?x)
                        :effect (and (not (rp ?x)) (rq ?x))))''',
                'target_problem.pddl':'(define (problem d) (:domain d) (:init (rp z)) (:goal (runreachable)))',
                'source.plan':'(finish a)\n'}
            for name,text in files.items():(root/name).write_text(text,encoding='utf-8')
            job={key:str(root/filename) for key,filename in (
                ('source_domain','source_domain.pddl'),('source_problem','source_problem.pddl'),
                ('target_domain','target_domain.pddl'),('target_problem','target_problem.pddl'),('source_plan','source.plan'))}
            job.update(output=str(root/'out'),objects={'a':'z'},predicates={'p':'rp','q':'rq','unreachable':'runreachable'},
                actions={'finish':{'target':'mapped','positions':[0]}},max_atoms=100,
                input_sha256={str(root/n):hashlib.sha256((root/n).read_bytes()).hexdigest() for n in files})
            path=root/'job.json';path.write_text(json.dumps(job),encoding='utf-8')
            result=run(path)
            self.assertEqual('PASS',result['status'])
            self.assertEqual(6,result['truth_comparisons'])
            self.assertEqual('not_requested_source_prefix_only',result['goal_evaluation'])
            self.assertNotIn('task_success',result)
            job.update(output=str(root/'public'),applicability_policy='public_is_applicable')
            path.write_text(json.dumps(job),encoding='utf-8')
            public=run(path)
            self.assertEqual(('PASS',6,'public_is_applicable'),
                (public['status'],public['truth_comparisons'],public['applicability_policy']))
            target=root/'target_domain.pddl'
            changed=target.read_text(encoding='utf-8').replace('(runreachable))','(runreachable) (required))')
            changed=changed.replace(':precondition (rp ?x)',':precondition (and (rp ?x) (required))')
            target.write_text(changed,encoding='utf-8')
            job['input_sha256'][str(target)]=hashlib.sha256(target.read_bytes()).hexdigest()
            job['output']=str(root/'blocked')
            path.write_text(json.dumps(job),encoding='utf-8')
            blocked=run(path)
            self.assertEqual(('FAIL',True,False),
                (blocked['status'],blocked['source_applicable'],blocked['target_applicable']))


if __name__=='__main__':unittest.main()

import copy
import unittest
import tempfile
from pathlib import Path

from rcnc.pddl import parse_sexpr, section, serialize
from scripts.data.prepare_action_reachability import instrument, audit_instrumentation, MARKER


class ActionMonitorTests(unittest.TestCase):
    def setUp(self):
        self.domain = parse_sexpr('(define (domain d) (:requirements :strips :conditional-effects) (:predicates (p) (q)) (:action a :parameters () :precondition (p) :effect (when (q) (not (p)))))')
        self.problem = parse_sexpr('(define (problem p) (:domain d) (:init (p)) (:goal (q)))')

    def test_observer_preserves_original_conditional_effect_and_world(self):
        before = copy.deepcopy(self.domain)
        edited, query = instrument(self.domain, self.problem, 'a')
        self.assertEqual(self.domain, before)
        self.assertEqual(section(query, ':init'), section(self.problem, ':init'))
        self.assertTrue(audit_instrumentation(self.domain, self.problem, edited, query, 'a'))

    def test_unrelated_change_is_rejected(self):
        edited, query = instrument(self.domain, self.problem, 'a')
        section(query, ':init').append(['q'])
        with self.assertRaises(ValueError):
            audit_instrumentation(self.domain, self.problem, edited, query, 'a')

    def test_collision_rejected(self):
        section(self.domain, ':predicates').append([MARKER])
        with self.assertRaises(ValueError):
            instrument(self.domain, self.problem, 'a')

    def test_marker_records_invocation_even_when_conditional_guard_false(self):
        from unified_planning.io import PDDLReader
        from unified_planning.shortcuts import SequentialSimulator
        edited, query = instrument(self.domain, self.problem, 'a')
        with tempfile.TemporaryDirectory() as tmp:
            directory = Path(tmp)
            (directory/'domain.pddl').write_text(serialize(edited), encoding='utf-8')
            (directory/'problem.pddl').write_text(serialize(query), encoding='utf-8')
            model = PDDLReader().parse_problem(str(directory/'domain.pddl'), str(directory/'problem.pddl'))
            with SequentialSimulator(model) as sim:
                initial = sim.get_initial_state()
                self.assertFalse(initial.get_value(model.fluent(MARKER)()).bool_constant_value())
                final = sim.apply(initial, model.action('a'), ())
                self.assertTrue(final.get_value(model.fluent(MARKER)()).bool_constant_value())
                self.assertTrue(final.get_value(model.fluent('p')()).bool_constant_value())

    def test_complete_prefix_audit_and_fixed_union_replay(self):
        from scripts.data.prepare_action_reachability import freeze
        from scripts.audit.audit_action_reachability import run as audit
        from scripts.experiments.replay_action_reachability import run as replay
        from rcnc.domain_union import build
        from scripts.experiments.run_downward_reference import save, sha
        import shutil
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            inputs = root/'inputs'
            inputs.mkdir()
            (inputs/'ONE_domainfile.pddl').write_text(serialize(self.domain), encoding='utf-8')
            (inputs/'ONE_problemfile.pddl').write_text(serialize(self.problem), encoding='utf-8')
            bundle, solved = root/'bundle', root/'solved'
            manifest = freeze(inputs, bundle)
            task = manifest['tasks'][0]
            execution = solved/'tasks'/task['id']
            execution.mkdir(parents=True)
            for filename in ['domain.pddl', 'problem.pddl']:
                shutil.copyfile(bundle/'tasks'/task['id']/filename, execution/filename)
            (execution/'plan.txt').write_text('(a)\n', encoding='utf-8')
            save(solved/'manifest.json', {'task_bundle_manifest_sha256': sha(bundle/'manifest.json')})
            save(solved/'report.json', {'status': 'complete', 'rows': [{'id': task['id'], 'status': 'solved'}]})
            audited = audit(bundle, solved, root/'audit')
            self.assertEqual(audited['status_counts'], {'PASS': 1})
            self.assertEqual(audited['states_compared'], 2)
            self.assertTrue(build(inputs, root/'union')['valid'])
            translated = replay(bundle, solved, root/'audit', root/'union', root/'replay')
            self.assertEqual(translated['counts'], {'PASS': 1})
            self.assertTrue(translated['hashes_unchanged'])


if __name__ == '__main__':
    unittest.main()

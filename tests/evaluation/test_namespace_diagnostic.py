from pathlib import Path
import tempfile
import unittest

from scripts.audit.diagnose_pddl_namespace import run


class NamespaceDiagnosticTests(unittest.TestCase):
    def test_name_policy_change_does_not_mutate_model_or_global_environment(self):
        from unified_planning.environment import get_environment
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            path = root / 'domain.pddl'
            text = '''(define (domain overlap) (:requirements :typing)
              (:types entity) (:predicates (entity ?x - entity)))'''
            path.write_text(text, encoding='utf-8')
            original = get_environment().error_used_name
            report = run(path, root / 'out')
            self.assertTrue(report['strict_error_relaxed_parsed'])
            self.assertEqual(text, path.read_text(encoding='utf-8'))
            self.assertEqual(original, get_environment().error_used_name)
            self.assertTrue(report['inputs_unchanged'])


if __name__ == '__main__':
    unittest.main()

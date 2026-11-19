"""The command index must work before optional solver/model packages are installed."""
from pathlib import Path
import subprocess
import sys
import unittest


ROOT = Path(__file__).resolve().parents[2]


class PackageCommandTests(unittest.TestCase):
    def test_help_and_invalid_command_do_not_load_planning_dependencies(self):
        for arguments, expected in [(['--help'], 0), (['unknown-command'], 2), ([], 2)]:
            with self.subTest(arguments=arguments):
                result = subprocess.run([sys.executable, '-S', '-m', 'rcnc', *arguments],
                    cwd=ROOT, capture_output=True, text=True)
                self.assertEqual(expected, result.returncode, result.stderr)
                self.assertNotIn('ModuleNotFoundError', result.stderr)
                self.assertIn('build-union', result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()

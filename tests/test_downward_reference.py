import tempfile
from pathlib import Path
import unittest
from unittest.mock import patch

from scripts.experiments.run_downward_reference import exit_status, freeze, linux_path


class DownwardReferenceTests(unittest.TestCase):
    def test_incomplete_bounds_and_limits_are_not_unqualified_unsolvable(self):
        self.assertEqual('unsolvable', exit_status(10))
        self.assertEqual('unsolvable', exit_status(11))
        self.assertEqual('incomplete', exit_status(12))
        self.assertEqual('unsolvable_within_bound', exit_status(13))
        for code in (20, 21, 22, 23, 24, 124, 137):
            self.assertNotEqual('unsolvable', exit_status(code))
        self.assertEqual('plan_found_time_limit', exit_status(2))
        self.assertEqual('unsupported', exit_status(34))

    def test_missing_binary_never_starts_or_labels_a_run(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            with self.assertRaisesRegex(ValueError, 'not built'):
                freeze(root/'input', None, root/'out', root/'planner', 60, 4096)
            self.assertFalse((root/'out').exists())

    @unittest.skipUnless(Path.cwd().drive, 'Windows-to-WSL path contract')
    def test_windows_paths_preserve_spaces_as_a_single_argument(self):
        self.assertEqual('/mnt/c/a path/domain.pddl', linux_path(Path('C:/a path/domain.pddl')))


if __name__ == '__main__':
    unittest.main()

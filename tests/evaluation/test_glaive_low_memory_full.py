import unittest
from scripts.experiments import run_glaive_low_memory_full as runner


class LowMemorySupervisorTests(unittest.TestCase):
    def test_signal_without_deadline_is_not_timeout(self):
        for code in (-9, -15, 137):
            self.assertEqual(runner.process_status({'deadline_triggered': False, 'returncode': code}, ''), 'terminated_by_signal')

    def test_actual_deadline_is_recorded_even_with_clean_shutdown(self):
        for code in (0, -15, -9):
            self.assertEqual(runner.process_status({'deadline_triggered': True, 'returncode': code}, ''), 'wall_time_limit')

    def test_heap_failure_stays_separate(self):
        self.assertEqual(runner.process_status({'deadline_triggered': False, 'returncode': 1}, 'java.lang.OutOfMemoryError'), 'memory_limit')

    def test_parse_failure_stays_separate(self):
        self.assertEqual(runner.process_status({'deadline_triggered': False, 'returncode': 1}, 'FormatException'), 'native_parse_error')

    def test_concurrency_leaves_memory_headroom(self):
        self.assertEqual(runner.WORKERS, 2)
        self.assertEqual(runner.WORKERS*runner.HEAP_MB, 8192)

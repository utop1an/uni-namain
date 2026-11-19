from datetime import datetime
import unittest
from scripts.audit.package_glaive_initialization_results import memory_events, losses


class InitializationPacketTests(unittest.TestCase):
    def test_oom_windows_use_timezone_and_exclude_invocation_notice(self):
        log = '\n'.join([
            '2026-11-08T21:58:50,552799+11:00 snapfuse invoked oom-killer',
            '2026-11-08T21:58:50,571916+11:00 Out of memory: Killed process 123 (java)',
            '2026-11-08T22:10:00,000000+11:00 Out of memory: Killed process 456 (java)'])
        result = memory_events(log, datetime.fromisoformat('2026-11-08T10:57:00+00:00'),
                               datetime.fromisoformat('2026-11-08T11:00:00+00:00'))
        self.assertEqual(len(result), 1)
        self.assertIn('123', result[0])

    def test_empty_oom_window_is_not_a_claim_about_other_windows(self):
        log = '2026-11-08T21:58:50,571916+11:00 Out of memory: Killed process 123 (java)'
        self.assertEqual(memory_events(log, datetime.fromisoformat('2026-11-08T12:00:00+00:00'),
                                       datetime.fromisoformat('2026-11-08T12:30:00+00:00')), [])

    def test_native_loss_kept_separate_from_dual_loss(self):
        rows = [{'kind': 'anchor', 'id': 'same', 'before': {'native_valid': True, 'valid': False},
                 'after': {'native_valid': False, 'valid': False}}]
        self.assertEqual(losses(rows, 'native_valid'), [{'kind': 'anchor', 'id': 'same'}])
        self.assertEqual(losses(rows, 'valid'), [])

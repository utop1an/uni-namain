from copy import deepcopy
from datetime import datetime, timedelta, timezone
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from rcnc.interface_annotation import digest
from scripts.experiments.run_downward_reference import sha
from scripts.experiments.run_interface_budget_pair import check_admission, prepare


class InterfaceBudgetPairTests(unittest.TestCase):
    def admission(self):
        now = datetime(2026, 10, 22, 22, tzinfo=timezone.utc)
        protocol = {'reference_identity': {'source_count': 15, 'budget_seconds': 10800},
            'admission_quiet_seconds': 60, 'budget': {'total_seconds_per_condition': 600,
                'whole_goal_stop_before_utc': (now + timedelta(hours=2)).isoformat()}}
        manifest = {'source_count': 15, 'budget_seconds': 10800, 'status': 'time_limit',
            'finished_utc': (now - timedelta(seconds=90)).isoformat()}
        report = {'status': 'time_limit', 'finished_utc': manifest['finished_utc'],
            'implementation_unchanged': True, 'source_snapshot_unchanged': True}
        return protocol, manifest, report, now

    def test_active_or_changed_reference_and_late_admission_are_rejected(self):
        protocol, manifest, report, now = self.admission()
        check_admission(protocol, manifest, report, now)
        changed = deepcopy(manifest)
        changed['status'] = 'running'
        with self.assertRaises(ValueError):
            check_admission(protocol, changed, report, now)
        changed = deepcopy(manifest)
        changed['source_count'] = 14
        with self.assertRaises(ValueError):
            check_admission(protocol, changed, report, now)
        with self.assertRaises(ValueError):
            check_admission(protocol, manifest, report, now - timedelta(seconds=60))
        with self.assertRaises(ValueError):
            check_admission(protocol, manifest, report, now + timedelta(minutes=110))

    def test_prepare_freezes_both_complete_request_sets_without_network(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            packet = {'items': [{'id': str(i), 'sides': [
                {'parameters': ['?x'], 'action_contexts': []}, {'parameters': ['?x'], 'action_contexts': []}]} for i in range(100)]}
            source = root / 'packet.json'
            source.write_text(json.dumps(packet), encoding='utf-8')
            protocol = {'packet': str(source), 'packet_file_sha256': sha(source), 'packet_sha256': digest(packet),
                'conditions': ['free_fields', 'coupled_fields'], 'model': 'existing',
                'options': {'temperature': 0}, 'budget': {'max_candidates_per_condition': 100, 'workers': 1},
                'scope': 'unit fixture only'}
            path = root / 'protocol.json'
            path.write_text(json.dumps(protocol), encoding='utf-8')
            with patch('scripts.experiments.run_interface_budget_pair.request_json', side_effect=AssertionError('No inference during freeze')):
                manifest = prepare(path, root / 'out')
            self.assertEqual(200, len(list((root / 'out/frozen_requests').glob('*/*.json'))))
            left = json.loads((root / 'out/frozen_requests/free_fields/0.json').read_text())
            right = json.loads((root / 'out/frozen_requests/coupled_fields/0.json').read_text())
            self.assertNotEqual(left.pop('format'), right.pop('format'))
            self.assertEqual(left, right)
            self.assertEqual('frozen_before_live_requests', manifest['status'])


if __name__ == '__main__':
    unittest.main()

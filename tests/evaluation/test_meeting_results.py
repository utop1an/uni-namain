import json
from pathlib import Path
import tempfile
import unittest

from scripts.evidence.build_meeting_results import build as summarize
from scripts.evidence.build_meeting_results import phase


class MeetingResultTests(unittest.TestCase):
    def test_running_experiment_cannot_be_published_as_complete_meeting_results(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            for name, value in [('matched/report.json', {'status': 'running'}),
                                ('matched/solver/manifest.json', {}), ('matched/bundle/manifest.json', {}),
                                ('replay/report.json', {}), ('historical/results.json', {})]:
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(json.dumps(value), encoding='utf-8')
            with self.assertRaises(ValueError):
                summarize(root / 'matched', root / 'replay', root / 'historical', root / 'output')
            self.assertFalse((root / 'output/results.json').exists())

    def test_logged_phase_recognizes_release_search_and_translation_cutoffs(self):
        with tempfile.TemporaryDirectory() as td:
            directory = Path(td)
            log = directory / 'planner.log'
            log.write_text('INFO Running translator.\nINFO Running search (release).', encoding='utf-8')
            self.assertEqual('search', phase(directory))
            log.write_text('INFO Running translator.\nTranslating task...', encoding='utf-8')
            self.assertEqual('translation', phase(directory))

import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from scripts.evidence.build_paper_results import checked_report
from scripts.experiments.replay_source_probes import sha


class PaperResultTests(unittest.TestCase):
    def test_relocated_frozen_report_still_requires_original_hash(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root/'scripts/evidence').mkdir(parents=True)
            records = root/'paper/records'
            records.mkdir(parents=True)
            moved = records/'report.json'
            report = {'status': 'complete'}
            moved.write_text(json.dumps(report), encoding='utf-8')
            (records/'relocation.json').write_text(json.dumps({'paths': {
                'paper/old.json': 'paper/records/report.json'
            }}), encoding='utf-8')
            original = root/'paper/old.json'
            entry = {'path': str(original), 'sha256': sha(moved),
                     'terminal_status': 'complete'}
            with patch('scripts.evidence.build_paper_results.__file__',
                       str(root/'scripts/evidence/build_paper_results.py')):
                self.assertEqual(report, checked_report(entry))
                moved.write_text('{"status": "changed"}', encoding='utf-8')
                with self.assertRaisesRegex(ValueError, 'Pinned report changed'):
                    checked_report(entry)
                moved.write_text(json.dumps(report), encoding='utf-8')
                original.write_text('{"status": "changed"}', encoding='utf-8')
                with self.assertRaisesRegex(ValueError, 'Pinned report changed'):
                    checked_report(entry)

    def test_rejects_incomplete_or_miscounted_report_even_with_updated_hash(self):
        with tempfile.TemporaryDirectory() as temp:
            path=Path(temp)/'report.json'
            report={'status':'complete','task_count':2,'rows':[{'id':'a','status':'solved'}],
                    'counts':{'solved':1}}
            path.write_text(json.dumps(report),encoding='utf-8')
            entry={'path':str(path),'sha256':sha(path),'terminal_status':'complete',
                   'denominator':'task_count','count_field':'counts'}
            with self.assertRaisesRegex(ValueError,'denominator'):
                checked_report(entry)
            report['rows'].append({'id':'b','status':'unsolvable'})
            path.write_text(json.dumps(report),encoding='utf-8');entry['sha256']=sha(path)
            with self.assertRaisesRegex(ValueError,'count differs'):
                checked_report(entry)
            report['counts']['unsolvable']=1
            path.write_text(json.dumps(report),encoding='utf-8');entry['sha256']=sha(path)
            self.assertEqual(report,checked_report(entry))


if __name__=='__main__':
    unittest.main()

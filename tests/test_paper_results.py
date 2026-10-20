import json
from pathlib import Path
import tempfile
import unittest
from scripts.evidence.build_paper_results import checked_report
from scripts.experiments.replay_source_probes import sha


class PaperResultTests(unittest.TestCase):
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

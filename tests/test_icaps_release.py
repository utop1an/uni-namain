from pathlib import Path
import tempfile
import unittest

from rcnc.domain_building import digest
from rcnc.glaive_merge import build
from scripts.evidence.reproduce_icaps_release import DEFAULT, load_sources, read, verify


class CompactReleaseTests(unittest.TestCase):
    def test_complete_final_evidence_and_saved_plans_recheck(self):
        result=verify(DEFAULT)
        self.assertEqual('verified_compact_release',result['status'])
        self.assertEqual(420,result['composition_rows'])
        self.assertEqual(33,result['native_plans_physically_replayed'])
        self.assertEqual(11,result['long_case_steps'])

    def test_long_case_uses_the_same_rebuildable_parameterized_model(self):
        gid='k04_0218ded14bc9db22'
        groups=read(DEFAULT/'groups.json')['groups']
        group=next(g for g in groups if g['id']==gid)
        consensus=next(r['groups'] for r in read(DEFAULT/'consensus.json')['rows'] if r['group']==gid)
        sources=load_sources(DEFAULT)
        with tempfile.TemporaryDirectory() as temp:
            folder=Path(temp)/'model'
            result=build([sources[s] for s in group['sources']],folder,groups=consensus,merge_actions=True)
            self.assertEqual(digest(DEFAULT/'long_case/domain.pddl'),digest(folder/'domain.pddl'))
            self.assertEqual(19,result['action_count'])


if __name__=='__main__':unittest.main()

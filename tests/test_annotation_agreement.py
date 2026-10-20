import copy
import unittest
from rcnc.annotation_agreement import agreement
from rcnc.interface_annotation import digest


class AgreementTests(unittest.TestCase):
    def packet(self):
        return {'items':[{'id':str(i),'sides':[{'parameters':['x','y'],
            'action_contexts':[{'ref':'act','text':'(p x y)'}]} for _ in range(2)]} for i in range(3)]}

    def annotations(self, packet, who, labels):
        return {'packet_sha256':digest(packet),'annotator_id':who,
            'independent_of_model_and_solver_outcomes':True,
            'rows':[{'candidate_id':str(i),'status':'completed','label':label,
                'right_from_left':[0,1] if label=='equivalent' else None,
                'rationale':'Synthetic calculation control','date':'2026-10-15',
                'evidence':[{'side':side,'ref':'act','quote':'(p x y)'} for side in (0,1)]}
                for i,label in enumerate(labels)]}

    def test_known_kappa_and_missing_not_disagreement(self):
        p=self.packet()
        a=self.annotations(p,'a',['equivalent','equivalent','incompatible'])
        b=self.annotations(p,'b',['equivalent','incompatible','incompatible'])
        r=agreement(p,[a,b])
        self.assertAlmostEqual(.4,r['cohen_kappa'])
        self.assertEqual(['1'],r['disagreement_ids'])
        b['rows'][1].update(status='unreviewed',label=None,right_from_left=None)
        r=agreement(p,[a,b])
        self.assertEqual(2,r['paired_completed'])
        self.assertEqual(1,r['raw_agreement'])

    def test_no_labels_and_constant_marginals_do_not_fabricate_scores(self):
        p=self.packet()
        self.assertIsNone(agreement(p,[])['raw_agreement'])
        a=self.annotations(p,'a',['uncertain']*3)
        b=copy.deepcopy(a);b['annotator_id']='b'
        r=agreement(p,[a,b])
        self.assertEqual(1,r['raw_agreement'])
        self.assertIsNone(r['cohen_kappa'])
        self.assertEqual('distinct_annotator_ids_required',agreement(p,[a,a])['status'])


if __name__ == '__main__':
    unittest.main()

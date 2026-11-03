import copy
import unittest

from rcnc.revised_sampling import balanced_chains,materialize_groups,validate_sampling


class RevisedSamplingTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.ids=['source_'+str(i).zfill(2) for i in range(60)]
        cls.chains,cls.trace=balanced_chains(cls.ids,seed='sampling-test')
        cls.groups=materialize_groups(cls.chains)

    def test_all_sizes_have_unique_nested_balanced_groups(self):
        report=validate_sampling(self.chains,self.groups,self.ids,chain_count=100,max_size=10,pair_cap=12)
        self.assertEqual(len(self.groups),900)
        self.assertEqual([r['groups'] for r in report],[100]*9)
        self.assertTrue(all(r['unique_sources']==60 for r in report))
        self.assertTrue(all(r['source_frequency_max']-r['source_frequency_min']<=1 for r in report))

    def test_input_permutation_does_not_change_sampling(self):
        chains,trace=balanced_chains(list(reversed(self.ids)),seed='sampling-test')
        self.assertEqual(chains,self.chains);self.assertEqual(trace,self.trace)

    def test_seed_changes_sequences(self):
        chains,_=balanced_chains(self.ids,seed='another-sampling-test')
        self.assertNotEqual(chains,self.chains)

    def test_broken_nesting_is_rejected(self):
        groups=copy.deepcopy(self.groups);groups[0]['prefix_order'].reverse()
        with self.assertRaisesRegex(ValueError,'nesting'):
            validate_sampling(self.chains,groups,self.ids,chain_count=100,max_size=10,pair_cap=12)

    def test_duplicate_groups_are_rejected(self):
        groups=copy.deepcopy(self.groups);groups[9]=copy.deepcopy(groups[0])
        with self.assertRaisesRegex(ValueError,'Duplicate'):
            validate_sampling(self.chains,groups,self.ids,chain_count=100,max_size=10,pair_cap=12)

    def test_semantic_labels_cannot_be_injected(self):
        groups=copy.deepcopy(self.groups);groups[0]['semantic_relation_label']='compatible'
        with self.assertRaisesRegex(ValueError,'semantic label'):
            validate_sampling(self.chains,groups,self.ids,chain_count=100,max_size=10,pair_cap=12)

    def test_infeasible_population_fails_instead_of_reusing_sources(self):
        with self.assertRaisesRegex(ValueError,'maximum group size'):
            balanced_chains(['a','b'],chain_count=1,max_size=3,seed='test')
        with self.assertRaisesRegex(ValueError,'Too many'):
            balanced_chains(['a','b','c'],chain_count=4,max_size=3,seed='test')


if __name__=='__main__':unittest.main()

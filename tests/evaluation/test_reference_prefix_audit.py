import unittest
from scripts.audit.audit_reference_prefix_diagnostic import registry, verify_bindings


class ReferencePrefixAuditTests(unittest.TestCase):
    def test_permutation_retains_unused_argument_and_distinct_objects(self):
        result=verify_bindings([['give','a','unused']], [['act__give','obj__unused','obj__a']],
            {'give':{'target':'act__give','positions':[1,0]}}, {'a':'obj__a','unused':'obj__unused'})
        self.assertEqual({'steps':1,'arguments':2},result)
        for bad in ([['act__give','obj__a']], [['act__give','obj__a','obj__unused']],
                    [['act__give','obj__unused','obj__unused']]):
            with self.assertRaises(ValueError):
                verify_bindings([['give','a','unused']],bad,
                    {'give':{'target':'act__give','positions':[1,0]}},{'a':'obj__a','unused':'obj__unused'})

    def test_nonbijective_roles_and_omitted_steps_are_rejected(self):
        for positions in ([0,0],[0],[0,2]):
            with self.assertRaises(ValueError):
                verify_bindings([['go','a','b']],[['next','x','y']],
                    {'go':{'target':'next','positions':positions}},{'a':'x','b':'y'})
        with self.assertRaises(ValueError):
            verify_bindings([['go','a']],[],{}, {})

    def test_failed_and_unavailable_rows_remain_in_denominator(self):
        slots=[{'id':'a'},{'id':'b'},{'id':'c'}]
        rows=[{'id':'c','status':'diagnostic_time_limit'}, {'id':'a','status':'PASS'},
              {'id':'b','status':'no_audited_source_prefix'}]
        report={'task_count':3,'rows':rows,'status_counts':{
            'PASS':1,'no_audited_source_prefix':1,'diagnostic_time_limit':1}}
        self.assertEqual(3,len(registry({'task_count':3,'slots':slots},report,{'task_count':3})[1]))
        report['rows']=rows[:-1]
        with self.assertRaises(ValueError):
            registry({'task_count':3,'slots':slots},report,{'task_count':3})

    def test_duplicate_ids_and_false_summary_are_rejected(self):
        report={'task_count':2,'rows':[{'id':'a','status':'PASS'},{'id':'b','status':'FAIL'}],
                'status_counts':{'PASS':2}}
        with self.assertRaises(ValueError):
            registry({'task_count':2,'slots':[{'id':'a'},{'id':'b'}]},report,{'task_count':2})
        report['status_counts']={'PASS':1,'FAIL':1}
        with self.assertRaises(ValueError):
            registry({'task_count':2,'slots':[{'id':'a'},{'id':'a'}]},report,{'task_count':2})


if __name__=='__main__':
    unittest.main()

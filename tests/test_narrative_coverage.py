import unittest

from scripts.audit.audit_all_narrative_coverage import summarize


class NarrativeCoverageTests(unittest.TestCase):
    def row(self, domain, passed, raw='parsed', empty=False):
        return {'domain': domain, 'single_domain_pass': passed, 'native': {'status': raw},
                'conversion': 'exported' if passed else 'rejected',
                'status': 'export_parse_pass' if passed else 'export_rejected',
                'domain_bytes': 0 if empty else 12, 'domain_sha256': 'empty' if empty else domain,
                'canonical_domain_sha256': 'canonical_' + domain, 'constant_contract': {}}

    def test_failed_problem_stays_in_pair_denominator_and_partial_domain_is_separate(self):
        result = summarize([self.row('a', True), self.row('a', False), self.row('b', True)])
        self.assertEqual((result['passed'], result['pairs'], result['pass_percent']), (2, 3, 66.67))
        self.assertEqual(result['admitted_domain_files'], 2)
        self.assertEqual(result['all_problem_passed_domain_files'], 1)

    def test_empty_records_are_not_unique_models_or_removed_from_coverage(self):
        result = summarize([self.row('a', True), self.row('b', False, 'empty_source', True),
                            self.row('c', False, 'empty_source', True)])
        self.assertEqual(result['pairs'], 3)
        self.assertEqual(result['nonempty_unique_raw_domain_hashes'], 1)
        self.assertEqual(result['admitted_unique_canonical_syntax'], 1)

    def test_export_pass_is_not_inferred_from_native_parse(self):
        result = summarize([self.row('a', False), self.row('b', True, 'native_parse_error')])
        self.assertEqual((result['raw_parsed'], result['passed']), (1, 1))


if __name__ == '__main__': unittest.main()

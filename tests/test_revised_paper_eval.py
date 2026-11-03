import unittest
from scripts.audit.evaluate_revised_repeat_paper import result_counts


class PaperResultCountingTests(unittest.TestCase):
    def test_returned_but_unsupported_is_not_validated(self):
        row = {'search_anchor': True, 'search': {'status': 'solved'},
            'replay': {'status': 'unavailable_counterfactual_plan_format'},
            'transport': {'status': 'unavailable_valid_native_plan'}}
        r = result_counts([row])
        self.assertEqual(1, r['returned_unknown'])
        self.assertEqual(0, r['validated_returns'])
        self.assertEqual(0, r['return_violations'])
        self.assertEqual(1, r['transport_status']['unavailable_valid_native_plan'])

    def test_non_anchor_does_not_enter_search_denominator(self):
        good = {'status': 'replayed', 'goal': True, 'unexplained_steps': 0,
                'physical': {'status': 'replayed', 'goal': True}}
        r = result_counts([{'search_anchor': False, 'search': {'status': 'not_registered_anchor'}, 'transport': good}])
        self.assertEqual(1, r['source_slots'])
        self.assertEqual(0, r['searches'])
        self.assertEqual(1, r['validated_transports'])
        self.assertEqual(0, r['validated_returns'])


if __name__ == '__main__': unittest.main()

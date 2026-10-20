import copy
import json
from pathlib import Path
import tempfile
import unittest

from rcnc.interface_annotation import build_packet, validate_annotations


class InterfaceAnnotationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.inputs = self.root/'inputs'
        self.inputs.mkdir()
        for source, predicate in [('A', 'knows'), ('B', 'told')]:
            (self.inputs/f'{source}_domainfile.pddl').write_text(f'''(define (domain {source})
              (:requirements :adl :typing) (:types person place - object)
              (:predicates ({predicate} ?p - person ?l - place) (ready ?p - person))
              (:action inform :parameters (?p - person ?l - place)
               :precondition (exists (?q - person) (ready ?q))
               :effect (when (ready ?p) ({predicate} ?p ?l))))''', encoding='utf-8')
        self.manifest = build_packet(self.inputs, self.root/'packet', 10, 'test-seed')
        self.packet = json.loads((self.root/'packet/packet.json').read_text())
        self.template = json.loads((self.root/'packet/annotation_template.json').read_text())

    def annotated(self):
        result = copy.deepcopy(self.template)
        result.update(annotator_id='synthetic-test-reviewer', independent_of_model_and_solver_outcomes=True)
        for row, item in zip(result['rows'], self.packet['items']):
            row.update(status='completed', label='equivalent',
                       right_from_left=list(range(len(item['sides'][0]['parameters']))),
                       rationale='Synthetic validation fixture, not a semantic gold judgment.', date='2026-10-15',
                       evidence=[{'side': side, 'ref': data['action_contexts'][0]['ref'],
                                  'quote': data['action_contexts'][0]['text']} for side, data in enumerate(item['sides'])])
        return result

    def test_denominator_determinism_and_no_problem_dependency(self):
        self.assertEqual(4, self.manifest['all_cross_source_pairs'])
        self.assertEqual(2, self.manifest['different_arity_excluded'])
        self.assertEqual(2, self.manifest['selected_pairs'])
        # A malformed problem cannot affect a packet: no problem/outcome data is read.
        (self.inputs/'A_problemfile.pddl').write_text('unparseable secret goal and solver prediction')
        other = build_packet(self.inputs, self.root/'other', 10, 'test-seed')
        self.assertEqual(self.manifest, other)
        self.assertEqual((self.root/'packet/packet.json').read_bytes(), (self.root/'other/packet.json').read_bytes())
        text = json.dumps(self.packet)
        self.assertNotIn('secret goal', text)
        self.assertNotIn('stratum', text)
        self.assertIn('(exists', text)
        self.assertIn('(when', text)

    def test_unfilled_template_is_not_completed_annotation(self):
        report = validate_annotations(self.packet, self.template)
        self.assertFalse(report['valid'])
        self.assertEqual(0, report['completed'])
        self.assertIn('independence_not_declared', report['errors'])

    def test_citations_permutations_duplicates_and_hash_are_checked(self):
        baseline = self.annotated()
        self.assertTrue(validate_annotations(self.packet, baseline)['valid'])
        for mutation in ('hash', 'quote', 'one_side', 'order', 'duplicate'):
            changed = copy.deepcopy(baseline)
            row = changed['rows'][0]
            if mutation == 'hash': changed['packet_sha256'] = 'stale'
            elif mutation == 'quote': row['evidence'][0]['quote'] = 'invented source text'
            elif mutation == 'one_side': row['evidence'].pop()
            elif mutation == 'order': row['right_from_left'] = [9]
            else: changed['rows'].append(copy.deepcopy(row))
            self.assertFalse(validate_annotations(self.packet, changed)['valid'], mutation)

    def test_uncertain_is_distinct_from_missing(self):
        values = self.annotated()
        values['rows'][0].update(label='uncertain', right_from_left=None, evidence=[])
        values['rows'][1] = self.template['rows'][1]
        report = validate_annotations(self.packet, values)
        self.assertTrue(report['valid'])
        self.assertEqual(1, report['completed'])
        self.assertEqual(1, report['label_counts']['uncertain'])
        self.assertEqual(1, report['unreviewed_or_missing'])


if __name__ == '__main__':
    unittest.main()

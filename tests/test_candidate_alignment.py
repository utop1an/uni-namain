import copy
import hashlib
import json
from pathlib import Path
import tempfile
import unittest

from rcnc.candidate_alignment import propose, run
from rcnc.interface_annotation import digest
from rcnc.pddl import parse_domain, serialize


class CandidateAlignmentTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.inputs = self.root / 'inputs'
        self.inputs.mkdir()
        sides = {}
        for source in ('A', 'B', 'C'):
            path = self.inputs / (source + '_domainfile.pddl')
            path.write_text(f'''(define (domain {source.lower()})
              (:requirements :strips :typing) (:types person - object)
              (:predicates (rel ?x ?y ?z - person))
              (:action act :parameters (?x ?y ?z - person)
               :precondition (and) :effect (rel ?x ?y ?z)))''', encoding='utf-8')
            model = parse_domain(path)
            sides[source] = {'source': source, 'predicate': 'rel',
                'parameters': model.predicates['rel'].parameters,
                'action_contexts': [{'ref': source + ':action:act',
                    'text': serialize(model.actions['act']),
                    'occurrences': [{'literal': '(rel ?x ?y ?z)'}]}]}
        self.packet = {'source_sha256': {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
                                        for p in self.inputs.glob('*.pddl')},
                       'items': [{'id': 'ab', 'sides': [sides['A'], sides['B']]}]}
        self.sides = sides
        self.predictions = self.predictions_for(self.packet, [[1, 2, 0]])

    def predictions_for(self, packet, orders):
        rows = []
        for item, order in zip(packet['items'], orders):
            rows.append({'candidate_id': item['id'], 'status': 'checked', 'response': {
                'candidate_id': item['id'],
                'label': 'equivalent' if order == [0, 1, 2] else 'permuted_equivalent',
                'right_from_left': order, 'rationale': 'Synthetic role control',
                'evidence': [{'side': i, 'ref': side['action_contexts'][0]['ref'],
                              'quote': '(rel ?x ?y ?z)'} for i, side in enumerate(item['sides'])]}})
        return {'status': 'complete', 'total': len(rows), 'processed': len(rows),
                'packet_sha256': digest(packet), 'counts': {'checked': len(rows)}, 'rows': rows}

    def test_noninvolutive_permutation_compiles_without_world_or_identity_inference(self):
        packet, predictions = self.root / 'packet.json', self.root / 'predictions.json'
        packet.write_text(json.dumps(self.packet), encoding='utf-8')
        predictions.write_text(json.dumps(self.predictions), encoding='utf-8')
        manifest = self.root / 'manifest.json'
        manifest.write_text(json.dumps({'status': 'complete', 'packet_sha256': digest(self.packet),
                                        'model': 'synthetic_fixture_not_a_real_model_run'}), encoding='utf-8')
        result = run(packet, predictions, self.inputs, self.root / 'out', True, True, manifest)
        self.assertEqual('compiled_and_independently_parsed', result['compilation']['status'])
        spec = json.loads((self.root / 'out/alignment.json').read_text())
        self.assertEqual([2, 0, 1], spec['predicate_groups'][0]['members'][1]['order'])
        self.assertEqual('machine_hypothesis', spec['decision_basis'])
        self.assertFalse(spec['object_identity_inferred'])
        self.assertFalse(result['planner_called'])
        self.assertTrue(result['alignment_unchanged'])
        with self.assertRaises(ValueError):
            run(packet, predictions, self.inputs, self.root / 'out', True, True, manifest)

    def test_default_withholds_roles_and_stale_inputs_rejected(self):
        spec, report = propose(self.packet, self.predictions, self.inputs)
        self.assertEqual([], spec['predicate_groups'])
        self.assertEqual('missing_explicit_role_types', report['decisions'][0]['reason'])
        (self.inputs / 'A_domainfile.pddl').write_text('changed')
        with self.assertRaises(ValueError):
            propose(self.packet, self.predictions, self.inputs, True)

    def test_inconsistent_cycle_is_withheld_in_full(self):
        self.packet['items'] += [{'id': key, 'sides': [self.sides[a], self.sides[b]]}
                                 for key, a, b in [('bc', 'B', 'C'), ('ac', 'A', 'C')]]
        predictions = self.predictions_for(self.packet, [[1, 2, 0]] * 3)
        spec, report = propose(self.packet, predictions, self.inputs, True)
        self.assertFalse(spec['predicate_groups'])
        self.assertEqual('joint_conflict', report['decisions'][0]['reason'])
        bad = copy.deepcopy(predictions)
        bad['rows'].pop()
        with self.assertRaises(ValueError):
            propose(self.packet, bad, self.inputs, True)

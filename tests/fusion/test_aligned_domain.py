import copy
import hashlib
import json
from pathlib import Path
import tempfile
import unittest

from rcnc.aligned_domain import build, membership_facts
from rcnc.merged_planning import solve
from rcnc.narrative_pipeline import run
from scripts.experiments.run_union_regression import translate_plan


class AlignedDomainTests(unittest.TestCase):
    def test_pipeline_uses_explicit_shared_membership_and_rejects_implicit_identity(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, spec = self.fixture(root)
            query = {'alignment': spec,
                     'objects': {'hero': ['HEAR:person', 'TELL:person'], 'witness': ['HEAR:person', 'TELL:person']},
                     'initial': [['HEAR:ready', 'hero'], ['HEAR:partner', 'witness'], ['TELL:eligible', 'hero']],
                     'goal': {'positive': [['TELL:told', 'hero']]}, 'seconds': 30}
            result = run(query, inputs, root / 'out')
            self.assertEqual('solved', result['status'])
            self.assertEqual(2, result['search']['length'])
            self.assertEqual('VALID', result['search']['validation']['status'])
            self.assertEqual('assumptions_not_independently_verified', result['semantic_alignment_status'])
            mapping = json.loads((root / 'out/query_mapping.json').read_text())
            self.assertEqual(3, len(mapping['initial']))
            self.assertTrue(mapping['type_encoding_facts'])
            query['objects']['hero'] = 'HEAR:person'
            rejected = run(query, inputs, root / 'missing_membership')
            self.assertEqual('rejected', rejected['status'])
            self.assertFalse(rejected['planner_called'])

    def fixture(self, root):
        inputs = root / 'inputs'; inputs.mkdir()
        (inputs / 'HEAR_domainfile.pddl').write_text('''(define (domain hear)
          (:requirements :strips :typing) (:types person - object)
          (:predicates (ready ?p - person) (partner ?p - person) (knows ?p ?q - person))
          (:action learn :parameters (?p ?q - person)
           :precondition (and (ready ?p) (partner ?q)) :effect (knows ?p ?q)))''')
        (inputs / 'TELL_domainfile.pddl').write_text('''(define (domain tell)
          (:requirements :strips :typing) (:types person - object)
          (:predicates (known_by ?q ?p - person) (eligible ?p - person) (told ?p - person))
          (:action tell :parameters (?p ?q - person)
           :precondition (and (known_by ?q ?p) (eligible ?p)) :effect (told ?p)))''')
        spec = {'version': 1, 'decision_basis': 'authored_assumption',
                'source_sha256': {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs.glob('*.pddl')},
                'type_groups': [{'members': ['HEAR:person', 'TELL:person'], 'evidence': 'Synthetic person role correspondence'}],
                'predicate_groups': [{'id': 'knows', 'evidence': 'Synthetic converse argument order by construction',
                    'members': [{'predicate': 'HEAR:knows', 'order': [0, 1]},
                                {'predicate': 'TELL:known_by', 'order': [1, 0]}]}]}
        return inputs, spec

    def problem(self, output, path):
        meta = json.loads((output / 'meta_domain.json').read_text())
        facts = []
        for obj in ('hero', 'witness'):
            for source in ('HEAR', 'TELL'):
                typ = meta['namespaces'][source]['types']['person']
                facts.extend(membership_facts(obj, typ, meta['source_type_parents'], meta['type_guards']))
        facts += [[meta['predicate_maps']['HEAR']['ready'], 'hero'],
                  [meta['predicate_maps']['HEAR']['partner'], 'witness'],
                  [meta['predicate_maps']['TELL']['eligible'], 'hero']]
        from rcnc.pddl import serialize
        path.write_text(serialize(['define', ['problem', 'p'], [':domain', 'narrative_aligned'],
                                   [':objects', 'hero', 'witness', '-', 'object'], [':init', *facts],
                                   [':goal', [meta['predicate_maps']['TELL']['told'], 'hero']]]))

    def test_argument_permutation_enables_valid_composition_and_wrong_direction_does_not(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, spec = self.fixture(root)
            for name, order, expected in [('correct', [1, 0], 'solved'), ('wrong_direction', [0, 1], 'unsolvable')]:
                variant = copy.deepcopy(spec)
                variant['predicate_groups'][0]['members'][1]['order'] = order
                output = root / name; build(inputs, output, variant)
                self.problem(output, output / 'composition.pddl')
                result = solve(output / 'meta_domain.pddl', output / 'composition.pddl', output / 'planning')
                self.assertEqual(expected, result['status'])
                if expected == 'solved':
                    self.assertEqual(2, result['length'])
                    self.assertEqual('VALID', result['validation']['status'])

    def test_rejects_stale_sources_missing_type_correspondence_and_nonpermutations(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, spec = self.fixture(root)
            variants = []
            v = copy.deepcopy(spec); v['source_sha256'] = {}; variants.append(v)
            v = copy.deepcopy(spec); v['type_groups'] = []; variants.append(v)
            v = copy.deepcopy(spec); v['predicate_groups'][0]['members'][1]['order'] = [0, 0]; variants.append(v)
            for i, variant in enumerate(variants):
                with self.subTest(i=i), self.assertRaises(ValueError):
                    build(inputs, root / str(i), variant)

    def test_reified_type_guards_preserve_universal_source_plan(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs = root / 'inputs'; inputs.mkdir()
            for source in ('A', 'B'):
                (inputs / f'{source}_domainfile.pddl').write_text(f'''(define (domain {source})
                  (:requirements :strips :typing :universal-preconditions)
                  (:constants actor - object) (:predicates (ready ?p - object) (done))
                  (:action finish :parameters ()
                   :precondition (forall (?p - object) (ready ?p)) :effect (done)))''')
                (inputs / f'{source}_problemfile.pddl').write_text(f'''(define (problem p)
                  (:domain {source}) (:init (ready actor)) (:goal (done)))''')
            spec = {'version': 1, 'decision_basis': 'authored_assumption',
                    'source_sha256': {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs.glob('*_domainfile.pddl')}}
            build(inputs, root / 'aligned', spec)
            original = solve(inputs / 'A_domainfile.pddl', inputs / 'A_problemfile.pddl', root / 'original')
            self.assertEqual('solved', original['status'])
            mapped = translate_plan('A', inputs, root / 'aligned', root / 'original', root / 'mapped')
            self.assertEqual('VALID', mapped['validation']['status'])


if __name__ == '__main__':
    unittest.main()

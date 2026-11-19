from pathlib import Path
import tempfile
import unittest

from rcnc.aligned_domain import build
from rcnc.world_compatibility import inspect_worlds
from scripts.experiments.run_downward_reference import sha


class WorldCompatibilityTests(unittest.TestCase):
    def fixture(self, root, right_initial='(r v u)'):
        inputs = root / 'inputs'
        inputs.mkdir()
        worlds = []
        for source, objects, initial in [('A', 'a b', '(r a b)'), ('B', 'u v', right_initial)]:
            domain = inputs / (source + '_domainfile.pddl')
            domain.write_text(f'''(define (domain {source.lower()}) (:requirements :typing :strips)
              (:types item) (:predicates (r ?x ?y - item) (flag))
              (:action mark :parameters (?x ?y - item) :precondition (and) :effect (r ?x ?y)))''', encoding='utf-8')
            problem = root / (source + '.pddl')
            problem.write_text(f'''(define (problem p) (:domain {source.lower()})
              (:objects {objects} - item) (:init {initial}) (:goal (flag)))''', encoding='utf-8')
            worlds.append({'source': source, 'domain': domain, 'problem': problem,
                'domain_sha256': sha(domain), 'problem_sha256': sha(problem),
                'object_map': {name: 'q__' + target for name, target in zip(objects.split(), ['one', 'two'])}})
        spec = {'version': 1, 'decision_basis': 'authored_assumption',
            'source_sha256': {path.name: sha(path) for path in inputs.glob('*.pddl')},
            'type_groups': [{'members': ['A:item', 'B:item'], 'evidence': 'synthetic fixture'}],
            'predicate_groups': [{'id': 'relation', 'members': [{'predicate': 'A:r', 'order': [0, 1]},
                {'predicate': 'B:r', 'order': [1, 0]}], 'evidence': 'synthetic fixture'},
                {'id': 'flag', 'members': [{'predicate': 'A:flag', 'order': []},
                    {'predicate': 'B:flag', 'order': []}], 'evidence': 'synthetic fixture'}]}
        compiled = root / 'compiled'
        build(inputs, compiled, spec)
        pins = {'domain_sha256': sha(compiled / 'meta_domain.pddl'), 'metadata_sha256': sha(compiled / 'meta_domain.json')}
        return compiled, worlds, pins

    def test_argument_permutation_and_closed_world_falsity_define_conflicts(self):
        with tempfile.TemporaryDirectory() as td:
            compiled, worlds, pins = self.fixture(Path(td))
            result = inspect_worlds(compiled, worlds, **pins)
            self.assertTrue(result['compatible'])
            self.assertEqual(10, result['ground_atom_comparisons'])
            self.assertFalse(result['facts_imported_into_planning'])
            worlds[1]['problem'].write_text('''(define (problem p) (:domain b)
              (:objects u v - item) (:init (r u v) (flag)) (:goal (flag)))''', encoding='utf-8')
            worlds[1]['problem_sha256'] = sha(worlds[1]['problem'])
            conflict = inspect_worlds(compiled, worlds, **pins)
            self.assertFalse(conflict['compatible'])
            self.assertEqual(3, conflict['conflicting_atoms'])
            self.assertTrue(all(item['left']['truth'] != item['right']['truth'] for item in conflict['conflicts']))

    def test_budget_and_noninjective_embeddings_never_report_compatibility(self):
        with tempfile.TemporaryDirectory() as td:
            compiled, worlds, pins = self.fixture(Path(td))
            limited = inspect_worlds(compiled, worlds, max_atoms=9, **pins)
            self.assertEqual('atom_budget_limit', limited['status'])
            self.assertIsNone(limited['compatible'])
            self.assertFalse(limited['complete'])
            worlds[0]['object_map']['b'] = 'q__one'
            with self.assertRaisesRegex(ValueError, 'injective'):
                inspect_worlds(compiled, worlds, **pins)


if __name__ == '__main__':
    unittest.main()

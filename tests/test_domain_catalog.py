import hashlib
import json
from pathlib import Path
import tempfile
import unittest

from rcnc.domain_catalog import catalog, select
from rcnc.narrative_pipeline import run


class DomainCatalogTests(unittest.TestCase):
    def fixture(self, root):
        inputs = root / 'inputs'; inputs.mkdir()
        texts = {
            'A': '''(:predicates (seed) (signal) (unrelated))
              (:action emit :parameters () :precondition (seed) :effect (signal))
              (:action extra :parameters () :precondition (signal) :effect (unrelated))''',
            'B': '''(:predicates (signal) (done))
              (:action finish :parameters () :precondition (signal) :effect (done))''',
            'C': '''(:predicates (irrelevant))
              (:action distract :parameters () :precondition (and) :effect (irrelevant))'''}
        for source, text in texts.items():
            (inputs / f'{source}_domainfile.pddl').write_text(f'(define (domain {source}) (:requirements :strips) {text})')
        spec = {'version': 1, 'decision_basis': 'authored_assumption',
                'source_sha256': {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs.glob('*.pddl')},
                'predicate_groups': [{'id': 'signal', 'evidence': 'Synthetic shared event by construction',
                                      'members': [{'predicate': 'A:signal', 'order': []},
                                                  {'predicate': 'B:signal', 'order': []}]}]}
        return inputs, {'alignment': spec, 'initial': [['A:seed']], 'goal': {'positive': [['B:done']]}, 'seconds': 30}

    def test_selection_excludes_unrelated_domain_but_keeps_all_selected_actions(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, query = self.fixture(root)
            inventory = catalog(inputs)
            selection = select({**query, 'selection': 'goal_dependencies'}, inventory)
            self.assertEqual(['A', 'B'], selection['selected'])
            self.assertEqual(['C'], selection['excluded'])
            result = run({**query, 'selection': 'goal_dependencies'}, inputs, root / 'selected')
            self.assertEqual('solved', result['status'])
            meta = json.loads((root / 'selected/union/meta_domain.json').read_text())
            self.assertEqual(3, meta['counts']['operators'])
            self.assertIn('extra', meta['action_maps']['A'])
            all_result = run(query, inputs, root / 'all')
            self.assertEqual('solved', all_result['status'])
            self.assertEqual(all_result['search']['length'], result['search']['length'])
            for name in ('all', 'selected'):
                mapping = json.loads((root / name / 'query_mapping.json').read_text())
                self.assertEqual(1, len(mapping['initial']))
                self.assertEqual('VALID', (all_result if name == 'all' else result)['search']['validation']['status'])

    def test_initial_only_fallback_and_explicit_selection_conflict(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); inputs, query = self.fixture(root)
            inventory = catalog(inputs)
            initial_only = {k: v for k, v in query.items() if k != 'goal'}
            self.assertEqual(['A', 'B', 'C'], select({**initial_only, 'selection': 'goal_dependencies'}, inventory)['selected'])
            with self.assertRaises(ValueError):
                select({**query, 'sources': ['A'], 'selection': 'goal_dependencies'}, inventory)


if __name__ == '__main__':
    unittest.main()

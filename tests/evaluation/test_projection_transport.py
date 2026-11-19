from pathlib import Path
import tempfile
import unittest

from scripts.audit.audit_composition_projection import transport_plan


class ProjectionTransportTests(unittest.TestCase):
    def test_prefix_collision_resolves_source_identity_and_preserves_unused_argument(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            projected, original = root / 'projected', root / 'original'
            for directory, constants, action, target in [
                (projected, 'd000_c d001_c', 'd000_go', 'd000_c'),
                (original, 'd000_c d001_c d002_c', 'd001_go', 'd001_c')]:
                directory.mkdir()
                (directory / 'domain.pddl').write_text(f'''(define (domain d)
                  (:requirements :strips :typing) (:types item)
                  (:constants {constants} - item) (:predicates (done ?x - item))
                  (:action {action} :parameters (?x ?unused - item)
                   :precondition (and) :effect (done ?x)))''', encoding='utf-8')
                (directory / 'problem.pddl').write_text(f'''(define (problem p) (:domain d)
                  (:objects q__hero - item) (:init) (:goal (done {target})))''', encoding='utf-8')
            (projected / 'plan.txt').write_text('(d000_go d000_c d001_c)\n', encoding='utf-8')
            left = {'action_maps': {'B': {'go': 'd000_go'}},
                'constant_maps': {'B': {'c': 'd000_c'}, 'C': {'c': 'd001_c'}}}
            right = {'action_maps': {'B': {'go': 'd001_go'}},
                'constant_maps': {'A': {'c': 'd000_c'}, 'B': {'c': 'd001_c'}, 'C': {'c': 'd002_c'}}}
            result = transport_plan(projected, left, original, right, {'objects': {'hero': 'B:item'}}, root / 'out')
            self.assertEqual('valid', result['status'])
            self.assertEqual('(d001_go d001_c d002_c)', (root / 'out/plan.txt').read_text(encoding='utf-8').strip())


if __name__ == '__main__':
    unittest.main()

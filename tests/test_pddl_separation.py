from dataclasses import asdict
from pathlib import Path
import tempfile
import unittest

from archive.domain_merge import parse_domain as parse_legacy_domain
from rcnc.pddl import parse_domain, validate_domain, write_domain


class PddlSeparationTests(unittest.TestCase):
    def fixture(self, directory):
        path = directory/'A_domainfile.pddl'
        path.write_text('''(define (domain a)
          (:requirements :strips :typing)
          (:types person location - object)
          (:constants hero - person room - location)
          (:predicates (located ?p - person ?l - location))
          (:action arrive :parameters () :precondition (and)
           :effect (located hero room)))''', encoding='utf-8')
        return path

    def test_raw_parser_preserves_aliases_and_identity_mappings(self):
        with tempfile.TemporaryDirectory() as td:
            raw = parse_domain(self.fixture(Path(td)))
            self.assertEqual({'located'}, set(raw.predicates))
            self.assertEqual({'A': {'located': 'located'}}, raw.predicate_maps)
            self.assertEqual([], raw.decisions)
            self.assertEqual(['located', 'hero', 'room'], raw.actions['arrive'][-1])

    def test_historical_semantics_are_explicit_and_can_still_be_disabled(self):
        with tempfile.TemporaryDirectory() as td:
            path = self.fixture(Path(td))
            raw = parse_domain(path)
            legacy = parse_legacy_domain(path)
            self.assertEqual({'at'}, set(legacy.predicates))
            self.assertEqual({'A': {'located': 'at'}}, legacy.predicate_maps)
            self.assertEqual(['at', 'hero', 'room'], legacy.actions['arrive'][-1])
            self.assertEqual(asdict(raw), asdict(parse_legacy_domain(
                path, apply_reviewed_semantics=False)))

    def test_raw_export_round_trip_preserves_source_model(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            raw = parse_domain(self.fixture(root))
            output = root/'roundtrip/A_domainfile.pddl'
            write_domain(raw, output)
            self.assertEqual([], validate_domain(raw))
            self.assertEqual(asdict(raw), asdict(parse_domain(output)))


if __name__ == '__main__':
    unittest.main()

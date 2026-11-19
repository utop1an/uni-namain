from dataclasses import asdict
from pathlib import Path
import tempfile
import unittest

from rcnc.pddl import parse_domain, validate_domain, write_domain


def location_domain(directory):
    path = directory/'A_domainfile.pddl'
    path.write_text('''(define (domain a)
      (:requirements :strips :typing)
      (:types person location - object)
      (:constants hero - person room - location)
      (:predicates (located ?p - person ?l - location))
      (:action arrive :parameters () :precondition (and)
       :effect (located hero room)))''', encoding='utf-8')
    return path


class PddlSeparationTests(unittest.TestCase):
    def test_raw_parser_preserves_aliases_and_identity_mappings(self):
        with tempfile.TemporaryDirectory() as td:
            raw = parse_domain(location_domain(Path(td)))
            self.assertEqual({'located'}, set(raw.predicates))
            self.assertEqual({'A': {'located': 'located'}}, raw.predicate_maps)
            self.assertEqual([], raw.decisions)
            self.assertEqual(['located', 'hero', 'room'], raw.actions['arrive'][-1])

    def test_raw_export_round_trip_preserves_source_model(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            raw = parse_domain(location_domain(root))
            output = root/'roundtrip/A_domainfile.pddl'
            write_domain(raw, output)
            self.assertEqual([], validate_domain(raw))
            self.assertEqual(asdict(raw), asdict(parse_domain(output)))


if __name__ == '__main__':
    unittest.main()

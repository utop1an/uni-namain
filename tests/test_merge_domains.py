import tempfile
import unittest
from pathlib import Path

from merge_domains import parse_domain, parse_sexpr, run, validate_domain


ROOT = Path(__file__).resolve().parents[1]
INPUT = ROOT / "data" / "narra-domains"


class DomainFusionTests(unittest.TestCase):
    def test_all_source_domains_parse_and_reference_declared_predicates(self):
        paths = sorted(INPUT.glob("*_domainfile.pddl"))
        self.assertEqual(15, len(paths))
        for path in paths:
            with self.subTest(path=path.name):
                domain = parse_domain(path)
                self.assertEqual([], validate_domain(domain))

    def test_fusion_preserves_all_actions_and_builds_valid_problems(self):
        source_actions = sum(len(parse_domain(path).actions) for path in INPUT.glob("*_domainfile.pddl"))
        with tempfile.TemporaryDirectory() as temp_dir:
            output = Path(temp_dir) / "merged"
            merged = run(INPUT, output)
            self.assertEqual(15, len(merged.sources))
            self.assertEqual(source_actions, len(merged.actions))
            self.assertEqual([], validate_domain(merged))
            self.assertEqual(15, len(list((output / "problems").glob("*_problemfile.pddl"))))
            self.assertTrue((output / "validation.json").is_file())
            parse_sexpr((output / "meta_domain.pddl").read_text(encoding="utf-8"))

    def test_reviewed_location_aliases_are_unified(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            merged = run(INPUT, Path(temp_dir) / "merged")
            self.assertIn("at", merged.predicates)
            for alias in ("located", "entity_at", "item_at", "at_item"):
                self.assertNotIn(alias, merged.predicates)


if __name__ == "__main__":
    unittest.main()

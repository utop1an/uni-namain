import hashlib
import json
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

from merge_domains import Domain, Predicate
from unidomain_ollama_fusion import (
    FusionRuntime,
    parse_action,
    predicate_text,
    run,
    update_actions_for_predicate,
)


ROOT = Path(__file__).resolve().parents[1]
PROMPT_DIR = ROOT / "prompts" / "domain_fusion"


def empty_domain(source: str) -> Domain:
    return Domain(
        name=source,
        requirements={":strips", ":typing"},
        types={},
        constants={},
        predicates={},
        actions={},
        sources={source},
        predicate_maps={source: {}},
        constant_maps={source: {}},
        action_maps={source: {}},
    )


class OfficialFusionAlignmentTests(unittest.TestCase):
    def test_prompts_match_official_normalized_fingerprints(self):
        expected = {
            "check_merge_predicates.txt": (
                "1bdb97364b8685f49cba61c370f9ce25"
                "fcf1020633bf0ee7e678a1a62551c783"
            ),
            "update_action_string.txt": (
                "63d72422d8864b204f4a231e5d522d97"
                "256541d250cdb5a0a7baf12bc25b9400"
            ),
            "check_merge_actions.txt": (
                "71d5e2564bf53dff3e758ea4af60778c"
                "61c2353f96d26e0470652e5b0ab0b42a"
            ),
        }
        for name, expected_hash in expected.items():
            with self.subTest(prompt=name):
                normalized = (PROMPT_DIR / name).read_text(encoding="utf-8").rstrip("\r\n")
                digest = hashlib.sha256(normalized.encode("utf-8")).hexdigest()
                self.assertEqual(expected_hash, digest)

    def test_predicate_candidates_preserve_similarity_order(self):
        first = Predicate("first", [("?x", "object")])
        second = Predicate("second", [("?x", "object")])

        class FakeEmbedding:
            def filter_and_sort(self, query, candidates, threshold):
                self.asserted = (query, candidates, threshold)
                return [(candidates[1], 0.9), (candidates[0], 0.4)]

        runtime = object.__new__(FusionRuntime)
        runtime.embedding = FakeEmbedding()
        runtime.predicate_threshold = 0.3

        result = runtime.predicate_candidates(
            Predicate("query", [("?x", "object")]),
            {"first": first, "second": second},
        )

        self.assertEqual([("second", 0.9), ("first", 0.4)], result)

    def test_same_arity_type_change_uses_llm_action_update(self):
        old = Predicate("old_state", [("?x", "type_a")])
        new = Predicate("new_state", [("?x", "type_b")])
        action = parse_action(
            "(:action change :parameters (?x - type_a) "
            ":precondition (old_state ?x) :effect (old_state ?x))"
        )
        domain = Domain(
            name="test",
            requirements={":strips", ":typing"},
            types={"type_a": "object", "type_b": "object"},
            constants={},
            predicates={"old_state": old, "new_state": new},
            actions={"change": action},
            sources={"test"},
            predicate_maps={"test": {"old_state": "old_state", "new_state": "new_state"}},
            action_maps={"test": {"change": "change"}},
        )

        class RecordingLLM:
            model = "test"

            def __init__(self):
                self.calls = 0

            def call(self, task, prompt, schema, validator):
                self.calls += 1
                result = {
                    "reasoning": "test",
                    "updated_action": (
                        "(:action change :parameters (?x - type_b) "
                        ":precondition (new_state ?x) :effect (new_state ?x))"
                    ),
                }
                validator(result)
                return result

        llm = RecordingLLM()
        update_actions_for_predicate(domain, old, new, SimpleNamespace(llm=llm))

        self.assertEqual(1, llm.calls)
        self.assertIn("new_state", predicate_text(new))
        self.assertIn("new_state", str(domain.actions["change"]))

    def test_odd_node_is_inserted_first_in_next_layer(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            base = Path(temp_dir)
            input_dir = base / "input"
            input_dir.mkdir()
            for index in range(5):
                (input_dir / f"{index}_domainfile.pddl").write_text("", encoding="utf-8")

            runtime = SimpleNamespace(
                predicate_threshold=0.3,
                operator_threshold=0.3,
                embedding_model="sentence-transformers/all-mpnet-base-v2",
                llm=SimpleNamespace(
                    model="test",
                    network_calls=0,
                    cache_hits=0,
                    total_duration_seconds=0.0,
                ),
            )

            def fake_parse(path, apply_reviewed_semantics=False):
                return empty_domain(path.name.removesuffix("_domainfile.pddl"))

            def fake_fuse(left, right, runtime):
                merged = empty_domain("_".join(sorted(left.sources | right.sources)))
                merged.sources = left.sources | right.sources
                return merged

            with (
                patch("unidomain_ollama_fusion.parse_domain", side_effect=fake_parse),
                patch("unidomain_ollama_fusion.fuse_pair", side_effect=fake_fuse),
                patch("unidomain_ollama_fusion.write_node"),
                patch("unidomain_ollama_fusion.write_domain"),
                patch("unidomain_ollama_fusion.validate_domain", return_value=[]),
            ):
                run(input_dir, base / "output", runtime=runtime, num_workers=2)

            tree = json.loads((base / "output" / "fusion_tree.json").read_text())
            edges = [
                (edge["parent"], edge["left"], edge["right"])
                for edge in tree["edges"]
            ]
            self.assertEqual(
                [(5, 0, 1), (6, 2, 3), (7, 4, 5), (8, 6, 7)],
                edges,
            )


if __name__ == "__main__":
    unittest.main()

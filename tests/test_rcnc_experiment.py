import tempfile
import unittest
from pathlib import Path

from merge_domains import parse_domain
from rcnc.experiment import (
    build_causal_edges,
    event_family,
    extract_domain_frames,
    generate_stories,
    predicate_frame,
    run_experiment,
)


ROOT = Path(__file__).resolve().parents[1]
INPUT = ROOT / "data" / "narra-domains"


class RCNCExperimentTests(unittest.TestCase):
    def test_predicate_factorization_preserves_state_values(self):
        opened = predicate_frame("test", "door_open", ["location"])
        closed = predicate_frame("test", "door_closed", ["location"])
        located = predicate_frame("test", "located", ["entity", "location"])
        at = predicate_frame("test", "at", ["entity", "location"])

        self.assertNotEqual(opened.key, closed.key)
        self.assertEqual("status", opened.category)
        self.assertEqual(located.key, at.key)

    def test_action_family_is_independent_of_unidomain_merge(self):
        self.assertEqual("MOVE", event_family("travel_to"))
        self.assertEqual("HARM", event_family("shoot_dragon"))
        self.assertEqual("SOCIAL_COMMITMENT", event_family("king_proposes_marriage"))

    def test_fixed_constants_are_lifted_into_slots(self):
        domain = parse_domain(INPUT / "BIRT_domainfile.pddl", apply_reviewed_semantics=False)
        _, actions, profiles = extract_domain_frames(domain)
        hear = next(action for action in actions if action.action == "hear_tapping_on_beech")

        self.assertIn("bench", hear.lifted_constants)
        bench = next(profile for profile in profiles if profile.name == "bench")
        self.assertGreater(bench.fixed_action_occurrences, 0)

    def test_cross_domain_causal_stories_are_generated(self):
        actions = []
        for name in ("BIRT", "CHIC_NP", "HANS_NP", "JACK_NP"):
            domain = parse_domain(INPUT / f"{name}_domainfile.pddl", apply_reviewed_semantics=False)
            _, domain_actions, _ = extract_domain_frames(domain)
            actions.extend(domain_actions)
        edges = build_causal_edges(actions)
        stories = generate_stories(
            actions,
            edges,
            length=4,
            count=3,
            novelty_level="conservative",
        )

        self.assertTrue(edges)
        self.assertTrue(stories)
        self.assertTrue(all(len(story.connectors) == 3 for story in stories))
        self.assertTrue(all(len(set(story.sources)) >= 2 for story in stories))

    def test_full_experiment_writes_auditable_outputs(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            output = Path(temp_dir) / "experiment"
            result = run_experiment(INPUT, output, story_length=4, story_count=2)

            self.assertEqual(15, result.summary["input"]["domains"])
            self.assertTrue((output / "entity_profiles.json").is_file())
            self.assertTrue((output / "predicate_frames.json").is_file())
            self.assertTrue((output / "causal_edges.json").is_file())
            self.assertTrue((output / "stories" / "creative.json").is_file())


if __name__ == "__main__":
    unittest.main()

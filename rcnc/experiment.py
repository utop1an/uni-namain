"""Deterministic first experiment for Role-Causal Narrative Composition.

This module intentionally does not reuse UniDomain's embedding, LLM, or binary
fusion procedure.  It lifts story constants into substitutable slots, projects
predicates into state frames, projects actions into event families, and builds
cross-domain causal edges from producer effects to consumer preconditions.
"""

from __future__ import annotations

import json
import math
import re
from collections import Counter, defaultdict
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any, Iterable, Iterator

from merge_domains import (
    BUILT_INS,
    LOGICAL_FORMS,
    Domain,
    SExpr,
    atom,
    parse_domain,
    typed_symbols,
)


LOCATION_ALIASES = {"at", "located", "entity_at", "item_at", "at_item"}
POSSESSION_ALIASES = {"has", "holds", "possesses"}
STATUS_WORDS = {
    "alive", "dead", "asleep", "awake", "captured", "escaped", "lost",
    "locked", "open", "closed", "burned", "poisoned", "invited", "married",
    "rescued", "hidden", "concealed", "trapped", "wealthy", "poor", "rich",
    "joyful", "gloomy", "airborne", "empty", "intact", "shrunk", "drunk",
}
SOCIAL_TOKENS = {
    "married", "invited", "invitation", "owned", "employed", "kissed",
    "agreed", "reward", "worshipped", "knighted", "reunited",
}
COMMUNICATION_TOKENS = {
    "heard", "informed", "spoken", "story", "declares", "announced",
    "requests", "calls", "sound", "phrase", "intent",
}
PLOT_TOKENS = {
    "rescued", "received", "reached", "fetched", "sewn", "shot", "broken",
    "repaired", "shared", "crossed", "collected", "revealed", "opened",
}

EVENT_RULES: list[tuple[str, set[str]]] = [
    ("ESCAPE", {"escape", "escaped", "flee", "flees", "run", "away"}),
    ("RESCUE", {"rescue", "rescued", "help", "reunite", "release", "save"}),
    ("HARM", {"attack", "bite", "kick", "shoot", "kill", "dead", "die", "dies", "eat", "eaten", "boil", "burn", "poison"}),
    ("TRANSFORM", {"transform", "disguise", "change", "grow", "shrink", "revert", "become"}),
    ("COMMUNICATE", {"tell", "inform", "speak", "spoken", "utter", "share", "hear", "call", "announce", "declare"}),
    ("SOCIAL_COMMITMENT", {"invite", "invites", "accept", "accepts", "propose", "proposes", "marriage", "marry", "married", "agree", "kiss"}),
    ("TRANSFER", {"give", "sell", "trade", "offer", "payment", "pay"}),
    ("ACQUIRE", {"receive", "take", "collect", "buy", "steal", "fetch", "obtain"}),
    ("CONTAIN", {"hide", "conceal", "contain", "force", "inside", "trap"}),
    ("MOVE", {"move", "travel", "arrive", "return", "approach", "climb", "enter", "cross", "carry", "follow", "go"}),
    ("DISCOVER", {"find", "found", "discover", "see", "spot", "witness", "meet", "encounter"}),
    ("REWARD", {"reward", "treasure", "gold", "rubies", "sapphires"}),
]

ROLE_NAME_RULES: list[tuple[str, set[str]]] = [
    ("authority", {"king", "queen", "prince", "princess", "master", "chief"}),
    ("family", {"father", "mother", "grandmother", "wife", "brother", "child", "children", "son"}),
    ("antagonist-candidate", {"wolf", "fox", "witch", "robber", "impostor", "stepmother", "woe"}),
    ("helper-candidate", {"dwarf", "dwarfs", "fairy", "gnome", "friend", "hunter", "tailor"}),
    ("animal-character", {"wolf", "fox", "pig", "cat", "hound", "cock", "donkey", "duck", "bird", "badger", "ass"}),
    ("reward-object", {"gold", "treasure", "ruby", "rubies", "sapphire", "sapphires", "crown", "kingdom"}),
    ("danger-place", {"foxhole", "forest", "oven", "jail", "pit"}),
    ("social-place", {"palace", "castle", "house", "cottage", "theater", "temple"}),
]

STOP_ACTION_TOKENS = {
    "a", "an", "and", "as", "at", "by", "for", "from", "in", "into",
    "of", "on", "the", "to", "with", "is", "be",
}


def tokens(name: str) -> list[str]:
    return [token for token in re.split(r"[_\-]+", name.lower()) if token]


@dataclass(frozen=True)
class Literal:
    predicate: str
    arguments: tuple[str, ...]
    argument_types: tuple[str, ...]
    negated: bool
    frame_key: str
    frame_category: str


@dataclass
class ConstantProfile:
    source: str
    name: str
    base_type: str
    roles: set[str] = field(default_factory=set)
    capabilities: set[str] = field(default_factory=set)
    predicates: set[str] = field(default_factory=set)
    actions: set[str] = field(default_factory=set)
    fixed_action_occurrences: int = 0

    def to_dict(self) -> dict[str, Any]:
        result = asdict(self)
        for key in ("roles", "capabilities", "predicates", "actions"):
            result[key] = sorted(result[key])
        return result


@dataclass(frozen=True)
class PredicateFrame:
    source: str
    predicate: str
    category: str
    relation: str
    value: str | None
    argument_types: tuple[str, ...]

    @property
    def key(self) -> str:
        suffix = f":{self.value}" if self.value else ""
        return f"{self.category}:{self.relation}{suffix}/{len(self.argument_types)}"


@dataclass
class ActionFrame:
    source: str
    action: str
    event_family: str
    parameters: dict[str, str]
    lifted_constants: dict[str, str]
    preconditions: list[Literal]
    add_effects: list[Literal]
    delete_effects: list[Literal]

    @property
    def id(self) -> str:
        return f"{self.source}:{self.action}"

    def to_dict(self) -> dict[str, Any]:
        def literal_dict(value: Literal) -> dict[str, Any]:
            return asdict(value)

        return {
            "id": self.id,
            "source": self.source,
            "action": self.action,
            "event_family": self.event_family,
            "parameters": self.parameters,
            "lifted_constants": self.lifted_constants,
            "preconditions": [literal_dict(item) for item in self.preconditions],
            "add_effects": [literal_dict(item) for item in self.add_effects],
            "delete_effects": [literal_dict(item) for item in self.delete_effects],
        }


@dataclass(frozen=True)
class CausalEdge:
    producer: str
    consumer: str
    producer_source: str
    consumer_source: str
    frame_key: str
    producer_literal: tuple[str, ...]
    consumer_literal: tuple[str, ...]
    bindings: tuple[tuple[str, str], ...]
    required_adapters: tuple[str, ...]
    lexical_novelty: float

    @property
    def cross_domain(self) -> bool:
        return self.producer_source != self.consumer_source

    def to_dict(self) -> dict[str, Any]:
        result = asdict(self)
        result["bindings"] = dict(self.bindings)
        result["cross_domain"] = self.cross_domain
        return result


@dataclass
class StoryCandidate:
    action_ids: list[str]
    connectors: list[CausalEdge]
    score: float

    @property
    def sources(self) -> list[str]:
        return [action_id.split(":", 1)[0] for action_id in self.action_ids]

    def to_dict(self) -> dict[str, Any]:
        return {
            "action_ids": self.action_ids,
            "sources": self.sources,
            "distinct_sources": len(set(self.sources)),
            "score": round(self.score, 6),
            "connectors": [edge.to_dict() for edge in self.connectors],
            "candidate_graph_connected": len(self.connectors) == len(self.action_ids) - 1 and all(
                edge.producer == self.action_ids[index]
                and edge.consumer == self.action_ids[index + 1]
                for index, edge in enumerate(self.connectors)
            ),
        }


@dataclass
class ExperimentResult:
    summary: dict[str, Any]
    constant_profiles: list[ConstantProfile]
    predicate_frames: list[PredicateFrame]
    action_frames: list[ActionFrame]
    causal_edges: list[CausalEdge]
    stories: dict[str, list[StoryCandidate]]


def predicate_frame(source: str, name: str, argument_types: Iterable[str]) -> PredicateFrame:
    name_tokens = tokens(name)
    token_set = set(name_tokens)
    value: str | None = None
    relation = name.replace("_", "-")

    if name in LOCATION_ALIASES:
        category, relation = "spatial", "located-at"
    elif name in POSSESSION_ALIASES:
        category, relation = "possession", "possesses"
    elif name == "owned_by":
        category, relation = "possession", "owned-by"
    elif token_set & STATUS_WORDS:
        category, relation = "status", "has-status"
        value = next((token for token in name_tokens if token in STATUS_WORDS), name_tokens[-1])
    elif token_set & SOCIAL_TOKENS:
        category, relation = "social", name_tokens[-1]
    elif token_set & COMMUNICATION_TOKENS:
        category, relation = "communication", name_tokens[-1]
    elif token_set & PLOT_TOKENS or not tuple(argument_types):
        category, relation = "plot", relation
    elif len(tuple(argument_types)) >= 2:
        category = "relation"
    else:
        category = "attribute"
    return PredicateFrame(source, name, category, relation, value, tuple(argument_types))


def action_parameters(action: list[SExpr]) -> dict[str, str]:
    if ":parameters" not in action:
        return {}
    expression = action[action.index(":parameters") + 1]
    if not isinstance(expression, list):
        return {}
    return typed_symbols(expression)


def iter_raw_literals(expr: SExpr, *, negated: bool = False) -> Iterator[tuple[str, tuple[str, ...], bool]]:
    reasons = unsupported_logic(expr)
    if reasons:
        raise ValueError(f"Unsupported logic: {reasons}")
    if not expr:
        return
    head = atom(expr[0]) if isinstance(expr[0], str) else ""
    if head == "not":
        if len(expr) > 1:
            yield from iter_raw_literals(expr[1], negated=not negated)
        return
    if head in {"exists", "forall"}:
        yield from iter_raw_literals(expr[-1], negated=negated)
        return
    if head in LOGICAL_FORMS:
        for child in expr[1:]:
            yield from iter_raw_literals(child, negated=negated)
        return
    if head.startswith(":") or head in BUILT_INS:
        return
    args = tuple(atom(value) for value in expr[1:] if isinstance(value, str))
    yield head, args, negated


def unsupported_logic(expr: SExpr) -> list[str]:
    """Accept conjunctions of signed atoms; reject unsupported syntax explicitly."""
    if not isinstance(expr, list):
        return ["malformed-expression"]
    if not expr:
        return []
    head = expr[0]
    if not isinstance(head, str):
        return ["malformed-expression"]
    if head == "and":
        return sorted({reason for child in expr[1:] for reason in unsupported_logic(child)})
    if head == "not":
        if len(expr) != 2 or not isinstance(expr[1], list) or not expr[1] or not isinstance(expr[1][0], str) or expr[1][0] in BUILT_INS:
            return ["non-atomic-negation"]
        return unsupported_logic(expr[1])
    if head in BUILT_INS:
        return [head]
    if head.startswith(":") or any(not isinstance(arg, str) for arg in expr[1:]):
        return ["malformed-atom"]
    return []


def literal_from_raw(
    source: str,
    domain: Domain,
    parameters: dict[str, str],
    predicate: str,
    arguments: tuple[str, ...],
    negated: bool,
) -> Literal:
    declaration = domain.predicates.get(predicate)
    declared_types = [value_type for _, value_type in declaration.parameters] if declaration else []
    argument_types = []
    for index, argument in enumerate(arguments):
        argument_types.append(
            parameters.get(
                argument,
                domain.constants.get(
                    argument,
                    declared_types[index] if index < len(declared_types) else "object",
                ),
            )
        )
    frame = predicate_frame(source, predicate, argument_types)
    return Literal(
        predicate=predicate,
        arguments=arguments,
        argument_types=tuple(argument_types),
        negated=negated,
        frame_key=frame.key,
        frame_category=frame.category,
    )


def event_family(action_name: str, frame_categories: Iterable[str] = ()) -> str:
    action_tokens = set(tokens(action_name))
    for family, keywords in EVENT_RULES:
        if action_tokens & keywords:
            return family
    categories = set(frame_categories)
    if "communication" in categories:
        return "COMMUNICATE"
    if "social" in categories:
        return "SOCIAL_EVENT"
    if "spatial" in categories:
        return "MOVE"
    return "PLOT_EVENT"


def initial_roles(name: str, base_type: str) -> set[str]:
    result = {
        "character" if base_type == "entity"
        else "artifact" if base_type == "item"
        else "place" if base_type == "location"
        else base_type
    }
    token_set = set(tokens(name))
    for role, keywords in ROLE_NAME_RULES:
        if token_set & keywords or any(keyword in name.lower() for keyword in keywords):
            result.add(role)
    return result


def update_profile_from_literal(profile: ConstantProfile, literal: Literal, index: int) -> None:
    profile.predicates.add(literal.predicate)
    if literal.frame_category == "spatial":
        profile.capabilities.add("move" if index == 0 else "host-location")
    elif literal.frame_category == "possession":
        profile.capabilities.add("possess" if index == 0 else "be-possessed")
    elif literal.frame_category == "communication":
        profile.capabilities.add("communicate")
    elif literal.frame_category == "social":
        profile.capabilities.add("participate-socially")
    elif literal.frame_category == "status":
        profile.capabilities.add("change-state")


def extract_domain_frames(domain: Domain) -> tuple[list[PredicateFrame], list[ActionFrame], list[ConstantProfile]]:
    source = next(iter(domain.sources))
    frames = [
        predicate_frame(source, predicate.name, [value_type for _, value_type in predicate.parameters])
        for predicate in domain.predicates.values()
    ]
    profiles = {
        name: ConstantProfile(source, name, base_type, roles=initial_roles(name, base_type))
        for name, base_type in domain.constants.items()
    }
    actions: list[ActionFrame] = []

    for action_name, action in domain.actions.items():
        if any(unsupported_logic(action[action.index(key) + 1])
               for key in (":precondition", ":effect") if key in action):
            continue
        parameters = action_parameters(action)
        preconditions: list[Literal] = []
        add_effects: list[Literal] = []
        delete_effects: list[Literal] = []
        fixed_constants: dict[str, str] = {}

        for section_name, target in ((":precondition", preconditions), (":effect", None)):
            if section_name not in action:
                continue
            expression = action[action.index(section_name) + 1]
            for predicate, arguments, negated in iter_raw_literals(expression):
                literal = literal_from_raw(source, domain, parameters, predicate, arguments, negated)
                if section_name == ":precondition":
                    target.append(literal)  # type: ignore[union-attr]
                elif negated:
                    delete_effects.append(literal)
                else:
                    add_effects.append(literal)
                for index, argument in enumerate(arguments):
                    if argument.startswith("?"):
                        continue
                    value_type = domain.constants.get(
                        argument,
                        literal.argument_types[index] if index < len(literal.argument_types) else "object",
                    )
                    fixed_constants[argument] = value_type
                    profile = profiles.setdefault(
                        argument,
                        ConstantProfile(source, argument, value_type, roles=initial_roles(argument, value_type)),
                    )
                    profile.actions.add(action_name)
                    profile.fixed_action_occurrences += 1
                    update_profile_from_literal(profile, literal, index)

        family = event_family(
            action_name,
            [literal.frame_category for literal in preconditions + add_effects + delete_effects],
        )
        actions.append(
            ActionFrame(
                source=source,
                action=action_name,
                event_family=family,
                parameters=parameters,
                lifted_constants={
                    name: f"?lifted_{re.sub(r'[^a-z0-9_]+', '_', name.lower())}"
                    for name in sorted(fixed_constants)
                },
                preconditions=preconditions,
                add_effects=add_effects,
                delete_effects=delete_effects,
            )
        )
    return frames, actions, list(profiles.values())


def compatible_types(left: str, right: str) -> tuple[bool, str | None]:
    if left == right or "object" in {left, right}:
        return True, None
    return True, f"adapt-type:{left}->{right}"


def lexical_novelty(left: str, right: str) -> float:
    left_tokens = set(tokens(left)) - STOP_ACTION_TOKENS
    right_tokens = set(tokens(right)) - STOP_ACTION_TOKENS
    if not left_tokens and not right_tokens:
        return 0.0
    similarity = len(left_tokens & right_tokens) / len(left_tokens | right_tokens)
    return 1.0 - similarity


def build_causal_edges(actions: list[ActionFrame]) -> list[CausalEdge]:
    best: dict[tuple[str, str, str], CausalEdge] = {}
    for producer in actions:
        for consumer in actions:
            if producer.id == consumer.id or producer.source == consumer.source:
                continue
            for effect in producer.add_effects:
                for precondition in consumer.preconditions:
                    if precondition.negated:
                        continue
                    if effect.frame_key != precondition.frame_key:
                        continue
                    if len(effect.arguments) != len(precondition.arguments):
                        continue
                    adapters: list[str] = []
                    compatible = True
                    for left_type, right_type in zip(effect.argument_types, precondition.argument_types):
                        ok, adapter = compatible_types(left_type, right_type)
                        compatible = compatible and ok
                        if adapter:
                            adapters.append(adapter)
                    if not compatible:
                        continue
                    bindings = tuple(zip(precondition.arguments, effect.arguments))
                    edge = CausalEdge(
                        producer=producer.id,
                        consumer=consumer.id,
                        producer_source=producer.source,
                        consumer_source=consumer.source,
                        frame_key=effect.frame_key,
                        producer_literal=effect.arguments,
                        consumer_literal=precondition.arguments,
                        bindings=bindings,
                        required_adapters=tuple(sorted(set(adapters))),
                        lexical_novelty=lexical_novelty(producer.action, consumer.action),
                    )
                    key = (producer.id, consumer.id, effect.frame_key)
                    existing = best.get(key)
                    if existing is None or len(edge.required_adapters) < len(existing.required_adapters):
                        best[key] = edge
    return sorted(best.values(), key=lambda edge: (edge.producer, edge.consumer, edge.frame_key))


def edge_score(
    edge: CausalEdge,
    *,
    novelty_level: str,
    frame_frequency: Counter[str],
    total_edges: int,
) -> float:
    domain_reward = 2.0 if edge.cross_domain else 0.0
    adapter_reward = {
        "conservative": -10.0,
        "creative": -0.35,
        "surreal": 0.50,
    }[novelty_level] * len(edge.required_adapters)
    information_reward = 0.75 * math.log(
        (total_edges + 1) / (frame_frequency[edge.frame_key] + 1)
    )
    return domain_reward + edge.lexical_novelty + adapter_reward + information_reward


def generate_stories(
    actions: list[ActionFrame],
    edges: list[CausalEdge],
    *,
    length: int,
    count: int,
    novelty_level: str,
    beam_size: int = 300,
) -> list[StoryCandidate]:
    if length < 2:
        raise ValueError("story length must be at least 2")
    outgoing: dict[str, list[CausalEdge]] = defaultdict(list)
    action_by_id = {action.id: action for action in actions}
    frame_frequency = Counter(edge.frame_key for edge in edges)
    for edge in edges:
        if novelty_level == "conservative" and edge.required_adapters:
            continue
        if novelty_level == "creative" and len(edge.required_adapters) > 1:
            continue
        outgoing[edge.producer].append(edge)

    beam = [StoryCandidate([action.id], [], 0.0) for action in actions if action.id in outgoing]
    for _ in range(length - 1):
        expanded: list[StoryCandidate] = []
        for candidate in beam:
            for edge in outgoing.get(candidate.action_ids[-1], []):
                if edge.consumer in candidate.action_ids:
                    continue
                action_ids = candidate.action_ids + [edge.consumer]
                connectors = candidate.connectors + [edge]
                sources = [value.split(":", 1)[0] for value in action_ids]
                previous_sources = set(candidate.sources)
                source_bonus = 0.50 if edge.consumer_source not in previous_sources else 0.0
                previous_frames = [item.frame_key for item in candidate.connectors]
                frame_bonus = 0.75 if edge.frame_key not in previous_frames else -0.60 * previous_frames.count(edge.frame_key)
                previous_families = {action_by_id[item].event_family for item in candidate.action_ids}
                family_bonus = 0.40 if action_by_id[edge.consumer].event_family not in previous_families else 0.0
                score = (
                    candidate.score
                    + edge_score(
                        edge,
                        novelty_level=novelty_level,
                        frame_frequency=frame_frequency,
                        total_edges=len(edges),
                    )
                    + source_bonus
                    + frame_bonus
                    + family_bonus
                )
                expanded.append(StoryCandidate(action_ids, connectors, score))
        if not expanded:
            return []
        expanded.sort(
            key=lambda value: (value.score, len(set(value.sources)), value.action_ids),
            reverse=True,
        )
        beam = expanded[:beam_size]

    unique: list[StoryCandidate] = []
    seen: set[tuple[str, ...]] = set()
    for candidate in beam:
        key = tuple(candidate.action_ids)
        if key in seen:
            continue
        seen.add(key)
        unique.append(candidate)
        if len(unique) >= count:
            break
    return unique


def _json_dump(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def run_experiment(
    input_dir: Path,
    output_dir: Path,
    *,
    story_length: int = 5,
    story_count: int = 10,
) -> ExperimentResult:
    paths = sorted(input_dir.glob("*_domainfile.pddl"), key=lambda path: path.name.lower())
    if not paths:
        raise ValueError(f"No narrative domains found under {input_dir}")

    predicate_frames: list[PredicateFrame] = []
    action_frames: list[ActionFrame] = []
    constant_profiles: list[ConstantProfile] = []
    quarantined: list[dict[str, Any]] = []
    for path in paths:
        domain = parse_domain(path, apply_reviewed_semantics=False)
        for name, action in domain.actions.items():
            reasons = sorted({reason for key in (":precondition", ":effect") if key in action
                              for reason in unsupported_logic(action[action.index(key) + 1])})
            if reasons:
                quarantined.append({"source": next(iter(domain.sources)), "action": name, "reasons": reasons})
        frames, actions, profiles = extract_domain_frames(domain)
        predicate_frames.extend(frames)
        action_frames.extend(actions)
        constant_profiles.extend(profiles)

    causal_edges = build_causal_edges(action_frames)
    stories = {
        level: generate_stories(
            action_frames,
            causal_edges,
            length=story_length,
            count=story_count,
            novelty_level=level,
        )
        for level in ("conservative", "creative", "surreal")
    }

    frame_groups = Counter(frame.key for frame in predicate_frames)
    frame_categories = Counter(frame.category for frame in predicate_frames)
    event_families = Counter(action.event_family for action in action_frames)
    direct_edges = [edge for edge in causal_edges if not edge.required_adapters]
    lifted_occurrences = sum(profile.fixed_action_occurrences for profile in constant_profiles)
    summary = {
        "method": "Role-Causal Narrative Composition",
        "representation_version": 2,
        "quarantined_actions": quarantined,
        "experiment": "RCNC Experiment 1: deterministic representation and causal composition",
        "input": {
            "domains": len(paths),
            "predicates": len(predicate_frames),
            "actions": len(action_frames) + len(quarantined),
            "eligible_actions": len(action_frames),
            "constant_profiles": len(constant_profiles),
        },
        "lifting": {
            "fixed_constant_occurrences_in_actions": lifted_occurrences,
            "actions_with_lifted_constants": sum(bool(action.lifted_constants) for action in action_frames),
        },
        "predicate_frames": {
            "unique_frame_keys": len(frame_groups),
            "cross_source_frame_keys": sum(
                1
                for key in frame_groups
                if len({frame.source for frame in predicate_frames if frame.key == key}) > 1
            ),
            "categories": dict(sorted(frame_categories.items())),
        },
        "action_frames": {
            "families": dict(sorted(event_families.items())),
        },
        "causal_graph": {
            "cross_domain_edges": len(causal_edges),
            "direct_edges": len(direct_edges),
            "role_adapter_edges": len(causal_edges) - len(direct_edges),
            "producer_actions": len({edge.producer for edge in causal_edges}),
            "consumer_actions": len({edge.consumer for edge in causal_edges}),
        },
        "stories": {
            level: {
                "count": len(values),
                "length": story_length,
                "max_distinct_sources": max((len(set(value.sources)) for value in values), default=0),
                "all_candidate_graph_connected": bool(values) and all(len(value.connectors) == story_length - 1 for value in values),
            }
            for level, values in stories.items()
        },
        "limitations": [
            "Experiment 1 validates abstract effect-to-precondition connectivity, not full grounded PDDL execution.",
            "Role and event labels are deterministic lexical/structural heuristics.",
            "Bindings are positional candidate annotations; they are not globally validated. Use the separate explicit-query planner for execution checks.",
        ],
    }

    _json_dump(output_dir / "summary.json", summary)
    _json_dump(output_dir / "entity_profiles.json", [profile.to_dict() for profile in constant_profiles])
    _json_dump(output_dir / "predicate_frames.json", [asdict(frame) | {"key": frame.key} for frame in predicate_frames])
    _json_dump(output_dir / "action_frames.json", [action.to_dict() for action in action_frames])
    _json_dump(output_dir / "causal_edges.json", [edge.to_dict() for edge in causal_edges])
    for level, values in stories.items():
        _json_dump(output_dir / "stories" / f"{level}.json", [value.to_dict() for value in values])

    return ExperimentResult(summary, constant_profiles, predicate_frames, action_frames, causal_edges, stories)



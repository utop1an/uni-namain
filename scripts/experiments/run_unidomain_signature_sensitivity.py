"""Run two explicitly scoped interpretations of the saved three-source UniDomain root."""

import argparse
from pathlib import Path

from unified_planning.io import PDDLReader
from unified_planning.shortcuts import SequentialSimulator

from rcnc.glaive_merge import action_fields
from rcnc.pddl import section, typed_symbols
from scripts.experiments.audit_official_unidomain_table234_projection import node_records
from scripts.experiments.evaluate_official_unidomain_matched import mapped_world, parse, tree
from scripts.experiments.evaluate_official_unidomain_table234 import BUDGET, causal_check
from scripts.experiments.run_downward_reference import run, save, sha
from scripts.experiments.run_matched_unidomain_rule import PLANNER, pddl
from scripts.experiments.run_official_unidomain_batch import read
from scripts.experiments.resume_official_unidomain_batch import receipt

GROUP = "story__causal_link__k03__004"
C = "writing_prompts__wp_011"
ARMS = ("merged_signatures", "separate_signatures")
BASE = Path("data/validation")
EXPERIMENT = BASE / "priority1_union_full_evaluation_2026_11_06_v1/repeat_01"
ROOT = BASE / ("official_unidomain_table234_batch_resume21_2026_11_09_v1/nodes/"
               "d7a50f67eb57aecfe62b08fb53e317e8c5f5ce88a0708b382fb6f3e64ba236f7/official_domain.json")
ROOT_SHA256 = "d84abacdd9b26fefb3c3d70a3b38e7535dc7fae129191a43abf30d6dc5b7438a"


def symbols(arm, source):
    # The root-round rewrite targets the broader has signature for AB, and C
    # already uses it. The old narrow declaration is kept unused when split.
    at = "shared_at" if arm == "merged_signatures" else (
        "at_character_place" if source == C else "shared_at_entity_object")
    return {"at": at, "has": "shared_has", "happy": "shared_happy"}


def rewrite_formula(expr, aliases):
    if not isinstance(expr, list):
        return expr
    return [aliases.get(expr[0], expr[0]), *[rewrite_formula(x, aliases) for x in expr[1:]]]


def export(arm, folder, union_domain, union_problem, mapping, ownership, root):
    source_ids = sorted(set(ownership.values()))
    membership = [p for p in section(union_domain, ":predicates")[1:]
                  if any(p[0] == s + "_active" or p[0].startswith(s + "_type_") for s in source_ids)]
    guard_names = {p[0] for p in membership}
    arities = {}
    for signature in root["predicates"]:
        tokens = parse(signature)
        # Count parameters without flattening the official either-type list.
        arity = sum(isinstance(v, str) and v.startswith("?") for v in tokens[1:])
        for source in source_ids:
            name = symbols(arm, source).get(tokens[0], tokens[0])
            if arities.setdefault(name, arity) != arity:
                raise ValueError("Inconsistent predicate arity")
    if arm == "separate_signatures":
        arities["has_item"] = arities["shared_has"]
    predicates = [[name, *[f"?p{i}" for i in range(arity)]] for name, arity in arities.items()]
    domain = ["define", ["domain", "revised_merged"], [":requirements", ":adl", ":typing", ":equality"]]
    constants = section(union_domain, ":constants")
    if constants and len(constants) > 1:
        domain.append(constants)
    domain.append([":predicates", *membership, *predicates])
    action_maps = {}
    for text in root["operators"].values():
        action = parse(text)
        name = action[1]
        source = ownership[name]
        fields = action_fields(action)
        params = typed_symbols(fields[":parameters"])
        guards = [[source + "_active"], *[[source + "_type_" + t, v] for v, t in params.items()]]
        if any(guard[0] not in guard_names for guard in guards):
            raise ValueError("Official action parameters require an absent source membership")
        aliases = symbols(arm, source)
        pre = rewrite_formula(fields[":precondition"], aliases)
        effect = rewrite_formula(fields[":effect"], aliases)
        domain.append([":action", name, ":parameters", list(params),
                       ":precondition", ["and", *guards, pre], ":effect", effect])
        action_maps[f"{source}:{name}"] = {"name": name, "order": list(range(len(params)))}
    folder.mkdir(parents=True)
    domain_path, problem_path = folder / "domain.pddl", folder / "problem.pddl"
    pddl(domain_path, domain)
    predicates = {(sid, name): (symbols(arm, sid).get(name, name), list(order))
                  for sid, maps in mapping["predicate_maps"].items() for name, (_, order) in maps.items()}
    if any(target not in arities or len(order) != arities[target] for target, order in predicates.values()):
        raise ValueError("Frozen predicate mapping outside exported dialect")
    mapped_world(union_problem, mapping, predicates, problem_path)
    problem = PDDLReader().parse_problem(str(domain_path), str(problem_path))
    with SequentialSimulator(problem) as sim:
        if sim.is_goal(sim.get_initial_state()):
            raise ValueError("Goal was true initially")
    return action_maps


def experiment(output, prepare_only=False):
    if sha(ROOT) != ROOT_SHA256:
        raise ValueError("Unexpected official root")
    nodes = node_records(ROOT)
    leaves = [Path(nodes[0][key]) for key in ("left", "right")] + [Path(nodes[1]["left"])]
    original_actions = [(parse(text)[1], path.stem)
                        for path in leaves for text in read(path)["operators"].values()]
    ownership = dict(original_actions)
    root = read(ROOT)
    if len(ownership) != len(original_actions) or set(ownership) != {
            parse(text)[1] for text in root["operators"].values()}:
        raise ValueError("Action ownership changed")
    records = read(EXPERIMENT / "composition_tasks.json")["tasks"]
    task, = [row for row in records if row["group"] == GROUP and row["condition"] == "union"]
    source_problem, source_domain, source_mapping = (Path(task[k]) for k in ("problem", "domain", "mapping"))
    frozen = (read(EXPERIMENT.parent / "protocol.json")["input_sha256"]
              | read(EXPERIMENT / "compiled_freeze.json")["input_sha256"])
    for path in (source_problem, source_domain, source_mapping):
        if sha(path) != frozen[str(path)]:
            raise ValueError("Frozen task input changed")
    output.mkdir(parents=True, exist_ok=False)
    bundle = output / "bundle"
    prepared, provenance = [], {}
    for arm in ARMS:
        directory = bundle / "tasks" / arm
        provenance[arm] = export(arm, directory, tree(source_domain), source_problem, read(source_mapping),
                                 ownership, root)
        prepared.append({"id": arm, "source": GROUP, "representation": arm,
                         "domain_sha256": sha(directory / "domain.pddl"),
                         "problem_sha256": sha(directory / "problem.pddl")})
    save(bundle / "manifest.json", {"status": "frozen_before_search", "mode": "matched_source_representations",
                                     "task_count": len(prepared), "tasks": prepared, "budget": BUDGET})
    save(output / "protocol.json", {
        "status": "frozen_before_search", "scope": "Two explicit interpretations, sensitivity analysis only",
        "group": GROUP, "official_root": receipt(ROOT), "frozen_problem": receipt(source_problem),
        "nodes": nodes, "action_source_maps": provenance, "budget": BUDGET,
        "policy": {"merged_signatures": "One fact per name and argument tuple for at and has.",
                   "separate_signatures": "C uses character-place at; A/B use entity-object at. "
                   "Root-round has rewrites and C bind to object has; stale item has is separate and unused.",
                   "common": "Official action bodies and arities retained. Action parameter types become "
                   "static source-membership guards on the frozen world. Predicate argument annotations "
                   "are used to name signatures, without independent runtime fluent-type restrictions. "
                   "Initial facts and goal moved by source provenance without adding business facts."},
    })
    if prepare_only:
        return
    assess(output, provenance)


def assess(output, provenance):
    report = run(Path("."), None, output / "solver", PLANNER, BUDGET["wall_seconds"],
                 BUDGET["memory_mb"], task_bundle=output / "bundle")
    group = {"sources": sorted({ref.split(":")[0] for ref in provenance[ARMS[0]]})}
    for row in report["rows"]:
        if row["status"] == "solved":
            row["attribution"] = causal_check(output, row["id"], group, provenance[row["id"]])
    save(output / "report.json", {"status": "complete_sensitivity_analysis", "group": GROUP,
                                  "rows": report["rows"], "protocol": receipt(output / "protocol.json")})


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--prepare-only", action="store_true")
    group.add_argument("--run-prepared", action="store_true")
    args = parser.parse_args()
    if args.run_prepared:
        assess(args.output, read(args.output / "protocol.json")["action_source_maps"])
    else:
        experiment(args.output, args.prepare_only)

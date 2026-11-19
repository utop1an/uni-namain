"""Replay and search with fixed alignments and the published operator union rule."""

import argparse
from collections import Counter
from copy import deepcopy
import json
from pathlib import Path

from rcnc.causal_attribution import recover_branch_provenance
from rcnc.glaive_merge import translate_plan
from rcnc.pddl import parse_sexpr, section, serialize, typed_symbols
from rcnc.revised_probe_validation import replay_physical
from scripts.experiments.run_downward_reference import run, save, sha


PARENT = Path("data/validation/priority1_union_full_evaluation_2026_11_06_v1/repeat_01")
PLANNER = Path(".tmp/fast-downward-26.6")
SECONDS = 5
MEMORY = 4096
ARMS = ("narrafuse", "unidomain_rule")


def read(path):
    return json.loads(path.read_text(encoding="utf-8"))


def tree(path):
    return parse_sexpr(path.read_text(encoding="utf-8"))


def pddl(path, value):
    path.write_text(serialize(value) + "\n", encoding="utf-8")


def actions(domain):
    return (x for x in domain if isinstance(x, list) and x and x[0] == ":action")


def mentions_intention(expr):
    return isinstance(expr, list) and bool(expr) and (
        expr[0] == "intends" or any(mentions_intention(x) for x in expr))


def physical_effect(expr):
    head = expr[0]
    if head == "intends" or (head == "not" and expr[1][0] == "intends"):
        return ["and"]
    if head == "and":
        return ["and", *(effect for part in expr[1:]
                         if (effect := physical_effect(part)) != ["and"])]
    if head in ("when", "forall"):
        if head == "when" and mentions_intention(expr[1]):
            raise ValueError("An effect guard reads intention")
        result = physical_effect(expr[2])
        return ["and"] if result == ["and"] else [head, expr[1], result]
    if mentions_intention(expr):
        raise ValueError("Unrecognized intention effect")
    return expr


def physical_domain(domain):
    requirements = section(domain, ":requirements")
    requirements[:] = [r for r in requirements if r != ":intentionality"]
    for action in actions(domain):
        fields = dict(zip(action[2::2], action[3::2]))
        if mentions_intention(fields.get(":precondition")):
            raise ValueError("An action precondition reads intention")
        if ":agents" in action:
            i = action.index(":agents")
            del action[i:i + 2]
        if ":effect" in action:
            i = action.index(":effect") + 1
            action[i] = physical_effect(action[i])
        else:
            action.extend([":effect", ["and"]])
    return [x for x in domain if x not in ([":types"], [":constants"])]


def physical_problem(problem):
    if mentions_intention(section(problem, ":goal")):
        raise ValueError("The goal reads intention")
    initial = section(problem, ":init")
    positives = [a for a in initial[1:] if a[0] not in ("intends", "not")]
    if any(a[0] == "not" and a[1] in positives for a in initial[1:]):
        raise ValueError("Contradictory explicit initial facts")
    initial[:] = [":init", *positives]
    return [x for x in problem if x != [":objects"]]


def union_rule(domain, provenance):
    domain = deepcopy(domain)
    changed = 0
    for action in actions(domain):
        entry = provenance["actions"].get(action[1])
        if entry is None:
            continue
        pre_index = action.index(":precondition") + 1
        guards, conditions = [], []
        parameters = list(typed_symbols(action[action.index(":parameters") + 1]))
        for branch in entry["branches"]:
            sid = branch["source"]
            head, active, *body = branch["precondition"]
            n = len(parameters)
            memberships = body[:n]
            if (head != "and" or active != [sid + "_active"]
                    or len(body) not in (n, n + 1)
                    or any(len(g) != 2 or not g[0].startswith(sid + "_type_")
                           for g in memberships)
                    or sorted(g[1] for g in memberships) != sorted(parameters)):
                raise ValueError(f"Unrecognized compiler guard layout in {action[1]}")
            guards.append(["and", active, *memberships])
            for condition in body[n:]:
                if condition not in conditions:
                    conditions.append(condition)
        # Source activation and type membership are encoding metadata. The
        # published union applies to domain preconditions and effects.
        # The effect union is identical here by the matched eligibility gate.
        action[pre_index] = ["and", ["or", *guards], *conditions]
        changed += 1
    if changed != len(provenance["actions"]) or not changed:
        raise ValueError("Expected nonempty, certified shared action clusters")
    return domain, changed


def prepare(output):
    output.mkdir(parents=True, exist_ok=False)
    frozen = read(PARENT / "compiled_freeze.json")["input_sha256"]
    inputs = {}

    def pin(path, expected=None):
        path = Path(path).resolve()
        actual = sha(path)
        expected = expected or frozen.get(str(path))
        if expected and expected != actual:
            raise ValueError(f"Historical hash mismatch: {path}")
        inputs[str(path)] = actual
        return path

    for name in ("compiled_freeze", "compilation_report", "composition_tasks",
                 "original_tasks", "references"):
        pin(PARENT / f"{name}.json")
    for name in (__file__, "rcnc/pddl.py", "rcnc/causal_attribution.py",
                 "rcnc/glaive_merge.py", "rcnc/revised_probe_validation.py",
                 "scripts/experiments/run_downward_reference.py"):
        pin(name)
    groups = {}
    for row in read(PARENT / "compilation_report.json")["rows"]:
        counts = row["model_counts"]["full"]
        if row["status"] == "compiled" and counts["action_count"] < counts["source_action_count"]:
            groups[row["group"]["id"]] = {"group": row["group"],
                "construction": row["construction"]["status"]}
    for gid, group in sorted(groups.items()):
        root = PARENT / "groups" / gid
        full = pin(root / "full/domain.pddl")
        mapping = pin(root / "full/mapping.json")
        variant = pin(root / "predicate_mapping_stage/domain.pddl")
        provenance = recover_branch_provenance(full, read(mapping), variant,
                                               read(pin(variant.with_name("mapping.json"))))
        directory = output / "models" / gid
        directory.mkdir(parents=True)
        original = tree(full)
        baseline, changed = union_rule(original, provenance)
        group["matched_action_clusters"] = changed
        group["mapping"] = str(mapping)
        group["models"] = {}
        if any(isinstance(x, list) and x and x[0] == ":axiom" for x in original):
            group["physical_status"] = "unsupported_native_axioms"
            continue
        try:
            projected = [physical_domain(model) for model in (original, baseline)]
        except ValueError as exc:
            group["physical_status"] = "unsupported_intention_dependency"
            group["physical_reason"] = str(exc)
            continue
        group["physical_status"] = "ready"
        for arm, model in zip(ARMS, projected):
            dest = directory / f"{arm}.pddl"
            pddl(dest, model)
            group["models"][arm] = {"path": str(dest), "sha256": sha(dest)}

    search_tasks = []
    bundle = output / "bundle"
    composition = {t["group"]: t for t in read(PARENT / "composition_tasks.json")["tasks"]
                   if t["condition"] == "full"}
    for gid, group in sorted(groups.items()):
        task = composition[gid]
        group["construction_status"] = task["status"]
        group["task_status"] = task["status"]
        if task["status"] != "ready":
            continue
        source_problem = pin(task["problem"])
        if group["physical_status"] != "ready":
            group["task_status"] = group["physical_status"]
            continue
        try:
            problem = physical_problem(tree(source_problem))
        except ValueError as exc:
            group["task_status"] = "unsupported_intention_goal"
            group["task_reason"] = str(exc)
            continue
        for arm in ARMS:
            task_id = f"{gid}__{arm}"
            dest = bundle / "tasks" / task_id
            dest.mkdir(parents=True)
            (dest / "domain.pddl").write_bytes(Path(group["models"][arm]["path"]).read_bytes())
            pddl(dest / "problem.pddl", problem)
            search_tasks.append({"id": task_id, "source": gid, "representation": arm,
                                 "domain_sha256": sha(dest / "domain.pddl"),
                                 "problem_sha256": sha(dest / "problem.pddl")})
        assert search_tasks[-2]["problem_sha256"] == search_tasks[-1]["problem_sha256"]
    refs = read(PARENT / "references.json")["worlds"]
    transports = []
    for task in sorted(read(PARENT / "original_tasks.json")["tasks"], key=lambda t: t["id"]):
        if task["condition"] != "full" or task["group"] not in groups:
            continue
        reference = refs[task["world"]]
        assert reference["source"] == task["source"]
        transports.append(task | {"reference": reference})
        if reference.get("validation_level") == "dual_validated":
            pin(reference["source_plan"], reference["source_plan_sha256"])
            pin(task["problem"])
    budget = {"wall_seconds": SECONDS, "overall_cpu_seconds": SECONDS, "memory_mb": MEMORY, "workers": 1}
    save(bundle / "manifest.json", {"status": "frozen_before_search",
        "mode": "matched_source_representations", "budget": budget,
        "task_count": len(search_tasks), "tasks": search_tasks})
    protocol = {"status": "frozen_before_replay_and_search",
        "scope": "Matched operator-rule adaptation, with frozen alignments and NarraFuse-eligible clusters. "
                 "The UniDomain-style arm conjunctively unions business conditions and unions effects; "
                 "source activation/type guards remain alternatives in both arms. Identical effects on "
                 "eligible clusters. Shared physical projection drops write-only intention annotations, "
                 "normalizes empty declarations, omitted effects and explicit false initial atoms, "
                 "and marks native axioms and intention dependencies unsupported. "
                 "No new model calls.",
        "selection": "Every frozen Priority-1 group with an accepted and applied NarraFuse action cluster.",
        "groups": groups, "transport_slots": transports, "input_sha256": inputs,
        "bundle_sha256": sha(bundle / "manifest.json"), "budget": budget}
    save(output / "protocol.json", protocol)
    print(json.dumps({"groups": len(groups), "composition_pairs": len(search_tasks) // 2,
                      "transport_slots_per_arm": len(transports),
                      "dual_reference_slots": sum(t["reference"].get("validation_level") == "dual_validated"
                                                 for t in transports)}), flush=True)


def execute(output):
    protocol_file = output / "protocol.json"
    protocol_digest = sha(protocol_file)
    protocol = read(protocol_file)
    inputs = protocol["input_sha256"]
    bundle = output / "bundle"
    budget = protocol["budget"]
    if ((output / "replay").exists() or (output / "solver").exists()
            or sha(bundle / "manifest.json") != protocol["bundle_sha256"]
            or any(sha(Path(p)) != h for p, h in inputs.items())
            or any(sha(Path(m["path"])) != m["sha256"]
                   for g in protocol["groups"].values() for m in g["models"].values())):
        raise ValueError("Expected unchanged frozen inputs and a fresh execution")
    transports = []
    for task in protocol["transport_slots"]:
        reference = task["reference"]
        row = {key: task[key] for key in ("id", "group", "world", "source", "cohort")}
        row["reference_status"] = reference.get("validation_level", reference["status"])
        group = protocol["groups"][task["group"]]
        if row["reference_status"] == "dual_validated" and group["physical_status"] != "ready":
            for arm in ARMS:
                row[arm] = {"status": group["physical_status"]}
        elif row["reference_status"] == "dual_validated":
            plan = output / "replay" / f'{task["id"]}.pddl'
            plan.parent.mkdir(exist_ok=True)
            translate_plan(task["source"], read(Path(group["mapping"])), task["terms"],
                           reference["source_plan"], plan)
            actual_problem = Path(task["problem"])
            plan_tree = tree(plan)
            section(plan_tree, ":problem")[1] = section(tree(actual_problem), "problem")[1]
            pddl(plan, plan_tree)
            row["plan"] = str(plan)
            row["plan_sha256"] = sha(plan)
            physical = plan.with_suffix(".problem.pddl")
            try:
                pddl(physical, physical_problem(tree(actual_problem)))
            except ValueError as exc:
                for arm in ARMS:
                    row[arm] = {"status": "unsupported_intention_goal", "reason": str(exc)}
                transports.append(row)
                continue
            for arm in ARMS:
                try:
                    replay = replay_physical(Path(group["models"][arm]["path"]), physical, plan)
                    replay.pop("applied", None)
                    row[arm] = replay
                except (ValueError, KeyError, TypeError, IndexError) as exc:
                    row[arm] = {"status": "unsupported_replay", "reason": str(exc)}
        transports.append(row)
    save(output / "transport_report.json", {"rows": transports})
    report = run(Path("."), None, output / "solver", PLANNER, budget["wall_seconds"],
                 budget["memory_mb"], task_bundle=bundle)
    assert all(report[key] for key in ("binary_unchanged", "runner_unchanged",
                                      "implementation_unchanged", "validator_unchanged"))
    assert all(r["inputs_unchanged"] for r in report["rows"])
    assert sha(protocol_file) == protocol_digest and all(sha(Path(p)) == h for p, h in inputs.items())
    by_id = {row["id"]: row for row in report["rows"]}
    composition = []
    for gid, group in sorted(protocol["groups"].items()):
        row = {"group": gid, "cohort": group["group"]["cohort"], "task_status": group["task_status"],
               "construction_status": group["construction_status"]}
        for arm in ARMS:
            row[arm] = by_id.get(f"{gid}__{arm}", {"status": group["task_status"]})
        composition.append(row)
    eligible = [r for r in transports if r["reference_status"] == "dual_validated"]
    ready = [r for r in composition if r["task_status"] == "ready"]
    summary = {"status": "complete", "protocol_sha256": protocol_digest,
               "solver_report_sha256": sha(output / "solver/report.json"),
               "transport_report_sha256": sha(output / "transport_report.json"),
               "group_count": len(composition), "search_pairs": len(ready),
               "transport_slots": len(transports), "dual_reference_slots": len(eligible),
               "constructed_tasks": sum(r["construction_status"] == "ready" for r in composition),
               "reference_counts": dict(Counter(r["reference_status"] for r in transports)),
               "construction_counts": dict(Counter(r["task_status"] for r in composition)),
               "transport_passes": {a: sum(r[a].get("goal") is True and r[a]["status"] == "replayed"
                                          for r in eligible) for a in ARMS},
               "search_outcomes": {a: dict(Counter(r[a]["status"] for r in ready)) for a in ARMS},
               "replay_outcomes": {a: dict(Counter(r[a]["status"] for r in eligible)) for a in ARMS},
               "rows": composition}
    save(output / "report.json", summary)
    print(json.dumps({k: v for k, v in summary.items() if k != "rows"}), flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("phase", choices=("prepare", "execute"))
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    {"prepare": prepare, "execute": execute}[args.phase](args.output)

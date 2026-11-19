"""Freeze and execute a matched physical comparison on the terminal UniDomain domains."""

import argparse
from collections import Counter, defaultdict
from functools import cache
from pathlib import Path
import json
import shutil
import subprocess
import sys
import time

from unified_planning.io import PDDLReader
from unified_planning.shortcuts import SequentialSimulator

from rcnc.causal_attribution import causal_trace_v2
from rcnc.pddl import section, serialize
from scripts.experiments.audit_official_unidomain_table234_projection import (
    audit, physical_projection, pinned, tree,
)
from scripts.experiments.evaluate_official_unidomain_matched import parse
from scripts.experiments.run_downward_reference import run, save, sha
from scripts.experiments.run_matched_unidomain_rule import PLANNER, physical_domain, physical_problem, pddl
from scripts.experiments.run_official_unidomain_batch import read
from scripts.experiments.resume_official_unidomain_batch import atomic_progress, receipt

ARMS = {"union": "union", "full": "narrafuse", "official": "official_unidomain"}
BUDGET = {"wall_seconds": 5, "overall_cpu_seconds": 5, "memory_mb": 4096, "workers": 1}
MAPPING_ERRORS = (ValueError, TypeError, KeyError, IndexError)


@cache
def load(path):
    return read(path)


def task_index(path, fields):
    paired = {}
    for task in read(path)["tasks"]:
        key = tuple(task[field] for field in fields)
        per_arm = paired.setdefault(key, {})
        if task["condition"] in per_arm:
            raise ValueError("Duplicate frozen task key")
        per_arm[task["condition"]] = task
    if any(set(arms) != {"union", "full"} for arms in paired.values()):
        raise ValueError("Unpaired historical tasks")
    return paired


def project_problem(path, destination):
    projected = physical_problem(tree(path))
    pddl(destination, [part for part in projected
                       if not isinstance(part, list) or part[:1] != [":requirements"]])


def export_baselines(directory, group):
    for condition in ("union", "full"):
        source = pinned(group["frozen_arms"][ARMS[condition]]["domain"])
        model = tree(source)
        if any(isinstance(x, list) and x[:1] in ([":axiom"], [":derived"]) for x in model):
            raise ValueError("Native axiom outside the shared physical condition")
        pddl(directory / (condition + ".pddl"), physical_domain(model))


def mapped_steps(original_calls, source, mapping, terms):
    for call in original_calls:
        action = mapping.get(source + ":" + call[0])
        if action is None:
            return None
        if sorted(action["order"]) != list(range(len(call) - 1)):
            raise ValueError("Unverified reference argument order")
    return [[mapping[source + ":" + call[0]]["name"],
             *[terms[call[i+1]] for i in mapping[source + ":" + call[0]]["order"]]]
            for call in original_calls]


def register(registry, projection, output):
    groups = {r["id"]: r for r in registry["groups"]}
    projected = {r["group"]: r for r in projection["rows"]}
    inputs = registry["registered_inputs"]
    model_root = output / "models"
    model_root.mkdir()
    models, admissions, searches, replays = {}, [], [], []
    for key, fields in (("composition", ("group",)), ("anchor", ("group", "source", "world")),
                        ("transport", ("group", "source", "world"))):
        for index, (task_key, pair) in enumerate(task_index(pinned(inputs[key]), fields).items()):
            gid = task_key[0]
            official = projected[gid]
            row = {"id": f"{key}_{index:05d}", "key": list(task_key), "kind": key,
                   "group": gid, "status": "unregistered", "fusion_status": official["fusion_status"]}
            admissions.append(row)
            if any(not t.get("problem") for t in pair.values()):
                row["status"] = "no_registered_problem"
                continue
            reference = pair["union"].get("reference") if key == "transport" else None
            if key == "transport" and (reference or {}).get("validation_level") != "dual_validated":
                row["status"] = "no_dual_reference"
                continue
            if official["status"] != "projected_physical_model":
                row["status"] = official["status"]
                continue
            directory = model_root / gid
            if gid not in models:
                directory.mkdir()
                try:
                    export_baselines(directory, groups[gid])
                except MAPPING_ERRORS as error:
                    models[gid] = str(error)
                else:
                    models[gid] = None
            if models[gid] is not None:
                row.update(status="unsupported_baseline_export", reason=models[gid])
                continue
            baseline_map = {k: load(Path(t["mapping"])) for k, t in pair.items()}
            aliases = load(Path(official["lineage"]["path"]))
            pred = {(sid, name): (target, order) for sid, name, target, order in aliases["predicates"]}
            action = {f"{sid}:{name}": {"name": target, "order": order}
                      for sid, name, target, order in aliases["actions"]}
            tasks = []
            try:
                if key == "transport":
                    if pair["full"].get("reference") != reference:
                        raise ValueError("Methods lack an identical frozen reference")
                    plan = Path(reference["source_plan"])
                    if sha(plan) != reference["source_plan_sha256"]:
                        raise ValueError("Frozen reference changed")
                    calls = section(tree(plan), ":steps")[1:]
                    if any(not call or call[0] == "non-executed" for call in calls):
                        raise ValueError("Reference uses nonphysical counterfactual steps")
                    row["reference"] = receipt(plan)
                for condition, arm in ARMS.items():
                    task_id = row["id"] + "__" + arm
                    root = output / ("replay" if key == "transport" else "bundle") / "tasks" / task_id
                    root.mkdir(parents=True)
                    domain = root / "domain.pddl"
                    problem = root / "problem.pddl"
                    if condition == "official":
                        shutil.copyfile(official["domain"]["path"], domain)
                        physical_projection(pair["union"]["problem"], baseline_map["union"], pred, problem)
                    else:
                        shutil.copyfile(directory / (condition + ".pddl"), domain)
                        project_problem(pair[condition]["problem"], problem)
                    parsed = PDDLReader().parse_problem(str(domain), str(problem))
                    task = {"id": task_id, "source": gid, "representation": arm,
                            "domain_sha256": sha(domain), "problem_sha256": sha(problem)}
                    if key == "composition":
                        with SequentialSimulator(parsed) as simulator:
                            task["goal_initially_true"] = simulator.is_goal(simulator.get_initial_state())
                    if key == "transport":
                        mapping = action if condition == "official" else baseline_map[condition]["action_maps"]
                        terms = pair["union" if condition == "official" else condition]["terms"]
                        steps = mapped_steps(calls, task_key[1], mapping, terms)
                        if steps is None:
                            if condition != "official":
                                raise ValueError("Archived baseline lacks a reference action")
                            task["absent_action"] = True
                        else:
                            plan_path = root / "plan.txt"
                            plan_path.write_text("".join(serialize(call) + "\n" for call in steps), encoding="utf-8")
                            task["plan_sha256"] = sha(plan_path)
                    tasks.append(task)
            except Exception as error:
                row.update(status="unsupported_projection_or_binding", reason=str(error))
                continue
            row.update(status="ready", tasks=[t["id"] for t in tasks])
            if key == "composition":
                row["goal_initially_true"] = {
                    task["representation"]: task["goal_initially_true"] for task in tasks}
            (replays if key == "transport" else searches).extend(tasks)
    for name, tasks in (("bundle", searches), ("replay", replays)):
        directory = output / name
        directory.mkdir(exist_ok=True)
        save(directory / "manifest.json", {"status": "frozen_before_search", "mode": "matched_source_representations",
                                           "task_count": len(tasks), "tasks": tasks, "budget": BUDGET})
    save(output / "admissions.json", {"status": "frozen_before_evaluation", "rows": admissions,
                                     "budget": BUDGET, "scope": "Same registered tasks and fresh physical checks for "
                                     "all three methods. This does not replace the archived native/dual evidence."})
    return admissions, searches, replays


def replay(output, tasks):
    results = []
    script = ("import json, sys; from pathlib import Path; from rcnc.validation import validate_artifacts; "
              "print(json.dumps(validate_artifacts(Path(sys.argv[1]))))")
    for task in tasks:
        root = output / "replay" / "tasks" / task["id"]
        if (sha(root / "domain.pddl") != task["domain_sha256"]
                or sha(root / "problem.pddl") != task["problem_sha256"]):
            raise ValueError("Frozen replay model or world changed")
        row = {"id": task["id"], "status": "source_action_absent"}
        if not task.get("absent_action"):
            if sha(root / "plan.txt") != task["plan_sha256"]:
                raise ValueError("Frozen replay plan changed")
            try:
                result = subprocess.run([sys.executable, "-c", script, str(root)], capture_output=True,
                                        encoding="utf-8", timeout=BUDGET["wall_seconds"], check=True)
                result = json.loads(result.stdout.splitlines()[-1])
                row.update(status=result["status"], validation=result)
            except subprocess.TimeoutExpired:
                row["status"] = "replay_timeout"
            except (ValueError, subprocess.CalledProcessError):
                row["status"] = "replay_process_error"
        results.append(row)
    return results


def causal_check(output, task_id, group, action_map):
    root = output / "solver" / "tasks" / task_id
    try:
        actions = [parse(line) for line in (root / "plan.txt").read_text(encoding="utf-8").splitlines()
                   if line.strip() and not line.lstrip().startswith(";")]
        problem = tree(root / "problem.pddl")
        plan = root / "causal.plan.pddl"
        pddl(plan, ["define", ["plan", "physical_plan"], [":problem", section(problem, "problem")[1]],
                    [":steps", *actions]])
        return causal_trace_v2(root / "domain.pddl", root / "problem.pddl", plan,
                               {"action_maps": action_map}, selected_sources=group["sources"],
                               source_count_profile=True)
    except MAPPING_ERRORS as error:
        return {"status": "unknown", "reason": str(error)}


def evaluate(registry_path, fusion, output, *, prepare_only):
    output.mkdir(parents=True, exist_ok=False)
    registry = read(registry_path)
    sealed = read(fusion)
    protocol = read(Path(sealed["protocol"]["path"]))
    if (sha(Path(sealed["protocol"]["path"])) != sealed["protocol"]["sha256"]
            or sha(registry_path) != protocol["registry_sha256"]):
        raise ValueError("Final fusion is not tied to the frozen input registry")
    save(output / "protocol.json", {
        "status": "physical_condition_registered", "registry": receipt(registry_path),
        "fusion": receipt(fusion), "implementation": receipt(Path(__file__)),
        "budget": BUDGET, "methods": list(ARMS.values()), "search": "Fast Downward 26.6 LAMA-first",
        "replay": "Unified Planning sequential validator on the same ordered source plan",
        "scope": "Shared physical condition. Archived Glaive and intention evidence remains separate.",
    })
    audit(registry_path, fusion, output / "projection")
    projection = read(output / "projection" / "report.json")
    admissions, searches, replays = register(registry, projection, output)
    if prepare_only:
        return
    replay_rows = replay(output, replays)
    save(output / "replay_report.json", {"status": "complete", "rows": replay_rows})
    search_rows = run(Path("."), None, output / "solver", PLANNER, BUDGET["wall_seconds"],
                      BUDGET["memory_mb"], task_bundle=output / "bundle")["rows"] if searches else []
    by_task = {r["id"]: r for r in (*search_rows, *replay_rows)}
    groups = {g["id"]: g for g in registry["groups"]}
    official = {g["group"]: g for g in projection["rows"]}
    counts = defaultdict(Counter)
    for row in admissions:
        counts[row["kind"]][row["status"]] += 1
        if row["status"] != "ready":
            continue
        row["results"] = {}
        for task_id in row["tasks"]:
            arm = task_id.split("__")[-1]
            result = by_task[task_id]
            row["results"][arm] = result
            counts[row["kind"]][f"{arm}:{result['status']}"] += 1
            if row["kind"] != "composition" or result["status"] != "solved":
                continue
            if row["goal_initially_true"][arm]:
                counts[row["kind"]][f"{arm}:goal_initially_true"] += 1
                continue
            group = groups[row["group"]]
            if arm == "official_unidomain":
                actions = load(Path(official[row["group"]]["lineage"]["path"]))["actions"]
                action_map = {f"{sid}:{name}": {"name": target, "order": order}
                              for sid, name, target, order in actions}
            else:
                action_map = load(pinned(group["frozen_arms"][arm]["mapping"]))["action_maps"]
            attribution = causal_check(output, task_id, group, action_map)
            result["attribution"] = attribution
            profile = attribution.get("source_count_profile") or {}
            if profile.get("status") != "classified":
                counts[row["kind"]][f"{arm}:attribution_unknown"] += 1
            else:
                for threshold, verdict in profile["at_least"].items():
                    counts[row["kind"]][f"{arm}:sources_ge_{threshold}:{verdict['status']}"] += 1
    save(output / "report.json", {"status": "complete_physical_comparison", "counts": counts, "rows": admissions,
                                  "admission": receipt(output / "admissions.json"), "fusion": receipt(fusion),
                                  "limits": "The physical condition has no intention validation. "
                                            "Ambiguous or unproven source branches remain unknown."})


def wait_for_fusion(registry, fusion, output, *, prepare_only):
    queue = output.with_name(output.name + ".queue.json")
    if queue.exists() or output.exists():
        raise ValueError("Fresh evaluation target required")
    report_path = fusion.with_name("report.json")
    start = time.time()
    while True:
        if report_path.is_file():
            state = read(report_path)
            heartbeat = report_path.stat().st_mtime
        else:
            state, heartbeat = {}, start
        status = state.get("status", "waiting_for_report")
        if status in {"fusion_terminal", "fusion_budget_exhausted_frozen"}:
            if not fusion.is_file():
                raise ValueError("Missing terminal domain manifest")
            atomic_progress(queue, {"status": "evaluation_started", "fusion": receipt(fusion)})
            break
        if (status in {"recovery_incomplete", "batch_state_unresolved", "batch_ended_without_completion",
                       "budget_cap_reached"} or time.time() - heartbeat > 3600):
            atomic_progress(queue, {"status": "evaluation_wait_stopped", "fusion_status": status})
            return
        atomic_progress(queue, {"status": "waiting_for_terminal_fusion", "fusion_status": status,
                                "wave": state.get("wave"), "budget": BUDGET})
        time.sleep(40)
    try:
        evaluate(registry, fusion, output, prepare_only=prepare_only)
    except Exception as error:
        atomic_progress(queue, {"status": "evaluation_error", "reason": f"{type(error).__name__}: {error}"})
        raise
    atomic_progress(queue, {"status": "evaluation_prepared" if prepare_only else "evaluation_complete"})


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("registry", type=Path)
    parser.add_argument("fusion", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--prepare-only", action="store_true")
    parser.add_argument("--wait-for-fusion", action="store_true")
    args = parser.parse_args()
    execute = wait_for_fusion if args.wait_for_fusion else evaluate
    execute(args.registry, args.fusion, args.output, prepare_only=args.prepare_only)

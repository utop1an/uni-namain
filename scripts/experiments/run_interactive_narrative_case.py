"""Freeze and run a reusable-domain vignette from saved local artifacts."""

import argparse
from collections import Counter
import json
from pathlib import Path
import subprocess
import sys
from zipfile import ZIP_DEFLATED, ZipFile

from unified_planning.io import PDDLReader
from unified_planning.shortcuts import SequentialSimulator

from rcnc.causal_attribution import causal_trace_v2
from rcnc.glaive_merge import Source, map_problem
from rcnc.pddl import parse_sexpr, section
from rcnc.revised_followup import authored_problem
from rcnc.validation import validate_artifacts
from scripts.experiments.audit_official_unidomain_table234_projection import (
    node_records, physical_projection,
)
from scripts.experiments.evaluate_official_unidomain_matched import lineage, project_model
from scripts.experiments.run_matched_unidomain_rule import (
    actions, pddl, physical_domain, physical_problem, tree,
)
from scripts.experiments.run_downward_reference import save, sha

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / "data/validation"
GROUP = "human__random__k03__022"
SOURCES = {
    "arthur": "human_72bec7307b121ea5",
    "batman": "human_62959785b3ec220a",
    "red": "human_281c51d26d5d4ff3",
}
RESCUE = DATA / "priority1_red_arthur_batman_2026_11_08_v1"
ORIGINAL = DATA / "rescue_original_plan_comparison_2026_11_10_v1"
BATCH = DATA / "official_unidomain_table234_batch_resume115_2026_11_15_v1/report.json"
SOURCE_INDEX = DATA / "priority1_union_full_initialization_capped8_continuation_2026_11_09_v1/sources.json"


def read(path):
    return json.loads(path.read_text(encoding="utf-8"))


def calls(path):
    return [parse_sexpr(line) for raw in path.read_text(encoding="utf-8").splitlines()
            if (line := raw.split(";", 1)[0].strip())]


def write_plan(path, steps):
    path.write_text("".join("(" + " ".join(step) + ")\n" for step in steps), encoding="utf-8")


def physical_world(raw, path):
    pddl(path, [part for part in physical_problem(tree(raw))
                if not isinstance(part, list) or part[:1] != [":requirements"]])


def packet(root, sources):
    brief = """# Interactive narrative task authoring

Write 3–5 short quest requirements using the attached source modules. Give each
task a title, a player-facing goal, named entities and their source roles, an
explicit starting world, and success conditions. List any scene or role
constraints that a plan must respect. Include a variation that changes the
starting world or a constraint while retaining the same modules. You can
propose a task whose feasibility is uncertain. Do not design a solution trace.

The attached domain and original problem files describe what each module can
express. Treat the original problems as examples of the vocabulary. Supply the
new world's facts explicitly. Label each fact and goal with its source
module, and specify any entity that plays a role in multiple modules.
Record your name or study ID, date, and any prior exposure to project results.
Return the requirements before seeing any generated domains or solver output.
"""
    with ZipFile(root / "task-author-packet.zip", "x", compression=ZIP_DEFLATED) as archive:
        archive.writestr("README.md", brief)
        for name, source in sources.items():
            archive.write(source.domain_path, f"{name}/domain.pddl")
            archive.write(source.problem_path, f"{name}/original-problem.pddl")


def prepare(spec_path, root):
    spec = read(spec_path)
    if spec["group"] != GROUP or spec["model_calls"] != 0:
        raise ValueError("Unexpected source group or model-call policy")
    rescue = read(RESCUE / "protocol.json")
    base_world = read(RESCUE / "scenario.json")
    source_catalog = {entry["id"]: entry for entry in read(SOURCE_INDEX)["sources"]}
    references = {entry["source"]: entry for entry in read(ORIGINAL / "comparison_evidence.json")["original_cases"]}
    source_args = {}
    pinned_inputs = {spec_path, SOURCE_INDEX, Path(__file__)}
    for label, sid in SOURCES.items():
        entry = source_catalog[sid]
        domain, problem = Path(entry["domain"]), Path(entry["representative_problem"])
        source_args[label] = Source(sid, domain, problem, constant_contract=entry["constant_contract"],
                                    consent_policy=entry["consent_policy"])
        pinned_inputs.update((domain, problem))

    root.mkdir(parents=True)
    models = root / "models"
    models.mkdir()
    maps, domains = {}, {}
    for arm, historical in (("union", "union"), ("narrafuse", "full")):
        receipts = rescue["tasks"][historical]
        d, m = Path(receipts["domain"]), Path(receipts["mapping"])
        for path in (d, m):
            if sha(path) != rescue["input_sha256"][str(path)]:
                raise ValueError(f"Historical input changed: {path}")
        pinned_inputs.update((d, m))
        domains[arm] = models / f"{arm}.pddl"
        maps[arm] = read(m)
        pddl(domains[arm], physical_domain(tree(d)))
        save(models / f"{arm}.mapping.json", maps[arm])

    for label, sid in SOURCES.items():
        arm = f"isolated-{label}"
        domains[arm] = models / f"{arm}.pddl"
        model = tree(domains["union"])
        names = {row["name"] for name, row in maps["union"]["action_maps"].items()
                 if name.startswith(sid + ":")}
        if not names or not names <= {action[1] for action in actions(model)}:
            raise ValueError(f"Incomplete isolated action provenance for {label}")
        pddl(domains[arm], [part for part in model
                            if part not in actions(model) or part[1] in names])

    official_arm = "official-unidomain"
    checkpoint = read(BATCH)
    official = next(row for row in checkpoint["rows"] if row["group"] == GROUP)
    official_status = {"status": official["status"]}
    if official["status"] == "official_root_constructed":
        path = ROOT / official["domain"]
        if sha(path) != official["sha256"]:
            raise ValueError("Official root hash mismatch")
        pinned_inputs.add(path)
        official_status.update(root=str(path.relative_to(ROOT)), sha256=sha(path))
        try:
            nodes = node_records(path)
            predicates, official_actions = lineage({"domain": str(path), "nodes": nodes})
            preflight = models / f"{official_arm}.pddl"
            project_model(path, predicates, official_actions, domains["union"], maps["union"], preflight)
            domains[official_arm] = preflight
            official_status["status"] = "projected_physical_model"
            official_status["lineage_nodes"] = list(nodes)
        except (ValueError, KeyError, TypeError, IndexError) as error:
            official_status.update(status="unsupported_official_export", reason=str(error))

    scenarios, entries = [], []
    for definition in spec["tasks"]:
        removed = [[SOURCES[sid], atom] for sid, atom in definition.get("remove_facts", [])]
        if any(fact not in base_world["facts"] for fact in removed):
            raise ValueError("Removal references an absent fact")
        scenario = {**base_world, "id": definition["id"],
                    "facts": [fact for fact in base_world["facts"] if fact not in removed],
                    "goal": [[SOURCES[sid], goal] for sid, goal in definition["goal"]]}
        scenarios.append(scenario)
        registered = {}
        for arm in (*domains, *([] if official_arm in domains else [official_arm])):
            entry = {"task": definition["id"], "arm": arm, "kind": "search"}
            entries.append(entry)
            folder = root / "checks" / definition["id"] / arm
            folder.mkdir(parents=True)
            if arm not in domains:
                entry.update(official_status)
                continue
            problem = folder / "problem.pddl"
            if arm == official_arm:
                try:
                    physical_projection(registered["union"], maps["union"], predicates, problem)
                    PDDLReader().parse_problem(str(domains[arm]), str(problem))
                except (ValueError, KeyError, TypeError, IndexError, SyntaxError) as error:
                    entry.update(status="unsupported_official_problem", reason=str(error))
                    continue
            elif arm.startswith("isolated-"):
                problem.write_bytes(registered["union"].read_bytes())
            else:
                raw = folder / "authored.pddl"
                mapping = authored_problem(list(source_args.values()), maps[arm], scenario, raw)
                if mapping["source_problem_facts_copied"]:
                    raise ValueError("Unexpected source problem facts in authored world")
                physical_world(raw, problem)
            registered[arm] = problem
            entry["status"] = "ready"

    for label, source in source_args.items():
        sid = source.id
        ref = references[label]
        path = ORIGINAL / ref["path"]
        if sha(path) != ref["sha256"]:
            raise ValueError(f"Reference plan changed: {label}")
        pinned_inputs.add(path)
        if label == "arthur":
            source_calls = section(tree(path), ":steps")[1:]
        else:
            source_calls = [[step[0].removeprefix(sid + "_a_"),
                             *[term.removeprefix(sid + "_o_") for term in step[1:]]]
                            for step in calls(path)]
        original_terms = None
        for arm in ("union", "narrafuse", f"isolated-{label}", official_arm):
            task = f"original-{label}"
            entry = {"task": task, "arm": arm, "kind": "replay", "reference": ref["validation"]}
            entries.append(entry)
            if arm not in domains:
                entry.update(official_status)
                continue
            folder = root / "checks" / task / arm
            folder.mkdir(parents=True)
            mapping = maps["union"] if arm.startswith("isolated-") else maps.get(arm)
            problem = folder / "problem.pddl"
            if arm == official_arm:
                try:
                    physical_projection(root / "checks" / task / "union/problem.pddl",
                                        maps["union"], predicates, problem)
                    PDDLReader().parse_problem(str(domains[arm]), str(problem))
                    transport = {key: {"name": name, "order": order}
                                 for key, (name, order) in official_actions.items()}
                except (ValueError, KeyError, TypeError, IndexError, SyntaxError) as error:
                    entry.update(status="unsupported_official_problem", reason=str(error))
                    continue
            else:
                raw = folder / "mapped.pddl"
                original_terms = map_problem(list(source_args.values()), sid, mapping, raw)
                physical_world(raw, problem)
                transport = {tuple(key.split(":", 1)): value for key, value in mapping["action_maps"].items()}
            steps = []
            for name, *args in source_calls:
                action = transport[(sid, name)]
                steps.append([action["name"], *[original_terms[args[i]] for i in action["order"]]])
            write_plan(folder / "plan.txt", steps)
            entry.update(status="ready", steps=len(steps))

    packet(root, source_args)
    save(root / "scenarios.json", scenarios)
    files = sorted(path for path in root.rglob("*") if path.is_file())
    inputs = {str(path.relative_to(ROOT)): sha(path) for path in pinned_inputs}
    save(root / "protocol.json", {
        "status": "frozen_before_search", "group": GROUP, "specification": spec,
        "official_admission": official_status, "status_scope": "Physical validation on all arms",
        "tasks": entries, "input_sha256": inputs,
        "local_sha256": {str(path.relative_to(root)): sha(path) for path in files},
    })


def run(root):
    protocol_path = root / "protocol.json"
    protocol = read(protocol_path)
    if protocol["status"] != "frozen_before_search":
        raise ValueError("Expected a frozen protocol")
    for base, key in ((ROOT, "input_sha256"), (root, "local_sha256")):
        for file, digest in protocol[key].items():
            if sha(base / file) != digest:
                raise ValueError(f"Frozen input changed: {file}")
    spec = protocol["specification"]
    budget = {key: spec[key] for key in ("max_states", "max_depth", "max_ground_actions", "max_ground_fluents")}
    budget["correlated_parameter_tuples"] = True
    output = root / "execution"
    output.mkdir()
    rows = []
    for task in protocol["tasks"]:
        row = dict(task)
        rows.append(row)
        if task["status"] != "ready":
            continue
        name, arm = task["task"], task["arm"]
        inputs = root / "checks" / name / arm
        target = output / name / arm
        target.mkdir(parents=True)
        domain, problem = root / "models" / f"{arm}.pddl", inputs / "problem.pddl"
        row["domain_sha256"] = sha(domain)
        if task["kind"] == "replay":
            for source, filename in ((domain, "domain.pddl"), (problem, "problem.pddl"),
                                     (inputs / "plan.txt", "plan.txt")):
                (target / filename).write_bytes(source.read_bytes())
            verdict = validate_artifacts(target)
            row.update(status="replayed" if verdict["status"] == "VALID" else verdict["status"].lower(),
                       validation=verdict)
            continue
        parsed = PDDLReader().parse_problem(str(domain), str(problem))
        with SequentialSimulator(parsed) as simulator:
            if simulator.is_goal(simulator.get_initial_state()):
                row.update(status="goal_initially_true")
                continue
        command = [sys.executable, "-m", "rcnc", "plan", "--worker", "--mode", "initial_goal",
                   "--solver", "state_projected", "--domain", str(domain), "--problem", str(problem),
                   "--output", str(target), "--budget", json.dumps(budget)]
        with (target / "worker.log").open("w", encoding="utf-8") as log:
            try:
                subprocess.run(command, cwd=ROOT, stdout=log, stderr=log, timeout=spec["wall_seconds"])
                result = read(target / "search.json") if (target / "search.json").exists() else {"status": "worker_error"}
            except subprocess.TimeoutExpired:
                result = {"status": "wall_time_limit"}
        row["status"] = result["status"]
        if result["status"] == "solved":
            row.update(length=result["length"], validation=result["validation"])
            if arm in ("union", "narrafuse"):
                plan = target / "trace.pddl"
                pddl(plan, ["define", ["plan", name], [":problem", name],
                            [":steps", *calls(target / "plan.txt")]])
                mapping = read(root / "models" / f"{arm}.mapping.json")
                trace = causal_trace_v2(domain, problem, plan, mapping, selected_sources=tuple(SOURCES.values()),
                                        source_count_profile=True)
                save(target / "attribution.json", trace)
                row["cross"] = trace["cross"]["status"]
                row["all_k"] = trace["all_k"]["status"]
        print(name, arm, row["status"], flush=True)
    if any(sha(root / file) != digest for file, digest in protocol["local_sha256"].items()):
        raise ValueError("Frozen local input changed during execution")
    save(root / "report.json", {
        "status": "complete", "protocol_sha256": sha(protocol_path), "model_calls": 0,
        "task_count": len(rows), "status_counts": dict(Counter(row["status"] for row in rows)),
        "rows": rows, "official_admission": protocol["official_admission"],
        "scope": "One known source group and starting-world family, development tasks authored before new search, "
                 "no independent authors or intentional replay. All original reference steps are replayed as saved.",
    })


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    parser.add_argument("--prepare", type=Path)
    args = parser.parse_args()
    if args.prepare:
        prepare(args.prepare.resolve(), args.output.resolve())
    else:
        run(args.output.resolve())

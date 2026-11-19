"""Run all frozen Table 4 goal queries under one fresh, matched budget."""
import argparse
from collections import Counter, defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed
import hashlib
import json
from pathlib import Path
import random
import subprocess
import time

from rcnc.pddl import parse_sexpr, section
from rcnc.saved_plan_validation import replay_saved


def read(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def write(path, value):
    temporary = path.with_suffix(".tmp")
    temporary.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")
    temporary.replace(path)


def check_inputs(hashes):
    for filename, expected in hashes.items():
        if sha(filename) != expected:
            raise ValueError(f"Frozen input changed: {filename}")


def prepare(args):
    archives = {row["id"]: row for row in read(args.anchors)["rows"]}
    by_query = defaultdict(dict)
    files = [args.registry, args.anchors, args.jar, args.java, Path(__file__),
             *Path("rcnc").glob("*.py")]
    hashes = {str(path.resolve()): sha(path) for path in files}
    jar_digest = hashes[str(args.jar.resolve())]
    if jar_digest != "18fe40166ef5ea3bddd58395f5e8739232a1cf6a1b8ec808a9c1e37fd5a94041":
        raise ValueError("Expected the original Table 4 Glaive runtime")
    for row in read(args.registry)["tasks"]:
        old = archives.pop(row["id"])
        if row["status"] != "ready" or any(row[k] != old[k] for k in ("domain", "problem", "mapping")):
            raise ValueError(f"Registry mismatch: {row['id']}")
        key = (row["group"], row["source"], row["world"])
        arm = row["condition"]
        if arm in by_query[key]:
            raise ValueError(f"Duplicate arm: {key}/{arm}")
        task = {key: row[key] for key in ("id", "condition", "domain", "problem")}
        for k in ("domain", "problem"):
            path = task[k]
            digest = old["search"]["input_sha256"][path]
            if hashes.setdefault(path, digest) != digest:
                raise ValueError(f"Inconsistent archived digest: {path}")
        by_query[key][arm] = task
    if archives or len(by_query) != 2400 or any(set(a) != {"union", "full"} for a in by_query.values()):
        raise ValueError("Expected exactly 2,400 registered pairs")
    pairs = [by_query[key] for key in sorted(by_query)]
    random.Random(20261115).shuffle(pairs)
    check_inputs(hashes)
    args.output.mkdir(parents=True)
    write(args.output / "protocol.json", {
        "registered": 4800, "registered_pairs": 2400,
        "search_seconds": 60, "native_replay_seconds": 60, "heap_mb": 4096,
        "workers": args.workers, "pair_shuffle_seed": 20261115,
        "pairs": pairs, "java": str(args.java.resolve()), "jar": str(args.jar.resolve()),
        "input_sha256": hashes,
        "scope": "One fresh search per registered arm and query. A pass requires full native replay and independent state replay, including native axioms and quantified action effects. Counterfactual projections do not count as passes.",
    })


def invoke(spec, task, folder, mode, plan):
    seconds = spec["search_seconds" if mode == "search" else "native_replay_seconds"]
    command = [spec["java"], "-Xmx4096m", "-cp", spec["jar"], "GlaiveOptimized",
               mode, task["domain"], task["problem"], str(plan), str(seconds)]
    write(folder / f"{mode}_command.json", command)
    started = time.monotonic()
    code = None
    log_path = folder / f"{mode}.log"
    with log_path.open("xb") as log_file:
        try:
            code = subprocess.run(command, stdout=log_file, stderr=subprocess.STDOUT,
                                  timeout=seconds, creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0)).returncode
        except subprocess.TimeoutExpired:
            pass
    elapsed = time.monotonic() - started
    log = log_path.read_text(encoding="utf-8", errors="replace")
    phases = [json.loads(line) for line in log.splitlines() if line.startswith('{"phase":')]
    terminal = phases[-1] if phases and phases[-1]["phase"] == "result" else {}
    if code is None:
        status = "wall_time_limit"
    elif "OutOfMemoryError" in log:
        status = "memory_limit"
    elif code == 0 and terminal:
        status = terminal["status"]
    elif "ArithmeticException: integer overflow" in log:
        status = "integer_overflow"
    elif "NonDeterministicException" in log:
        status = "non_ground_intention_error"
    else:
        status = "runtime_error"
    return {**terminal, "status": status, "seconds": elapsed, "returncode": code,
            "last_phase": phases[-1]["phase"] if phases else None}


def run_slot(spec, task, folder):
    folder.mkdir(parents=True, exist_ok=True)
    receipt = folder / "result.json"
    if receipt.is_file():
        result = read(receipt)
        if result["id"] != task["id"]:
            raise ValueError(f"Receipt identity mismatch: {receipt}")
        return result
    attempt = folder / f"attempt_{len(list(folder.glob('attempt_*'))) + 1:02d}"
    attempt.mkdir()
    plan = attempt / "plan.pddl"
    search = invoke(spec, task, attempt, "search", plan)
    result = {**task, "search": search, "attempt": attempt.name, "dual_pass": False}
    if search["status"] == "solved":
        result["plan_sha256"] = sha(plan)
        steps = section(parse_sexpr(plan.read_text(encoding="utf-8")), ":steps")
        if steps is None:
            result["validation_status"] = "missing_steps"
        elif any(step[0] == "non-executed" for step in steps[1:]):
            result["validation_status"] = "unavailable_counterfactual_plan_format"
        else:
            native = invoke(spec, task, attempt, "replay", plan)
            result["native"] = native
            if (native["status"] == "replayed" and native.get("goal") is True
                    and native.get("unexplained_steps") == 0):
                try:
                    physical = replay_saved(Path(task["domain"]), Path(task["problem"]), plan,
                                            native_axioms=True, quantified_action_effects=True)
                except (ValueError, TypeError, KeyError) as error:
                    physical = {"status": "unsupported_or_invalid", "reason": str(error)}
                result["physical"] = {k: physical[k] for k in ("status", "reason", "goal", "steps") if k in physical}
                result["dual_pass"] = (physical["status"] == "replayed" and physical["goal"] is True
                                       and physical["steps"] == native["steps"])
        if sha(plan) != result["plan_sha256"]:
            raise ValueError(f"Plan changed during validation: {plan}")
    write(receipt, result)
    return result


def run(output):
    path = output / "protocol.json"
    spec = read(path)
    protocol_hash = sha(path)
    check_inputs(spec["input_sha256"])
    progress = Counter()

    def run_pair(index, pair):
        folder = output / "runs" / f"{index:04d}"
        order = ("union", "full") if index % 2 == 0 else ("full", "union")
        return {arm: run_slot(spec, pair[arm], folder / arm) for arm in order}

    rows_by_pair = {}
    with ThreadPoolExecutor(max_workers=spec["workers"]) as executor:
        futures = {executor.submit(run_pair, i, pair): i for i, pair in enumerate(spec["pairs"])}
        for future in as_completed(futures):
            i = futures[future]
            pair = future.result()
            rows_by_pair[i] = pair
            for row in pair.values():
                progress[row["condition"]] += int(row["dual_pass"])
            done = len(rows_by_pair)
            if done == 1 or done % 10 == 0 or done == spec["registered_pairs"]:
                snapshot = {"completed_pairs": done, "registered_pairs": spec["registered_pairs"],
                            "dual_pass_so_far": dict(progress)}
                write(output / "progress.json", snapshot)
                print(json.dumps(snapshot), flush=True)
    check_inputs(spec["input_sha256"])
    if sha(path) != protocol_hash:
        raise ValueError("Protocol changed during run")
    pairs = [rows_by_pair[i] for i in range(spec["registered_pairs"])]
    rows = [pair[arm] for pair in pairs for arm in ("union", "full")]
    if len({r["id"] for r in rows}) != spec["registered"]:
        raise ValueError("Incomplete or duplicated rows")
    patterns = Counter(f'{int(p["union"]["dual_pass"])}->{int(p["full"]["dual_pass"])}' for p in pairs)
    search_statuses = {arm: dict(Counter(p[arm]["search"]["status"] for p in pairs)) for arm in ("union", "full")}
    write(output / "report.json", {
        "status": "complete_table4_original_goal_rerun", "registered": len(rows),
        "summary": {"dual_pass": dict(progress), "paired_dual_pass": dict(patterns), "search_statuses": search_statuses},
        "inputs_unchanged": True, "protocol_sha256": protocol_hash, "rows": rows,
    })


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=("prepare", "run"))
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--workers", type=int, default=3)
    for option in ("registry", "anchors", "jar", "java"):
        parser.add_argument("--" + option, type=Path)
    args = parser.parse_args()
    if args.mode == "prepare":
        prepare(args)
    else:
        run(args.output.resolve())


if __name__ == "__main__":
    main()

"""Offline phase/size census for the frozen priority-one diagnostic tasks.

Does not invoke a planner or rewrite any experiment. Binding estimates are
syntactic counts, not measured ground-action or reachable-state counts.
"""
import argparse
from collections import Counter, defaultdict
from functools import lru_cache
import hashlib
import json
from pathlib import Path
import statistics

from rcnc.pddl import parse_sexpr, section, typed_symbols


def read(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def conjuncts(expr):
    if isinstance(expr, list) and expr and expr[0] == "and":
        for part in expr[1:]:
            yield from conjuncts(part)
    else:
        yield expr


def nodes(expr):
    if isinstance(expr, list):
        yield expr
        for part in expr:
            yield from nodes(part)


@lru_cache(maxsize=None)
def dimensions(domain, problem):
    d = parse_sexpr(Path(domain).read_text(encoding="utf-8"))
    p = parse_sexpr(Path(problem).read_text(encoding="utf-8"))
    actions = [x for x in d if isinstance(x, list) and x and x[0] == ":action"]
    axioms = [x for x in d if isinstance(x, list) and x and x[0] == ":axiom"]
    objects = set(typed_symbols((section(d, ":constants") or [None])[1:]))
    objects.update(typed_symbols((section(p, ":objects") or [None])[1:]))
    initial = {tuple(x) for x in (section(p, ":init") or [None])[1:]
               if isinstance(x, list) and all(isinstance(v, str) for v in x)}
    # Over-approximate modified predicates; embedded intention goals and all
    # axiom expressions are also excluded from the static candidate set.
    modified = set()
    for a in actions:
        for x in nodes(a[a.index(":effect") + 1] if ":effect" in a else []):
            if x and isinstance(x[0], str):
                modified.add(x[0])
    for a in axioms:
        for x in nodes(a):
            if x and isinstance(x[0], str):
                modified.add(x[0])
    details = []
    for a in actions:
        params = typed_symbols(a[a.index(":parameters") + 1])
        allowed = {v: set(objects) for v in params}
        pre = a[a.index(":precondition") + 1] if ":precondition" in a else []
        filters = 0
        for atom in conjuncts(pre):
            if not isinstance(atom, list) or len(atom) != 2:
                continue
            pred, variable = atom
            if not isinstance(pred, str) or not isinstance(variable, str):
                continue
            if "_type_" in pred and pred not in modified and variable in allowed:
                allowed[variable].intersection_update(x[1] for x in initial if len(x) == 2 and x[0] == pred)
                filters += 1
        pruned = 1
        for values in allowed.values():
            pruned *= len(values)
        details.append({"name": a[1], "arity": len(params), "all_object": set(params.values()) <= {"object"},
                        "raw_bindings": len(objects) ** len(params), "unary_guard_bindings": pruned,
                        "unary_filters": filters})
    return {"objects": len(objects), "actions": len(actions), "axioms": len(axioms),
            "max_arity": max((a["arity"] for a in details), default=0),
            "all_object": all(a["all_object"] for a in details),
            "raw_bindings": sum(a["raw_bindings"] for a in details),
            "unary_guard_bindings": sum(a["unary_guard_bindings"] for a in details),
            "actions_detail": details}


def phase(log):
    if "Planning with" in log or "Planning in debug" in log:
        return "search_started"
    if "Creating state space" in log:
        return "state_space_done_before_search" if "[State Space:" in log else "creating_state_space"
    if "Reading problem" in log:
        return "reading_problem"
    if "Reading domain" in log:
        return "reading_domain"
    return "no_phase_marker"


def analyze(roots, output):
    output.mkdir(parents=True, exist_ok=False)
    rows, hashes = [], {}
    # Include parent locations because each continuation retains old outcomes.
    log_roots = [*roots, *[p for p in roots[0].parent.glob("priority1_union_full_*2026_11_0*_v1")
                           if (p / "repeat_01/execution").exists()]]
    for root in roots:
        report = root / "repeat_01/composition_report.json"
        hashes[str(report.resolve())] = sha(report)
        for row in read(report)["rows"]:
            if "search" not in row or not row.get("domain") or not row.get("problem"):
                continue
            if not Path(row["problem"]).exists():
                continue
            candidates = []
            for r in log_roots:
                p = r / "repeat_01/execution/composition" / row["id"] / "search"
                if (p / "result.json").exists():
                    result = read(p / "result.json")
                    if result == row["search"]:
                        candidates.append(p / "stdout.txt")
            log_path = candidates[0] if candidates else None
            log = log_path.read_text(encoding="utf-8") if log_path else ""
            if log_path:
                hashes[str(log_path.resolve())] = sha(log_path)
            dims = dimensions(row["domain"], row["problem"])
            rows.append({"campaign": root.name, **{k: row[k] for k in ["id", "group", "cohort", "method", "size", "condition", "domain", "problem"]},
                         "status": row["search"]["status"], "valid": row.get("valid"),
                         "seconds": row["search"].get("seconds"), "phase": phase(log),
                         "log": str(log_path) if log_path else None, "log_tail": log[-500:],
                         "dimensions": {k: v for k, v in dims.items() if k != "actions_detail"}})
    groups = defaultdict(list)
    for row in rows:
        groups[row["campaign"], row["condition"], row["status"]].append(row)
    summaries = []
    for (campaign, condition, status), rr in sorted(groups.items()):
        summaries.append({"campaign": campaign, "condition": condition, "status": status, "n": len(rr),
                          "phases": dict(Counter(r["phase"] for r in rr)),
                          "missing_logs": sum(r["log"] is None for r in rr),
                          "medians": {k: statistics.median(r["dimensions"][k] for r in rr)
                                      for k in ["objects", "actions", "max_arity", "raw_bindings", "unary_guard_bindings"]}})
    result = {"status": "offline_census_complete", "summaries": summaries, "rows": rows,
              "input_sha256": hashes, "new_planner_calls": 0,
              "limits": ["Log marker identifies last reported phase, not an in-phase CPU profile.",
                         "Binding counts describe syntactic candidates; they are not reachable states.",
                         "Unary-guard bound leaves disjunctions and other preconditions unfiltered."]}
    (output / "report.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
    print(json.dumps(summaries, indent=2))


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--root", type=Path, action="append", required=True)
    p.add_argument("--output", type=Path, required=True)
    a = p.parse_args()
    analyze(a.root, a.output)

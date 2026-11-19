"""Audit official UniDomain root lineage and physical exports before any search."""

import argparse
from collections import Counter
from functools import cache
import hashlib
from pathlib import Path

from unified_planning.io import PDDLReader

from scripts.experiments.evaluate_official_unidomain_matched import (
    UnsupportedMapping, lineage, mapped_world, project_model, tree,
)
from scripts.experiments.resume_official_unidomain_batch import receipt
from scripts.experiments.run_matched_unidomain_rule import pddl
from scripts.experiments.run_official_unidomain_batch import ROOT, read, save, sha


def pinned(receipt):
    path = ROOT / receipt["path"]
    if sha(path) != receipt["sha256"]:
        raise ValueError(f"Input changed: {path}")
    return path


@cache
def node_records(path):
    if path.parent.name == "atomic":
        return ()
    details = read(path.with_name("receipt.json"))
    left, right = (Path(details[side]) for side in ("left", "right"))
    identity = hashlib.sha256((sha(left) + sha(right)).encode()).hexdigest()
    checksum = sha(path)
    if (path.parent.name != identity or details["domain_sha256"] != checksum
            or details["decisions_sha256"] != sha(path.with_name("decisions.json"))):
        raise ValueError("Official lineage receipt mismatch")
    record = {"domain": str(path), "left": str(left), "right": str(right), "sha256": checksum}
    return (*node_records(left), *node_records(right), record)


def physical_projection(problem, mapping, predicates, destination):
    mapped_world(problem, mapping, predicates, destination)
    projected = tree(destination)
    # The domain carries the physical requirements. Glaive's problem-level
    # declaration is redundant here after the checked physical projection.
    pddl(destination, [part for part in projected
                       if not isinstance(part, list) or part[:1] != [":requirements"]])


def audit(registry_path, fusion_path, output, *, checkpoint=False):
    frozen = read(fusion_path)
    if not checkpoint and frozen["status"] != "domain_fusion_frozen":
        raise ValueError("Evaluation admission requires a terminal frozen fusion manifest")
    registry = read(registry_path)
    groups = {g["id"]: g for g in registry["groups"]}
    sources = frozen["rows" if checkpoint else "groups"]
    if len(sources) != len(groups) or {g["group"] for g in sources} != set(groups):
        raise ValueError("Fusion and input group registries differ")
    inputs = registry["registered_inputs"]
    anchor = read(pinned(inputs["anchor"]))["tasks"]
    composition = read(pinned(inputs["composition"]))["tasks"]
    originals = {r["group"]: r for r in anchor if r["condition"] == "union" and r.get("problem")}
    diagnostics = {r["group"]: r for r in composition if r["condition"] == "union" and r.get("problem")}
    output.mkdir(parents=True, exist_ok=False)
    results = []
    for entry in sources:
        gid = entry["group"]
        row = {"group": gid, "fusion_status": entry["status"], "status": entry["status"]}
        results.append(row)
        if entry["status"] != "official_root_constructed":
            continue
        root = Path(entry["domain"])
        if sha(root) != entry["sha256"]:
            raise ValueError(f"Root changed: {gid}")
        group = groups[gid]
        union = group["frozen_arms"]["union"]
        try:
            nodes = node_records(root)
            predicates, actions = lineage({"domain": str(root), "nodes": nodes})
            by_source = {}
            for (source, _), (name, _) in predicates.items():
                names = by_source.setdefault(source, set())
                if name in names:
                    raise UnsupportedMapping("Distinct predicates of one source collapse to one symbol")
                names.add(name)
            target = output / gid
            target.mkdir()
            domain = target / "domain.pddl"
            mapping = read(pinned(union["mapping"]))
            project_model(root, predicates, actions, pinned(union["domain"]), mapping, domain)
            row.update(status="projected_physical_model", domain=receipt(domain), root=receipt(root))
            save(target / "lineage.json", {
                "nodes": list(nodes),
                "predicates": [[sid, name, target, order] for (sid, name), (target, order) in predicates.items()],
                "actions": [[sid, name, target, order] for (sid, name), (target, order) in actions.items()],
            })
            row["lineage"] = receipt(target / "lineage.json")
        except (ValueError, KeyError, TypeError, IndexError) as error:
            row.update(status="unsupported_official_export", reason=str(error))
            continue
        probes = {}
        for kind, task in (("original", originals.get(gid)), ("composition", diagnostics.get(gid))):
            if not task:
                probes[kind] = {"status": "no_registered_problem"}
                continue
            path = target / f"{kind}.problem.pddl"
            try:
                physical_projection(task["problem"], mapping, predicates, path)
                PDDLReader().parse_problem(str(domain), str(path))
            except Exception as error:
                probes[kind] = {"status": "projection_or_parser_unsupported", "reason": str(error)}
            else:
                probes[kind] = {"status": "parsed_physical_projection",
                                "original": receipt(Path(task["problem"])), "problem": receipt(path)}
        row["probes"] = probes
    status = "checkpoint_projection_audit" if checkpoint else "terminal_projection_audit"
    counts = dict(Counter(row["status"] for row in results))
    save(output / "report.json", {"status": status, "counts": counts, "rows": results,
                                  "fusion_input": receipt(fusion_path), "registry": receipt(registry_path),
                                  "scope": "Structural lineage and physical parser checks only. "
                                           "No search, replay, semantic validation, or matched denominator."})
    print(status, counts)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("registry", type=Path)
    parser.add_argument("fusion", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--checkpoint", action="store_true")
    args = parser.parse_args()
    audit(args.registry, args.fusion, args.output, checkpoint=args.checkpoint)

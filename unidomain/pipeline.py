"""Reference binary fusion tree execution and artifact validation."""
from __future__ import annotations

import json
from concurrent.futures import Future, ThreadPoolExecutor
from pathlib import Path

from rcnc.pddl import (
    Domain, domain_summary, parse_domain, rewrite_problem, validate_domain,
    validate_problem, write_domain, write_node,
)
from .fusion import FusionRuntime, fuse_pair


def run(
    input_dir: Path,
    output_dir: Path,
    *,
    runtime: FusionRuntime,
    num_workers: int,
) -> Domain:
    paths = sorted(input_dir.glob("*_domainfile.pddl"), key=lambda path: path.name.lower())
    if not paths:
        raise ValueError(f"No domain files found in {input_dir}")

    if output_dir.exists() and any(output_dir.iterdir()):
        raise ValueError('Use an empty output directory; historical fusion artifacts are preserved')
    tree_dir = output_dir / "domain_fusion"
    tree_dir.mkdir(parents=True)

    current: list[tuple[int, Domain]] = []
    mapping: dict[str, int] = {}
    edges: list[dict[str, int]] = []
    for node_id, path in enumerate(paths):
        domain = parse_domain(path)
        current.append((node_id, domain))
        mapping[next(iter(domain.sources))] = node_id
        write_node(domain, tree_dir / str(node_id), leaf=True)

    next_id = len(current)
    with ThreadPoolExecutor(max_workers=num_workers) as executor:
        while len(current) > 1:
            odd_one_out = current[-1] if len(current) % 2 else None
            following = [odd_one_out] if odd_one_out is not None else []
            jobs: list[tuple[int, int, int, Future[Domain]]] = []
            for index in range(0, len(current) - 1, 2):
                left_id, left = current[index]
                right_id, right = current[index + 1]
                node_id = next_id
                next_id += 1
                print(
                    f"Fusing node {left_id} ({len(left.predicates)}p/{len(left.actions)}o) "
                    f"+ {right_id} ({len(right.predicates)}p/{len(right.actions)}o) "
                    f"-> {node_id}",
                    flush=True,
                )
                future = executor.submit(fuse_pair, left, right, runtime)
                jobs.append((node_id, left_id, right_id, future))
            for node_id, left_id, right_id, future in jobs:
                merged = future.result()
                write_node(merged, tree_dir / str(node_id), leaf=False)
                edges.append({"parent": node_id, "left": left_id, "right": right_id})
                following.append((node_id, merged))
            current = following

    root_id, merged = current[0]
    write_domain(merged, output_dir / "meta_domain.pddl")
    summary = domain_summary(merged)
    summary["algorithm"] = {
        "name": "UniDomain Binary Tree Fusion with structural safety guards",
        "constant_identity_policy": "preserve distinct source identities",
        "invalid_proposal_policy": "rollback and retain source variants",
        "predicate_threshold": runtime.predicate_threshold,
        "operator_threshold": runtime.operator_threshold,
        "embedding_model": runtime.embedding_model,
        "llm_provider": "Ollama",
        "node_workers": num_workers,
        "llm_model": runtime.llm.model,
    }
    (output_dir / "meta_domain.json").write_text(
        json.dumps(summary, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    (output_dir / "mapping_table.json").write_text(
        json.dumps(mapping, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    (output_dir / "fusion_tree.json").write_text(
        json.dumps({"root": root_id, "edges": edges}, indent=2) + "\n",
        encoding="utf-8",
    )

    problem_dir = output_dir / "problems"
    for problem in sorted(input_dir.glob("*_problemfile.pddl"), key=lambda path: path.name.lower()):
        rewrite_problem(problem, merged, problem_dir / problem.name)

    errors = validate_domain(merged)
    for problem in problem_dir.glob("*_problemfile.pddl"):
        errors.extend(validate_problem(problem, merged))
        from unified_planning.io import PDDLReader
        try:
            PDDLReader().parse_problem(str(output_dir/'meta_domain.pddl'),str(problem))
        except Exception as exc:
            errors.append(f'{problem.name}: independent parse failed: {exc}')
    validation = {
        "valid": not errors,
        "errors": errors,
        "root_node": root_id,
        **summary["counts"],
        "problem_files": len(list(problem_dir.glob("*_problemfile.pddl"))),
        "llm_network_calls": runtime.llm.network_calls,
        "llm_cache_hits": runtime.llm.cache_hits,
        "llm_duration_seconds": runtime.llm.total_duration_seconds,
        "algorithm": summary["algorithm"],
    }
    (output_dir / "validation.json").write_text(
        json.dumps(validation, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    if errors:
        raise ValueError("strict fusion validation failed: " + "; ".join(errors))
    return merged


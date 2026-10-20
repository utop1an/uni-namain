"""Strict UniDomain binary-tree fusion using all-mpnet-base-v2 and local Ollama.

This adapter follows the official predicate-first/operator-second fusion procedure,
uses the official thresholds and prompt rules, and keeps the local dataset's PDDL
requirements, types, constants, and problem mappings intact.
"""

import argparse
from pathlib import Path

from .fusion import FusionRuntime
from .pipeline import run


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, default=Path("data/narra-domains"))
    parser.add_argument("--output", type=Path, default=Path("data/merged_strict"))
    parser.add_argument("--model", default="gemma3:4b")
    parser.add_argument("--ollama-url", default="http://127.0.0.1:11434")
    parser.add_argument(
        "--embedding-model",
        default="sentence-transformers/all-mpnet-base-v2",
    )
    parser.add_argument("--predicate-threshold", type=float, default=0.3)
    parser.add_argument("--num-workers", type=int, default=4)
    parser.add_argument("--operator-threshold", type=float, default=0.3)
    parser.add_argument(
        "--cache-dir",
        type=Path,
        default=Path(".cache/unidomain_fusion"),
    )
    args = parser.parse_args()
    runtime = FusionRuntime(
        model=args.model,
        base_url=args.ollama_url,
        embedding_model=args.embedding_model,
        predicate_threshold=args.predicate_threshold,
        operator_threshold=args.operator_threshold,
        cache_dir=args.cache_dir,
    )
    merged = run(args.input, args.output, runtime=runtime, num_workers=args.num_workers)
    print(
        f"Strict fusion complete: {len(merged.sources)} domains, "
        f"{len(merged.predicates)} predicates, {len(merged.actions)} operators, "
        f"{runtime.llm.network_calls} Ollama calls.",
        flush=True,
    )


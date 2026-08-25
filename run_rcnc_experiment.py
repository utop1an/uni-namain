"""Run the first deterministic RCNC experiment over narrative PDDL domains."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from rcnc import run_experiment


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, default=Path("data/narra-domains"))
    parser.add_argument("--output", type=Path, default=Path("data/rcnc/experiment_1"))
    parser.add_argument("--story-length", type=int, default=5)
    parser.add_argument("--story-count", type=int, default=10)
    args = parser.parse_args()

    result = run_experiment(
        args.input,
        args.output,
        story_length=args.story_length,
        story_count=args.story_count,
    )
    print(json.dumps(result.summary, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()

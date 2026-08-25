# UniDomain Local Fusion Work Summary and Handoff

Date: 2026-08-21

## Objective and Scope

The project applies the UniDomain fusion method to the 15 local narrative PDDL domain/problem pairs in `data/narra-domains`. The UniDomain paper and official repository are references for the algorithm, execution order, and prompts only; no official UniDomain source domains are included in the fusion input.

## Implemented Workflows

- `unidomain_ollama_fusion.py` is the strict reproduction path. It uses `sentence-transformers/all-mpnet-base-v2` for candidate ranking at a `0.3` threshold and a local Ollama LLM for predicate and action merge decisions.
- The binary-tree fusion order, predicate-before-action processing, candidate similarity order, odd-node handling, and three fusion prompts were aligned with the official implementation. Tests verify normalized prompt fingerprints and the main ordering rules.
- Because the local PDDL input has no UniDomain-style natural-language predicate descriptions, descriptions are derived from declarations and action usage. Ollama JSON-schema output is a provider-level adaptation.
- `merge_domains.py` is a deterministic, dataset-specific offline fallback. It is not a strict reproduction of the paper method.

## Current Artifact and Validation

The checked-in `data/merged_strict` snapshot passes structural validation:

- root fusion node: 28
- source problem files rewritten: 15
- final predicates: 198
- final actions: 221
- Ollama model recorded in the artifact: `gemma3:4b`
- LLM network calls/cache hits: 8,709/7,952

The test command is:

```powershell
python -m unittest discover -s tests -v
```

The latest verified run completed all seven tests successfully. Structural validation confirms parsable PDDL and valid rewritten references; it does not establish that every LLM-approved merge is semantically correct.

Important: the checked-in merged snapshot was generated before the latest official-alignment fixes. Regenerate `data/merged_strict` before using it as the current strict-reproduction result.

## Result Diagnostics

The current snapshot reduces 236 source predicate declarations to 198 final predicates and 234 source action declarations to 221 final actions. Provenance identifies 13 final predicates and 12 final actions as products of merging, representing 6.6% and 5.4% of the respective final symbol sets.

The detailed provenance analysis is in [Domain Fusion Result Diagnostics](2026-08-18-domain-fusion-diagnostics.md). Its main findings are:

- Generic location concepts remain under-merged across `at`, `entity_at`, `located`, `at_item`, `item_at`, and `on`.
- Some apparent duplication already exists inside source domains. For example, `JACK_NP` contains both `at_item` and `on` with the same argument signature.
- The same original name can reach different final symbols: `JACK_NP:at_item` remains `at_item`, while `PUSS:at_item` and `SNOW:at_item` merge into `item_at`. This indicates order sensitivity in pairwise greedy fusion.
- `inside` is an over-merge because entity-location and entity-item relations are combined.
- Several action merge groups are semantically questionable, so structural merge counts must not be interpreted as counts of correct semantic reuse.

## Recommended Next Steps

1. Regenerate the strict result with the aligned workflow and record the exact Ollama model and runtime settings.
2. Recompute all summary statistics from provenance maps after regeneration.
3. Compare the regenerated merge groups with the current diagnostic cases.
4. For narrative domains, evaluate global predicate clustering plus argument-role/type constraints and semantic validation to reduce both under-merging and over-merging.

## Repository State

The repository was initialized on `main` and published at <https://github.com/utop1an/uni-namain>. The initial implementation commit is `7a59c2f`.

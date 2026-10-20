# Project map

Read the [README](../README.md), then follow one path below. The `rcnc` package
name predates the current pipeline. It now contains the active workflow and
shared regression components; historical experiment modules live in `archive/rcnc/`.

## Current request path

```text
run_narrative_pipeline.py       command-line entry only
  rcnc/pipeline_cli.py         argument parsing and request/worker mode selection
    rcnc/narrative_pipeline.py request contract, problem mapping, orchestration
    rcnc/planning_worker.py    isolated solver dispatch and search report handling

Shared compilation and search:
  rcnc/pddl.py                 PDDL syntax, models and export
  rcnc/pddl_checks.py          structural checks and safe renaming
  rcnc/domain_catalog.py       domain catalog and dependency selection
  rcnc/domain_union.py         source-preserving namespaced domain
  rcnc/aligned_domain.py       explicit alignment and membership encoding
  rcnc/merged_planning.py      bounded initial+goal search
  rcnc/outcome_planning.py     bounded initial-only exploration
  rcnc/heuristic_planning.py   optional Pyperplan adapter
  rcnc/validation.py           independent exported-plan validation
```

Start with `run()` in `rcnc/narrative_pipeline.py`. The merged artifact and its
mappings are constructed before search. `rcnc/pddl.py` provides shared PDDL models, parsing, type helpers, export and
structural checks. Parsing preserves source predicate names and identity maps.
The historical alias groups and offline binary merger live in
`archive/domain_merge.py`; `merge_domains.py` is only its compatibility command.
The current pipeline and the Ollama reference adapter import `rcnc.pddl` directly
and do not load historical semantic overrides.

See the [scripts directory guide](../scripts/README.md) for the current layout
and module commands. Only command-line entry points remain at the repository root. Worker dispatch
and structural checks live in `rcnc/`.

Domain construction lives in `rcnc/domain_union.py` and `rcnc/aligned_domain.py`.
`rcnc/domain_building.py` shares declaration checks, output guards, JSON/hash
bookkeeping and independent problem parsing. Union keeps parse failures as report
rows; alignment keeps its strict failure behavior. Namespace, type-membership and
bound-variable transformations remain separate. The two root `build_*.py` files
are CLI wrappers using `rcnc/domain_builder_cli.py`.

## Tools by purpose

| Purpose | Entry points | Where to read more |
| --- | --- | --- |
| Build a reusable domain | `build_narrative_union.py`, `build_aligned_domain.py` | [Domain and alignment commands](commands.md#conservative-merged-domain-baseline) |
| Check preservation | `scripts/audit/audit_union_preservation.py`, `scripts/experiments/run_union_regression.py`, `scripts/experiments/replay_*.py`, `scripts/validation/validate_*.py` | [Command reference](commands.md) |
| Prepare independent labels | `scripts/annotation/prepare_interface_annotations.py`, `scripts/annotation/build_annotation_viewer.py` | [Annotation commands](commands.md#independent-interface-annotation-preparation) |
| Examine machine proposals | `scripts/annotation/run_annotation_predictions.py`, `scripts/annotation/compare_annotation_predictions.py`, `scripts/audit/audit_interface_graph.py` | [Annotation and schema controls](commands.md#independent-interface-annotation-preparation) |
| Run comparison baselines | `scripts/experiments/run_fusion_reference.py`, `scripts/experiments/run_composed_development.py`, `scripts/experiments/run_downward_reference.py` | [Comparison commands](commands.md#fresh-reference-and-matched-development-runs) |
| Verify paper inventory | `scripts/evidence/build_paper_results.py` | [Evidence verification](commands.md#rechecking-development-evidence) |

The wildcard groups above include specialized engineering controls; they are not
steps that every ordinary request must run. No model execution is needed to read
or replay the symbolic workflow.

The local UniDomain comparison adapter has its own
[module guide](../unidomain/README.md). Its existing root command is unchanged.

## Historical approaches and shared dependencies

| Files | Disposition |
| --- | --- |
| `archive/rcnc/run_rcnc_experiment.py`, `archive/rcnc/experiment.py` | Earlier lexical candidate graph; not the current method |
| `archive/rcnc/run_rcnc_planning.py`, `archive/rcnc/run_rcnc_lifting*.py`, `archive/rcnc/lifting.py` | Earlier planning/lifting experiments; post-search exports are not pre-search fusion |
| `scripts/experiments/build_rcnc_frozen.py`, `scripts/experiments/run_rcnc_frozen.py`, `archive/rcnc/protocol.py`, `archive/rcnc/constraints.py` | Frozen authored development protocol and sensitivity controls |
| `archive/rcnc/run_rcnc_interfaces.py`, `archive/rcnc/run_rcnc_semantics.py` | Optional proposal tools; outputs are unverified assumptions |
| `unidomain/`, `unidomain_ollama_fusion.py`, `prompts/domain_fusion/` | Separate model, fusion, pipeline and CLI modules; retained UniDomain-style baseline |
| `archive/rcnc/validate_narrative_pipeline.py` | Historical snapshot audit and smoke fixtures; its shared `bounded_plan` helper now lives in `rcnc/reference_planning.py` |

Commands and interpretation limits are in [historical tools](legacy-tools.md).
Earlier command-line tools are archived under `archive/rcnc/`; run them from
the repository root using `python -m archive.rcnc.<module>`. Historical library modules now live in `archive/rcnc/` too. `rcnc/` retains
the current pipeline, shared validation/grounding helpers and the supported
source-regression reference solver.
`scripts/experiments/build_rcnc_frozen.py` and `scripts/experiments/run_rcnc_frozen.py`
are resolved through the relocation inventory when verifying old frozen paths;
verification still requires their original expected hashes.
See the [archive inventory](../archive/README.md) for the relocation record.

## Data and paper files

| Location | Meaning |
| --- | --- |
| `data/narra-domains/` | Input domain/problem files; upstream provenance may be unknown |
| `data/validation/`, `data/annotation/` | Versioned runs, failures, annotation packets and checks |
| Other `data/` experiment directories | Historical inputs/outputs; inspect their manifests before reuse |
| `paper/claim_evidence.json` | Scientific claims and evidence boundaries |
| `paper/submission_workplan.json` | Submission milestones |
| `paper/result_sources_*.json`, `paper/results_snapshot_*/` | Pinned historical inventories and snapshots |
| `docs/dev-notes/` | Dated results and handoffs |
| `.venv/`, `.cache/`, `.tmp/`, `__pycache__/` | Local environment, caches and temporary files; ignored by Git |

Do not interpret a report's `complete` status as all cases passing. Preserve
failure rows and distinguish original goals, action-invocation probes and generated
outcomes. Historical hashes and measurements refer to their saved implementation,
not a reconstruction with current code.

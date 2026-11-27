# Repository tools

Run Python tools **from the repository root**, using `.venv/Scripts/python.exe -m`.
Use `--help` for the public CLI entry points and a fresh output directory for every run.
Direct execution of files in these subdirectories is not supported.
Some historical preparation scripts use positional arguments or fixed protocol
paths; inspect their source before invoking them. Do not assume `--help` is supported.

The main request runner and domain builders use `python -m rcnc`; the UniDomain
reference uses `python -m unidomain`. Reusable compilation, planning and validation
code lives in `rcnc/`, and dependencies are declared in `pyproject.toml`.
The [project guide](../README.md) links shared-type compilation, planning and paper evidence.

## Find a tool

| Directory | Purpose | Starting points |
| --- | --- | --- |
| `experiments/` | Registered experiment runners, solver adapters and replay workers | `run_causal_multistory`, `run_causal_chains`, `run_revised_multistory`, `run_union_regression` |
| `audit/` | Saved-plan, provenance, mapping and experiment checks | `audit_saved_physical_plans`, `audit_story_opportunities`, `audit_fusion_mapping` |
| `data/` | Source intake, task preparation and protocol freezing | `freeze_revised_multistory`, `snapshot_external_pddl`, `prepare_source_probes` |
| `annotation/` | Blind review packets, model predictions and agreement | `prepare_interface_annotations`, `evaluate_interface_predictions`, `build_annotation_viewer` |
| `evidence/` | Verified result inventories, checkpoints and working-paper tables | `build_paper_results`, `check_submission_checkpoint`, `recheck_frozen_artifacts` |
| `validation/` | Synthetic controls for model and compiler contracts | `validate_transition_preservation`, `validate_type_encoding`, `validate_world_compatibility` |
| `java/` | Glaive inspection and runtime regression helpers | `GlaiveProbe.java`, `GlaiveRuntimeRegression.java` |

List available Python tools with `rg --files scripts -g '*.py'`.
Experiment runners and their corresponding auditors share a topic suffix.
Existing comparison and diagnostic tools remain available for their protocols.
`evidence/build_meeting_results.py` also supplies phase and resource-limit helpers
used by current audits, so it remains here.

The [5 November selection handoff](../docs/dev-notes/2026-11-05-causal-path-domain-selection.md)
records the inputs, budgets and results of that causal-path experiment.

## Common entry points

```powershell
.venv/Scripts/python.exe -m rcnc build-shared --help
.venv/Scripts/python.exe -m rcnc plan-shared --help
.venv/Scripts/python.exe -m scripts.experiments.run_shared_type_rescue --help
.venv/Scripts/python.exe -m scripts.experiments.run_causal_multistory --help
.venv/Scripts/python.exe -m scripts.experiments.run_causal_chains --help
.venv/Scripts/python.exe -m scripts.experiments.run_revised_multistory --help
.venv/Scripts/python.exe -m scripts.experiments.run_union_regression --help
.venv/Scripts/python.exe -m scripts.audit.audit_saved_physical_plans --help
.venv/Scripts/python.exe -m scripts.evidence.build_paper_results --help
```

Commands that call models, download sources or execute planners still require
explicit inputs and budgets. Continuations remain separate conditions.

For offline annotation, start with `scripts/annotation/prepare_interface_annotations.py`.
Only independent labels can support semantic agreement scores.

## Historical tools and path recovery

The [archived experiment entry points](../archive/scripts/README.md#archived-experiment-entry-points)
include the role-identity clarification, explicit-schema preparation, and frozen
timeout-retry continuation. Run them as modules under `archive.scripts.experiments`.

Authored Snow/ACCO/BIRT cases, meeting deliveries and fixed selection follow-ups
are in [archive/scripts](../archive/scripts/README.md). Early frozen RCNC commands
are beside their implementation in `archive/rcnc/`:

```powershell
.venv/Scripts/python.exe -m archive.scripts.experiments.prepare_snow_roles_case --help
.venv/Scripts/python.exe -m archive.rcnc.build_rcnc_frozen --help
.venv/Scripts/python.exe -m archive.rcnc.run_rcnc_frozen --help
```

[relocation.json](relocation.json) maps former paths to current locations, retaining
pre-move hashes. Historical locks and saved commands keep their original paths;
relocation still requires the expected bytes and never excuses code drift.
The [cleanup recovery inventory](../archive/maintenance/2026_11_02_scripts_cleanup_v1/README.md)
preserves exact pre-cleanup files. Inputs, results and frozen evidence stay in place.

One-off Glaive runtime builders and profiling entry points are now in
[archive/scripts/diagnostics](../archive/scripts/diagnostics/README.md).
Their exact bytes and old paths are recorded in `scripts/relocation.json`.

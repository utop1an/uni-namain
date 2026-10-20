# Repository tools

Run tools **from the repository root** using the project Python environment and
`-m`. Direct execution of files inside these subdirectories is not supported.

```powershell
.venv/Scripts/python.exe -m scripts.experiments.run_union_regression --help
.venv/Scripts/python.exe -m scripts.evidence.build_paper_results --help
```

The root retains the request runner, two reusable-domain builders, the UniDomain
adapter and the historical merge command. All five root Python files are CLI
entries; structural checks now live in `rcnc/pddl_checks.py`, and request worker
handling lives in `rcnc/planning_worker.py`. Shared
PDDL parsing/export now lives in `rcnc/pddl.py`; domain construction lives in
`rcnc/domain_union.py` and `rcnc/aligned_domain.py`. Both root builder commands
remain available with the same arguments. Earlier RCNC commands remain
in `archive/rcnc/`. Inputs, historical results and frozen inventories stay in place.

| Directory | Purpose |
| --- | --- |
| `audit/` | Evidence, provenance, mappings, comparisons and diagnostics |
| `validation/` | Synthetic controls and preservation checks |
| `experiments/` | Bounded runners, solver adapters and trace replays |
| `annotation/` | Blind annotation pages, machine predictions and agreement |
| `data/` | Task/probe preparation and external problem packaging |
| `evidence/` | Paper result inventory verification |

[relocation.json](relocation.json) records each original path and its pre-move hash.
New runs record current source paths/hashes. The freezing protocol can locate
relocated implementation files referenced by old locks, but still requires the
original expected bytes; code drift is never accepted as exact reproduction.
Old dated commands in handoffs and saved snapshots describe their original layout.
Use the commands below for new runs and always choose a fresh output directory.

## Commands

### annotation

Offline comparison against two independent annotation files (no model calls):

```powershell
.venv/Scripts/python.exe -m scripts.annotation.evaluate_interface_predictions --packet <packet.json> --annotations <rater-a.json> <rater-b.json> --predictions <run/report.json> --prediction-manifest <run/manifest.json> --output <fresh-report.json>
```

Missing or invalid annotation files cannot produce semantic scores. Exact two-rater
consensus is a descriptive reference, not semantic certification. Missing,
disagreement and uncertain judgments remain coverage categories; model failures
remain in the definite-reference scoring denominator. The existing stratified
development sample does not estimate population prevalence or unseen-family
generalization. New-run design: `paper/evaluation_protocol_2026_10_19_v1.json`;
budgets and test inputs still require a separate execution freeze.

```powershell
.venv/Scripts/python.exe -m scripts.annotation.build_annotation_viewer --help
.venv/Scripts/python.exe -m scripts.annotation.compare_annotation_predictions --help
.venv/Scripts/python.exe -m scripts.annotation.prepare_interface_annotations --help
.venv/Scripts/python.exe -m scripts.annotation.run_annotation_predictions --help
.venv/Scripts/python.exe -m scripts.annotation.summarize_interface_agreement --help
```

### audit

```powershell
.venv/Scripts/python.exe -m scripts.audit.audit_action_reachability --help
.venv/Scripts/python.exe -m scripts.audit.audit_action_removal --help
.venv/Scripts/python.exe -m scripts.audit.audit_composed_development --help
.venv/Scripts/python.exe -m scripts.audit.audit_conditional_prefixes --help
.venv/Scripts/python.exe -m scripts.audit.audit_external_worlds --help
.venv/Scripts/python.exe -m scripts.audit.audit_fusion_mapping --help
.venv/Scripts/python.exe -m scripts.audit.audit_initial_only_development --help
.venv/Scripts/python.exe -m scripts.audit.audit_interface_graph --help
.venv/Scripts/python.exe -m scripts.audit.audit_probe_trace_states --help
.venv/Scripts/python.exe -m scripts.audit.audit_source_provenance --help
.venv/Scripts/python.exe -m scripts.audit.audit_trace_coverage --help
.venv/Scripts/python.exe -m scripts.audit.audit_union_preservation --help
.venv/Scripts/python.exe -m scripts.audit.compare_solver_exports --help
.venv/Scripts/python.exe -m scripts.audit.diagnose_source_support --help
.venv/Scripts/python.exe -m scripts.audit.diagnose_transport_failure --help
.venv/Scripts/python.exe -m scripts.audit.summarize_action_reachability --help
```

### data

```powershell
.venv/Scripts/python.exe -m scripts.data.package_external_problem --help
.venv/Scripts/python.exe -m scripts.data.prepare_action_reachability --help
.venv/Scripts/python.exe -m scripts.data.prepare_action_removal --help
.venv/Scripts/python.exe -m scripts.data.prepare_source_probes --help
```

### evidence

```powershell
.venv/Scripts/python.exe -m scripts.evidence.build_paper_results --help
```

### experiments

```powershell
.venv/Scripts/python.exe -m scripts.experiments.build_rcnc_frozen --help
.venv/Scripts/python.exe -m scripts.experiments.probe_fusion_source_plans --help
.venv/Scripts/python.exe -m scripts.experiments.replay_action_reachability --help
.venv/Scripts/python.exe -m scripts.experiments.replay_downward_preservation --help
.venv/Scripts/python.exe -m scripts.experiments.replay_external_problems --help
.venv/Scripts/python.exe -m scripts.experiments.replay_source_probes --help
.venv/Scripts/python.exe -m scripts.experiments.run_composed_development --help
.venv/Scripts/python.exe -m scripts.experiments.run_downward_reference --help
.venv/Scripts/python.exe -m scripts.experiments.run_fusion_reference --help
.venv/Scripts/python.exe -m scripts.experiments.run_initial_only_development --help
.venv/Scripts/python.exe -m scripts.experiments.run_rcnc_frozen --help
.venv/Scripts/python.exe -m scripts.experiments.run_union_regression --help
```

### validation

```powershell
.venv/Scripts/python.exe -m scripts.validation.validate_capture_states --help
.venv/Scripts/python.exe -m scripts.validation.validate_formula_boundaries --help
.venv/Scripts/python.exe -m scripts.validation.validate_formula_mutation --help
.venv/Scripts/python.exe -m scripts.validation.validate_pipeline_modes --help
.venv/Scripts/python.exe -m scripts.validation.validate_prediction_schemas --help
.venv/Scripts/python.exe -m scripts.validation.validate_semantic_negative_control --help
.venv/Scripts/python.exe -m scripts.validation.validate_sparse_outcomes --help
.venv/Scripts/python.exe -m scripts.validation.validate_transition_mutations --help
.venv/Scripts/python.exe -m scripts.validation.validate_transition_preservation --help
.venv/Scripts/python.exe -m scripts.validation.validate_type_encoding --help
```

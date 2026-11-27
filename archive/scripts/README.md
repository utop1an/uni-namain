# Archived case-study and meeting tools

These tools implement authored cases and fixed follow-ups from earlier development
work. Current experiment runners and shared utilities stay in [scripts](../../scripts/README.md).
Run archived commands explicitly from the repository root; arguments are unchanged:

```powershell
.venv/Scripts/python.exe -m archive.scripts.experiments.prepare_snow_roles_case --help
.venv/Scripts/python.exe -m archive.scripts.audit.audit_snow_roles_case --help
.venv/Scripts/python.exe -m archive.scripts.evidence.render_snow_roles_case --help
```

## Tool groups

| Group | Tools |
| --- | --- |
| Authored ACCO/BIRT case | `experiments/prepare_acco_birt_case.py`, `audit/audit_acco_birt_case.py`, `evidence/render_acco_birt_case.py` |
| Authored Snow shared-role case | `experiments/prepare_snow_roles_case.py`, `audit/audit_snow_roles_case.py`, `evidence/render_snow_roles_case.py` |
| Authored Snow long case | `experiments/prepare_snow_long_case.py`, `audit/audit_snow_long_case.py`, `evidence/build_snow_long_delivery.py`, `evidence/render_snow_long_case.py` |
| Meeting comparison and follow-ups | `experiments/run_meeting_comparison.py`, `experiments/prepare_meeting_selection.py`, `experiments/run_meeting_followups.py`, `experiments/replay_meeting_original_goals.py` |
| Fixed selection comparisons | `experiments/prepare_composed_selection.py`, `experiments/prepare_component_action_selection.py`, `experiments/prepare_world_selection.py`, `experiments/replay_world_selected_goals.py` |
| Selection results and meeting PDFs | `evidence/build_composed_selection_results.py`, `evidence/build_selection_results.py`, `evidence/render_meeting_brief.py`, `evidence/render_selection_brief.py` |
| Fixed historical diagnostics | `audit/audit_conditional_prefixes.py`, `audit/recheck_component_admission.py` |
| Repeat-01 paper tables and assessment | `evidence/render_revised_repeat_paper.py` |
| October five-case translator profiling | `diagnostics/run_translation_diagnostics.py` |

PDF rendering needs ReportLab and the project's Unified Planning dependencies.
The cleanup checks use the project Python with the bundled document packages
added for that process only; no packages or persistent settings are changed.
Current audits still use
`scripts/evidence/build_meeting_results.py`, so that shared module remains active.
The older frozen RCNC builders/runners live in `archive/rcnc/`, with their protocol.

## Archived experiment entry points

The following commands moved on 2026-11-27. From the repository root, use
`python -m archive.scripts.experiments.<module> --help` for their arguments.

| Module | Original use |
| --- | --- |
| [prepare_role_identity_followup](experiments/prepare_role_identity_followup.py) | Prepare the October role-identity clarification against the saved parent experiment. |
| [prepare_explicit_semantic_contract](experiments/prepare_explicit_semantic_contract.py) | Add an explicit JSON output schema to the fixed semantic-facets experiment. |
| [resume_frozen_timeout_retry](experiments/resume_frozen_timeout_retry.py) | Resume the November timeout retry from its registered checkpoint. |

The [path inventory](../../scripts/relocation.json) records the working-copy hash
at relocation. For the exact implementation used by an earlier experiment, use
that experiment's frozen snapshot and recorded hash.

## Reproduction boundaries

The November 2 cleanup moved 24 scripts from the same subdirectory under `scripts/`.
Only the meeting follow-up import changed within these moved scripts. New runs use
the module paths above and fresh output folders. Historical data, failed rows,
protocols and saved implementation snapshots have not been rewritten.

[Path mappings](../../scripts/relocation.json) retain original hashes.
[Recovery files](../maintenance/2026_11_02_scripts_cleanup_v1/README.md) contain the exact
pre-cleanup bytes. A relocated source with changed bytes still fails an old frozen
hash check; use the saved implementation for exact historical reproduction.

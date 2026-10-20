# Repository working instructions

## Read first

Read `docs/dev-notes/README.md` and its latest dated handoff, then `docs/research/narrative-domain-fusion-plan.md`. Current submission milestones live in `paper/submission_workplan.json`; dated results are evidence snapshots, not automatically current measurements.

## Research and data contracts

- The primary artifact is a parameterized merged domain produced before planning, with source mappings and provenance. Do not substitute a plan-specific reconstruction.
- Require an explicit initial state. Goal-only requests return `needs_initial_state`; never infer or pool initial facts from source problems. Initial-only outcomes and original-goal solutions are different evaluation units.
- Keep compilation preservation, interface semantic correctness, and narrative quality separate. Parsing, tests, model-output validation and plan success do not supply independent semantic labels.
- Preserve original worlds and all failure/resource-limit rows in comparisons. Freeze inputs, budgets and mappings before search; use fresh versioned output directories and retain historical artifacts.
- Source-local preservation depends on explicit object/type membership, binding-safe substitutions and consistent world embeddings. Independent source regressions do not prove that conflicting source worlds can be combined.
- Cache continuation after an interrupted experiment is a separately labeled condition; never report it as completion within the original fresh-run budget.

## Local workflow

Use `.venv/Scripts/python.exe` and explicit UTF-8 for text. Run relevant checks; the full suite is `.venv/Scripts/python.exe -m unittest discover -s tests -v`. For Windows temporary-file restrictions, use repository `.tmp` as TEMP/TMP.

Evidence inventory verification: `.venv/Scripts/python.exe -m scripts.evidence.build_paper_results --index <versioned-index.json> --output <fresh-directory>`. Inspect report status, hashes and denominators before quoting results. Do not overwrite uncommitted or untracked research outputs.

## Documentation

Keep stable rules here, dated outcomes in `docs/dev-notes/`, and scientific claims/limits in `paper/claim_evidence.json`. Update documentation when requested; do not turn historical test counts into permanent correctness claims.

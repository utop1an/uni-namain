# Narrative planning domain fusion

Select and merge narrative planning domains into a **parameterized domain before
planning**, retaining source mappings and provenance. Requests supply an explicit
initial state and may supply a goal.

The current baseline supports source-preserving union, explicit alignment
assumptions, domain dependency selection, bounded planning and plan validation.
Automatic semantic alignment, independent semantic evaluation and narrative
ranking remain unfinished. The ICAPS 2027 manuscript is a working draft.

## Start here

- [Project map](docs/project-map.md): code to read and which tools are historical.
- [Scripts by purpose](scripts/README.md): audit, validation, experiments and annotation.
- [Commands](docs/commands.md): alignment, annotation, checks and experiment runners.
- [Research contract](docs/research/narrative-domain-fusion-plan.md): objective and evaluation boundaries.
- [Latest research handoff](docs/dev-notes/2026-10-15-icaps-submission-progress.md): dated evidence and open gaps.
- [Submission milestones](paper/submission_workplan.json) and [claim evidence](paper/claim_evidence.json).

## Run the baseline

From the repository root, install the symbolic planning dependencies:

```powershell
.venv/Scripts/python.exe -m pip install -r requirements-planning.txt
.venv/Scripts/python.exe run_narrative_pipeline.py --query path/to/query.json --output data/my_pipeline_run
```

The project expects a Python virtual environment at `.venv`. The CLI defaults to
sources in `data/narra-domains`; use `--input` for another source directory.
The query format and a synthetic example are in the
[request reference](docs/commands.md#explicit-requests-against-the-pre-search-union).
Always choose a new output directory.

| Request | Behavior |
| --- | --- |
| Explicit initial state + goal | Search and independently validate a plan |
| Explicit initial state only | Generate bounded reachable outcomes; no narrative ranking |
| Missing or null initial state | Return `needs_initial_state` before planning |

An explicit empty initial state is distinct from a missing state. Source problem
facts are never pooled into the request world. Shared entity identities and
alignment assumptions must be supplied explicitly.

## Check changes

```powershell
New-Item -ItemType Directory -Force .tmp | Out-Null
$env:TEMP = Join-Path (Get-Location) '.tmp'
$env:TMP = $env:TEMP
.venv/Scripts/python.exe -m unittest discover -s tests -v
```

Tests and plan validation check engineering behavior. They do not establish
interface semantic correctness or narrative quality. To verify a dated evidence
inventory, use `scripts/evidence/build_paper_results.py` with its versioned index and a fresh output
path; see the [reproduction reference](docs/commands.md#rechecking-development-evidence).

Earlier RCNC commands, historical acceptance audits and the UniDomain reference
setup are in [historical and reference tools](docs/legacy-tools.md).

# Archived command-line tools

These earlier RCNC entry points are outside the current request workflow. They
remain available for development diagnostics and historical interpretation.
Run from the repository root with the project environment, for example:

```powershell
.venv/Scripts/python.exe -m archive.rcnc.run_rcnc_planning --help
.venv/Scripts/python.exe -m archive.rcnc.validate_narrative_pipeline --help
```

All ten modules support the same command-line arguments as before. Direct file
execution from this subdirectory is not supported; `-m` keeps repository imports
and root-relative data paths correct. The optional interface/semantic proposal
commands are also here; they can still be used explicitly.

[relocation.json](rcnc/relocation.json) records original paths and pre-move SHA-256
hashes. Imports have since been updated to the explicit `archive.rcnc` library
paths; these current copies are not claimed to match their original hashes. The
historical pipeline audit resolves the repository root from its new location and
uses `rcnc/reference_planning.py` for the shared source-regression solver.

Historical data, reports, code snapshots and frozen manifests are unchanged.
Old saved commands still describe their original layout. For a new diagnostic run,
use the module command above and a fresh output directory. Exact historical
reproduction requires the saved original implementation; relocation is not a claim
that current code matches earlier hashes.

The frozen-experiment commands are now in `scripts/experiments/` as well.
The protocol resolves their old paths through `scripts/relocation.json` and still
checks the original expected hashes. Existing locks are never rewritten and
changed source bytes still fail verification. Only current and shared library code stays in `rcnc/`; eight earlier experiment
modules are now archived with their callers. The active HTML template
is in `templates/`; generated annotation pages are untouched.

## Historical library modules

`experiment`, `planning`, `lifting`, `selection`, `constraints`, `interface_proposals`,
`semantic_proposals` and `protocol` are now imported from `archive.rcnc` explicitly.
[package-relocation.json](rcnc/package-relocation.json) records their pre-move hashes.
The current package no longer exports the old `run_experiment` convenience API;
use `archive.rcnc.experiment.run_experiment` for that diagnostic.

Current type compatibility uses the existing cycle-safe `rcnc.pddl` type
hierarchy. Shared solver artifact preparation and plan validation live in
`rcnc/validation.py`. The `rcnc/reference_planning.py` backend stays available for
source regression and the explicit `--solver legacy` comparison; it is not the
current request planner. Search policies and budget meanings are unchanged.

New frozen bundles include both active and archived library sources. Old locks
resolve moved package paths through the relocation inventory and still compare
their expected hashes. This does not make changed code an exact historical replay.

## Offline semantic merge baseline

`archive/domain_merge.py` contains the old authored location aliases and same-name
binary merge logic. Run it explicitly with `python -m archive.domain_merge`, or
use the existing `python merge_domains.py` compatibility command with the same
arguments. `archive.domain_merge.parse_domain` retains the old semantic-override
switch for baseline use. Ordinary `rcnc.pddl.parse_domain` always parses without
those overrides. The Ollama UniDomain adapter uses this raw parser, preserving its
previous behavior with overrides disabled.

[pddl-relocation.json](pddl-relocation.json) records the split and original source
hash. Current runs hash `rcnc/pddl.py`, and any legacy semantic implementation they
execute, rather than hashing only the root compatibility command. Existing frozen
manifests and implementation snapshots are retained unchanged.

## Remaining root utility and worker migration

Structural checks are in `rcnc/pddl_checks.py`; the former root utility was moved
without changing its bytes. Request command parsing and isolated worker dispatch
live in `rcnc/pipeline_cli.py` and `rcnc/planning_worker.py`. The root request
command and its arguments remain unchanged. Worker errors still save an explicit
error report using the original process-exit convention; the caller reads report
status separately from the process return code.

[entrypoints-relocation.json](../rcnc/entrypoints-relocation.json) records this move.
The freeze verifier can resolve the old structural-check path, but still requires
the lock's original expected hash. Existing locks are never rewritten. Current
request manifests include the CLI, worker and relocated checker source hashes.

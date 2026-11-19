# NarraFuse

NarraFuse compiles narrative planning domains into a reusable, parameterized
domain before search. The compiler records source mappings and provenance.
Planning takes an explicit initial state and an optional goal.

The [domain catalog](data/README.md) links source domains and merged models by
experiment group. For the Arthur, Batman and Little Red example, look up
`human__random__k03__022` in `data/groups.csv`.

## Run with shared semantic types

New composed worlds use `build-shared` and `plan-shared`. Objects have shared
semantic types: for example, `batman - hunter`, with `hunter` a subtype of
`character`. An action taking `?who - character` accepts Batman regardless of
its source. Original preconditions still apply. Source provenance is retained
in the mapping, without per-object source permissions.

The type specification declares a hierarchy, complete source-type
mappings, source hashes and their evidence. Matching names alone do not establish
equivalence: the rescue sources use `thing` with different meanings. Incompatible
multiple types are rejected rather than collapsed to `object`. Problem files
declare canonical object types and explicit facts; source problem facts are never
pooled. Native Glaive export also supports explicitly declared multiple
inheritance; physical planner adapters may support a narrower type fragment.

Using the frozen rescue inputs as an example:

```powershell
$case = 'paper/results/shared_types_2026_11_19_v3/inputs'
.venv/Scripts/python.exe -m rcnc build-shared --sources "$case/sources.json" --types "$case/types.json" --alignments "$case/alignments_with_shared_at.json" --output output/my_shared_domain
.venv/Scripts/python.exe -m rcnc plan-shared --compiled output/my_shared_domain --world "$case/world.json" --output output/my_shared_plan
```

Compilation saves the full parameterized domain and mappings before seeing the
new planning world. `plan-shared` checks physical execution; intentional validity
is a separate check. Global source activation flags remain available for source
ablations, and all sources are active by default. These flags do not distinguish
objects by origin. Quantifiers range over the shared type, which can change
behavior relative to the original source's smaller universe. The source-local
preservation theorem therefore does not apply unconditionally.

See the [shared-type implementation review](paper/results/shared_types_2026_11_19_v3/review.md)
for controls separating type alignment from predicate alignment. Historical
benchmarks retain their recorded source-scoped compilation; their counts are not
results for the new shared-type mode.

## Run the historical baseline

From the repository root on Windows with Python 3.12 installed:

```powershell
py -3.12 -m venv .venv
.venv/Scripts/python.exe -m pip install -e .
.venv/Scripts/python.exe -m rcnc build-union --output output/my_first_union
```

Choose a fresh output directory for each run. The default input is
`data/narra-domains/` in the research layout described below. Use `python -m rcnc --help` to list construction and
planning commands. A planning request takes an explicit initial state. Supply a
goal to search for a solution, or omit the goal to explore reachable outcomes.

The [UniDomain adapter](unidomain/README.md) has its own entry point,
`python -m unidomain`. Optional model and solver dependencies are listed in
[pyproject.toml](pyproject.toml).

## Check changes

In the local research checkout, the full suite and historical experiment
runners use the original problem, benchmark and result paths. Select the
research layout before running them and return to the catalog layout afterward.
Switch only between runs. The original tree is parked in
`archive/research-data-v1/data/` while the catalog is active.

```powershell
./scripts/data/Set-DataLayout.ps1 Research
New-Item -ItemType Directory -Force .tmp | Out-Null
$env:TEMP = (Resolve-Path .tmp).Path
$env:TMP = $env:TEMP
.venv/Scripts/python.exe -m unittest discover -s tests -v
./scripts/data/Set-DataLayout.ps1 Domains
```

See the [script index](scripts/README.md) for experiment and audit entry points.

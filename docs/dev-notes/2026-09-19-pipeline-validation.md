# Corrected pipeline validation (2026-09-19)

## Scope

Validation of current components against `docs/research/narrative-domain-fusion-plan.md`. No production fusion/planning algorithms or historical experiment inputs were changed. Added `validate_narrative_pipeline.py` and isolated validation artifacts. The existing UniDomain snapshot was inspected, not regenerated with fresh embedding/LLM inference; findings about that snapshot do not establish the outcome of a fresh run with current code.

## Results

- Existing complete unit suite: **56 tests passed**.
- Original source domain/problem independent parsing: **15/15 passed** using Unified Planning 1.3.0.
- Historical source-to-merged predicate/constant/action map coverage and target existence: **15/15 passed**.
- Rewriting the source problems using the saved mappings reproduces the historical rewritten problem ASTs: **15/15 matched**.
- Independent parsing of the historical merged domain with its rewritten problems: **0/15 passed**. The shared domain is blocked by duplicate constants `King` and `king`; PDDL names are case-insensitive. There is also a cross-category `house` name collision, a separate tool-compatibility concern.
- Structural auditing found **6 merged actions** with undeclared symbols, wrong predicate arity or argument-type errors, affecting mappings from **10 original actions**. Each of those original actions passed the same source audit. Four additional actions use logic outside the small RCNC STRIPS subset; those are implementation limitations, not classified as malformed source actions.

Examples of structural regressions:

| Merged action | Error |
| --- | --- |
| eat_dragon | Undeclared `?h`; wrong `dead` predicate arity |
| reverse_direction | Undeclared `wood` |
| remove_poisoned_comet | Undeclared `?d` |
| invite | `object` arguments supplied where `entity` is required |
| knock_down_kettle, force_kettle_into_box | `item` argument supplied to `captured` requiring `entity` |

The historical `validation.json` says `valid: true`, but its checker only checks predicate references/domain references. It does not establish correct symbol scopes, arity, typing or case-insensitive name uniqueness. Mapping coverage likewise does not establish that mapped transitions preserve their meaning.

## Independent synthetic wiring test

Two new small narrative-shaped domains, HEAR and WARN, are written by the validation harness. They are engineering fixtures, not upstream-learned data, an independent benchmark, or a test of semantic inference. Their common `rumor_known` relation is deliberately unambiguous.

The harness calls the existing deterministic merger with reviewed semantic overrides disabled. It writes a parameterized merged domain **before any planning**, then solves all cases directly through Unified Planning's simulator with bounded BFS and independently validates the plans. No mocked fusion decisions or planner results are used.

- Both original source problems solve in one step before and after mapping: **four VALID plans**.
- The composed task produces `hear_report(hero) -> warn_village(hero)`: **two steps, VALID**.
- A second problem with a different object uses the same domain: **two steps, VALID**.
- Removing the initial `messenger_present` fact yields **unsolvable**, not an invented initial fact.
- The merged-domain SHA256 remains identical across every case.

This demonstrates reusable parameterized-domain plumbing on a small fixture. It does not validate the real historical fused domain, automatic domain selection, narrative semantic alignment, scalability or narrative quality.

## Task input contract

The existing `run_query` prototype was tested with the solver patched to raise if invoked, so invocation of planning with incomplete inputs cannot be mistaken for a safe rejection:

| Request | Actual result | Interpretation |
| --- | --- | --- |
| goal without initial | `rejected`, reason `'initial'`; solver not called | No silent initial-state synthesis, but missing a clear `needs_initial_state` response/request |
| initial without goal | `rejected`, reason `'goal'`; solver not called | Initial-only outcome generation remains unimplemented |

Thus the corrected end-to-end pipeline is **NOT_READY**. Passing the old test suite and a synthetic wiring test cannot substitute for these missing or failing acceptance checks.

## Reproduction and artifacts

```powershell
.venv/Scripts/python.exe -m unittest discover -s tests -v
.venv/Scripts/python.exe validate_narrative_pipeline.py --output data/validation/my_pipeline_check
```

Use a fresh output directory. The validation command exits 1 when acceptance checks fail; this is an expected failure report, not a crash. The final run is `data/validation/pipeline_2026_09_19_v2/report.json`. An earlier audit and supplementary diagnosis remain in `data/validation/pipeline_2026_09_19/`.

## Next implementation priorities

1. Check case-insensitive identifier collisions, symbol binding, arity and argument types before accepting/writing merged nodes; validate with an independent parser. Avoid changing old snapshots to disguise errors.
2. Implement the conservative, source-preserving merged-domain baseline and source-problem regression specified in M1. Preserve action variants when a proposed merge cannot meet the contract.
3. Expose a clear missing-initial response; implement initial-only reachable-outcome generation separately. Do not infer an initial world for goal-only input.
4. Connect automatic domain selection and narrative-aware fusion after this baseline is executable and auditable.

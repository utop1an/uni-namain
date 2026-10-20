# Commands and reproduction reference

Run commands from the repository root. Use a fresh output path for each run.
For the everyday entry point and installation, see the [README](../README.md).
Earlier RCNC workflows and the UniDomain adapter setup are in
[historical and reference tools](legacy-tools.md).
Dated measurements below are development snapshots, not fresh verification.

## Conservative merged-domain baseline

The first pre-search domain artifact is now available:

```powershell
.venv/Scripts/python.exe build_narrative_union.py --output data/my_preserving_union
```

It preserves every source action under distinct symbol namespaces, without
inferring semantic equivalences. The fresh `data/merged_preserving_v2` domain
retains 234 actions; all 15 mapped problems pass independent parsing. This
baseline does not yet provide cross-source semantic interfaces.

The LLM fusion adapter now rejects invalid structural proposals transactionally
and preserves source variants. Final outputs require independent parsing, and
historical output directories cannot be overwritten. See
[fixes, validation and remaining scope](../docs/dev-notes/2026-09-19-fusion-safety-fixes.md).

### Source-preservation checks

The union now gives each source its own root object type. This preserves the
scope of object-typed parameters and quantifiers when other sources add objects.
A regression fixture demonstrates that leaving the PDDL root shared can
invalidate a valid source plan with a universal precondition.

Run complete schema/problem recovery and bounded source-plan translation checks:

```powershell
.venv/Scripts/python.exe build_narrative_union.py --output data/my_isolated_union
.venv/Scripts/python.exe -m scripts.audit.audit_union_preservation --union data/my_isolated_union --output data/my_schema_audit.json
.venv/Scripts/python.exe -m scripts.experiments.run_union_regression --output data/my_union_regression --seconds 60 --max-states 5000 --max-depth 30
```

The schema audit checks injective mappings, source object scopes, signatures,
complete action expressions, and unchanged source problem facts/goals. It
normalizes equivalent grouped PDDL parameter declarations before comparison.
It does not establish the truth of learned source models or narrative quality.

The plan regression creates one fixed union before searching any source. Each
source search runs with a process time limit; valid source plans are translated
and independently checked in that union. Reports retain every source and
distinguish missing problems, search limits, errors, exhaustive unsolvability,
and validated translations. `status: complete` means the run ended, not that
every source solved or every preservation claim was established.

On Windows environments with restricted system temporary directories, set
`TEMP` and `TMP` to a writable project-local temporary directory before tests.

## Explicit requests against the pre-search union

```powershell
.venv/Scripts/python.exe run_narrative_pipeline.py --query path/to/query.json --output data/my_pipeline_run
.venv/Scripts/python.exe -m scripts.validation.validate_pipeline_modes --output data/my_mode_validation
```

The mode-validation command creates small synthetic HEAR/WARN inputs and
saved query examples. They are engineering fixtures, not an independent benchmark.
An initial+goal request for those fixture domains looks like:

```json
{
  "sources": ["HEAR", "WARN"],
  "objects": {"hero": "HEAR:person"},
  "initial": [["HEAR:messenger_present", "hero"]],
  "goal": {"positive": [["HEAR:rumor_known", "hero"]]},
  "seconds": 60
}
```

Pass the fixture input directory with `--input` when using that example.
Predicates, types and constants use `SOURCE:symbol`; request objects have
explicit types. Equal names across sources do not imply shared identities.
Omitting `sources` selects all domains; providing it selects complete domains,
not individual successful actions. Set `"selection": "goal_dependencies"` for
the deterministic dependency selector described below. Source problems are retained for auditing but their initial facts
are never imported into the request world.

Omit `goal` for initial-only exploration. Its policy returns the first distinct
noninitial states discovered by bounded BFS, with their positive/negative state
changes and independently validated plans. `max_outcomes` defaults to 3.
Returned outcomes are not success against independently specified goals and
are not ranked for narrative quality. A missing or null `initial` returns
`needs_initial_state` before model construction; `initial: []` means an
explicitly empty world. Partial-observation states are explicitly rejected.

The default `typed_cartesian` reference solver supports `max_states`,
`max_depth`, `max_ground_actions` and the process `seconds` limit. Its explicit
grounding path avoids the duplicate static-parameter removal bug observed in
Unified Planning 1.3.0 without changing source actions. Initial-only exploration
also supports `max_ground_fluents` to bound endpoint-difference enumeration.
Initial-only BFS now projects conjunctive positive preconditions against the
current state's complete true-atom index before grounding. Simulation checks
remaining conditions; expanded effect targets update the index, including
deletions and conditional/quantified effects. Differences compare the initial
and resulting true-atom sets. `max_ground_actions` counts unique visited
projected bindings; `max_ground_fluents` counts effect targets on visited
state-changing transitions. These budget counters differ from the older eager
grounding implementation. Existing valid outcomes remain visible at a cutoff.
The persistent authored comparison in
`data/validation/outcome_sparse_2026_10_15_v2/report.json` checks complete changes
and plans against the saved dense implementation. The six same-input real-source
development conditions in `initial_only_development_2026_10_15_v2` return twelve
validated outcomes across four conditions and exhaust the two empty-world
conditions; `comparison_audit.json` checks exact input bytes and complete endpoint
changes. The earlier six timeouts remain in v1. This is development coverage,
not narrative ranking or a controlled runtime speedup.

For goal-directed heuristic search, install optional dependencies and set
`"solver": "pyperplan"` in the query:

```powershell
.venv/Scripts/python.exe -m pip install -r requirements-heuristic-planning.txt
.venv/Scripts/python.exe -m scripts.experiments.run_union_regression --solver pyperplan --output data/my_heuristic_regression --seconds 120
```

This uses greedy best-first search with hFF after explicit UP removal of
quantifiers, conditional effects, disjunction and negative conditions as needed.
Plans are lifted back and validated in the original model. The adapter enforces
only the process time limit for Pyperplan; it rejects query state/depth/grounding
limits that this engine cannot enforce. Pyperplan is a teaching/prototyping
reference, not a state-of-the-art performance baseline.

## Explicit alignment and domain dependency selection

### Meeting experiment reproduction

```powershell
.venv/Scripts/python.exe -m scripts.experiments.run_meeting_comparison --alignment data/validation/candidate_alignment_2026_10_20_v2/alignment.json --output data/my_fresh_matched_run --seconds 20 --memory-mb 4096
.venv/Scripts/python.exe -m scripts.experiments.run_meeting_followups --matched data/my_fresh_matched_run --output data/my_fresh_meeting_followups
.venv/Scripts/python.exe -m scripts.experiments.replay_meeting_original_goals --matched data/my_fresh_matched_run --output data/my_fresh_original_goal_replay
```

The first command freezes 15 original worlds in four representations before any
search. It requires the existing Fast Downward 26.6 Ubuntu WSL installation.
The follow-up keeps selection separate as an exploratory condition, runs only
after the baseline finishes, and re-audits archived source traces with current
code before replaying them in the nonzero-interface model. Historical solver
traces are reused as trace evidence, not counted as new solver calls.

Completed runs are combined by `scripts.evidence.build_meeting_results`, which
rejects partial denominators and changed hashes. The PDF renderer uses the Codex
bundled Python/reportlab runtime, separately from the research environment.

### Offline machine-candidate bridge

```powershell
.venv/Scripts/python.exe -m scripts.annotation.build_candidate_alignment --packet data/annotation/interface_development_2026_10_15_v1/packet.json --predictions data/validation/interface_predictions_gemma_coupled_2026_10_15_v2/report.json --prediction-manifest data/validation/interface_predictions_gemma_coupled_2026_10_15_v2/manifest.json --inputs data/narra-domains --output data/my_fresh_candidate_alignment --infer-role-types --compile
```

This is an explicitly unverified machine-hypothesis condition. Without
`--infer-role-types`, components needing cross-source role-type assumptions are
withheld. With it, aligned argument slots propose those assumptions; neither
equal type names nor a consistent graph verifies semantics. Inconsistent
components are withheld in full. The output includes candidate decisions,
`alignment.json`, the original prediction manifest, domain-only source snapshots,
and optionally `compiled/meta_domain.pddl`. No source problem facts or object
identities are inferred, and no planner runs. The saved alignment can be passed
to the existing builder or request runner. Future planning still requires an
explicit initial world and object memberships.

### External-source admission screening

```powershell
.venv/Scripts/python.exe -m scripts.data.snapshot_sabre_candidates --output data/my_fresh_source_snapshot
.venv/Scripts/python.exe -m scripts.audit.audit_source_candidates --snapshot data/my_fresh_source_snapshot --attribution-report data/validation/external_source_admission_2026_10_15_v1/candidate_files/report/report.tex --output data/my_fresh_source_admission/report.json
```

Only the snapshot command uses the network. It retrieves fixed-commit original
`.lbl/.lbp` files for Aladdin, Bribery, Deerhunter and Secretagent, checks Git blob
hashes and excludes solution files. The audit checks snapshot completeness,
raw compatibility, intention/actor markers and byte overlap against local files.
Byte differences do not establish story independence. These four examples share
an upstream research lineage and are currently not admitted to classical PDDL
evaluation; intention fields must not be silently removed.

### Additional source screening and independent annotation delivery

```powershell
.venv/Scripts/python.exe -m scripts.data.snapshot_external_pddl --selection paper/source_screen_2026_10_20_v1.json --output data/my_fresh_external_snapshot
.venv/Scripts/python.exe -m scripts.audit.admit_external_pddl --snapshot data/my_fresh_external_snapshot --output data/my_fresh_external_admission --allow-header-packaging --allow-parser-name-overlap
.venv/Scripts/python.exe -m scripts.annotation.prepare_external_annotations --admission-reports data/my_fresh_external_admission/report.json --output data/my_fresh_external_annotations
```

The selection is fixed before parsing. Every supplied HRI household/pizza run
is retained in the admission denominator; only run_0 was selected in advance
for annotation. A failed run_0 is never replaced with another successful run.
The separate extension selection is
`paper/source_screen_extension_2026_10_20_v1.json` (Camelot and TextWorld).

Header packaging uses the existing audited adapter and cannot alter actions,
objects, world facts or goals. The optional parser-name diagnostic retries only
name-policy failures in a dedicated UP environment; the original rejection is
retained. Accepted mapped problems must still parse with the normal compiler
configuration. Source bytes remain intact.

Annotation delivery contains two identical blank bundles for independent human
judgments, a provenance-aware HTML page and Chinese instructions. Coordinator
sampling strata and admission outcomes are excluded from the bundles. No person
is contacted and no independent labels are generated. These auxiliary sources
are not evidence of narrative quality or pristine held-out generalization.

### Explicit supplied alignment commands

```powershell
.venv/Scripts/python.exe build_aligned_domain.py --input path/to/sources --alignment path/to/assumptions.json --output data/my_aligned_domain
.venv/Scripts/python.exe run_narrative_pipeline.py --input path/to/sources --query path/to/query.json --alignment path/to/assumptions.json --output data/my_aligned_run
```

Alignment specifications require `version: 1`, `decision_basis`
(`authored_assumption` or `reviewed_annotation`), current source-domain hashes,
`type_groups` with evidence, and `predicate_groups` with evidence and an explicit
argument permutation for each member. An order `[1, 0]` maps source arguments
`(x, y)` to shared arguments `(y, x)`. Missing role-type correspondences, stale
hashes, repeated argument indices, duplicate assignments and within-source
predicate collapses are rejected. Passing these checks is not proof that the
asserted semantic equivalence is correct. No LLM proposal is promoted into an
accepted specification automatically.

The compiler preserves action variants and constant identities. Source types
are represented by static membership predicates that guard parameters and
quantifiers; type facts are derived from declared types and saved separately
from narrative initial facts. This prevents foreign objects from changing the
scope of a source universal condition. A shared request entity is explicit:
`"hero": ["HEAR:person", "TELL:person"]`. Type correspondences alone do not
identify constants or silently assign an object to another source universe.

`selection: "goal_dependencies"` performs an unsigned, predicate-level backward
dependency closure from goal vocabulary, retaining query-referenced sources
and complete asserted predicate groups. It selects whole domains and records
reasons for every selection/exclusion before fusion or search. It is an
over-approximation, not a minimal-subset or reachability guarantee. Initial-only
requests fall back to all domains because no target outcome has been specified.

Tests cover direction-sensitive composition, missing shared membership,
unchanged universal scope, and all-domain versus selected-domain execution.
These are synthetic engineering controls. The real-source type-encoding check
replays available source plans without any predicate merges:

```powershell
.venv/Scripts/python.exe -m scripts.validation.validate_type_encoding --source-run data/my_heuristic_regression --output data/my_type_encoding_check
```

## Independent interface annotation preparation

```powershell
.venv/Scripts/python.exe -m scripts.annotation.prepare_interface_annotations build --output data/my_annotation_packet --per-stratum 24
.venv/Scripts/python.exe -m scripts.annotation.prepare_interface_annotations check --packet data/my_annotation_packet/packet.json --annotations path/to/reviewer_copy.json
.venv/Scripts/python.exe -m scripts.annotation.run_annotation_predictions --packet data/my_annotation_packet/packet.json --output data/my_machine_predictions
.venv/Scripts/python.exe -m scripts.annotation.run_annotation_predictions --packet data/my_annotation_packet/packet.json --output data/my_prediction_replay --replay data/my_machine_predictions
```

The packet reads source domains only. It retains complete action contexts,
including quantifiers and conditional effects, and samples equal-arity pairs
within name/type-spelling strata using a recorded hash ranking. Type spelling
does not establish semantic type correspondence. Different-arity exclusions,
unsampled candidates, source hashes and sampling policy remain in the coordinator
manifest. The annotator-facing packet excludes predictions and solver outcomes.
Current local domains are development material, including newly sampled pairs.

Copy the blank template separately for each reviewer; do not overwrite frozen
packets or adjudicate by replacing original judgments. The labels distinguish
equivalence, permuted equivalence, abstraction, complementary relations,
incompatibility and uncertainty. Completed uncertainty and missing annotations
have different coverage counts. Validation checks hashes, explicit argument
bijections and cited source excerpts; it cannot verify semantic truth or actual
reviewer independence. No annotation is automatically turned into a compiler
alignment. The default packet has 100 selected pairs and zero completed labels.

The optional prediction runner uses an already installed local Ollama model,
rejects cloud-backed models, records every response and keeps failed, invalid
and checked predictions separate. It does not create human annotation files.
Offline replay checks packet, prompt, model and options against the original
run. Machine predictions remain unverified regardless of structural acceptance.

## Finite-state and semantic-negative controls

```powershell
.venv/Scripts/python.exe -m scripts.validation.validate_transition_preservation --output data/my_transition_check
.venv/Scripts/python.exe -m scripts.validation.validate_transition_mutations --original data/my_transition_check --output data/my_mutation_check
.venv/Scripts/python.exe -m scripts.validation.validate_semantic_negative_control --output data/my_semantic_negative
```

These authored controls compare finite-state transitions and detect deliberately
corrupted compiler outputs. The capture/burial counterexample demonstrates that
an incompatible interface can preserve both source plans and produce a valid
composed plan. Neither result estimates real-domain semantic accuracy.

## Fresh reference and matched development runs

```powershell
.venv/Scripts/python.exe -m scripts.experiments.run_fusion_reference --output data/my_fresh_reference --seconds 10800 --workers 1
.venv/Scripts/python.exe -m scripts.experiments.run_composed_development --output data/my_composed_development --seconds 60
```

The fresh reference freezes inputs, adapter code, prompts, dependencies and
local-model identity. It uses cached MPNet weights offline and a new answer
cache. Timeouts and errors preserve partial outputs. This is the existing
hardened local UniDomain adapter, with its recorded deviations, not an unchanged
upstream reproduction. The historical `data/merged_strict` is never overwritten.

The matched development runner freezes 18 conditions before search: three
explicit initial worlds, zero-merge versus authored possession correspondence,
and pair-only/all-domain/dependency selection. Both interface conditions use
the same source-type membership encoding and declared shared entities. Source
problem files are excluded from the bundle. These authored cases preserve
known source-model generality, including BIRT's broad item-possession effect;
they are mechanical comparisons rather than independent narrative judgments.
Report all conditions and cutoffs. Concurrent workloads make wall-clock results
descriptive, not a controlled performance measurement.

## Source-problem support diagnostics

```powershell
.venv/Scripts/python.exe -m scripts.audit.diagnose_source_support --output data/my_source_support_audit
```

This diagnostic over-approximates reachable predicate symbols by ignoring
bindings, negative conditions, universal conditions and effect guards. It can
certify some missing-support or unseeded-cycle obstructions, but a supported
abstract goal is not proof of concrete solvability. It neither adds initial
facts nor repairs actions. A source problem's unreachable goal is not a reason
to discard its reusable domain from a different explicit-world request.

`scripts/experiments/run_downward_reference.py` supports original source problems or, with
`--composed`, the exact exports from a completed matched-world run. It requires
a local Fast Downward 26.6 build and existing Ubuntu WSL, records binary and
input hashes, distinguishes engine exit codes, and validates all returned plans
independently. `scripts/audit/compare_solver_exports.py` checks identical inputs and full
condition counts across the completed solver runs.

## Rechecking development evidence

The measured environment uses Python 3.12.10, Unified Planning 1.3.0,
up-pyperplan 1.1.0, pyperplan 2.1 and jsonschema 4.26.0. Install
`requirements-heuristic-planning.txt` for the symbolic checks. Fusion additionally
requires `requirements-fusion.txt`, local model weights and Ollama; it is not
needed for symbolic replay. Fast Downward experiments require the separately
recorded 26.6 build and Ubuntu WSL. The full environment inventory and commands
are in `paper/reproduction_protocol_2026_10_15.json`.

Use fresh output paths. On Windows, set the temporary directory before tests:

```powershell
New-Item -ItemType Directory -Force .tmp | Out-Null
$env:TEMP = Join-Path (Get-Location) '.tmp'
$env:TMP = $env:TEMP
.venv/Scripts/python.exe -m unittest discover -s tests -v
```

The result inventory verifies pinned report hashes, terminal states and declared
denominators. It does not rerun planners or independently establish each claim.
For current-code finite controls use the commands above under "Finite-state and
semantic-negative controls". For historical results, retain the archived domain,
problem, plan, manifest and implementation snapshots. Rebuilding with current
code is a new experiment, not an exact replay of an earlier compiler version.
In particular, the completed composed and initial-only comparisons predate the
bound-variable capture fix; the v2 type-encoding source/probe replays use the fix.

The source-action necessity experiment can be prepared from a completed matched
run without changing its worlds or interfaces:

```powershell
.venv/Scripts/python.exe -m scripts.data.prepare_action_removal --origin data/my_composed_development --output data/my_action_removal_tasks
.venv/Scripts/python.exe -m scripts.experiments.run_downward_reference --task-bundle data/my_action_removal_tasks --output data/my_action_removal_results
.venv/Scripts/python.exe -m scripts.audit.audit_action_removal --bundle data/my_action_removal_tasks --run data/my_action_removal_results --origin data/my_composed_development --output data/my_action_removal_results/comparison_audit.json
```

`--schema-policy coupled_fields` selects the separately defined machine-output
schema intervention; offline replay must use the same schema policy as its
original run. `scripts/audit/audit_interface_graph.py` checks joint permutation consistency
among structurally checked proposals. It withholds conflicting components and
does not infer type correspondences, approve merges, or create human labels.

## Source action invocation coverage

Freeze all source action schemas before search. Each task preserves the original
world and adds one fresh nullary observer effect to the target action. Its goal
asks whether that action can be invoked; it does not ask whether the original
goal can be solved. Conditional-effect activation is a separate coverage measure.

```powershell
.venv/Scripts/python.exe -m scripts.data.prepare_action_reachability --output data/my_action_probes
.venv/Scripts/python.exe -m scripts.experiments.run_downward_reference --task-bundle data/my_action_probes --output data/my_action_probe_results --seconds 20 --memory-mb 4096
.venv/Scripts/python.exe -m scripts.audit.audit_action_reachability --bundle data/my_action_probes --solved data/my_action_probe_results --output data/my_action_probe_audit
.venv/Scripts/python.exe -m scripts.experiments.replay_action_reachability --bundle data/my_action_probes --solved data/my_action_probe_results --audit data/my_action_probe_audit --compiled data/my_fixed_compiled_model --output data/my_action_probe_replay
```

The audit requires a complete solver report and retains all frozen tasks,
including unsolvable and resource-limited cases. It checks the instrumentation,
freshly validates returned monitor plans, and compares every original ground
source atom at each state of each returned executable prefix. Replay uses the
same source inputs in a previously compiled model, with no observer added to
that model. Inspect `status_counts`/`counts` and `hashes_unchanged`: a report's
`complete` status means processing finished, not that every trace passed.

## Offline independent interface annotation

Build a standalone page from the frozen blind packet, then open `index.html` in a
browser. It embeds only the packet, never predictions, plans or selection strata.
Each annotator should keep a separate private annotation file and avoid consulting
another annotator until the original judgments are frozen.

```powershell
.venv/Scripts/python.exe -m scripts.annotation.build_annotation_viewer --packet data/annotation/interface_development_2026_10_15_v1/packet.json --output data/my_annotation_viewer
.venv/Scripts/python.exe -m scripts.annotation.prepare_interface_annotations check --packet data/annotation/interface_development_2026_10_15_v1/packet.json --annotations data/my_annotations.json
```

The page holds drafts only in memory. Use **生成导出内容**, then download the JSON
or copy its complete text into a `.json` file before leaving. Import only your own
draft. Completing a row checks its label, argument map, explanation and literal
citations; editing it changes it back to unreviewed. The independence declaration
is never preselected. The Python check remains authoritative for structural
acceptance, and cannot verify semantic truth or actual human independence.

The development page at
`data/annotation/interface_viewer_2026_10_15_v2/index.html` has been checked for
navigation, state changes, JSON generation and local draft import. Direct browser
download was not confirmed in the in-app browser; copying the displayed JSON is
the verified fallback. UI test labels are synthetic and are not independent data.

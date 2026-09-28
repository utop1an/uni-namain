# Narrative domain selection and fusion: active development plan

Date: 2026-09-19. This is the active project direction, superseding the method priorities in the 2026-09-05 RCNC handoff. Historical experiments and their results remain unchanged.

## Research objective

Given a collection of narrative planning domains produced by upstream learning methods, select and merge suitable domains so that the resulting planning domain can generate narrative plans under supplied initial states and/or goals.

The input domains are the upstream models to reuse. Improving or relearning them is a separate research question. Record their learner/version/training provenance when supplied; do not invent that provenance for the current local files. Input quality limitations must be reported, but annotating or repairing every source action is not a prerequisite for studying fusion.

The methodological reference is UniDomain's domain-level selection/alignment/fusion pattern. The narrative variant must preserve event consequences, relation direction, entity continuity, and distinguish compatible action variants from genuinely equivalent actions. The project is not defined by a specific story pair, an item-capability ontology, or a particular local LLM.

Primary artifact: a parameterized merged domain, generated before downstream plan search, with source-to-merged predicate/action/constant mappings and a reproducible merge manifest. It must support multiple problems within its declared scope. A plan-specific grounded action subset or PDDL reconstructed after finding one plan is a downstream artifact, not evidence that this primary artifact already exists.

## Target pipeline

```text
Upstream learned narrative domains + provenance
    -> domain catalog and structural audit
    -> task-conditioned domain retrieval/selection (or reusable offline domain groups)
    -> predicate/type/entity alignment proposals with local action context
    -> explicit alignment decisions and compatibility checks
    -> source union + accepted predicate mappings + conservative action fusion
    -> parameterized merged domain + mappings + provenance
    -> problem construction/mapping for the chosen task mode
    -> planning in the merged domain
    -> independent validation + source/task regression checks
    -> comparison/ranking of valid narrative plans
```

Domain selection may be conditioned on the request. All selection/merge decisions for that request must be finalized and saved before running the planner. If a later planner failure motivates a new merge, record a new development version; do not silently revise the previous run. Evaluation must distinguish task-conditioned fusion from reusable offline fusion.

## Task modes and state semantics

| Mode | Supplied information | Behavior | Evaluation boundary |
| --- | --- | --- | --- |
| initial + goal | Objects, explicit initial state, goal | Map the problem into the merged vocabulary and solve | Preserve initial facts and goal meaning; retain unsolvable and budget outcomes |
| initial only | Objects and explicit initial state; optional narrative preferences | Explore reachable nontrivial outcomes under a fixed policy/budget, construct candidate goals or endpoints, then validate and compare plans | These are generated outcomes, not success on independently specified goals; exclude empty/no-change plans by a declared policy |
| goal only | Goal without an initial state | Return a request for the user to supply an initial state; do not run the planner | No inferred, pooled, empty-default or synthetic initial world |

User decision (2026-09-19): initial state is required for planning; goal is optional. A goal-only request must ask the user to supply the initial state. Do not select an initial state from source problems, invent one, or silently interpret a missing field as an empty world. An explicitly supplied empty state is distinct from a missing state and remains subject to the ordinary closed-world planning semantics.

Several supplied initial states are separate planning instances by default; do not union them into one world. If they represent partial observations, represent known/unknown information explicitly. The existing closed-world STRIPS engine only supports complete states within its modeling convention; it must not quietly treat a partial-observation problem as solved.

Goal vocabulary and object names require an explicit mapping into the selected merged model. Type/name similarity alone does not establish object identity. Source-problem initial facts are not automatically pooled across unrelated stories.

## What selection means

Select source domains, not a hand-picked successful action sequence. Build a catalog of predicates, action preconditions/effects, constants, types and source requirements. Use request relevance and potential inter-domain support through candidate interfaces. Record scores, budgets, selected and excluded domains, and the reason for each exclusion.

Compare at least all-domain fusion, selected-domain fusion and source-isolated models. A small deterministic selection baseline should precede a learned ranking method. Do not claim a minimal or optimal subset without an appropriate search or proof. Ground-action pruning remains a planner optimization after domain selection; it cannot substitute for evaluating domain selection.

## Narrative-specific fusion contract

- Keep source namespaces until an explicit mapping has been selected. Equal names are candidate evidence only.
- Distinguish equivalent predicates, predicates related by an argument permutation, broader abstractions, complementary relations and incompatible meanings. These are different merge decisions. The current pairwise module handles only same-order equivalence hypotheses.
- For argument permutations, rewrite every occurrence consistently and verify mappings. Preserve negation, ordered participant roles, static/dynamic usage and event consequences.
- Start with union of source action variants after accepted predicate mappings. Deduplicate only transitions whose equivalence is established under the mapping; do not union unrelated preconditions/effects into a new action.
- Preserve distinct source constants by default. Entity alignment and constant lifting need explicit, reusable rules and provenance. A role may remain stable across a plan; per-step identity changes must not be accidental.
- Do not require all narratives to use a predefined footwear/key/guide vocabulary. Capability constraints may be supplied as explicit world assumptions or examined in separate repair studies. They are not default fusion semantics.
- An abstraction or adapter that intentionally changes the original transition relation is an additional method component. Represent its preconditions/effects and evidence explicitly, and evaluate it separately from equivalence fusion.
- Do not infer that all learned action models are trustworthy because their PDDL parses. Separate unsupported syntax, source-model uncertainty, merge uncertainty and planning resource limits.

LLM proposals are optional assistance to alignment. They must not rewrite a domain merely because a particular goal would otherwise fail. Structural validation and quoted evidence are not semantic correctness labels. Full manual source annotation is not required to run the pipeline; a small independent evaluation set is needed to measure semantic claims.

## Current components and disposition

| Component | Actual current behavior | Role after correction |
| --- | --- | --- |
| unidomain_ollama_fusion.py | Existing predicate-first/operator-second binary-tree fusion; local provider adaptation | Separate UniDomain-style reference implementation/baseline; retain its original behavior |
| merge_domains.py | Parser/export helpers plus dataset-specific offline semantic groups | Reuse parser/export helpers with reviewed semantic overrides disabled; offline semantic groups remain a labeled fallback |
| rcnc/interface_proposals.py | Budgeted pairwise interface judgments from action context | Alignment candidate subsystem; not the main method and not a trusted registry |
| rcnc/semantic_proposals.py | Parameter/interface/role hypotheses | Optional proposal subsystem; do not automatically apply constraints |
| rcnc/planning.py, selection.py | Explicit-query grounding, signed relevance pruning and bounded BFS | Execution/reference planner infrastructure; its source eligibility filtering is not the new domain-selection algorithm |
| rcnc/lifting.py | Enumerates declared role assignments, then exports parameterized PDDL after solving | Controlled transformation/reference experiment; not a pre-search merged-domain pipeline |
| rcnc/validation.py | Independent validation of exported plans | Reuse as a required execution check, alongside source/task regression tests |
| parameter_tasks_v1, frozen_protocol_v1 | Authored capabilities and variants of two known task templates | Development/sensitivity diagnostics only; no primary benchmark or automatic promotion to held-out data |
| rcnc/experiment.py | Lexical frame graph and heuristic skeleton ranking | Historical exploration; no default narrative ontology or verified novelty metric |

There is currently no single completed entry point implementing the target pipeline. In particular, narrative-specific automatic domain selection, pre-search merged-domain integration, initial-only outcome generation and goal-only initial-state request handling are not implemented as one end-to-end path. Existing prototype commands must not be relabeled to imply otherwise.

## Revised implementation order and acceptance criteria

### M1: Establish the pre-search domain artifact

Progress (2026-09-19): `build_narrative_union.py` implements the source-preserving namespaced union baseline. All 15 mapped source problems independently parse; small source-plan regression fixtures pass. Broad source-plan solvability/trace regression remains to be established. See [safety fixes](../dev-notes/2026-09-19-fusion-safety-fixes.md).

Build an explicit catalog/manifest of the supplied domain pool. Implement a conservative source-preserving union baseline with namespaced constants/predicates/actions and full reverse mappings. Expose accepted alignment decisions as versioned inputs; default to no unverified merges. Export parameterized domain PDDL before any plan search. Reuse the existing UniDomain runner as a separate comparison, not as an already validated narrative solution.

Acceptance: multiple original problems map into one fixed merged domain and retain documented behavior. When a source plan is available, its translated form validates. A missing source plan is reported as missing evidence, not synthesized into a correctness claim. Unsupported constructs must be recorded or cause explicit rejection, not silently discarded. Check cross-source identity collisions and precondition/effect preservation.

### M2: Domain selection and narrative fusion

Add request-based domain selection and action-context alignment to the M1 path. Compare selecting all domains to selecting a subset. Keep variants by default; add more aggressive action merging only with a separate justification and ablation. Test relation direction and entity continuity beyond same-name relations.

Acceptance: a merged domain and its selection/merge manifest exist before planning; both original and new composition tasks run against it without hand-selecting actions for each successful plan. Report selection coverage, merge decisions, regressions and failures.

### M3: Connect problem modes and the planner

First finish initial+goal planning against the merged domain; then add initial-only reachable-outcome generation. Handle a goal-only request by requesting the missing initial state before any planner invocation. Reuse the existing bounded solver as a reference and evaluate a stronger planner when scale requires it.

Acceptance: mapped initial facts/goal retain declared meaning, complete traces independently validate, and resource cutoffs remain distinct from unsolvability. No goal-only or initial-only mode may be simulated by secretly adding facts to a desired plan.

### M4: Narrative plan comparison

Generate a candidate set of valid plans, then evaluate event progression, entity continuity, cross-source reuse, redundancy and narrative coherence. Cross-source action count and source necessity are diagnostics, not definitions of narrative quality. Goal achievement is not sufficient to claim an interesting narrative. Natural-language realization, if added, follows validated traces and is a separate stage.

Acceptance: fixed ranking criteria and small independent assessments; report the whole candidate/task denominator. Do not hard-code that every good plan must use two domains or have a particular length.

## Evaluation and post-hoc controls

Treat all currently observed BIRT/CHIC_NP/PUSS templates, capabilities and interface pairs as development material. Establish new splits before further tuning, preferably grouping by upstream source domain/story family. Reusing already studied domains with new object names does not create independent-domain evidence.

Report separately: source isolated, namespaced union, UniDomain reference, narrative fusion, selection ablation and any optional semantic repair. Compare algorithms on the same world facts, object assumptions and goals. If problem transformation changes the goal, isolate it from strict same-task comparisons. For a request that originally supplied only a goal, obtain the initial state from the user and then compare methods on that identical state. In initial-only mode compare reachable outcomes, not a contrived success rate on self-selected goals.

Primary evidence concerns whether selection/fusion yields usable merged models and valid, coherent narrative plans while preserving documented source behavior. Compression, structural proposal acceptance, source counts and source-removal necessity are secondary diagnostics.

Freeze source pool, split, task/context generation rules, mappings, model/prompt versions, ranking criteria and implementation dependencies before independent evaluation. Include the parser (merge_domains.py) and relevant runtime configuration in the new manifest. The historical frozen-v1 manifest is retained unchanged and is not retroactively claimed to freeze this new pipeline.

# RCNC Experiment 1: Deterministic Cross-Story Causal Composition

Date: 2026-08-24

## Objective

This experiment tests the first hypothesis of Role-Causal Narrative
Composition (RCNC): unrelated narrative domains can be connected without
semantic-equivalence fusion when constants are treated as substitutable slots
and action effects are matched to preconditions through generalized predicate
frames.

RCNC is implemented as an independent path. It does not use UniDomain's
embeddings, LLM verifier, merge prompts, or binary fusion tree.

## Command

```powershell
python run_rcnc_experiment.py `
  --input data/narra-domains `
  --output data/rcnc/experiment_1 `
  --story-length 5 `
  --story-count 10
```

Run all tests with:

```powershell
python -m unittest discover -s tests -v
```

## Deterministic Pipeline

1. Parse the 15 source narrative PDDL domains without reviewed UniDomain
   semantic merges.
2. Build source-scoped constant profiles and identify fixed constants used in
   actions as lifting candidates.
3. Factor predicates into spatial, possession, status, social,
   communication, relation, attribute, and plot frames.
4. Classify actions into deterministic event families.
5. Construct cross-domain causal edges when an add effect can satisfy a
   precondition under positional argument binding.
6. Mark type changes as explicit role-adapter requirements instead of silently
   treating them as compatible.
7. Search for length-five story skeletons under conservative, creative, and
   surreal policies.

## Results

| Measurement | Result |
| --- | ---: |
| Source domains | 15 |
| Source predicates | 236 |
| Source actions | 234 |
| Source-scoped constant profiles | 347 |
| Fixed-constant action occurrences | 167 |
| Actions with lifting candidates | 79 |
| Unique predicate frame keys | 190 |
| Frame keys shared across sources | 14 |
| Cross-domain causal edges | 4,973 |
| Direct same-type edges | 4,342 |
| Edges requiring type adapters | 631 |
| Producer actions represented in the graph | 99 |
| Consumer actions represented in the graph | 157 |

Each novelty policy generated ten length-five, causally connected skeletons.
The best returned skeletons covered four distinct source stories.

## Hub-Dominance Diagnosis and Correction

The initial search was structurally successful but semantically degenerate:
3,321 edges used the generalized `located-at` frame and 1,509 used the
generalized `possesses` frame. Together they accounted for 4,830 of 4,973
edges, so top paths mostly alternated between location and possession.

The search score was corrected with inverse frame-frequency reward, repeated
connector penalty, event-family diversity, and incremental source diversity.
After correction, the top conservative path used the connector sequence:

```text
dead -> alive -> intact -> dead
```

One representative cross-story skeleton was:

```text
HANS_NP:push_witch_into_oven
  -> SNOW:dwarfs_remove_comb_rescue_snow_white
  -> PIGS_NP:wolf_fails_to_blow_house
  -> JACK_NP:cut_beanstalk
  -> SNOW:dwarfs_prepare_glass_coffin_for_snow_white
```

The edge bindings reinterpret the killed witch as the rescue target, the
revived target as the wolf-role participant, the intact house as the
beanstalk-role object, and the killed giant as the coffin target. This is the
intended form of unusual cross-story reuse: source actions remain distinct,
while their state interfaces and roles are rebound.

Creative and surreal paths additionally use explicit adapters such as
`adapt-type:item->location` for an `inside` relation. Creative mode penalizes
these adaptations; surreal mode rewards them.

## What This Experiment Establishes

- Cross-story composition does not require destructive predicate or action
  fusion.
- Constant lifting is relevant to the dataset: 79 of 234 actions contain at
  least one fixed constant that can become a role-bound slot.
- Generalized status and relation frames provide non-trivial causal bridges in
  addition to generic location and possession predicates.
- Hub-aware search is necessary because generic predicates otherwise dominate
  the composition graph.

## Limitations

- Causal validity is currently checked per adjacent edge, not through one
  global object-binding environment.
- Type adapters are annotations; they are not yet compiled into executable
  transformation or role-change actions.
- The generated output is an abstract story skeleton, not yet a grounded PDDL
  domain/problem pair validated by an external planner.
- Event families and roles are deterministic lexical/structural heuristics and
  require a later semantic audit.
- Novelty modes currently differ mainly through adapter policy; stronger
  role-distance and narrative-function objectives are still needed.

## Next Experiment

Experiment 2 should add global role unification, explicit adapter operators,
backward construction of the initial state, compilation of a selected story
into a small PDDL domain/problem, and planner validation. The main success
criterion should be a complete cross-source plan whose bindings remain
consistent across the full trace.

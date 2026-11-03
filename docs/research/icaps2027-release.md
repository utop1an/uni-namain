# ICAPS research checkpoint: 3 November 2026

The current manuscript and compact evidence describe one completed **interrupted
continuation** of the registered five-repeat learned-domain experiment. Repeat 2
attempted 576 of 4,680 judgments before the cloud monthly quota stopped it;
repeats 3--5 are unstarted. The composition expansion is fresh search on the same
first-repeat domains, not another LLM merge repeat.

## Latest results

- 60 previously admitted GPT-4 revised sources; 300 frozen groups of size 2/3/4.
- Predicate sharing in 120 groups and action merging in 19.
- Full retains all 499 available original-plan checks, repeatedly using 33 plans
  of length 1--20; 401 of 900 slots remain without validated reference plans.
- The generator supports 35 groups and 70 descriptors, with 37 exact-world keys.
  The 420 new searches return 212 validated plans.
- Full confirms 50/70 cross-source plans and leaves 10 origin-unknown. The fixed
  37-world representatives yield 27 confirmed and five unknown. Predicate-only
  confirms 56/70 and 30/37. All comparable verdicts agree.
- Producer-off and identity-split controls each also retain ten origin-unknown
  cases. Zero confirmed links must not be described as proof that all links are
  absent. Automatic confirmed chains have two sources and two steps.
- A separate authored world validates an 11-step, four-source plan with one
  cross-source edge and independent goal branches. Fast Downward supplies the
  physical plan; original-domain Glaive replay passes after a separately recorded
  explicit apology intention is added. Original rules, physical state, goal, and
  plan are unchanged. Earlier timeouts and failed checks remain recorded.

This case is not a four-source causal chain, an independent story-quality result,
or an extra benchmark sample. The 60-domain experiment is retained; choosing only
the 33 validated-reference sources would require a new prospective protocol.

## Compact evidence included in Git

`data/research_release/icaps2027_2026_11_03/` contains necessary source PDDL,
source provenance and hashes, accepted group correspondences, all 2,700 transport
outcomes, all 420 composition outcomes and their returned action sequences,
preselected world representatives, the final long case, and failure summaries.
It deliberately omits request caches, raw service responses, logs, runtime JARs,
compiled Java classes, temporary exports, source archives, and original story
texts. The full immutable local runs are not deleted.

The source PDDL is attributed to Kelly et al., *There and Back Again* (AIIDE 2023),
upstream commit `de333cbc07a2c735942516bf6ef87d55d4b723a2`, variant
`gpt4_revised`. This cohort has already been examined during development.

## Offline verification and reconstruction

Run from the repository root with Python 3.11+ and the packages in
`requirements-research.txt`. These commands make no model or planner requests:

```powershell
python -m scripts.evidence.reproduce_icaps_release verify
python -m scripts.evidence.reproduce_icaps_release rebuild --output .tmp/rebuilt-models
python -m scripts.evidence.reproduce_icaps_release verify --models .tmp/rebuilt-models
```

The rebuild checks all 900 domain files against their original SHA-256 hashes.
The second verification reconstructs the explicit problems and physically
replays all 212 returned composition plans, reproducing their causal verdicts.
Saved Glaive intention results are retained; offline physical replay alone is
not a new intention or semantic validation.

To rerun the case's original intentional validation on Windows/WSL, supply the
corrected Glaive JAR and compiled `GlaiveProbe` class directory:

```powershell
python -m scripts.evidence.reproduce_icaps_release replay-case --runtime path/to/glaive-corrected.jar --classes path/to/classes --output .tmp/case-replay
```

The runtime is not vendored. The original Glaive distribution is in the pinned
upstream repository. `scripts/experiments/build_glaive_runtime_correction.py`
records the two corrections and regression gate: false-disjunction substitution
and empty-type Cartesian-product grounding. Its historical default input path
is documented by `INTAKE`/`JAR` in `run_revised_development.py`; setup that path
before using the historical builder. Compile `scripts/java/GlaiveProbe.java`
against the corrected JAR. The paper records the corrected binary hash.

The historical campaign launchers retain their original frozen local paths and
budgets. The compact release is sufficient for offline result/model verification;
it is not a promise that the cloud campaign or all legacy local runs can be
repeated without their external runtimes and source setup. Do not launch new
model requests just to verify the paper.

## Paper and checks

Main: `paper/icaps2027_method_draft.tex`. Supplement:
`paper/icaps2027_supplement.tex`. Build with PDFLaTeX/BibTeX using
`paper/build_icaps2027.ps1` and a fresh output directory. The official styles and
the vector figure PDFs are source dependencies; compiled manuscript PDFs are
local deliverables and are not committed.

```powershell
python -m unittest tests.test_icaps_release tests.test_revised_composition_expanded tests.test_revised_composition_eval tests.test_four_domain_long_case tests.test_revised_multistory_runner -v
```

Interpretation limits include conditional source-plan availability, overlapping
groups/worlds, origin-ambiguous fused actions, the retained lightbox/bike identity
concern, one completed merge repeat, and no independent semantic/narrative labels.

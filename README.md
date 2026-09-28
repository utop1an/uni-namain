# Narrative planning domain selection and fusion

The project targets ICAPS 2027. Given narrative planning domains learned by
upstream methods, it aims to select and merge suitable domains so that the
resulting model can generate narrative plans from supplied initial states
and/or goals. The methodological reference is UniDomain-style fusion, adapted
to narrative events, participant roles and entity continuity.

The primary output is a **parameterized merged domain produced before planning**,
with source mappings and provenance. Plan-specific grounding and validation
are downstream stages. Source-model repair and capability annotation are
optional, separately evaluated components.

Read the [active development plan](docs/research/narrative-domain-fusion-plan.md)
for the corrected scope, input contracts, milestones and evaluation rules.
It supersedes the development priorities of the older RCNC handoff.

## Target pipeline and current status

```text
Upstream narrative domains
 -> catalog and domain selection
 -> narrative-aware alignment and fusion
 -> merged domain + mappings
 -> initial-state/goal problem construction
 -> planning and independent validation
 -> narrative plan comparison
```

This complete pipeline is not yet implemented as one entry point. Existing
components provide fusion baselines, semantic proposals and planning/validation
infrastructure. A source-preserving pre-search union baseline is now implemented. Semantic
alignment, automatic domain selection and task-mode integration remain next.

| Task mode | Intended behavior | Current status |
| --- | --- | --- |
| Initial state + goal | Plan from unchanged initial facts to the mapped goal | Explicit-query prototype available; merged-domain integration remains |
| Initial state only | Generate reachable nontrivial outcomes and compare valid plans | Not integrated |
| Goal only | Ask the user to supply an initial state before planning | Required input contract; no initial-state synthesis |

Initial state is required for planning; a goal is optional. Missing initial
state must not be interpreted as an explicitly empty state.
Multiple supplied initial states are separate instances by default. Source
problem facts are not automatically pooled, and facts must not be invented to
make a desired plan executable.

## Existing UniDomain reference implementation

The local reference uses the 15 narrative domains and paired problems in
`data/narra-domains`. Record upstream learning provenance when available;
the presence of local files does not itself establish their learning provenance.
UniDomain's paper/repository supply the reference algorithm and prompts, not
additional experiment domains.

```powershell
python -m pip install -r requirements-fusion.txt
ollama pull gemma3:4b
$env:USE_TF='0'
$env:TRANSFORMERS_NO_TF='1'
python unidomain_ollama_fusion.py --input data/narra-domains --output data/merged_strict --model gemma3:4b --num-workers 4
```

This implementation uses all-mpnet-base-v2 candidates at threshold 0.3, local
LLM predicate verification followed by operator merging, and binary-tree fusion.
It retains the original fusion prompts. Predicate descriptions are derived
from local declarations/action usage; JSON-schema responses are a provider
adaptation. It is a reference baseline, not the completed narrative-specific method.

Artifacts include `meta_domain.pddl`, source mappings, rewritten problems,
fusion decisions and validation metadata. Structural validation does not prove
semantic equivalence or preservation of all source behavior. Inspect existing
output provenance before treating an old directory as a current run.

`python merge_domains.py` remains a deterministic offline fallback using
reviewed dataset-specific groups. Those groups must not become the default
semantic rules of the corrected research pipeline. Shared parser/export helpers
can be reused with reviewed semantic overrides disabled.

## Alignment proposal components

For action-context predicate-pair judgments:

```powershell
.venv/Scripts/python.exe run_rcnc_interfaces.py --sources BIRT PUSS --max-pairs 8 --output data/rcnc/my_interface_pairs
```

For free parameter/interface/role hypotheses:

```powershell
.venv/Scripts/python.exe run_rcnc_semantics.py --sources BIRT PUSS --output data/rcnc/my_semantics
```

Both retain evidence and run provenance. Their drafts are unverified and are
not automatically applied to planning. Pairwise `accept` is not a semantic
correctness label. See [pairwise results and false positives](docs/dev-notes/2026-09-19-interface-pair-proposals.md)
and [original proposal module](docs/dev-notes/2026-09-14-automatic-semantic-proposals.md).

## Planning and transformation reference tools

```powershell
.venv/Scripts/python.exe -m pip install -r requirements-planning.txt
.venv/Scripts/python.exe run_rcnc_planning.py --query data/rcnc/queries/source_pool_smoke.json --output data/rcnc/my_source_run
.venv/Scripts/python.exe run_rcnc_lifting.py --query data/rcnc/queries/lifting_smoke.json --output data/rcnc/my_lifting_run
```

Use fresh output directories. These tools provide typed STRIPS grounding,
fixed-initial-state BFS, signed goal-relevance pruning, trace replay and
independent Unified Planning validation. Lifting enumerates declared global
role assignments and exports parameterized PDDL after solving. It does not
constitute the target pre-search domain fusion pipeline.

Their source-action eligibility checks and ground-action pruning are not the
new domain selection algorithm. Author-provided interfaces, bindings and
capabilities remain input assumptions. Independent plan validation verifies
execution in the compiled model, not the truth of these assumptions.

See [selection/validation](docs/dev-notes/2026-09-13-selection-and-validation.md)
and [lifting/source necessity](docs/dev-notes/2026-09-13-constrained-lifting.md).

## Historical development experiments

The following remain useful diagnostics, not the primary benchmark or method:

- [Parameter-constraint sensitivity](docs/dev-notes/2026-09-14-parameter-constraints.md): three authored constraints, including one-sided restriction and a hypothetical multifunction object.
- [Frozen template variants](docs/dev-notes/2026-09-14-frozen-protocol.md): 16 known-source development/prospective variants, with no independent semantic annotations.
- [Annotation protocol](docs/research/annotation-protocol-v1.md): optional semantic-audit protocol; full annotation is not a prerequisite for domain fusion.
- [Candidate-graph experiment](docs/dev-notes/2026-08-24-rcnc-experiment-1.md): heuristic skeletons, not validated plans or a default narrative ontology.
- [Previous handoff](docs/dev-notes/2026-09-05-rcnc-discussion-handoff.md): historical design and corrected validity interpretation.

Preserve these artifacts and negative results. Do not promote already examined
tasks to independent tests, overwrite frozen experiments, or add case-specific
capabilities to manufacture cross-source necessity.

## Verification

```powershell
.venv/Scripts/python.exe -m unittest discover -s tests -v
```

The tests cover component behavior. Passing them does not establish narrative
quality, independent-domain generalization or completion of the target pipeline.

Current acceptance validation is recorded in
[the pipeline validation report](docs/dev-notes/2026-09-19-pipeline-validation.md).
The historical merged snapshot fails independent parsing and contains structural
regressions; it must not be treated as a validated executable fusion result.
A small synthetic pre-search fusion test passes, but the target pipeline remains
incomplete. Reproduce the acceptance audit with:

```powershell
.venv/Scripts/python.exe validate_narrative_pipeline.py --output data/validation/my_pipeline_check
```

A nonzero exit indicates unmet acceptance checks; inspect the saved report.

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
[fixes, validation and remaining scope](docs/dev-notes/2026-09-19-fusion-safety-fixes.md).

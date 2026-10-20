# Historical and reference tools

These commands are retained for reference and reproduction. Start with the
[current workflow](../README.md) for new requests. Historical results and old
acceptance audits describe their original artifacts, not current pipeline status.
The UniDomain adapter is still an active comparison baseline; RCNC planning,
lifting and candidate-graph experiments are earlier approaches.

## Existing UniDomain reference implementation

The local reference uses the 15 narrative domains and paired problems in
`data/narra-domains`. Record upstream learning provenance when available;
the presence of local files does not itself establish their learning provenance.
`scripts/audit/audit_source_provenance.py` records per-file local Git custody and explicit
upstream unknowns. The current audit covers all 30 source files, which match their
first local commit byte-for-byte; it does not attribute them to an upstream paper.
Prospective source admission and independent annotation rules are recorded in
`paper/evaluation_protocol_2026_10_15.json`.
UniDomain's paper/repository supply the reference algorithm and prompts, not
additional experiment domains.

```powershell
python -m pip install -r requirements-fusion.txt
ollama pull gemma3:4b
$env:USE_TF='0'
$env:TRANSFORMERS_NO_TF='1'
python unidomain_ollama_fusion.py --input data/narra-domains --output data/my_fusion_run --model gemma3:4b --num-workers 4
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
.venv/Scripts/python.exe -m archive.rcnc.run_rcnc_interfaces --sources BIRT PUSS --max-pairs 8 --output data/rcnc/my_interface_pairs
```

For free parameter/interface/role hypotheses:

```powershell
.venv/Scripts/python.exe -m archive.rcnc.run_rcnc_semantics --sources BIRT PUSS --output data/rcnc/my_semantics
```

Both retain evidence and run provenance. Their drafts are unverified and are
not automatically applied to planning. Pairwise `accept` is not a semantic
correctness label. See [pairwise results and false positives](../docs/dev-notes/2026-09-19-interface-pair-proposals.md)
and [original proposal module](../docs/dev-notes/2026-09-14-automatic-semantic-proposals.md).

## Planning and transformation reference tools

```powershell
.venv/Scripts/python.exe -m pip install -r requirements-planning.txt
.venv/Scripts/python.exe -m archive.rcnc.run_rcnc_planning --query data/rcnc/queries/source_pool_smoke.json --output data/rcnc/my_source_run
.venv/Scripts/python.exe -m archive.rcnc.run_rcnc_lifting --query data/rcnc/queries/lifting_smoke.json --output data/rcnc/my_lifting_run
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

See [selection/validation](../docs/dev-notes/2026-09-13-selection-and-validation.md)
and [lifting/source necessity](../docs/dev-notes/2026-09-13-constrained-lifting.md).

## Historical development experiments

The following remain useful diagnostics, not the primary benchmark or method:

- [Parameter-constraint sensitivity](../docs/dev-notes/2026-09-14-parameter-constraints.md): three authored constraints, including one-sided restriction and a hypothetical multifunction object.
- [Frozen template variants](../docs/dev-notes/2026-09-14-frozen-protocol.md): 16 known-source development/prospective variants, with no independent semantic annotations.
- [Annotation protocol](../docs/research/annotation-protocol-v1.md): optional semantic-audit protocol; full annotation is not a prerequisite for domain fusion.
- [Candidate-graph experiment](../docs/dev-notes/2026-08-24-rcnc-experiment-1.md): heuristic skeletons, not validated plans or a default narrative ontology.
- [Previous handoff](../docs/dev-notes/2026-09-05-rcnc-discussion-handoff.md): historical design and corrected validity interpretation.

Preserve these artifacts and negative results. Do not promote already examined
tasks to independent tests, overwrite frozen experiments, or add case-specific
capabilities to manufacture cross-source necessity.

## Historical acceptance audit

```powershell
.venv/Scripts/python.exe -m unittest discover -s tests -v
.venv/Scripts/python.exe -m scripts.evidence.build_paper_results --index paper/result_sources_2026_10_15_v6.json --output data/my_evidence_recheck
```

The tests cover component behavior. Passing them does not establish narrative
quality, independent-domain generalization or completion of the target pipeline.

The 2026-09-19 acceptance audit is recorded in
[the pipeline validation report](../docs/dev-notes/2026-09-19-pipeline-validation.md).
The historical merged snapshot fails independent parsing and contains structural
regressions; it must not be treated as a validated executable fusion result.
A small synthetic pre-search fusion test passes, but the target pipeline remains
incomplete. Reproduce the acceptance audit with:

```powershell
.venv/Scripts/python.exe -m archive.rcnc.validate_narrative_pipeline --output data/validation/my_pipeline_check
```

A nonzero exit indicates unmet acceptance checks; inspect the saved report.


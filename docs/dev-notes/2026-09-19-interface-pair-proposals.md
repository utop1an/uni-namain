# Predicate-pair interface proposals (2026-09-19)

## Scope and implementation

`rcnc/interface_proposals.py` adds a task-blind interface path alongside the original free proposal module. `run_rcnc_interfaces.py` is the entry point. It does not change source PDDL, the planning query, the frozen registry, or the parameter/role proposal path.

1. Parse source domains without reviewed semantic overrides. Enumerate distinct cross-source predicate pairs with identical ordered type names. This is a coarse syntactic eligibility filter, not a semantic claim or a proof of compatible type hierarchies.
2. Rank candidates deterministically by equal predicate name, then token Jaccard overlap, then lexical references. Evaluate the first `--max-pairs` (default 12). Save total and omitted counts, all source records/hashes, and the selection policy. There is no goal or planning-result input.
3. For each candidate, gather action usages with argument order, precondition/effect section, polarity and AST-serialized literal. Include the complete relevant action records. Unsupported logical actions are excluded from context with reasons; their logic is never flattened into STRIPS evidence.
4. Send one pair per local Ollama request. The model returns `accept`, `reject`, or `uncertain`, a relation judgment, argument alignment, explanation and citations. Variable renaming is explicitly distinguished from a change in relation direction. Model settings are fixed and saved.
5. In the current version, citation options are generated from actual candidate literals and correlated with action IDs in the response schema. The checker independently verifies quotes, candidate identity, decision consistency and both sides' action evidence for acceptance/rejection. A declaration alone cannot justify acceptance. Uncertainty may have no evidence. Missing usage on one side therefore prevents acceptance/rejection from passing the checker.
6. Save accepted hypotheses in `draft_registry.json`. If accepted pairs overlap on any source predicate, withhold every overlapping pair rather than choose the first or infer transitive equivalence. No draft is applied automatically, and `semantically_verified` remains zero.

The quote check establishes provenance only. It cannot verify that the rationale follows from its quotations. The structured relation/alignment check detects contradictory categorical fields; it is not a natural-language entailment checker. `completed` means processing finished, not that any interface is correct. Invalid judgments, failed calls, semantic rejection and uncertainty have separate counters.

## Commands

```powershell
.venv/Scripts/python.exe run_rcnc_interfaces.py --sources BIRT PUSS --max-pairs 8 --output data/rcnc/my_interface_pairs
.venv/Scripts/python.exe run_rcnc_interfaces.py --sources BIRT PUSS --max-pairs 8 --model llama3.2:latest --output data/rcnc/my_llama_interface_pairs
.venv/Scripts/python.exe run_rcnc_interfaces.py --sources BIRT PUSS --max-pairs 8 --replay-dir data/rcnc/semantic_interface_pairs_v2 --output data/rcnc/my_interface_replay
```

Use empty output directories. The runner requires an installed local model and does not download one. Every pair retains request, raw answer (live calls only), parsed answer and check report. Root artifacts include `candidates.json`, `progress.json`, `report.json` and `draft_registry.json`. Reports retain prompt, source/context manifest, implementation and model provenance. Replay performs no model call, requires an identical rebuilt candidate/context manifest, preserves origin-run metadata, and rechecks saved answers with the current checker. Old v1 context manifests cannot be replayed against the changed v2 literal-context format.

## Development results, not independent semantic evaluation

BIRT/PUSS has 44 type-compatible pairs. Each run below evaluated the same first 8, omitting 36. These are budgeted, name-prioritized development samples, not recall over all pairs.

| Run directory | Model | Checked / evaluated | Checked accept / reject / uncertain | Invalid | Draft pairs | Seconds |
| --- | --- | --- | --- | --- | --- | --- |
| semantic_interface_pairs_v1 | gemma3:4b | 4 / 8 | 0 / 1 / 3 | 4 | 0 | 51.47 |
| semantic_interface_pairs_v2 | gemma3:4b | 6 / 8 | 3 / 1 / 2 | 2 | 3 | 48.84 |
| semantic_interface_pairs_llama32_v1 | llama3.2:latest | 4 / 8 | 4 / 0 / 0 | 4 | 4 | 41.96 |

V1 used free-form quotes. V2 adds position explanations and constrains quotes to source literals. Thus the structural improvement is partly engineered evidence selection; it is not evidence of improved semantic accuracy. V2 full offline replay reproduced all eight decisions and check statuses.

Inspection of V2 identifies concrete limitations:

- `at` / `at` is accepted with entity/location interpretation.
- `door_open` / `gate_open` is accepted as an opening-state abstraction; this remains a modeling hypothesis requiring a scope decision.
- `corridor_reached` / `alive` is incorrectly accepted. The explanation confuses matching unary entity signatures with matching meanings. This is a visible false positive despite genuine citations.
- `has` / `has` explains possession equivalence but chooses rejection; the categorical consistency check rejects that answer.
- `corridor_reached` / `obedient` attempts acceptance without action evidence for `obedient`; the checker rejects it.

These observations are developer inspection, not independent annotations or measured precision. Neither the model's rationale nor a plan validator can establish semantic equivalence. Do not promote the draft to the existing frozen planning experiment. A useful next evaluation needs independent semantic cases, stronger relation reasoning and a separate adoption policy before planning comparisons.

The Llama comparison used exactly the V2 prompt and candidate/context manifest (identical hashes). It attempted to accept all eight pairs; four passed structural checking, including the incorrect `kissed_by` / `rescued_by` equivalence. It accepted `at` / `at` and `has` / `has`, but this does not offset the observed tendency to over-accept. Changing to this other installed small model therefore did not resolve semantic reliability. No winner or semantic accuracy estimate is claimed.

## Verification

56 unit tests passed, including 10 new tests for deterministic candidate selection, budgets, argument/polarity context, direction checks, forged and one-sided evidence, abstention, conflicting pair groups, replay source drift, failed responses, generated citation options and unsupported logic. Actual local inference and complete offline replay were also run. Existing frozen-v1 files were not regenerated; this path needs its own future freeze before formal evaluation.

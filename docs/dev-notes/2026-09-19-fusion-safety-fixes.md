# Fusion safety fixes and conservative union (2026-09-19)

## Changes

- `pddl_checks.py` checks case-insensitive duplicates within symbol categories, type hierarchies, action names/fields, variable binding, predicate arity and argument types. Quantifiers and conditional/logical forms retain their scopes rather than being flattened into STRIPS. This establishes structural well-formedness, not narrative equivalence.
- Both deterministic and LLM fusion paths preserve distinct colliding source constants by renaming them and retaining source mappings. A constant rename changes argument positions only; a same-spelled predicate remains a separate symbol. Problem rewriting follows the same rule.
- LLM predicate updates run on staged copies. Invalid updates are discarded without partially changing either domain. Arity-changing predicate proposals are rejected because the existing problem mapper cannot translate them safely. Unrelated declaration overwrites are rejected.
- Invalid operator proposals (unknown variables/constants, arity/type problems, name disagreements or overwrites) are rejected; source action variants are retained. Declined same-name predicates/actions receive distinct names rather than being silently collapsed.
- Final LLM fusion output must pass independent Unified Planning parsing against rewritten problems. Existing output directories are rejected, not recursively removed. The algorithm metadata now explicitly identifies structural safety guards and source-preserving constant identity. Original prompts/thresholds remain, but this is a hardened adapter, not an unchanged upstream reproduction.
- `run_query` returns `needs_initial_state` before compilation when initial state is missing/null. An explicitly supplied empty list remains different from a missing state.
- New frozen bundles include `merge_domains.py` and `pddl_checks.py`. Old frozen bundles are retained and may reject changed implementation hashes; they must not be retroactively overwritten or called current.

## New baseline

`build_narrative_union.py` builds a conservative merged domain directly from original inputs. Types, constants, predicates and actions receive injective source namespaces. No semantic equivalences, entity identities, capability rules or action unions are inferred. All source actions and their parameterized bodies are retained under symbol translation. Paired problems receive corresponding predicate/constant/type/object mappings; unsupported domain/problem sections are explicitly rejected.

```powershell
.venv/Scripts/python.exe build_narrative_union.py --output data/my_preserving_union
```

The final fresh artifact is `data/merged_preserving_v2/`:

| Measure | Result |
| --- | ---: |
| Source domains | 15 |
| Preserved actions | 234 |
| Preserved predicates | 236 |
| Preserved source constants | 347 |
| Namespaced types | 45 |
| Independently parsed mapped problems | 15/15 |

This is a usable structural baseline for the corrected pipeline, not a repaired semantic-fusion result. Namespaced predicates do not yet communicate across sources; selected narrative alignments are the next layer. The historical `data/merged_strict` remains unchanged and still contains its diagnosed failures. Do not compare its 0/15 parse result to this baseline's 15/15 as an LLM accuracy gain.

## Validation

64 tests passed. New tests cover invalid-operator fallback, predicate-update rollback, case-insensitive identity collisions, preservation of declined same-name variants, quantified source actions, historical error detection, same-spelled predicate/constant problem rewriting, and missing-initial handling. Small original problems validate before and after namespace union with the same plan length. Existing source and fusion tests remain passing.

A separate execution smoke run under `data/validation/fusion_fix_2026_09_19/` confirms that the existing deterministic same-name fixture still produces independently valid plans and does not change the merged domain during planning. Its missing-fact control stays unsolvable. The goal-only check now reports `needs_initial_state` without invoking the planner.

No full live embedding/LLM fusion rerun was performed. LLM rejection paths were tested with controlled invalid proposals; actual 15-source regeneration used the conservative namespace union. Independent parsing of all 15 mapped problems does not prove all original goals are solvable or all narrative semantics are correct.

Initial-only endpoint generation, automatic domain selection, and narrative-specific semantic merging remain implementation milestones; no empty goal is inserted to pretend these features are complete.

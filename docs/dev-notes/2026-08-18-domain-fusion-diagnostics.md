# Domain Fusion Result Diagnostics

Date: 2026-08-18

## Scope

This note summarizes the existing `data/merged_strict` snapshot. The snapshot predates the latest workflow-alignment fixes and should be regenerated before it is treated as the current result.

## Summary Statistics

| Symbol type | Source declarations | Final symbols | Net reduction | Source occurrences in merge groups | Final merge products |
| --- | ---: | ---: | ---: | ---: | ---: |
| Predicates | 236 | 198 | 38 | 51 | 13 |
| Actions | 234 | 221 | 13 | 25 | 12 |

- 185 final predicates and 209 final actions have single-source provenance.
- Merge products account for 6.6% of final predicates and 5.4% of final actions.
- Provenance maps are the authoritative basis for these counts. The predicate decision log contains 37 records rather than the net reduction of 38 because identical branch decisions can be deduplicated.

## Generic Spatial Predicate Provenance

| Final predicate | Source provenance |
| --- | --- |
| `at` | Original `at` predicates from 12 domains |
| `entity_at` | `FOUR_NP` only |
| `located` | `ACCO` only |
| `at_item` | `JACK_NP` only |
| `item_at` | `FOUR_NP:item_at`, plus `PUSS:at_item` and `SNOW:at_item` |
| `on` | `JACK_NP` only |
| `inside` | `BIRT`, `JACK_NP`, and `PIGS_NP` |
| `contained_in` | `ACCO` only |

## Findings

- The result contains both cross-domain under-merging and source-internal overlap. Generic location concepts remain split among `at`, `entity_at`, `located`, `at_item`, `item_at`, and `on`.
- `JACK_NP` already contains `at`, `at_item`, `on`, and `inside`. In particular, `at_item` and `on` have the same argument signature and appear to be a source-level near-duplication.
- The `entity_at`/`item_at` split in `FOUR_NP`, and the `at`/`at_item` splits in `PUSS` and `SNOW`, are more likely intentional typed specializations.
- The original predicate name `at_item` is mapped inconsistently: the `JACK_NP` version remains `at_item`, while the `PUSS` and `SNOW` versions merge with `FOUR_NP:item_at`. This is consistent with order-sensitive, pairwise greedy merging and intermediate renaming.
- `inside` is an over-merge: it combines an entity-location relation from `BIRT` with entity-item relations from `JACK_NP` and `PIGS_NP`.
- Some merged action groups are also semantically questionable. Therefore, the merge counts measure structural consolidation, not necessarily correct semantic reuse.

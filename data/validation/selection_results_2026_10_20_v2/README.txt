ICAPS meeting supplement, 2026-10-21

Fresh comparison: 30 solver calls, 15 original source worlds x 2 selection policies.
Old graph closure: 3 solved, 8 unsolvable, 4 resource limits.
Static source-universe components: 4 solved, 8 unsolvable, 3 resource limits.
All calls use Fast Downward 26.6 lama-first, 20-second wall/CPU configuration,
4096 MB, one worker. WSL launch/response and termination grace are included in
observed elapsed time; these are not strict 20-second Windows elapsed caps.
The earlier 60-call representation comparison is a separate measurement block.

CHIC_NP: 20.094 observed seconds / limit in the control; 1.421 seconds and a
validated 40-step plan under optimized selection. Diagnostic grounding counts:
graph closure 292117, including 291746 HANS_NP actions; selected CHIC_NP 371.
Full-pool CHIC_NP diagnostic 294157 grounded actions, 99.18% HANS_NP.
HANS_NP collect_treasure contributes 124852 bindings. Unused father/mother
parameters in abandon_children_in_forest contribute 49-fold multiplicity.

The 15 original worlds have disjoint source universes: optimized models are
single-source components. This does not demonstrate cross-source narrative fusion.
HANS_NP, MUSI and SNOW remain limited. Independent semantic labels remain zero.
4 available native original-goal plans replay validly: 64 states, 23457 source-
atom comparisons, zero mismatches. All 15 rows are retained. 175 tests passed.

Translation diagnostics are separate instrumented calls. v1: 5 attempts,
4 missing reports and 1 completed; retained and excluded. v2: all 5 sample
reports retained; 4 diagnostic wall limits and CPU-signal process exits during
teardown, 1 completed translation. They are not planning success measurements.

Reproduce with repository .venv/Scripts/python.exe -X utf8 and FRESH output paths:
1. -m scripts.experiments.prepare_world_selection --matched data/validation/meeting_matched_2026_10_20_v1 --previous-selection data/validation/meeting_followups_2026_10_20_v1/selection --output <fresh-selected>
2. -m scripts.experiments.run_downward_reference --inputs data/validation/meeting_matched_2026_10_20_v1/inputs --task-bundle <fresh-selected>/bundle --output <fresh-selected>/solver --seconds 20 --memory-mb 4096
3. -m scripts.experiments.run_translation_diagnostics --matched data/validation/meeting_matched_2026_10_20_v1 --selected <fresh-selected> --output <fresh-diagnostics>
4. -m scripts.experiments.replay_world_selected_goals --matched data/validation/meeting_matched_2026_10_20_v1 --selected <fresh-selected> --output <fresh-replay>
5. -m scripts.evidence.build_selection_results --matched data/validation/meeting_matched_2026_10_20_v1 --selected <fresh-selected> --diagnostics <fresh-diagnostics> --replay <fresh-replay> --output <fresh-results>

Evidence inventory verified with:
-m scripts.evidence.build_paper_results --index paper/result_sources_2026_10_20_selection_v1.json --output <fresh-inventory>

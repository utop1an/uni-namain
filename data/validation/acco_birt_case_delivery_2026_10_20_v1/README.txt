ACCO+BIRT meeting case, 2026-10-21
One authored world and five conditions; not five independent stories.
The first four world/goal PDDL files are byte-identical. Single-source controls
restrict actions while retaining vocabulary, objects and the shared ACCO goal.
The identity control additionally removes BIRT memberships for hero/token.
All source action definitions remain unchanged. There are no independent labels.

Results: one validated 4-step solution; all four controls solver-unsolvable.
Configured budget: 20-second wall/CPU, 4096 MB, one worker, FD 26.6 lama-first.
8.594 seconds is Windows observed elapsed time including WSL launch/response.
No timing improvement claim is made. Source worlds are not pooled.

Reproduce with .venv/Scripts/python.exe -X utf8 and fresh output directories:
1. -m scripts.experiments.prepare_acco_birt_case --output <fresh-case>
2. -m scripts.experiments.run_downward_reference --inputs <fresh-case>/inputs --task-bundle <fresh-case>/bundle --output <fresh-case>/solver --seconds 20 --memory-mb 4096
3. -m scripts.audit.audit_acco_birt_case --case <fresh-case> --output <fresh-audit>
The PDF uses reportlab from the bundled runtime and render_acco_birt_case.
Counterexample witnesses are offline executions, not extra solver calls or labels.

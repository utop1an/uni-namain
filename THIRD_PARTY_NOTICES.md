# Third-party notices

External PDDL admission snapshots are retained with original bytes and pinned
Git blob hashes under `data/validation/external_pddl*_snapshot_2026_10_20_v1/`.
Their manifests preserve public source URLs and commits. The selected providers
are QuestMasterAI, HRI-EU/pddl-domains, aibasel/downward-benchmarks, NL2Plan
(documentation only), Camelot-Wrapper and Microsoft TextWorld. Available
repository README and license files are included in each snapshot. Missing
artifact-specific licensing or generation history is not inferred from a tool's
license or default configuration. The external annotation pilot retains source
URLs and lineage descriptions; auxiliary classical domains are not relabeled
as narrative benchmarks.

The prompt wording under `prompts/domain_fusion/` is adapted from the MIT-licensed
UniDomain project:

- Project: https://github.com/RoboticSJTU/UniDomain
- Copyright: UniDomain contributors
- License: MIT

The local adapter retains the paper's predicate-first, operator-second binary
fusion procedure while preserving PDDL types, constants, and source problem
mappings that are not represented by the upstream JSON intermediate format.

Optional heuristic planning uses Pyperplan 2.1 (GPLv3) through up-pyperplan
1.1.0 (Apache-2.0):

- https://github.com/aibasel/pyperplan
- https://github.com/aiplan4eu/up-pyperplan

The dependencies are installed separately; their source is not vendored here.
Pyperplan is a lightweight teaching/prototyping planner and is not presented as
a state-of-the-art performance baseline. The adapter records compiler versions
and validates lifted plans in the original PDDL model.

Optional reference experiments use Fast Downward 26.6, downloaded from the
official release tarball into an ignored local build directory:

- https://www.fast-downward.org/latest/releases/26.6/
- https://github.com/aibasel/downward
- Copyright 2003-2026 Fast Downward contributors
- License: GNU GPL version 3 or later

Planner source and binaries are not vendored in this repository. The experiment
wrapper records release/binary hashes and validates plans in exported PDDL using
Unified Planning. The canonical reference is Malte Helmert, "The Fast Downward
Planning System," JAIR 26:191-246, 2006.

# Narrative planning domains

Start with [groups.csv](groups.csv). Each row identifies one registered source
group and links its NarraFuse domain, Union baseline and available official
UniDomain outputs. Use `source_ids` to find the exact inputs in
[`sources/registered/`](sources/registered/). Paths in the catalogs are relative
to this directory unless labeled as original paths.

| Location | Contents |
| --- | --- |
| `sources/registered/` | Exact source domains used by the 1,200 registered groups. |
| `sources/there_and_back/` | Original and revised GPT-4 outputs from TinyStories and WritingPrompts. The source catalog records empty outputs. Some nonempty outputs have syntax errors. |
| `sources/human_authored/` | Downloads from the Belief/Intention, Glaive, GME, Porteous and Sabre collections. Native Sabre files combine action definitions and a world in one file. |
| `narra-domains/` | The 15 original local narrative domains used by the default Union CLI. Their local intake did not verify the upstream author or learning method. |
| `sources/other_external/` | Additional downloaded comparison domains, including logistics and transport. |
| `merged/narrafuse/`, `merged/union/` | Parameterized pre-search PDDL, named by group. |
| `merged/unidomain/native/` | Official UniDomain's frozen root JSON, one file for each group with a constructed root. |
| `merged/unidomain/pilots/`, `merged/unidomain_local/` | Earlier official pilot outputs and the local binary-tree adapter's 15-domain output. These have separate provenance from the registered comparison. |
| `merged/unidomain/pddl_projection/` | Physical PDDL exports saved by the comparison adapter. An export alone does not establish plan validity. |
| `merged/mappings.tar.gz` | Exact source mappings for the two PDDL arms, plus lineage for the official projections. Entries are named by method and group. |
| `merged/other_experiments.tar.gz` | Additional identifiable input domains, multi-source compiler outputs, mappings and official fusion nodes from the research checkout. Read the archive's `index.csv` to locate the bytes. Repeated files share one digest. |

For the Arthur, Batman and Little Red case, open
[the NarraFuse domain](merged/narrafuse/human__random__k03__022.pddl) and
[the Union domain](merged/union/human__random__k03__022.pddl).
The official method's status for this group appears in `groups.csv`.

[sources.csv](sources.csv) gives collection identities and provenance.
[artifacts.csv](artifacts.csv) lists the SHA-256 and original research path for
each individually exported domain. Registered input files can also occur in
the downloaded collections under their original names. Count registered rows,
source identities and distinct byte sequences separately.
Third-party notices and available upstream license files are in
[`sources/notices.tar.gz`](sources/notices.tar.gz).

Original problems, plans, logs, failures, frozen indices and full experiment
runs are kept in the local research layout. From the repository root, switch
layouts between runs with `./scripts/data/Set-DataLayout.ps1 Research` or
`./scripts/data/Set-DataLayout.ps1 Domains`. Both operations rename directories
on the same volume and retain edits in their respective layouts.

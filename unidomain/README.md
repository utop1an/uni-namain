# Local UniDomain reference adapter

Use the package entry point:

```powershell
.venv/Scripts/python.exe -m unidomain --help
```

Run from the repository root. Real fusion requires `pip install -e ".[fusion]"`,
local model weights and Ollama. Reading modules and offline tests
do not require starting model inference.

| Module | Responsibility |
| --- | --- |
| `models.py` | MPNet embeddings, Ollama requests, retries, cache keys and counters |
| `fusion.py` | Response schemas, prompts, candidate selection, predicate/operator merging and rollback |
| `pipeline.py` | Ordered binary tree, worker execution, intermediate exports and final validation |
| `cli.py` | Existing arguments/defaults and runtime construction |
| `__main__.py` | Package command entry |

Python callers should import `FusionRuntime`/`fuse_pair` from `unidomain.fusion`,
`OllamaClient`/`EmbeddingService` from `unidomain.models`, and `run` from
`unidomain.pipeline`.
The current request pipeline remains in `rcnc/`, independently of this baseline.

Prompt files remain in `prompts/unidomain/`. Model options, strict threshold
comparison, candidate ordering, odd-node placement, predicate-first fusion,
constant identities, structural rollback, cache formats and retry behavior are
retained. This source split does not claim new semantic accuracy or completion
of the previously interrupted historical reference run.

The fresh-reference runner freezes the package entry point, all package sources, shared
PDDL helpers and prompt files. [relocation.json](relocation.json) records the
original source hash. Historical caches, outputs and frozen inventories are not
rewritten. Use a fresh output path for a new run; cache continuation remains a
separate condition.

The old root wrapper is preserved in `archive/entrypoints/`. Saved reference runs
can contain either the old wrapper or the package entry point; all recorded source
hashes are still verified before admitting a completed run.

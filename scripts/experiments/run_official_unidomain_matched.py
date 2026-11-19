"""Run the official UniDomain fusion kernel on the registered narrative cohort."""

import argparse
from collections import Counter
from contextlib import redirect_stdout
from contextvars import ContextVar
from functools import lru_cache
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import time
from types import SimpleNamespace
from urllib.request import Request, urlopen

from rcnc.glaive_merge import Source, action_fields
from rcnc.pddl import parse_sexpr, section, serialize
from scripts.experiments.run_downward_reference import save, sha
from scripts.experiments.run_matched_unidomain_rule import physical_domain


ROOT = Path(__file__).resolve().parents[2]
OFFICIAL = ROOT / ".tmp/unidomain_official_20261109"
DEPS = ROOT / ".tmp/unidomain_official_deps_20261109"
COMMIT = "db46419732d5c8949f85c0dbcce5ab9c8a8a4d5c"
PRIOR = ROOT / "data/validation/narrafuse_unidomain_rule_2026_11_09_v3"
SOURCE_INDEX = ROOT / "data/validation/priority1_union_full_evaluation_2026_11_06_v1/sources.json"
EMBEDDING = (Path.home() / ".cache/huggingface/hub/models--sentence-transformers--all-mpnet-base-v2"
             / "snapshots/e8c3b32edf5434bc2275fc9bab85f82640a19130")
TRACE = ContextVar("official_trace")


def read(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def atomic(source):
    domain = physical_domain(source.root)
    predicates = {}
    for definition in section(domain, ":predicates")[1:]:
        signature = serialize(definition)
        predicates[signature] = f"Source predicate {signature}."
    operators = {}
    for action in domain:
        if isinstance(action, list) and action and action[0] == ":action":
            fields = action_fields(action)
            body = "\n ".join(f"{key} {serialize(fields[key])}"
                             for key in (":parameters", ":precondition", ":effect"))
            operators[action[1]] = f"(:action {action[1]}\n {body}\n)"
    return {"predicates": predicates, "operators": operators}


def prepare(output):
    head = subprocess.check_output(["git", "-C", str(OFFICIAL), "rev-parse", "HEAD"], text=True).strip()
    if head != COMMIT:
        raise ValueError("Unexpected official commit")
    output.mkdir(parents=True, exist_ok=False)
    (output / "atomic").mkdir()
    parent = read(PRIOR / "protocol.json")
    sources = {r["id"]: r for r in read(SOURCE_INDEX)["sources"]}
    groups = {}
    leaves = {}
    for gid, group in sorted(parent["groups"].items()):
        ids = group["group"]["sources"]
        groups[gid] = {"sources": ids, "status": group["physical_status"],
                       "search_status": group["task_status"]}
        if group["physical_status"] != "ready":
            continue
        hashes = read(group["mapping"])["source_sha256"]
        for sid in ids:
            if sid in leaves:
                continue
            path = Path(sources[sid]["domain"])
            if sha(path) != hashes[sid]["domain"]:
                raise ValueError(f"Source changed for {sid}")
            spec = sources[sid]
            source = Source(sid, path, Path(spec["representative_problem"]),
                            spec.get("constant_contract"), spec.get("consent_policy"))
            if sha(source.problem_path) != hashes[sid]["problem"]:
                raise ValueError(f"Source representative problem changed for {sid}")
            data = atomic(source)
            artifact = output / "atomic" / f"{sid}.json"
            save(artifact, data)
            leaves[sid] = {"source": str(path), "source_sha256": sha(path),
                           "atomic_sha256": sha(artifact),
                           "predicates": len(data["predicates"]), "actions": len(data["operators"])}
    eligible = [g for g in groups if groups[g]["status"] == "ready" and len(groups[g]["sources"]) == 2]
    def pair_size(gid):
        left, right = (leaves[s] for s in groups[gid]["sources"])
        return sum(left[k] * right[k] for k in ("predicates", "actions")), gid
    pilot = min(eligible, key=pair_size)
    protocol = {"status": "frozen_official_fusion_inputs", "official_commit": COMMIT,
                "parent_protocol_sha256": sha(PRIOR / "protocol.json"),
                "source_index_sha256": sha(SOURCE_INDEX), "groups": groups, "sources": leaves,
                "original_reference_slots": parent["transport_slots"],
                "search_budget": parent["budget"], "pilot_group": pilot,
                "pilot_selection": "Smallest two-source candidate cross-product before any model decisions.",
                "thresholds": {"predicate": 0.3, "operator": 0.3},
                "primary_model": "gpt-4.1", "temperature": 0.0,
                "embedding_snapshot": EMBEDDING.name,
                "leaf_conversion": "Exact source predicates and physical action schemas in official JSON format. "
                                   "Typed arguments retained. Predicate descriptions expose declarations only. "
                                   "Native axiom cases inherit the paired physical-fragment exclusion."}
    save(output / "protocol.json", protocol)
    print(json.dumps({"groups": len(groups), "physical_groups": sum(g["status"] == "ready" for g in groups.values()),
                      "atomic_domains": len(leaves), "pilot": pilot, "pilot_candidate_upper_bound": pair_size(pilot)[0]}))


def official_runtime(model, max_calls, local):
    sys.path[:0] = [str(OFFICIAL / "src"), str(DEPS)]
    os.environ["HF_HUB_OFFLINE"] = "1"
    os.environ["EMBEDDING_MODEL_PATH"] = str(EMBEDDING)
    os.environ["CUDA_VISIBLE_DEVICES"] = "-1"
    if local:
        os.environ["API_KEY"] = "local-ollama"
        os.environ["BASE_URL"] = "http://127.0.0.1:11434/v1"
    else:
        from dotenv import dotenv_values
        key = dotenv_values(ROOT / ".env").get("openai_api")
        if not key:
            raise ValueError("Missing OpenAI configuration")
        os.environ["API_KEY"] = key
        os.environ["BASE_URL"] = "https://api.openai.com/v1"
    os.environ["CLIENT_TYPE"] = "OpenAI"
    from unidomain.configs.settings import config
    from unidomain.configs.llm import LLMAgentConfig
    from unidomain.domain_fusion import predicate_merging, operator_merging
    from unidomain.domain_fusion.runner import fuse_two_domains
    from unidomain.services.embedding import TextEmbeddingAPI
    from unidomain.services.llm_agent import LLMAgent

    config.llm_tasks.call_max_retries = 1
    config.llm_tasks.validator_max_retries = 2
    config.llm_tasks.validator_retry_delay = 0
    uncached = TextEmbeddingAPI.text_embedding

    @lru_cache(maxsize=12000)
    def embed(texts):
        return uncached(TextEmbeddingAPI(), list(texts))

    TextEmbeddingAPI.text_embedding = lambda self, texts: embed(tuple(texts))
    stats = Counter()

    class CallBudgetReached(RuntimeError):
        pass

    def ollama_completion(*, model, messages, n, temperature, max_tokens, timeout):
        if n != 1:
            raise ValueError("Fusion calls require exactly one candidate")
        body = json.dumps({"model": model, "messages": messages, "stream": False,
                           "think": False, "format": "json",
                           "options": {"temperature": temperature, "num_predict": max_tokens}})
        request = Request("http://127.0.0.1:11434/api/chat", data=body.encode("utf-8"),
                          headers={"Content-Type": "application/json"})
        with urlopen(request, timeout=timeout) as response:
            result = json.load(response)
        return SimpleNamespace(
            choices=[SimpleNamespace(message=SimpleNamespace(content=result["message"]["content"]))],
            usage=SimpleNamespace(prompt_tokens=result["prompt_eval_count"],
                                  completion_tokens=result["eval_count"]))

    class MeteredAgent(LLMAgent):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, **kwargs)
            if local:
                self._client = SimpleNamespace(chat=SimpleNamespace(
                    completions=SimpleNamespace(create=ollama_completion)))

        def call(self, prompt, image_path_list=None, n=1):
            if stats["model_calls"] >= max_calls:
                raise CallBudgetReached("Frozen model-call cap reached")
            stats["model_calls"] += 1
            result = super().call(prompt, image_path_list, n)
            stats["responses"] += 1
            return result

    def observe(fn, kind):
        def observed(agent, args):
            result = fn(agent, args)
            TRACE.get().append({"kind": kind, "input": args.model_dump(), "output": result})
            return result
        return observed

    predicate_merging._check_merge_predicates = observe(predicate_merging._check_merge_predicates, "predicate")
    predicate_merging._update_action_string = observe(predicate_merging._update_action_string, "predicate_rewrite")
    operator_merging._check_merge_actions = observe(operator_merging._check_merge_actions, "operator")
    settings = LLMAgentConfig(model=model, kwargs={"temperature": 0.0, "max_tokens": 1024, "timeout": 35})
    return fuse_two_domains, MeteredAgent, settings, stats


def fuse(output, model, max_calls, local, phase):
    protocol = read(output / "protocol.json")
    if sha(PRIOR / "protocol.json") != protocol["parent_protocol_sha256"]:
        raise ValueError("Matched input protocol changed")
    for sid, receipt in protocol["sources"].items():
        if sha(output / "atomic" / f"{sid}.json") != receipt["atomic_sha256"]:
            raise ValueError("Frozen official input changed")
    if phase == "diagnostic-pilot":
        ref_groups = {r["group"] for r in protocol["original_reference_slots"]
                      if r["reference"].get("validation_level") == "dual_validated"}
        eligible = [gid for gid, group in protocol["groups"].items()
                    if group["search_status"] == "ready" and len(group["sources"]) == 2
                    and gid in ref_groups]
        def size(gid):
            a, b = (protocol["sources"][s] for s in protocol["groups"][gid]["sources"])
            return a["actions"] * b["actions"] + a["predicates"] * b["predicates"], gid
        ids = [min(eligible, key=size)]
    elif phase == "pilot":
        ids = [protocol["pilot_group"]]
    else:
        ids = sorted(protocol["groups"])
    directory = output / phase
    directory.mkdir(exist_ok=False)
    save(directory / "execution_protocol.json", {"model": model, "max_calls": max_calls,
         "temperature": 0.0, "max_tokens": 1024, "official_commit": COMMIT,
         "input_protocol_sha256": sha(output / "protocol.json"),
         "implementation_sha256": sha(Path(__file__)),
         "endpoint": "local_ollama_native_json_no_thinking" if local else "openai",
         "group_ids": ids, "pilot_only": phase != "fusion",
         "policy": "Fresh official calls; no historical response reuse."})
    fusion, agent, settings, stats = official_runtime(model, max_calls, local)
    rows = []
    node_cache = {}
    for gid in ids:
        g = protocol["groups"][gid]
        row = {"group": gid, "status": g["status"], "nodes": []}
        if g["status"] == "ready":
            started = time.monotonic()
            before = stats["model_calls"]
            layer = [output / "atomic" / f"{s}.json" for s in g["sources"]]
            group_dir = directory / gid
            group_dir.mkdir()
            try:
                while len(layer) > 1:
                    next_layer = [layer[-1]] if len(layer) % 2 else []
                    for i in range(0, len(layer) - 1, 2):
                        left, right = layer[i:i + 2]
                        key = (sha(left), sha(right))
                        cached = key in node_cache
                        if cached:
                            dest = node_cache[key]
                        else:
                            step = group_dir / f"node_{len(row['nodes']):02d}"
                            step.mkdir()
                            dest = step / "official_domain.json"
                            trace = []
                            token = TRACE.set(trace)
                            try:
                                with (step / "console.log").open("w", encoding="utf-8") as log:
                                    with redirect_stdout(log):
                                        fusion(left.resolve(), right.resolve(), agent(settings, step.resolve()),
                                               dest.resolve(), 0.3, 0.3)
                            finally:
                                TRACE.reset(token)
                                save(step / "decisions.json", {"left": str(left), "right": str(right),
                                                              "events": trace})
                            node_cache[key] = dest
                        row["nodes"].append({"left": str(left), "right": str(right),
                                             "domain": str(dest), "sha256": sha(dest), "cached": cached})
                        next_layer.append(dest)
                    layer = next_layer
                row.update(status="official_root_constructed", domain=str(layer[0]))
            except Exception as exc:
                row.update(status="fusion_call_limit" if type(exc).__name__ == "CallBudgetReached"
                           else "official_fusion_error", error_type=type(exc).__name__)
            row.update(model_calls=stats["model_calls"] - before,
                       elapsed_seconds=round(time.monotonic() - started, 2))
        rows.append(row)
        save(directory / "report.json", {"status": "running", "model": model, "rows": rows,
                                         "model_calls": stats["model_calls"]})
        print(json.dumps({k: v for k, v in row.items() if k != "nodes"}), flush=True)
    save(directory / "report.json", {"status": "terminal", "model": model, "rows": rows,
                                     "model_calls": stats["model_calls"],
                                     "counts": dict(Counter(r["status"] for r in rows))})


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("phase", choices=("prepare", "pilot", "diagnostic-pilot", "fusion"))
    parser.add_argument("output", type=Path)
    parser.add_argument("--model", default="qwen3:8b")
    parser.add_argument("--max-calls", type=int, default=120)
    parser.add_argument("--openai", action="store_true",
                        help="External service. Requires explicit authorization to transfer these source domains.")
    args = parser.parse_args()
    if args.phase == "prepare":
        prepare(args.output)
    else:
        fuse(args.output, args.model, args.max_calls, not args.openai, args.phase)

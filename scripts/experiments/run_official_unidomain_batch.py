"""Execute the pinned official fusion kernel with dependency-aware OpenAI Batch calls."""

import argparse
from collections import Counter
from contextlib import redirect_stdout
from decimal import Decimal
import hashlib
import json
from pathlib import Path
import subprocess
import time

from rcnc.glaive_merge import Source
from scripts.experiments.run_downward_reference import save, sha
from scripts.experiments.run_official_unidomain_matched import (
    COMMIT, OFFICIAL, ROOT, TRACE, atomic, official_runtime, read,
)
from scripts.experiments.run_openai_alignment_batch import (
    NANO, TERMINAL, api, helpers, safe_error, upload,
)

MODEL = "gpt-6.1-sol"
MAX_OUTPUT = 4096
ENDPOINT = "/v1/responses"
INPUT_CAP = 64_000


class WaitingForBatch(Exception):
    pass


class UnavailableResponse(Exception):
    pass


def receipt_path(receipt):
    path = ROOT / receipt["path"]
    if sha(path) != receipt["sha256"]:
        raise ValueError(f"Frozen input changed: {path}")
    return path


def prepare(registry_path, directory, cap):
    if subprocess.check_output(["git", "-C", str(OFFICIAL), "rev-parse", "HEAD"],
                               text=True).strip() != COMMIT:
        raise ValueError("Unexpected UniDomain revision")
    if subprocess.check_output(["git", "-C", str(OFFICIAL), "status", "--porcelain"]):
        raise ValueError("Official UniDomain checkout is modified")
    registry = read(registry_path)
    source_index = read(receipt_path(registry["registered_inputs"]["source_index"]))
    metadata = {s["id"]: s for s in source_index["sources"]}
    directory.mkdir(parents=True, exist_ok=False)
    atomic_directory = directory / "atomic"
    atomic_directory.mkdir()
    sources = {}
    for sid, source in registry["sources"].items():
        domain = receipt_path(source["domain"])
        problem = receipt_path(source["representative_problem"])
        spec = metadata[sid]
        original = Source(sid, domain, problem, spec.get("constant_contract"), spec.get("consent_policy"))
        if any(isinstance(x, list) and x[:1] in ([":axiom"], [":derived"]) for x in original.root):
            sources[sid] = {"status": "unsupported_native_axioms"}
            continue
        try:
            leaf = atomic(original)
        except ValueError as error:
            sources[sid] = {"status": "unsupported_intention_dependency", "reason": str(error)}
            continue
        path = atomic_directory / f"{sid}.json"
        save(path, leaf)
        sources[sid] = {"status": "ready", "sha256": sha(path)}
    groups = []
    for row in registry["groups"]:
        excluded = sorted({sources[sid]["status"] for sid in row["sources"]} - {"ready"})
        groups.append({"id": row["id"], "sources": row["sources"], "excluded": excluded})
    protocol = {"status": "frozen_before_upload", "registry_sha256": sha(registry_path),
                "implementation_sha256": sha(Path(__file__)), "commit": COMMIT, "model": MODEL,
                "reasoning_effort": "medium", "api": "OpenAI Batch /v1/responses",
                "max_output_tokens": MAX_OUTPUT, "max_input_byte_allowance": INPUT_CAP,
                "thresholds": [0.3, 0.3], "cap_nano_usd": cap,
                "cost_rates_nano_per_token": {"input": 2500, "output": 5000},
                "scope": "Official prompts with frozen physical predicate and action schemas only; "
                         "no supplied problems, goals, source plans or narrative text.",
                "policy": "Exact-prompt response reuse within this run; no speculative requests, "
                          "automatic retries or synchronous model calls.",
                "sources": sources, "groups": groups}
    save(directory / "protocol.json", protocol)
    print(json.dumps({"registered_groups": len(groups), "eligible": sum(not g["excluded"] for g in groups),
                      "source_status": dict(Counter(s["status"] for s in sources.values()))}), flush=True)
    return protocol


def batch_request(prompt):
    if len(prompt.encode("utf-8")) + 8192 > INPUT_CAP:
        raise UnavailableResponse("prompt_exceeds_short_context_reservation_limit")
    body = {"model": MODEL, "reasoning": {"effort": "medium"}, "max_output_tokens": MAX_OUTPUT,
            "input": [{"role": "user", "content": prompt}], "store": False}
    request_id = hashlib.sha256(json.dumps(body, sort_keys=True).encode()).hexdigest()
    return {"custom_id": request_id, "method": "POST", "url": ENDPOINT, "body": body}


def batch_runtime():
    # Initialize the official package with a dummy credential and local
    # embedding weights. Only the supplied Batch agent handles LLM prompts.
    fusion, _, _, _ = official_runtime(MODEL, 0, True)
    from unidomain.configs.settings import config
    from unidomain.services.llm_agent import _llm_post_process
    config.llm_tasks.validator_max_retries = 1
    return fusion, _llm_post_process


def node_frontier(directory, protocol, responses, outcomes, runtime):
    fusion, clean_output = runtime
    for sid, source in protocol["sources"].items():
        if source["status"] == "ready" and sha(directory / "atomic" / f"{sid}.json") != source["sha256"]:
            raise ValueError("Frozen atomic model changed")
    pending = {}

    class BatchAgent:
        def __init__(self, log_dir):
            self.log_dir = log_dir

        def call(self, prompt, image_path_list=None, n=1):
            if image_path_list or n != 1:
                raise ValueError("Expected one text-only official call")
            request = batch_request(prompt)
            request_id = request["custom_id"]
            if request_id not in responses:
                pending[request_id] = request
                raise WaitingForBatch
            answer = responses[request_id]
            if answer is None:
                raise UnavailableResponse("official_model_response_unavailable")
            return clean_output(answer)

    def merge(left, right):
        node_id = hashlib.sha256((sha(left) + sha(right)).encode()).hexdigest()
        if node_id in outcomes:
            return outcomes[node_id]
        node = directory / "nodes" / node_id
        node.mkdir(parents=True, exist_ok=True)
        output = node / "official_domain.json"
        events = []
        token = TRACE.set(events)
        try:
            with (node / "console.log").open("a", encoding="utf-8") as log, redirect_stdout(log):
                fusion(left.resolve(), right.resolve(), BatchAgent(node.resolve()), output.resolve(), 0.3, 0.3)
        except WaitingForBatch:
            outcomes[node_id] = (None, "awaiting_batch")
        except Exception as error:
            save(node / "failure.json", {"type": type(error).__name__, "detail": str(error)})
            outcomes[node_id] = (None, "official_fusion_error")
        else:
            save(node / "decisions.json", {"left": str(left), "right": str(right), "events": events})
            save(node / "receipt.json", {"left": str(left), "right": str(right),
                                         "domain_sha256": sha(output),
                                         "decisions_sha256": sha(node / "decisions.json")})
            outcomes[node_id] = (output, "official_root_constructed")
        finally:
            TRACE.reset(token)
        return outcomes[node_id]

    rows = []
    for group in protocol["groups"]:
        row = {"group": group["id"], "status": "unsupported_input", "excluded": group["excluded"]}
        rows.append(row)
        if group["excluded"]:
            continue
        layer = [(directory / "atomic" / f"{sid}.json", "atomic") for sid in group["sources"]]
        while len(layer) > 1:
            next_layer = [layer[-1]] if len(layer) % 2 else []
            for index in range(0, len(layer) - 1, 2):
                (left, left_status), (right, right_status) = layer[index:index + 2]
                if left is not None and right is not None:
                    next_layer.append(merge(left, right))
                else:
                    failed = "official_fusion_error" in (left_status, right_status)
                    next_layer.append((None, "official_fusion_error" if failed else "awaiting_batch"))
            layer = next_layer
        output, row["status"] = layer[0]
        if output is not None:
            row.update(domain=str(output), sha256=sha(output))
    return rows, pending


def liability(request):
    size = len(request["body"]["input"][0]["content"].encode("utf-8"))
    return (size + 8192) * 2500 + MAX_OUTPUT * 5000


def completed_text(body):
    if body.get("status") != "completed":
        return None
    text = [part["text"] for item in body["output"] if item["type"] == "message"
            for part in item["content"] if part["type"] == "output_text"]
    return "".join(text) if text else None


def execute_wave(directory, wave, requests, key, responses):
    directory.mkdir(exist_ok=False)
    path = directory / "input.jsonl"
    path.write_text("".join(json.dumps(r, ensure_ascii=False) + "\n" for r in requests), encoding="utf-8")
    ceilings = {r["custom_id"]: liability(r) for r in requests}
    reservation = sum(ceilings.values())
    save(directory / "request_receipt.json", {"sha256": sha(path), "count": len(requests),
                                              "reserved_nano_usd": reservation})
    uploaded = upload(key, path)
    save(directory / "upload.json", uploaded)
    batch = api(key, "batches", {"input_file_id": uploaded["id"], "endpoint": ENDPOINT,
                                 "completion_window": "24h"})
    save(directory / "created.json", batch)
    print(json.dumps({"wave": wave, "batch_id": batch["id"], "requests": len(requests),
                      "reserved_usd": reservation / NANO, "status": batch["status"]}), flush=True)
    while batch["status"] not in TERMINAL:
        time.sleep(20)
        batch = api(key, "batches/" + batch["id"])
        helpers.atomic_progress(directory / "status.json", batch)
    save(directory / "terminal.json", batch)
    consumed = 0
    seen = set()
    for file_kind in ("output", "error"):
        file_id = batch.get(file_kind + "_file_id")
        if not file_id:
            continue
        content = api(key, "files/" + file_id + "/content", raw=True)
        (directory / (file_kind + ".jsonl")).write_bytes(content)
        for line in content.splitlines():
            row = json.loads(line)
            rid = row["custom_id"]
            if rid in seen or rid not in ceilings:
                raise ValueError("Unexpected Batch response identity")
            seen.add(rid)
            response = row.get("response") or {}
            body = response.get("body") or {}
            usage = body.get("usage") or {}
            debit = ceilings[rid]
            if type(usage.get("input_tokens")) is int and type(usage.get("output_tokens")) is int:
                debit = usage["input_tokens"] * 2500 + usage["output_tokens"] * 5000
                if not 0 <= debit <= ceilings[rid]:
                    raise ValueError("Usage outside reserved billing envelope")
            consumed += debit
            model = body.get("model", "")
            same_model = model == MODEL or model.startswith(MODEL + "-")
            responses[rid] = completed_text(body) if response.get("status_code") == 200 and same_model else None
    for rid in ceilings.keys() - seen:
        consumed += ceilings[rid]
        responses[rid] = None
    return consumed, batch["status"]


def run(directory, protocol):
    key = helpers.credential(ROOT / ".env")
    runtime = batch_runtime()
    responses, outcomes = {}, {}
    spent, wave = 0, 0
    while True:
        outcomes = {k: v for k, v in outcomes.items() if v[1] != "awaiting_batch"}
        rows, pending = node_frontier(directory, protocol, responses, outcomes, runtime)
        counts = dict(Counter(row["status"] for row in rows))
        report = {"status": "ready_for_batch", "waves_completed": wave, "response_slots": len(responses),
                  "accounted_usd": spent / NANO, "counts": counts, "rows": rows}
        helpers.atomic_progress(directory / "report.json", report)
        if not pending:
            report["status"] = "fusion_terminal"
            break
        remaining = protocol["cap_nano_usd"] - spent
        selected = []
        for request in pending.values():
            maximum = liability(request)
            if maximum <= remaining:
                selected.append(request)
                remaining -= maximum
        if not selected:
            report["status"] = "budget_cap_reached"
            break
        wave_path = directory / f"wave_{wave + 1:04d}"
        try:
            spent_delta, terminal = execute_wave(wave_path, wave + 1, selected, key, responses)
        except Exception as error:
            report.update(status="batch_state_unresolved", error=safe_error(error),
                          held_liability_usd=sum(map(liability, selected)) / NANO)
            break
        spent += spent_delta
        wave += 1
        if terminal != "completed":
            report.update(status="batch_ended_without_completion", batch_terminal_status=terminal,
                          waves_completed=wave, response_slots=len(responses), accounted_usd=spent / NANO)
            break
    helpers.atomic_progress(directory / "report.json", report)
    print(json.dumps({k: v for k, v in report.items() if k != "rows"}), flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("registry", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--cap-usd", type=Decimal, required=True)
    parser.add_argument("--submit", action="store_true")
    args = parser.parse_args()
    if not args.cap_usd.is_finite() or args.cap_usd <= 0:
        parser.error("A positive finite spending limit is required")
    registered = prepare(args.registry, args.output, int(args.cap_usd * NANO))
    if args.submit:
        run(args.output, registered)
    else:
        rows, pending = node_frontier(args.output, registered, {}, {}, batch_runtime())
        save(args.output / "offline_frontier.json",
             {"counts": dict(Counter(r["status"] for r in rows)), "requests": len(pending),
              "maximum_first_wave_usd": sum(map(liability, pending.values())) / NANO})

"""Recover the official UniDomain campaign without reissuing any submitted request."""

import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import time
from urllib.error import HTTPError, URLError

from scripts.experiments import run_official_unidomain_batch as batch


def receipt(path):
    return {"path": str(path), "sha256": batch.sha(path)}


def atomic_progress(path, value):
    for attempt in range(8):
        try:
            batch.helpers.atomic_progress(path, value)
            return
        except PermissionError:
            # Windows can briefly deny replacement while a reader has the file open.
            if attempt == 7:
                raise
            time.sleep(0.25 * (attempt + 1))


def rows_from(path):
    return [json.loads(line) for line in path.read_bytes().splitlines()]


def check_wave(wave):
    path = wave / "input.jsonl"
    registered = batch.read(wave / "request_receipt.json")
    rows = rows_from(path)
    requests = {}
    for row in rows:
        inputs, = row["body"]["input"]
        rid = row["custom_id"]
        if row != batch.batch_request(inputs["content"]) or rid in requests:
            raise ValueError(f"Changed or duplicate request in {wave}")
        requests[rid] = batch.liability(row)
    if (batch.sha(path) != registered["sha256"] or len(rows) != registered["count"]
            or sum(requests.values()) != registered["reserved_nano_usd"]):
        raise ValueError(f"Request receipt mismatch in {wave}")
    return requests


def check_batch(wave, response):
    created = batch.read(wave / "created.json")
    uploaded = batch.read(wave / "upload.json")
    if (response["id"] != created["id"] or response["input_file_id"] != uploaded["id"]
            or created["input_file_id"] != uploaded["id"] or response["endpoint"] != batch.ENDPOINT
            or response["completion_window"] != "24h"
            or response.get("model") not in (None, batch.MODEL)):
        raise ValueError(f"Provider batch identity mismatch in {wave}")


def ingest(ceilings, terminal, output_directory, responses):
    if terminal["status"] not in batch.TERMINAL or ceilings.keys() & responses.keys():
        raise ValueError("Nonterminal or already accounted Batch")
    answers, spent = {}, 0
    for kind in ("output", "error"):
        if not terminal.get(f"{kind}_file_id"):
            continue
        for row in rows_from(output_directory / f"{kind}.jsonl"):
            rid = row["custom_id"]
            if rid in answers or rid not in ceilings:
                raise ValueError("Unexpected Batch response identity")
            response = row.get("response") or {}
            body = response.get("body") or {}
            model = body.get("model", "")
            correct_model = model == batch.MODEL or model.startswith(batch.MODEL + "-")
            usage = body.get("usage") or {}
            debit = ceilings[rid]
            if type(usage.get("input_tokens")) is int and type(usage.get("output_tokens")) is int:
                a, b = usage["input_tokens"], usage["output_tokens"]
                if min(a, b) < 0 or b > batch.MAX_OUTPUT:
                    raise ValueError("Invalid usage record")
                debit = a * 2500 + b * 5000
                if debit > ceilings[rid]:
                    raise ValueError("Usage outside reserved billing envelope")
            spent += debit
            answers[rid] = batch.completed_text(body) if response.get("status_code") == 200 and correct_model else None
    count = terminal.get("request_counts") or {}
    if terminal["status"] == "completed" and len(answers) != len(ceilings):
        raise ValueError("Completed Batch does not account for every request")
    if len(answers) < count.get("completed", 0) + count.get("failed", 0):
        raise ValueError("Returned files omit provider-accounted requests")
    for rid in ceilings.keys() - answers.keys():
        answers[rid] = None
        spent += ceilings[rid]
    responses.update(answers)
    return spent


def load_history(original, active_wave, checkpoints=()):
    protocol = batch.read(original / "protocol.json")
    original_code = Path(batch.__file__)
    if batch.sha(original_code) != protocol["implementation_sha256"]:
        raise ValueError("Frozen original fusion implementation changed")
    if protocol["cap_nano_usd"] != 100 * batch.NANO or protocol["model"] != batch.MODEL:
        raise ValueError("Expected the original USD 100 gpt-6.1-sol protocol")
    for cmd, expected in ((["rev-parse", "HEAD"], protocol["commit"]), (["status", "--porcelain"], "")):
        actual = batch.subprocess.check_output(["git", "-C", str(batch.OFFICIAL), *cmd], text=True).strip()
        if actual != expected:
            raise ValueError("Pinned official repository changed")
    segments = (original, *checkpoints)
    waves = sorted((path for segment in segments for path in segment.glob("wave_*") if path.is_dir()),
                   key=lambda path: path.name)
    if [path.name for path in waves] != [f"wave_{i:04d}" for i in range(1, active_wave + 1)]:
        raise ValueError("Campaign has missing or duplicate wave directories")
    recovered = {}
    for checkpoint in checkpoints:
        previous = batch.read(checkpoint / "continuation.json")
        if previous["original_protocol"] != receipt(original / "protocol.json"):
            raise ValueError("Continuation references another campaign")
        snapshot = checkpoint / "implementation_at_checkpoint.py"
        if not snapshot.is_file():
            snapshot = Path(previous["implementation"]["path"])
        if batch.sha(snapshot) != previous["implementation"]["sha256"]:
            raise ValueError("Checkpoint implementation receipt mismatch")
        for path in checkpoint.glob("recovered_wave_*"):
            name = path.name.removeprefix("recovered_")
            if name in recovered:
                raise ValueError("Duplicate recovery for one wave")
            recovered[name] = path
    submitted, responses, spent, evidence, batch_ids = set(), {}, 0, [], set()
    for index, wave in enumerate(waves, 1):
        ceilings = check_wave(wave)
        if submitted & ceilings.keys():
            raise ValueError("Duplicate request across original Batch submissions")
        submitted.update(ceilings)
        provider = batch.read(wave / "created.json")
        check_batch(wave, provider)
        if provider["id"] in batch_ids:
            raise ValueError("Duplicate provider batch ID")
        batch_ids.add(provider["id"])
        terminal_source = recovered.get(wave.name, wave)
        terminal_path = terminal_source / "terminal.json"
        if index != active_wave:
            terminal = batch.read(terminal_path)
            check_batch(wave, terminal)
            spent += ingest(ceilings, terminal, terminal_source, responses)
        evidence.append({"wave": index, "batch_id": provider["id"], "requests": len(ceilings),
                         "files": [receipt(wave / n) for n in (
                             "input.jsonl", "request_receipt.json", "upload.json", "created.json")]
                         + [receipt(terminal_source / n) for n in ("terminal.json", "output.jsonl", "error.jsonl")
                            if (terminal_source / n).is_file()]})
    active = waves[-1]
    reserved = sum(check_wave(active).values())
    prior_report = batch.read(segments[-1] / "report.json")
    if (prior_report.get("waves_accounted", prior_report.get("waves_completed")) != active_wave - 1
            or prior_report["response_slots"] != len(responses)
            or round(prior_report["accounted_usd"] * batch.NANO) != spent
            or spent + reserved > protocol["cap_nano_usd"]):
        raise ValueError("Recovered billing and original ledger disagree")
    if prior_report.get("submitted_requests", len(submitted)) != len(submitted):
        raise ValueError("Checkpoint and submitted request count differ")
    return protocol, responses, submitted, spent, evidence, active, reserved


def checked_nodes(original):
    outcomes = {}
    for path in sorted((original / "nodes").glob("*/receipt.json")):
        record = batch.read(path)
        node = path.parent
        left, right = (Path(record[k]) for k in ("left", "right"))
        identity = hashlib.sha256((batch.sha(left) + batch.sha(right)).encode()).hexdigest()
        domain = node / "official_domain.json"
        if (identity != node.name or batch.sha(domain) != record["domain_sha256"]
                or batch.sha(node / "decisions.json") != record["decisions_sha256"]):
            raise ValueError(f"Frozen node mismatch: {node.name}")
        outcomes[node.name] = (domain, "official_root_constructed")
    return outcomes


def read_api(key, resource, raw=False):
    for attempt in range(5):
        try:
            return batch.api(key, resource, raw=raw)
        except (URLError, TimeoutError) as exc:
            if isinstance(exc, HTTPError) and exc.code not in {408, 429, 500, 502, 503, 504}:
                raise
            if attempt == 4:
                raise
            time.sleep(3 * (attempt + 1))


def settle_wave(original_wave, destination, key, responses, heartbeat):
    provider = batch.read(original_wave / "created.json")
    while True:
        status = read_api(key, "batches/" + provider["id"])
        check_batch(original_wave, status)
        atomic_progress(destination / "status.json", status)
        heartbeat(status)
        if status["status"] in batch.TERMINAL:
            break
        time.sleep(30)
    batch.save(destination / "terminal.json", status)
    for kind in ("output", "error"):
        file_id = status.get(f"{kind}_file_id")
        if file_id:
            content = read_api(key, "files/" + file_id + "/content", raw=True)
            (destination / f"{kind}.jsonl").write_bytes(content)
    return ingest(check_wave(original_wave), status, destination, responses), status["status"]


def submit_wave(directory, selected, key):
    directory.mkdir(exist_ok=False)
    path = directory / "input.jsonl"
    path.write_text("".join(json.dumps(row, ensure_ascii=False) + "\n" for row in selected), encoding="utf-8")
    batch.save(directory / "request_receipt.json", {
        "sha256": batch.sha(path), "count": len(selected),
        "reserved_nano_usd": sum(map(batch.liability, selected)),
    })
    uploaded = batch.upload(key, path)
    batch.save(directory / "upload.json", uploaded)
    provider = batch.api(key, "batches", {"input_file_id": uploaded["id"], "endpoint": batch.ENDPOINT,
                                          "completion_window": "24h"})
    batch.save(directory / "created.json", provider)
    check_batch(directory, provider)


def summary(rows):
    return dict(Counter(row["status"] for row in rows))


def freeze_domains(original, directory, rows, spent, reason):
    batch.save(directory / "frozen_domains.json", {
        "status": "domain_fusion_frozen", "stop_reason": reason,
        "protocol": receipt(original / "protocol.json"),
        "continuation": receipt(directory / "continuation.json"), "accounted_usd": spent / batch.NANO,
        "counts": summary(rows), "groups": rows,
    })


def checked_chain_nodes(segments):
    outcomes = {}
    for segment in segments:
        for key, result in checked_nodes(segment).items():
            if key in outcomes and batch.sha(result[0]) != batch.sha(outcomes[key][0]):
                raise ValueError("Duplicate node has different results")
            outcomes[key] = result
    return outcomes


def resume(original, directory, active_wave, history, checkpoints=()):
    protocol, responses, submitted, spent, evidence, active, reserved = history
    outcomes = checked_chain_nodes((original, *checkpoints))
    directory.mkdir(parents=True, exist_ok=False)
    (directory / "atomic").mkdir()
    for sid, entry in protocol["sources"].items():
        if entry["status"] == "ready":
            raw = (original / "atomic" / f"{sid}.json").read_bytes()
            if hashlib.sha256(raw).hexdigest() != entry["sha256"]:
                raise ValueError(f"Frozen source input changed: {sid}")
            (directory / "atomic" / f"{sid}.json").write_bytes(raw)
    batch.save(directory / "continuation.json", {
        "status": "registered_continuation", "registered_utc": datetime.now(timezone.utc).isoformat(),
        "original_protocol": receipt(original / "protocol.json"), "implementation": receipt(Path(__file__)),
        "prior_continuations": [receipt(checkpoint / "continuation.json") for checkpoint in checkpoints],
        "original_wave": active_wave, "original_waves": evidence, "reused_nodes": len(outcomes),
        "cap_usd": 100, "spent_at_checkpoint_usd": spent / batch.NANO,
        "held_for_active_batch_usd": reserved / batch.NANO, "already_submitted_requests": len(submitted),
        "method": "Existing Batch ID queried and downloaded, every historically submitted request ID "
                  "blocked from further submission, same pinned fusion kernel and USD cap.",
    })
    key = batch.helpers.credential(batch.ROOT / ".env")
    report = {"status": "reconnected_to_existing_batch", "wave": active_wave,
              "accounted_usd": spent / batch.NANO, "held_liability_usd": reserved / batch.NANO,
              "submitted_requests": len(submitted), "recovered_response_slots": len(responses)}

    def progress():
        atomic_progress(directory / "report.json", report)

    def heartbeat(status):
        report.update(provider_status=status["status"], provider_counts=status.get("request_counts"))
        progress()

    progress()
    recovered = directory / f"recovered_wave_{active_wave:04d}"
    recovered.mkdir(exist_ok=False)
    try:
        debit, recovered_terminal = settle_wave(active, recovered, key, responses, heartbeat)
    except Exception as error:
        report.update(status="recovery_incomplete", error=batch.safe_error(error))
        progress()
        raise
    spent += debit
    if responses.keys() != submitted or spent > protocol["cap_nano_usd"]:
        raise ValueError("Recovered request and spending ledger mismatch")
    report.update(status="resumed", recovered_terminal_status=recovered_terminal,
                  accounted_usd=spent / batch.NANO, held_liability_usd=0,
                  recovered_response_slots=len(responses))
    progress()
    runtime = batch.batch_runtime()
    wave = active_wave
    while True:
        outcomes = {k: v for k, v in outcomes.items() if v[1] != "awaiting_batch"}
        rows, pending = batch.node_frontier(directory, protocol, responses, outcomes, runtime)
        if submitted & pending.keys():
            raise ValueError("Duplicate request blocked")
        report.update(status="ready_for_batch", waves_accounted=wave, response_slots=len(responses),
                      submitted_requests=len(submitted), accounted_usd=spent / batch.NANO,
                      held_liability_usd=0, counts=summary(rows), rows=rows)
        if not pending:
            report["status"] = "fusion_terminal"
            freeze_domains(original, directory, rows, spent, "all_groups_accounted")
            break
        remaining = protocol["cap_nano_usd"] - spent
        selected = []
        for request in pending.values():
            cost = batch.liability(request)
            if cost <= remaining:
                selected.append(request)
                remaining -= cost
        if not selected:
            for row in rows:
                if row["status"] == "awaiting_batch":
                    row["status"] = "fusion_budget_limit"
            report.update(status="fusion_budget_exhausted_frozen", counts=summary(rows))
            freeze_domains(original, directory, rows, spent, "budget_cap_reached")
            break
        wave += 1
        reserved = sum(map(batch.liability, selected))
        submitted.update(request["custom_id"] for request in selected)
        report.update(status="submitting_new_batch", wave=wave, held_liability_usd=reserved / batch.NANO,
                      submitted_requests=len(submitted))
        progress()
        try:
            destination = directory / f"wave_{wave:04d}"
            submit_wave(destination, selected, key)
            report["status"] = "waiting_for_new_batch"
            debit, terminal = settle_wave(destination, destination, key, responses, heartbeat)
        except Exception as error:
            report.update(status="batch_state_unresolved", error=batch.safe_error(error))
            break
        spent += debit
        if responses.keys() != submitted or spent > protocol["cap_nano_usd"]:
            raise ValueError("Continuation request or spending ledger mismatch")
        if terminal in {"failed", "cancelled"}:
            report.update(status="batch_ended_without_completion", batch_terminal_status=terminal,
                          waves_accounted=wave, response_slots=len(responses), accounted_usd=spent / batch.NANO,
                          held_liability_usd=0)
            break
    progress()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("original", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--wave", type=int, default=21)
    parser.add_argument("--checkpoint", type=Path, action="append", default=[])
    parser.add_argument("--audit-only", action="store_true")
    args = parser.parse_args()
    history = load_history(args.original, args.wave, args.checkpoint)
    _, responses, submitted, spent, _, active, reserved = history
    if args.audit_only:
        print(json.dumps({"recovered_response_slots": len(responses), "submitted_requests": len(submitted),
                          "accounted_usd": spent / batch.NANO, "held_liability_usd": reserved / batch.NANO,
                          "reused_nodes": len(checked_chain_nodes((args.original, *args.checkpoint))),
                          "existing_batch_id": batch.read(active / "created.json")["id"]}))
    else:
        resume(args.original, args.output, args.wave, history, args.checkpoint)

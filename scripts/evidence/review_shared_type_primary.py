"""Verify completed primary receipts and report the manual-pause condition."""
import argparse
from copy import deepcopy
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
from pathlib import Path
import sys


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def read(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def write(path, data):
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def run(primary, continuation, output):
    primary, continuation, output = primary.resolve(), continuation.resolve(), output.resolve()
    output.mkdir(exist_ok=False)
    write(output / "status.json", {"status": "checking_receipts"})
    raw_path, manifest_path = primary / "report.json", continuation / "continuation_manifest.json"
    raw, manifest = read(raw_path), read(manifest_path)
    if raw["status"] != "complete_shared_type_rerun" or not raw["inputs_unchanged"]:
        raise ValueError("Primary experiment is not complete")
    if sha(primary / "protocol.json") != raw["protocol_sha256"]:
        raise ValueError("Primary protocol changed")
    if sha(manifest["pause_receipt"]) != manifest["pause_receipt_sha256"]:
        raise ValueError("Pause receipt changed")
    if read(continuation / "resume_receipt.json")["status"] != "resumed":
        raise ValueError("No successful resume receipt")
    protocol = read(primary / "protocol.json")
    expected_ids = set()
    for task in read(protocol["registry"]):
        if task["kind"] == "composition":
            expected_ids.add(task["id"])
        else:
            if task["reference_status"] == "available":
                expected_ids.add(task["id"] + "__reference")
            if task["search_anchor"]:
                expected_ids.add(task["id"] + "__goal")
    rows = raw["rows"]
    if len(rows) != 11362 or len({r["id"] for r in rows}) != len(rows) or {r["id"] for r in rows} != expected_ids:
        raise ValueError("Registry or denominator mismatch")
    before = manifest["completed_result_sha256"]
    found_before = set()
    plans = {}
    for i, row in enumerate(rows, 1):
        receipt = primary / "runs" / row["kind"] / row["id"] / "result.json"
        content = receipt.read_bytes()
        if json.loads(content) != row:
            raise ValueError("Receipt and final report differ: " + row["id"])
        key = str(receipt)
        if key in before:
            if hashlib.sha256(content).hexdigest() != before[key]:
                raise ValueError("Pre-pause receipt changed: " + key)
            found_before.add(key)
        if row.get("plan_sha256"):
            plan = row["plan"]
            if plan not in plans:
                plans[plan] = sha(plan)
            if plans[plan] != row["plan_sha256"]:
                raise ValueError("Saved plan changed: " + plan)
        if i % 1000 == 0:
            write(output / "status.json", {"status": "checking_receipts", "checked": i, "registered": len(rows)})
    if found_before != set(before):
        raise ValueError("Missing pre-pause receipts")
    spec = importlib.util.spec_from_file_location("frozen_pause_review", continuation / "review.py")
    helper = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(helper)
    interrupted = {row["id"] for row in manifest["in_flight_at_resume"]}
    reviewed = helper.reviewed_rows(rows, interrupted)
    sys.path.insert(0, str(primary / "code"))
    from scripts.experiments.run_shared_type_tables import summarize, table_metrics
    if summarize(rows) != raw["summary"] or table_metrics(rows) != raw["tables"]:
        raise ValueError("Raw summaries do not match rows")
    report = {**deepcopy(raw), "status": "complete_shared_type_primary_pause_review",
              "condition": manifest["condition"], "source_report_sha256": sha(raw_path),
              "continuation_manifest_sha256": sha(manifest_path),
              "completed_result_hashes_unchanged": True, "receipt_report_equality": True,
              "verified_plan_files": len(plans), "saved_results_before_resume": len(before),
              "pause_affected_task_ids": sorted(interrupted), "scope": manifest["treatment"],
              "summary": summarize(reviewed), "tables": table_metrics(reviewed), "rows": reviewed}
    write(output / "report.json", report)
    write(output / "tables_2_3_4_primary.json", report["tables"])
    index = {"reports": {"shared_type_primary": {
        "path": str(output / "report.json"), "sha256": sha(output / "report.json"),
        "terminal_status": report["status"], "denominator": "registered",
        "required_true": ["inputs_unchanged", "completed_result_hashes_unchanged", "receipt_report_equality"],
        "metrics": ["registered", "summary", "tables", "pause_affected_task_ids", "verified_plan_files"],
        "scope": manifest["treatment"]}},
        "excluded_pending": {"official_unidomain": "Matched physical follow-up had not started when this primary-only review was prepared."}}
    write(output / "evidence_index.json", index)
    write(output / "status.json", {"status": "ready_for_inventory_verification", "registered": len(rows),
                                   "pause_affected_rows": len(interrupted), "verified_plan_files": len(plans),
                                   "finished_at": datetime.now(timezone.utc).isoformat()})
    print(json.dumps({"status": "ready_for_inventory_verification", "summary": report["summary"]}), flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--primary", type=Path, required=True)
    parser.add_argument("--continuation", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    run(args.primary, args.continuation, args.output)

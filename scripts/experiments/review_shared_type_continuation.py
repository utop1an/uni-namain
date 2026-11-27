"""Label a manually suspended campaign without changing frozen experiment code."""
import argparse
from copy import deepcopy
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import sys
import time


def read(path):
    return Path(path).read_text(encoding="utf-8")


def load(path):
    return json.loads(read(path))


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def save(path, value):
    temp = path.with_suffix(".tmp")
    temp.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")
    temp.replace(path)


def reviewed_rows(raw_rows, interrupted_ids):
    rows = deepcopy(raw_rows)
    if not interrupted_ids <= {row["id"] for row in rows}:
        raise ValueError("Interrupted tasks are missing from the completed registry")
    for row in rows:
        if row["id"] not in interrupted_ids:
            continue
        row["outcome_after_resume"] = {
            key: deepcopy(row[key]) for key in
            ("status", "native_pass", "physical_pass", "dual_pass", "search", "native", "physical", "attribution")
            if key in row
        }
        row.update(status="interrupted_by_manual_pause", native_pass=False,
                   physical_pass=False, dual_pass=False,
                   budget_interpretation="Unknown: in progress during user-requested process suspension; retained in denominator.")
        # Preserve the raw evidence above; it is not an uninterrupted-budget result.
        for key in ("search", "native", "physical", "attribution"):
            row.pop(key, None)
    return rows


def run(output):
    output = output.resolve()
    manifest_path = output / "continuation_manifest.json"
    manifest = load(manifest_path)
    manifest_hash = digest(manifest_path)
    primary, official = Path(manifest["primary"]), Path(manifest["official"])
    status_path = output / "status.json"
    with (output / "review_started.json").open("x", encoding="utf-8") as f:
        json.dump({"started_at": datetime.now(timezone.utc).isoformat(),
                   "implementation_sha256": digest(Path(__file__))}, f)
    save(status_path, {"status": "waiting_for_campaign", "condition": manifest["condition"]})
    while True:
        campaign = load(primary / "campaign.json")
        if campaign["status"] == "failed":
            raise RuntimeError("Underlying campaign failed; partial results retained")
        post = primary / "postprocess_status.json"
        if post.exists():
            state = load(post)
            if state["status"] == "complete":
                break
            if state["status"].startswith("blocked"):
                raise RuntimeError("Underlying finalization blocked: " + state["status"])
        time.sleep(15)
    save(status_path, {"status": "verifying_completed_receipts", "condition": manifest["condition"]})
    for path, expected in manifest["completed_result_sha256"].items():
        if digest(path) != expected:
            raise ValueError("Pre-pause receipt changed: " + path)
    if digest(manifest["pause_receipt"]) != manifest["pause_receipt_sha256"]:
        raise ValueError("Pause receipt changed")
    if digest(manifest_path) != manifest_hash:
        raise ValueError("Continuation manifest changed")
    resume_path = output / "resume_receipt.json"
    if load(resume_path)["status"] != "resumed":
        raise ValueError("Resumption was not completed")
    sys.path.insert(0, str(primary / "code"))
    from scripts.experiments.run_shared_type_tables import summarize, table_metrics
    from scripts.evidence.build_paper_results import build
    raw_path = primary / "report.json"
    raw = load(raw_path)
    if raw["registered"] != manifest["registered"] or not raw["inputs_unchanged"]:
        raise ValueError("Registered denominator or frozen inputs changed")
    ids = {row["id"] for row in manifest["in_flight_at_resume"]}
    rows = reviewed_rows(raw["rows"], ids)
    if len(rows) != manifest["registered"] or len({r["id"] for r in rows}) != len(rows):
        raise ValueError("Incomplete registry")
    tables = table_metrics(rows)
    tables["official_unidomain"] = load(primary / "tables_2_3_4_reviewed.json")["official_unidomain"]
    report = {**raw, "status": "complete_shared_type_continuation_after_manual_pause",
              "condition": manifest["condition"], "source_report_sha256": digest(raw_path),
              "manifest_sha256": manifest_hash, "resume_receipt_sha256": digest(resume_path),
              "saved_results_before_resume": manifest["saved_results_before_resume"],
              "completed_result_hashes_unchanged": True, "pause_affected_task_ids": sorted(ids),
              "scope": manifest["treatment"], "rows": rows, "summary": summarize(rows), "tables": tables}
    save(output / "report.json", report)
    save(output / "tables_2_3_4.json", tables)
    official_report = official / "interface_review_v1/report.json"
    index = {"reports": {
        "shared_type_continuation": {
            "path": str(output / "report.json"), "sha256": digest(output / "report.json"),
            "terminal_status": report["status"], "metrics": ["registered", "summary", "tables", "pause_affected_task_ids"],
            "scope": manifest["treatment"]},
        "official_matched_physical": {
            "path": str(official_report), "sha256": digest(official_report),
            "terminal_status": load(official_report)["status"], "metrics": ["registered", "counts", "matched_composition"],
            "scope": "Separate fresh physical matched stage started after resumption; no intentional-validity claim."}},
        "excluded_pending": {}}
    save(output / "evidence_index.json", index)
    build(output / "evidence_index.json", output / "verified_inventory")
    verified = load(output / "verified_inventory/results.json")
    if verified["status"] != "verified_snapshot":
        raise ValueError("Continuation evidence inventory did not verify")
    save(status_path, {"status": "complete", "condition": manifest["condition"],
                      "finished_at": datetime.now(timezone.utc).isoformat(),
                      "pause_affected_rows": len(ids), "verified_status": verified["status"]})


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    try:
        run(args.output)
    except Exception as exc:
        save(args.output / "status.json", {"status": "failed", "error": type(exc).__name__ + ": " + str(exc)})
        raise

"""Verify the terminal Table 4 rerun and publish a guarded manuscript update."""
import argparse
from collections import Counter
from pathlib import Path
import re

from scripts.evidence.build_paper_results import build
from scripts.experiments.run_table4_goal_rerun import check_inputs, read, sha, write


def replace_once(text, pattern, replacement, *, flags=0):
    updated, count = re.subn(pattern, lambda _: replacement, text, flags=flags)
    if count != 1:
        raise ValueError(f"Expected one manuscript match for {pattern!r}, found {count}")
    return updated


def finalize(output, manuscript, expected_manuscript_hash):
    report_path = output / "report.json"
    protocol_path = output / "protocol.json"
    report = read(report_path)
    protocol = read(protocol_path)
    if (report["status"] != "complete_table4_original_goal_rerun"
            or report["registered"] != 4800 or protocol["registered_pairs"] != 2400
            or report["protocol_sha256"] != sha(protocol_path)):
        raise ValueError("Missing or incompatible terminal report")
    check_inputs(protocol["input_sha256"])
    rows = {row["id"]: row for row in report["rows"]}
    totals = Counter({"union": 0, "full": 0})
    outcomes = Counter()
    for index, pair in enumerate(protocol["pairs"]):
        flags = []
        for arm in ("union", "full"):
            task = pair[arm]
            row = rows.pop(task["id"])
            folder = output / "runs" / f"{index:04d}" / arm
            if read(folder / "result.json") != row or any(row[k] != v for k, v in task.items()):
                raise ValueError(f"Invalid receipt: {task['id']}")
            if row["dual_pass"]:
                native, physical = row["native"], row["physical"]
                if (row["search"]["status"] != "solved" or native["status"] != "replayed"
                        or physical["status"] != "replayed" or native["goal"] is not True
                        or physical["goal"] is not True or native["unexplained_steps"] != 0
                        or native["steps"] != physical["steps"]
                        or sha(folder / row["attempt"] / "plan.pddl") != row["plan_sha256"]):
                    raise ValueError(f"Invalid dual-validation pass: {task['id']}")
                totals[arm] += 1
            flags.append(int(row["dual_pass"]))
        outcomes[f"{flags[0]}->{flags[1]}"] += 1
    if rows or dict(totals) != report["summary"]["dual_pass"] or dict(outcomes) != report["summary"]["paired_dual_pass"]:
        raise ValueError("Final outcomes do not reconcile with the report")
    index_path = output / "evidence_index.json"
    write(index_path, {"reports": {"table4_original_goal_search": {
        "path": report_path.as_posix(), "sha256": sha(report_path),
        "terminal_status": report["status"], "scope": "Fresh, equal-budget Table 4 original-goal search",
        "required_true": ["inputs_unchanged"], "denominator": "registered",
        "metrics": ["registered", "summary", "protocol_sha256"],
    }}, "excluded_pending": {}})
    build(index_path, output / "verified_inventory")
    if sha(manuscript) != expected_manuscript_hash:
        write(output / "publication.json", {"status": "manuscript_changed", "dual_pass": dict(totals)})
        return
    original = manuscript.read_bytes().decode("utf-8")
    updated = render(original, totals)
    snapshot = output / "AnonymousSubmission2027.tex"
    snapshot.write_bytes(updated.encode("utf-8"))
    if sha(manuscript) != expected_manuscript_hash:
        write(output / "publication.json", {"status": "manuscript_changed", "dual_pass": dict(totals)})
        return
    temporary = manuscript.with_suffix(".table4.tmp")
    temporary.write_bytes(snapshot.read_bytes())
    temporary.replace(manuscript)
    write(output / "publication.json", {"status": "manuscript_updated", "dual_pass": dict(totals),
                                       "manuscript_sha256": sha(manuscript), "report_sha256": sha(report_path)})


def render(original, totals):
    newline = "\r\n" if "\r\n" in original else "\n"
    original = original.replace("\r\n", "\n")
    union, full = (f"{totals[arm]:,}" for arm in ("union", "full"))
    updated = replace_once(original, r"^Original-goal search \(dual\) & 2,400 & [\d,]+ & [\d,]+\\\\$",
                           rf"Original-goal search (dual) & 2,400 & {union} & {full}\\", flags=re.M)
    updated = replace_once(updated, r"Original-goal search covers 2,400 registered queries from 136 distinct source problems\..*?(?= For context, archived source searches)",
                           f"Original-goal search covers 2,400 registered queries from 136 distinct source problems. "
                           f"Union returns {union} dual-validated plans and NarraFuse returns {full}.")
    updated = replace_once(updated, r"These timeouts show why plan preservation.*?The supplement separates grounding and search costs\.\n\n", "")
    updated = replace_once(updated, r" Under the reported budget, Union solves six original-goal queries that time out in NarraFuse\.", "")
    updated = replace_once(updated, r"(?=\nEach initial Glaive search or replay)",
                           "\nFor the original-goal search row in Table~\\ref{tab:priority1-preservation}, each "
                           "model receives one fresh 60-second search per query, using the original Glaive runtime "
                           "with three workers and a 4\\,GiB Java heap per process. Returned plans receive up to "
                           "60 seconds for Glaive replay and are checked independently for physical validity.\n\n"
                           "In the historical campaign,")
    updated = updated.replace("In the historical campaign,\nEach initial", "In the historical campaign, each initial")
    updated = replace_once(updated, r"Across the 2,400 original-goal queries, 1,148 pass in both models",
                           "In the historical campaign, 1,148 original-goal queries pass in both models")
    return updated.replace("\n", newline)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--manuscript", type=Path, required=True)
    parser.add_argument("--expected-manuscript-hash", required=True)
    args = parser.parse_args()
    finalize(args.output, args.manuscript, args.expected_manuscript_hash)

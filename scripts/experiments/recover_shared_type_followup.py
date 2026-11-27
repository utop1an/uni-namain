"""Run a never-started physical follow-up after a completed primary campaign."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys


def read(path):
    return json.loads(path.read_text(encoding="utf-8"))


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(path, data):
    tmp = path.with_suffix(".tmp")
    tmp.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    tmp.replace(path)


def main(output):
    output = output.resolve()
    config = read(output / "config.json")
    root, primary, official, continuation = [Path(config[k]) for k in ("repository", "primary", "official", "continuation")]
    os.environ["NARRAFUSE_REPO"] = str(root)
    os.environ["TEMP"] = os.environ["TMP"] = str(root / ".tmp")
    report = read(primary / "report.json")
    if report["status"] != "complete_shared_type_rerun" or report["registered"] != 11362 or not report["inputs_unchanged"]:
        raise ValueError("Primary experiment is not complete")
    if (official / "started.json").exists() or (official / "report.json").exists():
        raise ValueError("Follow-up already started: no implicit cache continuation")
    for path, expected in config["input_sha256"].items():
        if sha(Path(path)) != expected:
            raise ValueError("Pinned recovery input changed: " + path)
    state_path = output / "campaign.json"
    with state_path.open("x", encoding="utf-8") as f:
        state = {"status": "running", "pid": os.getpid(), "started_at": datetime.now(timezone.utc).isoformat(),
                 "condition": "completed_primary_with_manual_pause_then_fresh_physical_followup",
                 "primary_report_sha256": sha(primary / "report.json"), "stages": []}
        json.dump(state, f)
    python = root / ".venv/Scripts/python.exe"
    stages = [
        ("official_physical", [str(python), "-X", "utf8", "-m", "scripts.experiments.run_shared_type_official_followup", "run", "--output", str(official)], official / "code"),
        ("finalization", [str(python), "-X", "utf8", str(output / "finalizer.py"), "--primary", str(primary), "--official", str(official), "--archive", config["archive"], "--campaign-state", str(output / "search_stages_complete.json")], root),
        ("continuation_review", [str(python), "-X", "utf8", str(continuation / "review.py"), "--output", str(continuation)], root),
    ]
    for name, command, cwd in stages:
        stage = {"name": name, "status": "running", "command": command, "started_at": datetime.now(timezone.utc).isoformat()}
        state["stages"].append(stage)
        save(state_path, state)
        with (output / (name + "_stdout.log")).open("xb") as stdout, (output / (name + "_stderr.log")).open("xb") as stderr:
            child = subprocess.Popen(command, cwd=cwd, stdout=stdout, stderr=stderr,
                                     creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
            stage["pid"] = child.pid
            save(state_path, state)
            code = child.wait()
        stage.update(status="complete" if code == 0 else "failed", returncode=code, finished_at=datetime.now(timezone.utc).isoformat())
        if code:
            state["status"] = "failed"
            save(state_path, state)
            raise SystemExit(code)
        if name == "official_physical":
            save(output / "search_stages_complete.json", {"status": "complete", "scope": "Primary report already complete; fresh official follow-up now complete."})
        save(state_path, state)
    state.update(status="complete", finished_at=datetime.now(timezone.utc).isoformat())
    save(state_path, state)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    main(args.output)

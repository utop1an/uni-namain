"""Sequential follow-ups after the 60-case run: selection, re-audit, replay."""
import argparse
import json
from pathlib import Path

from rcnc.domain_building import require_empty_output, save
from scripts.audit.audit_action_reachability import run as audit_traces
from scripts.experiments.prepare_meeting_selection import prepare
from scripts.experiments.replay_action_reachability import run as replay_traces
from scripts.experiments.run_downward_reference import run as solve, sha


def run(matched, output, planner):
    baseline = json.loads((matched / 'report.json').read_text(encoding='utf-8'))
    if baseline['status'] != 'complete':
        raise ValueError('Finish the original 60-case run first; avoid competing workloads')
    require_empty_output(output)
    output.mkdir(parents=True, exist_ok=True)
    report = {'status': 'running', 'stage': 'preparing_selection',
              'baseline_report_sha256': sha(matched / 'report.json'),
              'scope': 'Exploratory selected-domain condition plus new replay of historical traces; no new model calls'}
    save(output / 'report.json', report)
    selection = output / 'selection'
    prepare(matched, selection)
    report['stage'] = 'selection_solver'
    save(output / 'report.json', report)
    solve(matched / 'inputs', None, selection / 'solver', planner, 20, 4096,
          task_bundle=selection / 'bundle')
    report['stage'] = 'fresh_instrumentation_reaudit'
    save(output / 'report.json', report)
    bundle = Path('data/validation/source_action_reachability_tasks_2026_10_15_v1')
    solved = Path('data/validation/downward_action_reachability_2026_10_15_v1')
    audit = output / 'trace_audit'
    audit_traces(bundle, solved, audit)
    report['stage'] = 'machine_interface_trace_replay'
    save(output / 'report.json', report)
    replay = output / 'machine_replay'
    replay_traces(bundle, solved, audit, matched / 'models/machine_interfaces', replay)
    report.update(status='complete', stage='complete',
        selection_report_sha256=sha(selection / 'solver/report.json'),
        fresh_audit_sha256=sha(audit / 'report.json'), replay_report_sha256=sha(replay / 'report.json'))
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--matched', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--planner', type=Path, default=Path('.tmp/fast-downward-26.6'))
    args = parser.parse_args()
    print(json.dumps(run(args.matched, args.output, args.planner), indent=2))

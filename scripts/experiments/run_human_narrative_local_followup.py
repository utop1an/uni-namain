"""Local-only followup after a terminal model-stage failure; never sends requests."""
import argparse
from pathlib import Path
import shutil
import traceback

from rcnc.domain_building import digest, save, snapshot_implementation
from scripts.experiments import run_revised_multistory as base


def run(parent, root):
    protocol = base.verify(parent)
    if base.read(parent/'coordinator.json')['status'] != 'stopped_model_stage_incomplete':
        raise ValueError('Expected terminal incomplete model stage')
    if root.exists():
        raise ValueError('Fresh diagnostic directory required')
    root.mkdir(parents=True)
    repeat = root/'repeat_01'
    shutil.copyfile(parent/'selected_groups.json', root/'selected_groups.json')
    shutil.copyfile(parent/'selected_candidates.json', root/'selected_candidates.json')
    shutil.copytree(parent/'repeat_01/judgments', repeat/'judgments')
    protocol.update(status='frozen_before_local_only_followup', created_utc=base.now(),
        parent=str(parent), condition='local_only_followup_using_incomplete_single_model_round',
        repeats=[{'id': 'repeat_01', 'path': str(repeat)}], new_model_calls=0)
    protocol['policy'] = ['Separate diagnostic, not completion within the stopped parent protocol.',
        'No model requests or retries. All 28 parent candidate outcomes retained; invalid/failed judgments cannot merge.',
        'Same groups, source worlds, thresholds, search/replay budgets and anchors as parent.']
    protocol['input_sha256'].update({str(p): digest(p) for p in root.rglob('*') if p.is_file()})
    protocol['input_sha256'].update({str(parent/n): digest(parent/n) for n in ['protocol.json', 'report.json', 'repeat_01/judgments/report.json', 'repeat_01/judgments/groups.json']})
    protocol['implementation_sha256'].update(snapshot_implementation(root, [Path(__file__)]))
    save(root/'protocol.json', protocol)
    (root/'PROTOCOL.sha256').write_text(digest(root/'protocol.json')+'  protocol.json\n', encoding='utf-8')
    state_path = root/'coordinator.json'
    state = {'status': 'running', 'stage': 'compilation', 'new_model_calls': 0, 'started_utc': base.now()}
    save(state_path, state)
    try:
        state['compilation'] = base.compile_models(root, repeat)
        state['stage'] = 'execution'
        save(state_path, state)
        summary = base.execute(root, repeat, state, state_path)
        state.update(status='complete', stage='complete', result=summary)
        save(root/'report.json', {'status': 'complete', 'condition': protocol['condition'],
             'parent': str(parent), 'new_model_calls': 0, 'result': summary})
    except Exception as exc:
        state.update(status='failed', error=str(exc), traceback=traceback.format_exc())
        raise
    finally:
        state['ended_utc'] = base.now()
        save(state_path, state)
    return state


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--parent', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    print(run(args.parent.resolve(), args.output.resolve()))

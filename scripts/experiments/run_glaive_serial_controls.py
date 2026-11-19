"""Fresh single-worker controls on the six already registered profile medians.

This separately labeled condition checks initialization performance with less
shared-memory contention. It neither replaces nor retries the 355-pair run.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
import time


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    sys.modules[name] = result
    spec.loader.exec_module(result)
    return result


def execute(root, parent, selection_path):
    e = module('_glaive_executor', parent/'executor.py')
    isolation = e.isolation()
    if root.exists():
        raise ValueError('Fresh serial control directory required')
    print(json.dumps({'status': 'waiting_for_parent_completion', 'parent': str(parent), 'model_requests': 0}), flush=True)
    while True:
        try:
            parent_report = e.read(parent/'report.json')
            break
        except (FileNotFoundError, json.JSONDecodeError):
            time.sleep(5)
    if parent_report['status'] != 'complete_paired_timeout_comparison' or not parent_report['inputs_unchanged']:
        raise ValueError('Parent comparison did not complete with unchanged inputs')
    p = e.read(parent/'protocol.json')
    selection = e.read(selection_path)
    ids = {(c['kind'], c['id']) for c in selection['probes']}
    assert len(ids) == 6
    pairs = [pair for pair in p['pairs'] if (pair['task']['kind'], pair['task']['id']) in ids]
    assert len(pairs) == 6
    files = dict(p['input_sha256'])
    for path in (parent/'report.json', parent/'protocol.json', selection_path):
        files[str(path)] = e.sha(path)
    for path, h in files.items():
        if e.sha(path) != h:
            raise ValueError('Frozen input changed: '+str(path))
    root.mkdir(parents=True, exist_ok=False)
    for source, name in ((Path(__file__), 'driver.py'), (parent/'driver.py', 'pairs.py'), (parent/'executor.py', 'executor.py')):
        dest = root/name
        dest.write_bytes(source.read_bytes())
        files[str(dest)] = e.sha(dest)
    protocol = {'status': 'frozen_before_serial_controls', 'created_utc': e.now(), 'pairs': pairs,
                'registered_pairs': 6, 'workers': 1, 'seconds_per_search_or_replay': 60, 'worker_seconds': 180,
                'memory_mb': 4096, 'jars': p['jars'], 'input_sha256': files, 'model_requests': 0,
                'selection': 'Exactly the six stratum medians frozen before the first profiles; no selection using paired outcomes.',
                'scope': 'Separate fresh serial diagnostic condition, not a replacement or continuation of the 355-pair experiment.',
                'reason': 'The 16 GB host recorded kernel OOM kills during the registered eight-worker condition. Check representative effects with one Java invocation at a time.',
                'policies': ['Both jars execute each task afresh with the same 60 second limit and 4096 MB heap.',
                             'Original task, plan and mapping bytes and frozen native/physical validators remain unchanged.',
                             'No additional retries, cached outcomes, model requests or network access.']}
    e.write(root/'protocol.json', protocol)
    (root/'PROTOCOL.sha256').write_text(e.sha(root/'protocol.json')+'\n', encoding='utf-8')
    e.write(root/'execution_start.json', {'started_utc': e.now(), 'isolation': isolation,
                                        'meminfo': Path('/proc/meminfo').read_text()})
    helpers = module('_glaive_pairs', root/'pairs.py')
    e.initialize(p['jars']['before'])
    started = time.monotonic()
    rows = []
    with (root/'pair_events.jsonl').open('x', encoding='utf-8') as stream:
        for pair in pairs:
            row = {'kind': pair['task']['kind'], 'id': pair['task']['id'], 'last_phase': pair['last_phase'],
                   'historical': pair['historical'], 'arm_order': pair['arm_order']}
            for arm in pair['arm_order']:
                e.JAR = e.local(p['jars'][arm])
                job = helpers.make_job(root, pair, arm)
                job['condition'] = 'initialization_serial_control_'+arm
                row[arm] = e.one(job)
                e.write(root/arm/'completed'/row['kind']/(row['id']+'.json'), row[arm])
            rows.append(row)
            stream.write(json.dumps(row, ensure_ascii=False)+'\n')
            stream.flush()
            e.progress(root, status='running', completed_pairs=len(rows), registered_pairs=6, elapsed_seconds=time.monotonic()-started)
            print(json.dumps({'serial_pairs_completed': len(rows), 'registered_pairs': 6,
                              'seconds': round(time.monotonic()-started, 2)}), flush=True)
    elapsed = time.monotonic()-started
    unchanged = all(e.sha(path) == h for path, h in files.items())
    report = {'status': 'complete_serial_timeout_controls' if unchanged and len(rows) == 6 else 'failed',
              'registered_pairs': 6, 'completed_pairs': len(rows), 'workers': 1,
              'wall_seconds_both_arms': elapsed, 'inputs_unchanged': unchanged, 'model_requests': 0,
              'comparison': helpers.compare(rows), 'rows': rows,
              'limitations': protocol['policies']+[protocol['scope'], protocol['selection']]}
    e.write(root/'report.json', report)
    e.progress(root, status=report['status'], completed_pairs=len(rows), registered_pairs=6, elapsed_seconds=elapsed)
    print(json.dumps({k: v for k, v in report.items() if k not in ('rows', 'limitations')}), flush=True)


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--parent', type=Path, required=True)
    p.add_argument('--selection', type=Path, required=True)
    a = p.parse_args()
    execute(a.output.resolve(), a.parent.resolve(), a.selection.resolve())

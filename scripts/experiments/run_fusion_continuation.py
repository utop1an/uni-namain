"""Separately budgeted cache continuation of a terminal fresh-run time limit.

Never changes the predecessor result or relabels continuation as fresh success.
The existing model, implementation, inputs and decoding options must match.
"""
import argparse
from datetime import datetime, timezone
import json
import math
import os
from pathlib import Path
import subprocess
import sys
import time
import urllib.request

from rcnc.domain_building import snapshot_implementation
from scripts.experiments.run_fusion_reference import freeze as freeze_fresh, save, sha, ROOT


def matches(path, digest):
    try:
        return path.is_file() and sha(path) == digest
    except OSError:
        return False


def freeze(predecessor, output, seconds=10800, stop_before=None):
    if type(seconds) not in (int, float) or not math.isfinite(seconds) or seconds <= 0:
        raise ValueError('Invalid continuation worker budget')
    if stop_before is not None:
        deadline = datetime.fromisoformat(stop_before.replace('Z', '+00:00'))
        if deadline.tzinfo is None:
            raise ValueError('Overall stop time requires an explicit timezone')
        available = int((deadline - datetime.now(timezone.utc)).total_seconds()) - 600
        seconds = min(seconds, available)
        if seconds <= 0:
            raise ValueError('No continuation budget remains before overall stop time')
    original = json.loads((predecessor / 'manifest.json').read_text(encoding='utf-8'))
    terminal = json.loads((predecessor / 'report.json').read_text(encoding='utf-8'))
    if original.get('http_attempt_ledger') is not None:
        raise ValueError('Attempt-recorded predecessors require a separately implemented continuation accounting protocol')
    if original['status'] != 'time_limit' or terminal['status'] != 'time_limit':
        raise ValueError('Only an inspected terminal fresh time limit is eligible; active/error/complete runs are not restarted')
    if original.get('condition', 'fresh') != 'fresh' or original.get('cache_policy') != 'new empty per-run cache; no historical answers imported':
        raise ValueError('Predecessor must be a fresh condition, not another continuation')
    if not terminal['source_snapshot_unchanged'] or not terminal['implementation_unchanged']:
        raise ValueError('Predecessor integrity failed')
    if not original.get('model_digest'):
        raise ValueError('Predecessor has no fixed model digest')
    for name, digest in original['source_sha256'].items():
        if sha(predecessor / 'inputs' / name) != digest:
            raise ValueError('Predecessor input drift')
    for name, digest in original['implementation_sha256'].items():
        if sha(ROOT / name) != digest:
            raise ValueError('Continuation would change the frozen fusion implementation')
    files = sorted(path for path in (predecessor / 'cache').rglob('*') if path.is_file())
    cached = {path.relative_to(predecessor / 'cache').as_posix(): sha(path) for path in files}
    response_count = sum(name.startswith('ollama/') and name.endswith('.json') for name in cached)
    if not response_count:
        raise ValueError('No cached model responses to continue')
    manifest = freeze_fresh(predecessor / 'inputs', output, seconds, original['node_workers'], original['model'],
                            original.get('namespace_policy', 'raw'))
    if manifest['dependencies'] != original['dependencies'] or manifest['inference_options'] != original['inference_options']:
        raise ValueError('Continuation dependency/decoding condition changed')
    for name, digest in cached.items():
        source = predecessor / 'cache' / name
        destination = output / 'cache' / name
        destination.parent.mkdir(parents=True, exist_ok=True)
        content = source.read_bytes()
        destination.write_bytes(content)
        if sha(destination) != digest:
            raise ValueError('Cache changed while importing')
    manifest['implementation_sha256'].update(snapshot_implementation(output,
        [Path(__file__), ROOT / 'rcnc/domain_building.py'], root=ROOT))
    archived = output / 'predecessor'
    archived.mkdir()
    for name in ('manifest.json', 'report.json', 'command.json'):
        (archived / name).write_bytes((predecessor / name).read_bytes())
    save(output / 'imported_cache_index.json', cached)
    manifest.update(condition='cache_continuation_extended_budget',
        cache_policy='Copied terminal predecessor cache; no predecessor result overwritten; not a fresh condition',
        predecessor=str(predecessor), predecessor_manifest_sha256=sha(archived / 'manifest.json'),
        predecessor_report_sha256=sha(archived / 'report.json'), predecessor_model_digest=original['model_digest'],
        predecessor_registered_worker_budget_seconds=original['budget_seconds'],
        predecessor_observed_elapsed_seconds=terminal['elapsed_seconds'],
        cumulative_registered_worker_budget_seconds=original['budget_seconds'] + seconds,
        imported_cache_index_sha256=sha(output / 'imported_cache_index.json'),
        imported_response_count=response_count, overall_stop_before_utc=stop_before,
        resume_policy='Rerun the complete fusion tree; reuse only exact-request response-cache hits. No process checkpoint or in-memory embedding state is resumed.',
        scope='Separately budgeted cached continuation of a terminal fresh time limit. Root completion, if any, belongs to the extended-budget condition only.')
    save(output / 'manifest.json', manifest)
    return manifest


def run(predecessor, output, seconds=10800, stop_before=None):
    manifest = freeze(predecessor, output, seconds, stop_before)
    start = time.monotonic()
    report = {'status': 'starting', 'condition': manifest['condition']}
    save(output / 'report.json', report)
    try:
        with urllib.request.urlopen('http://127.0.0.1:11434/api/tags', timeout=10) as stream:
            tags = json.load(stream)
        model = manifest['model']
        installed = next((item for item in tags.get('models', []) if item['name'] == model), None)
        if installed is None or installed.get('remote_host') or installed.get('remote_model') or 'cloud' in model:
            raise ValueError('Only the already installed local predecessor model is permitted')
        if installed['digest'] != manifest['predecessor_model_digest']:
            raise ValueError('Model digest changed since predecessor')
        manifest.update(status='running', model_digest=installed['digest'])
        save(output / 'manifest.json', manifest)
        previous = json.loads((output / 'predecessor/command.json').read_text(encoding='utf-8'))
        overrides = previous['environment_overrides']
        if overrides.get('HF_HUB_OFFLINE') != '1' or overrides.get('TRANSFORMERS_OFFLINE') != '1':
            raise ValueError('Continuation requires the offline embedding environment')
        environment = {**os.environ, **overrides}
        command = [sys.executable, '-m', 'unidomain',
            '--input', str((output / 'inputs').resolve()), '--output', str((output / 'fusion').resolve()),
            '--cache-dir', str((output / 'cache').resolve()), '--model', model,
            '--num-workers', str(manifest['node_workers']), '--predicate-threshold', '0.3', '--operator-threshold', '0.3',
            '--namespace-policy', manifest.get('namespace_policy', 'raw')]
        save(output / 'command.json', {'argv': command, 'environment_overrides': overrides})
        with (output / 'worker.log').open('w', encoding='utf-8') as log:
            process = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT,
                                     timeout=manifest['budget_seconds'], env=environment, cwd=ROOT)
        report.update(status='complete' if process.returncode == 0 else 'worker_error', returncode=process.returncode)
        validation = output / 'fusion/validation.json'
        if validation.is_file():
            report['validation'] = json.loads(validation.read_text(encoding='utf-8'))
        if process.returncode == 0 and not report.get('validation', {}).get('valid'):
            report['status'] = 'missing_or_invalid_final_validation'
    except subprocess.TimeoutExpired:
        report['status'] = 'time_limit'
    except Exception as exc:
        report.update(status='error', error=f'{type(exc).__name__}: {exc}')
    imported = json.loads((output / 'imported_cache_index.json').read_text(encoding='utf-8'))
    elapsed = round(time.monotonic() - start, 3)
    report.update(elapsed_seconds=elapsed, finished_utc=datetime.now(timezone.utc).isoformat(),
        source_snapshot_unchanged=all(matches(output / 'inputs' / p, h) for p, h in manifest['source_sha256'].items()),
        implementation_unchanged=all(matches(ROOT / p, h) for p, h in manifest['implementation_sha256'].items()),
        imported_cache_unchanged=all(matches(output / 'cache' / p, h) for p, h in imported.items()),
        predecessor_cache_unchanged=all(matches(predecessor / 'cache' / p, h) for p, h in imported.items()),
        predecessor_report_unchanged=matches(predecessor / 'report.json', manifest['predecessor_report_sha256']),
        imported_response_count=manifest['imported_response_count'],
        cached_responses=len(list((output / 'cache/ollama').glob('*.json'))),
        completed_fusion_nodes=len(list((output / 'fusion/domain_fusion').glob('*/meta_domain.pddl'))),
        completed_internal_nodes=sum(path.parent.name.isdigit() and int(path.parent.name) >= manifest['source_count']
            for path in (output / 'fusion/domain_fusion').glob('*/meta_domain.pddl')),
        node_count_policy='completed_fusion_nodes counts all saved node artifacts, including input leaves; completed_internal_nodes excludes input leaves',
        cache_hits=report.get('validation', {}).get('llm_cache_hits'),
        network_calls=report.get('validation', {}).get('llm_network_calls'),
        new_response_cache_entries=sum(('ollama/' + path.name) not in imported for path in (output / 'cache/ollama').glob('*.json')),
        cumulative_registered_worker_budget_seconds=manifest['cumulative_registered_worker_budget_seconds'],
        cumulative_observed_elapsed_seconds=manifest['predecessor_observed_elapsed_seconds'] + elapsed,
        scope=manifest['scope'], semantic_accuracy='not_measured')
    report['integrity_checks_passed'] = all(report[key] for key in ('source_snapshot_unchanged', 'implementation_unchanged',
        'imported_cache_unchanged', 'predecessor_cache_unchanged', 'predecessor_report_unchanged'))
    if not report['integrity_checks_passed']:
        report.update(worker_status=report['status'], status='artifact_changed')
    save(output / 'report.json', report)
    manifest.update(status=report['status'], finished_utc=report['finished_utc'])
    save(output / 'manifest.json', manifest)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--predecessor', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--seconds', type=float, default=10800)
    parser.add_argument('--stop-before-utc', help='Overall goal deadline; leave ten minutes for cleanup and reporting')
    args = parser.parse_args()
    report = run(args.predecessor, args.output, args.seconds, args.stop_before_utc)
    print(json.dumps(report, indent=2))

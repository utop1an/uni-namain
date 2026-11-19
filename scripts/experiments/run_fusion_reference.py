"""Fresh bounded local UniDomain-adapter run with frozen provenance and no old cache."""
import argparse
from datetime import datetime, timezone
import hashlib
import importlib.metadata
import json
import math
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import time
import urllib.request

ROOT = Path(__file__).resolve().parents[2]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8')


def freeze(inputs, output, seconds, workers, model, namespace_policy='raw', record_http_attempts=False):
    if type(record_http_attempts) is not bool:
        raise ValueError('HTTP attempt recording must be an explicit boolean')
    if namespace_policy not in ('raw', 'category_qualified'):
        raise ValueError('Unknown namespace export policy')
    if not math.isfinite(seconds) or seconds <= 0 or type(workers) is not int or workers < 1:
        raise ValueError('Invalid runtime budget')
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use a fresh empty output directory')
    paths = sorted(inputs.glob('*_domainfile.pddl')) + sorted(inputs.glob('*_problemfile.pddl'))
    if not any(p.name.endswith('_domainfile.pddl') for p in paths):
        raise ValueError('No source domains')
    output.mkdir(parents=True, exist_ok=True)
    snapshot = output/'inputs'
    snapshot.mkdir()
    for path in paths:
        shutil.copyfile(path, snapshot/path.name)
    code = [ROOT/n for n in ('rcnc/pddl.py', 'rcnc/pddl_checks.py', 'rcnc/namespace_export.py', 'scripts/experiments/run_fusion_reference.py')]
    code.extend(sorted((ROOT/'unidomain').glob('*.py')))
    code.extend(sorted((ROOT/'prompts/domain_fusion').glob('*.txt')))
    hashes = {}
    for path in code:
        relative = path.relative_to(ROOT)
        dest = output/'implementation'/relative
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(path, dest)
        hashes[relative.as_posix()] = sha(path)
    versions = {}
    for package in ('sentence-transformers', 'transformers', 'torch', 'requests', 'numpy', 'unified-planning', 'huggingface-hub'):
        try:
            versions[package] = importlib.metadata.version(package)
        except importlib.metadata.PackageNotFoundError:
            versions[package] = 'not_installed'
    manifest = {'status': 'prepared', 'started_utc': datetime.now(timezone.utc).isoformat(),
        'scope': 'Fresh local hardened UniDomain adapter; not unchanged official reproduction or semantic gold',
        'source_count': sum(p.name.endswith('_domainfile.pddl') for p in paths),
        'source_sha256': {p.name: sha(p) for p in paths}, 'implementation_sha256': hashes,
        'python': platform.python_version(), 'dependencies': versions,
        'budget_seconds': seconds, 'node_workers': workers, 'model': model,
        'namespace_policy': namespace_policy,
        'http_attempt_ledger': 'http_attempts.jsonl' if record_http_attempts else None,
        'embedding_model': 'sentence-transformers/all-mpnet-base-v2',
        'embedding_offline': True, 'predicate_threshold': 0.3, 'operator_threshold': 0.3,
        'cache_policy': 'new empty per-run cache; no historical answers imported',
        'inference_options': {'temperature': 0, 'num_ctx': 8192, 'num_predict': 1200},
        'known_adapter_differences': ['Local Ollama schema-constrained answers',
            'Descriptions derived from PDDL declaration/action usage, not source natural-language descriptions',
            'Structural safety rollback; source constant identity preserved',
            'No explicit argument permutation trace for merged action/predicate signatures',
            'Type/object universes use existing adapter semantics, not the source-preserving compiler'],
        'semantic_accuracy': 'not_measured'}
    save(output/'manifest.json', manifest)
    return manifest


def run(inputs, output, seconds=10800, workers=1, model='gemma3:4b', namespace_policy='raw', record_http_attempts=False):
    manifest = freeze(inputs, output, seconds, workers, model, namespace_policy, record_http_attempts)
    start = time.monotonic()
    report = {'status': 'starting', 'source_count': manifest['source_count']}
    try:
        with urllib.request.urlopen('http://127.0.0.1:11434/api/tags', timeout=10) as stream:
            tags = json.load(stream)
        installed = next((m for m in tags.get('models', []) if m['name'] == model), None)
        if installed is None or installed.get('remote_host') or installed.get('remote_model') or 'cloud' in model:
            raise ValueError('Requires an already installed local model')
        manifest['model_digest'] = installed['digest']
        manifest['status'] = 'running'
        save(output/'manifest.json', manifest)
        environment = {**os.environ, 'HF_HUB_OFFLINE': '1', 'TRANSFORMERS_OFFLINE': '1',
                       'USE_TF': '0', 'TRANSFORMERS_NO_TF': '1', 'TOKENIZERS_PARALLELISM': 'false',
                       'OMP_NUM_THREADS': '4', 'MKL_NUM_THREADS': '4'}
        command = [sys.executable, '-m', 'unidomain',
            '--input', str((output/'inputs').resolve()), '--output', str((output/'fusion').resolve()),
            '--cache-dir', str((output/'cache').resolve()), '--model', model,
            '--num-workers', str(workers), '--predicate-threshold', '0.3', '--operator-threshold', '0.3',
            '--namespace-policy', namespace_policy]
        if record_http_attempts:
            command.extend(['--attempt-ledger', str((output/'http_attempts.jsonl').resolve())])
        save(output/'command.json', {'argv': command, 'environment_overrides': {k: environment[k] for k in
              ('HF_HUB_OFFLINE', 'TRANSFORMERS_OFFLINE', 'USE_TF', 'TRANSFORMERS_NO_TF', 'TOKENIZERS_PARALLELISM', 'OMP_NUM_THREADS', 'MKL_NUM_THREADS')}})
        with (output/'worker.log').open('w', encoding='utf-8') as log:
            process = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, timeout=seconds, env=environment, cwd=ROOT)
        report.update(status='complete' if process.returncode == 0 else 'worker_error', returncode=process.returncode)
        validation = output/'fusion/validation.json'
        if validation.exists():
            report['validation'] = json.loads(validation.read_text(encoding='utf-8'))
        if process.returncode == 0 and not report.get('validation', {}).get('valid'):
            report['status'] = 'missing_or_invalid_final_validation'
    except subprocess.TimeoutExpired:
        report['status'] = 'time_limit'
    except Exception as exc:
        report.update(status='error', error=f'{type(exc).__name__}: {exc}')
    report.update(elapsed_seconds=round(time.monotonic()-start, 3),
        finished_utc=datetime.now(timezone.utc).isoformat(),
        source_snapshot_unchanged=all(sha(output/'inputs'/name) == value for name, value in manifest['source_sha256'].items()),
        implementation_unchanged=all(sha(ROOT/name) == value for name, value in manifest['implementation_sha256'].items()),
        completed_fusion_nodes=len(list((output/'fusion/domain_fusion').glob('*/meta_domain.pddl'))),
        cached_responses=len(list((output/'cache/ollama').glob('*.json'))),
        limit='Parsing and full processing do not establish source preservation, alignment accuracy or narrative quality')
    if record_http_attempts:
        ledger = output/'http_attempts.jsonl'
        report['http_attempt_ledger'] = {'path': 'http_attempts.jsonl',
            'exists': ledger.exists(), 'sha256': sha(ledger) if ledger.exists() else None,
            'scope': 'Opt-in observations; audit separately, retain incomplete intents. No historical cost reconstruction.'}
    save(output/'report.json', report)
    manifest.update(status=report['status'], finished_utc=report['finished_utc'])
    save(output/'manifest.json', manifest)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inputs', type=Path, default=Path('data/narra-domains'))
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--seconds', type=float, default=10800)
    parser.add_argument('--workers', type=int, default=1)
    parser.add_argument('--model', default='gemma3:4b')
    parser.add_argument('--namespace-policy', choices=('raw', 'category_qualified'), default='raw')
    parser.add_argument('--record-http-attempts', action='store_true',
                        help='Freeze an opt-in fresh client attempt ledger, without prompts or answers')
    args = parser.parse_args()
    result = run(args.inputs, args.output, args.seconds, args.workers, args.model, args.namespace_policy, args.record_http_attempts)
    print(json.dumps(result, indent=2))

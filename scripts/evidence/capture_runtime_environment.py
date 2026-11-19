"""Non-identifying runtime observation; not a retroactive hardware freeze."""
import argparse
import ctypes
from datetime import datetime, timezone
import hashlib
import importlib.metadata
import json
import os
from pathlib import Path
import platform
import struct
import subprocess
import sys
import urllib.request


def command(arguments):
    try:
        result = subprocess.run(arguments, capture_output=True, text=True, encoding='utf-8',
            errors='replace', timeout=10)
        return {'status': 'observed' if result.returncode == 0 else 'unavailable',
            'exit_code': result.returncode, 'stdout': result.stdout.strip(), 'stderr': result.stderr.strip()}
    except Exception as exc:
        return {'status': 'unavailable', 'reason': f'{type(exc).__name__}: {exc}'}


def capture(output):
    if output.exists():
        raise ValueError('Use a fresh observation file')
    packages = {}
    for name in ('unified-planning', 'pyperplan', 'transformers', 'sentence-transformers', 'torch', 'numpy', 'scipy', 'jsonschema'):
        try:
            packages[name] = importlib.metadata.version(name)
        except importlib.metadata.PackageNotFoundError:
            packages[name] = None
    memory = None
    if os.name == 'nt':
        class MemoryStatus(ctypes.Structure):
            _fields_ = [('length', ctypes.c_ulong), ('load', ctypes.c_ulong),
                *[(name, ctypes.c_ulonglong) for name in ('total_phys', 'avail_phys', 'total_page',
                    'avail_page', 'total_virtual', 'avail_virtual', 'avail_extended')]]
        status = MemoryStatus()
        status.length = ctypes.sizeof(status)
        if ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(status)):
            memory = status.total_phys
    try:
        with urllib.request.urlopen('http://127.0.0.1:11434/api/version', timeout=5) as response:
            ollama = {'status': 'observed', **json.load(response)}
    except Exception as exc:
        ollama = {'status': 'unavailable', 'reason': f'{type(exc).__name__}: {exc}'}
    result = {'status': 'observed_runtime_snapshot', 'observed_utc': datetime.now(timezone.utc).isoformat(),
        'windows': {'platform': platform.platform(), 'python': sys.version,
            'python_executable': sys.executable, 'process_bits': struct.calcsize('P') * 8,
            'logical_cpus': os.cpu_count(), 'processor_identifier': os.environ.get('PROCESSOR_IDENTIFIER'),
            'installed_physical_memory_bytes': memory}, 'package_versions': packages,
        'gpu': command(['nvidia-smi', '--query-gpu=name,memory.total,driver_version', '--format=csv,noheader']),
        'wsl_kernel': command(['wsl', '--exec', 'uname', '-sr']),
        'wsl_os': command(['wsl', '--exec', 'cat', '/etc/os-release']),
        'wsl_memory': command(['wsl', '--exec', 'head', '-n', '1', '/proc/meminfo']),
        'ollama_runtime': ollama, 'model_inference_requests': 0,
        'implementation_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        'scope': 'Current-host/runtime observation during cached extended fusion. No host name, serial number or GPU UUID requested. Later observation is not a pre-run freeze or proof of every historical run configuration. Other manifests retain their original hardware gaps.'}
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(capture(args.output), indent=2))

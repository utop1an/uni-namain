"""Isolated archived compiler entry point; run with Python -I.

The synthetic package shell prevents fallback to current repository modules.
It is not a claim that an unrecorded historical initializer was recovered.
"""
import argparse
import hashlib
import importlib
import importlib.machinery
import importlib.metadata
import json
from pathlib import Path
import sys
import types

COMPILER_MODULES = frozenset(('rcnc/pddl.py', 'rcnc/pddl_checks.py', 'rcnc/domain_building.py',
                              'rcnc/domain_union.py', 'rcnc/aligned_domain.py'))

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def execute(job_path):
    job = json.loads(job_path.read_text(encoding='utf-8'))
    code = Path(job['code']).resolve()
    output, report_path = Path(job['output']), Path(job['report'])
    if report_path.exists() or output.exists():
        raise ValueError('Fresh compiler output and report paths required')
    if any(name == 'rcnc' or name.startswith('rcnc.') for name in sys.modules):
        raise ValueError('Project package was imported before archived isolation')
    for name, expected in job['input_sha256'].items():
        if sha(Path(name)) != expected:
            raise ValueError('Frozen child input changed: ' + name)
    if set(job['compiler_sha256']) != COMPILER_MODULES:
        raise ValueError('Complete five-module archived compiler inventory required')
    for relative, expected in job['compiler_sha256'].items():
        path = (code / relative).resolve()
        if sha(path) != expected or job['input_sha256'].get(str(path)) != expected:
            raise ValueError('Archived compiler digest must match before importing code: ' + relative)
    package = types.ModuleType('rcnc')
    package.__path__ = [str(code / 'rcnc')]
    package.__package__ = 'rcnc'
    package.__spec__ = importlib.machinery.ModuleSpec('rcnc', loader=None, is_package=True)
    package.__spec__.submodule_search_locations = package.__path__
    sys.modules['rcnc'] = package
    modules = {}
    for relative, expected in job['compiler_sha256'].items():
        module_name = relative.removesuffix('.py').replace('/', '.')
        module = importlib.import_module(module_name)
        path = Path(module.__file__).resolve()
        if path != (code / relative).resolve() or not path.is_relative_to(code) or sha(path) != expected:
            raise ValueError('Compiler module was not loaded from its exact archive: ' + module_name)
        modules[module_name] = {'file': str(path), 'sha256': expected}
    build = importlib.import_module('rcnc.aligned_domain').build
    result = build(Path(job['inputs']), output, json.loads(Path(job['alignment']).read_text(encoding='utf-8')))
    for name, module in tuple(sys.modules.items()):
        if name.startswith('rcnc.') and getattr(module, '__file__', None):
            if not Path(module.__file__).resolve().is_relative_to(code):
                raise ValueError('Unexpected repository-module fallback: ' + name)
    intact = all(sha(Path(name)) == expected for name, expected in job['input_sha256'].items())
    report = {'status': 'compiled', 'structurally_valid': result['valid'],
        'domain_sha256': sha(output / 'meta_domain.pddl'), 'metadata_sha256': sha(output / 'meta_domain.json'),
        'loaded_modules': modules, 'inputs_unchanged': intact,
        'python': sys.version, 'unified_planning': importlib.metadata.version('unified-planning'),
        'scope': 'Exact archived compiler modules under the recorded current runtime; no model or planner requests.'}
    report_path.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--job', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(execute(args.job), indent=2))

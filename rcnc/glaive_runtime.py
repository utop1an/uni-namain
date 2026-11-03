"""Bounded native Glaive execution. Never strips or repairs source syntax."""
import json
from pathlib import Path
import re
import subprocess
import time

from .domain_building import digest, save


def linux_path(path):
    path = Path(path).resolve().as_posix()
    if not re.match(r'^[A-Za-z]:/', path):
        raise ValueError('Expected absolute Windows path')
    return '/mnt/' + path[0].lower() + path[2:]


def invoke(jar, domain, problem, output, *, mode='search', seconds=30, classes=None, plan=None):
    output = Path(output)
    if (output / 'result.json').exists():
        raise ValueError('Completed execution cannot be overwritten')
    output.mkdir(parents=True, exist_ok=True)
    cmd = ['wsl.exe', '--exec', 'timeout', '--signal=TERM', '--kill-after=2s', str(seconds) + 's',
           'java', '-Xmx4096m']
    if mode == 'search':
        cmd += ['-jar', linux_path(jar), '-d', linux_path(domain), '-p', linux_path(problem),
                '-tl', str(seconds * 1000), '-o', linux_path(output / 'plan.pddl')]
    else:
        cmd += ['-cp', linux_path(jar) + ':' + linux_path(classes), 'GlaiveProbe', mode,
                linux_path(domain), linux_path(problem)]
        if plan is not None: cmd.append(linux_path(plan))
    inputs = {str(Path(p).resolve()): digest(p) for p in (jar, domain, problem)}
    if plan is not None: inputs[str(Path(plan).resolve())] = digest(plan)
    save(output / 'invocation.json', {'command': cmd, 'mode': mode, 'seconds': seconds,
                                      'input_sha256': inputs, 'memory_mb': 4096})
    start = time.monotonic()
    # GNU timeout owns the Java process lifetime even if the Windows caller exits.
    process = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    log = process.stdout.decode('utf-8', errors='replace')
    (output / 'stdout.txt').write_text(log, encoding='utf-8')
    result = {'status': 'runtime_error', 'returncode': process.returncode, 'seconds': time.monotonic() - start,
              'mode': mode, 'search_calls': int(mode == 'search'), 'input_sha256': inputs}
    if process.returncode in (124, 137): result['status'] = 'wall_time_limit'
    elif mode == 'search':
        if 'A solution was found' in log and (output / 'plan.pddl').exists(): result['status'] = 'solved'
        elif 'No solution was found' in log: result['status'] = 'no_solution_returned'
        elif 'ParseException' in log or 'FormatException' in log: result['status'] = 'native_parse_error'
        if 'OutOfMemoryError' in log: result['status'] = 'memory_limit'
        match = re.search(r'(\d+) nodes were visited; (\d+) were generated', log)
        if match: result.update(visited=int(match[1]), generated=int(match[2]))
    elif process.returncode == 0:
        for line in log.splitlines():
            if line.startswith('{'):
                try: result.update(json.loads(line))
                except json.JSONDecodeError: pass
    elif 'ParseException' in log or 'FormatException' in log: result['status'] = 'native_parse_error'
    if any(digest(Path(p)) != h for p, h in inputs.items()):
        raise ValueError('Runtime changed an input')
    save(output / 'result.json', result)
    return result

"""Root-only, private cgroup launcher; the workload runs as UID 1000 offline."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time


def write(path, value):
    with path.open('x', encoding='utf-8') as f:
        json.dump(value, f, indent=2)


def now():
    return datetime.now(timezone.utc).isoformat()


def kernel(root, name):
    p = subprocess.run(['dmesg', '--time-format', 'iso'], capture_output=True, text=True)
    write(root/name, {'utc': now(), 'boot_id': Path('/proc/sys/kernel/random/boot_id').read_text().strip(),
                     'returncode': p.returncode, 'stdout': p.stdout, 'stderr': p.stderr})


def launch(root, program, high, maximum, swap):
    assert os.getuid() == 0
    workspace = Path('/mnt/c/anu/uninamain').resolve()
    assert root.is_relative_to(workspace/'data/validation') and root.is_dir()
    assert program.parent == root and program.is_file()
    name = 'codex-uninamain-'+hashlib.sha256(str(root).encode()).hexdigest()[:16]
    group = Path('/sys/fs/cgroup')/name
    assert group.parent == Path('/sys/fs/cgroup') and not group.exists()
    group.mkdir()
    for key, value in (('memory.high', high), ('memory.max', maximum), ('memory.swap.max', swap), ('memory.oom.group', 0)):
        (group/key).write_text(str(value))

    def sample():
        result = {'utc': now(), 'path': str(group)}
        for key in ('memory.high', 'memory.max', 'memory.swap.max', 'memory.current', 'memory.peak',
                    'memory.swap.current', 'memory.events', 'cgroup.procs'):
            result[key] = (group/key).read_text().strip()
        return result

    kernel(root, 'kernel_before.json')
    write(root/'cgroup_before.json', sample())
    command = ['unshare', '--user', '--map-root-user', '--net', 'python3', str(program)]
    if program.name == 'runner.py':
        command += ['run', '--output', str(root)]
    env = dict(os.environ, GLAIVE_WORKLOAD_CGROUP=str(group))

    def enter():
        (group/'cgroup.procs').write_text(str(os.getpid()))
        Path('/proc/self/oom_score_adj').write_text('-500')
        os.setgroups([])
        os.setgid(1000)
        os.setuid(1000)

    with (root/'launcher_stdout.txt').open('xb') as stream:
        p = subprocess.run(command, stdout=stream, stderr=subprocess.STDOUT, cwd=str(workspace),
                           env=env, preexec_fn=enter)
    remaining = (group/'cgroup.procs').read_text().split()
    if remaining:
        # This freshly created group contains only this launch's descendants.
        (group/'cgroup.kill').write_text('1')
        for _ in range(50):
            if not (group/'cgroup.procs').read_text().strip():
                break
            time.sleep(.02)
    write(root/'cgroup_after.json', sample())
    kernel(root, 'kernel_after.json')
    write(root/'launcher_exit.json', {'returncode': p.returncode, 'finished_utc': now(),
        'private_cgroup': str(group), 'cleanup_remaining_pids': remaining, 'model_requests': 0})
    if not (group/'cgroup.procs').read_text().strip():
        group.rmdir()
    print(json.dumps({'returncode': p.returncode, 'root': str(root), 'private_cgroup': str(group)}), flush=True)
    return p.returncode


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--program', default='runner.py')
    p.add_argument('--high-mb', type=int, default=10240)
    p.add_argument('--max-mb', type=int, default=12288)
    p.add_argument('--swap-mb', type=int, default=1024)
    a = p.parse_args()
    root = a.output.resolve()
    sys.exit(launch(root, (root/a.program).resolve(), a.high_mb*1024**2, a.max_mb*1024**2, a.swap_mb*1024**2))

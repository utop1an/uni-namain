"""Detached coordinator: primary fresh rerun, then physical matched follow-up."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys


def save(path, value):
    tmp = path.with_suffix('.tmp')
    tmp.write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8')
    tmp.replace(path)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--primary', type=Path, required=True)
    p.add_argument('--official', type=Path, required=True)
    a = p.parse_args()
    primary, official = a.primary.resolve(), a.official.resolve()
    for output in (primary, official):
        if not (output / 'protocol.json').is_file() or (output / 'started.json').exists():
            raise ValueError('Both stages must be prepared and never started')
    receipt = primary / 'campaign.json'
    if receipt.exists():
        raise ValueError('A campaign has already been launched')
    state = {'status': 'running', 'started_at': datetime.now(timezone.utc).isoformat(), 'pid': os.getpid(),
             'coordinator_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(), 'stages': []}
    save(receipt, state)
    for name, output, module in [('primary', primary, 'run_shared_type_tables'),
                                 ('official_physical', official, 'run_shared_type_official_followup')]:
        cmd = [sys.executable, '-X', 'utf8', '-m', 'scripts.experiments.' + module, 'run', '--output', str(output)]
        stage = {'name': name, 'output': str(output), 'status': 'running', 'command': cmd,
                 'started_at': datetime.now(timezone.utc).isoformat()}
        state['stages'].append(stage)
        save(receipt, state)
        with (output / 'execution_stdout.log').open('xb') as stdout, (output / 'execution_stderr.log').open('xb') as stderr:
            code = subprocess.run(cmd, cwd=output / 'code', stdout=stdout, stderr=stderr,
                                  creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0)).returncode
        stage.update(status='complete' if code == 0 else 'failed', returncode=code,
                     finished_at=datetime.now(timezone.utc).isoformat())
        if code:
            state['status'] = 'failed'
            save(receipt, state)
            raise SystemExit(code)
        save(receipt, state)
    state.update(status='complete', finished_at=datetime.now(timezone.utc).isoformat())
    save(receipt, state)


if __name__ == '__main__':
    main()

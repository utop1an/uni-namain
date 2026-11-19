"""Metadata-only adapter for Windows readers that briefly block file replacement."""
import json
from pathlib import Path
import time
import uuid

from rcnc import model_semantics_parallel


def durable_progress(path, value, *, retry_delays=(.01, .03, .1, .2, .4)):
    """Retry local metadata replacement, never model requests.

    Completed model outcomes are independently persisted per candidate. If a
    viewer keeps the progress filename locked, retain a fresh immutable progress
    snapshot instead of terminating the experiment or losing completed outcomes.
    """
    path=Path(path)
    content=json.dumps(value,indent=2)+'\n'
    temporary=path.with_name(path.name+'.'+uuid.uuid4().hex+'.writing')
    temporary.write_text(content,encoding='utf-8')
    for attempt in range(len(retry_delays)+1):
        try:
            temporary.replace(path)
            return path
        except PermissionError:
            if attempt<len(retry_delays):time.sleep(retry_delays[attempt])
    # This is a new filename, so an open reader of progress.json cannot block it.
    fallback=path.with_name(path.stem+'.checkpoint.'+str(time.time_ns())+'.json')
    fallback.write_text(content,encoding='utf-8')
    try:temporary.unlink()
    except OSError:pass
    print('Progress filename locked; saved',fallback,flush=True)
    return fallback


def run_campaign(root):
    """Run the frozen scheduler with only its progress writer replaced.

    The dedicated experiment process runs one model stage at a time. All model
    requests, validation, dispatch limits, and planning code remain unchanged.
    The adapter is restored on exit and registered as a separate implementation.
    """
    from scripts.experiments.run_revised_multistory_parallel import pipeline
    previous=model_semantics_parallel.atomic_save
    model_semantics_parallel.atomic_save=durable_progress
    try:return pipeline(root)
    finally:model_semantics_parallel.atomic_save=previous

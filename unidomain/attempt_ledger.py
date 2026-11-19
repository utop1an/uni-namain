"""Opt-in durable HTTP attempt observations, without prompts or model answers.

A durable intent precedes dispatch. An unmatched intent is indeterminate: the
process can die either before dispatch or while awaiting the server. Returned
token counts are server observations, not a billing or model-identity proof.
"""
from contextlib import contextmanager
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import threading
import time
import uuid


class AttemptLedger:
    def __init__(self, path: Path, model: str):
        self.path = Path(path)
        if self.path.suffix.lower() != '.jsonl':
            raise ValueError('Attempt ledger requires a fresh .jsonl path')
        self.model = model
        self.lock = threading.Lock()
        self.path.parent.mkdir(parents=True, exist_ok=True)
        # Never append a new run to an old ledger, including an empty old file.
        with self.path.open('x', encoding='utf-8') as stream:
            self._write(stream, {'event': 'ledger_created', 'version': 1,
                                 'model': model, 'observed_utc': self.now()})

    @staticmethod
    def now():
        return datetime.now(timezone.utc).isoformat()

    @staticmethod
    def _write(stream, value):
        stream.write(json.dumps(value, ensure_ascii=False, allow_nan=False) + '\n')
        stream.flush()
        os.fsync(stream.fileno())

    def append(self, value):
        with self.lock, self.path.open('a', encoding='utf-8') as stream:
            self._write(stream, value)

    @contextmanager
    def attempt(self, task, request_key):
        identifier = uuid.uuid4().hex
        self.append({'event': 'dispatch_intent', 'attempt_id': identifier,
                     'task': task, 'request_key': request_key, 'model': self.model,
                     'observed_utc': self.now()})
        started = time.perf_counter()
        observation = {'stage': 'http_request'}
        try:
            yield observation
        except BaseException as error:
            observation['error_class'] = type(error).__name__
            raise
        finally:
            observation.setdefault('outcome', observation['stage'] + '_error')
            self.append({'event': 'attempt_finished', 'attempt_id': identifier,
                         'observed_utc': self.now(),
                         'client_elapsed_seconds': time.perf_counter() - started,
                         **observation})


def returned_counts(payload):
    """Missing, malformed or negative server counters stay explicitly unknown."""
    result = {}
    for name in ('prompt_eval_count', 'eval_count', 'total_duration'):
        value = payload.get(name) if isinstance(payload, dict) else None
        result[name] = value if type(value) is int and value >= 0 else None
    return result

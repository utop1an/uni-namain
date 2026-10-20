"""Embedding service and cached Ollama calls for the reference adapter."""
from __future__ import annotations

import hashlib
import json
import os
import threading
import time
from pathlib import Path
from typing import Any, Callable

os.environ.setdefault("USE_TF", "0")
os.environ.setdefault("TRANSFORMERS_NO_TF", "1")

import numpy as np
import requests


class EmbeddingService:
    def __init__(self, model_name: str) -> None:
        from sentence_transformers import SentenceTransformer

        self.model_name = model_name
        self.model = SentenceTransformer(model_name)
        self.cache: dict[str, np.ndarray] = {}
        self.lock = threading.Lock()

    def encode(self, texts: list[str]) -> np.ndarray:
        with self.lock:
            missing = [text for text in dict.fromkeys(texts) if text not in self.cache]
            if missing:
                vectors = self.model.encode(
                    missing,
                    normalize_embeddings=True,
                    show_progress_bar=False,
                )
                self.cache.update(zip(missing, vectors))
            return np.asarray([self.cache[text] for text in texts])

    def filter_and_sort(
        self,
        query: str,
        candidates: list[str],
        threshold: float,
    ) -> list[tuple[str, float]]:
        if not candidates:
            return []
        vectors = self.encode([query, *candidates])
        similarities = vectors[1:] @ vectors[0]
        scored = [
            (candidate, float(score))
            for candidate, score in zip(candidates, similarities)
            if float(score) > threshold
        ]
        return sorted(scored, key=lambda item: item[1], reverse=True)



class OllamaClient:
    def __init__(
        self,
        *,
        base_url: str,
        model: str,
        cache_dir: Path,
        max_retries: int = 5,
    ) -> None:
        self.base_url = base_url.rstrip("/")
        self.model = model
        self.cache_dir = cache_dir
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.max_retries = max_retries
        self.network_calls = 0
        self.cache_hits = 0
        self.total_duration_seconds = 0.0

    def call(
        self,
        task: str,
        prompt: str,
        schema: dict[str, Any],
        validator: Callable[[dict[str, Any]], None],
    ) -> dict[str, Any]:
        for attempt in range(1, self.max_retries + 1):
            effective_prompt = prompt
            digest = hashlib.sha256(
                json.dumps(
                    {
                        "model": self.model,
                        "task": task,
                        "prompt": effective_prompt,
                        "schema": schema,
                    },
                    sort_keys=True,
                ).encode("utf-8")
            ).hexdigest()
            cache_path = self.cache_dir / f"{digest}.json"
            if cache_path.exists():
                cached = json.loads(cache_path.read_text(encoding="utf-8"))
                data = cached.get("response", cached)
                self.cache_hits += 1
            else:
                started = time.perf_counter()
                response = requests.post(
                    f"{self.base_url}/api/chat",
                    json={
                        "model": self.model,
                        "messages": [{"role": "user", "content": effective_prompt}],
                        "format": schema,
                        "stream": False,
                        "keep_alive": "30m",
                        "options": {"temperature": 0, "num_ctx": 8192, "num_predict": 1200},
                    },
                    timeout=600,
                )
                response.raise_for_status()
                payload = response.json()
                try:
                    data = json.loads(payload["message"]["content"])
                except json.JSONDecodeError as error:
                    if attempt == self.max_retries:
                        raise ValueError(
                            f"Ollama returned invalid JSON for {task}: {error}"
                        ) from error
                    continue
                elapsed = time.perf_counter() - started
                self.network_calls += 1
                self.total_duration_seconds += elapsed
                if self.network_calls % 10 == 0:
                    print(
                        f"Ollama progress: {self.network_calls} network calls "
                        f"(latest {task}: {elapsed:.1f}s)",
                        flush=True,
                    )
                cache_path.write_text(
                    json.dumps(
                        {
                            "task": task,
                            "prompt": effective_prompt,
                            "response": data,
                            "duration_seconds": elapsed,
                        },
                        indent=2,
                        ensure_ascii=False,
                    )
                    + "\n",
                    encoding="utf-8",
                )
            try:
                validator(data)
                return data
            except (AssertionError, KeyError, TypeError, ValueError) as error:
                if attempt == self.max_retries:
                    raise ValueError(
                        f"Ollama output failed validation for {task}: {error}"
                    ) from error
        raise AssertionError("unreachable")


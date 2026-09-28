"""Strict UniDomain binary-tree fusion using all-mpnet-base-v2 and local Ollama.

This adapter follows the official predicate-first/operator-second fusion procedure,
uses the official thresholds and prompt rules, and keeps the local dataset's PDDL
requirements, types, constants, and problem mappings intact.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import threading
import time
from concurrent.futures import Future, ThreadPoolExecutor
from copy import deepcopy
from pathlib import Path
from typing import Any, Callable

os.environ.setdefault("USE_TF", "0")
os.environ.setdefault("TRANSFORMERS_NO_TF", "1")

import numpy as np
import requests

from merge_domains import (
    Domain,
    Predicate,
    SExpr,
    atom,
    called_predicates,
    domain_summary,
    parse_domain,
    parse_sexpr,
    replace_current_name,
    rewrite_expr,
    rewrite_problem,
    serialize,
    unique_name,
    validate_domain,
    validate_problem,
    write_domain,
    write_node,
)


PROMPT_DIR = Path(__file__).resolve().parent / "prompts" / "domain_fusion"

PREDICATE_SCHEMA = {
    "type": "object",
    "properties": {
        "reasoning": {"type": "string"},
        "merge_flag": {"type": "boolean"},
        "new_predicate": {
            "anyOf": [
                {
                    "type": "array",
                    "items": {"type": "string"},
                    "minItems": 2,
                    "maxItems": 2,
                },
                {"type": "null"},
            ]
        },
    },
    "required": ["reasoning", "merge_flag", "new_predicate"],
}

ACTION_UPDATE_SCHEMA = {
    "type": "object",
    "properties": {
        "reasoning": {"type": "string"},
        "updated_action": {"type": "string"},
    },
    "required": ["reasoning", "updated_action"],
}

ACTION_MERGE_SCHEMA = {
    "type": "object",
    "properties": {
        "reasoning": {"type": "string"},
        "merge_flag": {"type": "boolean"},
        "new_operator_name": {"anyOf": [{"type": "string"}, {"type": "null"}]},
        "new_operator": {"anyOf": [{"type": "string"}, {"type": "null"}]},
    },
    "required": ["reasoning", "merge_flag", "new_operator_name", "new_operator"],
}


def load_prompt(name: str, **values: str) -> str:
    template = (PROMPT_DIR / name).read_text(encoding="utf-8")
    return template.format(**values)


def predicate_text(predicate: Predicate) -> str:
    return serialize(predicate.to_expr())


def predicate_description(predicate: Predicate, domain: Domain | None = None) -> str:
    words = predicate.name.replace("_", " ").replace("-", " ")
    arguments = ", ".join(
        f"{variable} is a {value_type}"
        for variable, value_type in predicate.parameters
    )
    if not predicate.parameters:
        meaning = f"the state '{words}' holds"
    elif len(predicate.parameters) == 1:
        variable, value_type = predicate.parameters[0]
        meaning = f"{value_type} {variable} is in the state '{words}'"
    else:
        meaning = f"relation '{words}' holds; arguments: {arguments}"

    if domain is None:
        return meaning
    usages = []
    for action_name, action in domain.actions.items():
        for role in (":precondition", ":effect"):
            if role in action and predicate.name in called_predicates(
                action[action.index(role) + 1]
            ):
                usages.append(f"{role[1:]} of {action_name}")
    if usages:
        meaning += "; used as " + ", ".join(usages[:8])
    return meaning


def parse_predicate(text: str) -> Predicate:
    expression = parse_sexpr(text)
    if not isinstance(expression, list) or not expression:
        raise ValueError("new_predicate is not one PDDL predicate expression")
    name = atom(expression[0])
    parameters: list[tuple[str, str]] = []
    pending: list[str] = []
    index = 1
    while index < len(expression):
        token = atom(expression[index])
        if token == "-":
            if not pending or index + 1 >= len(expression):
                raise ValueError("invalid typed predicate parameters")
            value_type = atom(expression[index + 1])
            parameters.extend((item, value_type) for item in pending)
            pending.clear()
            index += 2
        else:
            pending.append(token)
            index += 1
    parameters.extend((item, "object") for item in pending)
    if any(not variable.startswith("?") for variable, _ in parameters):
        raise ValueError("predicate parameters must be variables")
    return Predicate(name=name, parameters=parameters)


def parse_action(text: str) -> list[SExpr]:
    expression = parse_sexpr(text)
    if (
        not isinstance(expression, list)
        or len(expression) < 2
        or expression[0] != ":action"
    ):
        raise ValueError("updated action is not a PDDL :action expression")
    return expression


def action_predicates(action: list[SExpr]) -> set[str]:
    result: set[str] = set()
    for key in (":precondition", ":effect"):
        if key in action:
            result.update(called_predicates(action[action.index(key) + 1]))
    return result


def action_explanations(domain: Domain, action: list[SExpr]) -> str:
    used = action_predicates(action)
    values = {
        predicate_text(domain.predicates[name]): predicate_description(domain.predicates[name], domain)
        for name in sorted(used)
        if name in domain.predicates
    }
    return str(values)


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


class FusionRuntime:
    def __init__(
        self,
        *,
        model: str,
        base_url: str,
        embedding_model: str,
        predicate_threshold: float,
        operator_threshold: float,
        cache_dir: Path,
    ) -> None:
        self.embedding = EmbeddingService(embedding_model)
        self.llm = OllamaClient(
            base_url=base_url,
            model=model,
            cache_dir=cache_dir / "ollama",
        )
        self.embedding_model = embedding_model
        self.predicate_threshold = predicate_threshold
        self.operator_threshold = operator_threshold

    def predicate_candidates(
        self,
        query: Predicate,
        candidates: dict[str, Predicate],
    ) -> list[tuple[str, float]]:
        candidate_names = list(candidates)
        candidate_text_to_name = {
            predicate_text(candidates[name]): name for name in candidate_names
        }
        scored_texts = self.embedding.filter_and_sort(
            predicate_text(query),
            list(candidate_text_to_name),
            self.predicate_threshold,
        )
        return [
            (candidate_text_to_name[text], score)
            for text, score in scored_texts
        ]

    def action_candidates(
        self,
        query_name: str,
        candidate_names: list[str],
    ) -> list[tuple[str, float]]:
        return self.embedding.filter_and_sort(
            query_name,
            candidate_names,
            self.operator_threshold,
        )


def update_actions_for_predicate(
    domain: Domain,
    old: Predicate,
    new: Predicate,
    runtime: FusionRuntime,
) -> None:
    old_name = old.name
    new_name = new.name
    old_text = predicate_text(old)
    new_text = predicate_text(new)
    signature_changed = old.parameters != new.parameters
    updated_actions: dict[str, list[SExpr]] = {}

    for action_name, action in list(domain.actions.items()):
        if old_name not in action_predicates(action):
            updated_actions[action_name] = action
            continue

        if not signature_changed:
            new_action = rewrite_expr(action, predicate_names={old_name: new_name})
            assert isinstance(new_action, list)
        else:
            prompt = load_prompt(
                "update_action_string.txt",
                action_string=serialize(action),
                predicates_in_action=action_explanations(domain, action),
                old_predicate=old_text,
                new_predicate=new_text,
            )

            result = runtime.llm.call(
                "update_action_string",
                prompt,
                ACTION_UPDATE_SCHEMA,
                lambda data: None,
            )
            new_action = parse_action(result["updated_action"])
        new_action_name = atom(new_action[1])
        if new_action_name != action_name and new_action_name in domain.actions:
            raise ValueError('Action update would overwrite another source action')
        if new_action_name in updated_actions:
            raise ValueError('Action update name collision')
        updated_actions[new_action_name] = new_action
        if new_action_name != action_name:
            replace_current_name(domain.action_maps, action_name, new_action_name)

    domain.actions = updated_actions


def merge_predicates_with_llm(
    left: Domain,
    right: Domain,
    runtime: FusionRuntime,
) -> None:
    merged_left: set[str] = set()
    merged_right: set[str] = set()
    approved_names: set[str] = set()

    for left_name in list(left.predicates):
        if left_name not in left.predicates or left_name in merged_left:
            continue
        left_predicate = left.predicates[left_name]
        candidates = runtime.predicate_candidates(left_predicate, right.predicates)
        for right_name, similarity in candidates:
            if right_name not in right.predicates or right_name in merged_right:
                continue
            right_predicate = right.predicates[right_name]
            prompt = load_prompt(
                "check_merge_predicates.txt",
                predicate_in_domain_1=(
                    f"{predicate_text(left_predicate)} ; "
                    f"{predicate_description(left_predicate, left)}"
                ),
                predicate_in_domain_2=(
                    f"{predicate_text(right_predicate)} ; "
                    f"{predicate_description(right_predicate, right)}"
                ),
            )

            result = runtime.llm.call(
                "check_merge_predicates",
                prompt,
                PREDICATE_SCHEMA,
                lambda data: None,
            )
            if not result["merge_flag"]:
                continue

            # Stage both sides; a failed update must not partially mutate the domains.
            try:
                new_predicate = parse_predicate(result["new_predicate"][0])
                if new_predicate.arity != left_predicate.arity or new_predicate.arity != right_predicate.arity:
                    raise ValueError('Arity-changing predicate merges require an explicit problem mapping')
                for side,old in ((left,left_name),(right,right_name)):
                    if any(n.lower()==new_predicate.name.lower() and n!=old for n in side.predicates):
                        raise ValueError('Proposed predicate overwrites an unrelated declaration')
                staged_left,staged_right=deepcopy(left),deepcopy(right)
                for side,old in ((staged_left,left_predicate),(staged_right,right_predicate)):
                    update_actions_for_predicate(side,old,new_predicate,runtime)
                    del side.predicates[old.name]
                    side.predicates[new_predicate.name]=deepcopy(new_predicate)
                    replace_current_name(side.predicate_maps,old.name,new_predicate.name)
                    errors=validate_domain(side)
                    if errors:raise ValueError('; '.join(errors))
            except (ValueError,KeyError,TypeError,IndexError) as exc:
                left.decisions.append({'kind':'rejected_predicate_merge','left':left_name,'right':right_name,'reason':str(exc)})
                continue
            left.__dict__.update(staged_left.__dict__)
            right.__dict__.update(staged_right.__dict__)
            approved_names.add(new_predicate.name)

            decision = {
                "kind": "predicate",
                "left": predicate_text(left_predicate),
                "right": predicate_text(right_predicate),
                "result": predicate_text(new_predicate),
                "reason": result["reasoning"],
                "similarity": similarity,
                "verifier": runtime.llm.model,
            }
            left.decisions.append(decision)
            right.decisions.append(decision)
            merged_left.add(new_predicate.name)
            merged_right.add(new_predicate.name)
            break

    # A declined same-name candidate must remain two distinct predicates.
    from pddl_checks import safe_name
    for name in list(right.predicates):
        if name not in approved_names and name.lower() in {n.lower() for n in left.predicates}:
            target=safe_name(sorted(right.sources)[0]+'__p_'+name,set(left.predicates)|set(right.predicates))
            pred=right.predicates.pop(name);pred.name=target;right.predicates[target]=pred
            right.actions={n:rewrite_expr(a,predicate_names={name:target}) for n,a in right.actions.items()}
            replace_current_name(right.predicate_maps,name,target)



def merge_operators_with_llm(
    left: Domain,
    right: Domain,
    runtime: FusionRuntime,
) -> dict[str, list[SExpr]]:
    final_actions = deepcopy(left.actions)
    merged_left: set[str] = set()

    for right_name, right_action in right.actions.items():
        candidates = runtime.action_candidates(right_name, list(left.actions))
        merged = False
        for left_name, similarity in candidates:
            if left_name in merged_left:
                continue
            left_action = left.actions[left_name]
            prompt = load_prompt(
                "check_merge_actions.txt",
                action_in_domain_1=serialize(left_action),
                predicates_in_domain_1=action_explanations(left, left_action),
                action_in_domain_2=serialize(right_action),
                predicates_in_domain_2=action_explanations(right, right_action),
            )
            result = runtime.llm.call(
                "check_merge_actions",
                prompt,
                ACTION_MERGE_SCHEMA,
                lambda data: None,
            )
            if not result["merge_flag"]:
                continue

            try:
                new_name = result["new_operator_name"]
                new_action = parse_action(result["new_operator"])
                if not isinstance(new_name,str) or new_name != new_action[1]:
                    raise ValueError('Operator name disagrees with action AST')
                if any(n.lower()==new_name.lower() and n!=left_name for n in final_actions):
                    raise ValueError('Operator merge would overwrite another action')
                check=deepcopy(left)
                check.types={**left.types,**right.types}
                check.constants={**left.constants,**right.constants}
                check.predicates={**left.predicates,**right.predicates}
                check.actions={new_name:new_action}
                errors=validate_domain(check)
                if errors:raise ValueError('; '.join(errors))
            except (ValueError,KeyError,TypeError,IndexError) as exc:
                left.decisions.append({'kind':'rejected_operator_merge','left':left_name,'right':right_name,'reason':str(exc)})
                continue
            final_actions.pop(left_name, None)
            final_actions[new_name] = new_action
            replace_current_name(left.action_maps, left_name, new_name)
            replace_current_name(right.action_maps, right_name, new_name)
            merged_left.add(left_name)
            merged = True
            left.decisions.append(
                {
                    "kind": "operator",
                    "left": left_name,
                    "right": right_name,
                    "result": new_name,
                    "reason": result["reasoning"],
                    "similarity": similarity,
                    "verifier": runtime.llm.model,
                }
            )
            break

        if not merged:
            from pddl_checks import safe_name
            target=safe_name(right_name,final_actions)
            action=deepcopy(right_action);action[1]=target;final_actions[target]=action
            replace_current_name(right.action_maps,right_name,target)

    return final_actions


def merge_metadata(left: Domain, right: Domain) -> tuple[dict[str, str], list[dict[str, Any]]]:
    from pddl_checks import rename_constant, safe_name
    decisions=[]
    for name,parent in right.types.items():
        if name in left.types and left.types[name]!=parent:
            raise ValueError(f'Conflicting type hierarchy: {name}')
    occupied=set(left.constants)|set(left.predicates)|set(right.predicates)|set(left.actions)|set(right.actions)
    for name in list(right.constants):
        if name.lower() in {n.lower() for n in occupied}:
            target=safe_name(sorted(right.sources)[0]+'__c_'+name,occupied)
            rename_constant(right,name,target)
            decisions.append({'kind':'constant','left':name,'right':name,'result':target,'reason':'preserve distinct source identity and avoid case-insensitive collisions'})
            name=target
        occupied.add(name)
    return {**left.constants,**right.constants},decisions


def fuse_pair(left: Domain, right: Domain, runtime: FusionRuntime) -> Domain:
    left = deepcopy(left)
    right = deepcopy(right)
    constants, metadata_decisions = merge_metadata(left, right)
    merge_predicates_with_llm(left, right, runtime)

    collisions = set(left.predicates) & set(right.predicates)
    for name in collisions:
        if left.predicates[name].parameters != right.predicates[name].parameters:
            raise ValueError(f"predicate merge left incompatible collision: {name}")

    actions = merge_operators_with_llm(left, right, runtime)
    predicates = {**left.predicates, **right.predicates}
    merged = Domain(
        name="unified_narrative_domain",
        requirements=left.requirements | right.requirements,
        types={**left.types, **right.types},
        constants=constants,
        predicates=predicates,
        actions=actions,
        sources=left.sources | right.sources,
        predicate_maps={**left.predicate_maps, **right.predicate_maps},
        constant_maps={**left.constant_maps, **right.constant_maps},
        action_maps={**left.action_maps, **right.action_maps},
        decisions=left.decisions + [
            decision for decision in right.decisions if decision not in left.decisions
        ] + metadata_decisions,
    )
    from pddl_checks import rename_constant, safe_name
    occupied=set(merged.constants)|set(merged.predicates)|set(merged.actions)
    for name in list(merged.constants):
        if name.lower() in {n.lower() for n in set(merged.predicates)|set(merged.actions)}:
            target=safe_name('source__c_'+name,occupied)
            rename_constant(merged,name,target);occupied.add(target)
    errors = validate_domain(merged)
    if errors:
        raise ValueError("invalid fused node: " + "; ".join(errors))
    return merged


def run(
    input_dir: Path,
    output_dir: Path,
    *,
    runtime: FusionRuntime,
    num_workers: int,
) -> Domain:
    paths = sorted(input_dir.glob("*_domainfile.pddl"), key=lambda path: path.name.lower())
    if not paths:
        raise ValueError(f"No domain files found in {input_dir}")

    if output_dir.exists() and any(output_dir.iterdir()):
        raise ValueError('Use an empty output directory; historical fusion artifacts are preserved')
    tree_dir = output_dir / "domain_fusion"
    tree_dir.mkdir(parents=True)

    current: list[tuple[int, Domain]] = []
    mapping: dict[str, int] = {}
    edges: list[dict[str, int]] = []
    for node_id, path in enumerate(paths):
        domain = parse_domain(path, apply_reviewed_semantics=False)
        current.append((node_id, domain))
        mapping[next(iter(domain.sources))] = node_id
        write_node(domain, tree_dir / str(node_id), leaf=True)

    next_id = len(current)
    with ThreadPoolExecutor(max_workers=num_workers) as executor:
        while len(current) > 1:
            odd_one_out = current[-1] if len(current) % 2 else None
            following = [odd_one_out] if odd_one_out is not None else []
            jobs: list[tuple[int, int, int, Future[Domain]]] = []
            for index in range(0, len(current) - 1, 2):
                left_id, left = current[index]
                right_id, right = current[index + 1]
                node_id = next_id
                next_id += 1
                print(
                    f"Fusing node {left_id} ({len(left.predicates)}p/{len(left.actions)}o) "
                    f"+ {right_id} ({len(right.predicates)}p/{len(right.actions)}o) "
                    f"-> {node_id}",
                    flush=True,
                )
                future = executor.submit(fuse_pair, left, right, runtime)
                jobs.append((node_id, left_id, right_id, future))
            for node_id, left_id, right_id, future in jobs:
                merged = future.result()
                write_node(merged, tree_dir / str(node_id), leaf=False)
                edges.append({"parent": node_id, "left": left_id, "right": right_id})
                following.append((node_id, merged))
            current = following

    root_id, merged = current[0]
    write_domain(merged, output_dir / "meta_domain.pddl")
    summary = domain_summary(merged)
    summary["algorithm"] = {
        "name": "UniDomain Binary Tree Fusion with structural safety guards",
        "constant_identity_policy": "preserve distinct source identities",
        "invalid_proposal_policy": "rollback and retain source variants",
        "predicate_threshold": runtime.predicate_threshold,
        "operator_threshold": runtime.operator_threshold,
        "embedding_model": runtime.embedding_model,
        "llm_provider": "Ollama",
        "node_workers": num_workers,
        "llm_model": runtime.llm.model,
    }
    (output_dir / "meta_domain.json").write_text(
        json.dumps(summary, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    (output_dir / "mapping_table.json").write_text(
        json.dumps(mapping, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    (output_dir / "fusion_tree.json").write_text(
        json.dumps({"root": root_id, "edges": edges}, indent=2) + "\n",
        encoding="utf-8",
    )

    problem_dir = output_dir / "problems"
    for problem in sorted(input_dir.glob("*_problemfile.pddl"), key=lambda path: path.name.lower()):
        rewrite_problem(problem, merged, problem_dir / problem.name)

    errors = validate_domain(merged)
    for problem in problem_dir.glob("*_problemfile.pddl"):
        errors.extend(validate_problem(problem, merged))
        from unified_planning.io import PDDLReader
        try:
            PDDLReader().parse_problem(str(output_dir/'meta_domain.pddl'),str(problem))
        except Exception as exc:
            errors.append(f'{problem.name}: independent parse failed: {exc}')
    validation = {
        "valid": not errors,
        "errors": errors,
        "root_node": root_id,
        **summary["counts"],
        "problem_files": len(list(problem_dir.glob("*_problemfile.pddl"))),
        "llm_network_calls": runtime.llm.network_calls,
        "llm_cache_hits": runtime.llm.cache_hits,
        "llm_duration_seconds": runtime.llm.total_duration_seconds,
        "algorithm": summary["algorithm"],
    }
    (output_dir / "validation.json").write_text(
        json.dumps(validation, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    if errors:
        raise ValueError("strict fusion validation failed: " + "; ".join(errors))
    return merged


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, default=Path("data/narra-domains"))
    parser.add_argument("--output", type=Path, default=Path("data/merged_strict"))
    parser.add_argument("--model", default="gemma3:4b")
    parser.add_argument("--ollama-url", default="http://127.0.0.1:11434")
    parser.add_argument(
        "--embedding-model",
        default="sentence-transformers/all-mpnet-base-v2",
    )
    parser.add_argument("--predicate-threshold", type=float, default=0.3)
    parser.add_argument("--num-workers", type=int, default=4)
    parser.add_argument("--operator-threshold", type=float, default=0.3)
    parser.add_argument(
        "--cache-dir",
        type=Path,
        default=Path(".cache/unidomain_fusion"),
    )
    args = parser.parse_args()
    runtime = FusionRuntime(
        model=args.model,
        base_url=args.ollama_url,
        embedding_model=args.embedding_model,
        predicate_threshold=args.predicate_threshold,
        operator_threshold=args.operator_threshold,
        cache_dir=args.cache_dir,
    )
    merged = run(args.input, args.output, runtime=runtime, num_workers=args.num_workers)
    print(
        f"Strict fusion complete: {len(merged.sources)} domains, "
        f"{len(merged.predicates)} predicates, {len(merged.actions)} operators, "
        f"{runtime.llm.network_calls} Ollama calls.",
        flush=True,
    )


if __name__ == "__main__":
    main()

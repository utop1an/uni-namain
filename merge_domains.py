"""Fuse narrative PDDL domains with UniDomain's binary-tree strategy.

The official UniDomain implementation uses sentence embeddings to shortlist
predicate/action pairs and an LLM to approve semantic merges.  This repository
does not contain API credentials, so the semantic approvals for this dataset are
recorded explicitly in ``SEMANTIC_PREDICATE_GROUPS``.  The remainder of the
pipeline follows the paper/code structure: bottom-up balanced binary fusion,
predicate alignment before operator alignment, and auditable intermediate nodes.

Unlike the upstream parser/generator, this adapter preserves requirements,
types, constants, and creates problem files that point at the fused domain.
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
from copy import deepcopy
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterable


SExpr = str | list["SExpr"]
LOGICAL_FORMS = {"and", "or", "not", "imply", "exists", "forall", "when"}
BUILT_INS = LOGICAL_FORMS | {"=", ">", "<", ">=", "<=", "+", "-", "*", "/"}

# These names have the same binary relation: an object is at a location.  This
# is the only non-name-based semantic merge approved for the current dataset.
# More specific relations such as gold_at and stone_at remain separate, in line
# with UniDomain's rule not to merge subset/containing relationships.
SEMANTIC_PREDICATE_GROUPS = {
    "at": {"at", "located", "entity_at", "item_at", "at_item"},
}


def strip_comments(text: str) -> str:
    return re.sub(r";[^\n\r]*", "", text)


def parse_sexpr(text: str) -> SExpr:
    tokens = re.findall(r"\(|\)|[^\s()]+", strip_comments(text))
    stack: list[list[SExpr]] = []
    current: list[SExpr] = []
    for token in tokens:
        if token == "(":
            stack.append(current)
            current = []
        elif token == ")":
            if not stack:
                raise ValueError("Unexpected ')' in PDDL")
            completed = current
            current = stack.pop()
            current.append(completed)
        else:
            current.append(token)
    if stack:
        raise ValueError("Unclosed '(' in PDDL")
    if len(current) != 1:
        raise ValueError(f"Expected one PDDL root expression, got {len(current)}")
    return current[0]


def atom(expr: SExpr) -> str:
    if not isinstance(expr, str):
        raise ValueError(f"Expected atom, got {expr!r}")
    return expr


def serialize(expr: SExpr) -> str:
    if isinstance(expr, str):
        return expr
    return "(" + " ".join(serialize(item) for item in expr) + ")"


def section(root: list[SExpr], key: str) -> list[SExpr] | None:
    for item in root:
        if isinstance(item, list) and item and item[0] == key:
            return item
    return None


def typed_symbols(tokens: Iterable[SExpr], default_type: str = "object") -> dict[str, str]:
    flat = [atom(token) for token in tokens]
    result: dict[str, str] = {}
    pending: list[str] = []
    i = 0
    while i < len(flat):
        token = flat[i]
        if token == "-":
            if i + 1 >= len(flat):
                raise ValueError("Dangling '-' in typed symbol list")
            symbol_type = flat[i + 1]
            for name in pending:
                result[name] = symbol_type
            pending.clear()
            i += 2
        else:
            pending.append(token)
            i += 1
    for name in pending:
        result[name] = default_type
    return result


def format_typed_symbols(symbols: dict[str, str], indent: str) -> list[str]:
    groups: dict[str, list[str]] = {}
    for name, symbol_type in symbols.items():
        groups.setdefault(symbol_type, []).append(name)
    lines = []
    for symbol_type in sorted(groups):
        names = " ".join(sorted(groups[symbol_type], key=str.lower))
        lines.append(f"{indent}{names} - {symbol_type}")
    return lines


@dataclass
class Predicate:
    name: str
    parameters: list[tuple[str, str]]

    @property
    def arity(self) -> int:
        return len(self.parameters)

    def to_expr(self) -> list[SExpr]:
        values: list[SExpr] = [self.name]
        for variable, variable_type in self.parameters:
            values.extend([variable, "-", variable_type])
        return values


@dataclass
class Domain:
    name: str
    requirements: set[str]
    types: dict[str, str]
    constants: dict[str, str]
    predicates: dict[str, Predicate]
    actions: dict[str, list[SExpr]]
    sources: set[str]
    predicate_maps: dict[str, dict[str, str]] = field(default_factory=dict)
    constant_maps: dict[str, dict[str, str]] = field(default_factory=dict)
    action_maps: dict[str, dict[str, str]] = field(default_factory=dict)
    decisions: list[dict[str, Any]] = field(default_factory=list)


def parse_domain(path: Path, *, apply_reviewed_semantics: bool = True) -> Domain:
    root = parse_sexpr(path.read_text(encoding="utf-8"))
    if not isinstance(root, list) or not root or root[0] != "define":
        raise ValueError(f"{path}: not a PDDL define expression")
    header = root[1]
    if not isinstance(header, list) or len(header) < 2 or header[0] != "domain":
        raise ValueError(f"{path}: missing domain header")

    source = path.name.removesuffix("_domainfile.pddl")
    requirements_expr = section(root, ":requirements") or [":requirements"]
    requirements = {atom(value) for value in requirements_expr[1:]}
    requirements.update({":strips", ":typing"})

    types_expr = section(root, ":types") or [":types"]
    types = typed_symbols(types_expr[1:])
    constants_expr = section(root, ":constants") or [":constants"]
    constants = typed_symbols(constants_expr[1:])

    predicates_expr = section(root, ":predicates")
    if predicates_expr is None:
        raise ValueError(f"{path}: missing :predicates")
    predicates: dict[str, Predicate] = {}
    for pred_expr in predicates_expr[1:]:
        if not isinstance(pred_expr, list) or not pred_expr:
            continue
        pred_name = atom(pred_expr[0])
        params = list(typed_symbols(pred_expr[1:]).items())
        predicates[pred_name] = Predicate(pred_name, params)

    actions: dict[str, list[SExpr]] = {}
    for item in root[2:]:
        if isinstance(item, list) and len(item) >= 2 and item[0] == ":action":
            actions[atom(item[1])] = item

    domain = Domain(
        name=atom(header[1]),
        requirements=requirements,
        types=types,
        constants=constants,
        predicates=predicates,
        actions=actions,
        sources={source},
        predicate_maps={source: {name: name for name in predicates}},
        constant_maps={source: {name: name for name in constants}},
        action_maps={source: {name: name for name in actions}},
    )
    if apply_reviewed_semantics:
        apply_semantic_predicate_groups(domain)
    return domain


def rewrite_expr(
    expr: SExpr,
    *,
    predicate_names: dict[str, str] | None = None,
    symbols: dict[str, str] | None = None,
) -> SExpr:
    predicate_names = predicate_names or {}
    symbols = symbols or {}
    if isinstance(expr, str):
        return symbols.get(expr, expr)
    if not expr:
        return []
    rewritten = [rewrite_expr(item, predicate_names=predicate_names, symbols=symbols) for item in expr]
    if isinstance(rewritten[0], str) and rewritten[0] in predicate_names:
        rewritten[0] = predicate_names[rewritten[0]]
    return rewritten


def replace_current_name(maps: dict[str, dict[str, str]], old: str, new: str) -> None:
    for source_map in maps.values():
        for original, current in list(source_map.items()):
            if current == old:
                source_map[original] = new


def apply_semantic_predicate_groups(domain: Domain) -> None:
    for canonical, aliases in SEMANTIC_PREDICATE_GROUPS.items():
        present = [name for name in domain.predicates if name in aliases]
        if not present:
            continue
        merged = Predicate(canonical, [("?obj", "object"), ("?loc", "location")])
        for old_name in present:
            if domain.predicates[old_name].arity != merged.arity:
                continue
            if old_name != canonical:
                domain.actions = {
                    name: rewrite_expr(action, predicate_names={old_name: canonical})
                    for name, action in domain.actions.items()
                }
                replace_current_name(domain.predicate_maps, old_name, canonical)
                domain.decisions.append(
                    {"kind": "predicate", "left": old_name, "right": canonical, "result": canonical,
                     "reason": "reviewed semantic equivalence"}
                )
            del domain.predicates[old_name]
        domain.predicates[canonical] = merged


def type_ancestors(symbol_type: str, types: dict[str, str]) -> list[str]:
    result = [symbol_type]
    seen = set(result)
    while symbol_type in types and types[symbol_type] not in seen:
        symbol_type = types[symbol_type]
        result.append(symbol_type)
        seen.add(symbol_type)
    if "object" not in seen:
        result.append("object")
    return result


def common_type(left: str, right: str, types: dict[str, str]) -> str:
    right_ancestors = set(type_ancestors(right, types))
    return next((item for item in type_ancestors(left, types) if item in right_ancestors), "object")


def unique_name(base: str, occupied: set[str], source_label: str) -> str:
    candidate = f"{source_label.lower()}_{base}"
    suffix = 2
    while candidate in occupied:
        candidate = f"{source_label.lower()}_{base}_{suffix}"
        suffix += 1
    return candidate


def merge_domains(left: Domain, right: Domain) -> Domain:
    left = deepcopy(left)
    right = deepcopy(right)
    source_label = sorted(right.sources, key=str.lower)[0]
    types = {**left.types, **right.types}
    decisions = left.decisions + right.decisions

    from pddl_checks import rename_constant, safe_name
    constants = dict(left.constants)
    occupied=set(constants) | set(left.predicates) | set(right.predicates) | set(left.actions) | set(right.actions)
    for name in list(right.constants):
        if name.lower() in {n.lower() for n in occupied}:
            new_name=safe_name(source_label+'__c_'+name,occupied)
            rename_constant(right,name,new_name)
            decisions.append({'kind':'constant','left':name,'right':name,'result':new_name,'reason':'preserve distinct source identity and avoid name collision'})
            name=new_name
        constants[name]=right.constants[name];occupied.add(name)
    for name in list(left.constants):
        if name.lower() in {n.lower() for n in set(left.predicates)|set(right.predicates)|set(left.actions)|set(right.actions)}:
            new_name=safe_name('source__c_'+name,occupied)
            rename_constant(left,name,new_name);constants.pop(name);constants[new_name]=left.constants[new_name];occupied.add(new_name)

    predicates = deepcopy(left.predicates)
    for name, right_pred in list(right.predicates.items()):
        if name not in predicates:
            predicates[name] = deepcopy(right_pred)
            continue
        left_pred = predicates[name]
        if left_pred.arity == right_pred.arity:
            parameters = []
            for index, ((left_var, left_type), (_, right_type)) in enumerate(
                zip(left_pred.parameters, right_pred.parameters)
            ):
                variable = left_var if left_var.startswith("?") else f"?arg{index + 1}"
                parameters.append((variable, common_type(left_type, right_type, types)))
            predicates[name] = Predicate(name, parameters)
            if left_pred.parameters != right_pred.parameters:
                decisions.append(
                    {"kind": "predicate", "left": name, "right": name, "result": name,
                     "reason": "same-name merge with compatible arity and generalized types"}
                )
        else:
            new_name = unique_name(name, set(predicates), source_label)
            right.actions = {
                action_name: rewrite_expr(action, predicate_names={name: new_name})
                for action_name, action in right.actions.items()
            }
            replace_current_name(right.predicate_maps, name, new_name)
            renamed = deepcopy(right_pred)
            renamed.name = new_name
            predicates[new_name] = renamed
            decisions.append(
                {"kind": "predicate", "left": name, "right": name, "result": new_name,
                 "reason": "same name with incompatible arity"}
            )

    actions = deepcopy(left.actions)
    for name, action in list(right.actions.items()):
        if name not in actions:
            actions[name] = action
        elif serialize(actions[name]).lower() == serialize(action).lower():
            decisions.append(
                {"kind": "operator", "left": name, "right": name, "result": name,
                 "reason": "structurally identical operator"}
            )
        else:
            new_name = unique_name(name, set(actions), source_label)
            renamed_action = deepcopy(action)
            renamed_action[1] = new_name
            actions[new_name] = renamed_action
            replace_current_name(right.action_maps, name, new_name)
            decisions.append(
                {"kind": "operator", "left": name, "right": name, "result": new_name,
                 "reason": "same name but different operator structure"}
            )

    return Domain(
        name="unified_narrative_domain",
        requirements=left.requirements | right.requirements,
        types=types,
        constants=constants,
        predicates=predicates,
        actions=actions,
        sources=left.sources | right.sources,
        predicate_maps={**left.predicate_maps, **right.predicate_maps},
        constant_maps={**left.constant_maps, **right.constant_maps},
        action_maps={**left.action_maps, **right.action_maps},
        decisions=decisions,
    )


def write_domain(domain: Domain, path: Path) -> None:
    lines = [f"(define (domain {domain.name})"]
    lines.append("  (:requirements " + " ".join(sorted(domain.requirements)) + ")")
    if domain.types:
        lines.append("  (:types")
        lines.extend(format_typed_symbols(domain.types, "    "))
        lines.append("  )")
    if domain.constants:
        lines.append("  (:constants")
        lines.extend(format_typed_symbols(domain.constants, "    "))
        lines.append("  )")
    lines.append("  (:predicates")
    for name in sorted(domain.predicates, key=str.lower):
        lines.append("    " + serialize(domain.predicates[name].to_expr()))
    lines.append("  )")
    for name in sorted(domain.actions, key=str.lower):
        action = domain.actions[name]
        lines.append("")
        lines.append(f"  (:action {name}")
        i = 2
        while i < len(action):
            key = atom(action[i])
            value = action[i + 1] if i + 1 < len(action) else []
            lines.append(f"    {key} {serialize(value)}")
            i += 2
        lines.append("  )")
    lines.append(")")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def domain_summary(domain: Domain) -> dict[str, Any]:
    return {
        "sources": sorted(domain.sources, key=str.lower),
        "counts": {
            "requirements": len(domain.requirements),
            "types": len(domain.types),
            "constants": len(domain.constants),
            "predicates": len(domain.predicates),
            "operators": len(domain.actions),
        },
        "predicate_maps": domain.predicate_maps,
        "constant_maps": domain.constant_maps,
        "action_maps": domain.action_maps,
        "decisions": domain.decisions,
    }


def write_node(domain: Domain, node_dir: Path, *, leaf: bool) -> None:
    filename = "atomic_domain.pddl" if leaf else "meta_domain.pddl"
    write_domain(domain, node_dir / filename)
    (node_dir / ("atomic_domain.json" if leaf else "meta_domain.json")).write_text(
        json.dumps(domain_summary(domain), indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )


def rewrite_problem(path: Path, domain: Domain, output_path: Path) -> None:
    source = path.name.removesuffix("_problemfile.pddl")
    root = parse_sexpr(path.read_text(encoding="utf-8"))
    if not isinstance(root, list):
        raise ValueError(f"{path}: invalid problem root")
    pred_map = domain.predicate_maps[source]
    constant_map = domain.constant_maps[source]
    def formula(expr):
        if not isinstance(expr,list) or not expr:return expr
        head=expr[0]
        if head in ('and','or','not','imply','when'):return [head,*[formula(x) for x in expr[1:]]]
        if head in ('exists','forall'):return [head,expr[1],formula(expr[2])]
        return [pred_map.get(head,head),*[constant_map.get(x,x) if isinstance(x,str) else formula(x) for x in expr[1:]]]
    # Rename constants only in term positions, never a same-spelled predicate or type.
    rewritten = [root[0],root[1],*[([part[0],*[formula(x) for x in part[1:]]] if part[0] in (':init',':goal') else part) for part in root[2:]]]
    assert isinstance(rewritten, list)
    domain_decl = section(rewritten, ":domain")
    if domain_decl is None:
        raise ValueError(f"{path}: missing :domain")
    domain_decl[1] = domain.name
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(serialize(rewritten) + "\n", encoding="utf-8")


def called_predicates(expr: SExpr) -> set[str]:
    if isinstance(expr, str) or not expr:
        return set()
    head = atom(expr[0]) if isinstance(expr[0], str) else ""
    if head in {"exists", "forall"}:
        return called_predicates(expr[-1])
    if head in LOGICAL_FORMS:
        result: set[str] = set()
        for item in expr[1:]:
            result.update(called_predicates(item))
        return result
    if head.startswith(":") or head in BUILT_INS:
        return set()
    return {head}


def validate_domain(domain: Domain) -> list[str]:
    from pddl_checks import check_domain
    return check_domain(domain)


def validate_problem(path: Path, domain: Domain) -> list[str]:
    root = parse_sexpr(path.read_text(encoding="utf-8"))
    assert isinstance(root, list)
    errors: list[str] = []
    domain_decl = section(root, ":domain")
    if domain_decl is None or len(domain_decl) < 2 or domain_decl[1] != domain.name:
        errors.append(f"{path.name}: domain reference is not {domain.name}")
    used: set[str] = set()
    for key in (":init", ":goal"):
        value = section(root, key)
        if value:
            for expr in value[1:]:
                used.update(called_predicates(expr))
    missing = used - set(domain.predicates)
    if missing:
        errors.append(f"{path.name}: undeclared predicates {sorted(missing)}")
    return errors


def run(input_dir: Path, output_dir: Path) -> Domain:
    domain_paths = sorted(input_dir.glob("*_domainfile.pddl"), key=lambda p: p.name.lower())
    if not domain_paths:
        raise ValueError(f"No *_domainfile.pddl files found under {input_dir}")

    if output_dir.exists():
        shutil.rmtree(output_dir)
    tree_dir = output_dir / "domain_fusion"
    tree_dir.mkdir(parents=True)

    current: list[tuple[int, Domain]] = []
    mapping: dict[str, int] = {}
    tree_edges: list[dict[str, int]] = []
    for node_id, path in enumerate(domain_paths):
        domain = parse_domain(path)
        current.append((node_id, domain))
        mapping[next(iter(domain.sources))] = node_id
        write_node(domain, tree_dir / str(node_id), leaf=True)

    next_id = len(current)
    while len(current) > 1:
        following: list[tuple[int, Domain]] = []
        for index in range(0, len(current) - 1, 2):
            left_id, left = current[index]
            right_id, right = current[index + 1]
            merged = merge_domains(left, right)
            write_node(merged, tree_dir / str(next_id), leaf=False)
            tree_edges.append({"parent": next_id, "left": left_id, "right": right_id})
            following.append((next_id, merged))
            next_id += 1
        if len(current) % 2:
            following.append(current[-1])
        current = following

    root_id, merged = current[0]
    write_domain(merged, output_dir / "meta_domain.pddl")
    (output_dir / "meta_domain.json").write_text(
        json.dumps(domain_summary(merged), indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    (output_dir / "mapping_table.json").write_text(
        json.dumps(mapping, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    (output_dir / "fusion_tree.json").write_text(
        json.dumps({"root": root_id, "edges": tree_edges}, indent=2) + "\n", encoding="utf-8"
    )

    problems_dir = output_dir / "problems"
    for problem_path in sorted(input_dir.glob("*_problemfile.pddl"), key=lambda p: p.name.lower()):
        rewrite_problem(problem_path, merged, problems_dir / problem_path.name)

    errors = validate_domain(merged)
    for problem_path in problems_dir.glob("*_problemfile.pddl"):
        errors.extend(validate_problem(problem_path, merged))
    validation = {
        "valid": not errors,
        "errors": errors,
        "root_node": root_id,
        **domain_summary(merged)["counts"],
        "problem_files": len(list(problems_dir.glob("*_problemfile.pddl"))),
    }
    (output_dir / "validation.json").write_text(
        json.dumps(validation, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    if errors:
        raise ValueError("Merged artifacts failed validation:\n" + "\n".join(errors))
    return merged


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, default=Path("data/narra-domains"))
    parser.add_argument("--output", type=Path, default=Path("data/merged"))
    args = parser.parse_args()
    merged = run(args.input, args.output)
    counts = domain_summary(merged)["counts"]
    print(
        f"Merged {len(merged.sources)} domains into {args.output / 'meta_domain.pddl'} "
        f"({counts['predicates']} predicates, {counts['operators']} operators)."
    )


if __name__ == "__main__":
    main()

"""PDDL syntax, source models, structural checks and deterministic export.

Parsing never applies semantic correspondences. Historical authored alias groups
and the offline binary merge baseline live explicitly in archive.domain_merge.
"""
from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterable

SExpr = str | list["SExpr"]

LOGICAL_FORMS = {"and", "or", "not", "imply", "exists", "forall", "when"}

BUILT_INS = LOGICAL_FORMS | {"=", ">", "<", ">=", "<=", "+", "-", "*", "/"}


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


def parse_domain(path: Path) -> Domain:
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


def is_type_compatible(actual: str, expected: str, types: dict[str, str]) -> bool:
    """Check source type membership using the same cycle-safe ancestor rules."""
    return expected in type_ancestors(actual, types)


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
    from rcnc.pddl_checks import check_domain
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

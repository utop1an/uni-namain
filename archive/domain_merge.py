"""Historical offline semantic-alias and same-name binary merge baseline.

These authored alias groups are not independent semantic annotations. The current
request workflow and local UniDomain adapter use rcnc.pddl directly instead.
"""
from __future__ import annotations

import argparse
import json
import shutil
from copy import deepcopy
from pathlib import Path

from rcnc.pddl import (
    Domain, Predicate, common_type, domain_summary, replace_current_name, rewrite_expr,
    rewrite_problem, serialize, unique_name, validate_domain, validate_problem, write_domain,
    write_node,
)
from rcnc.pddl import parse_domain as parse_source_domain


SEMANTIC_PREDICATE_GROUPS = {
    "at": {"at", "located", "entity_at", "item_at", "at_item"},
}


def parse_domain(path: Path, *, apply_reviewed_semantics: bool = True) -> Domain:
    """Retain the historical baseline's explicit semantic-override policy."""
    domain = parse_source_domain(path)
    if apply_reviewed_semantics:
        apply_semantic_predicate_groups(domain)
    return domain


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


def merge_domains(left: Domain, right: Domain) -> Domain:
    left = deepcopy(left)
    right = deepcopy(right)
    source_label = sorted(right.sources, key=str.lower)[0]
    types = {**left.types, **right.types}
    decisions = left.decisions + right.decisions

    from rcnc.pddl_checks import rename_constant, safe_name
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

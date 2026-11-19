"""Map registered worlds to completed official UniDomain roots without repairing their rules."""

import argparse
from collections import Counter
from pathlib import Path
from types import SimpleNamespace

from rcnc.glaive_intake import casefold_tree
from rcnc.glaive_merge import action_fields, conjunction, rewrite, translate_plan
from rcnc.pddl import parse_sexpr, section, typed_symbols
from rcnc.revised_probe_validation import replay_physical
from scripts.experiments.run_downward_reference import run, save, sha
from scripts.experiments.run_matched_unidomain_rule import PARENT, PLANNER, pddl, physical_problem
from scripts.experiments.run_official_unidomain_matched import PRIOR, read


class UnsupportedMapping(ValueError):
    pass


def parse(text):
    return casefold_tree(parse_sexpr(text))


def tree(path):
    return parse(Path(path).read_text(encoding="utf-8"))


def arguments(expr, action=False):
    return typed_symbols(action_fields(expr)[":parameters"] if action else expr[1:])


def rename(old, new, action=False):
    a, b = list(arguments(old, action)), list(arguments(new, action))
    if len(a) != len(b):
        raise UnsupportedMapping(f"Official change to parameter arity ({len(a)} to {len(b)})")
    missing = [i for i, var in enumerate(a) if var not in b]
    if len(missing) > 1:
        raise UnsupportedMapping("No independently identifiable argument permutation")
    return (new[1] if action else new[0],
            [a.index(v) if v in a else missing[0] for v in b])


def remap(entries, transforms):
    result = {}
    for ref, (name, order) in entries.items():
        target, permutation = transforms.get(name, (name, list(range(len(order)))))
        result[ref] = (target, [order[j] for j in permutation])
    return result


def leaf(path):
    source = path.stem
    data = read(path)
    predicates, actions = {}, {}
    for signature in data["predicates"]:
        exp = parse(signature)
        predicates[(source, exp[0])] = (exp[0], list(range(len(arguments(exp)))))
    for text in data["operators"].values():
        exp = parse(text)
        actions[(source, exp[1])] = (exp[1], list(range(len(arguments(exp, True)))))
    return predicates, actions


def lineage(row):
    resolved = {}
    for node in row["nodes"]:
        path = Path(node["domain"])
        if sha(path) != node["sha256"]:
            raise ValueError("Official model hash mismatch")
        halves = []
        for side in ("left", "right"):
            source = Path(node[side])
            halves.append(leaf(source) if source.parent.name == "atomic" else resolved[source])
        pred_edits = [{}, {}]
        action_edits = [{}, {}]
        pred_aliases = [x[0] for x in halves]
        action_aliases = [x[1] for x in halves]
        matched_common = set()
        events = read(path.with_name("decisions.json"))["events"]
        for event in events:
            kind, inputs, outcome = event["kind"], event["input"], event["output"]
            if kind == "predicate_rewrite":
                old, new = parse(inputs["action_string"]), parse(outcome)
                mapping = rename(old, new, True)
                if old[1] != mapping[0] or mapping[1] != list(range(len(mapping[1]))):
                    sides = [i for i, aliases in enumerate(action_aliases)
                             if any(name == old[1] for name, _ in aliases.values())]
                    if len(sides) != 1:
                        raise UnsupportedMapping("Ambiguous action ownership during predicate rewrite")
                    i = sides[0]
                    action_aliases[i] = remap(action_aliases[i], {old[1]: mapping})
            elif kind == "predicate" and outcome[0]:
                new = parse(outcome[1][0])
                for i in range(2):
                    old = parse(inputs[f"predicate_in_domain_{i+1}"].split(" ; ", 1)[0])
                    pred_edits[i][old[0]] = rename(old, new)
            elif kind == "operator" and outcome[0]:
                new = parse(outcome[2])
                old = [parse(inputs[f"action_in_domain_{i+1}"]) for i in range(2)]
                if old[0][1] == old[1][1]:
                    matched_common.add(old[0][1])
                for i in range(2):
                    action_edits[i][old[i][1]] = rename(old[i], new, True)
        names = [set(name for name, _ in actions.values()) for actions in action_aliases]
        # The official implementation inserts unmerged right operators into a
        # dict after the left operators. A same-name right action can replace
        # an unmerged left action without an accepted semantic merge.
        overwritten = (names[0] & names[1]) - matched_common
        if any(n in action_edits[0] or n in action_edits[1] for n in overwritten):
            raise UnsupportedMapping("Same-name collision with a concurrent operator merge")
        retained_left = {ref: pair for ref, pair in action_aliases[0].items() if pair[0] not in overwritten}
        predicates = remap(pred_aliases[0], pred_edits[0]) | remap(pred_aliases[1], pred_edits[1])
        actions = remap(retained_left, action_edits[0]) | remap(action_aliases[1], action_edits[1])
        actual = {parse(text)[1] for text in read(path)["operators"].values()}
        if actual != {name for name, _ in actions.values()}:
            raise UnsupportedMapping("Official operators differ from reconstructed names")
        resolved[path] = predicates, actions
    return resolved[Path(row["domain"])]


def project_model(root, predicate_lineage, action_lineage, union, union_map, output):
    original = tree(union)
    auxiliary = [p for p in section(original, ":predicates")[1:]
                 if any(p[0] == sid + "_active" or p[0].startswith(sid + "_type_")
                        for sid in union_map["predicate_maps"])]
    known_guards = {p[0] for p in auxiliary}
    constant_section = section(original, ":constants") or [":constants"]
    root_data = read(root)
    declarations = {}
    for signature in root_data["predicates"]:
        expr = parse(signature)
        name = expr[0]
        arity = len(arguments(expr))
        if name in known_guards or (name in declarations and declarations[name] != arity):
            raise UnsupportedMapping("Conflicting predicate declarations")
        declarations[name] = arity
    if any(name not in declarations or declarations[name] != len(order)
           for name, order in predicate_lineage.values()):
        raise UnsupportedMapping("Mapped predicate absent or changed arity")
    declared = {name: (name, list(range(arity))) for name, arity in declarations.items()}
    parameters = {}
    for action in original:
        if isinstance(action, list) and action[:1] == [":action"]:
            parameters[action[1]] = list(arguments(action, True))
    union_actions = union_map["action_maps"]
    guard_types = {}
    for action in original:
        if not isinstance(action, list) or action[:1] != [":action"]:
            continue
        fields = action_fields(action)
        formals = parameters[action[1]]
        condition = fields[":precondition"]
        parts = condition[1:] if condition[0] == "and" else [condition]
        lookup = {a[1]: a[0] for a in parts if len(a) == 2 and a[0] in known_guards}
        guard_types[action[1]] = [lookup[v] for v in formals]
    export = ["define", ["domain", "revised_merged"], [":requirements", ":adl", ":typing", ":equality"],
              [":predicates", *auxiliary,
               *[[name, *[f"?p{i}" for i in range(arity)]] for name, arity in declarations.items()]]]
    if len(constant_section) > 1:
        export.append(constant_section)
    for text in root_data["operators"].values():
        action = parse(text)
        fields = action_fields(action)
        name, formals = action[1], list(arguments(action, True))
        origins = [(sid, original_name, order) for (sid, original_name), (target, order)
                   in action_lineage.items() if name == target]
        if not origins:
            raise UnsupportedMapping("Official operator has no verifiable source")
        guards = []
        terms = {}
        for sid, original_name, order in origins:
            if len(order) != len(formals):
                raise UnsupportedMapping("Output action parameter arity mismatch")
            ref = union_actions[sid + ":" + original_name]
            if ref["order"] != list(range(len(order))):
                raise UnsupportedMapping("Unexpected source transport permutation")
            types = guard_types[ref["name"]]
            guard = [[sid + "_active"], *[[types[i], formals[j]] for j, i in enumerate(order)]]
            for var, typ in arguments(action, True).items():
                if typ != "object":
                    literal = sid + "_type_" + typ
                    if literal not in known_guards:
                        raise UnsupportedMapping("Official output type absent from source")
                    guard.append([literal, var])
            guards.append(conjunction(guard))
            for before, after in union_map["constant_maps"][sid].items():
                if before in terms and terms[before] != after:
                    raise UnsupportedMapping("Ambiguous constant ownership in official action")
                terms[before] = after
        quantifier_source = None
        if len({sid for sid, _, _ in origins}) == 1:
            sid = origins[0][0]
            prefix = sid + "_type_"
            quantifier_source = SimpleNamespace(id=sid, type_parents={
                x[len(prefix):]: "object" for x in known_guards if x.startswith(prefix) and x != prefix + "object"})
        pre = rewrite(fields[":precondition"], quantifier_source, declared, terms)
        eff = rewrite(fields[":effect"], quantifier_source, declared, terms, context="effect")
        export.append([":action", name, ":parameters", formals, ":precondition",
                       ["and", guards[0] if len(guards) == 1 else ["or", *guards], pre],
                       ":effect", eff])
    pddl(output, export)


def mapped_world(path, union_map, predicate_lineage, output):
    targets = {}
    for sid, predicates in union_map["predicate_maps"].items():
        for name, (compiled, order) in predicates.items():
            target, output_order = predicate_lineage[(sid, name)]
            targets[compiled] = (target, [order.index(i) for i in output_order])

    def translate(expr):
        if not isinstance(expr, list) or not expr:
            return expr
        if expr[0] in targets:
            name, order = targets[expr[0]]
            return [name, *[expr[i + 1] for i in order]]
        return [translate(x) for x in expr]

    problem = translate(tree(path))
    return pddl(output, physical_problem(problem))


def evaluate(root, phase, output, search):
    output.mkdir(parents=True, exist_ok=False)
    experiment = read(root / "protocol.json")
    prior = read(PRIOR / "report.json")
    assert sha(PRIOR / "protocol.json") == experiment["parent_protocol_sha256"]
    official = read(root / phase / "report.json")
    assert official["status"] == "terminal"
    inputs = {f: sha(f) for f in (root / "protocol.json", root / phase / "report.json",
                                 PRIOR / "protocol.json", PRIOR / "report.json")}
    union_tasks = {r["group"]: r for r in read(PARENT / "composition_tasks.json")["tasks"]
                   if r["condition"] == "union"}
    union_worlds = {(r["group"], r["world"]): r for r in read(PARENT / "original_tasks.json")["tasks"]
                    if r["condition"] == "union"}
    bundle = output / "bundle"
    bundle.mkdir()
    tasks, groups, transports = [], [], []
    for row in official["rows"]:
        gid = row["group"]
        g = {"group": gid, "fusion_status": row["status"]}
        groups.append(g)
        if row["status"] != "official_root_constructed":
            g["status"] = row["status"]
            continue
        dest = output / gid
        dest.mkdir()
        try:
            predicates, actions = lineage(row)
            task = union_tasks[gid]
            union = read(task["mapping"])
            domain = dest / "domain.pddl"
            project_model(row["domain"], predicates, actions, task["domain"], union, domain)
        except (ValueError, KeyError, TypeError, IndexError) as exc:
            g.update(status="unsupported_official_export", reason=str(exc))
            continue
        g["status"] = "model_exported"
        if experiment["groups"][gid]["search_status"] == "ready":
            try:
                d = bundle / "tasks" / gid
                d.mkdir(parents=True)
                problem = d / "problem.pddl"
                mapped_world(task["problem"], union, predicates, problem)
                (d / "domain.pddl").write_bytes(domain.read_bytes())
                tasks.append({"id": gid, "source": gid, "representation": "official_unidomain",
                              "domain_sha256": sha(domain), "problem_sha256": sha(problem)})
            except (ValueError, KeyError, TypeError, IndexError) as exc:
                g.update(status="unsupported_official_world", reason=str(exc))
        translated = {"action_maps": {f"{sid}:{name}": {"name": target, "order": order}
                                      for (sid, name), (target, order) in actions.items()}}
        for t in experiment["original_reference_slots"]:
            if t["group"] != gid or t["reference"].get("validation_level") != "dual_validated":
                continue
            r = {"id": t["id"], "group": gid, "world": t["world"]}
            try:
                entry = union_worlds[gid, t["world"]]
                problem = dest / f'{t["world"]}.problem.pddl'
                plan = dest / f'{t["world"]}.plan.pddl'
                mapped_world(entry["problem"], union, predicates, problem)
                ref = t["reference"]
                if sha(Path(ref["source_plan"])) != ref["source_plan_sha256"]:
                    raise ValueError("Historical reference plan hash changed")
                original_calls = section(tree(ref["source_plan"]), ":steps")[1:]
                if any(f'{t["source"]}:{call[0]}' not in translated["action_maps"] for call in original_calls):
                    r.update(status="source_action_absent")
                    transports.append(r)
                    continue
                translate_plan(t["source"], translated, entry["terms"], ref["source_plan"], plan)
                value = tree(plan)
                section(value, ":problem")[1] = section(tree(problem), "problem")[1]
                pddl(plan, value)
                result = replay_physical(domain, problem, plan)
                result.pop("applied", None)
                r.update(result)
            except (ValueError, KeyError, TypeError, IndexError) as exc:
                r.update(status="unsupported_official_transport", reason=str(exc))
            transports.append(r)
    budget = experiment["search_budget"]
    save(bundle / "manifest.json", {"status": "frozen_before_search", "mode": "matched_source_representations",
                                    "task_count": len(tasks), "tasks": tasks, "budget": budget})
    if search and tasks:
        run(Path("."), None, output / "solver", PLANNER,
            budget["wall_seconds"], budget["memory_mb"], task_bundle=bundle)
    assert all(sha(f) == v for f, v in inputs.items())
    report = {"status": "pilot_terminal" if phase != "fusion" else "official_evaluation_terminal",
              "group_rows": groups, "transport_rows": transports,
              "transport_counts": dict(Counter(r["status"] for r in transports)),
              "model_counts": dict(Counter(r["status"] for r in groups)),
              "ready_search_tasks": len(tasks), "search_budget": budget,
              "prior_rule_report_sha256": sha(PRIOR / "report.json")}
    save(output / "report.json", report)
    print({k: v for k, v in report.items() if k != "transport_rows"})


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path)
    parser.add_argument("phase", choices=("pilot", "diagnostic-pilot", "fusion"))
    parser.add_argument("output", type=Path)
    parser.add_argument("--search", action="store_true")
    args = parser.parse_args()
    evaluate(args.root, args.phase, args.output, args.search)

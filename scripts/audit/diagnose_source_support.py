"""Conservative predicate-level reachability certificates, without source repair.

Ignore bindings, negative conditions, equality, universal preconditions and
conditional-effect guards. This enlarges reachability: failure in this relaxed
model is an obstruction; success says nothing about concrete solvability.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path

from rcnc.pddl import (
    parse_domain, parse_sexpr, section, serialize, validate_domain, validate_problem,
)


def possible(expr, reachable):
    if not isinstance(expr, list) or not expr or not isinstance(expr[0], str):
        raise ValueError('Malformed Boolean formula')
    head = expr[0].lower()
    if head == 'and':
        return all(possible(child, reachable) for child in expr[1:])
    if head == 'or':
        return any(possible(child, reachable) for child in expr[1:])
    if head in ('not', '=', 'forall', 'imply'):
        # Universal truth does not imply a predicate instance exists when its
        # type extension is empty. Dropping the entire condition is safe.
        return True
    if head == 'exists':
        return possible(expr[2], reachable)
    if any(isinstance(term, list) for term in expr[1:]):
        raise ValueError('Unsupported nested predicate argument')
    return head in reachable


def additions(expr):
    if not isinstance(expr, list) or not expr:
        raise ValueError('Malformed effect')
    head = expr[0].lower()
    if head == 'and':
        return set().union(*(additions(child) for child in expr[1:]))
    if head == 'not':
        return set()
    if head in ('when', 'forall'):
        return additions(expr[2])
    if head in ('assign', 'increase', 'decrease', 'scale-up', 'scale-down', 'probabilistic', 'oneof') or any(isinstance(t, list) for t in expr[1:]):
        raise ValueError('Unsupported non-Boolean or nondeterministic effect')
    return {head}


def positive_goal_atoms(expr):
    head = expr[0].lower()
    if head in ('and', 'or'):
        return [atom for child in expr[1:] for atom in positive_goal_atoms(child)]
    if head == 'exists':
        return positive_goal_atoms(expr[2])
    if head in ('not', '=', 'forall', 'imply'):
        return []
    return [expr]


def diagnose(domain_path, problem_path):
    domain = parse_domain(domain_path)
    errors = validate_domain(domain) + validate_problem(problem_path, domain)
    if errors:
        raise ValueError('Invalid source structure: ' + '; '.join(errors))
    root = parse_sexpr(domain_path.read_text(encoding='utf-8'))
    allowed = {'domain', ':requirements', ':types', ':constants', ':predicates', ':action'}
    if any(part[0] not in allowed for part in root[1:]):
        raise ValueError('Unsupported domain section')
    problem = parse_sexpr(problem_path.read_text(encoding='utf-8'))
    if any(part[0] not in ('problem', ':domain', ':objects', ':init', ':goal') for part in problem[1:]):
        raise ValueError('Unsupported problem section')
    initial = section(problem, ':init')[1:]
    if any(not isinstance(atom, list) or not atom or atom[0] in ('=', 'assign') for atom in initial):
        raise ValueError('Unsupported initial state')
    goal = section(problem, ':goal')[1]
    reachable = {atom[0].lower() for atom in initial if atom[0].lower() != 'not'}
    initial_predicates = sorted(reachable)
    rules = []
    for name, action in sorted(domain.actions.items()):
        fields = {action[i]: action[i+1] for i in range(2, len(action), 2)}
        if set(fields) - {':parameters', ':precondition', ':effect'}:
            raise ValueError('Unsupported action field')
        pre = fields.get(':precondition', ['and'])
        effects = additions(fields.get(':effect', ['and']))
        rules.append({'action': name, 'condition': pre, 'adds': sorted(effects)})
    layers = []
    fired = set()
    while True:
        available = [rule for rule in rules if rule['action'] not in fired and possible(rule['condition'], reachable)]
        if not available:
            break
        added = set().union(*(set(rule['adds']) for rule in available)) - reachable
        fired.update(rule['action'] for rule in available)
        reachable.update(added)
        layers.append({'actions': [rule['action'] for rule in available], 'new_predicates': sorted(added)})
    may_satisfy_goal = possible(goal, reachable)
    missing = [serialize(atom) for atom in positive_goal_atoms(goal) if atom[0].lower() not in reachable]
    return {'status': 'not_proved_unreachable' if may_satisfy_goal else 'predicate_relaxation_proves_unreachable',
        'initial_predicates': initial_predicates, 'reachable_predicates': sorted(reachable),
        'unreachable_goal_atoms': missing, 'goal_may_hold_in_relaxation': may_satisfy_goal,
        'layers': layers, 'unfired_actions': [rule for rule in rules if rule['action'] not in fired],
        'rules': rules, 'source_domain_sha256': hashlib.sha256(domain_path.read_bytes()).hexdigest(),
        'source_problem_sha256': hashlib.sha256(problem_path.read_bytes()).hexdigest(),
        'scope': 'Predicate-symbol over-approximation; negative/quantified constraints may be ignored; no solvability inference from a reachable abstract goal'}


def run(inputs, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    output.mkdir(parents=True)
    rows = []
    for domain in sorted(inputs.glob('*_domainfile.pddl')):
        source = domain.name.removesuffix('_domainfile.pddl')
        try:
            result = diagnose(domain, inputs/(source+'_problemfile.pddl'))
        except Exception as exc:
            result = {'status': 'unsupported_or_error', 'error': f'{type(exc).__name__}: {exc}'}
        (output/(source+'.json')).write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
        rows.append({'source': source, 'status': result['status'], 'unreachable_goal_atoms': result.get('unreachable_goal_atoms', [])})
    report = {'status': 'complete', 'source_count': len(rows), 'counts': dict(Counter(row['status'] for row in rows)),
              'rows': rows, 'implementation_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'limits': 'Development diagnostic; does not infer missing initial facts, modify sources, or prove source narrative intent'}
    (output/'report.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inputs', type=Path, default=Path('data/narra-domains'))
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(run(args.inputs, args.output), indent=2))

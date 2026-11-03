"""Conditional semantic alignment and same-effect action fusion before search.

Sense cards are versioned judgments, never semantic gold. The compiler checks
their provenance, roles and agreement, then separately checks a conservative
Boolean fragment. Unknown/rejected candidates retain their original symbols.
"""
import copy
import hashlib
import itertools
import json
import math
from pathlib import Path
import re
import shutil

from .aligned_domain import build as build_aligned
from .domain_building import (check_exported_domain, check_exported_problem,
                              digest, require_empty_output, save)
from .pddl import (Predicate, domain_summary, parse_domain, serialize,
                   typed_symbols, validate_domain, write_domain)


def symbol_digest(value):
    if isinstance(value, Predicate):
        value = [value.name, *[x for v, t in value.parameters for x in (v, '-', t)]]
    return hashlib.sha256(serialize(value).encode('utf-8')).hexdigest()


def fields(action):
    names = action[2::2]
    if len(action[2:]) % 2 or len(names) != len(set(names)):
        raise ValueError('Malformed action fields')
    result = dict(zip(names, action[3::2]))
    if set(result) != {':parameters', ':precondition', ':effect'}:
        raise ValueError('Only parameters, precondition and effect supported')
    return result


def permutation(order, arity):
    return (isinstance(order, list) and all(type(i) is int for i in order)
            and sorted(order) == list(range(arity)))


def semantic_gate(group, kind, domains, threshold):
    """Require explicit sense/role judgments tied to the exact input symbol.

    Confidence is supplied by the proposal author; it is not calibrated accuracy.
    This gate checks consistency of semantic judgments, not their truth.
    """
    verdict = group.get('model_judgment')
    if verdict is not None and verdict.get('decision') != 'compatible':
        return {'status': 'rejected' if verdict.get('decision') == 'different' else 'unknown',
                'reason': 'model_' + verdict.get('decision', 'unavailable'),
                'rationale': verdict.get('rationale', '')}
    cards = []
    for member in group.get('members', []):
        ref = member.get(kind, '')
        try:
            source, name = ref.split(':')
            symbols = domains[source].predicates if kind == 'predicate' else domains[source].actions
            value = symbols[name]
            arity = value.arity if kind == 'predicate' else len(typed_symbols(fields(value)[':parameters']))
        except (KeyError, ValueError):
            return {'status': 'unknown', 'reason': 'unknown_source_symbol', 'member': ref}
        card = member.get('semantics', {})
        if not isinstance(card, dict):
            return {'status': 'unknown', 'reason': 'missing_sense_card', 'member': ref}
        confidence = card.get('confidence')
        if (not isinstance(card, dict) or not card.get('description') or not card.get('evidence')
                or card.get('symbol_sha256') != symbol_digest(value)
                or type(confidence) not in (int, float) or not math.isfinite(confidence)
                or not 0 <= confidence <= 1 or confidence < threshold
                or not card.get('scope') or not card.get('concept')):
            return {'status': 'unknown', 'reason': 'missing_stale_or_low_confidence_sense', 'member': ref}
        if card['concept'] in {'state', 'relation', 'action', 'event'}:
            return {'status': 'rejected', 'reason': 'vacuous_common_concept', 'member': ref}
        roles = card.get('roles')
        order = member.get('order')
        if (not isinstance(roles, list) or len(roles) != arity
                or any(not isinstance(r, str) or not r for r in roles)
                or len(set(roles)) != arity or not permutation(order, arity)):
            return {'status': 'unknown', 'reason': 'incomplete_role_bijection', 'member': ref}
        cards.append((card['concept'], card['scope'], [roles[i] for i in order]))
    if len(cards) < 2:
        return {'status': 'unknown', 'reason': 'fewer_than_two_members'}
    if any(card != cards[0] for card in cards[1:]):
        return {'status': 'rejected', 'reason': 'sense_scope_or_roles_disagree', 'senses': cards}
    return {'status': 'accepted_hypothesis', 'concept': cards[0][0], 'scope': cards[0][1],
            'roles': cards[0][2], 'independently_verified': False}


def boolean(expr):
    """Canonical quantifier-free Boolean conditions; no equality assumptions."""
    if not isinstance(expr, list) or not expr:
        raise ValueError('Malformed Boolean expression')
    head = expr[0]
    if head in ('and', 'or'):
        children = []
        for part in expr[1:]:
            value = boolean(part)
            children.extend(value[1] if value[0] == head else [value])
        children = tuple(sorted(set(children), key=repr))
        return children[0] if len(children) == 1 else (head, children)
    if head == 'not' and len(expr) == 2:
        return ('not', boolean(expr[1]))
    if head in ('not', 'when', 'forall', 'exists', 'imply', '=', 'increase', 'assign'):
        raise ValueError('Unsupported Boolean fragment: ' + head)
    if any(not isinstance(x, str) for x in expr):
        raise ValueError('Function terms unsupported')
    return ('atom', tuple(expr))


def effect_literals(expr):
    if expr[0] == 'and':
        return frozenset().union(*(effect_literals(e) for e in expr[1:]))
    value = boolean(expr)
    if value[0] == 'atom' or (value[0] == 'not' and value[1][0] == 'atom'):
        return frozenset([value])
    raise ValueError('Only unconditional add/delete effects supported')


def certify_replacement(originals, replacement, max_atoms=16):
    """A sufficient all-state forward check after total parameter alignment.

    Identical add/delete programs commute with every object substitution,
    including aliased arguments. Propositional implication over-approximates
    consistent ground valuations, so acceptance is sound for the stated fragment.
    A failing valuation need not be reachable in a particular source problem.
    """
    if type(max_atoms) is not int or not 0 <= max_atoms <= 20:
        raise ValueError('max_atoms must be between 0 and 20')
    try:
        target = fields(replacement)
        target_pre = boolean(target[':precondition'])
        target_eff = effect_literals(target[':effect'])
        for source in originals:
            old = fields(source)
            if old[':parameters'] != target[':parameters']:
                return {'status': 'rejected', 'reason': 'parameters_not_aligned'}
            if effect_literals(old[':effect']) != target_eff:
                return {'status': 'rejected', 'reason': 'different_add_delete_effects'}
            pre = boolean(old[':precondition'])
            # This structural certificate proves implication without a truth-table budget.
            if pre == target_pre or (target_pre[0] == 'or' and pre in target_pre[1]):
                continue
            atoms = set()
            def collect(e):
                if e[0] == 'atom': atoms.add(e[1])
                elif e[0] == 'not': collect(e[1])
                else:
                    for child in e[1]: collect(child)
            collect(pre); collect(target_pre)
            if len(atoms) > max_atoms:
                return {'status': 'unknown', 'reason': 'implication_atom_budget', 'atoms': len(atoms)}
            atoms = sorted(atoms)
            def evaluate(e, state):
                if e[0] == 'atom': return e[1] in state
                if e[0] == 'not': return not evaluate(e[1], state)
                values = [evaluate(child, state) for child in e[1]]
                return all(values) if e[0] == 'and' else any(values)
            for bits in itertools.product((False, True), repeat=len(atoms)):
                state = {a for a, bit in zip(atoms, bits) if bit}
                if evaluate(pre, state) and not evaluate(target_pre, state):
                    return {'status': 'rejected', 'reason': 'strengthened_applicability',
                            'propositional_counterexample': [list(a) for a in sorted(state)],
                            'reachable_state_claim': False}
        return {'status': 'accepted', 'certificate': 'source_pre_implies_target_and_identical_add_delete',
                'scope': 'All bindings and states in the supported Boolean fragment under the fixed embedding; no semantic-label claim'}
    except (ValueError, IndexError, TypeError) as exc:
        return {'status': 'unknown', 'reason': 'unsupported_fragment', 'details': str(exc)}


def canonical_action(action, order):
    item = fields(action)
    parameters = list(typed_symbols(item[':parameters']))
    if not permutation(order, len(parameters)):
        raise ValueError('Complete parameter bijection required')
    # aligned_domain has already replaced types by source-specific static guards.
    if any(t != 'object' for t in typed_symbols(item[':parameters']).values()):
        raise ValueError('Expected membership-guarded action')
    substitution = {parameters[i]: f'?m{j}' for j, i in enumerate(order)}
    def walk(value):
        if isinstance(value, str): return substitution.get(value, value)
        if value and value[0] in ('forall', 'exists'):
            raise ValueError('Quantified action fusion deferred')
        return [walk(x) for x in value]
    return [':action', action[1], ':parameters',
            [x for i in range(len(parameters)) for x in (f'?m{i}', '-', 'object')],
            ':precondition', walk(item[':precondition']), ':effect', walk(item[':effect'])]


def build(inputs, output, specification, *, merge_actions=True, semantic_mode='required'):
    require_empty_output(output)
    if semantic_mode not in ('required', 'off_diagnostic'):
        raise ValueError('Unknown semantic mode')
    if specification.get('version') != 1 or specification.get('decision_basis') not in (
            'machine_hypothesis', 'authored_assumption', 'reviewed_annotation'):
        raise ValueError('Version and explicit decision_basis required')
    threshold = specification.get('semantic_min_confidence', .9)
    if type(threshold) not in (int, float) or not math.isfinite(threshold) or not 0 <= threshold <= 1:
        raise ValueError('Invalid semantic threshold')
    paths = sorted(inputs.glob('*_domainfile.pddl'))
    domains = {p.name.removesuffix('_domainfile.pddl'): parse_domain(p) for p in paths}
    if any(specification.get('source_sha256', {}).get(p.name) != digest(p) for p in paths):
        raise ValueError('Missing or stale source hash')
    output.mkdir(parents=True, exist_ok=True)
    save(output / 'merge_specification.json', specification)
    alignment = {k: copy.deepcopy(specification[k]) for k in ('version', 'decision_basis', 'source_sha256')}
    alignment.update(type_groups=copy.deepcopy(specification.get('type_groups', [])), predicate_groups=[])
    decisions = []
    ids = set()
    def start(group, kind):
        identifier = group.get('id', '')
        if not re.fullmatch(r'[a-z][a-z0-9_]*', identifier) or (kind, identifier) in ids:
            raise ValueError('Candidate ids must be unique safe identifiers')
        ids.add((kind, identifier))
        gate = semantic_gate(group, kind, domains, threshold)
        row = {'kind': kind, 'id': identifier, 'members': [m.get(kind) for m in group.get('members', [])],
               'semantic': gate, 'formal': {'status': 'not_checked'}}
        decisions.append(row)
        row['status'] = gate['status'] if gate['status'] != 'accepted_hypothesis' else 'pending'
        if semantic_mode == 'off_diagnostic':
            row['semantic_bypassed_for_ablation'] = True
        return row, gate['status'] == 'accepted_hypothesis' or semantic_mode == 'off_diagnostic'
    for group in specification.get('predicate_candidates', []):
        row, proceed = start(group, 'predicate')
        if not proceed: continue
        proposal = {'id': group['id'], 'evidence': group.get('evidence'),
                    'members': [{k: m[k] for k in ('predicate', 'order')} for m in group['members']]}
        trial = copy.deepcopy(alignment)
        trial['predicate_groups'].append(proposal)
        try:
            report = build_aligned(inputs, output / 'predicate_trials' / group['id'], trial)
            if not report['valid']: raise ValueError('Independent parsing failed')
            alignment = trial
            row.update(status='accepted', formal={'status': 'accepted',
                'certificate': 'source_injective_predicate_permutations_with_static_membership',
                'scope': 'Conditional source-local embedding; coherent explicit worlds required'})
        except ValueError as exc:
            row.update(status='rejected', formal={'status': 'rejected', 'reason': str(exc)})
    stage = output / 'predicate_model'
    build_aligned(inputs, stage, alignment)
    domain = parse_domain(stage / 'meta_domain.pddl')
    meta = json.loads((stage / 'meta_domain.json').read_text(encoding='utf-8'))
    maps = meta['action_maps']
    orders = {s: {a: list(range(len(typed_symbols(fields(domain.actions[t])[':parameters']))))
                  for a, t in table.items()} for s, table in maps.items()}
    origins = {t: [{'source': s, 'action': a, 'source_to_target_positions': orders[s][a]}]
               for s, table in maps.items() for a, t in table.items()}
    assigned = set()
    for group in specification.get('action_candidates', []):
        row, proceed = start(group, 'action')
        if not merge_actions:
            row['status'] = 'disabled_by_condition'
            continue
        if not proceed: continue
        try:
            refs = [m['action'] for m in group['members']]
            if len(refs) < 2 or len({r.split(':')[0] for r in refs}) != len(refs) or assigned.intersection(refs):
                raise ValueError('Use distinct sources and nonoverlapping action groups')
            names = [maps[s][a] for s, a in (r.split(':') for r in refs)]
            original = [canonical_action(domain.actions[n], m['order']) for n, m in zip(names, group['members'])]
            target = 'shared__a_' + group['id']
            if target in domain.actions: raise ValueError('Action name collision')
            candidate = copy.deepcopy(original[0]); candidate[1] = target
            candidate[candidate.index(':precondition') + 1] = ['or', *[fields(a)[':precondition'] for a in original]]
            proof = certify_replacement(original, candidate)
            row['formal'] = proof
            row['status'] = proof['status']
            if proof['status'] != 'accepted': continue
            row['merge_kind'] = ('equivalent_guarded_actions' if len({boolean(fields(a)[':precondition']) for a in original}) == 1
                                 else 'same_effect_disjunctive_applicability')
            provenance = []
            for ref, name, member, normalized in zip(refs, names, group['members'], original):
                source, action = ref.split(':')
                source_to_target = [member['order'].index(i) for i in range(len(member['order']))]
                maps[source][action] = target; orders[source][action] = source_to_target
                provenance.append({'source': source, 'action': action,
                    'source_to_target_positions': source_to_target,
                    'branch_precondition': fields(normalized)[':precondition']})
                del domain.actions[name]; del origins[name]
            domain.actions[target] = candidate; origins[target] = provenance
            assigned.update(refs)
            row.update(target=target, origins=provenance)
        except (ValueError, KeyError) as exc:
            row.update(status='unknown', formal={'status': 'unknown', 'reason': str(exc)})
    errors = validate_domain(domain)
    if errors: raise ValueError(str(errors))
    write_domain(domain, output / 'meta_domain.pddl')
    parsed = check_exported_domain(output / 'meta_domain.pddl')
    (output / 'problems').mkdir()
    problem_rows = []
    for problem in (stage / 'problems').glob('*.pddl'):
        destination = output / 'problems' / problem.name
        shutil.copyfile(problem, destination)
        problem_rows.append(check_exported_problem(output / 'meta_domain.pddl', destination))
    meta.update(method='conditional_semantic_and_formal_merge', action_maps=maps,
                action_parameter_maps=orders, action_origins=origins,
                semantic_mode=semantic_mode, semantic_status='accepted_judgments_not_independent_labels',
                counts=domain_summary(domain)['counts'],
                compiled_domain_sha256=digest(output / 'meta_domain.pddl'),
                conditional_merge_implementation_sha256=digest(Path(__file__)))
    save(output / 'meta_domain.json', meta)
    result = {'valid': True, 'status': 'complete', 'domain_parse': parsed, 'problems': problem_rows,
              'counts': meta['counts'], 'source_actions': sum(len(d.actions) for d in domains.values()),
              'source_predicates': sum(len(d.predicates) for d in domains.values()),
              'merged_action_groups': sum(r['kind'] == 'action' and r['status'] == 'accepted' for r in decisions),
              'merged_predicate_groups': len(alignment['predicate_groups']), 'decisions': decisions,
              'scope': 'Conditional formal preservation under explicit semantic hypotheses; not independent semantic accuracy'}
    save(output / 'validation.json', result)
    return result

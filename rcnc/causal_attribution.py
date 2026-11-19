"""Versioned causal attribution over saved plans and applicable source branches.

This module makes no model or planner calls. Source labels are alternatives, not
simultaneous participation. Cross and All-k quantify over complete, consistent
branch/support interpretations of a fixed physical trace. Historical v1 reports
and their evaluator remain reproducible and are not overwritten.
"""
from collections import Counter, defaultdict
from hashlib import sha256
from itertools import product
import json
from pathlib import Path

from .composition_probes import literals
from .glaive_merge import action_fields, rename_vars, signed_effects
from .pddl import parse_sexpr, section, typed_symbols
from .revised_probe_validation import ground, holds, changes, replay_physical

VERSION = 'applicable-source-branches-v2'
SOURCE_COUNT_PROFILE_VERSION = 'goal-relevant-chain-source-counts-v1'


def file_digest(path):
    return sha256(Path(path).read_bytes()).hexdigest()


def value_digest(value):
    return sha256(json.dumps(value, sort_keys=True, separators=(',', ':')).encode()).hexdigest()


def _domain(path):
    tree = parse_sexpr(Path(path).read_text(encoding='utf-8'))
    actions = {x[1]: action_fields(x) for x in tree
               if isinstance(x, list) and x and x[0] == ':action'}
    return tree, actions


def _conjuncts(expr):
    if expr[0] == 'and':
        return [x for child in expr[1:] for x in _conjuncts(child)]
    return [expr]


def _permutation(order, n):
    if (not isinstance(order, list) or any(type(x) is not int for x in order)
            or sorted(order) != list(range(n))):
        raise ValueError('incomplete_parameter_bijection')
    return order


def recover_branch_provenance(domain, mapping, variant_domain, variant_mapping):
    """Recover and certify a sidecar from the frozen Predicate-only variant model.

    Both models must use identical predicate maps and original source hashes.
    Every reconstructed guarded branch, effect and actor list is checked against
    the actual Full operator. No PDDL or historical mapping is rewritten.
    """
    if mapping['predicate_maps'] != variant_mapping['predicate_maps']:
        raise ValueError('different_predicate_maps')
    if mapping['source_sha256'] != variant_mapping['source_sha256']:
        raise ValueError('different_source_hashes')
    _, actions = _domain(domain)
    _, variants = _domain(variant_domain)
    reverse = defaultdict(list)
    for ref, item in mapping['action_maps'].items():
        reverse[item['name']].append(ref)
    recorded = {}
    for name, refs in sorted(reverse.items()):
        if len(refs) < 2:
            continue
        action = actions[name]
        params = list(typed_symbols(action[':parameters']))
        pre = action[':precondition']
        if pre[0] != 'or' or len(pre) - 1 != len(refs):
            raise ValueError('fused_branch_count_mismatch')
        available = set(range(len(pre) - 1))
        branches = []
        for ref in sorted(refs):
            vmap = variant_mapping['action_maps'][ref]
            if sum(v['name'] == vmap['name'] for v in variant_mapping['action_maps'].values()) != 1:
                raise ValueError('variant_model_has_merged_actions')
            original = variants[vmap['name']]
            vparams = list(typed_symbols(original[':parameters']))
            n = len(params)
            if len(vparams) != n:
                raise ValueError('variant_parameter_count_mismatch')
            order = _permutation(mapping['action_maps'][ref]['order'], n)
            vorder = _permutation(vmap['order'], n)
            renaming = {v: params[order.index(vorder[i])] for i, v in enumerate(vparams)}
            condition = rename_vars(original[':precondition'], renaming)
            effect = rename_vars(original.get(':effect', ['and']), renaming)
            agents = rename_vars(original.get(':agents', []), renaming)
            if signed_effects(effect) != signed_effects(action.get(':effect', ['and'])):
                raise ValueError('branch_effect_mismatch')
            if set(agents) != set(action.get(':agents', [])):
                raise ValueError('branch_actor_mismatch')
            source = ref.split(':', 1)[0]
            if [source + '_active'] not in _conjuncts(condition):
                raise ValueError('missing_source_guard')
            matches = sorted(i for i in available if pre[i + 1] == condition)
            if not matches:
                raise ValueError('source_variant_branch_not_found')
            index = matches[0]
            available.remove(index)
            branches.append({'source': source, 'source_action': ref,
                             'branch_index': index, 'source_parameter_order': order,
                             'variant_parameters': vparams,
                             'parameter_map': renaming, 'precondition': condition,
                             'effect': effect, 'agents': agents})
        if available:
            raise ValueError('unaccounted_fused_branch')
        recorded[name] = {'parameters': params, 'branches': sorted(branches, key=lambda b: b['branch_index'])}
    return {'version': VERSION, 'basis': 'verified_frozen_source_variants',
            'domain_sha256': file_digest(domain), 'mapping_digest': value_digest(mapping),
            'variant_domain_sha256': file_digest(variant_domain),
            'variant_mapping_digest': value_digest(variant_mapping), 'actions': recorded}


def _source_branches(name, fields, mapping, provenance):
    refs = sorted(ref for ref, v in mapping['action_maps'].items() if v['name'] == name)
    if not refs:
        raise ValueError('missing_action_mapping')
    if len(refs) == 1:
        return [{'source': refs[0].split(':', 1)[0], 'source_action': refs[0],
                 'branch_index': 0, 'precondition': fields[':precondition']}]
    if provenance is None or name not in provenance['actions']:
        raise ValueError('missing_verified_branch_provenance')
    entry = provenance['actions'][name]
    branches = entry['branches']
    params = list(typed_symbols(fields[':parameters']))
    pre = fields[':precondition']
    if (entry['parameters'] != params or pre[0] != 'or'
            or sorted(b['source_action'] for b in branches) != refs
            or sorted(b['branch_index'] for b in branches) != list(range(len(pre) - 1))):
        raise ValueError('branch_provenance_mismatch')
    for branch in branches:
        ref, source = branch['source_action'], branch['source']
        if (source != ref.split(':', 1)[0]
                or branch['source_parameter_order'] != mapping['action_maps'][ref]['order']
                or branch['precondition'] != pre[branch['branch_index'] + 1]
                or [source + '_active'] not in _conjuncts(branch['precondition'])
                or signed_effects(branch['effect']) != signed_effects(fields.get(':effect', ['and']))
                or set(branch['agents']) != set(fields.get(':agents', []))):
            raise ValueError('branch_provenance_mismatch')
    return branches


def _supports(expr, state, limit):
    """All true positive-support alternatives in the finite Boolean fragment.

    Negative literals constrain applicability but are not positive causal edges.
    Disjuncts are alternatives: their supporting facts are never pooled.
    """
    head = expr[0]
    if head == 'and':
        result = {frozenset()}
        for child in expr[1:]:
            choices = _supports(child, state, limit)
            result = {a | b for a in result for b in choices}
            if len(result) > limit:
                raise ValueError('support_enumeration_limit')
        return result
    if head == 'or':
        result = set()
        for child in expr[1:]:
            result.update(_supports(child, state, limit))
            if len(result) > limit:
                raise ValueError('support_enumeration_limit')
        return result
    if head == '=':
        return {frozenset()} if holds(expr, state) else set()
    if head == 'not':
        literals(expr)  # Reject unsupported compound negation, not just false branches.
        return {frozenset()} if holds(expr, state) else set()
    literals(expr)  # Fail closed on quantifiers, function terms and other constructs.
    return {frozenset([tuple(expr)])} if holds(expr, state) else set()


def _chain(steps, edges, relevant, sources):
    target = frozenset(sources)
    incoming = defaultdict(list)
    for edge in edges:
        incoming[edge['to']].append(edge)
    paths = {}
    for step in steps:
        i, sid = step['index'], step['source']
        if i not in relevant or sid not in target:
            continue
        paths[i] = {frozenset([sid]): [i]}
        for edge in incoming[i]:
            previous = edge['from']
            if previous not in paths:
                continue
            if steps[previous]['source'] != sid and not edge['fact'][0].startswith('shared_'):
                continue
            for covered, path in paths[previous].items():
                paths[i].setdefault(covered | {sid}, path + [i])
        if target in paths[i]:
            return paths[i][target]
    return []


def _interpret(options, goal_owners, sources):
    steps = [{'index': i, 'source': o['source'], 'source_action': o['source_action'],
              'branch_index': o['branch_index'], 'call': o['call']}
             for i, o in enumerate(options)]
    edges = [edge for o in options for edge in o['edges']]
    relevant = set(goal_owners)
    while True:
        enlarged = relevant | {e['from'] for e in edges if e['to'] in relevant}
        if enlarged == relevant:
            break
        relevant = enlarged
    causal = [e for e in edges if e['to'] in relevant]
    cross = [e for e in causal if e['fact'][0].startswith('shared_')
             and steps[e['from']]['source'] != steps[e['to']]['source']]
    path = _chain(steps, causal, relevant, sources) if sources else []
    return {'steps': steps, 'causal_edges': causal, 'cross_source_edges': cross,
            'all_k_path': path, 'goal_relevant_steps': sorted(relevant)}


def _verdict(positive, total):
    return {'status': 'confirmed' if positive == total else ('absent' if positive == 0 else 'ambiguous'),
            'positive_interpretations': positive, 'total_interpretations': total}


def maximum_chain_sources(trace, selected_sources):
    """Largest distinct-source count on one goal-relevant causal path.

    A fork does not pool its siblings. Same-source links may extend a path;
    a link between different sources must carry a shared predicate, matching
    the existing Cross/All-k convention. Counts concern one interpretation.
    """
    allowed = set(selected_sources)
    relevant = set(trace['goal_relevant_steps'])
    incoming = defaultdict(list)
    for edge in trace['causal_edges']:
        incoming[edge['to']].append(edge)
    paths, best = {}, []
    maximum = 0
    for step in trace['steps']:
        index, source = step['index'], step['source']
        if index not in relevant:
            continue
        if source not in allowed:
            raise ValueError('path_source_outside_selected_group')
        paths[index] = {frozenset([source]): [index]}
        for edge in incoming[index]:
            previous = edge['from']
            if previous not in paths:
                continue
            if trace['steps'][previous]['source'] != source and not edge['fact'][0].startswith('shared_'):
                continue
            for covered, path in paths[previous].items():
                paths[index].setdefault(covered | {source}, path + [index])
        for covered, path in paths[index].items():
            if len(covered) > maximum:
                maximum, best = len(covered), path
    return maximum, best


def causal_trace_v2(domain, problem, plan, mapping, *, provenance=None,
                    selected_sources=None, max_interpretations=4096, max_supports=256,
                    source_count_profile=False):
    """Classify Cross and All-k independently over every supported interpretation.

    A cap or unsupported formula yields unknown, never a partial robust verdict.
    The witness for a possible metric is not a claim of a uniquely chosen origin.
    """
    result = {'version': VERSION, 'status': 'unknown',
              'cross': {'status': 'unknown'},
              'all_k': {'status': 'unknown' if selected_sources else 'not_requested'},
              'limits': {'interpretations': max_interpretations, 'supports_per_step': max_supports}}
    if source_count_profile:
        result['source_count_profile'] = {'version': SOURCE_COUNT_PROFILE_VERSION, 'status': 'unknown'}
    try:
        if source_count_profile and (not selected_sources or len(set(selected_sources)) < 2):
            raise ValueError('source_count_profile_requires_selected_sources')
        if max_interpretations < 1 or max_supports < 1:
            raise ValueError('invalid_attribution_budget')
        tree, actions = _domain(domain)
        if any(isinstance(x, list) and x and x[0] == ':axiom' for x in tree):
            raise ValueError('axiom_closure_outside_attribution_fragment')
        if provenance is not None and (provenance.get('version') != VERSION
                or provenance['domain_sha256'] != file_digest(domain)
                or provenance['mapping_digest'] != value_digest(mapping)):
            raise ValueError('stale_branch_provenance')
        physical = replay_physical(Path(domain), Path(problem), Path(plan))
        result['physical'] = {k: v for k, v in physical.items() if k != 'applied'}
        if physical['status'] != 'replayed' or not physical.get('goal'):
            raise ValueError('independent_physical_replay_failed')
        p = parse_sexpr(Path(problem).read_text(encoding='utf-8'))
        q = parse_sexpr(Path(plan).read_text(encoding='utf-8'))
        initial = section(p, ':init')
        if initial is None:
            raise ValueError('needs_initial_state')
        if section(q, ':problem')[1] != section(p, 'problem')[1]:
            raise ValueError('plan_problem_mismatch')
        if any(x[0] == 'not' for x in initial[1:]):
            raise ValueError('explicit_negative_initial_outside_trace_fragment')
        state = {tuple(x) for x in initial[1:] if x[0] != 'intends'}
        goal = section(p, ':goal')[1]
        goals = literals(goal)
        if any(not sign for sign, _ in goals):
            raise ValueError('negative_goal_outside_causal_slice')
        owners, step_options, step_records = {}, [], []
        for index, call in enumerate(section(q, ':steps')[1:]):
            if call[0] == 'non-executed':
                raise ValueError('counterfactual_step')
            fields = actions[call[0]]
            params = list(typed_symbols(fields[':parameters']))
            if len(params) != len(call) - 1:
                raise ValueError('action_arity_mismatch')
            binding = dict(zip(params, call[1:]))
            if not holds(ground(fields[':precondition'], binding), state):
                raise ValueError('inapplicable_trace')
            candidates = _source_branches(call[0], fields, mapping, provenance)
            choices, branch_checks = [], []
            for branch in candidates:
                condition = ground(branch['precondition'], binding)
                applicable = holds(condition, state)
                branch_checks.append({'source_action': branch['source_action'],
                                      'branch_index': branch['branch_index'],
                                      'applicable': applicable, 'grounded_precondition': condition})
                if not applicable:
                    continue
                for support in sorted(_supports(condition, state, max_supports), key=lambda s: sorted(s)):
                    edges = [{'from': owners[fact], 'to': index, 'fact': list(fact)}
                             for fact in sorted(support) if fact in owners]
                    choices.append({'source': branch['source'], 'source_action': branch['source_action'],
                                    'branch_index': branch['branch_index'], 'call': call,
                                    'positive_support': [list(f) for f in sorted(support)], 'edges': edges})
            if not choices:
                raise ValueError('no_applicable_source_branch')
            if len(choices) > max_supports:
                raise ValueError('step_alternative_limit')
            # Conditional-effect guards would need their own causal supports.
            # Reject them instead of silently certifying an incomplete graph.
            signed_effects(fields.get(':effect', ['and']))
            add, delete = changes(ground(fields.get(':effect', ['and']), binding), state)
            if add & delete:
                raise ValueError('conflicting_simultaneous_effects')
            for fact in delete:
                owners.pop(fact, None)
            for fact in add - state:
                owners[fact] = index
            state = (state - delete) | add
            step_options.append(choices)
            step_records.append({'index': index, 'call': call, 'branches': branch_checks,
                                 'applicable_sources': sorted({c['source'] for c in choices}),
                                 'alternatives': choices})
        if not holds(goal, state):
            raise ValueError('goal_not_reached')
        result.update(physical_goal_reached=True, steps=step_records,
                      origin_ambiguous_steps=[s['index'] for s in step_records if len(s['applicable_sources']) > 1])
        total = 1
        for options in step_options:
            total *= len(options)
        result['interpretations_required'] = total
        if total > max_interpretations:
            raise ValueError('interpretation_limit')
        goal_owners = {owners[tuple(atom)] for _, atom in goals if tuple(atom) in owners}
        cross_count = all_k_count = 0
        witnesses = {}
        chain_counts, chain_witnesses = Counter(), {}
        for combination in product(*step_options):
            trace = _interpret(combination, goal_owners, selected_sources)
            cross, all_k = bool(trace['cross_source_edges']), bool(trace['all_k_path'])
            cross_count += cross
            all_k_count += all_k
            witnesses.setdefault('cross_positive' if cross else 'cross_negative', trace)
            if selected_sources:
                witnesses.setdefault('all_k_positive' if all_k else 'all_k_negative', trace)
            if source_count_profile:
                count, path = maximum_chain_sources(trace, selected_sources)
                chain_counts[count] += 1
                chain_witnesses.setdefault(str(count), {'path': path, 'interpretation': trace})
        result.update(status='classified', interpretations_examined=total,
                      cross=_verdict(cross_count, total), witnesses=witnesses)
        if selected_sources:
            result['all_k'] = _verdict(all_k_count, total)
            result['all_k']['required_sources'] = sorted(selected_sources)
        if source_count_profile:
            smallest, largest = min(chain_counts), max(chain_counts)
            thresholds = {str(j): _verdict(sum(n for m, n in chain_counts.items() if m >= j), total)
                          for j in range(2, len(set(selected_sources)) + 1)}
            if thresholds['2']['status'] != result['cross']['status']:
                raise ValueError('chain_profile_cross_inconsistency')
            if thresholds[str(len(set(selected_sources)))]['status'] != result['all_k']['status']:
                raise ValueError('chain_profile_all_k_inconsistency')
            result['source_count_profile'] = {
                'version': SOURCE_COUNT_PROFILE_VERSION, 'status': 'classified',
                'selected_k': len(set(selected_sources)), 'minimum_over_interpretations': smallest,
                'maximum_over_interpretations': largest,
                'exact_count': smallest if smallest == largest else None,
                'interpretation_count_by_maximum_chain_sources': dict(sorted(chain_counts.items())),
                'at_least': thresholds, 'witnesses': chain_witnesses,
                'scope': 'Maximum distinct-source count on one goal-relevant positive-fact causal path in each interpretation; not total plan sources or a probability.'}
        return result
    except (KeyError, ValueError, TypeError, IndexError) as exc:
        result['reason'] = str(exc)
        return result

"""Predeclared lexical controls and conservative independent-task intake.

No function in this module supplies independent human semantic judgments.
"""
from collections import defaultdict
from pathlib import Path

from rcnc.domain_building import digest
from rcnc.interface_annotation import digest as json_digest
from rcnc.pddl import parse_domain


def lexical_alignment(inputs):
    """Name/arity-only hypothesis; role types are explicit assumptions, not gold."""
    paths = sorted(Path(inputs).glob('*_domainfile.pddl'))
    groups = defaultdict(list)
    for path in paths:
        source = path.name.removesuffix('_domainfile.pddl')
        for name, pred in parse_domain(path).predicates.items():
            groups[(name.lower(), pred.arity)].append((source, name, pred))
    predicates, types = [], []
    for (name, arity), members in sorted(groups.items()):
        if len(members) < 2:
            continue
        if len({m[0] for m in members}) != len(members):
            raise ValueError('Lexical grouping would collapse within-source predicates')
        identifier = 'lex_' + json_digest([name, arity])[:16]
        predicates.append({'id': identifier, 'members': [
            {'predicate': source + ':' + original, 'order': list(range(arity))}
            for source, original, _ in members],
            'evidence': 'Frozen same-name/arity heuristic; semantic equivalence unverified'})
        for slot in range(arity):
            role_types = sorted({source + ':' + pred.parameters[slot][1]
                                 for source, _, pred in members})
            if len(role_types) > 1:
                types.append({'members': role_types,
                    'evidence': 'Explicit unverified positional role-type assumption for ' + identifier})
    return {'version': 1, 'decision_basis': 'machine_hypothesis',
        'semantic_status': 'unverified_lexical_baseline',
        'source_sha256': {p.name: digest(p) for p in paths},
        'predicate_groups': predicates, 'type_groups': types,
        'object_identity_inferred': False, 'initial_facts_inferred': False}


def lexical_predictions(packet, condition):
    if condition not in ('no_merge', 'same_name_and_arity'):
        raise ValueError('Unknown frozen lexical condition')
    rows = []
    for item in packet['items']:
        left, right = item['sides']
        positive = (condition == 'same_name_and_arity'
            and left['predicate'].lower() == right['predicate'].lower()
            and len(left['parameters']) == len(right['parameters']))
        evidence = []
        for side, record in enumerate(item['sides']):
            if record['action_contexts']:
                context = record['action_contexts'][0]
                evidence.append({'side': side, 'ref': context['ref'], 'quote': context['text']})
        # A candidate with no action evidence is an abstention, never false gold.
        positive = positive and len(evidence) == 2
        response = {'candidate_id': item['id'], 'label': 'equivalent' if positive else 'uncertain',
            'right_from_left': list(range(len(left['parameters']))) if positive else None,
            'rationale': 'Deterministic baseline hypothesis only; no semantic judgment. '
                         'No-merge or unmatched names abstain; quoted context is not an entailment proof.',
            'evidence': evidence}
        rows.append({'candidate_id': item['id'], 'status': 'checked', 'response': response})
    return {'status': 'complete', 'total': len(rows), 'condition': condition, 'rows': rows,
            'packet_sha256': json_digest(packet), 'independent_labels_created': 0}


def audit_task_registry(registry, source_sha256):
    """Check intake, not task truth, feasibility, or actual author independence."""
    ids = [row.get('id') for row in registry['tasks']]
    if (registry['task_count'] != len(ids) or len(ids) != len(set(ids))
            or any(not isinstance(key, str) or not key for key in ids)):
        raise ValueError('Complete unique task registry required')
    results = []
    for task in registry['tasks']:
        missing = []
        if task.get('source_availability') != 'available':
            missing.append('source_not_available')
        if task.get('source_sha256') != source_sha256:
            missing.append('source_hash_mismatch')
        sources = task.get('sources', [])
        known = {Path(name).name.removesuffix('_domainfile.pddl') for name in source_sha256}
        if len(sources) != 2 or len(set(sources)) != 2 or not set(sources) <= known:
            missing.append('two_known_distinct_sources_required')
        provenance = task.get('provenance', {})
        for key in ('author_id', 'authored_at', 'goal_meaning'):
            if not isinstance(provenance.get(key), str) or not provenance[key].strip():
                missing.append('missing_' + key)
        if provenance.get('independent_of_method_development') is not True:
            missing.append('task_author_independence_not_declared')
        if provenance.get('unexposed_to_predictions_plans_outcomes') is not True:
            missing.append('outcome_blinding_not_declared')
        query = task.get('query')
        if not isinstance(query, dict):
            missing.append('missing_explicit_query')
        else:
            if set(query) - {'objects', 'initial', 'goal'}:
                missing.append('unexpected_query_fields')
            if not isinstance(query.get('objects'), dict):
                missing.append('missing_explicit_objects')
            elif any(not isinstance(k, str) or not k or not isinstance(v, (str, list))
                     or not v or (isinstance(v, list) and any(not isinstance(x, str) or not x for x in v))
                     for k, v in query['objects'].items()):
                missing.append('malformed_object_membership')
            if not isinstance(query.get('initial'), list):
                missing.append('missing_explicit_initial')
            goal = query.get('goal')
            if (not isinstance(goal, dict) or set(goal) - {'positive', 'negative'}
                    or any(not isinstance(v, list) for v in goal.values())
                    or not any(goal.values())):
                missing.append('missing_nonempty_goal')
            def atoms_ok(values):
                return isinstance(values, list) and all(isinstance(a, list) and a
                    and all(isinstance(x, str) and x for x in a) for a in values)
            if isinstance(query.get('initial'), list) and not atoms_ok(query['initial']):
                missing.append('malformed_initial_atoms')
            if isinstance(goal, dict) and any(not atoms_ok(v) for v in goal.values()):
                missing.append('malformed_goal_atoms')
        results.append({'id': task['id'], 'status': 'needs_independent_task' if missing else 'intake_structurally_complete',
                        'missing': missing, 'planner_called': False})
    return {'status': 'intake_audited', 'task_count': len(results), 'rows': results,
        'ready_for_semantic_and_mapping_review': sum(r['status'] == 'intake_structurally_complete' for r in results),
        'planner_calls': 0, 'independence_verified': False,
        'scope': 'No automatic dispatch or semantic certification. Review mappings and freeze task bytes before planning.'}

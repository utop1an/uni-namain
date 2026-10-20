"""Outcome-blind annotation packets; no labels or compiler approvals inferred."""
import hashlib
import itertools
import json
from pathlib import Path

from rcnc.pddl import parse_domain, serialize


LABELS = ('equivalent', 'permuted_equivalent', 'abstraction', 'complementary',
          'incompatible', 'uncertain')


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, ensure_ascii=False).encode()).hexdigest()


def save(path, value):
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


def occurrences(expr, predicate, path=()):
    """Keep AST paths; enclosing logic remains available in the full action."""
    if not isinstance(expr, list):
        return []
    found = [{'path': list(path), 'literal': serialize(expr)}] if expr and expr[0] == predicate else []
    for i, child in enumerate(expr):
        if isinstance(child, list):
            found.extend(occurrences(child, predicate, path + (i,)))
    return found


def build_packet(inputs, output, per_stratum=24, seed='icaps-development-v1',
                 source_metadata=None, scope=None):
    if type(per_stratum) is not int or per_stratum < 1:
        raise ValueError('per_stratum must be positive')
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    records, hashes = {}, {}
    if source_metadata is not None and set(source_metadata) != {p.name for p in inputs.glob('*_domainfile.pddl')}:
        raise ValueError('Provenance must cover exactly the supplied source domains')
    for path in sorted(inputs.glob('*_domainfile.pddl')):
        domain = parse_domain(path)
        source = path.name.removesuffix('_domainfile.pddl')
        hashes[path.name] = hashlib.sha256(path.read_bytes()).hexdigest()
        if source_metadata is not None and source_metadata[path.name].get('domain_sha256') != hashes[path.name]:
            raise ValueError('Provenance source hash mismatch: ' + path.name)
        for name, pred in sorted(domain.predicates.items()):
            contexts = []
            for action_name, action in sorted(domain.actions.items()):
                uses = occurrences(action, name)
                if uses:
                    contexts.append({'ref': f'{source}:action:{action_name}',
                                     'text': serialize(action), 'occurrences': uses})
            records[f'{source}:{name}'] = {'source': source, 'predicate': name,
                'declaration': serialize(pred.to_expr()), 'parameters': pred.parameters,
                'type_hierarchy': domain.types, 'action_contexts': contexts,
                'story_or_learner_provenance': source_metadata[path.name] if source_metadata is not None else 'not_supplied'}
    if len(hashes) < 2:
        raise ValueError('At least two source domains required')
    strata = {}
    all_cross_source = different_arity = 0
    for left, right in itertools.combinations(sorted(records), 2):
        a, b = records[left], records[right]
        if a['source'] == b['source']:
            continue
        all_cross_source += 1
        ta, tb = [p[1] for p in a['parameters']], [p[1] for p in b['parameters']]
        if len(ta) != len(tb):
            different_arity += 1
            continue
        # Signature spelling is only a sampling category, not type equivalence.
        signature = 'same_order_type_names' if ta == tb else (
            'permuted_type_names' if sorted(ta) == sorted(tb) else 'different_type_names')
        stratum = ('same_name' if a['predicate'] == b['predicate'] else 'different_name') + '/' + signature
        refs = [left, right]
        strata.setdefault(stratum, []).append({'id': 'pair_' + digest(refs)[:16], 'refs': refs})
    chosen = []
    counts = {}
    selection = []
    for stratum, rows in sorted(strata.items()):
        rows.sort(key=lambda r: (digest([seed, r['id']]), r['id']))
        sampled = rows[:per_stratum]
        counts[stratum] = {'eligible': len(rows), 'selected': len(sampled), 'omitted': len(rows)-len(sampled)}
        for row in sampled:
            chosen.append(row)
            selection.append({**row, 'stratum': stratum})
    chosen.sort(key=lambda r: (digest([seed, 'presentation', r['id']]), r['id']))
    packet = {'version': 1, 'scope': scope or 'Observed local development domains; no independent-test claim',
        'source_sha256': hashes, 'label_choices': list(LABELS),
        'permutation_convention': 'right_arguments[j] = left_arguments[right_from_left[j]]; use identity for equivalent',
        'items': [{'id': row['id'], 'sides': [records[ref] for ref in row['refs']]} for row in chosen]}
    packet_hash = digest(packet)
    template = {'version': 1, 'packet_sha256': packet_hash, 'annotator_id': '',
        'independent_of_model_and_solver_outcomes': None,
        'rows': [{'candidate_id': row['id'], 'status': 'unreviewed', 'label': None,
                  'right_from_left': None, 'rationale': '', 'evidence': [], 'date': ''} for row in chosen]}
    manifest = {'version': 1, 'packet_sha256': packet_hash, 'seed': seed, 'per_stratum': per_stratum,
        'selection_policy': 'SHA256-ranked sample without replacement within name/type-spelling strata; equal arity only',
        'all_cross_source_pairs': all_cross_source, 'different_arity_excluded': different_arity,
        'equal_arity_pairs': all_cross_source-different_arity, 'selected_pairs': len(chosen),
        'strata': counts, 'selection': selection, 'independent_labels_completed': 0,
        'source_sha256': hashes, 'packet_generator_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        'limits': ['No goals, problem files, plans or model predictions are read',
                   'Source name/type spelling strata are not semantic gold labels',
                   'Equal-arity restriction excludes abstraction through argument addition or removal',
                   'Two independent annotators and adjudication are still required']}
    output.mkdir(parents=True, exist_ok=True)
    save(output/'packet.json', packet)
    save(output/'annotation_template.json', template)
    save(output/'coordinator_manifest.json', manifest)
    (output/'INSTRUCTIONS.txt').write_text(
        'Annotate packet.json independently. Do not consult plans, solver outcomes, model predictions, or another annotator.\n'
        'Copy annotation_template.json to a new file; never overwrite the packet. Fill your identifier and independence declaration.\n'
        'Use completed only after judgment; unreviewed means missing, not uncertain. Missing story evidence may justify uncertain.\n'
        'equivalent: interchangeable relation in the supplied context, same argument positions.\n'
        'permuted_equivalent: equivalent after an explicit nonidentity bijection.\n'
        'abstraction: one concept is broader; complementary: related but noninterchangeable; incompatible: cannot share a predicate.\n'
        'uncertain: evidence does not support a definite judgment. No judgment here approves an executable alignment.\n'
        'For equivalence give right_from_left (e.g. [1,0] maps right slot 0 to left slot 1). Explain each participant role and type scope.\n'
        'Cite evidence as {side: 0 or 1, ref: supplied action ref, quote: exact nonempty excerpt}. Cite both sides for definite labels.\n'
        'Retain separate original annotation files. Discuss disagreements only after both files are frozen.\n', encoding='utf-8')
    return manifest


def validate_annotations(packet, annotations):
    errors, completed = [], {}
    if annotations.get('packet_sha256') != digest(packet):
        errors.append('packet_hash_mismatch')
    if not isinstance(annotations.get('annotator_id'), str) or not annotations['annotator_id'].strip():
        errors.append('missing_annotator_id')
    if annotations.get('independent_of_model_and_solver_outcomes') is not True:
        errors.append('independence_not_declared')
    items = {item['id']: item for item in packet['items']}
    seen = set()
    rows = annotations.get('rows', [])
    if not isinstance(rows, list):
        return {'valid': False, 'errors': errors + ['rows_not_list'], 'completed': 0, 'total': len(items)}
    for row in rows:
        if not isinstance(row, dict) or not isinstance(row.get('candidate_id'), str):
            errors.append('malformed_row'); continue
        key = row['candidate_id']
        if key not in items or key in seen:
            errors.append('unknown_or_duplicate_candidate:' + key); continue
        seen.add(key)
        if row.get('status') == 'unreviewed':
            if row.get('label') is not None:
                errors.append('unreviewed_has_label:' + key)
            continue
        start = len(errors)
        if row.get('status') != 'completed' or row.get('label') not in LABELS:
            errors.append('invalid_status_or_label:' + key)
        for field in ('rationale', 'date'):
            if not isinstance(row.get(field), str) or not row[field].strip():
                errors.append('missing_' + field + ':' + key)
        label = row.get('label')
        if label in ('equivalent', 'permuted_equivalent'):
            order = row.get('right_from_left')
            identity = list(range(len(items[key]['sides'][0]['parameters'])))
            if not isinstance(order, list) or any(type(x) is not int for x in order) or sorted(order) != identity:
                errors.append('nonbijective_argument_map:' + key)
            elif (order == identity) != (label == 'equivalent'):
                errors.append('label_argument_map_disagreement:' + key)
        elif row.get('right_from_left') is not None:
            errors.append('non_equivalent_has_argument_map:' + key)
        evidence = row.get('evidence')
        sides = set()
        if not isinstance(evidence, list):
            errors.append('evidence_not_list:' + key); evidence = []
        for cite in evidence:
            if not isinstance(cite, dict) or type(cite.get('side')) is not int or cite['side'] not in (0, 1):
                errors.append('invalid_evidence_side:' + key); continue
            side = cite['side']
            contexts = {a['ref']: a['text'] for a in items[key]['sides'][side]['action_contexts']}
            ref, quote = cite.get('ref'), cite.get('quote')
            if not isinstance(ref, str) or ref not in contexts or not isinstance(quote, str) or not quote.strip() or quote not in contexts[ref]:
                errors.append('invalid_evidence_quote:' + key)
            else:
                sides.add(side)
        if label != 'uncertain' and sides != {0, 1}:
            errors.append('missing_both_side_evidence:' + key)
        if len(errors) == start:
            completed[key] = label
    return {'valid': not errors, 'errors': errors, 'total': len(items), 'completed': len(completed),
            'unreviewed_or_missing': len(items)-len(completed),
            'label_counts': {label: sum(v == label for v in completed.values()) for label in LABELS},
            'limit': 'Checks completeness and citation provenance, not semantic truth or actual annotator independence'}

"""Convert audited machine candidates to explicit pre-search research assumptions.

Never infer object identities or initial facts. Role-type proposals require an
explicit experimental policy; structural consistency is not semantic approval.
"""
import hashlib
import json
from pathlib import Path

from rcnc.aligned_domain import build
from rcnc.domain_building import require_empty_output, save
from rcnc.pddl import parse_domain
from scripts.audit.audit_interface_graph import audit


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def propose(packet, predictions, inputs, infer_role_types=False):
    graph = audit(packet, predictions)
    hashes = packet['source_sha256']
    models = {}
    for name, expected in hashes.items():
        if Path(name).name != name or not name.endswith('_domainfile.pddl'):
            raise ValueError('Expected flat source domain filename')
        path = inputs / name
        if sha(path) != expected:
            raise ValueError('Source hash mismatch: ' + name)
        models[name.removesuffix('_domainfile.pddl')] = parse_domain(path)
    signatures = {}
    for item in packet['items']:
        for side in item['sides']:
            source, predicate = side['source'], side['predicate']
            parameters = models[source].predicates[predicate].parameters
            if [list(p) for p in parameters] != [list(p) for p in side['parameters']]:
                raise ValueError('Packet signature differs from frozen source')
            signatures[source + ':' + predicate] = [source + ':' + typ for _, typ in parameters]
    spec = {'version': 1, 'decision_basis': 'machine_hypothesis',
            'source_sha256': hashes, 'type_groups': [], 'predicate_groups': [],
            'semantic_status': 'unverified_machine_assumptions',
            'role_type_policy': 'aligned_slot_hypothesis' if infer_role_types else 'withhold_missing_role_correspondences',
            'object_identity_inferred': False, 'initial_facts_inferred': False}
    decisions = []
    for component in graph['components']:
        decision = {'root': component['root'], 'edge_ids': component['edge_ids']}
        if component['conflicts']:
            decisions.append(dict(decision, status='withheld', reason='joint_conflict', conflicts=component['conflicts']))
            continue
        positions = component['canonical_positions']
        arity = len(positions[component['root']])
        roles = [sorted({signatures[ref][positions[ref][slot]] for ref in component['members']})
                 for slot in range(arity)]
        required = [members for members in roles if len(members) > 1]
        if required and not infer_role_types:
            decisions.append(dict(decision, status='withheld', reason='missing_explicit_role_types', required_role_types=required))
            continue
        evidence = 'Unverified machine candidate edges: ' + ', '.join(component['edge_ids'])
        for members in required:
            if not any(g['members'] == members for g in spec['type_groups']):
                spec['type_groups'].append({'members': members,
                    'evidence': evidence + '; aligned argument slot is a role-type hypothesis, not semantic proof'})
        identifier = 'interface_' + hashlib.sha256(component['root'].encode()).hexdigest()[:16]
        spec['predicate_groups'].append({'id': identifier, 'evidence': evidence,
            'members': [{'predicate': ref, 'order': positions[ref]} for ref in component['members']]})
        decisions.append(dict(decision, status='exported_unverified', group_id=identifier, required_role_types=required))
    return spec, {'status': 'complete', 'graph': graph, 'decisions': decisions,
                  'exported_groups': len(spec['predicate_groups']),
                  'semantic_equivalence_verified': False, 'planner_called': False}


def run(packet_path, prediction_path, inputs, output, infer_role_types=False, compile_domain=False,
        prediction_manifest_path=None):
    require_empty_output(output)
    packet = json.loads(packet_path.read_text(encoding='utf-8'))
    predictions = json.loads(prediction_path.read_text(encoding='utf-8'))
    spec, report = propose(packet, predictions, inputs, infer_role_types)
    if prediction_manifest_path is None:
        raise ValueError('Prediction run manifest required for model/prompt provenance')
    prediction_manifest = json.loads(prediction_manifest_path.read_text(encoding='utf-8'))
    from rcnc.interface_annotation import digest
    if prediction_manifest.get('packet_sha256') != digest(packet) or prediction_manifest.get('status') != 'complete':
        raise ValueError('Incomplete or packet-mismatched prediction manifest')
    spec['proposal_provenance'] = {'packet_sha256': digest(packet),
        'prediction_report_sha256': sha(prediction_path),
        'prediction_manifest_sha256': sha(prediction_manifest_path)}
    output.mkdir(parents=True, exist_ok=True)
    (output / 'packet.json').write_bytes(packet_path.read_bytes())
    (output / 'predictions.json').write_bytes(prediction_path.read_bytes())
    (output / 'prediction_manifest.json').write_bytes(prediction_manifest_path.read_bytes())
    snapshot = output / 'inputs'
    snapshot.mkdir()
    for name, expected in spec['source_sha256'].items():
        data = (inputs / name).read_bytes()
        if hashlib.sha256(data).hexdigest() != expected:
            raise ValueError('Source changed during snapshot')
        (snapshot / name).write_bytes(data)
    # Freeze before any compiler or planner invocation. Source problem files are
    # deliberately absent: candidates cannot import source initial worlds.
    save(output / 'alignment.json', spec)
    report['alignment_sha256'] = sha(output / 'alignment.json')
    report['input_sha256'] = {'packet': sha(output / 'packet.json'), 'predictions': sha(output / 'predictions.json')}
    report['implementation_sha256'] = {str(p): sha(p) for p in (
        Path(__file__), Path('rcnc/interface_graph.py'), Path('scripts/audit/audit_interface_graph.py'),
        Path('scripts/annotation/run_annotation_predictions.py'), Path('rcnc/interface_annotation.py'))}
    report['compilation'] = {'status': 'not_requested'}
    save(output / 'report.json', report)
    if compile_domain:
        try:
            validation = build(snapshot, output / 'compiled', spec)
            from unified_planning.io import PDDLReader
            PDDLReader().parse_problem(str(output / 'compiled/meta_domain.pddl'))
            report['compilation'] = {'status': 'compiled_and_independently_parsed', 'validation': validation}
        except Exception as exc:
            report['status'] = 'compilation_failed'
            report['compilation'] = {'status': 'failed', 'error': f'{type(exc).__name__}: {exc}'}
    report['alignment_unchanged'] = sha(output / 'alignment.json') == report['alignment_sha256']
    report['scope'] = 'Machine hypothesis development condition, not reviewed alignment or semantic evaluation; no planning or source world pooling'
    save(output / 'report.json', report)
    return report

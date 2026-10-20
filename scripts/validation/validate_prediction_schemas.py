"""Offline schema checks and classification of saved machine responses; no new labels."""
import argparse
import importlib.metadata
import json
from pathlib import Path

from jsonschema import Draft202012Validator
from rcnc.interface_annotation import digest
from scripts.experiments.replay_source_probes import sha
from scripts.annotation.run_annotation_predictions import response_schema


def audit(packet_path, previous, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    packet = json.loads(packet_path.read_text(encoding='utf-8'))
    old = json.loads((previous/'report.json').read_text(encoding='utf-8'))
    manifest = json.loads((previous/'manifest.json').read_text(encoding='utf-8'))
    if old['status'] != 'complete' or manifest['packet_sha256'] != digest(packet):
        raise ValueError('Requires completed same-packet prediction run')
    previous_rows = {row['candidate_id']:row for row in old['rows']}
    if set(previous_rows) != {item['id'] for item in packet['items']} or len(old['rows']) != len(packet['items']):
        raise ValueError('Prediction denominator mismatch')
    output.mkdir(parents=True)
    report = {'status':'PASS','total':len(packet['items']),'rows':[],
        'packet_sha256':digest(packet),'previous_report_sha256':sha(previous/'report.json'),
        'jsonschema_version':importlib.metadata.version('jsonschema'),
        'scope':'Schema syntax and label/map consistency only; no new model inference or semantic ground truth'}
    schema_hashes = {}
    for item in packet['items']:
        schemas = {policy:response_schema(item,policy) for policy in ('free_fields','coupled_fields')}
        for schema in schemas.values():
            Draft202012Validator.check_schema(schema)
        schema_hashes[item['id']] = {policy:digest(schema) for policy,schema in schemas.items()}
        validators = {p:Draft202012Validator(s) for p,s in schemas.items()}
        arity = len(item['sides'][0]['parameters'])
        base = {'candidate_id':item['id'],'label':'equivalent','right_from_left':list(range(arity)),
                'rationale':'Synthetic schema-control value, not a semantic judgment','evidence':[]}
        cases = [('identity_equivalence',base,True)]
        for label in ('abstraction','complementary','incompatible','uncertain'):
            valid = {**base,'label':label,'right_from_left':None}
            cases.append((label+'_null',valid,True))
            cases.append((label+'_nonnull',{**valid,'right_from_left':list(range(arity))},False))
        cases.extend([
            ('equivalence_null',{**base,'right_from_left':None},False),
            ('equivalence_nonbijective',{**base,'right_from_left':[0]*(arity+1)},False),
            ('permuted_identity',{**base,'label':'permuted_equivalent'},False)])
        if arity >= 2:
            reverse = list(reversed(range(arity)))
            cases.extend([('permuted_nonidentity',{**base,'label':'permuted_equivalent','right_from_left':reverse},True),
                          ('equivalent_nonidentity',{**base,'right_from_left':reverse},False)])
        controls = [{'name':name,'expected':expected,'accepted':validators['coupled_fields'].is_valid(value)}
                    for name,value,expected in cases]
        row = {'candidate_id':item['id'],'arity':arity,'schema_controls':controls,
               'origin_status':previous_rows[item['id']]['status']}
        source = previous/item['id']/'response.json'
        if source.exists():
            request = json.loads((previous/item['id']/'request.json').read_text(encoding='utf-8'))
            if request['format'] != schemas['free_fields']:
                raise ValueError('Historical free-field schema differs')
            response = json.loads(source.read_text(encoding='utf-8'))
            row.update(saved_response_sha256=sha(source),
                       free_schema_accepts=validators['free_fields'].is_valid(response),
                       coupled_schema_accepts=validators['coupled_fields'].is_valid(response))
        else:
            row['saved_response_absent'] = True
        if any(c['expected'] != c['accepted'] for c in controls):
            report['status']='FAIL'
        report['rows'].append(row)
    report.update(schema_hashes=schema_hashes,
        controls_checked=sum(len(r['schema_controls']) for r in report['rows']),
        saved_responses=sum('saved_response_sha256' in r for r in report['rows']),
        free_schema_accepted=sum(r.get('free_schema_accepts',False) for r in report['rows']),
        coupled_schema_accepted=sum(r.get('coupled_schema_accepts',False) for r in report['rows']),
        implementation_sha256={p:sha(Path(p)) for p in ('scripts/validation/validate_prediction_schemas.py','scripts/annotation/run_annotation_predictions.py')})
    (output/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    return report


if __name__ == '__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--packet',type=Path,required=True)
    p.add_argument('--previous',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args()
    result=audit(a.packet,a.previous,a.output)
    print(json.dumps({k:v for k,v in result.items() if k not in ('rows','schema_hashes')},indent=2))
    raise SystemExit(result['status'] != 'PASS')

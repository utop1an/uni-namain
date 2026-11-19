"""Compare complete schema interventions on identical frozen local-model requests."""
import argparse
from collections import Counter
import json
from pathlib import Path

from jsonschema import Draft202012Validator
from scripts.experiments.replay_source_probes import read, sha
from rcnc.interface_annotation import digest
from scripts.annotation.run_annotation_predictions import check_response


def compare(before, after, output):
    if output.exists():
        raise ValueError('Use a fresh comparison path')
    manifests = [read(p/'manifest.json') for p in (before,after)]
    reports = [read(p/'report.json') for p in (before,after)]
    if any(r['status'] != 'complete' for r in reports):
        raise ValueError('Both full runs must complete')
    for key in ('packet_sha256','model','model_digest','prompt_sha256','options','context_byte_limit','request_timeout_seconds'):
        if key not in manifests[0] or manifests[0][key] != manifests[1].get(key):
            raise ValueError('Unmatched protocol field: '+key)
    for key, default in (('total_budget_seconds', None), ('workers', 1)):
        if manifests[0].get(key, default) != manifests[1].get(key, default):
            raise ValueError('Unmatched protocol field: ' + key)
    packets = [read(p/'packet.json') for p in (before,after)]
    if packets[0] != packets[1]:
        raise ValueError('Packet content differs')
    if digest(packets[0]) != manifests[0]['packet_sha256']:
        raise ValueError('Packet differs from frozen hash')
    items = {item['id']:item for item in packets[0]['items']}
    indexed = [{row['candidate_id']:row for row in r['rows']} for r in reports]
    for r, index in zip(reports,indexed):
        if set(index) != set(items) or len(r['rows']) != len(items) or r['total'] != len(items):
            raise ValueError('Incomplete or duplicate candidate denominator')
    result = {'status':'PASS','total':len(items),'rows':[],
        'scope':'Output-contract intervention; statuses and schema compliance are not semantic accuracy',
        'independent_semantically_verified':0,
        'source_report_sha256':{'before':sha(before/'report.json'),'after':sha(after/'report.json')},
        'schema_policies':[m.get('schema_policy','free_fields') for m in manifests]}
    result['comparison_kind'] = ('schema_intervention' if len(set(result['schema_policies'])) == 2 else 'same_schema_recheck')
    result['execution_kinds'] = [m.get('execution_kind', 'offline_replay' if 'origin_manifest' in m else 'local_model') for m in manifests]
    result['measurement_condition'] = ('offline_replay_only' if set(result['execution_kinds']) == {'offline_replay'}
        else 'local_model_runs' if set(result['execution_kinds']) == {'local_model'} else 'mixed_live_and_replay')
    for key,item in items.items():
        row = {'candidate_id':key,'before_status':indexed[0][key]['status'],'after_status':indexed[1][key]['status']}
        requests=[]
        for label, root, index in zip(('before','after'),(before,after),indexed):
            path=root/key/'request.json'
            attempted = index[key].get('request_attempted', index[key]['status'] not in ('context_budget_excluded', 'budget_exhausted'))
            if not attempted:
                if index[key]['status'] not in ('context_budget_excluded', 'budget_exhausted'):
                    raise ValueError('Unrequested candidate has an inconsistent outcome')
                requests.append(None)
                continue
            if not path.exists():
                raise ValueError('Missing request for attempted candidate')
            request=read(path)
            schema=request.pop('format')
            requests.append(request)
            saved=root/key/'response.json'
            if index[key]['status'] in ('checked','invalid'):
                response=read(saved)
                if response != index[key]['response']:
                    raise ValueError('Saved response differs from report')
                errors=check_response(packets[0],item,response)
                if sorted(errors) != sorted(index[key]['errors']):
                    raise ValueError('Saved checker errors are not reproducible')
                if ('invalid' if errors else 'checked') != index[key]['status']:
                    raise ValueError('Saved checker status is not reproducible')
                row[label+'_strict_schema_compliant']=Draft202012Validator(schema).is_valid(response)
                row[label+'_response_sha256']=sha(saved)
        both_attempted = all(request is not None for request in requests)
        if both_attempted and requests[0] != requests[1]:
            raise ValueError('Request changed beyond schema: '+key)
        row['request_equal_except_schema'] = True if both_attempted else None
        result['rows'].append(row)
    result.update(before_counts=dict(Counter(r['before_status'] for r in result['rows'])),
        after_counts=dict(Counter(r['after_status'] for r in result['rows'])),
        status_transitions=dict(Counter(r['before_status']+' -> '+r['after_status'] for r in result['rows'])),
        strict_schema_compliant={label:sum(r.get(label+'_strict_schema_compliant',False) for r in result['rows']) for label in ('before','after')},
        matched_attempted_candidates=sum(r['request_equal_except_schema'] is True for r in result['rows']),
        request_comparison_unavailable=sum(r['request_equal_except_schema'] is None for r in result['rows']),
        total_budget_seconds=manifests[0].get('total_budget_seconds'),
        implementation_sha256={name:sha(Path(name)) for name in ('scripts/annotation/compare_annotation_predictions.py','scripts/annotation/run_annotation_predictions.py','rcnc/interface_annotation.py')})
    output.parent.mkdir(parents=True,exist_ok=True)
    output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    return result


if __name__ == '__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--before',type=Path,required=True)
    p.add_argument('--after',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args()
    r=compare(a.before,a.after,a.output)
    print(json.dumps({k:v for k,v in r.items() if k != 'rows'},indent=2))

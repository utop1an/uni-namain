"""Local-model hypotheses on a frozen annotation packet; never human gold."""
from prompts import load_prompt

import argparse
from collections import Counter
import copy
from datetime import datetime, timezone
import hashlib
import itertools
import json
import math
from pathlib import Path
import time
import urllib.request

from rcnc.interface_annotation import LABELS, digest, save, validate_annotations

PROMPT = load_prompt('annotation/annotation_predicate')


class _TotalBudgetExhausted(Exception):
    pass


def response_schema(item, policy='free_fields'):
    if policy not in ('free_fields', 'coupled_fields'):
        raise ValueError('Unknown schema policy')
    branches = []
    for side, data in enumerate(item['sides']):
        for action in data['action_contexts']:
            literals = sorted({o['literal'] for o in action['occurrences']})
            branches.append({'type': 'object', 'additionalProperties': False,
                'properties': {'side': {'type': 'integer', 'enum': [side]},
                    'ref': {'type': 'string', 'enum': [action['ref']]},
                    'quote': {'type': 'string', 'enum': literals}}, 'required': ['side', 'ref', 'quote']})
    base = {'type': 'object', 'additionalProperties': False,
        'properties': {'candidate_id': {'type': 'string', 'enum': [item['id']]},
            'label': {'type': 'string', 'enum': list(LABELS)},
            'right_from_left': {'anyOf': [{'type': 'null'}, {'type': 'array', 'items': {'type': 'integer'}}]},
            'rationale': {'type': 'string'},
            'evidence': {'type': 'array', 'maxItems': 6, 'items': {'anyOf': branches} if branches else {'type': 'object'},
                         **({'maxItems': 0} if not branches else {})}},
        'required': ['candidate_id', 'label', 'right_from_left', 'rationale', 'evidence']}
    if policy == 'free_fields':
        return base
    arity = len(item['sides'][0]['parameters'])
    if arity > 6:
        raise ValueError('Coupled permutation enumeration supports arity at most six')
    identity = list(range(arity))
    policies = [(['equivalent'], {'type': 'array', 'enum': [identity]}),
                (['abstraction', 'complementary', 'incompatible', 'uncertain'], {'type': 'null'})]
    other = [list(order) for order in itertools.permutations(identity) if list(order) != identity]
    if other:
        policies.append((['permuted_equivalent'], {'type': 'array', 'enum': other}))
    variants = []
    for labels, order_schema in policies:
        variant = copy.deepcopy(base)
        variant['properties']['label'] = {'type': 'string', 'enum': labels}
        variant['properties']['right_from_left'] = order_schema
        variants.append(variant)
    return {'anyOf': variants}


def check_response(packet, item, response):
    if not isinstance(response, dict):
        return ['response_not_object']
    if response.get('candidate_id') != item['id']:
        return ['wrong_candidate']
    # Reuse citation/map checks only. Explicitly retain machine provenance;
    # lack of human independence is expected, never converted to a declaration.
    annotation = {'packet_sha256': digest(packet), 'annotator_id': 'machine_prediction',
        'independent_of_model_and_solver_outcomes': False,
        'rows': [{**response, 'status': 'completed', 'date': 'machine-run'}]}
    result = validate_annotations(packet, annotation)
    errors = [e for e in result['errors'] if e != 'independence_not_declared']
    if isinstance(response.get('evidence'), list) and len(response['evidence']) > 6:
        errors.append('evidence_budget_exceeded')
    for cite in response.get('evidence', []) if isinstance(response.get('evidence'), list) else []:
        if not isinstance(cite, dict) or type(cite.get('side')) is not int or cite['side'] not in (0, 1):
            continue
        uses = [o['literal'] for a in item['sides'][cite['side']]['action_contexts']
                if a['ref'] == cite.get('ref') for o in a['occurrences']]
        if isinstance(cite.get('quote'), str) and not any(literal in cite['quote'] for literal in uses):
            errors.append('evidence_missing_candidate_occurrence')
    return sorted(set(errors))


def request_json(url, payload=None, timeout=240):
    request = urllib.request.Request(url, data=json.dumps(payload).encode() if payload is not None else None,
                                     headers={'Content-Type': 'application/json'})
    with urllib.request.urlopen(request, timeout=timeout) as result:
        return json.load(result)


def run(packet_path, output, model='gemma3:4b', replay=None, schema_policy='free_fields', total_seconds=None):
    if total_seconds is not None and (type(total_seconds) not in (int, float)
                                      or not math.isfinite(total_seconds) or total_seconds <= 0):
        raise ValueError('Total seconds budget must be finite and positive')
    if replay and total_seconds is not None:
        raise ValueError('Replay preserves original budget outcomes; do not impose a new live budget')
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    packet = json.loads(packet_path.read_text(encoding='utf-8'))
    schemas = {item['id']: response_schema(item, schema_policy) for item in packet['items']}
    output.mkdir(parents=True, exist_ok=True)
    save(output/'packet.json', packet)
    base = 'http://127.0.0.1:11434'
    options = {'temperature': 0, 'seed': 20261015, 'num_ctx': 16384, 'num_predict': 2048}
    manifest = {'status': 'prepared', 'packet_sha256': digest(packet), 'model': model,
        'prompt_sha256': digest(PROMPT), 'options': options, 'total': len(packet['items']),
        'schema_policy': schema_policy, 'schemas_sha256': digest(schemas),
        'implementation_sha256': {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in
             [Path(__file__), Path(__file__).resolve().parents[2]/'rcnc/interface_annotation.py']},
        'started_utc': datetime.now(timezone.utc).isoformat(), 'source': 'machine_predictions_not_human_annotations',
        'context_byte_limit': 48000, 'request_timeout_seconds': 240, 'automatic_alignment_adoption': False}
    manifest.update(total_budget_seconds=total_seconds,
        stop_rule='No new request after total deadline; unrequested candidates retained as budget_exhausted',
        budget_enforcement='Request-admission deadline and remaining socket timeout; response processing or active I/O may finish after deadline',
        workers=1, execution_kind='offline_replay' if replay else 'local_model',
        row_request_attempted_provenance='origin_run' if replay else 'current_run')
    save(output/'manifest.json', manifest)
    save(output/'schemas.json', schemas)
    implementation = output/'implementation'
    implementation.mkdir()
    for filename, expected in manifest['implementation_sha256'].items():
        path = Path(filename)
        content = path.read_bytes()
        if hashlib.sha256(content).hexdigest() != expected:
            raise ValueError('Code changed while freezing prediction run')
        (implementation/path.name).write_bytes(content)
    start = time.perf_counter()
    deadline = None if total_seconds is None else start + total_seconds
    rows = []
    requests_attempted = 0
    try:
        if replay:
            old = json.loads((replay/'manifest.json').read_text(encoding='utf-8'))
            if any(old[k] != manifest[k] for k in ('packet_sha256', 'model', 'prompt_sha256', 'options')):
                raise ValueError('Replay packet/model/prompt/options mismatch')
            if old.get('schema_policy', 'free_fields') != schema_policy:
                raise ValueError('Replay schema policy mismatch')
            manifest['origin_manifest'] = old
            origin = old
            while isinstance(origin, dict):
                if origin.get('model_digest'):
                    manifest['model_digest'] = origin['model_digest']
                    manifest['model_digest_provenance'] = 'replay_origin_not_live_verification'
                    break
                origin = origin.get('origin_manifest')
        else:
            tags = request_json(base+'/api/tags', timeout=min(10, total_seconds) if total_seconds else 10)
            installed = next((m for m in tags.get('models', []) if m['name'] == model), None)
            if installed is None or installed.get('remote_host') or installed.get('remote_model') or 'cloud' in model:
                raise ValueError('Only an already installed local model is permitted')
            manifest['model_digest'] = installed['digest']
        manifest['status'] = 'running'
        save(output/'manifest.json', manifest)
        for item in packet['items']:
            directory = output/item['id']
            directory.mkdir()
            row = {'candidate_id': item['id'], 'request_attempted': False}
            context = json.dumps(item, ensure_ascii=False)
            try:
                prior = json.loads((replay/item['id']/'report.json').read_text(encoding='utf-8')) if replay else None
                if prior is not None:
                    row['request_attempted'] = prior.get('request_attempted', prior['status'] not in ('budget_exhausted', 'context_budget_excluded'))
                remaining = None if deadline is None else deadline - time.perf_counter()
                if len(context.encode()) > manifest['context_byte_limit']:
                    row['status'] = 'context_budget_excluded'
                elif prior and prior['status'] == 'budget_exhausted':
                    row.update(status='budget_exhausted', reason=prior.get('reason', 'total_wall_budget_exhausted'))
                elif remaining is not None and remaining <= 0:
                    row.update(status='budget_exhausted', reason='total_wall_budget_exhausted')
                else:
                    payload = {'model': model, 'stream': False, 'format': schemas[item['id']], 'options': options,
                        'messages': [{'role': 'system', 'content': PROMPT}, {'role': 'user', 'content': context}]}
                    save(directory/'request.json', payload)
                    if replay:
                        saved_request = json.loads((replay/item['id']/'request.json').read_text(encoding='utf-8'))
                        if saved_request != payload:
                            raise ValueError('Replay request/schema mismatch')
                        if prior['status'] == 'failed':
                            row.update(status='failed', error=prior.get('error'), replayed_origin_failure=True)
                        else:
                            response = json.loads((replay/item['id']/'response.json').read_text(encoding='utf-8'))
                    else:
                        timeout = manifest['request_timeout_seconds']
                        if deadline is not None:
                            remaining = deadline - time.perf_counter()
                            if remaining <= 0:
                                raise _TotalBudgetExhausted()
                            timeout = min(timeout, remaining)
                        requests_attempted += 1
                        row['request_attempted'] = True
                        raw = request_json(base+'/api/chat', payload, timeout=timeout)
                        save(directory/'raw_response.json', raw)
                        if raw.get('done') is not True or raw.get('done_reason') == 'length':
                            raise ValueError('Incomplete or token-truncated response')
                        response = json.loads(raw['message']['content'])
                    if row.get('status') != 'failed':
                        save(directory/'response.json', response)
                        errors = check_response(packet, item, response)
                        row.update(status='invalid' if errors else 'checked', response=response, errors=errors)
            except _TotalBudgetExhausted:
                row.update(status='budget_exhausted', reason='total_wall_budget_exhausted')
            except Exception as exc:
                row.update(status='failed', error=f'{type(exc).__name__}: {exc}')
            rows.append(row)
            save(directory/'report.json', row)
            save(output/'progress.json', {'total': len(packet['items']), 'processed': len(rows), 'rows': rows})
            print(json.dumps({'processed': len(rows), 'total': len(packet['items']), 'candidate_id': item['id'], 'status': row['status']}), flush=True)
        report = {'status': 'complete', 'total': len(packet['items']), 'processed': len(rows),
            'counts': dict(Counter(r['status'] for r in rows)),
            'checked_label_counts': dict(Counter(r['response']['label'] for r in rows if r['status'] == 'checked')),
            'independent_semantically_verified': 0, 'rows': rows}
    except Exception as exc:
        report = {'status': 'failed', 'error': f'{type(exc).__name__}: {exc}', 'total': len(packet['items']), 'processed': len(rows), 'rows': rows}
    report.update(elapsed_seconds=time.perf_counter()-start, packet_sha256=digest(packet),
                  requests_attempted=requests_attempted, replay=bool(replay),
                  budget_exhausted_count=sum(r['status'] == 'budget_exhausted' for r in rows),
                  all_candidates_requested=not replay and report['status'] == 'complete' and not any(r['status'] in ('budget_exhausted', 'context_budget_excluded') for r in rows)
                      and len(rows) == len(packet['items']),
                  limit='Full processing coverage is not semantic accuracy; no gold annotations available')
    save(output/'report.json', report)
    manifest.update(status=report['status'], finished_utc=datetime.now(timezone.utc).isoformat())
    save(output/'manifest.json', manifest)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--packet', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--model', default='gemma3:4b')
    parser.add_argument('--replay', type=Path)
    parser.add_argument('--schema-policy', choices=['free_fields', 'coupled_fields'], default='free_fields')
    parser.add_argument('--total-seconds', type=float, help='Total live-run budget; keep unrequested rows as budget_exhausted')
    args = parser.parse_args()
    result = run(args.packet, args.output, args.model, args.replay, args.schema_policy, args.total_seconds)
    print(json.dumps({k: v for k, v in result.items() if k != 'rows'}, indent=2))

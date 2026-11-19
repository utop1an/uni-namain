"""Prepare reviewable OpenAI requests and union exports without network calls.

Model, monetary cap and credentials are resolved separately before dispatch.
The frozen selection and baseline remain immutable.
"""
import argparse
from collections import Counter
from functools import lru_cache
import importlib.util
import json
from pathlib import Path
import shutil

SELECTOR_PATH = Path(__file__).with_name('frozen_union_full.py')
spec = importlib.util.spec_from_file_location('frozen_selection_adapter', SELECTOR_PATH)
selection_adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(selection_adapter)
read, digest, write = selection_adapter.read, selection_adapter.digest, selection_adapter.write


def verify_selection(root):
    frozen = read(root / 'freeze.json')
    if digest(root / 'freeze.json') != (root / 'FREEZE.sha256').read_text(encoding='utf-8').strip():
        raise ValueError('Selection manifest changed')
    for name, checksum in frozen['artifact_sha256'].items():
        if digest(root / name) != checksum:
            raise ValueError('Selection artifact changed: ' + name)
    if digest(SELECTOR_PATH) != read(root / 'selection_policy.json')['adapter_sha256']:
        raise ValueError('Selection adapter changed')
    return frozen


def request_body(item, *, model, reasoning, max_output_tokens, compact_prompt, compact_schema):
    schema = compact_schema(item)
    content = (compact_prompt(item['kind']) + '\nRequired output JSON schema '
               '(all required fields, exact names and types; no markdown fences, no extra prose):\n'
               + json.dumps(schema) + '\nInput data:\n'
               + json.dumps({k: item[k] for k in ('kind', 'sides')}))
    return {'model': model, 'input': [{'role': 'user', 'content': content}],
            'reasoning': {'effort': reasoning}, 'max_output_tokens': max_output_tokens,
            'text': {'format': {'type': 'json_schema', 'name': 'semantic_alignment',
                                'strict': True, 'schema': schema}},
            'store': False}


def decode_response(payload, item, normalize, validate):
    if payload.get('status') != 'completed':
        raise ValueError('Incomplete response: ' + str(payload.get('incomplete_details')))
    parts = []
    for output in payload.get('output', []):
        if output.get('type') == 'message':
            for content in output.get('content', []):
                if content.get('type') == 'refusal':
                    raise ValueError('Model refusal')
                if content.get('type') == 'output_text':
                    parts.append(content['text'])
    if len(parts) != 1:
        raise ValueError('Expected exactly one JSON text response')
    compact = json.loads(parts[0])
    normalized = normalize(item, compact)
    validate(item, normalized)
    return compact, normalized


def prepare(dataset, root, model, reasoning, max_output_tokens):
    if root.exists():
        raise ValueError('Fresh preparation directory required')
    frozen = verify_selection(dataset)
    release = Path(frozen['release'])
    verified = selection_adapter.verify_release(release)
    selection, Source = selection_adapter.bind_release(release)
    from rcnc import model_semantics
    from rcnc.glaive_merge import build, map_problem
    from rcnc.model_semantics_compact import prompt, schema
    from rcnc.pddl import serialize
    root.mkdir(parents=True)
    sources, source_rows, worlds = selection_adapter.load_sources(release, Source)
    by_source = {r['id']: r for r in source_rows}
    groups = read(dataset / 'selected_groups.json')['groups']
    candidates = read(dataset / 'candidates.json')['candidates']
    # Each candidate is sent only once within this new round, independently of
    # method/cohort/k membership. No outcomes are used to choose or order groups.
    write(root / 'preparation_policy.json', {'status': 'offline_preparation_only',
        'dataset': str(dataset), 'selection_sha256': digest(dataset / 'freeze.json'),
        'release': str(release), **verified, 'conditions': ['union', 'full'],
        'model_proposal': model, 'reasoning_proposal': reasoning, 'max_output_tokens': max_output_tokens,
        'network_calls_authorized_by_this_artifact': False,
        'execution_requires': ['resolved OpenAI model and endpoint', 'available credential',
                               'frozen monetary and execution budgets', 'runtime preflight'],
        'no_history_reuse': True, 'no_retries': True})
    for filename in (SELECTOR_PATH, Path(__file__)):
        target = root / 'implementation' / filename.name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(filename, target)
    inputs = root / 'semantic_inputs'
    inputs.mkdir()
    for sid, source in sources.items():
        (inputs / (sid + '_domainfile.pddl')).write_text(serialize(source.root) + '\n', encoding='utf-8')

    def occurs(expr, symbol):
        return isinstance(expr, list) and (bool(expr) and expr[0] == symbol or any(occurs(x, symbol) for x in expr))

    @lru_cache(maxsize=None)
    def context(reference, kind):
        side = model_semantics.context(inputs, reference, kind)
        sid, name = reference.split(':', 1)
        if kind == 'predicate':
            side['contexts'].extend({'id': sid + ':axiom_' + str(i), 'text': serialize(axiom)}
                                   for i, axiom in enumerate(sources[sid].axioms) if occurs(axiom, name))
        return side

    totals = Counter()
    prompt_sizes = []
    with (root / 'openai_requests.jsonl').open('x', encoding='utf-8', newline='\n') as stream, (
            root / 'judgment_packet.jsonl').open('x', encoding='utf-8', newline='\n') as packet:
        for candidate in candidates:
            item = {**candidate, 'sides': [context(ref, candidate['kind']) for ref in candidate['references']]}
            body = request_body(item, model=model, reasoning=reasoning, max_output_tokens=max_output_tokens,
                                compact_prompt=prompt, compact_schema=schema)
            request = {'custom_id': item['id'], 'method': 'POST', 'url': '/v1/responses', 'body': body}
            stream.write(json.dumps(request, ensure_ascii=False) + '\n')
            packet.write(json.dumps(item, ensure_ascii=False) + '\n')
            size = len(body['input'][0]['content'].encode('utf-8'))
            schema_size = len(json.dumps(body['text']['format']).encode('utf-8'))
            # Byte counts are auditable sizing evidence, not a tokenizer result.
            totals['input_text_utf8_bytes'] += size
            totals['response_format_utf8_bytes'] += schema_size
            prompt_sizes.append(size)
    print('prepared OpenAI requests', len(candidates), 'text bytes', totals['input_text_utf8_bytes'], flush=True)
    write(root / 'payload_scope.json', {
        'destination_proposal': 'https://api.openai.com/v1/responses', 'store': False,
        'transmitted': ['fixed alignment instructions and output schema',
                        'published PDDL predicate/action declarations and usage formulas',
                        'applicable original domain axiom formulas',
                        'source-local IDs, argument types and symbol digests'],
        'not_transmitted': ['API credential in saved payloads', 'filesystem paths',
                            'problem initial states and goals', 'plans and search results',
                            'group/cohort/method membership and selection scores',
                            'repository source code and private configuration'],
        'source_provenance': [{'source': r['id'], 'baseline_model_id': r['baseline_model_id'],
                              'baseline_pair_ids': r['baseline_pair_ids']} for r in source_rows],
        'provenance_catalog': str(release / 'source_catalog.json'),
        'provenance_sha256': digest(release / 'source_catalog.json'),
        'semantic_inputs_sha256': {p.name: digest(p) for p in sorted(inputs.glob('*.pddl'))}})
    # Prepare the actual requested union arm before any model or planner call.
    # Export every original world separately, including failures in accounting.
    export_rows = []
    world_by_source = defaultdict_list(worlds, 'source')
    for index, group in enumerate(groups, 1):
        selected = [sources[s] for s in group['sources']]
        folder = root / 'union_models' / group['id']
        row = {'group': group['id'], 'cohort': group['cohort'], 'method': group['method'],
               'k': group['size'], 'condition': 'union', 'worlds': []}
        try:
            mapping = build(selected, folder)
            row['status'] = 'exported_not_native_parsed'
            row['domain'] = str(folder / 'domain.pddl')
            for sid in group['sources']:
                for world in world_by_source[sid]:
                    result = {'world': world['id'], 'source': sid}
                    try:
                        local = Source(sid, Path(world['domain']), Path(world['problem']),
                                       constant_contract=world['constant_contract'],
                                       consent_policy=world['consent_policy'])
                        problem = folder / 'worlds' / (world['id'] + '.pddl')
                        problem.parent.mkdir(parents=True, exist_ok=True)
                        terms = map_problem([local if s.id == sid else s for s in selected], sid, mapping, problem)
                        result.update(status='exported_not_native_parsed', problem=str(problem), terms=terms)
                    except (ValueError, KeyError, TypeError, IndexError) as exc:
                        result.update(status='world_export_failed', reason=str(exc))
                    row['worlds'].append(result)
        except (ValueError, KeyError, TypeError, IndexError) as exc:
            row.update(status='domain_export_failed', reason=str(exc))
            row['worlds'] = [{'world': w['id'], 'source': s, 'status': 'unavailable_domain_export'}
                             for s in group['sources'] for w in world_by_source[s]]
        export_rows.append(row)
        if index % 100 == 0:
            print('union export', index, '/', len(groups), flush=True)
    write(root / 'union_export_report.json', {'status': 'complete_export_census',
        'registered_groups': len(groups), 'domain_statuses': dict(Counter(r['status'] for r in export_rows)),
        'registered_source_world_slots': sum(len(r['worlds']) for r in export_rows),
        'world_statuses': dict(Counter(w['status'] for r in export_rows for w in r['worlds'])),
        'native_parse_or_plan_validation_claimed': False, 'rows': export_rows})
    report = {'status': 'prepared_awaiting_openai_configuration_and_budget',
        'groups': len(groups), 'conditions': ['union', 'full'], 'group_conditions': len(groups)*2,
        'model_requests': len(candidates), 'model_proposal': model, 'reasoning_proposal': reasoning,
        'max_output_tokens_per_request': max_output_tokens,
        'maximum_output_tokens': len(candidates)*max_output_tokens,
        **totals, 'largest_prompt_utf8_bytes': max(prompt_sizes),
        'token_count_status': 'not_measured_bytes_are_not_tokens',
        'pricing_reference': 'https://developers.openai.com/api/docs/models',
        'proposal_price_usd_per_million_tokens': {'input': 2.0, 'output': 10.0} if model == 'gpt-6.1-sol' else None,
        'proposal_maximum_output_cost_usd_excluding_input': round(len(candidates)*max_output_tokens*10/1e6, 2)
             if model == 'gpt-6.1-sol' else None,
        'budget_approved_usd': None, 'model_calls': 0, 'planner_calls': 0,
        'union_domain_statuses': dict(Counter(r['status'] for r in export_rows)),
        'full_status': 'not_run_missing_fresh_model_judgments',
        'original_worlds': len(worlds), 'original_worlds_pooled': False,
        'planning_budget_proposal': {'search_seconds_per_slot': 15, 'replay_seconds_per_slot': 15,
            'planner_workers': 2, 'planner_memory_mb_per_worker': 4096,
            'compiler_workers': 2, 'group_construction_seconds': 120, 'group_route_prefixes': 50000,
            'original_world_transport_slots': 2*sum(len(r['worlds']) for r in export_rows),
            'anchor_original_goal_search_slots': 4800, 'diagnostic_composition_search_slots': 2400,
            'raw_and_adapter_reference_search_slots': 2*len(worlds)},
        'interpretation': 'Prepared inputs and exports, not experiment outcomes or semantic validation.'}
    write(root / 'preparation_report.json', report)
    hashes = {p.relative_to(root).as_posix(): digest(p) for p in sorted(root.rglob('*')) if p.is_file()}
    write(root / 'preparation_freeze.json', {'status': 'frozen_offline_preparation',
        'selection_sha256': digest(dataset / 'freeze.json'), 'baseline_manifest_sha256': verified['manifest_sha256'],
        'files': hashes})
    (root / 'PREPARATION.sha256').write_text(digest(root / 'preparation_freeze.json') + '\n', encoding='utf-8')
    print(json.dumps(report, ensure_ascii=False, indent=2), flush=True)


def defaultdict_list(rows, key):
    result = {}
    for row in rows:
        result.setdefault(row[key], []).append(row)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dataset', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--model', default='gpt-6.1-sol', help='Proposal only; not permission to call')
    parser.add_argument('--reasoning', default='medium')
    parser.add_argument('--max-output-tokens', type=int, default=4096)
    args = parser.parse_args()
    if not 1 <= args.max_output_tokens <= 32768:
        raise ValueError('Invalid proposed output budget')
    prepare(args.dataset.resolve(), args.output.resolve(), args.model, args.reasoning, args.max_output_tokens)


if __name__ == '__main__':
    main()

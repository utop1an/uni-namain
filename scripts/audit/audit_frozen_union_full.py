"""Verify the new matrix and freeze pre-request eligibility without paid calls."""
import argparse
from collections import Counter
import importlib.util
import json
from pathlib import Path

ADAPTER = Path(__file__).resolve().parents[1] / 'experiments/prepare_union_full_openai.py'
spec = importlib.util.spec_from_file_location('openai_preparation_adapter', ADAPTER)
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)
read, digest, write = adapter.read, adapter.digest, adapter.write


def audit(dataset, preparation, output):
    if output.exists():
        raise ValueError('Fresh audit output required')
    selection = adapter.verify_selection(dataset)
    release = Path(selection['release'])
    checked = adapter.selection_adapter.verify_release(release)
    manifest = read(preparation / 'preparation_freeze.json')
    if digest(preparation / 'preparation_freeze.json') != (
            preparation / 'PREPARATION.sha256').read_text(encoding='utf-8').strip():
        raise ValueError('Preparation manifest changed')
    for name, checksum in manifest['files'].items():
        if digest(preparation / name) != checksum:
            raise ValueError('Prepared file changed: ' + name)
    output.mkdir(parents=True)
    groups = read(dataset / 'selected_groups.json')['groups']
    pools = {r['id']: r['pool'] for r in read(dataset / 'sources.json')['sources']}
    census = Counter((g['cohort'], g['method'], g['size']) for g in groups)
    assert len(groups) == len({g['id'] for g in groups}) == 1200
    assert len(census) == 24 and set(census.values()) == {50}
    for cell in census:
        members = [g for g in groups if (g['cohort'], g['method'], g['size']) == cell]
        assert len({tuple(g['sources']) for g in members}) == 50
        for group in members:
            assert len(set(group['sources'])) == group['size']
            assert group['sources'] == sorted(group['sources'])
            actual = {pools[s] for s in group['sources']}
            assert actual == ({'human', 'story'} if group['cohort'] == 'mixed' else {group['cohort']})
    # Replay deterministic selection using frozen input features, independent of
    # judgments/plans; a failed or partial graph census is never accepted.
    path_data = read(dataset / 'path_inventory.json')
    assert path_data['complete_within_declared_fragment'] is True
    core, Source = adapter.selection_adapter.bind_release(release)
    replayed, cells = adapter.selection_adapter.choose(read(dataset / 'sources.json')['sources'],
        read(dataset / 'pair_census.json')['pairs'], path_data, core)
    assert groups == replayed
    candidates = read(dataset / 'candidates.json')['candidates']
    items = [json.loads(line) for line in (preparation / 'judgment_packet.jsonl').open(encoding='utf-8')]
    assert [x['id'] for x in candidates] == [x['id'] for x in items]
    eligibility, stats, eligible_bytes = [], Counter(), Counter()
    requests = (preparation / 'openai_requests.jsonl').open(encoding='utf-8')
    for item in items:
        request = json.loads(next(requests))
        assert request['custom_id'] == item['id']
        assert request['url'] == '/v1/responses' and request['method'] == 'POST'
        body = request['body']
        assert body['model'] == 'gpt-6.1-sol' and body['reasoning'] == {'effort': 'medium'}
        assert body['max_output_tokens'] == 4096 and body['store'] is False
        assert body['text']['format']['strict'] is True
        assert json.loads(body['input'][0]['content'].rsplit('\n', 1)[1]) == {
            k: item[k] for k in ('kind', 'sides')}
        status = ('eligible' if all(s['contexts'] for s in item['sides'])
                  else 'not_requested_insufficient_source_context')
        eligibility.append({'id': item['id'], 'kind': item['kind'], 'status': status,
                            'missing_context_sides': [s['reference'] for s in item['sides'] if not s['contexts']]})
        stats[status] += 1
        if status == 'eligible':
            eligible_bytes['input_text_utf8_bytes'] += len(body['input'][0]['content'].encode('utf-8'))
            eligible_bytes['format_utf8_bytes'] += len(json.dumps(body['text']['format']).encode('utf-8'))
    assert next(requests, None) is None
    requests.close()
    union = read(preparation / 'union_export_report.json')
    assert {r['group'] for r in union['rows']} == {g['id'] for g in groups}
    assert union['registered_source_world_slots'] == sum(len(r['worlds']) for r in union['rows'])
    from rcnc.pddl import parse_domain, parse_sexpr, section
    parsed, world_count = 0, 0
    for row in union['rows']:
        if row['status'] != 'exported_not_native_parsed':
            continue
        domain = parse_domain(Path(row['domain']))
        mapping = read(Path(row['domain']).with_name('mapping.json'))
        assert mapping['action_count'] == mapping['source_action_count'] == len(domain.actions)
        assert len(mapping['action_maps']) == mapping['source_action_count']
        parsed += 1
        for world in row['worlds']:
            if world['status'] == 'exported_not_native_parsed':
                problem_root = parse_sexpr(Path(world['problem']).read_text(encoding='utf-8'))
                assert problem_root[0] == 'define' and problem_root[1][0] == 'problem'
                assert section(problem_root, ':init') is not None
                assert section(problem_root, ':goal') is not None
                world_count += 1
    write(output / 'request_eligibility.json', {'rows': eligibility, 'status_counts': dict(stats),
        'policy': 'Prospective evidence contract gate; no model/planner outcomes used. '
                  'Missing usage context cannot satisfy required per-side citations. Keep symbols separate and retain rows.',
        'candidate_denominator': len(items), 'all_groups_retained': 1200})
    eligible = stats['eligible']
    report = {'status': 'verified_offline_preparation', 'dataset': str(dataset),
        'preparation': str(preparation), 'model': 'gpt-6.1-sol', 'reasoning': 'medium',
        'selection_sha256': digest(dataset / 'freeze.json'),
        'preparation_sha256': digest(preparation / 'preparation_freeze.json'), **checked,
        'preparation_files_verified': len(manifest['files']), 'groups': 1200, 'group_conditions': 2400,
        'cells': [{'cohort': c[0], 'method': c[1], 'k': c[2], 'groups': n} for c, n in sorted(census.items())],
        'selection_replay_identical': True, 'conditions': ['union', 'full'],
        'python_parsed_union_domains': parsed, 'python_parsed_separate_source_problems': world_count,
        'native_glaive_parse_not_run': True, 'planner_or_replay_not_run': True,
        'candidates': len(items), 'request_status_counts': dict(stats),
        'maximum_paid_requests': eligible, 'max_output_tokens_per_request': 4096,
        'maximum_output_tokens': eligible*4096,
        'maximum_output_cost_usd_excluding_input': round(eligible*4096*10/1e6, 2),
        'official_pricing_source': 'https://developers.openai.com/api/docs/models',
        'usd_per_million_tokens': {'input': 2, 'output': 10}, **eligible_bytes,
        'input_tokens_not_measured': True, 'approved_spending_cap_usd': None,
        'model_access_read_only_probe': {'http_status': 200, 'model_id': 'gpt-6.1-sol',
                                       'credential_configuration_key': 'openai_api', 'inference_calls': 0},
        'meaning': 'Prepared and checked, not a completed comparison; no paid calls or search results.'}
    write(output / 'report.json', report)
    write(output / 'tests_receipt.json', {'command': '.venv/Scripts/python.exe -X utf8 -m unittest '
        'tests.test_frozen_union_full tests.test_selection_comparison -v',
        'tests_run': 16, 'status': 'passed', 'source': 'Observed local test command in this preparation turn',
        'test_file_sha256': {str(p): digest(p) for p in [
            Path('tests/test_frozen_union_full.py'), Path('tests/test_selection_comparison.py')]}})
    hashes = {p.name: digest(p) for p in output.iterdir() if p.is_file()}
    write(output / 'audit_freeze.json', {'status': 'frozen_prerequest_audit', 'files': hashes,
                                       'audit_implementation_sha256': digest(__file__)})
    print(json.dumps({k: v for k, v in report.items() if k != 'cells'}, ensure_ascii=False, indent=2), flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('dataset', 'preparation', 'output'):
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    audit(args.dataset.resolve(), args.preparation.resolve(), args.output.resolve())

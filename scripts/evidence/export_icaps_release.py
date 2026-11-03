"""Export necessary final research evidence, without caches, logs, or binaries.

This is a read-only export of existing completed experiments. It makes no model
or planner requests and refuses to overwrite an existing release directory.
"""
import argparse
from collections import Counter
from pathlib import Path
import json
import shutil

from rcnc.domain_building import digest, save
from scripts.experiments import run_revised_multistory as base


def export(output):
    if output.exists(): raise ValueError('Fresh release directory required')
    campaign = Path('data/validation/revised_multistory_k234_parallel10_iofix_2026_11_02_v1')
    expanded = Path('data/validation/revised_multistory_composition_expanded70_2026_11_03_v1')
    audit = Path('data/validation/revised_multistory_composition_expanded70_audit_2026_11_03_v1')
    case = Path('data/validation/four_domain_long_case_explicit_apology_intention_2026_11_03_v1')
    first = Path('data/validation/revised_multistory_repeat01_paper_eval_2026_11_03_v1')
    main = base.read(campaign / 'protocol.json')
    results = base.read(campaign / 'repeat_01/report.json')
    extra = base.read(audit / 'analysis.json'); final = base.read(case / 'report.json')
    if results['status'] != 'complete' or extra['status'] != 'verified_expanded_composition_analysis':
        raise ValueError('Incomplete source result')
    if not final['requirements_met'] or not base.valid(final['replay']):
        raise ValueError('Case did not pass all validation gates')
    output.mkdir(parents=True)
    def copy(source, relative):
        dst = output / relative; dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, dst)
    sources = []
    for row in main['source_rows']:
        sid = row['id']; record = {'id': sid, 'corpus': row['corpus']}
        for old_name, name in [('revised-domain.pddl', 'domain.pddl'), ('revised-problem.pddl', 'problem.pddl')]:
            source = base.DATA / row['files'][old_name]['frozen_path']
            relative = 'sources/' + sid + '/' + name
            copy(source, relative); record[name] = {'path': relative, 'sha256': digest(source)}
        sources.append(record)
    save(output / 'sources.json', {'upstream': 'https://github.com/alex-calderwood/there-and-back',
        'upstream_commit': 'de333cbc07a2c735942516bf6ef87d55d4b723a2',
        'variant': 'gpt4_revised', 'sources': sources,
        'scope': '60 previously admitted development sources from the legacy test split; original story texts and prompt metadata are not redistributed.'})
    copy(campaign / 'selected_groups.json', 'groups.json')
    consensus = base.read(campaign / 'repeat_01/consensus_audit.json')['rows']
    save(output / 'consensus.json', {'rows': [{'group': r['group'], 'groups': r['consensus_groups']} for r in consensus]})
    compilation = base.read(campaign / 'repeat_01/compilation.json')
    hashes = []
    for model in compilation['models']:
        folder = campaign / 'repeat_01/models' / model['group'] / model['condition']
        hashes.append({'group': model['group'], 'condition': model['condition'],
            'domain_sha256': digest(folder / 'domain.pddl'),
            'source_action_count': model['source_action_count'], 'action_count': model['action_count']})
    save(output / 'model_hashes.json', {'models': hashes})
    native = []
    for sid, row in results['native'].items():
        replay = row.get('replay', {})
        item = {'source': sid, 'search_status': row['status'], 'validated': base.valid(replay),
            'steps': replay.get('steps'), 'validation_status': replay.get('status')}
        if item['validated']:
            source = campaign / 'repeat_01/execution/native' / sid / 'plan.pddl'
            copy(source, 'native_plans/' + sid + '.pddl')
        native.append(item)
    save(output / 'native_results.json', {'registered': 60, 'rows': native})
    slots = []
    for row in results['rows']:
        transport = row['transport']
        slots.append({'id': row['id'], 'group': row['group'], 'source': row['source'],
            'condition': row['condition'], 'size': row['size'], 'status': transport['status'],
            'validated': base.valid(transport), 'steps': transport.get('steps')})
    save(output / 'transport_results.json', {'registered': 2700, 'rows': slots})
    copy(first / 'analysis.json', 'first_repeat_analysis.json')
    copy(first / 'group_metrics.json', 'group_metrics.json')
    copy(expanded / 'selected_cases.json', 'composition_cases.json')
    copy(expanded / 'world_registry.json', 'world_registry.json')
    copy(audit / 'analysis.json', 'expanded_analysis.json')
    old_census = base.read(expanded / 'census.json')
    save(output / 'generator_census.json', {'groups': old_census['groups'],
        'candidates': [{k:v for k,v in r.items() if k != 'scenario'} for r in old_census['candidates']],
        'unsupported_profiles': old_census['unsupported_profiles']})
    rows = []
    for row in base.read(expanded / 'report.json')['rows']:
        item = {k: row[k] for k in ('id','case_id','group','size','world_id','condition','valid_plan','causal')}
        item['search_status'] = row['search']['status']
        item['replay'] = {k:v for k,v in row.get('replay',{}).items()
                          if k in ('status','steps','goal','unexplained_steps','orphan_steps')}
        if row['search']['status'] == 'solved':
            plan = expanded / 'execution' / row['id'] / 'search/plan.pddl'
            item['plan'] = plan.read_text(encoding='utf-8')
            item['plan_sha256'] = digest(plan)
        rows.append(item)
    save(output / 'composition_results.json', {'registered': 420, 'rows': rows})
    for source, name in [('original_domain.pddl','domain.pddl'),('problem.pddl','problem.pddl'),
                         ('plan.pddl','plan.pddl'),('mapping.json','mapping.json'),
                         ('explicit_scenario.json','world.json'),('readable_steps.json','steps.json'),
                         ('case_zh.txt','case_zh.txt')]:
        copy(case / source, 'long_case/' + name)
    copy(Path('data/validation/four_domain_long_case_2026_11_03_v2/explicit_scenario.json'),
         'long_case/world_before_intention_revision.json')
    save(output / 'long_case/result.json', {'status': final['status'], 'requirements_met': True,
        'replay': {k:v for k,v in final['replay'].items() if k not in ('input_sha256','seconds')},
        'causal': final['causal'], 'independent_pairs': final['independent_pairs'],
        'scope': final['scope'], 'domain_sha256': digest(case / 'original_domain.pddl'),
        'problem_sha256': digest(case / 'problem.pddl'), 'plan_sha256': digest(case / 'plan.pddl')})
    prior = base.read(Path('data/validation/four_domain_long_case_2026_11_03_v2/report.json'))
    physical = base.read(Path('data/validation/four_domain_long_case_physical_search_2026_11_03_v1/report.json'))
    optimal = base.read(Path('data/validation/four_domain_long_case_optimal_2026_11_03_v1/report.json'))
    save(output / 'long_case/attempts.json', {'direct_glaive': [
        {'condition': r['condition'], 'status': r['search']['status'], 'seconds_limit': r['seconds']}
        for r in prior['rows']], 'lama': {'search_status': physical['search']['engine_status'],
        'steps': physical['search']['length'], 'validation': physical['search']['validation']},
        'optimal_original_intentions': [{'steps': r['steps'],
            'goal': r['replay']['goal'], 'unexplained_steps': r['replay']['unexplained_steps'],
            'orphan_steps': r['replay']['orphan_steps']} for r in optimal['rows']],
        'revision': base.read(case / 'revision_receipt.json'),
        'scope': 'All unsuccessful conditions retained as outcomes; logs, runtime binaries and intermediate exports omitted.'})
    judgments = base.read(campaign / 'repeat_02/judgments/report.json')
    save(output / 'repeat_status.json', {'registered_repeats': 5, 'completed_repeats': 1,
        'repeat01_condition': 'interrupted_continuation',
        'repeat02': {'requests_attempted': judgments['requests_attempted'],
            'candidate_count': judgments['candidate_count'], 'status_counts': judgments['status_counts'],
            'stop_category': 'cloud_monthly_quota_exhausted'}, 'repeat03_to_05': 'unstarted'})
    manifest = {'status': 'exported_final_evidence', 'created_utc': base.now(),
        'files': {p.relative_to(output).as_posix(): digest(p) for p in sorted(output.rglob('*')) if p.is_file()},
        'raw_run_policy': 'Full immutable raw runs remain local; this compact release contains final evidence, necessary source PDDL, frozen mappings, plans, and failure summaries only.',
        'new_model_calls': 0, 'new_planner_calls': 0}
    save(output / 'manifest.json', manifest)
    return {'status': manifest['status'], 'files': len(manifest['files']) + 1,
        'bytes': sum(p.stat().st_size for p in output.rglob('*') if p.is_file())}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(export(args.output), indent=2))

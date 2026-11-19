"""Frozen 15-story development census, judgments and matched execution."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import shutil

from rcnc.conditional_merge import build
from rcnc.domain_building import check_exported_problem, digest, require_empty_output, save, snapshot_implementation
from rcnc.model_semantics import prepare as prepare_model, run as run_model
from rcnc.model_semantics_contract import include_output_contract
from rcnc.narrative_pipeline import map_problem
from rcnc.pddl import parse_domain, write_domain
from rcnc.story_merge_protocol import census, candidates_and_cases, cross_queries, schema_witness
from rcnc.validation import validate_artifacts
from scripts.experiments.run_conditional_merge import remove_source
from scripts.experiments.run_original_world_pipeline import convert_problem
from scripts.experiments.run_formal_merge import code_paths as previous_code
from scripts.experiments.run_transport_merge import MODEL_DIGEST

CONDITIONS = ('no_share', 'predicate090', 'full090')


def read(p): return json.loads(Path(p).read_text(encoding='utf-8'))


def code_paths():
    return sorted(set([*previous_code(), Path(__file__), Path('rcnc/story_merge_protocol.py'),
        Path('scripts/audit/audit_story_opportunities.py'), Path('scripts/audit/audit_semantic_facets_comparison.py')]))


def check(root):
    frozen = read(root / 'pre_model_freeze.json')
    for p, h in {**frozen['input_sha256'], **frozen['implementation_sha256']}.items():
        if digest(Path(p)) != h: raise ValueError('Frozen input or implementation changed: ' + p)


def prepare(root):
    require_empty_output(root); root.mkdir(parents=True); (root / 'inputs').mkdir()
    originals, domains = [], {}
    for raw in sorted(Path('data/narra-domains').glob('*_domainfile.pddl')):
        s = raw.name.removesuffix('_domainfile.pddl'); domains[s] = parse_domain(raw)
        folder = root / 'native' / s; folder.mkdir(parents=True)
        for kind in ('domain', 'problem'):
            name = f'{s}_{kind}file.pddl'
            shutil.copyfile(Path('data/narra-domains') / name, root / 'inputs' / name)
            shutil.copyfile(root / 'inputs' / name, folder / (kind + '.pddl'))
        row = {'id': s, 'source': s, 'directory': folder.as_posix(), 'native_admission': 'ready', 'mapped_admission': 'ready'}
        try: row['parse'] = check_exported_problem(folder / 'domain.pddl', folder / 'problem.pddl')
        except Exception as exc: row.update(native_admission='native_parse_error', parse_error=str(exc))
        try: row['query'] = convert_problem(s, folder / 'domain.pddl', folder / 'problem.pddl')
        except Exception as exc: row.update(mapped_admission='original_mapping_unsupported', mapping_error=str(exc))
        originals.append(row)
    if len(domains) != 15: raise ValueError('Requires the fixed 15-story pool')
    inventory = census(domains); pairs, cases = candidates_and_cases(domains, inventory)
    save(root / 'census.json', inventory)
    witnesses = []
    by_id = {p['id']: p for p in pairs}
    for case in cases:
        for key in case['action_candidates']:
            for ref in by_id[key]['references']:
                s, name = ref.split(':'); w = {'id': case['id'] + '__' + s, 'case': case['id'], 'source': s, 'action': name,
                    'unit': 'schema_constructed_one_step_witness', 'status': 'ready'}
                folder = root / 'witnesses' / w['id']; folder.mkdir(parents=True); w['directory'] = folder.as_posix()
                shutil.copyfile(root / 'inputs' / (s + '_domainfile.pddl'), folder / 'domain.pddl')
                try:
                    query, problem, plan = schema_witness(s, domains[s], name)
                    w['query'] = query
                    (folder / 'problem.pddl').write_text(problem, encoding='utf-8')
                    (folder / 'plan.txt').write_text(plan, encoding='utf-8')
                    w['validation'] = validate_artifacts(folder)
                    if w['validation']['status'] != 'VALID': w['status'] = 'invalid_native_witness'
                except Exception as exc: w.update(status='witness_construction_error', reason=str(exc))
                witnesses.append(w)
    queries = cross_queries(cases, pairs)
    total = len(originals) + len(cases) * 6 + len(originals) + sum(5 if q['unit'] == 'authored_cross_positive' else 3 for q in queries)
    protocol = {'status': 'frozen_before_model_and_search', 'created_utc': datetime.now(timezone.utc).isoformat(),
        'sources': sorted(domains), 'originals': originals, 'pairs': pairs, 'cases': cases, 'queries': queries, 'witnesses': witnesses,
        'conditions': list(CONDITIONS), 'task_slots': total, 'primary_threshold': .9,
        'model_budget': {'seconds': 900, 'request_seconds': 240, 'attempts': 1, 'workers': 1},
        'budget': {'seconds': 20, 'memory_mb': 4096, 'attempts': 1, 'workers': 1},
        'transport_budget': {'seconds_each': 30, 'full_truth_projection': False, 'directions': ['forward']},
        'selection': 'All typed same-named-effect pairs selected by the whole-source census, one independent compiled case per pair; no post-model replacement. Only required effect predicates plus two historical alias controls are queried. Parameter permutations are diagnostic, never supplied as semantic answers.',
        'acceptance': 'Unchanged compact GLM contract, fixed .9 confidence, complete participant bijections, predicate source injectivity, identical signed effects after mapping, all guarded original preconditions retained. Unknown/invalid/different keep source variants. No merge quota or response reuse.',
        'scope': 'Known 15-story development pool. Native worlds are separate and byte-preserved. One explicitly authored cross-source family, three sizes; one known risk control; schema-derived witnesses are unit tests, not original goals or independent semantics. Whole-pool baseline has no shared vocabulary. No held-out story, realistic purchase, narrative-quality, isolated-cost or all-state empirical equivalence claim.'}
    save(root / 'protocol.json', protocol)
    prepare_model(root / 'inputs', pairs, root / 'judgments', model='glm-5.3:cloud', model_digest=MODEL_DIGEST,
        total_seconds=900, request_seconds=240, schema_policy='compact_kind_specific', num_predict=16384, num_ctx=32768)
    include_output_contract(root / 'judgments')
    code = snapshot_implementation(root / 'pre_model', code_paths())
    files = [p for p in root.rglob('*') if p.is_file() and 'implementation' not in p.parts]
    save(root / 'pre_model_freeze.json', {'status': 'frozen_before_model_calls', 'input_sha256': {p.as_posix(): digest(p) for p in files}, 'implementation_sha256': code})
    return {'sources': len(domains), 'action_candidates': len(inventory['selected']), 'model_requests': len(pairs),
            'planner_slots': total, 'witnesses': dict(Counter(w['status'] for w in witnesses))}


def compile_tasks(root):
    check(root)
    if (root / 'manifest.json').exists(): raise ValueError('Already compiled')
    protocol = read(root / 'protocol.json'); model = read(root / 'judgments/report.json')
    if model['status'] != 'complete' or not model['inputs_unchanged'] or not model['implementation_unchanged']:
        raise ValueError('Stable completed model block required')
    groups = {g['id']: g for g in read(root / 'judgments/groups.json')['groups']}
    models, rows, witness_rows = [], [], []
    def task(row, domain=None, problem=None, mapping=None):
        if row['admission_status'] == 'ready':
            folder = root / 'bundle/tasks' / row['id']; folder.mkdir(parents=True)
            shutil.copyfile(domain, folder / 'domain.pddl'); shutil.copyfile(problem, folder / 'problem.pddl')
            if mapping is not None: save(folder / 'query_mapping.json', mapping)
            row.update(domain_sha256=digest(folder / 'domain.pddl'), problem_sha256=digest(folder / 'problem.pddl'))
        rows.append(row)
    for case in protocol['originals']:
        folder = Path(case['directory'])
        task({'id': case['id'] + '__native', 'family': 'native_original', 'problem_id': case['id'], 'source': case['source'],
              'representation': 'native', 'admission_status': case['native_admission']}, folder / 'domain.pddl', folder / 'problem.pddl')
    cases = [*protocol['cases'], {'id': 'all_pool', 'sources': protocol['sources'], 'predicate_candidates': [], 'action_candidates': []}]
    for case in cases:
        cid, sources = case['id'], case['sources']; inputs = root / 'case_inputs' / cid; inputs.mkdir(parents=True)
        for s in sources: shutil.copyfile(root / 'inputs' / (s + '_domainfile.pddl'), inputs / (s + '_domainfile.pddl'))
        for condition in (('no_share',) if cid == 'all_pool' else CONDITIONS):
            folder = root / 'models' / cid / condition
            spec = {'version': 1, 'decision_basis': 'machine_hypothesis', 'semantic_min_confidence': .9,
                'source_sha256': {p.name: digest(p) for p in inputs.glob('*.pddl')},
                'type_groups': [{'members': [s + ':' + t for s in sources], 'evidence': 'Same declared role name only; original source/type guards retained'} for t in ('entity', 'item', 'location')],
                'predicate_candidates': [] if condition == 'no_share' else [groups[k] for k in case['predicate_candidates']],
                'action_candidates': [] if condition == 'no_share' else [groups[k] for k in case['action_candidates']]}
            m = {'id': cid + '__' + condition, 'case': cid, 'condition': condition, 'status': 'compiled'}
            try:
                result = build(inputs, folder, spec, merge_actions=condition == 'full090')
                m.update({k: result[k] for k in ('counts', 'source_actions', 'source_predicates', 'merged_action_groups', 'merged_predicate_groups', 'decisions')})
            except Exception as exc: m.update(status='compilation_error', reason=f'{type(exc).__name__}: {exc}')
            models.append(m)
            for original in [o for o in protocol['originals'] if o['source'] in sources]:
                s = original['source']; row = {'id': cid + '__' + s + '__' + condition, 'case': cid, 'family': 'original_mapped',
                    'problem_id': s, 'source': s, 'representation': condition, 'admission_status': 'ready' if m['status'] == 'compiled' else 'compilation_error'}
                if row['admission_status'] == 'ready': row['admission_status'] = original['mapped_admission']
                if row['admission_status'] == 'ready':
                    try:
                        target = folder / (s + '_problem.pddl'); mapping = map_problem(original['query'], folder, target)
                        task(row, folder / 'meta_domain.pddl', target, mapping)
                    except Exception as exc: row.update(admission_status='mapping_error', reason=str(exc)); task(row)
                else: task(row)
            for witness in [w for w in protocol['witnesses'] if w['case'] == cid]:
                row = {'id': witness['id'] + '__' + condition, 'witness_id': witness['id'], 'case': cid, 'source': witness['source'],
                       'condition': condition, 'status': 'ready' if m['status'] == 'compiled' and witness['status'] == 'ready' else 'unavailable_witness_or_model'}
                if row['status'] == 'ready':
                    try:
                        target = folder / (witness['id'] + '.pddl'); mapping = map_problem(witness['query'], folder, target)
                        row.update(problem=target.as_posix(), mapping=mapping)
                    except Exception as exc: row.update(status='witness_mapping_error', reason=str(exc))
                witness_rows.append(row)
            for query in [q for q in protocol['queries'] if q['case'] == cid]:
                conditions = [condition] + (['remove_' + s for s in sources] if condition == 'full090' and query['unit'] == 'authored_cross_positive' else [])
                for representation in conditions:
                    row = {'id': cid + '__' + query['id'] + '__' + representation, 'case': cid, 'family': query['unit'], 'problem_id': query['id'],
                        'source': '+'.join(sources), 'representation': representation, 'admission_status': 'ready' if m['status'] == 'compiled' else 'compilation_error'}
                    if row['admission_status'] != 'ready': task(row); continue
                    export = root / 'cross_exports' / row['id']; export.mkdir(parents=True)
                    try:
                        mapping = map_problem(query['query'], folder, export / 'problem.pddl')
                        if representation.startswith('remove_'):
                            write_domain(remove_source(parse_domain(folder / 'meta_domain.pddl'), read(folder / 'meta_domain.json'), representation[7:]), export / 'domain.pddl')
                        else: shutil.copyfile(folder / 'meta_domain.pddl', export / 'domain.pddl')
                        task(row, export / 'domain.pddl', export / 'problem.pddl', mapping)
                    except Exception as exc: row.update(admission_status='mapping_error', reason=str(exc)); task(row)
    if len(rows) != protocol['task_slots'] or len({r['id'] for r in rows}) != len(rows): raise ValueError('Task denominator changed')
    save(root / 'compilation.json', {'status': 'complete', 'models': models, 'witness_rows': witness_rows})
    ready = [r for r in rows if r['admission_status'] == 'ready']
    save(root / 'bundle/manifest.json', {'status': 'frozen_before_search', 'mode': 'external_source_preservation', 'task_count': len(ready), 'tasks': ready})
    code = snapshot_implementation(root / 'before_planner', code_paths())
    files = [p for p in root.rglob('*') if p.is_file() and 'implementation' not in p.parts]
    save(root / 'manifest.json', {'status': 'frozen_before_search', 'task_count': len(rows), 'rows': rows, 'budget': protocol['budget'],
        'input_sha256': {p.as_posix(): digest(p) for p in files}, 'implementation_sha256': code})
    return {'task_slots': len(rows), 'planner_calls_planned': len(ready), 'admission_counts': dict(Counter(r['admission_status'] for r in rows)), 'model_counts': dict(Counter(m['status'] for m in models))}


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__); p.add_argument('mode', choices=['prepare', 'judge', 'compile', 'execute'])
    p.add_argument('--output', type=Path, required=True); args = p.parse_args()
    if args.mode == 'prepare': result = prepare(args.output)
    elif args.mode == 'judge': check(args.output); result = run_model(args.output / 'judgments')
    elif args.mode == 'compile': result = compile_tasks(args.output)
    else:
        from scripts.experiments.frozen_solver import execute
        check(args.output); result = execute(args.output)
    print(json.dumps({k: v for k, v in result.items() if k not in ('rows', 'by_family_condition')}, indent=2))

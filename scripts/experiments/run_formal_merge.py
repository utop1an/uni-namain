"""Frozen prospective source-pair evaluation with explicit unavailable slots."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import shutil

from rcnc.conditional_merge import boolean, build, effect_literals, fields
from rcnc.domain_building import check_exported_domain, check_exported_problem, digest, require_empty_output, save, snapshot_implementation
from rcnc.formal_merge_protocol import candidates, carrier_types, cross_queries
from rcnc.model_semantics import prepare as prepare_model, run as run_model
from rcnc.model_semantics_contract import include_output_contract
from rcnc.narrative_pipeline import map_problem
from rcnc.pddl import parse_domain, parse_sexpr, validate_domain, write_domain
from scripts.experiments.run_conditional_merge import remove_source
from scripts.experiments.run_original_world_pipeline import convert_problem
from scripts.experiments.run_role_contract_merge import code_paths as old_code
from scripts.experiments.run_transport_merge import MODEL_DIGEST

INTAKE = Path('data/external/formal_merge_intake_2026_10_30_v1')
PRIMARY = ('no_share', 'predicate090', 'full090')
ALL_CONDITIONS = (*PRIMARY, 'predicate080', 'full080')


def read(p): return json.loads(Path(p).read_text(encoding='utf-8'))


def code_paths():
    return sorted(set([*old_code(), Path(__file__), Path('rcnc/formal_merge_protocol.py'), Path('rcnc/model_semantics_compact.py')]))


def check(root):
    frozen = read(root / 'pre_model_freeze.json')
    for p, h in {**frozen['input_sha256'], **frozen['implementation_sha256']}.items():
        if digest(Path(p)) != h: raise ValueError('Frozen formal input/code changed: ' + p)


def prepare(root):
    require_empty_output(root)
    intake, downloaded = read(INTAKE / 'protocol.json'), read(INTAKE / 'report.json')
    if downloaded['verified_files'] != 24 or digest(INTAKE / 'protocol.json') != downloaded['protocol_sha256']:
        raise ValueError('Complete verified intake required')
    for r in downloaded['rows']:
        if digest(INTAKE / 'files' / r['id']) != r['sha256']: raise ValueError('Downloaded source changed')
    root.mkdir(parents=True); (root / 'inputs').mkdir()
    domains, source_rows, originals = {}, [], []
    for source in intake['sources']:
        s = source['id']; raw = INTAKE / 'files' / source['domain']
        path = root / 'inputs' / (s + '_domainfile.pddl'); shutil.copyfile(raw, path)
        row = {'id': s, 'raw_sha256': digest(raw), 'status': 'supported'}
        try:
            row['domain_parse'] = check_exported_domain(path)
            d = parse_domain(path)
            errors = validate_domain(d)
            if errors: raise ValueError('; '.join(errors))
            sexpr = parse_sexpr(path.read_text(encoding='utf-8'))
            if any(isinstance(x, list) and x and x[0] == ':functions' for x in sexpr):
                raise ValueError('Numeric functions outside current merge fragment')
            for action in d.actions.values():
                f = fields(action); boolean(f[':precondition']); effect_literals(f[':effect'])
            domains[s] = d
            row.update(actions=len(d.actions), predicates=len(d.predicates))
        except Exception as exc:
            row.update(status='unsupported_merge_fragment', reason=f'{type(exc).__name__}: {exc}')
        source_rows.append(row)
        for p in source['problems']:
            identifier = s + '__' + Path(p).stem
            folder = root / 'native' / identifier; folder.mkdir(parents=True)
            shutil.copyfile(raw, folder / 'domain.pddl'); shutil.copyfile(INTAKE / 'files' / p, folder / 'problem.pddl')
            case = {'id': identifier, 'source': s, 'directory': folder.as_posix(), 'raw_problem': p,
                    'native_admission': 'ready', 'mapped_admission': 'unsupported_source', 'query': None}
            try:
                case['parse'] = check_exported_problem(folder / 'domain.pddl', folder / 'problem.pddl')
            except Exception as exc:
                case.update(native_admission='original_parse_error', reason=f'{type(exc).__name__}: {exc}')
            if s in domains:
                try:
                    case['query'] = convert_problem(s, folder / 'domain.pddl', folder / 'problem.pddl')
                    case['mapped_admission'] = 'ready'
                except Exception as exc:
                    case.update(mapped_admission='original_conversion_error', reason=f'{type(exc).__name__}: {exc}')
            originals.append(case)
    pairs, ledger = candidates(domains, intake['source_pairs'])
    save(root / 'admission.json', {'status': 'complete', 'source_count': 6, 'rows': source_rows,
        'status_counts': dict(Counter(r['status'] for r in source_rows)), 'originals': originals,
        'source_bytes_unchanged': True, 'scope': 'Raw original files, no cost stripping, case normalization or semantic rewrite.'})
    save(root / 'candidate_ledger.json', {'status': 'frozen_before_model_calls', 'rows': ledger,
        'selected_count': len(pairs), 'rule': 'Equal arity; actions also equal signed effect-arity multiset. Rank name-token Jaccard then SHA256(kind|left|right). Max6predicate+2action pairs per source pair. All excluded candidates retained, no goal/result ranking.'})
    queries = cross_queries()
    protocol = {'status': 'frozen_before_model_and_planning', 'created_utc': datetime.now(timezone.utc).isoformat(),
        'intake': INTAKE.as_posix(), 'source_pairs': intake['source_pairs'], 'sources': source_rows,
        'originals': originals, 'pairs': pairs, 'queries': queries, 'conditions': list(PRIMARY),
        'sensitivity': '0.8 models compile only; no sensitivity planning in this block',
        'primary_threshold': .9, 'source_pair_count': 15, 'original_problem_count': 18,
        'task_slots': 18 + 15 * 6 * 3 + len(queries) * 5,
        'model_budget': {'requests_max': len(pairs), 'seconds_total': 1800, 'seconds_each': 240, 'attempts': 1, 'workers': 1},
        'budget': {'seconds': 20, 'memory_mb': 4096, 'workers': 1, 'attempts': 1},
        'replay_budget': {'seconds_each': 15, 'source_atom_max': 200000, 'directions': ['forward']},
        'type_policy': 'All declared source types share an object carrier for signature comparison only; separate source/type guards and ancestry remain. No inferred object memberships or semantic type equality.',
        'acceptance': 'Frozen compact_kind_specific contract and .9 gate; complete role bijections, source-injective predicate maps, identical signed effects, every guarded original precondition retained. Unknown/invalid/rejected keep variants; no guaranteed merge quota.',
        'cross_scope': 'Three sizes of ONE authored gripper/rover carry-and-sample family, plus ONE robot/lift semantic-risk control. Other pairs retain original-world tests and zero preregistered cross-world opportunity. These are not independently authored tasks or semantic labels.',
        'scope': 'Prospective public sources not used to tune the frozen model prompt. Mechanical source preservation and authored cross-source evaluation; not model-pretraining novelty, independent semantic accuracy, or learned-narrative generalization.'}
    save(root / 'protocol.json', protocol)
    prepare_model(root / 'inputs', pairs, root / 'judgments', model='glm-5.3:cloud', model_digest=MODEL_DIGEST,
        total_seconds=1800, request_seconds=240, schema_policy='compact_kind_specific', num_predict=16384, num_ctx=32768)
    include_output_contract(root / 'judgments')
    code = snapshot_implementation(root / 'pre_model', code_paths())
    files = [p for p in root.rglob('*') if p.is_file() and 'implementation' not in p.parts]
    save(root / 'pre_model_freeze.json', {'status': 'frozen_before_model_calls',
        'input_sha256': {p.as_posix(): digest(p) for p in files}, 'implementation_sha256': code})
    return {'status': 'prepared', 'source_admission': Counter(r['status'] for r in source_rows),
        'model_requests': len(pairs), 'task_slots': protocol['task_slots'], 'original_problem_count': 18}


def compile_tasks(root):
    check(root)
    if (root / 'manifest.json').exists(): raise ValueError('Already compiled')
    protocol = read(root / 'protocol.json'); models, rows = [], []
    predictions = read(root / 'judgments/report.json')
    if predictions['status'] != 'complete' or not predictions['inputs_unchanged'] or not predictions['implementation_unchanged']:
        raise ValueError('Stable completed predictions required')
    groups = {g['id']: g for g in read(root / 'judgments/groups.json')['groups']}
    admitted = {r['id'] for r in protocol['sources'] if r['status'] == 'supported'}
    def task(row, domain=None, problem=None, mapping=None):
        if row['admission_status'] == 'ready':
            folder = root / 'bundle/tasks' / row['id']; folder.mkdir(parents=True)
            shutil.copyfile(domain, folder / 'domain.pddl'); shutil.copyfile(problem, folder / 'problem.pddl')
            if mapping is not None: save(folder / 'query_mapping.json', mapping)
            row.update(domain_sha256=digest(folder / 'domain.pddl'), problem_sha256=digest(folder / 'problem.pddl'))
        rows.append(row)
    for case in protocol['originals']:
        folder = Path(case['directory'])
        task({'id': case['id'] + '__native', 'family': 'native_original', 'source': case['source'], 'problem_id': case['id'],
            'representation': 'native', 'admission_status': case['native_admission']}, folder / 'domain.pddl', folder / 'problem.pddl')
    for sources in protocol['source_pairs']:
        bundle = '__'.join(sources); supported = set(sources) <= admitted
        inputs = root / 'bundle_inputs' / bundle; inputs.mkdir(parents=True)
        for s in sources: shutil.copyfile(root / 'inputs' / (s + '_domainfile.pddl'), inputs / (s + '_domainfile.pddl'))
        compiled = {}
        if supported:
            ds = {s: parse_domain(inputs / (s + '_domainfile.pddl')) for s in sources}
            for condition in ALL_CONDITIONS:
                spec = {'version': 1, 'decision_basis': 'machine_hypothesis', 'semantic_min_confidence': .8 if condition.endswith('080') else .9,
                    'source_sha256': {p.name: digest(p) for p in inputs.glob('*.pddl')}, 'type_groups': carrier_types(ds)}
                for kind in ('predicate', 'action'):
                    spec[kind + '_candidates'] = [groups[p['id']] for p in protocol['pairs'] if p['kind'] == kind and p['bundle'] == bundle] if condition != 'no_share' else []
                folder = root / 'models' / bundle / condition
                row = {'bundle': bundle, 'condition': condition}
                try:
                    result = build(inputs, folder, spec, merge_actions=condition.startswith('full'))
                    row.update(status='compiled', counts=result['counts'], source_actions=result['source_actions'],
                        predicates=result['merged_predicate_groups'], actions=result['merged_action_groups'], decisions=result['decisions'])
                    compiled[condition] = folder
                except Exception as exc:
                    row.update(status='compilation_error', reason=f'{type(exc).__name__}: {exc}')
                models.append(row)
        else:
            models.extend({'bundle': bundle, 'condition': c, 'status': 'unavailable_source'} for c in ALL_CONDITIONS)
        for case in [c for c in protocol['originals'] if c['source'] in sources]:
            for condition in PRIMARY:
                row = {'id': bundle + '__' + case['id'] + '__' + condition, 'bundle': bundle, 'family': 'original_mapped',
                    'source': case['source'], 'problem_id': case['id'], 'representation': condition,
                    'admission_status': 'ready' if condition in compiled else 'unavailable_source' if not supported else 'compilation_error'}
                if row['admission_status'] == 'ready':
                    row['admission_status'] = case['mapped_admission']
                if row['admission_status'] == 'ready':
                    model = compiled[condition]; problem = model / (case['id'] + '.pddl')
                    try:
                        mapping = map_problem(case['query'], model, problem)
                        task(row, model / 'meta_domain.pddl', problem, mapping)
                    except Exception as exc:
                        row.update(admission_status='mapping_error', reason=f'{type(exc).__name__}: {exc}'); task(row)
                else: task(row)
        crosses = [q for q in protocol['queries'] if q['bundle'] == bundle]
        for q in crosses:
            for condition in [*PRIMARY, *['remove_' + s for s in sources]]:
                base = 'full090' if condition.startswith('remove_') else condition
                row = {'id': bundle + '__' + q['id'] + '__' + condition, 'bundle': bundle, 'family': q['unit'],
                    'source': '+'.join(sources), 'problem_id': q['id'], 'representation': condition,
                    'admission_status': 'ready' if base in compiled else 'unavailable_compilation'}
                if row['admission_status'] != 'ready': task(row); continue
                model = compiled[base]; folder = root / 'cross_exports' / row['id']; folder.mkdir(parents=True)
                try:
                    mapping = map_problem(q['query'], model, folder / 'problem.pddl')
                    if condition.startswith('remove_'):
                        domain = remove_source(parse_domain(model / 'meta_domain.pddl'), read(model / 'meta_domain.json'), condition.removeprefix('remove_'))
                        write_domain(domain, folder / 'domain.pddl')
                    else: shutil.copyfile(model / 'meta_domain.pddl', folder / 'domain.pddl')
                    task(row, folder / 'domain.pddl', folder / 'problem.pddl', mapping)
                except Exception as exc:
                    row.update(admission_status='mapping_error', reason=f'{type(exc).__name__}: {exc}'); task(row)
    if len(rows) != protocol['task_slots'] or len({r['id'] for r in rows}) != len(rows): raise ValueError('Matrix denominator changed')
    save(root / 'compilation.json', {'status': 'complete', 'models': models, 'scope': 'Primary .9 plans; .8 compilation-only sensitivity'})
    ready = [r for r in rows if r['admission_status'] == 'ready']
    save(root / 'bundle/manifest.json', {'status': 'frozen_before_search', 'mode': 'external_source_preservation', 'task_count': len(ready), 'tasks': ready})
    code = snapshot_implementation(root / 'before_planner', code_paths())
    files = [p for p in root.rglob('*') if p.is_file() and 'implementation' not in p.parts]
    save(root / 'manifest.json', {'status': 'frozen_before_search', 'task_count': len(rows), 'rows': rows, 'budget': protocol['budget'],
        'input_sha256': {p.as_posix(): digest(p) for p in files}, 'implementation_sha256': code})
    return {'status': 'compiled', 'task_slots': len(rows), 'planner_calls_planned': len(ready), 'admission_counts': Counter(r['admission_status'] for r in rows)}


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

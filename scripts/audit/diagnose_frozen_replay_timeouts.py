"""Snapshot and analyze existing replay evidence, without new runtime calls."""
import argparse
from collections import Counter, defaultdict
from datetime import datetime, timezone
from functools import lru_cache
import hashlib
import json
from pathlib import Path
import statistics
import sys

REPO = Path('C:/anu/uninamain')
RELEASE = REPO / 'data/research_release/narrative_baseline_priority1_2026_11_05_v1'
sys.dont_write_bytecode = True
sys.path.insert(0, str(RELEASE / 'code'))
from rcnc.pddl import parse_sexpr, section, typed_symbols
from rcnc.glaive_intake import casefold_tree


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x', encoding='utf-8') as stream:
        json.dump(value, stream, ensure_ascii=False, indent=2)
        stream.write('\n')


@lru_cache(maxsize=None)
def tree(path):
    return casefold_tree(parse_sexpr(Path(path).read_text(encoding='utf-8')))


@lru_cache(maxsize=None)
def dimensions(domain, problem):
    d, p = tree(domain), tree(problem)
    actions = [a for a in d if isinstance(a, list) and a and a[0] == ':action']
    parameters = [typed_symbols(a[a.index(':parameters')+1] if ':parameters' in a else []) for a in actions]
    arities = [len(params) for params in parameters]
    types = [t for params in parameters for t in params.values()]
    objects = typed_symbols((section(p, ':objects') or [':objects'])[1:])
    constants = typed_symbols((section(d, ':constants') or [':constants'])[1:])
    def walk(e):
        if isinstance(e, list):
            yield e
            for x in e:
                yield from walk(x)
    total = len(objects.keys() | constants.keys())
    return {'actions': len(actions), 'axioms': sum(isinstance(a,list) and a and a[0]==':axiom' for a in d),
            'constants': len(constants), 'problem_objects': len(objects), 'total_objects_and_constants': total,
            'max_action_arity': max(arities, default=0), 'all_action_parameters_object_typed': set(types) <= {'object'},
            'forall_nodes': sum(bool(a) and a[0]=='forall' for a in walk(d)),
            'untyped_binding_upper_bound': sum(total**a for a in arities),
            'binding_bound_is_actual_ground_count': False}


def summary(rows):
    times = [r['seconds'] for r in rows]
    return {'n': len(rows), 'replay_statuses': dict(Counter(r['status'] for r in rows)),
            'median_seconds': statistics.median(times) if times else None,
            'median_plan_steps': statistics.median(r['plan_steps'] for r in rows) if rows else None,
            'median_objects': statistics.median(r['dimensions']['total_objects_and_constants'] for r in rows) if rows else None,
            'median_actions': statistics.median(r['dimensions']['actions'] for r in rows) if rows else None,
            'median_max_arity': statistics.median(r['dimensions']['max_action_arity'] for r in rows) if rows else None,
            'physical_goal_passes': sum(r['physical_goal_pass'] for r in rows),
            'physical_violations': sum(r['physical_violation'] for r in rows)}


def analyze(root, output, snapshot_path=None):
    if output.exists():
        raise ValueError('Fresh diagnostic output required')
    output.mkdir(parents=True)
    event = snapshot_path or root / 'repeat_01/transport_events.jsonl'
    data = event.read_bytes()
    lines = data.splitlines() if data.endswith(b'\n') else data.splitlines()[:-1]
    snapshot = b'\n'.join(lines)+b'\n'
    (output / 'events_snapshot.jsonl').write_bytes(snapshot)
    events = [json.loads(line) for line in lines]
    native = {r['id']: r for r in read(root / 'repeat_01/native_report.json')['rows']}
    evidence = {str(root / 'repeat_01/native_report.json'): sha(root / 'repeat_01/native_report.json'),
                str(RELEASE / 'code/scripts/java/GlaiveProbe.java'): sha(RELEASE / 'code/scripts/java/GlaiveProbe.java'),
                str(RELEASE / 'code/rcnc/glaive_runtime.py'): sha(RELEASE / 'code/rcnc/glaive_runtime.py')}
    rows = []
    for r in events:
        if 'replay' not in r:
            continue
        replay = r['replay']; physical = replay.get('physical', {})
        plan = Path(r['plan']); folder = plan.parent / 'replay'
        log = folder / 'stdout.txt'; text = log.read_text(encoding='utf-8') if log.exists() else None
        for path in (plan, log, folder/'result.json', folder/'checked_result.json', Path(r['domain']), Path(r['problem'])):
            if path.exists(): evidence[str(path)] = sha(path)
        reference = r['reference']; nr = native[r['world']+'__'+reference['condition']]
        row = {k: r[k] for k in ('id','group','cohort','method','size','condition','world','source','domain','problem','plan')}
        row.update(status=replay.get('status'), seconds=replay.get('seconds'), returncode=replay.get('returncode'),
            physical_status=physical.get('status'), physical_reason=physical.get('reason'),
            physical_goal_pass=physical.get('status')=='replayed' and physical.get('goal') is True,
            physical_violation=physical.get('status')=='inapplicable' or (physical.get('status')=='replayed' and physical.get('goal') is False),
            physical_initial_goal=physical.get('initial_goal'), plan_steps=len(section(tree(str(plan)), ':steps'))-1,
            log=str(log), log_empty=text=='', log_missing=text is None,
            dimensions=dimensions(r['domain'], r['problem']),
            reference_condition=reference['condition'], reference_validation_level=reference['validation_level'],
            reference_replay_seconds=nr.get('replay', {}).get('seconds'),
            reference_replay_status=nr.get('replay', {}).get('status'),
            reference_dimensions=dimensions(nr['domain'], nr['problem']),
            execution_condition=r.get('execution_provenance', {}).get('condition'))
        rows.append(row)
    paired = defaultdict(dict)
    for row in rows: paired[row['group'], row['world']][row['condition']] = row
    pairs = [rr for rr in paired.values() if set(rr)=={'union','full'}]
    matrix = Counter((rr['union']['status'],rr['full']['status']) for rr in pairs)
    timeouts = [r for r in rows if r['status']=='wall_time_limit']
    successes = [r for r in rows if r['status']=='replayed']
    breakdowns = {}
    for field in ('condition','cohort','size','execution_condition'):
        breakdowns[field] = {str(value):summary([r for r in rows if r[field]==value]) for value in sorted({r[field] for r in rows})}
    reference_times = [r['reference_replay_seconds'] for r in timeouts if r['reference_replay_seconds'] is not None]
    examples = []
    for predicate in (lambda r:r['status']=='wall_time_limit' and r['physical_goal_pass'] and r['plan_steps']<=4,
                      lambda r:r['status']=='wall_time_limit' and r['plan_steps']==0,
                      lambda r:r['status']=='replayed' and r['physical_goal_pass']):
        examples.extend(sorted((r for r in rows if predicate(r)),key=lambda r:(r['plan_steps'],r['id']))[:2])
    result = {'status':'existing_log_diagnostic_only','created_utc':datetime.now(timezone.utc).isoformat(),
        'root':str(root),'snapshot_source':str(event),'snapshot_registered_rows':len(events),'actual_replay_rows':len(rows),
        'timeout_summary':summary(timeouts),'completed_native_replay_summary':summary(successes),
        'empty_timeout_logs':sum(r['log_empty'] for r in timeouts),
        'timeout_returncodes':dict(Counter(str(r['returncode']) for r in timeouts)),
        'timeout_physical_statuses':dict(Counter(r['physical_status'] for r in timeouts)),
        'all_physical_nonpass_reasons':dict(Counter(r['physical_reason'] for r in rows if r['physical_reason'])),
        'timeout_reference_replay_median_seconds':statistics.median(reference_times) if reference_times else None,
        'timeout_short_plans_at_most_4_steps':sum(r['plan_steps']<=4 for r in timeouts),
        'timeout_zero_step_plans':sum(r['plan_steps']==0 for r in timeouts),
        'matched_union_full_pairs':len(pairs),'paired_status_matrix':[{'union':u,'full':f,'pairs':n} for (u,f),n in sorted(matrix.items())],
        'breakdowns':breakdowns,'examples':examples,'rows':rows,
        'new_api_requests':0,'new_search_calls':0,'new_replay_calls':0,
        'limits':['Ongoing campaign snapshot; not final coverage or uniformly sampled workload.',
                  'Current probe has no intermediate progress logging; empty timeout logs do not locate the exact blocked phase.',
                  'Physical replay passing is transition/goal evidence, not intentionality or independent semantic validation.',
                  'The untyped binding count is a loose syntactic upper bound, not measured grounding work.',
                  'No higher-budget or alternative-runtime controls were executed.']}
    write(output/'report.json',result)
    evidence[str(event)+'#snapshot_prefix_sha256'] = hashlib.sha256(snapshot).hexdigest()
    write(output/'evidence_sha256.json', evidence)
    return {k:v for k,v in result.items() if k not in ('rows','examples','limits')}


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--root',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--snapshot',type=Path)
    args=parser.parse_args();print(json.dumps(analyze(args.root.resolve(),args.output.resolve(),args.snapshot.resolve() if args.snapshot else None),ensure_ascii=False,indent=2))

"""Re-audit a verified November 9 composition registry without search."""
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import sys

from rcnc.causal_attribution import recover_branch_provenance
from rcnc.causal_attribution_axioms import causal_trace_with_axioms
from scripts.audit.recheck_glaive_axiom_transports import IMPLEMENTATION, _offline, _sha, _write

def audit(repo, output):
    root = repo / 'data/validation'
    previous = root / 'glaive_independent_axiom_composition_recheck_2026_11_09_v2'
    run = root / 'priority1_union_full_initialization_capped8_continuation_2026_11_09_v1'
    hashes = {}

    def pin(path, expected=None):
        path = Path(path).resolve()
        if path not in hashes:
            hashes[path] = _sha(path)
        if expected is not None and hashes[path] != expected:
            raise ValueError(f'Frozen input differs: {path}')
        return path

    def read(path, expected=None):
        return json.loads(pin(path, expected).read_text(encoding='utf-8'))

    inventory = read(previous / 'verified_inventory/results.json')
    if inventory['status'] != 'verified_snapshot' or inventory['excluded_pending']:
        raise ValueError('Composition revalidation evidence is incomplete')
    report_entry = inventory['results']['composition_recheck']
    assert Path(report_entry['path']).resolve() == previous/'report.json'
    old = read(previous/'report.json', report_entry['sha256'])
    protocol = read(previous/'protocol.json', old['protocol_sha256'])
    physical_hashes = protocol['input_sha256']
    assert old['controls_identical'] and old['inputs_unchanged']
    assert not any(old[k] for k in ('model_requests','search_calls','new_native_replay_calls'))
    registered = old['composition_rows']
    history = {r['id']:r for r in registered}
    assert len(history) == len(registered) == 2400
    assert Counter(r['condition'] for r in registered) == {'union':1200,'full':1200}
    assert Counter((r['condition'],r['attribution_status']) for r in registered if r['dual']) == {
        ('union','classified'):22, ('union','unknown'):25,
        ('full','classified'):204, ('full','unknown'):374}
    historic_count = inventory['results']['prior_attribution']
    source_count = read(historic_count['path'],historic_count['sha256'])
    original_inputs = read(run/'source_counts_v1/protocol.json',source_count['protocol_sha256'])['input_sha256']
    stage = inventory['results']['prior_composition']
    composition = read(stage['path'],stage['sha256'])
    archive = {r['id']:r for r in composition['rows']}
    assert archive.keys() == history.keys()
    physical = {r['id']:r for r in old['rows'] if r['dual_pass_with_retained_native']}
    assert physical.keys() == {r['id'] for r in registered if r['dual']}
    tasks = []
    for key, saved in physical.items():
        row = archive[key]
        files = {k:pin(saved[k],physical_hashes[str(Path(saved[k]).resolve())])
                 for k in ('domain','problem','mapping','plan')}
        assert all(files[k] == Path(row[k]).resolve() for k in files)
        mapping = read(files['mapping'])
        variant = None
        if any(n > 1 for n in Counter(v['name'] for v in mapping['action_maps'].values()).values()):
            directory = files['domain'].parent.parent / 'predicate_mapping_stage'
            variant = {k:pin(directory/name, original_inputs.get(str((directory/name).resolve())))
                       for k,name in [('domain','domain.pddl'),('mapping','mapping.json')]}
        tasks.append({'id':key, 'condition':row['condition'], 'previous_status':history[key]['attribution_status'],
                      'files':{k:str(v) for k,v in files.items()}, 'sources':row['sources'],
                      'variant':{k:str(v) for k,v in variant.items()} if variant else None})
    output.mkdir(parents=True,exist_ok=False)
    modules = (*IMPLEMENTATION[:5], 'rcnc/causal_attribution.py','rcnc/causal_attribution_axioms.py',
               'rcnc/composition_probes.py','rcnc/glaive_merge.py', 'scripts/audit/recheck_glaive_axiom_transports.py',
               str(Path(__file__).resolve().relative_to(repo)))
    for relative in modules:
        path = pin(repo/relative)
        frozen = output/'implementation'/relative
        frozen.parent.mkdir(parents=True,exist_ok=True)
        frozen.write_bytes(path.read_bytes())
        pin(frozen,hashes[path])
    registration = output/'protocol.json'
    _write(registration,{'status':'frozen_before_saved_source_attribution_audit',
                         'created_utc':datetime.now(timezone.utc).isoformat(),
                         'input_sha256':{str(k):v for k,v in hashes.items()},'tasks':tasks,
                         'max_interpretations':4096,'max_supports':256,'search_calls':0,
                         'new_native_replay_calls':0,'model_requests':0,
                         'metric':'Maximum number of distinct action sources on one goal-relevant positive-support path. Fired effect guards support only their own writes. Native axiom state updates provide intermediate support; they do not add action sources. A path crossing action sources must carry a shared fact between the actions.'})
    pin(registration)
    results = []
    updated = {r['id']:dict(r) for r in registered}
    control_errors = []
    for task in tasks:
        key = task['id']
        paths = {k:Path(v) for k,v in task['files'].items()}
        mapping = read(paths['mapping'])
        try:
            provenance = None
            if task['variant']:
                variant = task['variant']
                provenance = recover_branch_provenance(paths['domain'], mapping, variant['domain'], read(variant['mapping']))
            trace = causal_trace_with_axioms(paths['domain'],paths['problem'],paths['plan'],mapping,
                                            provenance=provenance,selected_sources=task['sources'])
        except (KeyError,ValueError,TypeError) as exc:
            trace = {'status':'unknown','reason':str(exc)}
        replay = trace.pop('physical',{})
        expected = physical[key]['new_physical']
        checks = ('status','goal','steps','initial_goal','applied')
        matched = all(json.loads(json.dumps(replay.get(k))) == expected.get(k) for k in checks)
        if 'axiom_closure_rounds' in expected:
            matched &= replay.get('axiom_closure_rounds') == expected['axiom_closure_rounds']
        if trace['status']=='classified' and not matched:
            trace = {'status':'unknown','reason':'physical_trace_differs_from_verified_replay'}
        profile = trace.get('source_count_profile',{})
        verdicts = {k:v['status'] for k,v in profile.get('at_least',{}).items()}
        row = updated[key]
        if task['previous_status']=='classified':
            if (trace['status']!='classified' or profile.get('exact_count')!=row['exact_count']
                    or {k:v=='confirmed' for k,v in verdicts.items()}!=row['confirmed_at_least']):
                control_errors.append(key)
        row.update(attribution_status=trace['status'], attribution_reason=trace.get('reason'),
                   threshold_verdicts=verdicts, exact_count=profile.get('exact_count'),
                   confirmed_at_least={k:v=='confirmed' for k,v in verdicts.items()})
        results.append({'id':key,'condition':task['condition'],'previous_status':task['previous_status'],
                        'physical_trace_identical':matched,'audit':trace})
    if any(_sha(k)!=v for k,v in hashes.items()):
        raise ValueError('Frozen input changed during audit')
    composition_rows=list(updated.values())
    summaries={}
    for arm in ('union','full'):
        active=[r for r in composition_rows if r['condition']==arm and r['dual']]
        targeted=[r for r in results if r['condition']==arm and r['previous_status']=='unknown']
        summaries[arm]={'dual_validated':len(active),'targeted':len(targeted),
            'newly_classified':sum(r['audit']['status']=='classified' for r in targeted),
            'classified':sum(r['attribution_status']=='classified' for r in active),
            'unknown':sum(r['attribution_status']=='unknown' for r in active),
            'unknown_reasons':dict(Counter(r['attribution_reason'] for r in active if r['attribution_status']=='unknown')),
            'exact_counts':dict(Counter(str(r['exact_count']) for r in active if r['exact_count'] is not None)),
            'thresholds':{str(k):dict(Counter(
                r['threshold_verdicts'].get(str(k),'unknown') for r in active if r['size']>=k)) for k in range(2,6)}}
    result={'status':'complete_extended_composition_attribution_audit' if not control_errors else 'control_regression',
            'registered':len(results),'rows':results,'composition_rows':composition_rows,'summary':summaries,
            'inputs_unchanged':True,'controls_identical':not control_errors,'control_errors':control_errors,
            'protocol_sha256':hashes[pin(registration)],'search_calls':0,'new_native_replay_calls':0,'model_requests':0}
    _write(output/'report.json',result)
    print(json.dumps({'summary':summaries,'control_errors':control_errors[:30]},indent=2))
    if control_errors:
        raise ValueError('Extended attribution disagrees with archived controls')
    _write(output/'evidence_index.json',{'reports':{
        'extended_composition_source_attribution':{'path':(output/'report.json').relative_to(repo).as_posix(),
            'sha256':_sha(output/'report.json'),'terminal_status':result['status'],
            'scope':'Saved-plan source attribution including native axioms and action-effect guards',
            'metrics':['registered','summary','protocol_sha256','search_calls','new_native_replay_calls','model_requests'],
            'required_true':['controls_identical','inputs_unchanged'],'denominator':'registered'},
        'composition_physical_recheck':{'path':str(previous/'report.json'),'sha256':report_entry['sha256'],
            'terminal_status':old['status'],'scope':'Dual-validation inputs retained for the 2400-row registry',
            'metrics':['registered','summary'],'required_true':['controls_identical','inputs_unchanged'],'denominator':'registered'}},
        'excluded_pending':{}})

if __name__=='__main__':
    sys.addaudithook(_offline)
    audit(Path.cwd(),Path(sys.argv[1]).resolve())


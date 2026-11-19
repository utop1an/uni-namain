"""Paired native/compiled/union trace checks for frozen reference executions.

Non-executed counterfactual branches are retained in the original files and
explicitly excluded from an executed-step projection. This checks state and
intention literals along that projection, not the full conflict explanation.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import shutil
import subprocess
import time

from rcnc.domain_building import digest, save
from rcnc.glaive_intake import casefold_tree
from rcnc.glaive_merge import Source, build, map_problem, translate_plan, rewrite, canonical
from rcnc.glaive_runtime import linux_path
from rcnc.pddl import parse_sexpr, section, serialize
from scripts.audit.recheck_human_single_domain import COLLECTION, REPO, read, verify

REFERENCES = {'case_013': 'ark-solution.pddl', 'case_014': 'blp-die-solution.pddl',
              'case_015': 'blp-win-solution.pddl', 'case_016': 'fantasy-solution.pddl',
              'case_018': 'space-solution.pddl', 'case_019': 'western-solution.pddl'}


def executed_projection(plan_path, problem_path, target):
    tree = casefold_tree(parse_sexpr(plan_path.read_text(encoding='utf-8')))
    problem = casefold_tree(parse_sexpr(problem_path.read_text(encoding='utf-8')))
    original = section(tree, ':steps')[1:]
    steps, removed = [], []
    for i, step in enumerate(original):
        if step[0] == 'non-executed':
            removed.append({'original_index': i, 'call': step})
        else:
            steps.append(step)
    name = section(problem, 'problem')[1]
    out = ['define', ['plan', 'executed_projection'], [':problem', name], [':steps', *steps]]
    target.write_text(serialize(out) + '\n', encoding='utf-8')
    return {'original_step_entries': len(original), 'executed_steps': len(steps), 'excluded_nonexecuted': removed,
            'original_problem_reference': section(tree, ':problem'), 'projected_problem_reference': name,
            'scope': 'Executed physical path; counterfactual steps and original file retained separately'}


def make_source(row):
    return Source(row['source_id'], COLLECTION / row['domain'], COLLECTION / row['problem'],
                  constant_contract=row['constant_contract'])


def prepare(output, admission, classes):
    if output.exists(): raise ValueError('Fresh trace directory required')
    report = read(admission / 'report.json')
    p = read(admission / 'protocol.json')
    verify(p['sha256'])
    rows = [r for r in report['rows'] if r['id'] in REFERENCES]
    if len(rows) != 6: raise ValueError('Six reference tasks required')
    output.mkdir(parents=True)
    (output / 'runtime').mkdir()
    shutil.copyfile(classes / 'GlaiveTraceProbe.class', output / 'runtime/GlaiveTraceProbe.class')
    shutil.copyfile(REPO / 'scripts/java/GlaiveTraceProbe.java', output / 'runtime/GlaiveTraceProbe.java')
    selected = {}
    for r in rows:
        if r['single_domain_pass'] and r['domain'] not in selected:
            selected[r['domain']] = make_source(r)
    union_sources = list(selected.values())
    union_meta = build(union_sources, output / 'union')
    tasks, files = [], []
    for row in rows:
        target = output / row['id']; target.mkdir()
        reference = (COLLECTION / row['domain']).parent / REFERENCES[row['id']]
        projection = target / 'executed_native.pddl'
        adapter = executed_projection(reference, COLLECTION / row['problem'], projection)
        task = {'id': row['id'], 'source_row': row, 'reference': str(reference), 'projection': adapter,
                'variants': {'native': {'domain': str(COLLECTION / row['domain']), 'problem': str(COLLECTION / row['problem']),
                                        'plan': str(projection)}}}
        files.extend([reference, COLLECTION / row['domain'], COLLECTION / row['problem']])
        if row['single_domain_pass']:
            source = make_source(row)
            for label in ('single', 'union'):
                bundle = target / label
                if label == 'single':
                    meta = build([source], bundle)
                    sources = [source]
                    domain = bundle / 'domain.pddl'
                else:
                    bundle.mkdir()
                    meta = union_meta
                    sources = [source if s.id == source.id else s for s in union_sources]
                    domain = output / 'union/domain.pddl'
                terms = map_problem(sources, source.id, meta, bundle / 'problem.pddl')
                translate_plan(source.id, meta, terms, projection, bundle / 'plan.pddl')
                auxiliaries = {s.id + '_active' for s in sources}
                auxiliaries |= {s.id + '_type_' + t for s in sources for t in s.types}
                task['variants'][label] = {'domain': str(domain), 'problem': str(bundle / 'problem.pddl'),
                                           'plan': str(bundle / 'plan.pddl'), 'predicate_map': meta['predicate_maps'][source.id],
                                           'terms': terms, 'auxiliaries': sorted(auxiliaries)}
        else:
            task['unavailable_reason'] = row.get('reason', 'single_domain_parse_failed')
        tasks.append(task)
    implementation = [REPO / 'rcnc' / n for n in ('glaive_merge.py', 'glaive_intake.py', 'pddl.py', 'glaive_runtime.py')]
    implementation += [Path(__file__), REPO / 'scripts/java/GlaiveTraceProbe.java']
    for path in implementation:
        target = output / 'implementation' / path.relative_to(REPO)
        target.parent.mkdir(parents=True, exist_ok=True); shutil.copyfile(path, target)
    files += implementation + [Path(p['jar']), admission / 'report.json', admission / 'protocol.json']
    files += [f for f in output.rglob('*') if f.is_file()]
    protocol = {'status': 'frozen_before_execution', 'created_utc': datetime.now(timezone.utc).isoformat(),
                'admission': str(admission), 'tasks': tasks, 'registered_tasks': 6, 'registered_slots': 18,
                'conditions': ['native', 'single', 'union'], 'seconds_per_trace': 30, 'attempts': 1,
                'jar': p['jar'], 'classes': str(output / 'runtime'),
                'union_unique_domain_files': len(union_sources), 'union_axioms': union_meta['axiom_count'],
                'policies': ['Six preselected original tasks; unavailable exports retained in all denominators.',
                             'Same runtime, world and executed reference steps across compared conditions.',
                             'Union uses distinct namespaces, no semantic predicate/action alignment and no pooled initial facts.',
                             'Compare every emitted true-literal state after native axiom closure, including intentions; remove only declared compiler auxiliaries.',
                             'Goal truth and explanation counters reported separately; full counterfactual intentional validity not assessed.'],
                'sha256': {str(f.resolve()): digest(f) for f in files}, 'model_calls': 0, 'search_calls': 0}
    save(output / 'protocol.json', protocol)
    (output / 'PROTOCOL.sha256').write_text(digest(output / 'protocol.json') + '\n', encoding='utf-8')
    return {'tasks': 6, 'registered_slots': 18, 'runnable_slots': sum(len(t['variants']) for t in tasks),
            'union_domains': len(union_sources)}


def invoke_trace(variant, protocol, output):
    if output.exists(): raise ValueError('Trace output already exists')
    output.mkdir(parents=True)
    files = [Path(protocol['jar']), Path(protocol['classes']) / 'GlaiveTraceProbe.class']
    files += [Path(variant[k]) for k in ('domain', 'problem', 'plan')]
    cmd = ['wsl.exe', '--exec', 'timeout', '--signal=TERM', '--kill-after=2s', str(protocol['seconds_per_trace']) + 's',
           'java', '-Xmx4096m', '-cp', linux_path(Path(protocol['jar'])) + ':' + linux_path(Path(protocol['classes'])),
           'GlaiveTraceProbe', *[linux_path(Path(variant[k])) for k in ('domain', 'problem', 'plan')]]
    hashes = {str(f.resolve()): digest(f) for f in files}
    save(output / 'invocation.json', {'command': cmd, 'input_sha256': hashes})
    start = time.monotonic()
    process = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    log = process.stdout.decode('utf-8', errors='replace')
    (output / 'stdout.txt').write_text(log, encoding='utf-8')
    states, result = [], {'status': 'runtime_error'}
    for line in log.splitlines():
        if line.startswith('{'):
            event = json.loads(line)
            if event.get('kind') == 'state': states.append(event)
            elif event.get('kind') == 'result': result.update(event)
    if process.returncode in (124, 137): result['status'] = 'wall_time_limit'
    elif 'OutOfMemoryError' in log: result['status'] = 'memory_limit'
    result.update(returncode=process.returncode, seconds=time.monotonic() - start, states=states, input_sha256=hashes)
    verify(hashes); save(output / 'result.json', result)
    return result


def compare(native, mapped, variant):
    if native['status'] != 'trace_complete' or mapped['status'] != 'trace_complete':
        return {'status': 'unavailable_complete_trace', 'native_status': native['status'], 'mapped_status': mapped['status']}
    if len(native['states']) != len(mapped['states']):
        return {'status': 'state_count_mismatch'}
    checks = []
    for before, after in zip(native['states'], mapped['states']):
        expected = {canonical(rewrite(casefold_tree(parse_sexpr(x)), None, variant['predicate_map'], variant['terms']))
                    for x in before['literals']}
        observed = set()
        for text in after['literals']:
            expr = casefold_tree(parse_sexpr(text))
            if expr[0] not in variant['auxiliaries']: observed.add(canonical(expr))
        checks.append({'step': before['step'], 'state_equal': expected == observed,
                       'missing': sorted(map(repr, expected - observed)), 'extra': sorted(map(repr, observed - expected)),
                       'goal_equal': before['goal'] == after['goal'],
                       'native_goal': before['goal'], 'mapped_goal': after['goal'],
                       'explanation_counters_equal': all(before[k] == after[k] for k in ('unexplained_steps', 'orphan_steps')),
                       'native_intentions': sum(x.startswith('(intends ') for x in before['literals']),
                       'mapped_intentions': sum(x.startswith('(intends ') for x in after['literals'])})
    return {'status': 'trace_match' if all(c['state_equal'] and c['goal_equal'] for c in checks) else 'trace_mismatch',
            'states_checked': len(checks), 'executed_steps': native['completed_steps'], 'checks': checks,
            'final_goal': native['states'][-1]['goal'],
            'all_explanation_counters_equal': all(c['explanation_counters_equal'] for c in checks)}


def execute(output):
    if (output / 'report.json').exists() or (output / 'progress.json').exists(): raise ValueError('Fresh execution required')
    if digest(output / 'protocol.json') != (output / 'PROTOCOL.sha256').read_text(encoding='utf-8').strip(): raise ValueError('Changed protocol')
    p = read(output / 'protocol.json'); verify(p['sha256'])
    rows, comparisons = [], []
    for task in p['tasks']:
        results = {}
        for condition in p['conditions']:
            row = {'id': task['id'] + '__' + condition, 'task': task['id'], 'condition': condition}
            if condition in task['variants']:
                result = invoke_trace(task['variants'][condition], p, output / task['id'] / ('trace_' + condition))
                results[condition] = result
                row.update(status=result['status'], states=len(result['states']), executed_steps=result.get('completed_steps'))
            else: row.update(status='unavailable_conversion', reason=task['unavailable_reason'])
            rows.append(row)
            print(row, flush=True); save(output / 'progress.json', {'rows': rows})
        for condition in ('single', 'union'):
            try:
                comparison = compare(results['native'], results[condition], task['variants'][condition]) if condition in results else {'status': 'unavailable_conversion'}
            except (ValueError, TypeError, KeyError, IndexError) as exc:
                comparison = {'status': 'comparison_error', 'reason': str(exc)}
            comparisons.append({'id': task['id'] + '__' + condition, 'task': task['id'], 'condition': condition, **comparison})
    report = {'status': 'complete', 'slots': len(rows), 'rows': rows, 'comparisons': comparisons,
              'counts': dict(Counter(r['status'] for r in rows)), 'comparison_counts': dict(Counter(c['status'] for c in comparisons)),
              'inputs_unchanged': verify(p['sha256']), 'model_calls': 0, 'search_calls': 0,
              'trace_calls': sum(r['status'] != 'unavailable_conversion' for r in rows),
              'states_compared': sum(c.get('states_checked', 0) for c in comparisons),
              'executed_steps_compared': sum(c.get('executed_steps', 0) for c in comparisons),
              'scope': 'Known original tasks; executed-step reference projections; no full counterfactual explanation or independent semantics claim'}
    save(output / 'report.json', report)
    return {k: report[k] for k in ('status', 'counts', 'comparison_counts', 'states_compared', 'executed_steps_compared')}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['prepare', 'execute'])
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--admission', type=Path)
    parser.add_argument('--classes', type=Path, default=Path('.tmp/glaive_trace_round2_v1'))
    args = parser.parse_args()
    result = prepare(args.output.resolve(), args.admission.resolve(), args.classes.resolve()) if args.mode == 'prepare' else execute(args.output.resolve())
    print(json.dumps(result, ensure_ascii=False, indent=2))

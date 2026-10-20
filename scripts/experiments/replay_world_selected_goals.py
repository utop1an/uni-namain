"""Audit all available native original-goal plans in frozen selected models."""
import argparse
from collections import Counter
import json
from pathlib import Path
from unified_planning.io import PDDLReader
from rcnc.domain_building import require_empty_output, save
from rcnc.trace_audit import compare_states
from scripts.experiments.run_downward_reference import sha
from scripts.experiments.run_union_regression import translate_plan


def run(matched, selected, output):
    require_empty_output(output)
    output.mkdir(parents=True)
    native_report = json.loads((matched / 'report.json').read_text(encoding='utf-8'))
    protocol = json.loads((selected / 'bundle/manifest.json').read_text(encoding='utf-8'))
    tasks = [t for t in protocol['tasks'] if t['representation'] == 'world_selected']
    native = {r['id']: r for r in native_report['rows']}
    if native_report['status'] != 'complete' or len({t['source'] for t in tasks}) != 15:
        raise ValueError('Complete 15-source original-world evidence required')
    frozen = {str(p): sha(p) for p in (matched / 'report.json', selected / 'bundle/manifest.json',
        Path(__file__), Path('rcnc/trace_audit.py'), Path('scripts/experiments/run_union_regression.py'))}
    rows = []
    for task in tasks:
        source = task['source']
        row = {'source': source, 'native_status': native[source + '__source_isolated']['status']}
        if row['native_status'] != 'solved':
            row['status'] = 'no_native_original_goal_plan'
        else:
            compiled = selected / 'models' / source / 'compiled'
            meta = json.loads((compiled / 'meta_domain.json').read_text(encoding='utf-8'))
            original = matched / 'solver/tasks' / (source + '__source_isolated')
            for kind, suffix in [('domain', 'domainfile'), ('problem', 'problemfile')]:
                if sha(original / (kind + '.pddl')) != meta['source_sha256'][source + '_' + suffix + '.pddl']:
                    raise ValueError('Original source drift')
                frozen[str(original / (kind + '.pddl'))] = sha(original / (kind + '.pddl'))
            for path in (compiled / 'meta_domain.json', compiled / 'meta_domain.pddl',
                         compiled / 'problems' / (source + '_problemfile.pddl'), original / 'plan.txt'):
                frozen[str(path)] = sha(path)
            mapped_dir = output / 'traces' / source
            mapped = translate_plan(source, matched / 'inputs', compiled, original, mapped_dir)
            reader = PDDLReader()
            src = reader.parse_problem(str(original / 'domain.pddl'), str(original / 'problem.pddl'))
            dst = reader.parse_problem(str(mapped_dir / 'domain.pddl'), str(mapped_dir / 'problem.pddl'))
            sp = reader.parse_plan(src, str(original / 'plan.txt'))
            tp = reader.parse_plan(dst, str(mapped_dir / 'plan.txt'))
            terms = {k.lower(): v.lower() for k, v in
                     {**meta['constant_maps'][source], **meta['namespaces'][source].get('objects', {})}.items()}
            audit = compare_states(src, dst, sp, tp,
                                   {k.lower(): v.lower() for k, v in meta['predicate_maps'][source].items()}, terms,
                                   {k.lower(): v for k, v in meta['predicate_orders'][source].items()})
            row.update(status='PASS' if mapped['validation']['status'] == 'VALID' and audit['status'] == 'PASS' else 'FAIL',
                       plan_length=mapped['length'], validation=mapped['validation'], state_audit=audit)
        rows.append(row)
    result = {'status': 'complete', 'rows': rows, 'task_count': len(rows),
        'counts': dict(Counter(r['status'] for r in rows)),
        'states_compared': sum(r.get('state_audit', {}).get('states_compared', 0) for r in rows),
        'truth_comparisons': sum(r.get('state_audit', {}).get('truth_comparisons', 0) for r in rows),
        'mismatch_count': sum(r.get('state_audit', {}).get('mismatch_count', 0) for r in rows),
        'frozen_sha256': frozen, 'hashes_unchanged': all(sha(Path(p)) == h for p, h in frozen.items()),
        'scope': 'Available original-goal source plans only; no new solver calls or independent semantic labels'}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('matched', 'selected', 'output'):
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    result = run(args.matched, args.selected, args.output)
    print(json.dumps({k: v for k, v in result.items() if k not in ('rows', 'frozen_sha256')}, indent=2))

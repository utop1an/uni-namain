"""Bounded source-plan regression against one immutable pre-search union.

This is development evidence for execution preservation, not semantic fusion
or narrative quality. Each source search has a separate process time budget.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
import math
from pathlib import Path
import platform
import subprocess
import sys
import time
import traceback

from rcnc.domain_union import build
from rcnc.validation import validate_artifacts


def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def translate_plan(source, inputs, union, original, output):
    """Map actual planner action instances; never infer object identity."""
    from unified_planning.io import PDDLReader, PDDLWriter
    from unified_planning.plans import ActionInstance, SequentialPlan
    reader = PDDLReader()
    src = reader.parse_problem(str(inputs / f'{source}_domainfile.pddl'),
                               str(inputs / f'{source}_problemfile.pddl'))
    plan = reader.parse_plan(src, str(original / 'plan.txt'))
    dst = reader.parse_problem(str(union / 'meta_domain.pddl'),
                               str(union / 'problems' / f'{source}_problemfile.pddl'))
    meta = json.loads((union / 'meta_domain.json').read_text(encoding='utf-8'))
    actions = {k.lower(): v.lower() for k, v in meta['action_maps'][source].items()}
    terms = {k.lower(): v.lower() for k, v in meta['constant_maps'][source].items()}
    terms.update({k.lower(): v.lower() for k, v in meta['namespaces'][source].get('objects', {}).items()})
    mapped = []
    trace = []
    for step in plan.actions:
        names = []
        for parameter in step.actual_parameters:
            if not parameter.is_object_exp():
                raise ValueError('Only object-valued action arguments are supported')
            names.append(terms[parameter.object().name.lower()])
        action = dst.action(actions[step.action.name.lower()])
        instance = ActionInstance(action, tuple(dst.environment.expression_manager.ObjectExp(dst.object(n)) for n in names))
        mapped.append(instance)
        trace.append({'source': str(step), 'mapped': str(instance)})
    output.mkdir(parents=True, exist_ok=True)
    (output / 'domain.pddl').write_bytes((union / 'meta_domain.pddl').read_bytes())
    (output / 'problem.pddl').write_bytes((union / 'problems' / f'{source}_problemfile.pddl').read_bytes())
    PDDLWriter(dst).write_plan(SequentialPlan(mapped), str(output / 'plan.txt'))
    save(output / 'trace_mapping.json', trace)
    return {'length': len(mapped), 'validation': validate_artifacts(output)}


def run(inputs, output, seconds=60, max_states=5000, max_depth=30,
        solver='typed_cartesian', max_ground_actions=100000):
    import unified_planning
    if not math.isfinite(seconds) or seconds <= 0 or max_states < 1 or max_depth < 0 or max_ground_actions < 1:
        raise ValueError('Invalid search budget')
    if solver not in ('legacy', 'typed_cartesian', 'pyperplan'):
        raise ValueError('Unknown solver')
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    sources = [p.name.removesuffix('_domainfile.pddl') for p in sorted(inputs.glob('*_domainfile.pddl'))]
    union = output / 'union'
    built = build(inputs, union)
    if not built['valid']:
        raise ValueError('Union failed independent parsing')
    from scripts.audit.audit_union_preservation import audit
    schema_audit = audit(inputs, union)
    save(output / 'schema_audit.json', schema_audit)
    if schema_audit['status'] != 'PASS':
        raise ValueError('Union failed source schema recovery audit')
    frozen_hash = digest(union / 'meta_domain.pddl')
    report = {
        'status': 'running', 'started_utc': datetime.now(timezone.utc).isoformat(),
        'scope': 'Development source-plan regression; no semantic alignment or narrative-quality claim',
        'source_count': len(sources), 'source_order': sources,
        'budget_per_source': {'seconds': seconds, **({'max_states': max_states, 'max_depth': max_depth,
                              'max_ground_actions': max_ground_actions} if solver != 'pyperplan' else {})},
        'solver': solver,
        'runtime': {'python': platform.python_version(), 'unified_planning': unified_planning.__version__},
        'implementation_sha256': {name: digest(Path(__file__).resolve().parents[2] / name) for name in
                                  ['scripts/experiments/run_union_regression.py', 'rcnc/reference_planning.py',
                                   'rcnc/domain_union.py', 'rcnc/domain_building.py', 'rcnc/pddl.py', 'rcnc/pddl_checks.py', 'rcnc/validation.py',
                                   'rcnc/merged_planning.py', 'rcnc/heuristic_planning.py', 'scripts/audit/audit_union_preservation.py',
                                   'rcnc/grounding.py']},
        'merged_before_planning': True, 'merged_domain_sha256': frozen_hash, 'rows': [],
    }
    save(output / 'report.json', report)
    for source in sources:
        directory = output / 'sources' / source
        original = directory / 'original'
        result_file = directory / 'search.json'
        directory.mkdir(parents=True, exist_ok=True)
        row = {'source': source}
        started = time.monotonic()
        if not (inputs / f'{source}_problemfile.pddl').exists():
            row['search'] = {'status': 'missing_problem'}
        else:
            command = [sys.executable, '-m', 'scripts.experiments.run_union_regression', '--worker',
                       '--input', str(inputs.resolve()), '--output', str(original.resolve()),
                       '--source', source, '--result', str(result_file.resolve()),
                       '--max-states', str(max_states), '--max-depth', str(max_depth),
                       '--solver', solver, '--max-ground-actions', str(max_ground_actions)]
            try:
                with (directory / 'worker.log').open('w', encoding='utf-8') as log:
                    completed = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, timeout=seconds)
                row['search'] = json.loads(result_file.read_text(encoding='utf-8')) if result_file.exists() else {
                    'status': 'worker_error', 'returncode': completed.returncode}
            except subprocess.TimeoutExpired:
                row['search'] = {'status': 'time_limit'}
        row['elapsed_seconds'] = round(time.monotonic() - started, 3)
        if row['search']['status'] == 'solved' and row['search'].get('validation', {}).get('status') == 'VALID':
            try:
                row['mapped'] = translate_plan(source, inputs, union, original, directory / 'mapped')
            except Exception as exc:
                row['mapped'] = {'validation': {'status': 'ERROR', 'reason': f'{type(exc).__name__}: {exc}'}}
        row['preservation_evidence'] = ('validated_translated_plan' if row.get('mapped', {}).get('validation', {}).get('status') == 'VALID'
                                        else 'translation_failed' if 'mapped' in row else 'no_valid_source_plan')
        report['rows'].append(row)
        report['search_counts'] = dict(Counter(r['search']['status'] for r in report['rows']))
        report['preservation_counts'] = dict(Counter(r['preservation_evidence'] for r in report['rows']))
        save(output / 'report.json', report)
        print(json.dumps(row), flush=True)
    report['merged_domain_unchanged'] = digest(union / 'meta_domain.pddl') == frozen_hash
    report['status'] = 'complete'
    report['finished_utc'] = datetime.now(timezone.utc).isoformat()
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input', type=Path, default=Path('data/narra-domains'))
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--seconds', type=float, default=60)
    parser.add_argument('--max-states', type=int, default=5000)
    parser.add_argument('--max-depth', type=int, default=30)
    parser.add_argument('--max-ground-actions', type=int, default=100000)
    parser.add_argument('--solver', choices=['legacy', 'typed_cartesian', 'pyperplan'], default='typed_cartesian')
    parser.add_argument('--worker', action='store_true', help=argparse.SUPPRESS)
    parser.add_argument('--source', help=argparse.SUPPRESS)
    parser.add_argument('--result', type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.worker:
        from rcnc.reference_planning import bounded_plan
        try:
            if args.solver == 'pyperplan':
                from rcnc.heuristic_planning import solve as heuristic_solve
                result = heuristic_solve(args.input / f'{args.source}_domainfile.pddl',
                                         args.input / f'{args.source}_problemfile.pddl', args.output)
            elif args.solver == 'typed_cartesian':
                from rcnc.merged_planning import solve
                result = solve(args.input / f'{args.source}_domainfile.pddl',
                               args.input / f'{args.source}_problemfile.pddl', args.output,
                               args.max_states, args.max_depth, args.max_ground_actions)
            else:
                result = bounded_plan(args.input / f'{args.source}_domainfile.pddl',
                                  args.input / f'{args.source}_problemfile.pddl', args.output,
                                  args.max_states, args.max_depth)
        except Exception as exc:
            traceback.print_exc()
            result = {'status': 'error', 'reason': f'{type(exc).__name__}: {exc}'}
        save(args.result, result)
    else:
        result = run(args.input, args.output, args.seconds, args.max_states, args.max_depth,
                     args.solver, args.max_ground_actions)
        raise SystemExit(0 if result['merged_domain_unchanged'] and not result['preservation_counts'].get('translation_failed') else 1)

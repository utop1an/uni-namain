"""Check synthetic source-probe traces in a fixed compiled model, keeping goals explicit."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path

from rcnc.pddl import parse_sexpr, section, serialize
from rcnc.validation import validate_artifacts
from scripts.experiments.run_union_regression import translate_plan


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run(probes, source_run, compiled, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    frozen, native, report = read(probes/'manifest.json'), read(source_run/'manifest.json'), read(source_run/'report.json')
    if report['status'] != 'complete' or native['mode'] != 'synthetic_source_effect_probes':
        raise ValueError('Requires completed synthetic-probe run')
    if native['probe_manifest_sha256'] != sha(probes/'manifest.json') or report['manifest_sha256'] != sha(source_run/'manifest.json'):
        raise ValueError('Probe/run manifest changed')
    tasks = {task['id']: task for task in frozen['tasks']}
    if len(tasks) != frozen['task_count'] or len(report['rows']) != len(tasks) or {r['id'] for r in report['rows']} != set(tasks):
        raise ValueError('Probe denominator mismatch')
    meta = read(compiled/'meta_domain.json')
    domain_hash = sha(compiled/'meta_domain.pddl')
    output.mkdir(parents=True)
    result = {'status': 'running', 'probe_count': len(tasks), 'compiled_domain_sha256': domain_hash,
        'probe_manifest_sha256': sha(probes/'manifest.json'), 'source_report_sha256': sha(source_run/'report.json'),
        'scope': 'Synthetic auxiliary goals with unchanged source initial worlds; not original-goal success or independent-domain evidence', 'rows': []}
    for old in report['rows']:
        task = tasks[old['id']]
        source, key = task['source'], task['id']
        row = {'id': key, 'source': source, 'probe_status': old['status']}
        try:
            snapshot = probes/'tasks'/key
            original = source_run/'tasks'/key
            for kind in ('domain', 'problem'):
                if sha(snapshot/(kind+'.pddl')) != task[kind+'_sha256'] or (snapshot/(kind+'.pddl')).read_bytes() != (original/(kind+'.pddl')).read_bytes():
                    raise ValueError('Probe input changed')
            if sha(snapshot/'original_problem.pddl') != task['original_problem_sha256']:
                raise ValueError('Original problem snapshot changed')
            for filename, current in [(source+'_domainfile.pddl', snapshot/'domain.pddl'),
                                      (source+'_problemfile.pddl', snapshot/'original_problem.pddl')]:
                if meta['source_sha256'].get(filename) != sha(current):
                    raise ValueError('Compiled source snapshot differs')
            probe_problem = parse_sexpr((snapshot/'problem.pddl').read_text(encoding='utf-8'))
            original_problem = parse_sexpr((snapshot/'original_problem.pddl').read_text(encoding='utf-8'))
            if section(probe_problem, ':init') != section(original_problem, ':init'):
                raise ValueError('Probe changes source initial state')
            if section(probe_problem, ':objects') != section(original_problem, ':objects'):
                raise ValueError('Probe changes source objects')
            if section(probe_problem, ':goal')[1] != ['and', task['goal']]:
                raise ValueError('Probe goal differs from frozen goal')
            if old['status'] == 'solved' and old.get('validation', {}).get('status') == 'VALID':
                if old.get('plan_length', 0) <= 0:
                    raise ValueError('Probe must demonstrate a nonempty trace')
                row['source_revalidation'] = validate_artifacts(original)
                if row['source_revalidation']['status'] != 'VALID':
                    raise ValueError('Probe plan fails fresh validation')
                directory = output/'probes'/key
                inputs, view = directory/'inputs', directory/'compiled_view'
                inputs.mkdir(parents=True); (view/'problems').mkdir(parents=True)
                (inputs/(source+'_domainfile.pddl')).write_bytes((snapshot/'domain.pddl').read_bytes())
                (inputs/(source+'_problemfile.pddl')).write_bytes((snapshot/'problem.pddl').read_bytes())
                for name in ('meta_domain.pddl', 'meta_domain.json'):
                    (view/name).write_bytes((compiled/name).read_bytes())
                target_problem = parse_sexpr((compiled/'problems'/(source+'_problemfile.pddl')).read_text(encoding='utf-8'))
                predicates = {k.lower(): v for k, v in meta['predicate_maps'][source].items()}
                terms = {k.lower(): v for k, v in meta['constant_maps'][source].items()}
                terms.update({k.lower(): v for k, v in meta['namespaces'][source].get('objects', {}).items()})
                name, *arguments = task['goal']
                order = meta.get('predicate_orders', {}).get(source, {}).get(name, list(range(len(arguments))))
                mapped_goal = [predicates[name.lower()], *[terms[arguments[i].lower()] for i in order]]
                section(target_problem, ':goal')[1] = ['and', mapped_goal]
                (view/'problems'/(source+'_problemfile.pddl')).write_text(serialize(target_problem)+'\n', encoding='utf-8')
                row['mapped_goal'] = mapped_goal
                row['mapped'] = translate_plan(source, inputs, view, original, directory/'validation')
                row['status'] = row['mapped']['validation']['status']
            else:
                row['status'] = 'no_probe_plan_evidence'
        except Exception as exc:
            row.update(status='ERROR', error=f'{type(exc).__name__}: {exc}')
        result['rows'].append(row)
        (output/'report.json').write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
        print(json.dumps(row), flush=True)
    result.update(status='complete', compiled_domain_unchanged=sha(compiled/'meta_domain.pddl') == domain_hash,
        available_probe_plans=sum(row['probe_status'] == 'solved' for row in result['rows']),
        validated_probe_plans=sum(row['status'] == 'VALID' for row in result['rows']),
        sources_with_validated_probe=sorted({row['source'] for row in result['rows'] if row['status'] == 'VALID'}),
        counts=dict(Counter(row['status'] for row in result['rows'])),
        implementation_sha256=sha(Path(__file__)))
    (output/'report.json').write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--probes', type=Path, required=True)
    parser.add_argument('--source-run', type=Path, required=True)
    parser.add_argument('--compiled', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = run(args.probes, args.source_run, args.compiled, args.output)
    raise SystemExit(0 if result['compiled_domain_unchanged'] and not result['counts'].get('ERROR') and result['available_probe_plans'] == result['validated_probe_plans'] else 1)

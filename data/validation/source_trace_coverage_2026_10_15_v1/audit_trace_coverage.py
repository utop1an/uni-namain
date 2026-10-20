"""Measure schema coverage of available source traces, not branch coverage."""
import argparse
from collections import Counter
import json
from pathlib import Path

from merge_domains import parse_domain, parse_sexpr
from rcnc.validation import validate_artifacts
from run_downward_reference import sha, save


def heads(expression):
    if not isinstance(expression, list) or not expression:
        return set()
    result = {expression[0]} if isinstance(expression[0], str) else set()
    for child in expression[1:]:
        result.update(heads(child))
    return result


def features(action):
    fields = dict(zip(action[2::2], action[3::2]))
    pre, eff = heads(fields.get(':precondition', [])), heads(fields.get(':effect', []))
    return {name for name, present in (
        ('universal_condition', 'forall' in pre), ('existential_condition', 'exists' in pre),
        ('disjunctive_condition', 'or' in pre), ('negative_condition', 'not' in pre),
        ('conditional_effect', 'when' in eff), ('universal_effect', 'forall' in eff),
        ('delete_effect', 'not' in eff)) if present}


def audit(inputs, runs, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    actions, source_hashes = {}, {}
    for path in sorted(inputs.glob('*_domainfile.pddl')):
        source = path.name.removesuffix('_domainfile.pddl')
        domain = parse_domain(path, apply_reviewed_semantics=False)
        source_hashes[source] = sha(path)
        actions.update({source+':'+name: features(action) for name, action in domain.actions.items()})
    frozen, traces, counts, covered = {}, [], {}, {}
    for label, run in runs.items():
        manifest_path, report_path = run/'manifest.json', run/'report.json'
        manifest, report = [json.loads(p.read_text(encoding='utf-8')) for p in (manifest_path, report_path)]
        tasks = {t['id']: t for t in manifest['tasks']}
        if (report['status'] != 'complete' or report['manifest_sha256'] != sha(manifest_path)
                or len(tasks) != manifest['task_count'] or len(report['rows']) != len(tasks)
                or {r['id'] for r in report['rows']} != set(tasks)
                or dict(Counter(r['status'] for r in report['rows'])) != report['status_counts']):
            raise ValueError('Complete hash-matched run required')
        frozen.update({str(p): sha(p) for p in (manifest_path, report_path)})
        covered[label] = set()
        counts[label] = {'tasks': len(tasks), 'available_valid_plans': 0,
                         'status_counts': report['status_counts'], 'action_instances': 0}
        for row in report['rows']:
            task = tasks[row['id']]
            source = task['source']
            directory = run/'tasks'/row['id']
            if task['domain_sha256'] != source_hashes[source]:
                raise ValueError('Task domain differs from original source')
            for name in ('domain', 'problem'):
                path = directory/(name+'.pddl')
                if sha(path) != task[name+'_sha256']:
                    raise ValueError('Frozen task input changed')
                frozen[str(path)] = sha(path)
            if row['status'] != 'solved':
                continue
            plan = directory/'plan.txt'
            frozen[str(plan)] = sha(plan)
            validation = validate_artifacts(directory)
            if validation['status'] != 'VALID':
                raise ValueError('Source plan failed fresh validation')
            used = []
            for line in plan.read_text(encoding='utf-8').splitlines():
                line = line.split(';', 1)[0].strip()
                if line:
                    used.append(source+':'+parse_sexpr(line)[0])
            if not set(used) <= set(actions):
                raise ValueError('Plan uses an unknown source action')
            covered[label].update(used)
            counts[label]['available_valid_plans'] += 1
            counts[label]['action_instances'] += len(used)
            traces.append({'run': label, 'id': row['id'], 'source': source,
                          'action_instances': len(used), 'distinct_actions': sorted(set(used)),
                          'fresh_validation': 'VALID'})
    combined = set().union(*covered.values())
    feature_names = sorted(set().union(*actions.values()))
    feature_coverage = {name: {'schemas_declaring_feature': sum(name in fs for fs in actions.values()),
        'visited_schemas_declaring_feature': sum(name in actions[a] for a in combined)} for name in feature_names}
    by_source = {}
    for source in source_hashes:
        declared = {a for a in actions if a.startswith(source+':')}
        by_source[source] = {'declared_actions': len(declared), 'covered_actions': len(declared & combined),
                             'uncovered_actions': sorted(declared-combined)}
    result = {'status': 'complete', 'source_count': len(source_hashes), 'declared_actions': len(actions),
        'covered_actions': len(combined), 'uncovered_actions': len(actions)-len(combined),
        'per_run': {label: {**counts[label], 'covered_actions': len(covered[label]),
                          'actions': sorted(covered[label])} for label in runs},
        'feature_coverage': feature_coverage, 'sources': by_source, 'traces': traces,
        'frozen_sha256': frozen, 'hashes_unchanged': all(sha(Path(p)) == h for p, h in frozen.items()),
        'scope': 'Distinct source action schemas occurring in available freshly valid traces. '
                 'A visited schema does not imply all bindings or conditional branches were exercised. '
                 'Original goals and auxiliary goals retain separate denominators; no semantic or independent-test claim.'}
    output.mkdir(parents=True)
    for path in (Path(__file__), Path('rcnc/validation.py')):
        (output/path.name).write_bytes(path.read_bytes())
    save(output/'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inputs', type=Path, default=Path('data/narra-domains'))
    parser.add_argument('--original-run', type=Path, required=True)
    parser.add_argument('--probe-run', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = audit(args.inputs, {'original': args.original_run, 'auxiliary': args.probe_run}, args.output)
    print(json.dumps({k: result[k] for k in ('status', 'declared_actions', 'covered_actions', 'uncovered_actions', 'feature_coverage', 'hashes_unchanged')}, indent=2))

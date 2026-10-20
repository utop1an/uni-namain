"""Replay multiple worlds of one source in a single fixed compiled domain."""
import argparse
import copy
import json
from pathlib import Path

from unified_planning.io import PDDLReader
from unified_planning.plans import ActionInstance, SequentialPlan

from rcnc.pddl import parse_sexpr, section, serialize
from rcnc.trace_audit import compare_states
from rcnc.validation import validate_artifacts
from scripts.experiments.run_downward_reference import sha, save


def mapped_formula(expression, predicates, terms, orders):
    head = expression[0].lower()
    if head in ('and', 'or', 'not', 'imply'):
        return [head, *[mapped_formula(x, predicates, terms, orders) for x in expression[1:]]]
    if head == '=':
        return [head, *[terms[x.lower()] for x in expression[1:]]]
    if head not in predicates:
        raise ValueError('Unsupported or unknown ground formula: '+head)
    args = [terms[x.lower()] for x in expression[1:]]
    order = orders.get(head, list(range(len(args))))
    return [predicates[head], *[args[i] for i in order]]


def run(source_run, compiled, reference_problem, source, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use a fresh output directory')
    metadata = json.loads((compiled/'meta_domain.json').read_text(encoding='utf-8'))
    manifest = json.loads((source_run/'manifest.json').read_text(encoding='utf-8'))
    native = json.loads((source_run/'report.json').read_text(encoding='utf-8'))
    tasks = {t['id']: t for t in manifest['tasks']}
    if (native['status'] != 'complete' or native['manifest_sha256'] != sha(source_run/'manifest.json')
            or len(native['rows']) != len(tasks) or {r['id'] for r in native['rows']} != set(tasks)):
        raise ValueError('Complete native task coverage required')
    if metadata['source_sha256'][source+'_problemfile.pddl'] != sha(reference_problem):
        raise ValueError('Reference problem differs from compilation snapshot')
    reference = parse_sexpr(reference_problem.read_text(encoding='utf-8'))
    template = parse_sexpr((compiled/'problems'/(source+'_problemfile.pddl')).read_text(encoding='utf-8'))
    predicates = {k.lower(): v.lower() for k, v in metadata['predicate_maps'][source].items()}
    terms = {k.lower(): v.lower() for k, v in metadata['constant_maps'][source].items()}
    terms.update({k.lower(): v.lower() for k, v in metadata['namespaces'][source].get('objects', {}).items()})
    orders = {k.lower(): v for k, v in metadata.get('predicate_orders', {}).get(source, {}).items()}
    guard_names = set(metadata.get('type_guards', {}).values())
    memberships = [x for x in section(template, ':init')[1:] if x[0] in guard_names]
    frozen = {str(p): sha(p) for p in (compiled/'meta_domain.pddl', compiled/'meta_domain.json',
        source_run/'manifest.json', source_run/'report.json', reference_problem, Path(__file__), Path('rcnc/trace_audit.py'))}
    output.mkdir(parents=True)
    result = {'status': 'running', 'source': source, 'problem_count': len(tasks),
        'compiled_source_count': len(metadata['sources']), 'rows': [], 'frozen_sha256': frozen,
        'scope': 'One externally sourced domain, separately supplied worlds; fixed parameterized model, zero cross-source predicate merges; no semantic alignment or narrative quality claim'}
    reader = PDDLReader()
    for old in native['rows']:
        task = tasks[old['id']]
        directory = source_run/'tasks'/old['id']
        row = {'id': old['id'], 'native_status': old['status']}
        for name in ('domain', 'problem'):
            path = directory/(name+'.pddl')
            if sha(path) != task[name+'_sha256']:
                raise ValueError('Native task changed')
            frozen[str(path)] = sha(path)
        if task['domain_sha256'] != metadata['source_sha256'][source+'_domainfile.pddl']:
            raise ValueError('Source domain differs from compilation snapshot')
        original = parse_sexpr((directory/'problem.pddl').read_text(encoding='utf-8'))
        if section(original, ':objects') != section(reference, ':objects'):
            raise ValueError('This audit requires identical typed object vocabularies')
        target = copy.deepcopy(template)
        section(target, ':init')[1:] = [mapped_formula(x, predicates, terms, orders) for x in section(original, ':init')[1:]] + memberships
        section(target, ':goal')[1] = mapped_formula(section(original, ':goal')[1], predicates, terms, orders)
        dest = output/'tasks'/old['id']
        dest.mkdir(parents=True)
        (dest/'domain.pddl').write_bytes((compiled/'meta_domain.pddl').read_bytes())
        (dest/'problem.pddl').write_text(serialize(target)+'\n', encoding='utf-8')
        row.update(domain_sha256=sha(dest/'domain.pddl'), problem_sha256=sha(dest/'problem.pddl'),
            narrative_initial_facts=len(section(original, ':init'))-1, representation_memberships=len(memberships),
            other_source_narrative_facts_imported=0)
        if old['status'] == 'solved':
            frozen[str(directory/'plan.txt')] = sha(directory/'plan.txt')
            row['native_validation'] = validate_artifacts(directory)['status']
            if row['native_validation'] != 'VALID':
                raise ValueError('Native plan no longer validates')
            src = reader.parse_problem(str(directory/'domain.pddl'), str(directory/'problem.pddl'))
            dst = reader.parse_problem(str(dest/'domain.pddl'), str(dest/'problem.pddl'))
            sp = reader.parse_plan(src, str(directory/'plan.txt'))
            mapped = [[metadata['action_maps'][source][a.action.name].lower(),
                       *[terms[p.object().name.lower()] for p in a.actual_parameters]] for a in sp.actions]
            tp = SequentialPlan([ActionInstance(dst.action(a[0]), tuple(dst.object(x) for x in a[1:])) for a in mapped])
            (dest/'plan.txt').write_text('\n'.join(serialize(a) for a in mapped)+'\n')
            row['translated_validation'] = validate_artifacts(dest)['status']
            row['state_audit'] = compare_states(src, dst, sp, tp, predicates, terms, orders)
            row['status'] = 'PASS' if row['translated_validation'] == 'VALID' and row['state_audit']['status'] == 'PASS' else 'FAIL'
        else:
            row['status'] = 'no_native_plan_evidence'
        result['rows'].append(row)
        save(output/'report.json', result)
        print(json.dumps({'id': row['id'], 'status': row['status']}), flush=True)
    result.update(status='complete', hashes_unchanged=all(sha(Path(p)) == h for p, h in frozen.items()),
        valid_replays=sum(r['status'] == 'PASS' for r in result['rows']),
        states_compared=sum(r.get('state_audit', {}).get('states_compared', 0) for r in result['rows']),
        truth_comparisons=sum(r.get('state_audit', {}).get('truth_comparisons', 0) for r in result['rows']))
    save(output/'report.json', result)
    (output/Path(__file__).name).write_bytes(Path(__file__).read_bytes())
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('source-run', 'compiled', 'reference-problem', 'output'):
        parser.add_argument('--'+name, type=Path, required=True)
    parser.add_argument('--source', required=True)
    args = parser.parse_args()
    result = run(args.source_run, args.compiled, args.reference_problem, args.source, args.output)
    print(json.dumps({k: v for k, v in result.items() if k not in ('rows', 'frozen_sha256')}, indent=2))
    raise SystemExit(not result['hashes_unchanged'] or any(r['status'] == 'FAIL' for r in result['rows']))

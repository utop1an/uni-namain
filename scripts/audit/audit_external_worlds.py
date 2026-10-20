"""Check full initial-world isolation independently using parsed UP atoms."""
import argparse
import json
from pathlib import Path

from unified_planning.io import PDDLReader
from scripts.experiments.replay_source_probes import read, sha
from scripts.experiments.run_downward_reference import save


def world_check(original, target, metadata, source):
    predicates = {k.lower(): v.lower() for k, v in metadata['predicate_maps'][source].items()}
    terms = {k.lower(): v.lower() for k, v in metadata['constant_maps'][source].items()}
    terms.update({k.lower(): v.lower() for k, v in metadata['namespaces'][source].get('objects', {}).items()})
    orders = metadata.get('predicate_orders', {}).get(source, {})
    allowed = set(predicates.values())
    guards = {v.lower() for v in metadata.get('type_guards', {}).values()}
    def key(atom):
        return (atom.fluent().name, tuple(arg.object().name for arg in atom.args))
    expected = set()
    for atom, value in original.explicit_initial_values.items():
        if value.is_true():
            name = atom.fluent().name
            args = [terms[arg.object().name] for arg in atom.args]
            order = orders.get(name, list(range(len(args))))
            expected.add((predicates[name], tuple(args[i] for i in order)))
    actual = {key(atom) for atom, value in target.explicit_initial_values.items()
              if value.is_true() and atom.fluent().name not in guards}
    foreign = sorted(str(atom) for atom in target.explicit_initial_values
                     if atom.fluent().name not in allowed | guards)
    return {'status': 'PASS' if expected == actual and not foreign else 'FAIL',
            'expected_narrative_true_atoms': len(expected), 'observed_narrative_true_atoms': len(actual),
            'extra_true_atoms': sorted(actual-expected), 'missing_true_atoms': sorted(expected-actual),
            'foreign_narrative_declarations': foreign}


def run(source_run, compiled, replay, source, output):
    if output.exists():
        raise ValueError('Use a fresh audit file')
    metadata, report = read(compiled/'meta_domain.json'), read(replay/'report.json')
    if report['status'] != 'complete' or len(report['rows']) != report['problem_count']:
        raise ValueError('Completed replay required')
    reader, rows = PDDLReader(), []
    frozen = {str(p): sha(p) for p in (compiled/'meta_domain.json', replay/'report.json', Path(__file__))}
    negative = None
    for row in report['rows']:
        left, right = source_run/'tasks'/row['id'], replay/'tasks'/row['id']
        for directory in (left, right):
            for name in ('domain.pddl', 'problem.pddl'):
                frozen[str(directory/name)] = sha(directory/name)
        original = reader.parse_problem(str(left/'domain.pddl'), str(left/'problem.pddl'))
        target = reader.parse_problem(str(right/'domain.pddl'), str(right/'problem.pddl'))
        rows.append({'id': row['id'], **world_check(original, target, metadata, source)})
        if negative is None:
            allowed = {v.lower() for v in metadata['predicate_maps'][source].values()}
            guards = {v.lower() for v in metadata.get('type_guards', {}).values()}
            for fluent in target.fluents:
                if fluent.name in allowed | guards:
                    continue
                args = [next(iter(target.objects(p.type)), None) for p in fluent.signature]
                if any(a is None for a in args):
                    continue
                mutant = target.clone()
                atom = fluent(*args)
                mutant.set_initial_value(atom, True)
                negative = {'injected_atom': str(atom), 'audit': world_check(original, mutant, metadata, source),
                            'scope': 'In-memory negative control; archived problem files unchanged'}
                break
    result = {'status': 'PASS' if all(r['status'] == 'PASS' for r in rows) and negative and negative['audit']['status'] == 'FAIL' else 'FAIL',
              'problem_count': len(rows), 'rows': rows, 'negative_control': negative,
              'frozen_sha256': frozen, 'hashes_unchanged': all(sha(Path(p)) == h for p, h in frozen.items()),
              'scope': 'Parsed initial-world correspondence plus absence of all foreign narrative declarations; type-membership facts explicitly separated; no story-quality claim'}
    save(output, result)
    return result


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    for name in ('source-run', 'compiled', 'replay', 'output'):
        p.add_argument('--'+name, type=Path, required=True)
    p.add_argument('--source', required=True)
    a = p.parse_args()
    r = run(a.source_run, a.compiled, a.replay, a.source, a.output)
    print(json.dumps({'status': r['status'], 'problems': r['problem_count'], 'hashes_unchanged': r['hashes_unchanged'], 'negative_control_status': r['negative_control']['audit']['status']}, indent=2))

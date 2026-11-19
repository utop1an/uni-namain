"""Recheck initial-world constraints with UP enumeration and state evaluation."""
import argparse
from collections import Counter
import json
from pathlib import Path

from unified_planning.io import PDDLReader
from unified_planning.model.fluent import get_all_fluent_exp
from unified_planning.shortcuts import SequentialSimulator

from rcnc.domain_building import archived_implementation, digest, require_empty_output, save, snapshot_implementation


def reconstruct(root, case):
    meta = json.loads((root / case['compiled'] / 'meta_domain.json').read_text(encoding='utf-8'))
    table, count = {}, 0
    counts = {}
    for world in case['worlds']:
        source = world['source']
        problem = PDDLReader().parse_problem(str(root / world['domain']), str(root / world['problem']))
        terms = {name.lower(): target.lower() for name, target in meta['constant_maps'][source].items()}
        terms.update(world['object_map'])
        counts[source] = 0
        with SequentialSimulator(problem) as simulator:
            state = simulator.get_initial_state()
            for fluent in problem.fluents:
                # Independent enumerator, rather than the helper's product loop.
                for atom in get_all_fluent_exp(problem, fluent):
                    count += 1
                    if count > 2000000:
                        raise ValueError('Independent audit atom budget exceeded')
                    counts[source] += 1
                    arguments = [terms[argument.object().name.lower()] for argument in atom.args]
                    order = meta['predicate_orders'][source][fluent.name]
                    target = (meta['predicate_maps'][source][fluent.name], *[arguments[index] for index in order])
                    truth = state.get_value(atom).bool_constant_value()
                    witness = (source, fluent.name, tuple(argument.object().name for argument in atom.args), truth)
                    table.setdefault(target, {}).setdefault(truth, set()).add(witness)
    return table, count, counts


def audit(root, output):
    require_empty_output(output)
    read = lambda path: json.loads(path.read_text(encoding='utf-8'))
    manifest, report = read(root / 'manifest.json'), read(root / 'report.json')
    if report['status'] != 'complete' or report['manifest_sha256'] != digest(root / 'manifest.json'):
        raise ValueError('Complete unchanged compatibility audit required')
    if any(report.get(key) is not True for key in ('inputs_unchanged', 'implementation_unchanged', 'all_controls_expected')):
        raise ValueError('Execution integrity/control failure')
    for path, expected in manifest['input_sha256'].items():
        if digest(root / path) != expected:
            raise ValueError('Frozen input drift')
    for path, expected in manifest['implementation_sha256'].items():
        if digest(archived_implementation(root, path)) != expected:
            raise ValueError('Missing frozen implementation')
    cases = {case['id']: case for case in manifest['cases']}
    rows = {row['id']: row for row in report['rows']}
    if len(cases) != 8 or len(rows) != 8 or len(manifest['cases']) != 8 or len(report['rows']) != 8 or set(cases) != set(rows):
        raise ValueError('Incomplete or duplicate8-case denominator')
    if dict(Counter(row['status'] for row in rows.values())) != report['status_counts']:
        raise ValueError('Summary status mismatch')
    checked = []
    for identifier, case in cases.items():
        row = rows[identifier]
        original = read(root / 'results' / (identifier + '.json'))
        if any(row.get(key) != value for key, value in original.items()):
            raise ValueError('Individual result differs from aggregate')
        table, count, source_counts = reconstruct(root, case)
        conflicts = {key: values for key, values in table.items() if len(values) == 2}
        if row['required_ground_atom_comparisons'] != count:
            raise ValueError('Ground-atom denominator mismatch')
        if row['status'] == 'atom_budget_limit':
            if count <= case['max_atoms'] or row['complete'] is not False or row['compatible'] is not None or row['ground_atom_comparisons'] != 0:
                raise ValueError('Budget cutoff was promoted to a verdict')
        else:
            if count > case['max_atoms'] or row['complete'] is not True or row['ground_atom_comparisons'] != count:
                raise ValueError('Inexact or over-budget compatibility verdict')
            if row['compatible'] != (not conflicts) or row['conflicting_atoms'] != len(conflicts):
                raise ValueError('Initial consistency verdict mismatch')
            if {tuple(item['mapped_atom']) for item in row['conflicts']} != set(conflicts):
                raise ValueError('Missing or added conflicting atoms')
            for item in row['conflicts']:
                target = tuple(item['mapped_atom'])
                for side in ('left', 'right'):
                    witness = item[side]
                    key = (witness['source'], witness['source_atom'][0], tuple(witness['source_atom'][1:]), witness['truth'])
                    if key not in conflicts[target][witness['truth']]:
                        raise ValueError('Conflict witness cannot be reproduced')
        checked.append({'id': identifier, 'status': row['status'], 'independently_counted_atoms': count,
            'source_counts': source_counts, 'independently_conflicting_atoms': len(conflicts),
            'original_verdict_retained': row['compatible'], 'expected_status': case['expected_status']})
    implementation = snapshot_implementation(output, [Path(__file__), Path('rcnc/domain_building.py')])
    result = {'status': 'verified_world_compatibility_snapshot', 'case_count': len(checked), 'rows': checked,
        'status_counts': dict(Counter(row['status'] for row in checked)), 'hashes_unchanged': True,
        'independent_semantic_labels': 0, 'pooled_planning_world_created': False,
        'report_sha256': digest(root / 'report.json'), 'manifest_sha256': digest(root / 'manifest.json'),
        'implementation_sha256': implementation,
        'scope': 'Independent UP typed-atom enumeration and simulator initial-truth recheck. These are initial-projection constraints only; no semantic-equivalence or joint-goal claim. The atom-budget control retains its unknown verdict.'}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = audit(args.root, args.output)
    print(json.dumps({key: value for key, value in result.items() if key not in ('rows', 'implementation_sha256')}, indent=2))

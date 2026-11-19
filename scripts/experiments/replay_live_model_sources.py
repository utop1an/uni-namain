"""Explicit source-world replay in one pre-existing live-proposed model."""
import argparse
from collections import Counter
import json
from pathlib import Path

from unified_planning.io import PDDLReader
from unified_planning.model.fluent import get_all_fluent_exp
from unified_planning.shortcuts import SequentialSimulator

from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.narrative_pipeline import map_problem
from rcnc.validation import validate_artifacts
from scripts.experiments.run_original_world_pipeline import convert_problem
from scripts.experiments.run_union_regression import translate_plan


def compare_states(native, mapped, source, metadata, mapping, remaining):
    reader = PDDLReader()
    left = reader.parse_problem(str(native / 'domain.pddl'), str(native / 'problem.pddl'))
    source_plan = reader.parse_plan(left, str(native / 'plan.txt'))
    right = reader.parse_problem(str(mapped / 'domain.pddl'), str(mapped / 'problem.pddl'))
    target_plan = reader.parse_plan(right, str(mapped / 'plan.txt'))
    if len(source_plan.actions) != len(target_plan.actions):
        raise ValueError('Full source action sequence must remain intact')
    atoms = [atom for fluent in left.fluents for atom in get_all_fluent_exp(left, fluent)]
    required = len(atoms) * (len(source_plan.actions) + 1)
    if required > remaining:
        return {'status': 'atom_budget_limit', 'required_comparisons': required, 'comparisons': 0}
    terms = {name.lower(): target.lower() for name, target in metadata['constant_maps'][source].items()}
    terms.update(mapping['objects'])
    pairs = []
    for atom in atoms:
        arguments = [right.object(terms[arg.object().name.lower()]) for arg in atom.args]
        order = metadata['predicate_orders'][source][atom.fluent().name]
        target = right.fluent(metadata['predicate_maps'][source][atom.fluent().name])
        pairs.append((atom, target(*[arguments[index] for index in order])))
    comparisons, mismatches, examples = 0, 0, []
    with SequentialSimulator(left) as first, SequentialSimulator(right) as second:
        a, b = first.get_initial_state(), second.get_initial_state()
        for step in range(len(source_plan.actions) + 1):
            for source_atom, target_atom in pairs:
                comparisons += 1
                source_value, target_value = a.get_value(source_atom), b.get_value(target_atom)
                if source_value.bool_constant_value() != target_value.bool_constant_value():
                    mismatches += 1
                    if len(examples) < 10:
                        examples.append({'step': step, 'source_atom': str(source_atom), 'mapped_atom': str(target_atom),
                            'source_truth': str(source_value), 'mapped_truth': str(target_value)})
            if step == len(source_plan.actions):
                break
            original, translated = source_plan.actions[step], target_plan.actions[step]
            a = first.apply(a, original.action, original.actual_parameters)
            b = second.apply(b, translated.action, translated.actual_parameters)
            if a is None or b is None:
                return {'status': 'inapplicable_step', 'step': step + 1, 'comparisons': comparisons,
                    'native_applicable': a is not None, 'mapped_applicable': b is not None}
    return {'status': 'equal' if not mismatches else 'mismatches', 'states': len(source_plan.actions) + 1,
        'comparisons': comparisons, 'source_ground_atoms': len(atoms), 'mismatches': mismatches, 'examples': examples}


def run(protocol_path, output):
    require_empty_output(output)
    read = lambda path: json.loads(path.read_text(encoding='utf-8'))
    protocol = read(protocol_path)
    compiled, source_run = Path(protocol['compiled']), Path(protocol['source_run'])
    if digest(compiled / 'meta_domain.pddl') != protocol['domain_sha256'] or digest(compiled / 'meta_domain.json') != protocol['metadata_sha256']:
        raise ValueError('Fixed live model drift')
    if digest(source_run / 'manifest.json') != protocol['source_manifest_sha256'] or digest(source_run / 'report.json') != protocol['source_report_sha256']:
        raise ValueError('Historical witness run drift')
    native_manifest, native_report, metadata = read(source_run / 'manifest.json'), read(source_run / 'report.json'), read(compiled / 'meta_domain.json')
    if native_report['status'] != 'complete' or native_manifest['mode'] != 'original_source_tasks' or native_report['manifest_sha256'] != digest(source_run / 'manifest.json'):
        raise ValueError('Complete native original-goal witness run required')
    native_tasks = {row['id']: row for row in native_manifest['tasks']}
    indexed = {row['id']: row for row in native_report['rows']}
    if len(native_tasks) != 15 or set(native_tasks) != set(indexed) or set(native_tasks) != set(metadata['sources']):
        raise ValueError('Complete15-source denominator required')
    output.mkdir(parents=True)
    (output / 'protocol.json').write_bytes(protocol_path.read_bytes())
    (output / 'model').mkdir()
    for name in ('meta_domain.pddl', 'meta_domain.json'):
        (output / 'model' / name).write_bytes((compiled / name).read_bytes())
    (output / 'inputs').mkdir()
    (output / 'worlds').mkdir()
    tasks = []
    for source, task in native_tasks.items():
        original = source_run / 'tasks' / source
        for name, suffix in (('domain', '_domainfile.pddl'), ('problem', '_problemfile.pddl')):
            path = original / (name + '.pddl')
            if digest(path) != task[name + '_sha256']:
                raise ValueError('Native witness input drift')
            (output / 'inputs' / (source + suffix)).write_bytes(path.read_bytes())
        if metadata['source_sha256'][source + '_domainfile.pddl'] != task['domain_sha256']:
            raise ValueError('Model and native source differ')
        row = {'id': source, 'source_search_status': indexed[source]['status'], 'admission_status': 'no_original_plan_evidence'}
        if indexed[source]['status'] == 'solved':
            world = output / 'worlds' / source
            world.mkdir()
            query = convert_problem(source, original / 'domain.pddl', original / 'problem.pddl')
            save(world / 'query.json', query)
            mapping = map_problem(query, output / 'model', world / 'problem.pddl')
            save(world / 'query_mapping.json', mapping)
            row.update(admission_status='ready', native_plan_sha256=digest(original / 'plan.txt'),
                mapped_problem_sha256=digest(world / 'problem.pddl'))
        tasks.append(row)
    implementation = snapshot_implementation(output, [Path(__file__), Path('scripts/experiments/run_union_regression.py'),
        Path('scripts/experiments/run_original_world_pipeline.py'), Path('rcnc/narrative_pipeline.py'),
        Path('rcnc/validation.py'), Path('rcnc/aligned_domain.py'), Path('rcnc/domain_union.py'),
        Path('rcnc/domain_building.py'), Path('rcnc/pddl.py'), Path('rcnc/pddl_checks.py')])
    files = [path for path in output.rglob('*') if path.is_file() and 'implementation' not in path.relative_to(output).parts]
    manifest = {'status': 'frozen_before_trace_replay', 'tasks': tasks, 'task_count': 15,
        'input_sha256': {path.relative_to(output).as_posix(): digest(path) for path in files},
        'implementation_sha256': implementation, 'budget': protocol['budget'], 'native_budget': native_manifest['budget'],
        'scope': protocol['scope']}
    save(output / 'manifest.json', manifest)
    rows, spent = [], 0
    for task in tasks:
        row = dict(task)
        if task['admission_status'] != 'ready':
            row['status'] = task['admission_status']
        else:
            source = task['id']
            original, world = source_run / 'tasks' / source, output / 'worlds' / source
            try:
                if digest(original / 'plan.txt') != task['native_plan_sha256']:
                    raise ValueError('Original plan changed after freeze')
                row['native_revalidation'] = validate_artifacts(original)
                if row['native_revalidation']['status'] != 'VALID':
                    raise ValueError('Original plan fails fresh validation')
                mapping = read(world / 'query_mapping.json')
                row['mapped'] = translate_plan(source, output / 'inputs', output / 'model', original,
                    output / 'replays' / source, problem_path=world / 'problem.pddl', object_map=mapping['objects'])
                row['truth_projection'] = compare_states(original, output / 'replays' / source, source, metadata,
                    mapping, protocol['budget']['max_total_atom_comparisons'] - spent)
                spent += row['truth_projection']['comparisons']
                row['status'] = 'validated_equal' if row['mapped']['validation']['status'] == 'VALID' and row['truth_projection']['status'] == 'equal' else 'replayed_with_limit_or_failure'
            except Exception as exc:
                row.update(status='replay_error', reason=f'{type(exc).__name__}: {exc}')
        rows.append(row)
        save(output / 'progress.json', {'processed': len(rows), 'task_count': 15, 'rows': rows})
    result = {'status': 'complete', 'task_count': 15, 'rows': rows,
        'status_counts': dict(Counter(row['status'] for row in rows)),
        'available_source_plans': sum(task['admission_status'] == 'ready' for task in tasks),
        'source_atom_comparisons': spent, 'validated_equal_plans': sum(row['status'] == 'validated_equal' for row in rows),
        'manifest_sha256': digest(output / 'manifest.json'),
        'inputs_unchanged': all(digest(output / path) == expected for path, expected in manifest['input_sha256'].items()),
        'implementation_unchanged': all(digest(Path(path)) == expected for path, expected in implementation.items()),
        'compiled_model_unchanged': digest(compiled / 'meta_domain.pddl') == protocol['domain_sha256'] and digest(compiled / 'meta_domain.json') == protocol['metadata_sha256'],
        'new_solver_or_model_calls': 0, 'independent_semantic_labels': 0, 'scope': protocol['scope']}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--protocol', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = run(args.protocol, args.output)
    print(json.dumps({key: value for key, value in result.items() if key != 'rows'}, indent=2))

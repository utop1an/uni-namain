"""Freeze and run source-only forward/reverse walks on 15 known worlds."""
import argparse
from collections import Counter
import copy
import json
from pathlib import Path
import subprocess
import sys
import time

from rcnc.bidirectional_replay import replay_directions
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def normalize_mapping(mapping):
    """Match the PDDL reader's case-insensitive names without hiding collisions."""
    from rcnc.namespace_export import fold_symbol_map
    result = {**mapping, 'objects': fold_symbol_map(mapping['objects']),
              'predicates': fold_symbol_map(mapping['predicates']), 'actions': {}, 'orders': {}}
    for name, binding in mapping['actions'].items():
        value = {**binding, 'target': binding['target'].lower()}
        if name.lower() in result['actions'] and result['actions'][name.lower()] != value:
            raise ValueError('Conflicting case-insensitive action bindings')
        result['actions'][name.lower()] = value
    for name, order in mapping.get('orders', {}).items():
        if name.lower() in result['orders'] and result['orders'][name.lower()] != order:
            raise ValueError('Conflicting case-insensitive predicate orders')
        result['orders'][name.lower()] = order
    return result


def prepare(protocol_path, output):
    from rcnc.aligned_domain import build
    from rcnc.narrative_pipeline import map_problem
    from rcnc.pddl import parse_domain, typed_symbols
    from scripts.experiments.run_original_world_pipeline import convert_problem
    protocol = read(protocol_path)
    require_empty_output(output)
    output.mkdir(parents=True)
    save(output / 'protocol.json', protocol)
    inputs = output / 'inputs'
    inputs.mkdir()
    for filename, expected in protocol['source_sha256'].items():
        origin = Path(protocol['inputs']) / filename
        if digest(origin) != expected:
            raise ValueError('Source drift')
        (inputs / filename).write_bytes(origin.read_bytes())
    alignment = Path(protocol['alignment'])
    if digest(alignment) != protocol['alignment_sha256']:
        raise ValueError('Alignment drift')
    spec = read(alignment)
    save(output / 'alignment.json', spec)
    sources = sorted(p.name.removesuffix('_domainfile.pddl') for p in inputs.glob('*_domainfile.pddl'))
    rows, model_cache = [], {}
    for i, source in enumerate(sources):
        native = parse_domain(inputs / (source + '_domainfile.pddl'))
        query = convert_problem(source, inputs / (source + '_domainfile.pddl'), inputs / (source + '_problemfile.pddl'))
        for size in protocol['pool_sizes']:
            selected = sorted({sources[(i + j) % len(sources)] for j in range(size)})
            for condition in protocol['conditions']:
                identifier = f'{source}__n{size}__{condition}'
                row = {'id': identifier, 'source': source, 'pool_size': size, 'condition': condition,
                       'sources': selected, 'status': 'preparing'}
                rows.append(row)
                try:
                    key = (tuple(selected), condition)
                    if key not in model_cache:
                        model = output / 'models' / f'model_{len(model_cache):03d}'
                        model_cache[key] = model
                        subset = output / 'model_inputs' / model.name
                        subset.mkdir(parents=True)
                        for name in selected:
                            filename = name + '_domainfile.pddl'
                            (subset / filename).write_bytes((inputs / filename).read_bytes())
                        local = copy.deepcopy(spec)
                        # Never truncate a predicate group; omit whole groups
                        # crossing this independently registered pool boundary.
                        local['predicate_groups'] = [g for g in spec['predicate_groups'] if condition == 'machine' and
                            {m['predicate'].split(':')[0] for m in g['members']} <= set(selected)]
                        local['type_groups'] = []
                        for group in spec['type_groups'] if condition == 'machine' else []:
                            members = [m for m in group['members'] if m.split(':')[0] in selected]
                            if len(members) >= 2:
                                local['type_groups'].append({**group, 'members': members})
                        result = build(subset, model, local)
                        if not result['valid']:
                            raise ValueError('Compiled model failed parsing')
                    model = model_cache[key]
                    meta = read(model / 'meta_domain.json')
                    directory = output / 'pairs' / identifier
                    directory.mkdir(parents=True)
                    qm = map_problem(query, model, directory / 'target_problem.pddl')
                    mapping = {'objects': {**meta['constant_maps'][source], **qm['objects']},
                        'predicates': meta['predicate_maps'][source], 'orders': meta['predicate_orders'][source],
                        'actions': {name: {'target': mapped, 'positions': list(range(len(typed_symbols(dict(zip(native.actions[name][2::2], native.actions[name][3::2]))[':parameters']))))}
                                    for name, mapped in meta['action_maps'][source].items()}}
                    job = {'source_domain': str(inputs / (source + '_domainfile.pddl')),
                        'source_problem': str(inputs / (source + '_problemfile.pddl')),
                        'target_domain': str(model / 'meta_domain.pddl'), 'target_problem': str(directory / 'target_problem.pddl'),
                        'mapping': normalize_mapping(mapping), 'budget': protocol['replay_budget']}
                    job['input_sha256'] = {job[k]: digest(Path(job[k])) for k in ('source_domain', 'source_problem', 'target_domain', 'target_problem')}
                    save(directory / 'job.json', job)
                    row.update(status='ready', job=str(directory / 'job.json'), active_interfaces=len(meta['alignment_specification']['predicate_groups']))
                except Exception as exc:
                    row.update(status='admission_failed', reason=f'{type(exc).__name__}: {exc}')
    implementation = snapshot_implementation(output, [Path(__file__), *Path('rcnc').glob('*.py'),
                                                      Path('scripts/experiments/run_original_world_pipeline.py')])
    pins = {str(p): digest(p) for p in output.rglob('*') if p.is_file()}
    manifest = {'status': 'frozen_before_search', 'rows': rows, 'pair_count': len(rows), 'source_worlds': len(sources),
                'trace_slots': len(rows) * len(replay_directions(protocol['replay_budget'])) * len(protocol['replay_budget']['seeds']), 'input_sha256': pins,
                'implementation_sha256': implementation, 'budget': protocol['replay_budget']}
    save(output / 'manifest.json', manifest)
    return manifest


def worker(job_path, destination):
    from unified_planning.io import PDDLReader
    from rcnc.bidirectional_replay import run_pair
    job = read(job_path)
    try:
        if not all(digest(Path(p)) == h for p, h in job['input_sha256'].items()):
            raise ValueError('Frozen pair drift')
        reader = PDDLReader()
        source = reader.parse_problem(job['source_domain'], job['source_problem'])
        target = reader.parse_problem(job['target_domain'], job['target_problem'])
        report = run_pair(source, target, job['mapping'], job['budget'], lambda r: save(destination, r))
    except Exception as exc:
        report = {'status': 'worker_error', 'reason': f'{type(exc).__name__}: {exc}', 'rows': []}
    save(destination, report)


def execute(output):
    manifest = read(output / 'manifest.json')
    if (output / 'report.json').exists():
        raise ValueError('No outcome-driven rerun')
    for p, h in {**manifest['input_sha256'], **manifest['implementation_sha256']}.items():
        if digest(Path(p)) != h:
            raise ValueError('Frozen dependency drift: ' + p)
    report = {'status': 'running', 'task_count': manifest['pair_count'], 'trace_slots': manifest['trace_slots'], 'rows': []}
    for registered in manifest['rows']:
        row = dict(registered)
        start = time.monotonic()
        if row['status'] == 'ready':
            folder = output / 'runs' / row['id']
            folder.mkdir(parents=True)
            command = [sys.executable, '-X', 'utf8', '-m', 'scripts.experiments.run_bidirectional_scaling',
                       '--job', row['job'], '--output', str(folder / 'report.json')]
            save(folder / 'command.json', command)
            try:
                with (folder / 'worker.log').open('w', encoding='utf-8') as log:
                    result = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT,
                                            timeout=manifest['budget']['seconds'] + 30)
                row['worker_returncode'] = result.returncode
            except subprocess.TimeoutExpired:
                row['status'] = 'supervisor_time_limit'
            receipt = read(folder / 'report.json') if (folder / 'report.json').exists() else {'status': 'missing_worker_receipt', 'rows': []}
            if row['status'] == 'ready':
                row['status'] = receipt['status']
            row['receipt'] = str(folder / 'report.json')
            row['receipt_sha256'] = digest(folder / 'report.json') if (folder / 'report.json').exists() else None
            row['trace_counts'] = dict(Counter(r['status'] for r in receipt['rows']))
            row['completed_steps'] = sum(r.get('steps', 0) for r in receipt['rows'])
            row['truth_checks'] = sum(r.get('truth_checks', 0) for r in receipt['rows'])
        row['elapsed_seconds'] = round(time.monotonic() - start, 3)
        report['rows'].append(row)
        save(output / 'report.json', report)
        print(json.dumps({k: row.get(k) for k in ('id', 'status', 'trace_counts', 'completed_steps')}), flush=True)
    report.update(status='complete', status_counts=dict(Counter(r['status'] for r in report['rows'])),
        inputs_unchanged=all(digest(Path(p)) == h for p, h in manifest['input_sha256'].items()),
        implementation_unchanged=all(digest(Path(p)) == h for p, h in manifest['implementation_sha256'].items()),
        manifest_sha256=digest(output / 'manifest.json'))
    save(output / 'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--protocol', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--job', type=Path)
    parser.add_argument('--execute', action='store_true')
    args = parser.parse_args()
    if args.job:
        worker(args.job, args.output)
    elif args.execute:
        execute(args.output)
    else:
        result = prepare(args.protocol, args.output)
        print(json.dumps({k: result[k] for k in ('status', 'pair_count', 'trace_slots')}))

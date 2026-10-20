"""Freeze original-world matched representations, then run one bounded solver batch."""
import argparse
import importlib.metadata
import json
from pathlib import Path
import platform
import time

from rcnc.aligned_domain import build as build_aligned
from rcnc.domain_building import require_empty_output, save
from rcnc.domain_union import build as build_union
from scripts.experiments.run_downward_reference import run as solve, sha


REPRESENTATIONS = ('source_isolated', 'namespaced_union', 'zero_merge_membership', 'machine_interfaces')


def freeze(inputs, alignment_path, output, seconds=20, memory_mb=4096):
    require_empty_output(output)
    if type(seconds) is not int or seconds < 1 or type(memory_mb) is not int or memory_mb < 64:
        raise ValueError('Invalid resource budgets')
    output.mkdir(parents=True, exist_ok=True)
    snapshot = output / 'inputs'
    snapshot.mkdir()
    sources = sorted(path.name.removesuffix('_domainfile.pddl') for path in inputs.glob('*_domainfile.pddl'))
    if not sources:
        raise ValueError('No source domains')
    for source in sources:
        for suffix in ('domainfile', 'problemfile'):
            path = inputs / (source + '_' + suffix + '.pddl')
            (snapshot / path.name).write_bytes(path.read_bytes())
    spec = json.loads(alignment_path.read_text(encoding='utf-8'))
    if spec.get('decision_basis') != 'machine_hypothesis':
        raise ValueError('Expected explicitly unverified machine hypothesis condition')
    for path in snapshot.glob('*_domainfile.pddl'):
        if spec['source_sha256'].get(path.name) != sha(path):
            raise ValueError('Alignment has different source snapshot')
    save(output / 'alignment.json', spec)
    zero = {'version': 1, 'decision_basis': 'authored_assumption',
            'source_sha256': spec['source_sha256'], 'predicate_groups': [], 'type_groups': []}
    save(output / 'zero_alignment.json', zero)
    code = [Path(__file__), Path('scripts/experiments/run_downward_reference.py'),
            *sorted(Path('rcnc').glob('*.py'))]
    implementation = {str(path): sha(path) for path in code}
    manifest = {'status': 'preparing_no_search', 'mode': 'matched_source_representations',
        'source_count': len(sources), 'representations': list(REPRESENTATIONS),
        'planned_task_count': len(sources) * len(REPRESENTATIONS),
        'source_sha256': {path.name: sha(path) for path in sorted(snapshot.glob('*.pddl'))},
        'alignment_sha256': sha(output / 'alignment.json'),
        'implementation_sha256': implementation, 'tasks': [],
        'budget': {'wall_seconds': seconds, 'overall_cpu_seconds': seconds, 'memory_mb': memory_mb,
                   'workers': 1, 'planned_solver_wall_seconds': seconds * len(sources) * len(REPRESENTATIONS)},
        'search_order': 'source name, then representation; no randomized order or speedup significance claim',
        'runtime': {'python': platform.python_version(), 'platform': platform.platform(),
                    'unified_planning': importlib.metadata.version('unified-planning')},
        'world_policy': 'Each exact original world and goal mapped separately. Foreign source initial facts never pooled; source constants stay distinct.',
        'scope': 'Observed local development domains; original-goal search comparison, not independent interface semantics or narrative quality'}
    save(output / 'preparation.json', manifest)
    builders = {'namespaced_union': lambda path: build_union(snapshot, path),
                'zero_merge_membership': lambda path: build_aligned(snapshot, path, zero),
                'machine_interfaces': lambda path: build_aligned(snapshot, path, spec)}
    construction = {}
    for representation, builder in builders.items():
        start = time.monotonic()
        result = builder(output / 'models' / representation)
        if not result['valid']:
            raise ValueError('Independent compilation check failed: ' + representation)
        construction[representation] = {'seconds': time.monotonic() - start, 'validation': result}
    save(output / 'construction.json', construction)
    bundle = output / 'bundle'
    for source in sources:
        for representation in REPRESENTATIONS:
            key = source + '__' + representation
            directory = bundle / 'tasks' / key
            directory.mkdir(parents=True)
            domain = (snapshot / (source + '_domainfile.pddl') if representation == 'source_isolated'
                      else output / 'models' / representation / 'meta_domain.pddl')
            problem = (snapshot / (source + '_problemfile.pddl') if representation == 'source_isolated'
                       else output / 'models' / representation / 'problems' / (source + '_problemfile.pddl'))
            for path, name in ((domain, 'domain.pddl'), (problem, 'problem.pddl')):
                (directory / name).write_bytes(path.read_bytes())
            manifest['tasks'].append({'id': key, 'source': source, 'representation': representation,
                'domain_sha256': sha(directory / 'domain.pddl'), 'problem_sha256': sha(directory / 'problem.pddl')})
    manifest.update(status='frozen_before_search', task_count=len(manifest['tasks']))
    if manifest['task_count'] != manifest['planned_task_count']:
        raise ValueError('Task denominator changed')
    save(bundle / 'manifest.json', manifest)
    return manifest


def run(inputs, alignment_path, output, planner, seconds=20, memory_mb=4096):
    manifest = freeze(inputs, alignment_path, output, seconds, memory_mb)
    frozen = sha(output / 'bundle/manifest.json')
    result = solve(inputs, None, output / 'solver', planner, seconds, memory_mb,
                   task_bundle=output / 'bundle')
    result['matched_protocol_unchanged'] = sha(output / 'bundle/manifest.json') == frozen
    result['construction_implementation_unchanged'] = all(sha(Path(name)) == value
        for name, value in manifest['implementation_sha256'].items())
    result['scope'] = manifest['scope']
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inputs', type=Path, default=Path('data/narra-domains'))
    parser.add_argument('--alignment', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--planner', type=Path, default=Path('.tmp/fast-downward-26.6'))
    parser.add_argument('--seconds', type=int, default=20)
    parser.add_argument('--memory-mb', type=int, default=4096)
    args = parser.parse_args()
    result = run(args.inputs, args.alignment, args.output, args.planner, args.seconds, args.memory_mb)
    print(json.dumps({k: v for k, v in result.items() if k != 'rows'}, indent=2))

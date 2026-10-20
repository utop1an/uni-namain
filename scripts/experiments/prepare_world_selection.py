"""Freeze all original worlds under static-universe source selection."""
import argparse
import json
from pathlib import Path
from rcnc.aligned_domain import build
from rcnc.domain_building import require_empty_output, save
from rcnc.pddl import parse_domain, parse_sexpr
from rcnc.world_source_selection import select_component
from scripts.experiments.run_downward_reference import sha


def prepare(matched, output, previous_selection=None):
    require_empty_output(output)
    output.mkdir(parents=True)
    model = matched / 'models/machine_interfaces'
    meta = json.loads((model / 'meta_domain.json').read_text(encoding='utf-8'))
    for path, digest in meta['implementation_sha256'].items():
        resolved = Path(path) if Path(path).exists() else Path('rcnc') / path
        if sha(resolved) != digest:
            raise ValueError('Compiled-model implementation changed: ' + path)
    for name, digest in meta['source_sha256'].items():
        if sha(matched / 'inputs' / name) != digest:
            raise ValueError('Source snapshot changed: ' + name)
    domain = parse_domain(model / 'meta_domain.pddl')
    original_manifest = json.loads((matched / 'bundle/manifest.json').read_text(encoding='utf-8'))
    originals = {t['source']: t for t in original_manifest['tasks'] if t['representation'] == 'machine_interfaces'}
    tasks = []
    for source in sorted(meta['sources']):
        original_problem = model / 'problems' / (source + '_problemfile.pddl')
        if sha(original_problem) != originals[source]['problem_sha256'] or sha(model / 'meta_domain.pddl') != originals[source]['domain_sha256']:
            raise ValueError('Frozen full-model world changed')
        problem = parse_sexpr(original_problem.read_text(encoding='utf-8'))
        projected, certificate = select_component(meta, domain, problem, source)
        directory = output / 'models' / source
        inputs = directory / 'inputs'
        inputs.mkdir(parents=True)
        for selected in certificate['selected_sources']:
            for suffix in ('domainfile', 'problemfile'):
                name = selected + '_' + suffix + '.pddl'
                (inputs / name).write_bytes((matched / 'inputs' / name).read_bytes())
        save(directory / 'selection_certificate.json', certificate)
        save(directory / 'alignment.json', projected)
        validation = build(inputs, directory / 'compiled', projected)
        if not validation['valid']:
            raise ValueError('Selected model failed independent parsing')
        task_id = source + '__world_selected'
        task_dir = output / 'bundle/tasks' / task_id
        task_dir.mkdir(parents=True)
        compiled = directory / 'compiled'
        (task_dir / 'domain.pddl').write_bytes((compiled / 'meta_domain.pddl').read_bytes())
        (task_dir / 'problem.pddl').write_bytes((compiled / 'problems' / (source + '_problemfile.pddl')).read_bytes())
        tasks.append({'id': task_id, 'source': source, 'representation': 'world_selected',
            'selected_sources': certificate['selected_sources'],
            'domain_sha256': sha(task_dir / 'domain.pddl'), 'problem_sha256': sha(task_dir / 'problem.pddl'),
            'certificate_sha256': sha(directory / 'selection_certificate.json')})
        if previous_selection is not None:
            previous = json.loads((previous_selection / 'bundle/manifest.json').read_text(encoding='utf-8'))
            prior = next(t for t in previous['tasks'] if t['source'] == source)
            prior_dir = previous_selection / 'bundle/tasks' / prior['id']
            new_id = source + '__graph_closure_control'
            control = output / 'bundle/tasks' / new_id
            control.mkdir(parents=True)
            for name in ('domain', 'problem'):
                if sha(prior_dir / (name + '.pddl')) != prior[name + '_sha256']:
                    raise ValueError('Previous control inputs changed')
                (control / (name + '.pddl')).write_bytes((prior_dir / (name + '.pddl')).read_bytes())
            tasks.append({**prior, 'id': new_id, 'representation': 'graph_closure_control',
                          'origin_task_id': prior['id']})
    manifest = {'status': 'frozen_before_search', 'mode': 'matched_source_representations',
        'task_count': len(tasks), 'tasks': tasks, 'seconds_per_task': 20, 'memory_mb': 4096, 'workers': 1,
        'origin_manifest_sha256': sha(matched / 'bundle/manifest.json'),
        'implementation_sha256': {str(p): sha(p) for p in (Path(__file__), Path('rcnc/world_source_selection.py'))},
        'scope': 'Exploratory follow-up; all original worlds/goals retained; no new identities or initial facts; whole source domains'}
    save(output / 'bundle/manifest.json', manifest)
    return manifest


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--matched', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--previous-selection', type=Path)
    args = parser.parse_args()
    result = prepare(args.matched, args.output, args.previous_selection)
    print(json.dumps({k: v for k, v in result.items() if k != 'tasks'}, indent=2))

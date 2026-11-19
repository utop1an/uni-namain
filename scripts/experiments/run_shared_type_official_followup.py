"""Fresh physical comparison on the previously frozen official matched cohort.

Reuses official model generation, not its old search outcomes. Uses native
Glaive without intentions for all three arms; this is a new budget/solver
condition, separate from the historical Fast Downward physical comparison.
"""
import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor, as_completed
from copy import deepcopy
from pathlib import Path
import random
import shutil
import sys

from rcnc.causal_attribution import VERSION, file_digest, value_digest
from rcnc.glaive_merge import action_fields
from rcnc.glaive_intake import formula_terms
from rcnc.pddl import parse_sexpr, section, serialize, typed_symbols
from rcnc.shared_types import SharedTypes
from scripts.experiments.run_matched_unidomain_rule import physical_domain, physical_problem, physical_effect
from scripts.experiments.run_shared_type_tables import (ROOT, ARCHIVE, JAVA, JAR, read, write, digest, check,
                                                       run_task)

PREVIOUS = ARCHIVE / 'validation/official_unidomain_table234_physical_comparison_2026_11_15_v4'


def tree(path):
    return parse_sexpr(Path(path).read_text(encoding='utf-8'))


def shared_official_types(d, p, primary_task):
    """Lower the SAME canonical types to origin-free static type predicates.

    The official exporter uses untyped parameters. Its source-membership guards
    are an adapter convention, not learned predicates. Replace that convention
    using the frozen ontology and the explicit native world's declarations.
    """
    meta = read(primary_task['mapping'])
    types = SharedTypes.from_metadata(meta)
    guards = {sid + '_type_' + typ: 'semantic_type_' + target
              for sid, mapping in types.maps.items() for typ, target in mapping.items()}
    def rewrite(x):
        if not isinstance(x, list):
            return x
        return [guards.get(v, v) if isinstance(v, str) else rewrite(v) for v in x]
    d = rewrite(d)
    definitions = section(d, ':predicates')
    definitions[:] = [':predicates', *{serialize(a): a for a in definitions[1:]}.values()]
    declared = {a[0] for a in definitions[1:]}
    for typ in types.ancestors:
        name = 'semantic_type_' + typ
        if name not in declared:
            definitions.append([name, '?x', '-', 'object'])
    world = tree(primary_task['problem'])
    objects = typed_symbols((section(world, ':objects') or [':objects'])[1:])
    objects.update(meta.get('shared_constant_types', {}))
    actual = typed_symbols((section(p, ':objects') or [':objects'])[1:])
    actual.update(typed_symbols((section(d, ':constants') or [':constants'])[1:]))
    unknown = set(actual) - set(objects)
    if unknown:
        raise ValueError('Official objects lack frozen canonical typings: ' + ', '.join(sorted(unknown)))
    initial = section(p, ':init')
    initial[:] = [':init', *[a for a in initial[1:] if a[0] not in guards]]
    for obj in sorted(actual):
        initial.extend([['semantic_type_' + typ, obj] for typ in types.ancestors[objects[obj]]])
    return d, p


def native_physical(domain, problem, folder, *, official_task=None):
    d, p = physical_domain(tree(domain)), physical_problem(tree(problem))
    if official_task is not None:
        d, p = shared_official_types(d, p, official_task)
    if section(d, ':types') is None:
        d.insert(3, [':types'])
    req = section(d, ':requirements')
    if ':intentionality' not in req:
        req.append(':intentionality')
    for a in d:
        if not isinstance(a, list) or not a or a[0] != ':action':
            continue
        f = action_fields(a)
        used = set(formula_terms(f[':precondition'])) | set(formula_terms(f[':effect']))
        unused = [v for v in typed_symbols(f[':parameters']) if v not in used]
        if unused:
            pre = ['and', f[':precondition'], *[['=', v, v] for v in unused]]
            if ':precondition' in a:
                a[a.index(':precondition') + 1] = pre
            else:
                a.extend([':precondition', pre])
    p = [x for x in p if not isinstance(x, list) or not x or x[0] != ':requirements']
    folder.mkdir(parents=True)
    (folder / 'domain.pddl').write_text(serialize(d) + '\n', encoding='utf-8')
    (folder / 'problem.pddl').write_text(serialize(p) + '\n', encoding='utf-8')


def prepare(primary, output):
    if output.exists():
        raise ValueError('Fresh output directory required')
    output.mkdir(parents=True)
    old = read(PREVIOUS / 'report.json')
    # Every historical eligibility/failure row is retained. The comparison is
    # explicitly on a frozen matched cohort, not a new post-search subset.
    write(output / 'historical_admission.json', [
        {k: r[k] for k in ('id', 'key', 'kind', 'group', 'status', 'fusion_status') if k in r}
        for r in old['rows']])
    primary_rows = read(primary / 'registry.json')
    lookup = {(r['group'], r['condition'], r.get('world')): r for r in primary_rows}
    manifest = {r['id']: r for r in read(PREVIOUS / 'bundle/manifest.json')['tasks']}
    tasks, inputs = [], {str(PREVIOUS / 'report.json'): digest(PREVIOUS / 'report.json'),
                         str(PREVIOUS / 'bundle/manifest.json'): digest(PREVIOUS / 'bundle/manifest.json')}
    for r in old['rows']:
        if r['status'] != 'ready':
            continue
        for arm, new_arm in [('union', 'union'), ('narrafuse', 'full'), ('official_unidomain', 'official_unidomain')]:
            tid = r['id'] + '__' + arm
            kind = {'composition': 'composition', 'anchor': 'original_goal', 'transport': 'reference'}[r['kind']]
            world = r['key'][2] if len(r['key']) > 1 else None
            src = lookup[(r['group'], 'full' if arm == 'official_unidomain' else new_arm, world)]
            folder = output / 'inputs' / tid
            t = {**src, 'id': tid, 'condition': new_arm, 'kind': kind, 'physical_only': True,
                 'domain': str(folder / 'domain.pddl'), 'problem': str(folder / 'problem.pddl'),
                 'mapping': str(folder / 'mapping.json'), 'provenance': str(folder / 'provenance.json')}
            if arm == 'official_unidomain':
                original = PREVIOUS / ('replay/tasks' if kind == 'reference' else 'bundle/tasks') / tid
                domain, problem = original / 'domain.pddl', original / 'problem.pddl'
                if kind != 'reference':
                    for key in ('domain', 'problem'):
                        if digest(original / (key + '.pddl')) != manifest[tid][key + '_sha256']:
                            raise ValueError('Frozen official input mismatch')
            else:
                domain, problem = Path(src['domain']), Path(src['problem'])
            if t['status'] == 'ready':
                try:
                    inputs.update({str(f): digest(f) for f in (domain, problem)})
                    native_physical(domain, problem, folder, official_task=src if arm == 'official_unidomain' else None)
                    if arm == 'official_unidomain':
                        lin = PREVIOUS / 'projection' / r['group'] / 'lineage.json'
                        inputs[str(lin)] = digest(lin)
                        mapping = {'action_maps': {sid + ':' + name: {'name': target, 'order': order}
                                    for sid, name, target, order in read(lin)['actions']}}
                        # Multi-source rewrites lack verified branch certificates:
                        # attribution remains unknown instead of guessing origins.
                        provenance = {'version': VERSION, 'actions': {}}
                    else:
                        mapping = read(src['mapping'])
                        provenance = deepcopy(read(src['provenance']))
                        for entry in provenance['actions'].values():
                            for branch in entry['branches']:
                                branch['agents'] = []
                                branch['effect'] = physical_effect(branch['effect'])
                    provenance.update(domain_sha256=file_digest(folder / 'domain.pddl'),
                                      mapping_digest=value_digest(mapping))
                    write(folder / 'mapping.json', mapping)
                    write(folder / 'provenance.json', provenance)
                    if kind == 'reference':
                        t['plan'] = str(folder / 'plan.pddl')
                        if arm == 'official_unidomain':
                            oldplan = original / 'plan.txt'
                            inputs[str(oldplan)] = digest(oldplan)
                            calls = [parse_sexpr(line) for line in oldplan.read_text(encoding='utf-8').splitlines()
                                     if line.strip() and not line.lstrip().startswith(';')]
                            plan = ['define', ['plan', 'transport'], [':problem', section(tree(problem), 'problem')[1]], [':steps', *calls]]
                            Path(t['plan']).write_text(serialize(plan) + '\n', encoding='utf-8')
                        else:
                            inputs[src['plan']] = digest(Path(src['plan']))
                            shutil.copyfile(src['plan'], t['plan'])
                except Exception as exc:
                    t.update(status='physical_export_unsupported', reason=type(exc).__name__ + ': ' + str(exc))
            tasks.append(t)
    write(output / 'registry.json', tasks)
    for directory in ('rcnc', 'scripts'):
        for f in (ROOT / directory).rglob('*.py'):
            target = output / 'code' / f.relative_to(ROOT)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(f, target)
    files = [p for p in output.rglob('*') if p.is_file()]
    with ThreadPoolExecutor(max_workers=8) as pool:
        inputs.update(zip(map(str, files), pool.map(digest, files)))
    inputs.update({str(p): digest(p) for p in (JAVA, JAR)})
    counts = dict(Counter(t['kind'] for t in tasks))
    if counts != {'composition': 120, 'original_goal': 480, 'reference': 330}:
        raise ValueError('Matched cohort denominator changed: ' + str(counts))
    write(output / 'protocol.json', {'condition': 'fresh_physical_shared_type_frozen_matched_cohort',
        'counts': counts, 'input_sha256': inputs, 'java': str(JAVA), 'jar': str(JAR),
        'search_seconds': 60, 'native_replay_seconds': 60, 'independent_check_seconds': 60,
        'attribution_seconds': 60, 'heap_mb': 4096, 'workers': 1,
        'max_interpretations': 4096, 'max_supports': 256, 'shuffle_seed': 20261119,
        'scope': 'Frozen 80-group matched cohort: 40 composition, 160 original-goal and 110 reference queries per arm. All historical admission failures retained separately. Official generated roots are reused; their export adapter source-membership guards are replaced by static canonical type predicates instantiated from the same explicit native world. This is a shared-type export adaptation, not a rerun of official model generation. Union and NarraFuse use native shared parameters. Fresh Glaive physical search for all arms, not the old 5-second Fast Downward condition. No intention-validity claim.'})
    print(counts, flush=True)


def run(output):
    spec = read(output / 'protocol.json')
    check(spec)
    with (output / 'started.json').open('x', encoding='utf-8') as f:
        f.write('fresh\n')
    tasks = read(output / 'registry.json')
    random.Random(spec['shuffle_seed']).shuffle(tasks)
    rows = []
    for t in tasks:
        folder = output / 'runs' / t['id']
        try:
            row = run_task(spec, t, folder)
        except Exception as exc:
            row = {**t, 'status': 'runner_error', 'reason': str(exc), 'dual_pass': False, 'native_pass': False}
            write(folder / 'result.json', row)
        rows.append(row)
        if len(rows) % 10 == 0 or len(rows) == 1:
            write(output / 'progress.json', {'status': 'running', 'completed': len(rows), 'registered': len(tasks)})
    check(spec)
    counts = Counter((r['kind'], r['condition'], r['status']) for r in rows)
    report = {'status': 'complete_shared_type_matched_physical', 'registered': len(rows), 'inputs_unchanged': True,
              'counts': [{'kind': k, 'method': a, 'status': s, 'count': n} for (k, a, s), n in sorted(counts.items())], 'rows': rows}
    write(output / 'report.json', report)
    write(output / 'progress.json', {k: v for k, v in report.items() if k != 'rows'})


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('mode', choices=('prepare', 'run'))
    p.add_argument('--primary', type=Path)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    if a.mode == 'prepare':
        prepare(a.primary.resolve(), a.output.resolve())
    else:
        run(a.output.resolve())

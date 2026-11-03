"""Frozen native and compiled development checks before held-out execution."""
from collections import Counter
from datetime import datetime, timezone
import argparse
import json
from pathlib import Path

from rcnc.domain_building import digest, save, snapshot_implementation
from rcnc.glaive_merge import Source, build, map_problem, translate_plan
from rcnc.glaive_runtime import invoke

INTAKE = Path('data/external/there_and_back_gpt4_revised_2026_11_01_v1')
ADMISSION = Path('data/validation/revised_native_admission_2026_11_01_v1/report.json')
CLASSES = Path('.tmp/glaive_classes_v1')
JAR = INTAKE / 'upstream/there_and_back/glaive/Glaive/glaive.jar'


def read(p): return json.loads(Path(p).read_text(encoding='utf-8'))


def paths(row):
    folder = INTAKE / 'upstream/results/runs' / row['upstream_id']
    return folder / 'revised-domain.pddl', folder / 'revised-problem.pddl'


def prepare(root):
    if root.exists(): raise ValueError('Fresh directory required')
    root.mkdir(parents=True)
    sources, rows = [], []
    # Verify every acquired source before preparing any task.
    for x in read(INTAKE / 'download_report.json')['files']:
        if digest(INTAKE / 'upstream' / x['path']) != x['sha256']: raise ValueError('Changed upstream file')
    for x in read(ADMISSION)['rows']:
        if x['split'] != 'development': continue
        r = {k: x[k] for k in ('id', 'upstream_id', 'split', 'status')}
        if x['status'] == 'parsed':
            try:
                s = Source(x['id'], *paths(x)); m = build([s], root / 'models' / s.id)
                map_problem([s], s.id, m, root / 'models' / s.id / 'problem.pddl')
                sources.append(s); r['adapter'] = 'compiled'
            except (ValueError, KeyError, TypeError) as exc: r.update(adapter='unsupported', reason=str(exc))
        rows.append(r)
    # A two-source intentional fixture tests actual action fusion and reversed roles.
    from tests.test_glaive_merge import fixture, environment_fixture
    froot = root / 'fixture'; froot.mkdir()
    fs, groups = fixture(froot)
    fm = build(fs, froot / 'merged', groups=groups, merge_actions=True)
    for s in fs: map_problem(fs, s.id, fm, froot / 'merged' / (s.id + '.pddl'))
    es, eg = environment_fixture(froot)
    em = build(es, froot / 'environment_merged', groups=eg, merge_actions=True)
    for s in es: map_problem(es, s.id, em, froot / 'environment_merged' / (s.id + '.pddl'))
    protocol = {'status': 'frozen_before_search', 'created_utc': datetime.now(timezone.utc).isoformat(),
                'rows': rows, 'seconds_each': 30, 'replay_seconds': 15, 'attempts': 1, 'workers': 1,
                'model_calls': 0, 'native_admission_sha256': digest(ADMISSION),
                'gate': 'No compiled parser error; all available ordinary native plans must transport with goal and no unexplained steps; at least three distinct original goals available. Non-executed counterfactual plan markers are explicitly unavailable to this replay adapter. Both authored intentional fusion branches must pass.',
                'claim_scope': 'Development engineering and native intention replay; no independent semantic or narrative labels.'}
    files = [p for p in root.rglob('*') if p.is_file()]
    for x in rows:
        if x['status'] == 'parsed': files.extend(paths(x))
    files += [JAR, CLASSES / 'GlaiveProbe.class']
    protocol['input_sha256'] = {str(p): digest(p) for p in files}
    protocol['implementation_sha256'] = snapshot_implementation(root, [Path(__file__), Path('rcnc/glaive_merge.py'),
        Path('rcnc/glaive_runtime.py'), Path('scripts/java/GlaiveProbe.java'), Path('tests/test_glaive_merge.py')])
    save(root / 'protocol.json', protocol)
    return {'development_sources': len(rows), 'native_tasks': sum(r['status']=='parsed' for r in rows),
            'adapted_tasks': len(sources), 'fixture_sources': 4}


def replay(domain, problem, plan, output, seconds=15):
    if 'non-executed' in plan.read_text(encoding='utf-8'):
        result = {'status': 'unavailable_counterfactual_plan_format', 'search_calls': 0}
        output.mkdir(parents=True); save(output / 'result.json', result); return result
    return invoke(JAR, domain, problem, output, mode='replay', seconds=seconds, classes=CLASSES, plan=plan)


def passed(r):
    return r.get('status') == 'replayed' and r.get('goal') is True and r.get('unexplained_steps') == 0


def execute(root):
    protocol = read(root / 'protocol.json')
    if (root / 'progress.json').exists(): raise ValueError('Fresh execution only, no continuation')
    for path, h in {**protocol['input_sha256'], **protocol['implementation_sha256']}.items():
        if digest(Path(path)) != h: raise ValueError('Frozen input changed: ' + path)
    rows = []
    for row in protocol['rows']:
        r = dict(row)
        if row['status'] == 'parsed':
            domain, problem = paths(row); out = root / 'execution' / row['id']
            native = invoke(JAR, domain, problem, out / 'native', seconds=30)
            r['native'] = native
            if native['status'] == 'solved':
                r['native_replay'] = replay(domain, problem, out / 'native/plan.pddl', out / 'native_replay')
            if row.get('adapter') == 'compiled':
                model = root / 'models' / row['id']; md, mp = model / 'domain.pddl', model / 'problem.pddl'
                r['compiled'] = invoke(JAR, md, mp, out / 'compiled', seconds=30)
                if r['compiled']['status'] == 'solved':
                    r['compiled_replay'] = replay(md, mp, out / 'compiled/plan.pddl', out / 'compiled_replay')
                if native['status'] == 'solved':
                    s = Source(row['id'], domain, problem); terms = {**s.term_map, **{o: s.id + '_o_' + o for o in s.objects}}
                    translate_plan(s.id, read(model / 'mapping.json'), terms, out / 'native/plan.pddl', out / 'transport.pddl')
                    r['transport'] = replay(md, mp, out / 'transport.pddl', out / 'transport')
        rows.append(r); save(root / 'progress.json', {'rows': rows}); print(row['id'], {k: r[k]['status'] for k in ('native','compiled','transport') if k in r}, flush=True)
    fixtures = []
    for sid in ('left', 'right', 'nature_left', 'nature_right'):
        f = root / 'fixture'; out = root / 'execution' / ('fixture_' + sid)
        merged = f / ('environment_merged' if sid.startswith('nature_') else 'merged')
        source = Source(sid, f / (sid + '.pddl'), f / (sid + '_problem.pddl'))
        native = invoke(JAR, source.domain_path, source.problem_path, out / 'native', seconds=30)
        r = {'id': sid, 'native': native}
        if native['status'] == 'solved':
            terms = {**source.term_map, **{o: sid + '_o_' + o for o in source.objects}}
            translate_plan(sid, read(merged / 'mapping.json'), terms, out / 'native/plan.pddl', out / 'transport.pddl')
            r['transport'] = replay(merged / 'domain.pddl', merged / (sid + '.pddl'), out / 'transport.pddl', out / 'transport')
        fixtures.append(r)
    available = [r for r in rows if r.get('transport', {}).get('status') != 'unavailable_counterfactual_plan_format' and 'transport' in r]
    errors = [r['id'] for r in rows if r.get('compiled', {}).get('status') in ('native_parse_error','runtime_error')
              or any(not passed(r[k]) for k in ('native_replay', 'compiled_replay', 'transport') if k in r and r[k]['status'] != 'unavailable_counterfactual_plan_format')]
    gate = len(available) >= 3 and not errors and all(passed(r.get('transport', {})) for r in fixtures)
    report = {'status': 'complete', 'gate_passed': gate, 'gate_errors': errors, 'rows': rows, 'fixtures': fixtures,
              'original_transports_available': len(available), 'original_transports_passed': sum(passed(r['transport']) for r in available),
              'counts': {k: dict(Counter(r[k]['status'] for r in rows if k in r)) for k in ('native','compiled','transport')},
              'search_calls': sum(r[k]['search_calls'] for r in rows + fixtures for k in ('native','compiled') if k in r), 'model_calls': 0,
              'inputs_unchanged': all(digest(Path(path)) == h for path,h in protocol['input_sha256'].items()),
              'implementation_unchanged': all(digest(Path(path)) == h for path,h in protocol['implementation_sha256'].items())}
    save(root / 'report.json', report)
    return {k: v for k, v in report.items() if k not in ('rows','fixtures')}


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__); p.add_argument('mode', choices=['prepare','execute']); p.add_argument('--output', type=Path, required=True)
    a = p.parse_args(); print(json.dumps(globals()[a.mode](a.output), indent=2))

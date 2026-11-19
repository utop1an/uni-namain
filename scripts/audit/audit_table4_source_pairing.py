"""Audit eligible original-world tasks and match their archived source outcomes."""

import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path

from rcnc.glaive_intake import casefold_tree
from rcnc.pddl import parse_sexpr, section


def audit(origin, initial, final, output):
    if output.exists():
        raise FileExistsError(output)
    hashes = {}

    def pin(path):
        path = Path(path).resolve()
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        if str(path) in hashes and hashes[str(path)] != digest:
            raise ValueError(f'Input changed: {path}')
        hashes[str(path)] = digest
        return digest

    def read(path):
        pin(path)
        return json.loads(Path(path).read_text(encoding='utf-8'))

    def rows(root, stage):
        return read(root / 'repeat_01' / f'{stage}_report.json')['rows']

    def steps(path):
        pin(path)
        return section(casefold_tree(parse_sexpr(Path(path).read_text(encoding='utf-8'))), ':steps')[1:]

    def paired(records):
        by_condition = {}
        for condition in ('union', 'full'):
            selected = [r for r in records if r['condition'] == condition]
            keyed = {(r['group'], r['source'], r['world']): r for r in selected}
            if len(keyed) != len(selected):
                raise ValueError(f'Duplicate task keys in {condition}')
            by_condition[condition] = keyed
        if by_condition['union'].keys() != by_condition['full'].keys():
            raise ValueError('Union and Full task keys differ')
        return by_condition

    def outcome(row, stage):
        result = row.get(stage, {})
        return {'id': row['id'], 'status': result.get('status', row['status']),
                'seconds': result.get('seconds'), 'dual_pass': bool(row['valid']),
                'native_pass': bool(row['native_valid']),
                'physical_status': row.get('replay', {}).get('physical', {}).get('status')}

    source_worlds = {r['id']: r for r in read(origin / 'baseline_tasks.json')['worlds']}
    admission_rows = {(r['world'], r['condition']): r for r in rows(origin, 'native')}
    registered_references = read(origin / 'repeat_01' / 'references.json')['worlds']
    admitted = {}
    goal_pairs, replay_pairs, coverage = {}, {}, {}

    for label, root in [('initial', initial), ('final', final)]:
        native = {(r['world'], r['condition']): r for r in rows(root, 'native')}
        searches = paired(rows(root, 'anchor'))
        transports = paired(rows(root, 'transport'))
        goal_pairs[label], replay_pairs[label] = [], []
        coverage[label] = Counter()
        for group, source, world in sorted(searches['union']):
            key = (group, source, world)
            definition = source_worlds[world]
            if definition['source'] != source:
                raise ValueError(f'Unbound source world: {key}')
            problem = Path(definition['problem'])
            if not problem.is_file():
                coverage[label]['missing_goal_input'] += 1
                continue
            problem_tree = parse_sexpr(problem.read_text(encoding='utf-8'))
            if section(problem_tree, ':init') is None or section(problem_tree, ':goal') is None:
                coverage[label]['missing_goal_input'] += 1
                continue
            pin(problem)
            coverage[label]['eligible_goal'] += 1
            entry = {'group': group, 'source': source, 'world': world}
            for variant in ('raw', 'adapter'):
                baseline = native[world, variant]
                if baseline['domain'] != definition[f'{variant}_domain'] or baseline['problem'] != definition[f'{variant}_problem']:
                    raise ValueError(f'Source baseline inputs differ: {world}/{variant}')
                pin(baseline['domain'])
                pin(baseline['problem'])
                entry['source_' + variant] = outcome(baseline, 'search')
            entry.update({c: outcome(a[key], 'search') for c, a in searches.items()})
            goal_pairs[label].append(entry)

        for key, union in sorted(transports['union'].items()):
            group, source, world = key
            full = transports['full'][key]
            reference = union['reference']
            if reference != full['reference'] or reference != registered_references[world]:
                raise ValueError(f'Transport reference changed: {key}')
            if reference['status'] != 'available':
                coverage[label]['missing_reference'] += 1
                continue
            variant, level = reference['condition'], reference['validation_level']
            coverage[label][level] += 1
            if world not in admitted:
                baseline = admission_rows[world, variant]
                if baseline['source'] != source or baseline['validation_level'] != level:
                    raise ValueError(f'Wrong source reference admission: {world}')
                plan = Path(baseline['plan'])
                replay_dir = plan.parent.parent / 'replay'
                invocation = read(replay_dir / 'invocation.json')
                result = read(replay_dir / 'checked_result.json')
                if invocation['seconds'] != 15 or invocation['mode'] != 'replay' or result != baseline['replay']:
                    raise ValueError(f'Wrong source replay receipt: {world}')
                for path, expected in invocation['input_sha256'].items():
                    if pin(path) != expected:
                        raise ValueError(f'Changed source replay input: {path}')
                reference_plan = Path(reference['source_plan'])
                if pin(reference_plan) != reference['source_plan_sha256']:
                    raise ValueError(f'Changed reference plan: {world}')
                source_steps = steps(plan)
                if variant == 'adapter':
                    definition = source_worlds[world]
                    mapping = read(definition['adapter_mapping'])
                    actions = mapping['action_maps']
                    reverse_actions = {v['name']: k.split(':', 1)[1] for k, v in actions.items()}
                    terms = definition['adapter_terms']
                    reverse_terms = {v: k for k, v in terms.items()}
                    if (len(reverse_actions) != len(actions) or len(reverse_terms) != len(terms)
                            or any(not k.startswith(source + ':') or v['order'] != list(range(len(v['order'])))
                                   for k, v in actions.items())):
                        raise ValueError(f'Non-invertible source adapter: {world}')
                    source_steps = [[reverse_actions[a], *[reverse_terms[x] for x in args]]
                                    for a, *args in source_steps]
                if source_steps != steps(reference_plan):
                    raise ValueError(f'Source replay and reference use different steps: {world}')
                admitted[world] = {**outcome(baseline, 'replay'), 'reference_representation': variant,
                                   'reference_validation': level, 'budget_seconds': 15,
                                   'invocation': str(replay_dir / 'invocation.json')}
            replay_pairs[label].append({'group': group, 'source': source, 'world': world,
                                        'reference_validation': level, 'source_replay': admitted[world],
                                        'union': outcome(union, 'replay'), 'full': outcome(full, 'replay')})

    for relative, digest in hashes.items():
        if hashlib.sha256(Path(relative).read_bytes()).hexdigest() != digest:
            raise ValueError(f'Input changed during audit: {relative}')

    metrics = {}
    for label in ('initial', 'final'):
        goal = goal_pairs[label]
        replay = replay_pairs[label]
        metrics[label] = {'coverage': dict(coverage[label]), 'distinct_goal_worlds': len({r['world'] for r in goal}),
            'distinct_reference_plans': len({r['world'] for r in replay}),
            'goal_dual_passes': {c: sum(r[c]['dual_pass'] for r in goal)
                                 for c in ('source_raw', 'source_adapter', 'union', 'full')},
            'goal_distinct_source_passes': {c: len({r['world'] for r in goal if r[c]['dual_pass']})
                                            for c in ('source_raw', 'source_adapter')},
            'goal_on_adapter_solved': {c: sum(r[c]['dual_pass'] for r in goal if r['source_adapter']['dual_pass'])
                                       for c in ('union', 'full')},
            'goal_on_adapter_not_solved': {c: sum(r[c]['dual_pass'] for r in goal if not r['source_adapter']['dual_pass'])
                                           for c in ('union', 'full')},
            'replay_by_reference': {level: {c: {
                'native_pass': sum(r[c]['native_pass'] for r in replay if r['reference_validation'] == level),
                'dual_pass': sum(r[c]['dual_pass'] for r in replay if r['reference_validation'] == level)}
                for c in ('source_replay', 'union', 'full')}
                for level in ('dual_validated', 'native_only_physical_unknown')}}
    report = {'status': 'verified_archived_table4_source_pairing', 'metrics': metrics,
              'source_replay_max_seconds': max(r['seconds'] for r in admitted.values()),
              'scope': 'Source replay receipts are the 15-second reference admission checks. They are selected by admission and are not a new synchronized replay benchmark. Source goal-search outcomes are from the corresponding archived stage and are reused across groups containing the same query.',
              'input_sha256': hashes, 'inputs_unchanged': True, 'new_planner_calls': 0, 'model_requests': 0,
              'goal_pairs': goal_pairs, 'replay_pairs': replay_pairs}
    output.mkdir(parents=True)
    with (output / 'report.json').open('x', encoding='utf-8') as stream:
        json.dump(report, stream, ensure_ascii=False, indent=2)
    print(json.dumps({'status': report['status'], 'metrics': metrics,
                      'source_replay_max_seconds': report['source_replay_max_seconds']}, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('origin', 'initial', 'final', 'output'):
        parser.add_argument('--' + name, required=True, type=Path)
    args = parser.parse_args()
    audit(args.origin, args.initial, args.final, args.output)

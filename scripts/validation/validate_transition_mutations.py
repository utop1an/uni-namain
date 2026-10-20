"""Negative controls for the exhaustive compilation checker; preserve originals."""
import argparse
import json
from pathlib import Path
import shutil

from rcnc.pddl import parse_sexpr, section, serialize
from scripts.validation.validate_transition_preservation import audit, digest


def run(original, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    output.mkdir(parents=True, exist_ok=True)
    baseline = audit(original / 'input', original / 'compiled')
    if baseline['status'] != 'PASS':
        raise ValueError('Baseline must pass before testing mutations')
    meta = json.loads((original / 'compiled/meta_domain.json').read_text(encoding='utf-8'))
    rows = []
    for mutation in ('drop_universal_effect_guard', 'flip_add_effect_to_delete', 'reverse_action_arguments', 'admit_foreign_object'):
        directory = output / mutation
        shutil.copytree(original / 'compiled', directory)
        domain_path = directory / 'meta_domain.pddl'
        root = parse_sexpr(domain_path.read_text(encoding='utf-8'))
        name = {'drop_universal_effect_guard': 'finish_all', 'flip_add_effect_to_delete': 'prepare',
                'reverse_action_arguments': 'link'}.get(mutation)
        if name:
            target = meta['action_maps']['A'][name]
            action = next(part for part in root if isinstance(part, list) and part[:2] == [':action', target])
            index = action.index(':effect') + 1
            expr = action[index]
            if mutation == 'drop_universal_effect_guard':
                if expr[0] != 'forall' or expr[2][0] != 'when':
                    raise ValueError('Unexpected universal-effect shape')
                expr[2] = expr[2][2]
            elif mutation == 'flip_add_effect_to_delete':
                action[index] = ['not', expr]
            else:
                expr[1:] = list(reversed(expr[1:]))
            domain_path.write_text(serialize(root) + '\n', encoding='utf-8')
        else:
            problem_path = directory / 'problems/A_problemfile.pddl'
            problem = parse_sexpr(problem_path.read_text(encoding='utf-8'))
            typ = meta['namespaces']['A']['types']['person']
            outsider = meta['constant_maps']['B']['outsider']
            section(problem, ':init').append([meta['type_guards'][typ], outsider])
            problem_path.write_text(serialize(problem) + '\n', encoding='utf-8')
        result = audit(original / 'input', directory)
        (directory / 'audit.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
        rows.append({'mutation': mutation, 'detected': result['status'] == 'FAIL', 'counts': result['counts'],
                     'counterexample_kinds': sorted({r['kind'] for r in result['counterexamples']}),
                     'mutated_domain_sha256': digest(domain_path),
                     'mutated_problem_sha256': digest(directory / 'problems/A_problemfile.pddl')})
        print(json.dumps(rows[-1]), flush=True)
    report = {'status': 'PASS' if all(r['detected'] for r in rows) else 'FAIL',
              'scope': 'Deliberately corrupted synthetic compilation outputs; tests checker sensitivity, not semantic inference',
              'baseline_counts': baseline['counts'], 'original_domain_sha256': digest(original / 'compiled/meta_domain.pddl'),
              'rows': rows, 'implementation_sha256': {p.name: digest(p) for p in
                  [Path(__file__), (Path(__file__).resolve().parents[2] / 'scripts/validation/validate_transition_preservation.py')]}}
    (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    return report


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--original', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    result = run(a.original, a.output)
    raise SystemExit(0 if result['status'] == 'PASS' else 1)

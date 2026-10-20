"""Check finite formula audit sensitivity to missing quantified membership guards."""
import argparse
import shutil
from pathlib import Path

from rcnc.pddl import parse_sexpr, serialize
from scripts.experiments.run_downward_reference import sha, save
from scripts.audit.audit_action_reachability import read
from scripts.validation.validate_transition_preservation import audit
from unified_planning.io import PDDLReader


def erase_quantifier_guards(expr, inside=False):
    if not isinstance(expr, list) or not expr:
        return expr
    if inside and isinstance(expr[0], str) and expr[0].startswith('typeguard__'):
        return ['and']
    if expr[0] in ('forall', 'exists'):
        return [expr[0], expr[1], erase_quantifier_guards(expr[2], True)]
    return [erase_quantifier_guards(x, inside) for x in expr]


def run(origin, output):
    prior = read(origin/'report.json')
    if prior['status'] != 'PASS' or not prior['hashes_unchanged'] or any(sha(Path(p)) != h for p, h in prior['frozen_sha256'].items()):
        raise ValueError('Require unchanged successful positive control')
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use a fresh output directory')
    output.mkdir(parents=True)
    compiled = output/'compiled'
    shutil.copytree(origin/'compiled', compiled)
    path = compiled/'meta_domain.pddl'
    root = parse_sexpr(path.read_text(encoding='utf-8'))
    changes = []
    for action in root:
        if not isinstance(action, list) or not action or action[0] != ':action':
            continue
        index = action.index(':precondition')+1
        before = action[index]
        after = erase_quantifier_guards(before)
        if before != after:
            changes.append({'action': action[1], 'before': before, 'after': after})
            action[index] = after
    if not changes:
        raise ValueError('Mutation changed nothing')
    path.write_text(serialize(root)+'\n', encoding='utf-8')
    PDDLReader().parse_problem(str(path), str(compiled/'problems/A_problemfile.pddl'))
    save(output/'mutation.json', {'changes': changes, 'positive_report_sha256': sha(origin/'report.json'),
        'mutated_domain_sha256': sha(path), 'scope': 'Remove quantified condition membership guards only; action parameter guards remain'})
    result = audit(origin/'inputs', compiled)
    result['mutation_detected'] = result['status'] == 'FAIL' and result['counts']['mismatches'] > 0
    result['changed_action_count'] = len(changes)
    result['producer_sha256'] = sha(Path(__file__))
    result['origin_report_sha256'] = sha(origin/'report.json')
    save(output/'report.json', result)
    (output/Path(__file__).name).write_bytes(Path(__file__).read_bytes())
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--origin', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = run(args.origin, args.output)
    print({k: v for k, v in result.items() if k not in ('counterexamples', 'state_atoms')})
    raise SystemExit(not result['mutation_detected'])

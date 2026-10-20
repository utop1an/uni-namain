"""Two authored HANS prefixes, unchanged source world; not goal-solving trials."""
import argparse
import json
from pathlib import Path

from unified_planning.io import PDDLReader
from unified_planning.model.fluent import get_all_fluent_exp
from unified_planning.plans import ActionInstance, SequentialPlan
from unified_planning.shortcuts import SequentialSimulator

from scripts.experiments.replay_source_probes import read, sha
from rcnc.trace_audit import compare_states
from rcnc.pddl import serialize


def run(inputs, compiled, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use a fresh output directory')
    source = 'HANS_NP'
    meta = read(compiled/'meta_domain.json')
    domain, problem = inputs/(source+'_domainfile.pddl'), inputs/(source+'_problemfile.pddl')
    for path in (domain, problem):
        if sha(path) != meta['source_sha256'][path.name]:
            raise ValueError('Source differs from compiled model provenance')
    frozen = {str(p): sha(p) for p in (domain, problem, compiled/'meta_domain.pddl',
        compiled/'meta_domain.json', compiled/'problems'/problem.name, Path(__file__), Path('rcnc/trace_audit.py'))}
    output.mkdir(parents=True)
    (output/'source_domain.pddl').write_bytes(domain.read_bytes())
    (output/'source_problem.pddl').write_bytes(problem.read_bytes())
    (output/'compiled_domain.pddl').write_bytes((compiled/'meta_domain.pddl').read_bytes())
    (output/'compiled_problem.pddl').write_bytes((compiled/'problems'/problem.name).read_bytes())
    (output/'meta_domain.json').write_bytes((compiled/'meta_domain.json').read_bytes())
    reader = PDDLReader()
    src = reader.parse_problem(str(domain), str(problem))
    dst = reader.parse_problem(str(compiled/'meta_domain.pddl'), str(compiled/'problems'/problem.name))
    follow = ['follow_breadcrumbs_home', 'grettel', 'hansel', 'forest', 'father_house']
    cases = {'guard_false': [follow], 'guard_true': [['drop_breadcrumb_on_path', 'hansel', 'pebble', 'father_house'], follow]}
    terms = {k.lower(): v.lower() for k, v in meta['constant_maps'][source].items()}
    terms.update({k.lower(): v.lower() for k, v in meta['namespaces'][source].get('objects', {}).items()})
    atoms = [atom for fluent in src.fluents for atom in get_all_fluent_exp(src, fluent)]
    rows = []
    for name, trace in cases.items():
        sp = SequentialPlan([ActionInstance(src.action(a[0]), tuple(src.object(x) for x in a[1:])) for a in trace])
        mapped = [[meta['action_maps'][source][a[0]].lower(), *[terms[x] for x in a[1:]]] for a in trace]
        tp = SequentialPlan([ActionInstance(dst.action(a[0]), tuple(dst.object(x) for x in a[1:])) for a in mapped])
        (output/(name+'_source.plan')).write_text('\n'.join(serialize(a) for a in trace)+'\n')
        (output/(name+'_compiled.plan')).write_text('\n'.join(serialize(a) for a in mapped)+'\n')
        row = {'id': name, 'source_trace': trace, 'mapped_trace': mapped,
            **compare_states(src, dst, sp, tp, {k.lower(): v.lower() for k, v in meta['predicate_maps'][source].items()},
                             terms, meta.get('predicate_orders', {}).get(source, {}))}
        with SequentialSimulator(src) as sim:
            state = sim.get_initial_state()
            for i, action in enumerate(sp.actions):
                before = state
                state = sim.apply(state, action.action, action.actual_parameters)
                if state is None:
                    raise ValueError('Authored source prefix is inapplicable')
                if i == len(sp.actions)-1:
                    row['guard_before_follow'] = before.get_value(src.fluent('crumb_on_path')(src.object('father_house'))).bool_constant_value()
                    row['changed_atoms_at_follow'] = [{'atom': str(atom), 'before': before.get_value(atom).bool_constant_value(),
                        'after': state.get_value(atom).bool_constant_value()} for atom in atoms if before.get_value(atom) != state.get_value(atom)]
        expected = name == 'guard_true'
        row['branch_control_passed'] = row['guard_before_follow'] == expected and bool(row['changed_atoms_at_follow']) == expected
        rows.append(row)
    result = {'status': 'PASS' if all(r['status'] == 'PASS' and r['branch_control_passed'] for r in rows) else 'FAIL',
        'trace_count': len(rows), 'rows': rows, 'frozen_sha256': frozen,
        'hashes_unchanged': all(sha(Path(p)) == h for p, h in frozen.items()),
        'states_compared': sum(r['states_compared'] for r in rows),
        'truth_comparisons': sum(r['truth_comparisons'] for r in rows),
        'scope': 'Authored executable prefixes from unchanged HANS initial state; original goals unchanged but goal attainment not required or claimed. Separate from the frozen original-goal and 45-probe evaluations.',
        'source_generality': 'drop_breadcrumb_on_path accepts any item, including the initially possessed pebble. This source behavior is retained, not asserted narratively plausible.'}
    save_path = output/'report.json'
    save_path.write_text(json.dumps(result, indent=2)+'\n')
    (output/Path(__file__).name).write_bytes(Path(__file__).read_bytes())
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inputs', type=Path, default=Path('data/narra-domains'))
    parser.add_argument('--compiled', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = run(args.inputs, args.compiled, args.output)
    print(json.dumps({k: v for k, v in result.items() if k not in ('rows', 'frozen_sha256')}, indent=2))
    raise SystemExit(result['status'] != 'PASS' or not result['hashes_unchanged'])

"""Compare parser namespace policies on unchanged PDDL in isolated environments."""
import argparse
import json
from pathlib import Path
import warnings

from unified_planning.environment import Environment
from unified_planning.io import PDDLReader

from rcnc.domain_building import require_empty_output, save, snapshot_implementation
from scripts.experiments.run_downward_reference import sha


def run(domain, output, problem=None):
    require_empty_output(output)
    output.mkdir(parents=True)
    (output / 'domain.pddl').write_bytes(domain.read_bytes())
    if problem is not None:
        (output / 'problem.pddl').write_bytes(problem.read_bytes())
    inputs = {name: sha(output / name) for name in ('domain.pddl', 'problem.pddl') if (output / name).exists()}
    implementation = snapshot_implementation(output, [Path(__file__), Path('rcnc/domain_building.py')])
    save(output / 'manifest.json', {'status': 'frozen_before_parse', 'input_sha256': inputs,
        'namespace_policies_error_used_name': [True, False], 'implementation_sha256': implementation})
    rows = []
    for strict in (True, False):
        environment = Environment()
        environment.error_used_name = strict
        row = {'id': 'strict' if strict else 'allow_cross_category_names', 'error_used_name': strict}
        with warnings.catch_warnings(record=True) as recorded:
            warnings.simplefilter('always')
            try:
                parsed = PDDLReader(environment=environment).parse_problem(str(output / 'domain.pddl'),
                    str(output / 'problem.pddl') if problem is not None else None)
                row.update(status='PARSED', actions=len(parsed.actions), fluents=len(parsed.fluents))
            except Exception as exc:
                row.update(status='ERROR', reason=f'{type(exc).__name__}: {exc}')
            row['warnings'] = [str(warning.message) for warning in recorded]
        rows.append(row)
    result = {'status': 'complete', 'task_count': 2, 'rows': rows,
        'strict_error_relaxed_parsed': rows[0]['status'] == 'ERROR' and rows[1]['status'] == 'PARSED',
        'inputs_unchanged': all(sha(output / name) == expected for name, expected in inputs.items()),
        'implementation_unchanged': all(sha(Path(name)) == expected for name, expected in implementation.items()),
        'manifest_sha256': sha(output / 'manifest.json'),
        'scope': 'Parser interoperability diagnosis only. Exact PDDL bytes unchanged. Neither parsing policy certifies standard compliance, source preservation, alignment semantics or narrative quality.'}
    save(output / 'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--domain', type=Path, required=True)
    parser.add_argument('--problem', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(run(args.domain, args.output, args.problem), indent=2))

"""Compare saved dense implementation with sparse effect-target differences."""
import argparse
import ast
import hashlib
import importlib.util
import json
from pathlib import Path

from rcnc.outcome_planning import explore


def run(output):
    before = output/'implementation/outcome_before.py'
    spec = importlib.util.spec_from_file_location('dense_outcome_reference', before)
    old = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(old)
    current = Path('rcnc/outcome_planning.py')
    (output/'implementation/outcome_after.py').write_bytes(current.read_bytes())
    for name in ('rcnc/grounding.py', 'rcnc/state_grounding.py', 'scripts/validation/validate_sparse_outcomes.py'):
        (output/'implementation'/Path(name).name).write_bytes(Path(name).read_bytes())
    fixture = ast.parse(Path('tests/test_outcome_sparse.py').read_text(encoding='utf-8'))
    method = next(n for n in ast.walk(fixture) if isinstance(n, ast.FunctionDef) and n.name.startswith('test_sparse_changes'))
    texts = [n.args[0].value for n in ast.walk(method) if isinstance(n, ast.Call)
             and isinstance(n.func, ast.Attribute) and n.func.attr == 'write_text']
    inputs = output/'inputs'
    inputs.mkdir()
    domain, problem = inputs/'domain.pddl', inputs/'problem.pddl'
    domain.write_text(texts[0], encoding='utf-8')
    problem.write_text(texts[1], encoding='utf-8')
    reports = {}
    for label, implementation in [('before', old.explore), ('after', explore)]:
        for cap in (4, 3000):
            key = f'{label}_cap_{cap}'
            reports[key] = implementation(domain, problem, output/key, max_ground_fluents=cap)
    def changes(report):
        return [[sorted((tuple(c['atom']), c['value']) for c in row['changes']), row['plan']]
                for row in report['outcomes']]
    checks = {
        'dense_tight_cap_exhausted': reports['before_cap_4']['stop_reason'] == 'ground_fluent_limit',
        'sparse_tight_cap_valid': reports['after_cap_4']['status'] == 'outcomes_generated' and
            all(row['validation']['status'] == 'VALID' for row in reports['after_cap_4']['outcomes']),
        'same_complete_changes_and_plans_nonbinding_cap': changes(reports['before_cap_3000']) == changes(reports['after_cap_3000']),
        'sparse_cap_does_not_change_result': changes(reports['after_cap_4']) == changes(reports['after_cap_3000']),
    }
    result = {'status': 'PASS' if all(checks.values()) else 'FAIL', 'checks': checks,
              'scope': 'Authored finite fixture, not narrative quality or corpus-wide performance',
              'implementation_sha256': {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
                                        for p in sorted((output/'implementation').glob('*.py'))},
              'runs': {key: {k: value[k] for k in ('status', 'stop_reason', 'states', 'ground_candidates')}
                       for key, value in reports.items()}}
    (output/'report.json').write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    result = run(parser.parse_args().output)
    print(json.dumps(result, indent=2))
    raise SystemExit(result['status'] != 'PASS')

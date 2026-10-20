"""Explicit problem-header packaging; no changes to planning content."""
import argparse
import copy
import json
from pathlib import Path

from rcnc.domain_building import check_raw_declarations
from rcnc.pddl import parse_sexpr, section, serialize
from scripts.experiments.run_downward_reference import sha, save
from unified_planning.io import PDDLReader


def package(domain, problem):
    check_raw_declarations(domain, 'domain')
    check_raw_declarations(problem, 'problem')
    domain_header = section(domain, 'domain')
    if not domain_header or len(domain_header) != 2 or not section(problem, 'problem'):
        raise ValueError('Expected explicit domain and problem headers')
    declared = section(problem, ':domain')
    if declared and declared != [':domain', domain_header[1]]:
        raise ValueError('Existing problem domain differs from paired domain')
    requirements = section(problem, ':requirements')
    supported = set((section(domain, ':requirements') or [':requirements'])[1:])
    if requirements and not set(requirements[1:]) <= supported:
        raise ValueError('Problem requirements are not already declared by the unchanged domain')
    result = copy.deepcopy(problem)
    result = [p for p in result if not (isinstance(p, list) and p and p[0] in (':domain', ':requirements'))]
    result.insert(2, [':domain', domain_header[1]])
    def content(root):
        return [p for p in root if not (isinstance(p, list) and p and p[0] in (':domain', ':requirements'))]
    if content(result) != content(problem):
        raise ValueError('Planning content changed')
    return result, {'domain_header_added': declared is None,
                    'problem_requirements_removed': requirements[1:] if requirements else [],
                    'requirements_already_in_domain': True, 'other_problem_sections_identical': True}


def run(domain_path, problem_path, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    domain_bytes, problem_bytes = domain_path.read_bytes(), problem_path.read_bytes()
    packaged, changes = package(parse_sexpr(domain_bytes.decode('utf-8')), parse_sexpr(problem_bytes.decode('utf-8')))
    output.mkdir(parents=True, exist_ok=True)
    (output/'domain.pddl').write_bytes(domain_bytes)
    (output/'original_problem.pddl').write_bytes(problem_bytes)
    (output/'problem.pddl').write_text(serialize(packaged)+'\n', encoding='utf-8')
    report = {'status': 'packaged', 'changes': changes,
        'original_domain_sha256': sha(domain_path), 'original_problem_sha256': sha(problem_path),
        'domain_sha256': sha(output/'domain.pddl'), 'problem_sha256': sha(output/'problem.pddl'),
        'implementation_sha256': sha(Path(__file__)),
        'scope': 'Declared packaging adapter; original bytes retained. No actions, objects, initial facts or goals repaired. Parsing does not establish semantic correctness or planning success.'}
    try:
        problem = PDDLReader().parse_problem(str(output/'domain.pddl'), str(output/'problem.pddl'))
        report.update(parser_status='PASS', actions=len(problem.actions), objects=len(list(problem.all_objects)), predicates=len(problem.fluents))
    except Exception as exc:
        report.update(parser_status='REJECTED', parser_error=f'{type(exc).__name__}: {exc}')
    save(output/'report.json', report)
    (output/Path(__file__).name).write_bytes(Path(__file__).read_bytes())
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('domain', 'problem', 'output'):
        parser.add_argument('--'+name, type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(run(args.domain, args.problem, args.output), indent=2))

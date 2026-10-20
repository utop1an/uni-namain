"""Independent PDDL parsing and plan validation through Unified Planning."""
from pathlib import Path


def prepare_artifacts(domain, problem_path, output):
    """Copy the unchanged model and problem before writing a candidate plan."""
    output = Path(output)
    output.mkdir(parents=True, exist_ok=True)
    (output/'domain.pddl').write_bytes(Path(domain).read_bytes())
    (output/'problem.pddl').write_bytes(Path(problem_path).read_bytes())
    return output


def write_validated_plan(problem, plan, output):
    """Write a plan and independently check it against the saved artifacts."""
    from unified_planning.io import PDDLWriter

    PDDLWriter(problem).write_plan(plan, str(output/'plan.txt'))
    validation = validate_artifacts(output)
    return {'status': 'solved' if validation['status'] == 'VALID' else 'validation_failed',
            'length': len(plan.actions), 'plan': str(plan), 'validation': validation}


def validate_artifacts(directory: Path):
    try:
        import unified_planning
        from unified_planning.io import PDDLReader
        from unified_planning.shortcuts import PlanValidator
    except ImportError as exc:
        return {'status': 'UNAVAILABLE', 'reason': str(exc)}
    try:
        reader = PDDLReader()
        problem = reader.parse_problem(str(directory/'domain.pddl'), str(directory/'problem.pddl'))
        plan = reader.parse_plan(problem, str(directory/'plan.txt'))
        with PlanValidator(name='sequential_plan_validator') as validator:
            result = validator.validate(problem, plan)
        return {'status': result.status.name, 'engine': result.engine_name,
                'version': unified_planning.__version__, 'details': str(result)}
    except Exception as exc:
        # Parser/engine failures are evidence of failed validation, never validity.
        return {'status': 'ERROR', 'version': unified_planning.__version__,
                'reason': f'{type(exc).__name__}: {exc}'}

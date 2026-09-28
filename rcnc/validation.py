"""Independent PDDL parsing and plan validation through Unified Planning."""
from pathlib import Path


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

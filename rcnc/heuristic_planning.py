"""Optional Pyperplan reference, with explicit UP compilation and plan lifting.

The caller must enforce a subprocess wall-clock limit. Pyperplan is a teaching
and prototyping planner, not a state-of-the-art performance baseline.
"""
import importlib.metadata
import json

from unified_planning.engines import CompilationKind
from unified_planning.io import PDDLReader
from unified_planning.shortcuts import Compiler, OneshotPlanner, get_environment

from rcnc.validation import prepare_artifacts, write_validated_plan


def solve(domain, problem_path, output):
    # Engine credits contain Unicode names that fail in Windows GBK pipes.
    # Attribution is retained in THIRD_PARTY_NOTICES and the saved metadata.
    get_environment().credits_stream = None
    problem = PDDLReader().parse_problem(str(domain), str(problem_path))
    output = prepare_artifacts(domain, problem_path, output)
    compiled = problem
    conversions = []
    stages = []
    operations = [
        ('up_quantifiers_remover', CompilationKind.QUANTIFIERS_REMOVING,
         lambda k: k.has_existential_conditions() or k.has_universal_conditions()),
        ('up_conditional_effects_remover', CompilationKind.CONDITIONAL_EFFECTS_REMOVING,
         lambda k: k.has_conditional_effects()),
        ('up_disjunctive_conditions_remover', CompilationKind.DISJUNCTIVE_CONDITIONS_REMOVING,
         lambda k: k.has_disjunctive_conditions()),
        ('up_negative_conditions_remover', CompilationKind.NEGATIVE_CONDITIONS_REMOVING,
         lambda k: k.has_negative_conditions()),
    ]
    metadata = {'engine': 'pyperplan', 'search': 'gbf', 'heuristic': 'hff',
                'versions': {name: importlib.metadata.version(name) for name in
                             ['unified-planning', 'up-pyperplan', 'pyperplan']},
                'budget_policy': 'external_process_wall_clock_only', 'compilations': stages}
    for name, kind, needed in operations:
        if not needed(compiled.kind):
            continue
        with Compiler(name=name, compilation_kind=kind) as compiler:
            result = compiler.compile(compiled, kind)
        compiled = result.problem
        conversions.append(result)
        stages.append({'engine': name, 'actions': len(compiled.actions), 'fluents': len(compiled.fluents)})
        (output / 'compilation.json').write_text(json.dumps(metadata, indent=2) + '\n', encoding='utf-8')
    with OneshotPlanner(name='pyperplan', params={'search': 'gbf', 'heuristic': 'hff'}) as planner:
        if not planner.supports(compiled.kind):
            return {**metadata, 'status': 'unsupported', 'problem_kind': str(compiled.kind)}
        result = planner.solve(compiled)
    metadata['engine_status'] = result.status.name
    if result.plan is None:
        return {**metadata, 'status': 'unsolvable' if result.status.name == 'UNSOLVABLE_PROVEN' else 'incomplete'}
    plan = result.plan
    for conversion in reversed(conversions):
        if conversion.map_back_action_instance is not None:
            plan = plan.replace_action_instances(conversion.map_back_action_instance)
        elif conversion.plan_back_conversion is not None:
            plan = conversion.plan_back_conversion(plan)
        else:
            raise ValueError('Compiler did not provide a plan lifting function')
    return {**metadata, **write_validated_plan(problem, plan, output)}

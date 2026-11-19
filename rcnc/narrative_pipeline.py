"""Explicit requests -> pre-search source union -> bounded validated planning.

Sources and symbols are selected at domain level. No source problem facts,
successful action subsets, or implicit object identities enter the request.
"""
import json
from pathlib import Path
import re
import subprocess
import sys

from rcnc.domain_union import build
from rcnc.domain_building import digest, save
from rcnc.pddl import parse_domain, serialize
from rcnc.pddl import is_type_compatible as compatible


ROOT = Path(__file__).resolve().parents[1]


def map_problem(query, union, output):
    """Accept source-qualified predicates/constants and explicitly typed objects."""
    domain = parse_domain(union / 'meta_domain.pddl')
    meta = json.loads((union / 'meta_domain.json').read_text(encoding='utf-8'))
    declarations = query.get('objects', {})
    if not isinstance(declarations, dict):
        raise ValueError('objects must map request names to source-qualified types')
    objects = {}
    object_types = {}
    logical_types = {}
    reified = meta.get('type_encoding') == 'static_membership'
    source_parents = meta['source_type_parents'] if reified else domain.types

    def lookup(reference, category):
        if not isinstance(reference, str) or reference.count(':') != 1:
            raise ValueError(f'Expected source-qualified {category}: {reference}')
        source, name = reference.split(':')
        if source not in meta['sources']:
            raise ValueError(f'Reference uses unselected source: {source}')
        table = meta['namespaces'][source]['types'] if category == 'type' else meta[category + '_maps'][source]
        table = {k.lower(): v for k, v in table.items()}
        if name.lower() not in table:
            raise ValueError(f'Unknown {category}: {reference}')
        return table[name.lower()]

    for name, typ in declarations.items():
        if not isinstance(name, str) or not re.fullmatch(r'[a-z][a-z0-9_-]*', name):
            raise ValueError('Request object names must be lowercase PDDL identifiers')
        objects[name] = 'q__' + name
        references = typ if isinstance(typ, list) and reified else [typ]
        if not references or len(set(references)) != len(references):
            raise ValueError('Explicit object type memberships must be nonempty and unique')
        logical_types[objects[name]] = [lookup(ref, 'type') for ref in references]
        object_types[objects[name]] = 'object' if reified else logical_types[objects[name]][0]

    def atom(value):
        if not isinstance(value, list) or not value or not isinstance(value[0], str):
            raise ValueError('Atoms must be nonempty lists of named symbols')
        name = lookup(value[0], 'predicate')
        source, original_name = value[0].split(':')
        if reified:
            source_signatures = {k.lower(): v for k, v in meta['source_predicate_types'][source].items()}
            signature_types = source_signatures[original_name.lower()]
        else:
            signature_types = [t for _, t in domain.predicates[name].parameters]
        if len(value) - 1 != len(signature_types):
            raise ValueError(f'Wrong predicate arity: {value[0]}')
        terms = []
        for supplied, expected in zip(value[1:], signature_types):
            if not isinstance(supplied, str):
                raise ValueError('Object references must be strings')
            if supplied in objects:
                term = objects[supplied]
                actual = logical_types[term]
            else:
                term = lookup(supplied, 'constant')
                actual = [meta['source_constant_types'][term] if reified else domain.constants[term]]
            if not any(compatible(t, expected, source_parents) for t in actual):
                raise ValueError(f'Ill-typed or cross-source object: {supplied} in {value[0]}')
            terms.append(term)
        orders = {k.lower(): v for k, v in meta.get('predicate_orders', {}).get(source, {}).items()}
        return [name, *[terms[i] for i in orders.get(original_name.lower(), range(len(terms)))]]

    initial = query['initial']
    goal = query['goal']
    if not isinstance(initial, list):
        raise ValueError('initial must be an explicit list of positive facts under complete closed-world semantics')
    if not isinstance(goal, dict) or set(goal) - {'positive', 'negative'}:
        raise ValueError('goal must contain positive and/or negative atom lists')
    positive, negative = goal.get('positive', []), goal.get('negative', [])
    if not isinstance(positive, list) or not isinstance(negative, list):
        raise ValueError('Goal clauses must be atom lists')
    mapped_initial = [atom(f) for f in initial]
    encoding_facts = []
    if reified:
        from rcnc.aligned_domain import membership_facts
        encoding_facts = list(meta['constant_membership_facts'])
        for obj, types in logical_types.items():
            for typ in types:
                encoding_facts.extend(membership_facts(obj, typ, source_parents, meta['type_guards']))
        encoding_facts = [list(f) for f in dict.fromkeys(tuple(f) for f in encoding_facts)]
    mapped_positive, mapped_negative = [atom(f) for f in positive], [atom(f) for f in negative]
    root = ['define', ['problem', 'narrative_query'], [':domain', domain.name],
            [':objects', *[x for obj, typ in object_types.items() for x in (obj, '-', typ)]],
            [':init', *mapped_initial, *encoding_facts],
            [':goal', ['and', *mapped_positive, *[['not', f] for f in mapped_negative]]]]
    output.write_text(serialize(root) + '\n', encoding='utf-8')
    # Independent parsing is a mandatory gate before invoking search.
    from unified_planning.io import PDDLReader
    PDDLReader().parse_problem(str(union / 'meta_domain.pddl'), str(output))
    return {'objects': objects, 'object_types': object_types, 'logical_type_memberships': logical_types,
            'initial': mapped_initial, 'type_encoding_facts': encoding_facts,
            'goal': {'positive': mapped_positive, 'negative': mapped_negative},
            'state_semantics': 'complete_closed_world', 'source_problem_facts_imported': False}


def run(query, inputs, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use an empty output directory')
    output.mkdir(parents=True, exist_ok=True)
    save(output / 'query.json', query)
    result = {'status': 'preparing', 'planner_called': False,
              'method': 'source_preserving_union_explicit_request',
              'scope': 'Execution baseline; no inferred semantic equivalences or narrative-quality claim'}

    def finish(status, **fields):
        result.update(status=status, **fields)
        save(output / 'result.json', result)
        return result

    if not isinstance(query, dict):
        return finish('rejected', reason='Query must be an object')
    if 'initial' not in query or query['initial'] is None:
        return finish('needs_initial_state', reason='Supply an explicit initial state; an empty list is allowed')
    initial_only = 'goal' not in query or query['goal'] is None
    result['mode'] = 'initial_only' if initial_only else 'initial_goal'
    try:
        allowed = {'sources', 'objects', 'initial', 'goal', 'state_semantics', 'max_states',
                   'max_depth', 'max_ground_actions', 'seconds', 'solver', 'max_outcomes', 'max_ground_fluents', 'inert_parameter_representatives', 'alignment', 'selection',
                   'planner', 'memory_mb', 'correlated_parameter_tuples', 'precondition_witness_representatives', 'conditional_merge'}
        if set(query) - allowed:
            raise ValueError(f'Unsupported query fields: {sorted(set(query) - allowed)}')
        if 'conditional_merge' in query and ('alignment' in query or 'sources' in query
                or query.get('selection', 'all_domains') != 'all_domains'):
            raise ValueError('Conditional merge v1 requires the complete supplied source set and no separate alignment')
        if query.get('state_semantics', 'complete_closed_world') != 'complete_closed_world':
            raise ValueError('Partial-observation states are not supported')
        solver = query.get('solver', 'typed_cartesian')
        if solver not in ('typed_cartesian', 'pyperplan', 'fast_downward', 'state_projected'):
            raise ValueError('Unknown solver')
        if solver != 'fast_downward' and any(k in query for k in ('planner', 'memory_mb')):
            raise ValueError('planner and memory_mb apply only to fast_downward')
        if 'inert_parameter_representatives' in query and (solver != 'state_projected'
                or type(query['inert_parameter_representatives']) is not bool):
            raise ValueError('inert_parameter_representatives is Boolean and applies only to state_projected')
        if 'correlated_parameter_tuples' in query and (solver != 'state_projected'
                or type(query['correlated_parameter_tuples']) is not bool):
            raise ValueError('correlated_parameter_tuples is Boolean and applies only to state_projected')
        if 'precondition_witness_representatives' in query and (solver != 'state_projected'
                or type(query['precondition_witness_representatives']) is not bool):
            raise ValueError('precondition_witness_representatives is Boolean and applies only to state_projected')
        if initial_only and solver != 'typed_cartesian':
            raise ValueError('Initial-only exploration uses the typed_cartesian reference engine')
        if not initial_only and ('max_outcomes' in query or
                ('max_ground_fluents' in query and solver != 'state_projected')):
            raise ValueError('Outcome budgets apply only to initial-only requests')
        if solver == 'pyperplan' and any(k in query for k in ('max_states', 'max_depth', 'max_ground_actions')):
            raise ValueError('Pyperplan supports only the process seconds budget in this adapter')
        if solver == 'fast_downward' and any(k in query for k in ('max_states', 'max_depth', 'max_ground_actions')):
            raise ValueError('Fast Downward supports seconds and memory_mb budgets in this adapter')
        budgets = {key: query.get(key, default) for key, default in
                   [('max_states', 5000), ('max_depth', 10 if initial_only else 30), ('max_ground_actions', 100000)]}
        if initial_only:
            budgets.update(max_outcomes=query.get('max_outcomes', 3),
                           max_ground_fluents=query.get('max_ground_fluents', 100000))
        elif solver == 'state_projected':
            budgets['max_ground_fluents'] = query.get('max_ground_fluents', 100000)
        for key, value in budgets.items():
            if type(value) is not int or value < (0 if key == 'max_depth' else 1):
                raise ValueError(f'Invalid budget: {key}')
        if solver == 'state_projected':
            budgets['inert_parameter_representatives'] = query.get('inert_parameter_representatives', False)
            budgets['correlated_parameter_tuples'] = query.get('correlated_parameter_tuples', False)
            budgets['precondition_witness_representatives'] = query.get('precondition_witness_representatives', False)
        seconds = query.get('seconds', 60)
        if type(seconds) not in (int, float) or not 0 < seconds <= 3600:
            raise ValueError('seconds must be positive and at most 3600')
        worker_budget = budgets
        supervisor_seconds = seconds
        if solver == 'fast_downward':
            memory_mb = query.get('memory_mb', 4096)
            if type(seconds) is not int or type(memory_mb) is not int or memory_mb < 64:
                raise ValueError('Fast Downward requires integer seconds and memory_mb >= 64')
            planner_value = query.get('planner', '.tmp/fast-downward-26.6')
            if not isinstance(planner_value, str):
                raise ValueError('planner must be a local path string')
            planner = Path(planner_value).resolve()
            if not (planner / 'builds/release/bin/downward').is_file():
                raise ValueError('Fast Downward release binary is not built')
            worker_budget = {'seconds': seconds, 'memory_mb': memory_mb, 'planner': str(planner)}
            # Linux owns the wall/CPU search deadline. Allow startup, process
            # observation and independent validation to finish separately.
            supervisor_seconds = seconds + 45
        available = {p.name.removesuffix('_domainfile.pddl'): p for p in sorted(inputs.glob('*_domainfile.pddl'))}
        from rcnc.domain_catalog import catalog, select, project_alignment
        inventory = catalog(inputs)
        save(output / 'catalog.json', inventory)
        static_components = query.get('selection') == 'static_universe_components'
        if static_components and (initial_only or 'alignment' not in query or 'sources' in query):
            raise ValueError('Static component selection requires alignment and an explicit goal, without explicit sources')
        selection = select({**query, 'selection': 'all_domains'} if static_components else query, inventory)
        sources = selection['selected']
        selected = output / 'selected_inputs'
        selected.mkdir()
        for source in sources:
            (selected / available[source].name).write_bytes(available[source].read_bytes())
            source_problem = inputs / f'{source}_problemfile.pddl'
            if source_problem.exists():
                (selected / source_problem.name).write_bytes(source_problem.read_bytes())
        save(output / 'selection.json', selection)
        union = output / 'union'
        if 'conditional_merge' in query:
            from rcnc.conditional_merge import build as build_conditional
            validation = build_conditional(selected, union, query['conditional_merge'])
            result['method'] = 'conditional_semantic_and_formal_merge'
            result['semantic_alignment_status'] = 'accepted_judgments_not_independent_labels'
        elif 'alignment' in query:
            from rcnc.aligned_domain import build as build_aligned
            applied_alignment, omitted = project_alignment(query['alignment'], sources)
            selection['omitted_alignment_groups'] = omitted
            save(output / 'selection.json', selection)
            validation = build_aligned(selected, union, applied_alignment)
            result['method'] = 'explicit_alignment_with_source_type_guards'
            result['alignment_decision_basis'] = applied_alignment['decision_basis']
            result['semantic_alignment_status'] = 'assumptions_not_independently_verified'
        else:
            validation = build(selected, union)
        if not validation['valid']:
            raise ValueError('Selected union failed independent parsing')
        mapped_path = output / 'mapped_problem.pddl'
        mapping = map_problem({**query, 'goal': {'positive': []}} if initial_only else query, union, mapped_path)
        mapping['goal_origin'] = 'none_initial_only' if initial_only else 'user_supplied'
        save(output / 'query_mapping.json', mapping)
        planning_domain = union / 'meta_domain.pddl'
        if static_components:
            from rcnc.component_selection import restrict
            planning_domain = output / 'selected_domain.pddl'
            certificate = restrict(query, union, mapped_path, planning_domain)
            save(output / 'selection_certificate.json', certificate)
            selection = {'policy': 'static_universe_components',
                'selected': certificate['selected_sources'], 'excluded': certificate['excluded_sources'],
                'goal_sources': certificate['goal_sources'], 'action_subset_selection': False,
                'vocabulary_policy': certificate['vocabulary_policy'],
                'scope': certificate['scope'], 'certificate_sha256': digest(output / 'selection_certificate.json')}
            save(output / 'selection.json', selection)
        manifest = {'selection': selection, 'solver': solver,
                    'catalog_sha256': digest(output / 'catalog.json'),
                    'budget': {**(budgets if solver == 'typed_cartesian' else {}), 'seconds': seconds},
                    'merged_before_planning': True, 'domain_sha256': digest(planning_domain),
                    'planning_domain': planning_domain.relative_to(output).as_posix(),
                    'problem_sha256': digest(mapped_path),
                    'full_compiled_domain_sha256': digest(union / 'meta_domain.pddl'),
                    'compiled_metadata_sha256': digest(union / 'meta_domain.json'),
                    'query_mapping_sha256': digest(output / 'query_mapping.json'),
                    'implementation_sha256': {name: digest(ROOT / name) for name in
                        ['rcnc/__main__.py', 'rcnc/pipeline_cli.py', 'rcnc/planning_worker.py', 'rcnc/narrative_pipeline.py', 'rcnc/merged_planning.py',
                         'rcnc/validation.py', 'rcnc/domain_union.py', 'rcnc/domain_building.py', 'rcnc/pddl.py', 'rcnc/pddl_checks.py',
                         'rcnc/heuristic_planning.py', 'rcnc/outcome_planning.py', 'rcnc/aligned_domain.py',
                         'rcnc/domain_catalog.py', 'rcnc/grounding.py', 'rcnc/state_grounding.py', 'rcnc/state_projected_planning.py', 'rcnc/inert_grounding.py', 'rcnc/correlated_grounding.py', 'rcnc/witness_grounding.py',
                         'rcnc/component_selection.py', 'rcnc/world_source_selection.py',
                         'rcnc/downward_planning.py', 'scripts/experiments/run_downward_reference.py']}}
        if solver == 'fast_downward':
            manifest['budget'].update(memory_mb=memory_mb, supervisor_grace_seconds=45)
            manifest['planner'] = str(planner)
        save(output / 'manifest.json', manifest)
        result.update(planner_called=True, status='running')
        save(output / 'result.json', result)
        command = [sys.executable, '-m', 'rcnc', 'plan', '--worker',
                   '--domain', str(planning_domain.resolve()),
                   '--problem', str(mapped_path.resolve()), '--output', str((output / 'planning').resolve()),
                   '--budget', json.dumps(worker_budget), '--solver', solver, '--mode', result['mode']]
        try:
            with (output / 'worker.log').open('w', encoding='utf-8') as log:
                completed = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, timeout=supervisor_seconds, cwd=ROOT)
            path = output / 'planning/search.json'
            search = json.loads(path.read_text(encoding='utf-8')) if path.exists() else {
                'status': 'worker_error', 'returncode': completed.returncode}
        except subprocess.TimeoutExpired:
            search = {'status': 'supervisor_time_limit' if solver == 'fast_downward' else 'time_limit'}
        unchanged = digest(planning_domain) == manifest['domain_sha256']
        provenance_unchanged = (digest(union / 'meta_domain.pddl') == manifest['full_compiled_domain_sha256']
            and digest(union / 'meta_domain.json') == manifest['compiled_metadata_sha256']
            and digest(output / 'query_mapping.json') == manifest['query_mapping_sha256'])
        return finish(search['status'] if unchanged and provenance_unchanged else 'artifact_changed', search=search,
                      domain_unchanged=unchanged, provenance_unchanged=provenance_unchanged, selection=selection)
    except Exception as exc:
        return finish('error' if result['planner_called'] else 'rejected',
                      reason=f'{type(exc).__name__}: {exc}')

"""Explicit requests -> pre-search source union -> bounded validated planning.

Sources and symbols are selected at domain level. No source problem facts,
successful action subsets, or implicit object identities enter the request.
"""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

from build_narrative_union import build
from merge_domains import parse_domain, serialize
from rcnc.planning import compatible


ROOT = Path(__file__).resolve().parents[1]


def save(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def map_problem(query, union, output):
    """Accept source-qualified predicates/constants and explicitly typed objects."""
    domain = parse_domain(union / 'meta_domain.pddl', apply_reviewed_semantics=False)
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
        from build_aligned_domain import membership_facts
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
                   'max_depth', 'max_ground_actions', 'seconds', 'solver', 'max_outcomes', 'max_ground_fluents', 'alignment', 'selection'}
        if set(query) - allowed:
            raise ValueError(f'Unsupported query fields: {sorted(set(query) - allowed)}')
        if query.get('state_semantics', 'complete_closed_world') != 'complete_closed_world':
            raise ValueError('Partial-observation states are not supported')
        solver = query.get('solver', 'typed_cartesian')
        if solver not in ('typed_cartesian', 'pyperplan'):
            raise ValueError('Unknown solver')
        if initial_only and solver != 'typed_cartesian':
            raise ValueError('Initial-only exploration uses the typed_cartesian reference engine')
        if not initial_only and any(k in query for k in ('max_outcomes', 'max_ground_fluents')):
            raise ValueError('Outcome budgets apply only to initial-only requests')
        if solver == 'pyperplan' and any(k in query for k in ('max_states', 'max_depth', 'max_ground_actions')):
            raise ValueError('Pyperplan supports only the process seconds budget in this adapter')
        budgets = {key: query.get(key, default) for key, default in
                   [('max_states', 5000), ('max_depth', 10 if initial_only else 30), ('max_ground_actions', 100000)]}
        if initial_only:
            budgets.update(max_outcomes=query.get('max_outcomes', 3),
                           max_ground_fluents=query.get('max_ground_fluents', 100000))
        for key, value in budgets.items():
            if type(value) is not int or value < (0 if key == 'max_depth' else 1):
                raise ValueError(f'Invalid budget: {key}')
        seconds = query.get('seconds', 60)
        if type(seconds) not in (int, float) or not 0 < seconds <= 3600:
            raise ValueError('seconds must be positive and at most 3600')
        available = {p.name.removesuffix('_domainfile.pddl'): p for p in sorted(inputs.glob('*_domainfile.pddl'))}
        from rcnc.domain_catalog import catalog, select, project_alignment
        inventory = catalog(inputs)
        save(output / 'catalog.json', inventory)
        selection = select(query, inventory)
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
        if 'alignment' in query:
            from build_aligned_domain import build as build_aligned
            applied_alignment, omitted = project_alignment(query['alignment'], sources)
            selection['omitted_alignment_groups'] = omitted
            save(output / 'selection.json', selection)
            validation = build_aligned(selected, union, applied_alignment)
            result['method'] = 'explicit_alignment_with_source_type_guards'
            result['semantic_alignment_status'] = 'assumptions_not_independently_verified'
        else:
            validation = build(selected, union)
        if not validation['valid']:
            raise ValueError('Selected union failed independent parsing')
        mapped_path = output / 'mapped_problem.pddl'
        mapping = map_problem({**query, 'goal': {'positive': []}} if initial_only else query, union, mapped_path)
        mapping['goal_origin'] = 'none_initial_only' if initial_only else 'user_supplied'
        save(output / 'query_mapping.json', mapping)
        manifest = {'selection': selection, 'solver': solver,
                    'catalog_sha256': digest(output / 'catalog.json'),
                    'budget': {**(budgets if solver == 'typed_cartesian' else {}), 'seconds': seconds},
                    'merged_before_planning': True, 'domain_sha256': digest(union / 'meta_domain.pddl'),
                    'problem_sha256': digest(mapped_path),
                    'implementation_sha256': {name: digest(ROOT / name) for name in
                        ['run_narrative_pipeline.py', 'rcnc/narrative_pipeline.py', 'rcnc/merged_planning.py',
                         'rcnc/validation.py', 'build_narrative_union.py', 'merge_domains.py', 'pddl_checks.py',
                         'rcnc/heuristic_planning.py', 'rcnc/outcome_planning.py', 'build_aligned_domain.py',
                         'rcnc/domain_catalog.py', 'rcnc/grounding.py', 'rcnc/state_grounding.py']}}
        save(output / 'manifest.json', manifest)
        result.update(planner_called=True, status='running')
        save(output / 'result.json', result)
        command = [sys.executable, str(ROOT / 'run_narrative_pipeline.py'), '--worker',
                   '--domain', str((union / 'meta_domain.pddl').resolve()),
                   '--problem', str(mapped_path.resolve()), '--output', str((output / 'planning').resolve()),
                   '--budget', json.dumps(budgets), '--solver', solver, '--mode', result['mode']]
        try:
            with (output / 'worker.log').open('w', encoding='utf-8') as log:
                completed = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, timeout=seconds)
            path = output / 'planning/search.json'
            search = json.loads(path.read_text(encoding='utf-8')) if path.exists() else {
                'status': 'worker_error', 'returncode': completed.returncode}
        except subprocess.TimeoutExpired:
            search = {'status': 'time_limit'}
        unchanged = digest(union / 'meta_domain.pddl') == manifest['domain_sha256']
        return finish(search['status'] if unchanged else 'artifact_changed', search=search,
                      domain_unchanged=unchanged, selection=selection)
    except Exception as exc:
        return finish('error' if result['planner_called'] else 'rejected',
                      reason=f'{type(exc).__name__}: {exc}')

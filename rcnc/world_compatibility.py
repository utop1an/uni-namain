"""Finite initial-valuation compatibility audit; never pools planning facts.

Worlds and object embeddings are explicit inputs. A common mapped atom with
opposite truth values is a conflict. Successful exhaustion concerns these
Boolean initial projections only, not mixed traces or joint goal reachability.
"""
from itertools import product
from math import prod
import re
import json

from unified_planning.io import PDDLReader

from rcnc.pddl import parse_domain
from rcnc.domain_building import digest as sha


def inspect_worlds(compiled, worlds, *, domain_sha256, metadata_sha256, max_atoms=100000):
    if type(max_atoms) is not int or max_atoms < 1:
        raise ValueError('max_atoms must be a positive integer')
    if sha(compiled / 'meta_domain.pddl') != domain_sha256 or sha(compiled / 'meta_domain.json') != metadata_sha256:
        raise ValueError('Compiled artifact or metadata differs from its explicit pin')
    meta = json.loads((compiled / 'meta_domain.json').read_text(encoding='utf-8'))
    if meta.get('compiled_domain_sha256') != domain_sha256 or meta.get('type_encoding') != 'static_membership':
        raise ValueError('Expected the pinned membership compilation')
    if not worlds or len({world['source'] for world in worlds}) != len(worlds):
        raise ValueError('Require one explicitly supplied world per distinct source')
    prepared, required = [], 0
    target = parse_domain(compiled / 'meta_domain.pddl')
    all_constants = {value.lower() for table in meta['constant_maps'].values() for value in table.values()}
    for world in worlds:
        source = world['source']
        if source not in meta['sources']:
            raise ValueError('Unknown compiled source: ' + source)
        domain, problem_path = world['domain'], world['problem']
        if sha(domain) != world['domain_sha256'] or sha(problem_path) != world['problem_sha256']:
            raise ValueError('Explicit world files drifted')
        if sha(domain) != meta['source_sha256'][source + '_domainfile.pddl']:
            raise ValueError('World domain differs from compiled source')
        native = parse_domain(domain)
        problem = PDDLReader().parse_problem(str(domain), str(problem_path))
        constants = {name.lower() for name in native.constants}
        problem_objects = {obj.name.lower() for obj in problem.all_objects} - constants
        mapping = world['object_map']
        if not isinstance(mapping, dict) or set(mapping) != problem_objects:
            raise ValueError('Every problem object requires an explicit embedding; no inferred identities')
        if any(not isinstance(value, str) or not re.fullmatch(r'q__[a-z][a-z0-9_-]*', value) or value in all_constants for value in mapping.values()):
            raise ValueError('Problem objects require fresh q__ identifiers distinct from source constants')
        terms = {name.lower(): value.lower() for name, value in meta['constant_maps'][source].items()}
        terms.update(mapping)
        if len(set(terms.values())) != len(terms):
            raise ValueError('Source object embedding must be injective')
        predicates = {name.lower(): value.lower() for name, value in meta['predicate_maps'][source].items()}
        if set(predicates) != {fluent.name.lower() for fluent in problem.fluents} or len(set(predicates.values())) != len(predicates):
            raise ValueError('Source-local predicate map must be complete and injective')
        orders = {name.lower(): order for name, order in meta['predicate_orders'][source].items()}
        schemas, count = [], 0
        for fluent in problem.fluents:
            if not fluent.type.is_bool_type() or any(not p.type.is_user_type() for p in fluent.signature):
                raise ValueError('Compatibility audit supports finite Boolean object fluents')
            order = orders[fluent.name.lower()]
            if len(order) != fluent.arity or any(type(index) is not int for index in order) or sorted(order) != list(range(fluent.arity)):
                raise ValueError('Invalid predicate argument permutation')
            if target.predicates[predicates[fluent.name.lower()]].arity != fluent.arity:
                raise ValueError('Mapped predicate arity mismatch')
            choices = [list(problem.objects(parameter.type)) for parameter in fluent.signature]
            count += prod(len(values) for values in choices)
            schemas.append((fluent, choices, order))
        required += count
        prepared.append((world, problem, terms, predicates, schemas, count))
    base = {'world_count': len(worlds), 'required_ground_atom_comparisons': required, 'max_atoms': max_atoms,
        'compiled_domain_sha256': domain_sha256, 'compiled_metadata_sha256': metadata_sha256,
        'facts_imported_into_planning': False, 'planner_called': False,
        'scope': 'Initial-valuation consistency under the supplied source worlds and injective object embeddings. No pooled world is emitted; no assertion of semantic correspondence, arbitrary mixed-trace preservation or simultaneous goal reachability.'}
    if required > max_atoms:
        return {**base, 'status': 'atom_budget_limit', 'compatible': None, 'complete': False,
            'ground_atom_comparisons': 0, 'conflicts': [], 'worlds': [{'source': row[0]['source'], 'required_atoms': row[5]} for row in prepared]}
    assignments, conflicts, rows = {}, {}, []
    for world, problem, terms, predicates, schemas, count in prepared:
        for fluent, choices, order in schemas:
            for arguments in product(*choices):
                value = problem.initial_value(fluent(*arguments))
                if value is None or not value.is_bool_constant():
                    raise ValueError('Every initial ground atom needs a Boolean truth value')
                mapped_terms = [terms[obj.name.lower()] for obj in arguments]
                atom = (predicates[fluent.name.lower()], *[mapped_terms[index] for index in order])
                witness = {'source': world['source'], 'source_atom': [fluent.name, *[obj.name for obj in arguments]],
                    'truth': value.bool_constant_value()}
                if atom not in assignments:
                    assignments[atom] = witness
                elif assignments[atom]['truth'] != witness['truth'] and atom not in conflicts:
                    conflicts[atom] = {'mapped_atom': list(atom), 'left': assignments[atom], 'right': witness}
        rows.append({'source': world['source'], 'ground_atom_comparisons': count,
            'domain_sha256': world['domain_sha256'], 'problem_sha256': world['problem_sha256'],
            'explicit_object_map': world['object_map']})
    return {**base, 'status': 'incompatible_initial_projections' if conflicts else 'compatible_initial_projections',
        'compatible': not conflicts, 'complete': True, 'ground_atom_comparisons': required,
        'distinct_mapped_atoms': len(assignments), 'conflicting_atoms': len(conflicts),
        'conflicts': list(conflicts.values()), 'worlds': rows}

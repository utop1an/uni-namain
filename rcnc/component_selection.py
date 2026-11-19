"""Whole-source action reduction with the complete supplied world retained.

This is a pre-search source-component restriction, not a plan-derived grounded
action subset. All vocabulary, constants and supplied problem bytes survive.
"""
import copy
import json
from .domain_building import digest

from unified_planning.io import PDDLReader
from .pddl import parse_domain, parse_sexpr, write_domain
from .world_source_selection import select_component


def restrict(query, compiled, problem_path, output, *, expected_domain_sha256=None):
    """Write a selected parameterized domain without remapping the problem."""
    if query.get('goal') is None:
        raise ValueError('Static component selection requires an explicit goal')
    if 'sources' in query:
        raise ValueError('Explicit sources and automatic selection cannot both be specified')
    goals = [atom for kind in ('positive', 'negative') for atom in query['goal'].get(kind, [])]
    if not goals:
        raise ValueError('Static component selection requires at least one goal atom')
    seeds = sorted({atom[0].split(':', 1)[0] for atom in goals})
    metadata = json.loads((compiled / 'meta_domain.json').read_text(encoding='utf-8'))
    exported = metadata.get('compiled_domain_sha256')
    if exported is not None and expected_domain_sha256 is not None and exported != expected_domain_sha256:
        raise ValueError('Compiler export hash conflicts with the frozen expected domain hash')
    expected = exported or expected_domain_sha256
    if expected is None:
        raise ValueError('Compiler export hash or explicit frozen expected domain hash required')
    if digest(compiled / 'meta_domain.pddl') != expected:
        raise ValueError('Compiled domain export hash mismatch; post-export adapters require a separate versioned contract')
    domain = parse_domain(compiled / 'meta_domain.pddl')
    if set(metadata['action_maps']) != set(metadata['sources']):
        raise ValueError('Complete source-action provenance required')
    mapped = [name for table in metadata['action_maps'].values() for name in table.values()]
    if len(set(mapped)) != len(mapped) or set(mapped) != set(domain.actions):
        raise ValueError('Complete unique source-action provenance required; adapted or unmapped actions need a separate policy')
    if set(metadata.get('constant_maps', {})) != set(metadata['sources']):
        raise ValueError('Complete source-constant provenance required')
    constants = [name for table in metadata['constant_maps'].values() for name in table.values()]
    if len(set(constants)) != len(constants) or set(constants) != set(domain.constants):
        raise ValueError('Complete unique source-constant provenance required')
    problem = parse_sexpr(problem_path.read_text(encoding='utf-8'))
    _, certificate = select_component(metadata, domain, problem, seeds)
    retained = {name for source in certificate['selected_sources']
                for name in metadata['action_maps'][source].values()}
    if retained - set(domain.actions):
        raise ValueError('Incomplete compiled action provenance')
    reduced = copy.deepcopy(domain)
    reduced.actions = {name: action for name, action in domain.actions.items() if name in retained}
    write_domain(reduced, output)
    PDDLReader().parse_problem(str(output), str(problem_path))
    certificate.update(policy='static_universe_components',
        full_compiled_domain_sha256=expected,
        compiled_metadata_sha256=digest(compiled / 'meta_domain.json'),
        mapped_problem_sha256=digest(problem_path),
        selected_domain_sha256=digest(output),
        domain_pin_basis='compiler_export_hash' if exported else 'explicit_external_frozen_registry_hash',
        vocabulary_policy='Retain complete declarations, constants and exact mapped problem; select whole source action sets',
        original_action_count=len(domain.actions), selected_action_count=len(reduced.actions),
        retained_actions=sorted(reduced.actions),
        excluded_actions=sorted(set(domain.actions) - retained),
        parameterized_before_search=True)
    return certificate

"""Causal source profiles for saved finite Glaive traces with state-update axioms."""

from collections import Counter, defaultdict
from itertools import product
from pathlib import Path

from .causal_attribution import (
    VERSION, _domain, _source_branches, _verdict, file_digest, value_digest,
)
from .glaive_intake import casefold_tree
from .native_axiom_replay import _holds, replay_native_axioms
from .pddl import parse_sexpr

PROFILE_VERSION = 'action-source-paths-with-axiom-and-effect-support-v1'


class _SupportGraph:
    def __init__(self, actions, mapping, provenance, limit):
        self.actions = actions
        self.mapping = mapping
        self.provenance = provenance
        self.limit = limit
        self.owners = {}
        self.nodes = []

    def _alternatives(self, expr, state, positive=True):
        """Enumerate positive incoming links in the true NNF alternatives."""
        if isinstance(expr, bool):
            return {frozenset()} if expr == positive else set()
        head, *args = expr
        if head == 'not':
            return self._alternatives(args[0], state, not positive)
        if head not in ('and', 'or'):
            if (expr in state) != positive:
                return set()
            return {frozenset([(self.owners[expr], expr)]) if positive and expr in self.owners
                    else frozenset()}
        if not positive:
            head = 'and' if head == 'or' else 'or'
        options = {frozenset()} if head == 'and' else set()
        for child in args:
            choices = self._alternatives(child, state, positive)
            if head == 'and':
                options = {left | right for left in options for right in choices}
            else:
                options.update(choices)
            if len(options) > self.limit:
                raise ValueError('support_enumeration_limit')
        return options

    def _node(self, kind, label, options, action=None):
        if not options:
            raise ValueError('missing_support_alternative')
        if len(options) > self.limit:
            raise ValueError('support_enumeration_limit')
        index = len(self.nodes)
        self.nodes.append({'kind': kind, 'label': label, 'action': action,
                           'options': sorted(options, key=lambda x: (x[0] or '', sorted(x[1])))})
        return index

    def action(self, step, name, bindings, state, ground):
        fields = self.actions[name]
        options = set()
        for branch in _source_branches(name, fields, self.mapping, self.provenance):
            condition = ground(branch['precondition'], bindings)
            for parents in self._alternatives(condition, state):
                options.add((branch['source'], parents))
        self.current_action = self._node('action', [step, name], options)

    def _writes(self, kind, state, effects, adds, deletes, action=None):
        fresh = adds - state
        choices = defaultdict(set)
        for guard, positive, atom in effects:
            if positive and atom in fresh and _holds(guard, state):
                choices[atom].update(self._alternatives(guard, state))
        updates = {}
        for atom in sorted(fresh):
            options = choices[atom]
            if action is not None and options == {frozenset()}:
                updates[atom] = action
                continue
            if action is not None:
                # This effect carries the action's source and inherits the
                # action precondition without making its guard support every
                # other effect of the same action.
                options = {edges | {(action, ())} for edges in options}
            updates[atom] = self._node(kind, list(atom), {(None, edges) for edges in options}, action)
        for atom in deletes:
            self.owners.pop(atom, None)
        self.owners.update(updates)

    def effect(self, state, effects, adds, deletes):
        self._writes('conditional_effect', state, effects, adds, deletes, self.current_action)

    def axiom(self, state, effects, adds, deletes):
        self._writes('axiom', state, effects, adds, deletes)

    def goal(self, goal, state):
        self._node('goal', None, {(None, edges) for edges in self._alternatives(goal, state)})

    def profile(self, selected_sources, max_interpretations):
        # Ignore choices that cannot lead to any support of the final goal.
        goal = len(self.nodes) - 1
        relevant = {goal}
        for index in range(goal, -1, -1):
            if index in relevant:
                relevant.update(p for _, parents in self.nodes[index]['options'] for p, _ in parents)
        indices = sorted(relevant)
        choices = [self.nodes[i]['options'] for i in indices]
        total = 1
        for options in choices:
            total *= len(options)
            if total > max_interpretations:
                raise ValueError('interpretation_limit')
        counts, witnesses = Counter(), {}
        for interpretation in product(*choices):
            count, path = self._maximum(indices, interpretation, selected_sources)
            counts[count] += 1
            if str(count) not in witnesses:
                witnesses[str(count)] = {
                    'path': path,
                    'support': [
                        {'node': i, 'kind': self.nodes[i]['kind'], 'label': self.nodes[i]['label'],
                         'source': source, 'parents': sorted(parents)}
                        for i, (source, parents) in zip(indices, interpretation)
                    ],
                }
        lo, hi = min(counts), max(counts)
        thresholds = {str(j): _verdict(sum(n for count, n in counts.items() if count >= j), total)
                      for j in range(2, len(selected_sources) + 1)}
        return {'status': 'classified', 'version': PROFILE_VERSION, 'exact_count': lo if lo == hi else None,
                'minimum_over_interpretations': lo, 'maximum_over_interpretations': hi,
                'interpretations_examined': total, 'at_least': thresholds,
                'interpretation_count_by_maximum_chain_sources': dict(sorted(counts.items())),
                'witnesses': witnesses}

    def _maximum(self, indices, interpretation, selected_sources):
        sources = dict(zip(indices, (source for source, _ in interpretation)))
        relevant = {indices[-1]}
        for i, (_, parents) in reversed(list(zip(indices, interpretation))):
            if i in relevant:
                relevant.update(parent for parent, _ in parents)
        paths = {}
        best_count, best_path = 0, []
        for i, (source, parents) in zip(indices, interpretation):
            if i not in relevant:
                continue
            node = self.nodes[i]
            if node['action'] is not None:
                source = sources[node['action']]
            if source is not None and source not in selected_sources:
                raise ValueError('path_source_outside_selected_group')
            current = {}
            if source is not None:
                current[frozenset([source]), source, False] = [i]
            for parent, fact in sorted(parents):
                for (covered, previous, shared), path in paths[parent].items():
                    shared |= bool(fact and fact[0].startswith('shared_'))
                    if source is None:
                        key = (covered, previous, shared)
                    elif source == previous or shared:
                        key = (covered | {source}, source, False)
                    else:
                        continue
                    current.setdefault(key, path + [i])
            paths[i] = current
            for (covered, _, _), path in current.items():
                if len(covered) > best_count:
                    best_count, best_path = len(covered), path
        return best_count, best_path


def causal_trace_with_axioms(domain, problem, plan, mapping, *, provenance=None,
                             selected_sources, max_interpretations=4096, max_supports=256):
    """Trace positive support, preserving alternative action branches and proofs."""
    result = {'status': 'unknown', 'version': PROFILE_VERSION}
    try:
        selected_sources = set(selected_sources)
        if len(selected_sources) < 2 or min(max_interpretations, max_supports) < 1:
            raise ValueError('invalid_attribution_scope')
        tree, actions = _domain(domain)
        if any(isinstance(x, list) and x and x[0] == ':derived' for x in tree):
            raise ValueError('pddl_derived_predicate_outside_native_axiom_fragment')
        if provenance is not None and (provenance['version'] != VERSION
                or provenance['domain_sha256'] != file_digest(domain)
                or provenance['mapping_digest'] != value_digest(mapping)):
            raise ValueError('stale_branch_provenance')
        graph = _SupportGraph(actions, mapping, provenance, max_supports)
        inputs = [tree, *(parse_sexpr(Path(path).read_text(encoding='utf-8')) for path in (problem, plan))]
        physical = replay_native_axioms(*(casefold_tree(x) for x in inputs),
                                        quantified_action_effects=True, observer=graph)
        result['physical'] = physical
        if physical['status'] != 'replayed' or physical['goal'] is not True:
            raise ValueError('independent_physical_replay_failed')
        profile = graph.profile(selected_sources, max_interpretations)
        result.update(status='classified', source_count_profile=profile)
    except (KeyError, ValueError, TypeError, IndexError) as exc:
        result['reason'] = str(exc)
    return result


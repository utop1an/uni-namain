"""Bounded, independently generated source-only traces in both directions.

Complete finite source-atom projection is checked, including false facts. The
full target-universe direction reports nontransportable object bindings rather
than pretending that a partial inverse is a source-local counterexample.
"""
from collections import Counter
import random
import time

from unified_planning.engines.compilers.grounder import GrounderHelper
from unified_planning.model.fluent import get_all_fluent_exp
from unified_planning.shortcuts import SequentialSimulator

from rcnc.state_grounding import PositiveStateGrounding, successor_atoms


DEFAULT_DIRECTIONS = ('forward', 'reverse_source_objects', 'reverse_full_universe')


def replay_directions(budget):
    """Old protocols retain both directions; new protocols may register forward only."""
    values = budget.get('directions', list(DEFAULT_DIRECTIONS))
    if (not isinstance(values, list) or not values or
            any(value not in DEFAULT_DIRECTIONS for value in values) or
            len(set(values)) != len(values)):
        raise ValueError('Replay directions must be a nonempty unique list of supported directions')
    return values


class ReplayLimit(Exception):
    pass


class Explorer:
    def __init__(self, problem, simulator, actions, budget, deadline, allowed_objects=None):
        self.problem, self.simulator = problem, simulator
        self.actions = sorted(actions, key=lambda a: a.name)
        self.budget, self.deadline, self.allowed_objects = budget, deadline, allowed_objects
        self.grounder = GrounderHelper(problem, prune_actions=True)
        self.targets, self.cache = set(), {}
        self.stats = Counter()

    def check(self):
        if time.monotonic() >= self.deadline:
            raise ReplayLimit('time_limit')

    def advance(self, state, atoms, action, args):
        self.check()
        args = tuple(self.problem.environment.expression_manager.auto_promote(*args))
        if not self.simulator.is_applicable(state, action, args):
            return None
        after = self.simulator.apply(state, action, args)
        if after is None:
            raise ValueError('Public applicability and simulator application disagree')
        grounded = self.grounder.ground_action(action, args)
        if grounded is None:
            raise ValueError('Applicable action simplified to None')
        following = successor_atoms(self.problem, grounded, after, atoms,
                                    self.grounder.simplifier, self.targets,
                                    self.budget['max_atoms'], self.stats)
        if following is None:
            raise ReplayLimit('effect_atom_limit')
        return after, following

    def successors(self, state, atoms):
        self.check()
        if atoms in self.cache:
            return self.cache[atoms]
        if len(self.cache) >= self.budget['max_states']:
            raise ReplayLimit('state_limit')
        candidates = PositiveStateGrounding(self.problem, atoms)
        values = []
        for action in self.actions:
            for args in candidates.parameters(action):
                self.check()
                self.stats['candidate_bindings'] += 1
                if self.stats['candidate_bindings'] > self.budget['max_candidates']:
                    raise ReplayLimit('candidate_limit')
                if self.allowed_objects is not None and any(a.object().name not in self.allowed_objects for a in args):
                    continue
                next_state = self.advance(state, atoms, action, args)
                if next_state is not None:
                    values.append((action, tuple(args), *next_state))
        self.cache[atoms] = values
        self.stats['expanded_states'] = len(self.cache)
        return values


def atom_projection(source, target, predicates, objects, orders, maximum):
    if set(objects) != {o.name for o in source.all_objects} or len(set(objects.values())) != len(objects):
        raise ValueError('Complete injective object mapping required')
    if set(predicates) != {f.name for f in source.fluents} or len(set(predicates.values())) != len(predicates):
        raise ValueError('Complete injective source predicate mapping required')
    pairs = {}
    types = {}
    for fluent in source.fluents:
        mapped = target.fluent(predicates[fluent.name])
        order = orders.get(fluent.name, list(range(len(fluent.signature))))
        if sorted(order) != list(range(len(fluent.signature))) or len(mapped.signature) != len(order):
            raise ValueError('Complete bijective predicate argument order required')
        for atom in get_all_fluent_exp(source, fluent):
            if len(pairs) >= maximum:
                raise ReplayLimit('projection_atom_limit')
            args = [target.object(objects[a.object().name]) for a in atom.args]
            args = [args[i] for i in order]
            for arg, parameter in zip(args, mapped.signature):
                allowed = types.setdefault(parameter.type, set(target.objects(parameter.type)))
                if arg not in allowed:
                    raise ValueError('Source atom is outside target predicate type: ' + str(atom))
            translated = mapped(*args)
            if translated in pairs:
                raise ValueError('Source atom projection is not injective')
            pairs[translated] = atom
    return pairs


def run_pair(source, target, mapping, budget, checkpoint=None):
    for problem in (source, target):
        if any(not f.type.is_bool_type() for f in problem.fluents):
            raise ValueError('Boolean fluents required')
        if any(not v.is_false() for v in problem.fluents_defaults.values()):
            raise ValueError('False Boolean defaults required')
    objects, predicates, actions = mapping['objects'], mapping['predicates'], mapping['actions']
    # positions[target_parameter_index] = source_parameter_index. This is
    # explicitly the inverse convention of action_alpha's source-to-target map.
    inverse_objects = {v: k for k, v in objects.items()}
    inverse_actions = {v['target']: k for k, v in actions.items()}
    if set(actions) != {a.name for a in source.actions} or len(inverse_actions) != len(actions):
        raise ValueError('Complete injective source action mapping required')
    for name, binding in actions.items():
        count = len(source.action(name).parameters)
        if sorted(binding['positions']) != list(range(count)) or len(target.action(binding['target']).parameters) != count:
            raise ValueError('Complete bijective action parameter mapping required')
    pairs = atom_projection(source, target, predicates, objects, mapping.get('orders', {}), budget['max_atoms'])
    deadline = time.monotonic() + budget['seconds']
    directions = replay_directions(budget)
    rows = [{'id': f'{direction}__{seed}', 'direction': direction, 'seed': seed,
             'status': 'not_started', 'steps': 0} for direction in directions for seed in budget['seeds']]
    report = {'status': 'running', 'rows': rows, 'task_count': len(rows),
              'source_atoms': len(pairs), 'projection': 'complete_finite_source_boolean_universe',
              'sampling': 'seeded_walk_preferring_unvisited_states_then_less_used_ground_actions',
              'scope': 'Source-only action traces from the same explicit world; sampled evidence, not universal equivalence.'}
    with SequentialSimulator(source) as ss, SequentialSimulator(target) as ts:
        original_atoms = frozenset(a for a, v in source.explicit_initial_values.items() if v.is_true())
        mapped_atoms = frozenset(a for a, v in target.explicit_initial_values.items() if v.is_true())
        for direction in directions:
            left = Explorer(source, ss, source.actions, budget, deadline)
            right = Explorer(target, ts, [target.action(n) for n in inverse_actions], budget, deadline,
                             set(inverse_objects) if direction == 'reverse_source_objects' else None)
            for row in [r for r in rows if r['direction'] == direction]:
                trace_deadline = min(deadline, time.monotonic() + budget.get('seconds_per_trace', budget['seconds']))
                left.deadline = right.deadline = trace_deadline
                rng = random.Random(row['seed'])
                a, b, x, y = ss.get_initial_state(), ts.get_initial_state(), original_atoms, mapped_atoms
                visited, used, trace = {x if direction == 'forward' else y}, Counter(), []
                row.update(status='running', truth_checks=0, repeated_states=0, unique_states=1,
                           first_repeat_step=None, goal_reached_source=False, goal_reached_target=False)
                try:
                    for index in range(budget['max_depth'] + 1):
                        left.check()
                        projected = frozenset(pairs[v] for v in y if v in pairs)
                        row['truth_checks'] += len(pairs)
                        if x != projected:
                            row.update(status='truth_mismatch', at_step=index,
                                       source_only=sorted(map(str, x - projected))[:10],
                                       target_only=sorted(map(str, projected - x))[:10])
                            break
                        sg, tg = ss.is_goal(a), ts.is_goal(b)
                        row['goal_reached_source'] |= sg
                        row['goal_reached_target'] |= tg
                        if sg != tg:
                            row.update(status='goal_mismatch', at_step=index)
                            break
                        if index == budget['max_depth']:
                            row.update(status='pass_sampled', stop_reason='depth_limit')
                            break
                        origin = left if direction == 'forward' else right
                        choices = origin.successors(a if direction == 'forward' else b, x if direction == 'forward' else y)
                        if not choices:
                            row.update(status='pass_sampled' if trace else 'no_executable_actions', stop_reason='dead_end')
                            break
                        scores = [(c[3] in visited, used[(c[0].name, tuple(str(v) for v in c[1]))]) for c in choices]
                        best = min(scores)
                        action, args, after, positive = rng.choice([c for c, score in zip(choices, scores) if score == best])
                        names = [v.object().name for v in args]
                        record = {'origin_action': action.name, 'arguments': names}
                        trace.append(record)
                        if direction == 'forward':
                            binding = actions[action.name]
                            other = target.action(binding['target'])
                            values = [target.object(objects[names[i]]) for i in binding['positions']]
                            mapped = right.advance(b, y, other, values)
                            if mapped is not None:
                                a, x, (b, y) = after, positive, mapped
                        else:
                            foreign = [n for n in names if n not in inverse_objects]
                            if foreign:
                                row.update(status='outside_source_object_universe', at_step=index + 1, foreign_objects=foreign)
                                break
                            name = inverse_actions[action.name]
                            other = source.action(name)
                            positions = actions[name]['positions']
                            values = [None] * len(names)
                            for j, i in enumerate(positions):
                                values[i] = source.object(inverse_objects[names[j]])
                            mapped = left.advance(a, x, other, values)
                            if mapped is not None:
                                b, y, (a, x) = after, positive, mapped
                        record['transported_action'] = other.name
                        record['transported_arguments'] = [v.name for v in values]
                        if mapped is None:
                            row.update(status='applicability_mismatch', at_step=index + 1)
                            break
                        row['steps'] += 1
                        if positive in visited:
                            row['repeated_states'] += 1
                            if row['first_repeat_step'] is None:
                                row['first_repeat_step'] = index + 1
                        visited.add(positive)
                        used[(action.name, tuple(names))] += 1
                        row['unique_states'] = len(visited)
                    row['trace'] = trace
                except ReplayLimit as exc:
                    row.update(status=str(exc), trace=trace)
                except Exception as exc:
                    row.update(status='replay_error', reason=f'{type(exc).__name__}: {exc}', trace=trace)
                if checkpoint:
                    checkpoint(report)
            report.setdefault('generation', {})[direction] = {'source': dict(left.stats), 'target': dict(right.stats)}
    report.update(status='complete', status_counts=dict(Counter(r['status'] for r in rows)))
    return report

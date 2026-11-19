import copy
import json
from pathlib import Path
import tempfile
import unittest

from rcnc.domain_building import check_raw_declarations
from rcnc.interface_annotation import build_packet, digest
from rcnc.interface_evaluation import evaluate
from rcnc.pddl import parse_sexpr
from rcnc.prospective_evaluation import audit_task_registry, lexical_alignment, lexical_predictions
from scripts.annotation.run_annotation_predictions import check_response
from scripts.experiments.prepare_casefold_followup import casefold_ast


class ProspectiveEvaluationTests(unittest.TestCase):
    def setUp(self):
        self.root = Path(self.enterContext(tempfile.TemporaryDirectory()))
        self.inputs = self.root / 'inputs'
        self.inputs.mkdir()
        for source in ('A', 'B'):
            (self.inputs / (source + '_domainfile.pddl')).write_text(
                f'(define (domain {source}) (:requirements :strips :typing) '
                '(:types item place) (:predicates (at ?x - item ?y - place) (done ?x - item)) '
                '(:action finish :parameters (?x - item ?y - place) '
                ':precondition (at ?x ?y) :effect (done ?x)))', encoding='utf-8')
        build_packet(self.inputs, self.root / 'packet', per_stratum=8)
        self.packet = json.loads((self.root / 'packet/packet.json').read_text(encoding='utf-8'))

    def test_name_baseline_is_valid_machine_output_not_gold(self):
        result = lexical_predictions(self.packet, 'same_name_and_arity')
        self.assertEqual(len(self.packet['items']), result['total'])
        for item, row in zip(self.packet['items'], result['rows']):
            self.assertEqual([], check_response(self.packet, item, row['response']))
        score = evaluate(self.packet, [], result, digest(self.packet))
        self.assertEqual('needs_valid_independent_annotations', score['status'])
        self.assertNotIn('metrics', score)
        self.assertEqual(0, result['independent_labels_created'])

    def test_no_merge_abstains_instead_of_fabricating_negative_labels(self):
        rows = lexical_predictions(self.packet, 'no_merge')['rows']
        self.assertTrue(all(r['response']['label'] == 'uncertain' for r in rows))
        self.assertTrue(all(r['response']['right_from_left'] is None for r in rows))

    def test_missing_context_forces_abstention(self):
        item = self.packet['items'][0]
        item['sides'][1]['predicate'] = item['sides'][0]['predicate']
        item['sides'][1]['action_contexts'] = []
        result = lexical_predictions(self.packet, 'same_name_and_arity')
        self.assertEqual('uncertain', result['rows'][0]['response']['label'])

    def test_alignment_keeps_source_hashes_and_explicit_role_types(self):
        spec = lexical_alignment(self.inputs)
        self.assertEqual(2, len(spec['predicate_groups']))
        self.assertEqual(2, len(spec['source_sha256']))
        self.assertFalse(spec['object_identity_inferred'])
        self.assertFalse(spec['initial_facts_inferred'])
        self.assertEqual('machine_hypothesis', spec['decision_basis'])
        self.assertTrue(spec['type_groups'])
        for group in spec['predicate_groups']:
            self.assertEqual(2, len(group['members']))

    def registry(self):
        hashes = {'A_domainfile.pddl': 'a', 'B_domainfile.pddl': 'b'}
        task = {'id': 'a_b_1', 'sources': ['A', 'B'], 'source_sha256': hashes, 'source_availability': 'available',
                'query': {'objects': {}, 'initial': [], 'goal': {'positive': [['B:done', 'x']]}},
                'provenance': {'author_id': 'synthetic_fixture_not_human', 'authored_at': '2026-10-26',
                    'goal_meaning': 'Test intake shape only', 'independent_of_method_development': True,
                    'unexposed_to_predictions_plans_outcomes': True}}
        return {'task_count': 1, 'tasks': [task]}, hashes

    def test_explicit_empty_state_allowed_but_missing_state_rejected(self):
        registry, hashes = self.registry()
        result = audit_task_registry(registry, hashes)
        self.assertEqual(1, result['ready_for_semantic_and_mapping_review'])
        self.assertFalse(result['independence_verified'])
        self.assertEqual(0, result['planner_calls'])
        del registry['tasks'][0]['query']['initial']
        self.assertIn('missing_explicit_initial', audit_task_registry(registry, hashes)['rows'][0]['missing'])

    def test_hash_drift_and_exposure_cannot_become_ready(self):
        registry, hashes = self.registry()
        registry['tasks'][0]['source_sha256'] = {}
        registry['tasks'][0]['provenance']['unexposed_to_predictions_plans_outcomes'] = False
        result = audit_task_registry(registry, hashes)
        self.assertEqual(0, result['ready_for_semantic_and_mapping_review'])
        self.assertIn('source_hash_mismatch', result['rows'][0]['missing'])
        self.assertIn('outcome_blinding_not_declared', result['rows'][0]['missing'])

    def test_incomplete_duplicate_and_unknown_source_rejected(self):
        registry, hashes = self.registry()
        registry['task_count'] = 2
        with self.assertRaises(ValueError):
            audit_task_registry(registry, hashes)
        registry['tasks'].append(copy.deepcopy(registry['tasks'][0]))
        with self.assertRaises(ValueError):
            audit_task_registry(registry, hashes)
        registry, hashes = self.registry()
        registry['tasks'][0]['sources'] = ['A', 'foreign']
        self.assertIn('two_known_distinct_sources_required', audit_task_registry(registry, hashes)['rows'][0]['missing'])

    def test_blank_tasks_are_pending_not_planner_failures(self):
        registry, hashes = self.registry()
        registry['tasks'][0].update(query=None, provenance={})
        result = audit_task_registry(registry, hashes)
        self.assertEqual('needs_independent_task', result['rows'][0]['status'])
        self.assertFalse(result['rows'][0]['planner_called'])

    def test_empty_goal_not_a_trivial_success(self):
        registry, hashes = self.registry()
        registry['tasks'][0]['query']['goal'] = {'positive': []}
        self.assertIn('missing_nonempty_goal', audit_task_registry(registry, hashes)['rows'][0]['missing'])

    def test_unavailable_source_blocks_even_completed_author_fields(self):
        registry, hashes = self.registry()
        registry['tasks'][0]['source_availability'] = 'unsupported_source'
        result = audit_task_registry(registry, hashes)
        self.assertEqual(0, result['ready_for_semantic_and_mapping_review'])
        self.assertIn('source_not_available', result['rows'][0]['missing'])

    def test_query_cannot_override_alignment_or_budgets(self):
        registry, hashes = self.registry()
        registry['tasks'][0]['query']['alignment'] = {}
        self.assertIn('unexpected_query_fields', audit_task_registry(registry, hashes)['rows'][0]['missing'])

    def test_malformed_atoms_and_memberships_are_rejected(self):
        registry, hashes = self.registry()
        registry['tasks'][0]['query'].update(objects={'x': []}, initial=[[]], goal={'positive': [[]]})
        missing = audit_task_registry(registry, hashes)['rows'][0]['missing']
        for reason in ('malformed_object_membership', 'malformed_initial_atoms', 'malformed_goal_atoms'):
            self.assertIn(reason, missing)

    def test_case_normalization_preserves_signed_ast_and_rejects_duplicates(self):
        ast = parse_sexpr('(define (domain D) (:predicates (P ?X)) '
                         '(:action A :parameters (?X) :precondition (P ?X) :effect (not (p ?x))))')
        folded = casefold_ast(ast)
        self.assertEqual(['not', ['p', '?x']], folded[-1][-1])
        self.assertEqual(folded, casefold_ast(folded))
        check_raw_declarations(folded, 'fixture')
        with self.assertRaises(ValueError):
            check_raw_declarations(parse_sexpr('(define (domain d) (:predicates (p ?x ?x)))'), 'fixture')


if __name__ == '__main__':
    unittest.main()

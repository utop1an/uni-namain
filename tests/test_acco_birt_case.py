import hashlib
import json
from pathlib import Path
import tempfile
import unittest
from scripts.experiments.prepare_acco_birt_case import prepare
from rcnc.pddl import parse_domain, parse_sexpr
from rcnc.world_source_selection import select_component


class AccoBirtCaseTests(unittest.TestCase):
    def test_controls_preserve_world_goal_and_remove_only_declared_availability(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            inputs = root / 'matched/inputs'
            inputs.mkdir(parents=True)
            domains = {
                'ACCO': '(define (domain a) (:requirements :strips :typing) (:types entity item) '
                    '(:predicates (has ?x - entity ?i - item) (wealthy ?x - entity)) '
                    '(:action finish :parameters (?x - entity ?i - item) :precondition (has ?x ?i) :effect (wealthy ?x)))',
                'BIRT': '(define (domain b) (:requirements :strips :typing) (:types entity item location) '
                    '(:predicates (at ?x - entity ?l - location) (has ?x - entity ?i - item)) '
                    '(:action take :parameters (?x - entity ?i - item ?l - location) :precondition (at ?x ?l) :effect (has ?x ?i)))'}
            hashes = {}
            for source, text in domains.items():
                path = inputs / (source + '_domainfile.pddl')
                path.write_text(text, encoding='utf-8')
                hashes[path.name] = hashlib.sha256(path.read_bytes()).hexdigest()
                (inputs / (source + '_problemfile.pddl')).write_text(
                    '(define (problem p) (:domain ' + ('a' if source == 'ACCO' else 'b') + ') (:init) (:goal (and)))', encoding='utf-8')
            query = {'objects': {'hero': ['ACCO:entity', 'BIRT:entity'],
                                'token': ['ACCO:item', 'BIRT:item'], 'stage': 'BIRT:location'},
                'initial': [['BIRT:at', 'hero', 'stage']], 'goal': {'positive': [['ACCO:wealthy', 'hero']]},
                'alignment': {'version': 1, 'decision_basis': 'authored_assumption', 'source_sha256': hashes,
                    'type_groups': [{'members': ['ACCO:' + typ, 'BIRT:' + typ], 'evidence': 'fixture'} for typ in ('entity', 'item')],
                    'predicate_groups': [{'id': 'possession', 'evidence': 'fixture', 'members': [
                        {'predicate': s + ':has', 'order': [0, 1]} for s in ('ACCO', 'BIRT')]}]}}
            historical = root / 'history/runs/bridge_needed__authored_possession_interface__explicit_pair'
            historical.mkdir(parents=True)
            (historical / 'query.json').write_text(json.dumps(query), encoding='utf-8')
            output = root / 'case'
            protocol = prepare(root / 'matched', root / 'history', output)
            self.assertEqual(5, protocol['task_count'])
            self.assertEqual(1, len({t['problem_sha256'] for t in protocol['tasks'] if t['id'] != 'no_shared_identity'}))
            task_dir = output / 'bundle/tasks'
            full = parse_domain(task_dir / 'interface_pair/domain.pddl')
            acco = parse_domain(task_dir / 'ACCO_actions_only/domain.pddl')
            birt = parse_domain(task_dir / 'BIRT_actions_only/domain.pddl')
            self.assertEqual(set(full.actions), set(acco.actions) | set(birt.actions))
            self.assertFalse(set(acco.actions) & set(birt.actions))
            meta = json.loads((output / 'models/interface_pair/meta_domain.json').read_text())
            _, shared = select_component(meta, full, parse_sexpr((task_dir / 'interface_pair/problem.pddl').read_text()), 'ACCO')
            _, separate = select_component(meta, full, parse_sexpr((task_dir / 'no_shared_identity/problem.pddl').read_text()), 'ACCO')
            self.assertEqual(['ACCO', 'BIRT'], shared['selected_sources'])
            self.assertEqual(['ACCO'], separate['selected_sources'])

import hashlib
import json
from pathlib import Path
import re
import tempfile
import unittest
import zipfile

from rcnc.interface_annotation import digest
from scripts.annotation.prepare_external_annotations import prepare
from scripts.audit.admit_external_pddl import audit


def sha(data):
    return hashlib.sha256(data).hexdigest()


class ExternalPDDLWorkflowTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def snapshot(self, duplicate=False, name_overlap=False):
        root = self.root / 'snapshot'
        directory = root / 'fixture/files'
        directory.mkdir(parents=True)
        selection = {'repositories': [{'id': 'fixture', 'repository': 'synthetic/fixture',
            'commit': 'synthetic', 'metadata': ['README.md'], 'lineage': 'Synthetic test only'}],
            'candidates': [{'id': source, 'provider': 'fixture', 'family': source,
                'role': 'synthetic_auxiliary', 'domain': source + '.pddl',
                'problem': source + '_problem.pddl', 'annotation_selected': True} for source in ('A', 'B')],
            'missing_artifact_lead': {'decision': 'synthetic fixture'}}
        files = {'README.md': b'Synthetic provenance only; not real independent evidence.'}
        for source in ('A', 'B'):
            extra = '(:predicates (ready ?x - person))' if duplicate and source == 'B' else ''
            types = 'person hero' if name_overlap else 'person'
            files[source + '.pddl'] = (f'(define (domain {source.lower()}) (:requirements :strips :typing) '
                f'(:types {types}) (:predicates (ready ?x - person)) ' + extra +
                '(:action act :parameters (?x - person) :precondition (ready ?x) :effect (not (ready ?x))))').encode()
            files[source + '_problem.pddl'] = (f'(define (problem p) (:domain {source.lower()}) '
                '(:requirements :strips) (:objects hero - person) (:init (ready hero)) '
                '(:goal (not (ready hero))))').encode()
        entries, rows = [], []
        for name, data in files.items():
            (directory / name).write_bytes(data)
            blob = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
            entries.append({'path': name, 'sha': blob})
            rows.append({'provider': 'fixture', 'path': name, 'sha256': sha(data),
                'git_blob_sha1': blob, 'url': 'synthetic://' + name})
        tree_bytes = json.dumps({'tree': entries}).encode()
        (root / 'fixture/tree.json').write_bytes(tree_bytes)
        selection_bytes = json.dumps(selection).encode()
        (root / 'selection.json').write_bytes(selection_bytes)
        (root / 'manifest.json').write_text(json.dumps({'status': 'complete',
            'selection_sha256': sha(selection_bytes), 'files': rows,
            'repositories': [{**selection['repositories'][0], 'tree_sha256': sha(tree_bytes)}]}), encoding='utf-8')
        local = self.root / 'local'
        local.mkdir()
        return root, local

    def test_admission_preserves_failure_denominator_and_only_packages_headers(self):
        snapshot, local = self.snapshot(duplicate=True)
        result = audit(snapshot, local, self.root / 'audit', True)
        self.assertEqual(2, len(result['rows']))
        self.assertEqual({'admitted_compatibility_only': 1, 'not_admitted': 1}, result['counts'])
        self.assertEqual(['A'], result['annotation_selected_admitted'])
        changes = result['rows'][0]['packaging']['changes']
        self.assertTrue(changes['other_problem_sections_identical'])
        self.assertFalse(result['planner_called'])

    def test_blind_bundles_include_provenance_and_no_completed_labels(self):
        snapshot, local = self.snapshot()
        audit(snapshot, local, self.root / 'audit', True)
        result = prepare([self.root / 'audit/report.json'], self.root / 'packet')
        self.assertEqual(2, result['source_count'])
        self.assertEqual(0, result['independent_labels_created'])
        with zipfile.ZipFile(self.root / 'packet/annotator_a.zip') as archive:
            self.assertEqual({'index.html', 'annotation_template.json', 'INSTRUCTIONS.txt'}, set(archive.namelist()))
            template = json.loads(archive.read('annotation_template.json'))
            self.assertIsNone(template['independent_of_model_and_solver_outcomes'])
            self.assertTrue(all(r['status'] == 'unreviewed' and r['label'] is None for r in template['rows']))
            html = archive.read('index.html').decode()
            payload = json.loads(re.search(r'id="payload">(.*?)</script>', html, re.S).group(1))
            self.assertEqual(result['packet_sha256'], digest(payload['packet']))
            side = payload['packet']['items'][0]['sides'][0]
            self.assertEqual('synthetic_auxiliary', side['story_or_learner_provenance']['source_role'])
            self.assertNotIn('response', side)
            self.assertNotIn('goal', side)
        self.assertEqual((self.root / 'packet/annotator_a.zip').read_bytes(),
                         (self.root / 'packet/annotator_b.zip').read_bytes())

    def test_snapshot_drift_and_changed_annotation_source_are_rejected(self):
        snapshot, local = self.snapshot()
        audit(snapshot, local, self.root / 'audit', True)
        admitted = self.root / 'audit/annotation_inputs/A_domainfile.pddl'
        admitted.write_text('tampered', encoding='utf-8')
        with self.assertRaises(ValueError):
            prepare([self.root / 'audit/report.json'], self.root / 'bad_packet')
        (snapshot / 'fixture/files/A.pddl').write_text('tampered', encoding='utf-8')
        with self.assertRaises(ValueError):
            audit(snapshot, local, self.root / 'bad_audit', True)

    def test_name_policy_diagnostic_is_explicit_and_does_not_change_global_environment(self):
        from unified_planning.environment import get_environment
        snapshot, local = self.snapshot(name_overlap=True)
        original = get_environment().error_used_name
        strict = audit(snapshot, local, self.root / 'strict', True)
        self.assertEqual({'not_admitted': 2}, strict['counts'])
        relaxed = audit(snapshot, local, self.root / 'diagnostic', True, True)
        self.assertEqual({'admitted_compatibility_only': 2}, relaxed['counts'])
        self.assertEqual('same_bytes_parsed_with_error_used_name_false',
                         relaxed['rows'][0]['original_parser']['diagnostic'])
        self.assertEqual(original, get_environment().error_used_name)

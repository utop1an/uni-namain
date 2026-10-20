import hashlib
import json
from pathlib import Path
import tempfile
import unittest

from scripts.audit.audit_source_candidates import audit, inspect_text


class SourceCandidateAdmissionTests(unittest.TestCase):
    def test_comment_markers_are_not_semantic_feature_evidence(self):
        rows = inspect_text('; intends fake\n:actors (?p) ; :not-needs-intention\n(intends p (ready))')
        self.assertEqual([':actors', 'intends'], [r['marker'] for r in rows])
        self.assertEqual([2, 3], [r['line'] for r in rows])

    def test_hash_tampering_missing_files_and_unsupported_semantics(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            snapshot = root / 'snapshot'
            candidate = snapshot / 'candidate_files/originals/aladdin/genie.lbl'
            candidate.parent.mkdir(parents=True)
            data = b'(define (action act) :actors (?p) :effect (intends ?p (ready)))'
            candidate.write_bytes(data)
            blob = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
            tree = {'tree': [{'path': 'originals/aladdin/genie.lbl', 'sha': blob}]}
            tree_bytes = json.dumps(tree).encode()
            (snapshot / 'tree.json').write_bytes(tree_bytes)
            manifest = {'status': 'complete', 'commit': 'synthetic_fixture', 'families': ['aladdin'],
                'tree_sha256': hashlib.sha256(tree_bytes).hexdigest(),
                'files': [{'path': 'originals/aladdin/genie.lbl', 'sha256': hashlib.sha256(data).hexdigest(),
                           'git_blob_sha1': blob, 'url': 'synthetic_fixture'}]}
            manifest_path = snapshot / 'snapshot_manifest.json'
            manifest_path.write_text(json.dumps(manifest), encoding='utf-8')
            local = root / 'local'
            local.mkdir()
            (local / 'observed.pddl').write_bytes(data)
            attribution = root / 'attribution.tex'
            attribution.write_text('\\subsection{Aladdin}\nSynthetic provenance fixture.\\end{quote}', encoding='utf-8')
            result = audit(snapshot, local, attribution, root / 'report.json')
            self.assertEqual(0, result['admitted_families'])
            self.assertEqual(1, len(result['files'][0]['exact_local_matches']))
            self.assertEqual('unsupported_raw_source', result['files'][0]['parser']['status'])
            candidate.write_bytes(data + b' changed')
            with self.assertRaises(ValueError):
                audit(snapshot, local, attribution, root / 'tampered.json')
            candidate.write_bytes(data)
            manifest['files'] = []
            manifest_path.write_text(json.dumps(manifest), encoding='utf-8')
            with self.assertRaises(ValueError):
                audit(snapshot, local, attribution, root / 'incomplete.json')

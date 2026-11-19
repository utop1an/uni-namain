from pathlib import Path
import tempfile
import unittest

from rcnc.pddl import parse_sexpr
from rcnc.pddl_package import separate_pair, split_package, verify_package
from rcnc.domain_building import digest, save
from scripts.audit.separate_narrative_packages import TARGETS, load_adapters


class PDDLPackageTests(unittest.TestCase):
    def test_plan_separated_without_altering_problem_and_comments(self):
        model = b'(define (problem p) ; ignored ) (\r\n (:domain d) (:init (a)) (:goal (or (a) (b))))'
        data = b'; preface (\r\n' + model + b'\r\n<|Solution|>\r\n(define (plan p-solution) (:steps (act)))\r\n'
        parts = split_package(data, 'problem')
        self.assertEqual([p['role'] for p in parts], ['notes', 'problem', 'notes', 'plan', 'notes'])
        self.assertEqual(data[parts[1]['start']:parts[1]['end']], model)
        self.assertEqual(b''.join(data[p['start']:p['end']] for p in parts), data)
        with self.assertRaises(ValueError): parse_sexpr(data.decode())

    def test_error_message_is_opaque_not_a_repair_instruction(self):
        data = '(define (problem p) (:domain d) (:init) (:goal (a)))\n<|Error|>\n说明：add intentions (unbalanced'.encode('utf-8')
        parts = split_package(data, 'problem')
        self.assertEqual([p['role'] for p in parts], ['problem', 'notes'])
        self.assertNotIn(b'intentions', data[parts[0]['start']:parts[0]['end']])

    def test_missing_wrong_truncated_and_ambiguous_models_rejected(self):
        for data in [b'', b'Unable to parse problem', b'(define (problem p)',
                     b'(define (domain d))', b'(define (problem p)) (define (problem q))',
                     b'(define (problem p)) <|Solution|> (define (problem q))',
                     b'(define (problem p)) <|Solution|> (define (plan p)) (define (plan q))',
                     b'(define (problem p)) <|Error|> (define (problem q))',
                     b'(define (problem p)) extra undeclared text']:
            with self.subTest(data=data), self.assertRaises(ValueError): split_package(data, 'problem')

    def test_exact_utf8_byte_reconstruction_and_tamper_detection(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            domain, problem = root / 'd', root / 'p'
            domain.write_bytes('; 中文 (\r\n(define (domain d) (:predicates (a)))\r\n'.encode('utf-8'))
            problem.write_bytes(b'(define (problem p) (:domain d) (:init) (:goal (a)))\n<|Error|>\nno plan (')
            result = separate_pair(domain, problem, root / 'split')
            self.assertTrue(verify_package(result))
            self.assertIsNone(result['plan'])
            self.assertEqual(result['model_repairs'], 0)
            self.assertEqual(Path(result['sources']['domain']['original_copy']).read_bytes(), domain.read_bytes())
            Path(result['effective_problem']).write_bytes(b'(define (problem changed))')
            with self.assertRaises(ValueError): verify_package(result)

    def test_no_initial_state_inferred_from_plan(self):
        data = b'(define (problem p) (:domain d) (:goal (a)))\n<|Solution|>\n(define (plan p) (:steps (make-a)))'
        part = split_package(data, 'problem')[0]
        model = data[part['start']:part['end']]
        self.assertNotIn(b':init', model)
        self.assertNotIn(b'make-a', model)

    def test_existing_output_cannot_be_overwritten(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            with self.assertRaisesRegex(ValueError, 'Fresh'):
                separate_pair(root / 'missing', root / 'missing', root)

    def test_adapter_registry_keeps_raw_paths_and_rejects_selection_drift(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            domain, problem = root / 'd', root / 'p'
            domain.write_bytes(b'(define (domain d) (:predicates (a)))')
            problem.write_bytes(b'(define (problem p) (:domain d) (:init) (:goal (a)))\n<|Error|>no plan')
            rows = [{'id': key, **separate_pair(domain, problem, root / key)} for key in TARGETS]
            manifest = root / 'manifest.json'
            files = {str(p): digest(p) for p in root.rglob('*') if p.is_file()}
            payload = {'status': 'verified_lossless_packages', 'rows': rows, 'registered_rows': 10, 'files': files}
            save(manifest, payload)
            registry = [{'id': key, 'domain': str(domain), 'problem': str(problem)} for key in TARGETS]
            adapters, hashes = load_adapters(manifest, registry)
            self.assertEqual(len(adapters), 10)
            self.assertIn(str(manifest), hashes)
            self.assertEqual(registry[0]['problem'], str(problem))
            self.assertNotEqual(adapters[TARGETS[0]]['effective_problem'], str(problem))
            registry[0]['problem'] = str(domain)
            with self.assertRaisesRegex(ValueError, 'raw registry'): load_adapters(manifest, registry)
            payload['rows'] = rows[:-1]
            save(manifest, payload)
            with self.assertRaisesRegex(ValueError, 'approved ten'): load_adapters(manifest, registry)


if __name__ == '__main__': unittest.main()

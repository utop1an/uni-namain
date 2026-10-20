import tempfile
from pathlib import Path
import unittest
from scripts.data.prepare_source_probes import prepare
from rcnc.pddl import parse_sexpr, section


class SourceProbeTests(unittest.TestCase):
    def test_probes_preserve_world_and_are_independent_of_original_goal(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            inputs = root/'inputs'; inputs.mkdir()
            (inputs/'A_domainfile.pddl').write_text('''(define (domain a)
                (:requirements :strips :typing) (:types person - object) (:constants hero - person)
                (:predicates (ready ?p - person) (done ?p - person) (other ?p - person))
                (:action finish :parameters (?p - person) :precondition (ready ?p) :effect (done ?p)))''')
            problem = inputs/'A_problemfile.pddl'
            problem.write_text('(define (problem a) (:domain a) (:init (ready hero)) (:goal (other hero)))')
            first = prepare(inputs, root/'first')
            self.assertEqual(1, first['task_count'])
            path = root/'first/tasks/A__probe_0/problem.pddl'
            generated = parse_sexpr(path.read_text())
            original = parse_sexpr(problem.read_text())
            self.assertEqual(section(original, ':init'), section(generated, ':init'))
            self.assertNotEqual(section(original, ':goal'), section(generated, ':goal'))
            self.assertEqual(['done', 'hero'], first['tasks'][0]['goal'])
            problem.write_text('(define (problem a) (:domain a) (:init (ready hero)) (:goal (ready hero)))')
            second = prepare(inputs, root/'second')
            self.assertEqual(first['tasks'][0]['goal'], second['tasks'][0]['goal'])
            self.assertEqual(first['tasks'][0]['sampled_binding'], second['tasks'][0]['sampled_binding'])


if __name__ == '__main__':
    unittest.main()

import copy
import unittest

from scripts.audit.audit_action_removal import compare_domain
from rcnc.pddl import parse_sexpr
from scripts.data.prepare_action_removal import remove_actions


class ActionRemovalTests(unittest.TestCase):
    def test_only_actions_can_change(self):
        original = parse_sexpr('(define (domain example) (:predicates (p) (q)) '
            '(:action a :parameters () :precondition (p) :effect (q)) '
            '(:action b :parameters () :precondition (q) :effect (p)))')
        modified = remove_actions(original, {'b'})
        self.assertTrue(compare_domain(original, modified, {'b'}))
        changed_effect = copy.deepcopy(modified)
        changed_effect[-1][-1] = ['p']
        self.assertFalse(compare_domain(original, changed_effect, {'b'}))
        changed_vocabulary = copy.deepcopy(modified)
        changed_vocabulary[2].append(['unexpected'])
        self.assertFalse(compare_domain(original, changed_vocabulary, {'b'}))
        self.assertFalse(compare_domain(original, modified, {'a'}))
        self.assertFalse(compare_domain(original, original, {'b'}))


if __name__ == '__main__':
    unittest.main()

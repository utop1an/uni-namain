import unittest

from rcnc.action_alpha import structural_parameter_map, bind_full_arguments
from rcnc.pddl import parse_sexpr


def action(parameters, precondition, effect):
    return parse_sexpr(f'(:action a :parameters ({parameters}) :precondition {precondition} :effect {effect})')


class ActionAlphaTests(unittest.TestCase):
    def test_full_binding_never_truncates_duplicates_or_fills_unrecorded_roles(self):
        self.assertEqual(['b','a'],bind_full_arguments(['a','b'],[1,0],2))
        for mapping,arity in (([0],1),([0,0],2),([0,2],2),([False,1],2)):
            with self.assertRaises(ValueError):bind_full_arguments(['a','b'],mapping,arity)

    def test_unique_bijection_retains_all_arguments_and_uses_fixed_symbol_maps(self):
        source=action('?x ?y - t','(p ?x ?y)','(q ?x)')
        target=action('?a ?b - t','(pp ?b ?a)','(qq ?b)')
        result=structural_parameter_map(source,target,{'p':'pp','q':'qq'},{})
        self.assertEqual('unique_structural_map',result['status'])
        self.assertEqual([1,0],result['source_to_target_positions'])

    def test_ambiguity_and_incomplete_search_never_choose_an_arbitrary_map(self):
        source=action('?x ?y - t','(and)','(and)')
        target=action('?a ?b - t','(and)','(and)')
        self.assertEqual('ambiguous_structural_maps',structural_parameter_map(source,target,{}, {})['status'])
        limited=structural_parameter_map(source,target,{}, {},max_permutations=1)
        self.assertEqual('permutation_budget_limit',limited['status'])
        self.assertNotIn('source_to_target_positions',limited)

    def test_bound_variable_shadowing_does_not_capture_the_action_parameter(self):
        source=action('?x - t','(exists (?x - t) (p ?x))','(q ?x)')
        target=action('?a - t','(exists (?b - t) (pp ?b))','(qq ?a)')
        self.assertEqual('unique_structural_map',structural_parameter_map(source,target,{'p':'pp','q':'qq'}, {})['status'])
        captured=action('?a - t','(exists (?b - t) (pp ?a))','(qq ?a)')
        self.assertEqual('no_structural_map',structural_parameter_map(source,captured,{'p':'pp','q':'qq'}, {})['status'])

    def test_arity_change_never_drops_unused_parameters(self):
        source=action('?x ?unused - t','(p ?x)','(q ?x)')
        target=action('?a - t','(pp ?a)','(qq ?a)')
        self.assertEqual('arity_change_not_inferred',structural_parameter_map(source,target,{'p':'pp','q':'qq'}, {})['status'])

    def test_structural_mutation_type_change_and_missing_maps_are_not_equivalence(self):
        source=action('?x - t','(p ?x)','(q ?x)')
        changed=action('?a - t','(and (pp ?a) (extra ?a))','(qq ?a)')
        self.assertEqual('no_structural_map',structural_parameter_map(source,changed,{'p':'pp','q':'qq'}, {})['status'])
        other_type=action('?a - u','(pp ?a)','(qq ?a)')
        self.assertEqual('no_structural_map',structural_parameter_map(source,other_type,{'p':'pp','q':'qq'}, {})['status'])
        self.assertEqual('unsupported_structure',structural_parameter_map(source,changed,{}, {})['status'])


if __name__=='__main__':unittest.main()

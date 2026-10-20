(define (domain Soup_From_A_Sausage_Skewer)
   (:requirements
      :disjunctive-preconditions :strips :typing)

   (:types 
      entity - object
      item - object
      location - object
   )

   (:constants 
      ant_queen - entity
      castle - location
      crape_skewer - item
      elf_chief - entity
      first_traveler_mouse - entity
      forest - location
      fourth_traveler_mouse - entity
      jailer - entity
      jailer_granddaughter - entity
      kitchen - location
      library - location
      maypole - item
      mouse_king - entity
      north - location
      oak_dryad - entity
      old_lady_mouse - entity
      old_owl - entity
      phantaesus - entity
      sausage_skewer - item
      sea - location
      second_traveler_mouse - entity
      ship - location
      third_traveler_mouse - entity
      violet - item
      watchman - entity
      young_lady_mouse - entity
   )

   (:predicates 
      (anointed ?i - item)
      (at ?e - entity ?l - location)
      (captured ?e - entity)
      (escaped ?e - entity)
      (has_feeling ?e - entity)
      (has_imagination ?e - entity)
      (has_understanding ?e - entity)
      (holds ?e - entity ?i - item)
      (in_cage ?e - entity)
      (is_poet ?e - entity)
      (is_queen ?e - entity)
      (king_tail_stirred )
      (soup_effect_created ?e - entity)
   )

   (:action travel_to
     :parameters (?m - entity ?dest ?orig - location)
     :precondition (and (at ?m ?orig) (holds ?m sausage_skewer))
     :effect (and (at ?m ?dest) (not (at ?m ?orig)))
   )
   
   (:action give_skewer_to_elves
     :parameters (?elf ?m - entity)
     :precondition (holds ?m sausage_skewer)
     :effect (and (holds ?elf sausage_skewer) (not (holds ?m sausage_skewer)))
   )
   
   (:action receive_anointed_skewer
     :parameters (?elf ?m - entity ?v - item)
     :precondition (and (holds ?m sausage_skewer) (holds ?elf violet))
     :effect (anointed sausage_skewer)
   )
   
   (:action receive_feather
     :parameters (?dryad ?m ?ph - entity ?feather - item ?loc - location)
     :precondition (and (at ?m ?loc) (at ?dryad ?loc) (at ?ph ?loc) (holds ?dryad ?feather))
     :effect (and (holds ?m ?feather) (has_imagination ?m))
   )
   
   (:action learn_wisdom_from_ants
     :parameters (?m - entity ?ant_loc - location)
     :precondition (at ?m ?ant_loc)
     :effect (has_understanding ?m)
   )
   
   (:action read_and_digest_books
     :parameters (?m - entity ?lib - location)
     :precondition (at ?m library)
     :effect (has_feeling ?m)
   )
   
   (:action escape_jail
     :parameters (?m - entity)
     :precondition (captured ?m)
     :effect (and (escaped ?m) (not (captured ?m)) (not (in_cage ?m)))
   )
   
   (:action run_in_cage
     :parameters (?m - entity)
     :precondition (captured ?m)
     :effect (in_cage ?m)
   )
   
   (:action prepare_soup_by_elf_effect
     :parameters (?m - entity)
     :precondition (and (holds ?m sausage_skewer) (anointed sausage_skewer) (at ?m kitchen))
     :effect (soup_effect_created ?m)
   )
   
   (:action prepare_soup_by_poet_imagination
     :parameters (?m - entity)
     :precondition (and (has_understanding ?m) (has_imagination ?m) (has_feeling ?m))
     :effect (and (soup_effect_created ?m) (is_poet ?m))
   )
   
   (:action prepare_soup_by_king_tail
     :parameters (?k - entity)
     :precondition (at mouse_king kitchen)
     :effect (king_tail_stirred)
   )
   
   (:action claim_queenhood
     :parameters (?m - entity)
     :precondition (or (soup_effect_created ?m) (king_tail_stirred))
     :effect (is_queen ?m)
   )
)
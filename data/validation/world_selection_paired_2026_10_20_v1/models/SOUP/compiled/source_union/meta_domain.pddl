(define (domain narrative_union)
  (:requirements :disjunctive-preconditions :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d000__t_object - object
  )
  (:constants
    d000__c_ant_queen d000__c_elf_chief d000__c_first_traveler_mouse d000__c_fourth_traveler_mouse d000__c_jailer d000__c_jailer_granddaughter d000__c_mouse_king d000__c_oak_dryad d000__c_old_lady_mouse d000__c_old_owl d000__c_phantaesus d000__c_second_traveler_mouse d000__c_third_traveler_mouse d000__c_watchman d000__c_young_lady_mouse - d000__t_entity
    d000__c_crape_skewer d000__c_maypole d000__c_sausage_skewer d000__c_violet - d000__t_item
    d000__c_castle d000__c_forest d000__c_kitchen d000__c_library d000__c_north d000__c_sea d000__c_ship - d000__t_location
  )
  (:predicates
    (d000__p_anointed ?i - d000__t_item)
    (d000__p_at ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_captured ?e - d000__t_entity)
    (d000__p_escaped ?e - d000__t_entity)
    (d000__p_has_feeling ?e - d000__t_entity)
    (d000__p_has_imagination ?e - d000__t_entity)
    (d000__p_has_understanding ?e - d000__t_entity)
    (d000__p_holds ?e - d000__t_entity ?i - d000__t_item)
    (d000__p_in_cage ?e - d000__t_entity)
    (d000__p_is_poet ?e - d000__t_entity)
    (d000__p_is_queen ?e - d000__t_entity)
    (d000__p_king_tail_stirred)
    (d000__p_soup_effect_created ?e - d000__t_entity)
  )

  (:action d000__a_claim_queenhood
    :parameters (?m - d000__t_entity)
    :precondition (or (d000__p_soup_effect_created ?m) (d000__p_king_tail_stirred))
    :effect (d000__p_is_queen ?m)
  )

  (:action d000__a_escape_jail
    :parameters (?m - d000__t_entity)
    :precondition (d000__p_captured ?m)
    :effect (and (d000__p_escaped ?m) (not (d000__p_captured ?m)) (not (d000__p_in_cage ?m)))
  )

  (:action d000__a_give_skewer_to_elves
    :parameters (?elf - d000__t_entity ?m - d000__t_entity)
    :precondition (d000__p_holds ?m d000__c_sausage_skewer)
    :effect (and (d000__p_holds ?elf d000__c_sausage_skewer) (not (d000__p_holds ?m d000__c_sausage_skewer)))
  )

  (:action d000__a_learn_wisdom_from_ants
    :parameters (?m - d000__t_entity ?ant_loc - d000__t_location)
    :precondition (d000__p_at ?m ?ant_loc)
    :effect (d000__p_has_understanding ?m)
  )

  (:action d000__a_prepare_soup_by_elf_effect
    :parameters (?m - d000__t_entity)
    :precondition (and (d000__p_holds ?m d000__c_sausage_skewer) (d000__p_anointed d000__c_sausage_skewer) (d000__p_at ?m d000__c_kitchen))
    :effect (d000__p_soup_effect_created ?m)
  )

  (:action d000__a_prepare_soup_by_king_tail
    :parameters (?k - d000__t_entity)
    :precondition (d000__p_at d000__c_mouse_king d000__c_kitchen)
    :effect (d000__p_king_tail_stirred)
  )

  (:action d000__a_prepare_soup_by_poet_imagination
    :parameters (?m - d000__t_entity)
    :precondition (and (d000__p_has_understanding ?m) (d000__p_has_imagination ?m) (d000__p_has_feeling ?m))
    :effect (and (d000__p_soup_effect_created ?m) (d000__p_is_poet ?m))
  )

  (:action d000__a_read_and_digest_books
    :parameters (?m - d000__t_entity ?lib - d000__t_location)
    :precondition (d000__p_at ?m d000__c_library)
    :effect (d000__p_has_feeling ?m)
  )

  (:action d000__a_receive_anointed_skewer
    :parameters (?elf - d000__t_entity ?m - d000__t_entity ?v - d000__t_item)
    :precondition (and (d000__p_holds ?m d000__c_sausage_skewer) (d000__p_holds ?elf d000__c_violet))
    :effect (d000__p_anointed d000__c_sausage_skewer)
  )

  (:action d000__a_receive_feather
    :parameters (?dryad - d000__t_entity ?m - d000__t_entity ?ph - d000__t_entity ?feather - d000__t_item ?loc - d000__t_location)
    :precondition (and (d000__p_at ?m ?loc) (d000__p_at ?dryad ?loc) (d000__p_at ?ph ?loc) (d000__p_holds ?dryad ?feather))
    :effect (and (d000__p_holds ?m ?feather) (d000__p_has_imagination ?m))
  )

  (:action d000__a_run_in_cage
    :parameters (?m - d000__t_entity)
    :precondition (d000__p_captured ?m)
    :effect (d000__p_in_cage ?m)
  )

  (:action d000__a_travel_to
    :parameters (?m - d000__t_entity ?dest - d000__t_location ?orig - d000__t_location)
    :precondition (and (d000__p_at ?m ?orig) (d000__p_holds ?m d000__c_sausage_skewer))
    :effect (and (d000__p_at ?m ?dest) (not (d000__p_at ?m ?orig)))
  )
)

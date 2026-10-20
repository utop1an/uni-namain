(define (domain narrative_aligned)
  (:requirements :adl :disjunctive-preconditions :strips :typing)
  (:constants
    d000__c_ant_queen d000__c_castle d000__c_crape_skewer d000__c_elf_chief d000__c_first_traveler_mouse d000__c_forest d000__c_fourth_traveler_mouse d000__c_jailer d000__c_jailer_granddaughter d000__c_kitchen d000__c_library d000__c_maypole d000__c_mouse_king d000__c_north d000__c_oak_dryad d000__c_old_lady_mouse d000__c_old_owl d000__c_phantaesus d000__c_sausage_skewer d000__c_sea d000__c_second_traveler_mouse d000__c_ship d000__c_third_traveler_mouse d000__c_violet d000__c_watchman d000__c_young_lady_mouse - object
  )
  (:predicates
    (d000__p_anointed ?a0 - object)
    (d000__p_at ?a0 - object ?a1 - object)
    (d000__p_captured ?a0 - object)
    (d000__p_escaped ?a0 - object)
    (d000__p_has_feeling ?a0 - object)
    (d000__p_has_imagination ?a0 - object)
    (d000__p_has_understanding ?a0 - object)
    (d000__p_holds ?a0 - object ?a1 - object)
    (d000__p_in_cage ?a0 - object)
    (d000__p_is_poet ?a0 - object)
    (d000__p_is_queen ?a0 - object)
    (d000__p_king_tail_stirred)
    (d000__p_soup_effect_created ?a0 - object)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
  )

  (:action d000__a_claim_queenhood
    :parameters (?m - object)
    :precondition (and (typeguard__d000__t_entity ?m) (or (d000__p_soup_effect_created ?m) (d000__p_king_tail_stirred)))
    :effect (d000__p_is_queen ?m)
  )

  (:action d000__a_escape_jail
    :parameters (?m - object)
    :precondition (and (typeguard__d000__t_entity ?m) (d000__p_captured ?m))
    :effect (and (d000__p_escaped ?m) (not (d000__p_captured ?m)) (not (d000__p_in_cage ?m)))
  )

  (:action d000__a_give_skewer_to_elves
    :parameters (?elf - object ?m - object)
    :precondition (and (typeguard__d000__t_entity ?elf) (typeguard__d000__t_entity ?m) (d000__p_holds ?m d000__c_sausage_skewer))
    :effect (and (d000__p_holds ?elf d000__c_sausage_skewer) (not (d000__p_holds ?m d000__c_sausage_skewer)))
  )

  (:action d000__a_learn_wisdom_from_ants
    :parameters (?m - object ?ant_loc - object)
    :precondition (and (typeguard__d000__t_entity ?m) (typeguard__d000__t_location ?ant_loc) (d000__p_at ?m ?ant_loc))
    :effect (d000__p_has_understanding ?m)
  )

  (:action d000__a_prepare_soup_by_elf_effect
    :parameters (?m - object)
    :precondition (and (typeguard__d000__t_entity ?m) (and (d000__p_holds ?m d000__c_sausage_skewer) (d000__p_anointed d000__c_sausage_skewer) (d000__p_at ?m d000__c_kitchen)))
    :effect (d000__p_soup_effect_created ?m)
  )

  (:action d000__a_prepare_soup_by_king_tail
    :parameters (?k - object)
    :precondition (and (typeguard__d000__t_entity ?k) (d000__p_at d000__c_mouse_king d000__c_kitchen))
    :effect (d000__p_king_tail_stirred)
  )

  (:action d000__a_prepare_soup_by_poet_imagination
    :parameters (?m - object)
    :precondition (and (typeguard__d000__t_entity ?m) (and (d000__p_has_understanding ?m) (d000__p_has_imagination ?m) (d000__p_has_feeling ?m)))
    :effect (and (d000__p_soup_effect_created ?m) (d000__p_is_poet ?m))
  )

  (:action d000__a_read_and_digest_books
    :parameters (?m - object ?lib - object)
    :precondition (and (typeguard__d000__t_entity ?m) (typeguard__d000__t_location ?lib) (d000__p_at ?m d000__c_library))
    :effect (d000__p_has_feeling ?m)
  )

  (:action d000__a_receive_anointed_skewer
    :parameters (?elf - object ?m - object ?v - object)
    :precondition (and (typeguard__d000__t_entity ?elf) (typeguard__d000__t_entity ?m) (typeguard__d000__t_item ?v) (and (d000__p_holds ?m d000__c_sausage_skewer) (d000__p_holds ?elf d000__c_violet)))
    :effect (d000__p_anointed d000__c_sausage_skewer)
  )

  (:action d000__a_receive_feather
    :parameters (?dryad - object ?m - object ?ph - object ?feather - object ?loc - object)
    :precondition (and (typeguard__d000__t_entity ?dryad) (typeguard__d000__t_entity ?m) (typeguard__d000__t_entity ?ph) (typeguard__d000__t_item ?feather) (typeguard__d000__t_location ?loc) (and (d000__p_at ?m ?loc) (d000__p_at ?dryad ?loc) (d000__p_at ?ph ?loc) (d000__p_holds ?dryad ?feather)))
    :effect (and (d000__p_holds ?m ?feather) (d000__p_has_imagination ?m))
  )

  (:action d000__a_run_in_cage
    :parameters (?m - object)
    :precondition (and (typeguard__d000__t_entity ?m) (d000__p_captured ?m))
    :effect (d000__p_in_cage ?m)
  )

  (:action d000__a_travel_to
    :parameters (?m - object ?dest - object ?orig - object)
    :precondition (and (typeguard__d000__t_entity ?m) (typeguard__d000__t_location ?dest) (typeguard__d000__t_location ?orig) (and (d000__p_at ?m ?orig) (d000__p_holds ?m d000__c_sausage_skewer)))
    :effect (and (d000__p_at ?m ?dest) (not (d000__p_at ?m ?orig)))
  )
)

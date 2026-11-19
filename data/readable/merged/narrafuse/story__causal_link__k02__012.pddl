(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (shared_p_consensus_acbeb05588901756 ?v0 - object ?v1 - object)
    (shared_p_consensus_d4d9d4efc255e647 ?v0 - object)
    (shared_p_consensus_e94b83be899333bd ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_p_in-stasis ?v0 - object)
    (writing_prompts__wp_011_p_ancient-technology ?v0 - object)
    (writing_prompts__wp_011_p_propellant-device ?v0 - object)
    (writing_prompts__wp_011_p_shielded ?v0 - object)
    (writing_prompts__wp_011_p_requested-tow ?v0 - object ?v1 - object)
    (writing_prompts__wp_064_active)
    (writing_prompts__wp_064_type_character ?x - object)
    (writing_prompts__wp_064_type_item ?x - object)
    (writing_prompts__wp_064_type_object ?x - object)
    (writing_prompts__wp_064_type_place ?x - object)
    (writing_prompts__wp_064_p_delivered ?v0 - object)
  )

  (:action writing_prompts__wp_011_a_discover-technology
    :parameters (?character - object ?object - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (shared_p_consensus_d4d9d4efc255e647 ?character)
          (shared_p_consensus_acbeb05588901756 ?character ?place)
        )
      )
    :effect
      (and
        (shared_p_consensus_e94b83be899333bd ?character ?object)
        (writing_prompts__wp_011_p_ancient-technology ?object)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_detect-stasis
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (and
          (shared_p_consensus_d4d9d4efc255e647 ?character)
          (shared_p_consensus_e94b83be899333bd ?character ?object)
          (writing_prompts__wp_011_p_ancient-technology ?object)
        )
      )
    :effect
      (writing_prompts__wp_011_p_in-stasis ?object)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_request-tow
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (shared_p_consensus_d4d9d4efc255e647 ?character)
          (shared_p_consensus_acbeb05588901756 ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_011_p_requested-tow ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_transport-object
    :parameters (?character - object ?object - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?from)
        (writing_prompts__wp_011_type_place ?to)
        (and
          (shared_p_consensus_d4d9d4efc255e647 ?character)
          (shared_p_consensus_acbeb05588901756 ?character ?from)
          (shared_p_consensus_e94b83be899333bd ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_acbeb05588901756 ?character ?from))
        (shared_p_consensus_acbeb05588901756 ?character ?to)
        (not (shared_p_consensus_e94b83be899333bd ?character ?object))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_064_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_064_active)
        (writing_prompts__wp_064_type_character ?character)
        (writing_prompts__wp_064_type_place ?from)
        (writing_prompts__wp_064_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_d4d9d4efc255e647 ?character)
          (shared_p_consensus_acbeb05588901756 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_acbeb05588901756 ?character ?from))
        (shared_p_consensus_acbeb05588901756 ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_064_a_deliver
    :parameters (?character - object ?item - object ?destination - object)
    :precondition
      (and
        (writing_prompts__wp_064_active)
        (writing_prompts__wp_064_type_character ?character)
        (writing_prompts__wp_064_type_item ?item)
        (writing_prompts__wp_064_type_place ?destination)
        (and
          (shared_p_consensus_d4d9d4efc255e647 ?character)
          (shared_p_consensus_acbeb05588901756 ?character ?destination)
          (shared_p_consensus_e94b83be899333bd ?character ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e94b83be899333bd ?character ?item))
        (writing_prompts__wp_064_p_delivered ?item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_064_a_pick-up
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_064_active)
        (writing_prompts__wp_064_type_character ?character)
        (writing_prompts__wp_064_type_item ?item)
        (writing_prompts__wp_064_type_place ?place)
        (and
          (shared_p_consensus_d4d9d4efc255e647 ?character)
          (shared_p_consensus_acbeb05588901756 ?character ?place)
        )
      )
    :effect
      (shared_p_consensus_e94b83be899333bd ?character ?item)
    :agents (?character)
  )
)

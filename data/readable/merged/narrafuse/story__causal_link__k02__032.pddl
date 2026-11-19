(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (shared_p_consensus_a879862271161eb5 ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_p_alive ?v0 - object)
    (writing_prompts__wp_011_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_p_in-stasis ?v0 - object)
    (writing_prompts__wp_011_p_ancient-technology ?v0 - object)
    (writing_prompts__wp_011_p_propellant-device ?v0 - object)
    (writing_prompts__wp_011_p_shielded ?v0 - object)
    (writing_prompts__wp_011_p_requested-tow ?v0 - object ?v1 - object)
    (writing_prompts__wp_045_active)
    (writing_prompts__wp_045_type_box ?x - object)
    (writing_prompts__wp_045_type_character ?x - object)
    (writing_prompts__wp_045_type_object ?x - object)
    (writing_prompts__wp_045_type_place ?x - object)
    (writing_prompts__wp_045_p_in-box ?v0 - object ?v1 - object)
    (writing_prompts__wp_045_p_nervous ?v0 - object)
    (writing_prompts__wp_045_p_composed ?v0 - object)
    (writing_prompts__wp_045_p_noticed ?v0 - object ?v1 - object)
    (writing_prompts__wp_045_p_opened ?v0 - object)
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
          (writing_prompts__wp_011_p_alive ?character)
          (shared_p_consensus_a879862271161eb5 ?character ?place)
        )
      )
    :effect
      (and
        (writing_prompts__wp_011_p_has ?character ?object)
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
          (writing_prompts__wp_011_p_alive ?character)
          (writing_prompts__wp_011_p_has ?character ?object)
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
          (writing_prompts__wp_011_p_alive ?character)
          (shared_p_consensus_a879862271161eb5 ?character ?place)
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
          (writing_prompts__wp_011_p_alive ?character)
          (shared_p_consensus_a879862271161eb5 ?character ?from)
          (writing_prompts__wp_011_p_has ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_a879862271161eb5 ?character ?from))
        (shared_p_consensus_a879862271161eb5 ?character ?to)
        (not (writing_prompts__wp_011_p_has ?character ?object))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_enter
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
        (writing_prompts__wp_045_type_place ?place)
        (not (shared_p_consensus_a879862271161eb5 ?character ?place))
      )
    :effect
      (shared_p_consensus_a879862271161eb5 ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_notice
    :parameters (?character - object ?box - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
        (writing_prompts__wp_045_type_box ?box)
        (writing_prompts__wp_045_type_place ?place)
        (and
          (shared_p_consensus_a879862271161eb5 ?character ?place)
          (shared_p_consensus_a879862271161eb5 ?box ?place)
        )
      )
    :effect
      (writing_prompts__wp_045_p_noticed ?character ?box)
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_open-box
    :parameters (?character - object ?box - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
        (writing_prompts__wp_045_type_box ?box)
        (writing_prompts__wp_045_type_place ?place)
        (and
          (shared_p_consensus_a879862271161eb5 ?character ?place)
          (shared_p_consensus_a879862271161eb5 ?box ?place)
          (writing_prompts__wp_045_p_noticed ?character ?box)
          (not (writing_prompts__wp_045_p_opened ?box))
        )
      )
    :effect
      (writing_prompts__wp_045_p_opened ?box)
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_become-nervous
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
      )
    :effect
      (writing_prompts__wp_045_p_nervous ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_become-composed
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
      )
    :effect
      (writing_prompts__wp_045_p_composed ?character)
    :agents (?character)
  )
)

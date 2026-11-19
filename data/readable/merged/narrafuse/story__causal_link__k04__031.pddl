(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_034_active)
    (tiny_stories__story_034_type_character ?x - object)
    (tiny_stories__story_034_type_object ?x - object)
    (shared_p_consensus_6b84b806c51358dc ?v0 - object ?v1 - object)
    (shared_p_consensus_4e11a7d41f64b5e0 ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_recognize ?v0 - object ?v1 - object)
    (shared_p_consensus_990b0e2d04db33c7 ?v0 - object)
    (tiny_stories__story_075_active)
    (tiny_stories__story_075_type_character ?x - object)
    (tiny_stories__story_075_type_dress ?x - object)
    (tiny_stories__story_075_type_item ?x - object)
    (tiny_stories__story_075_type_object ?x - object)
    (tiny_stories__story_075_p_damaged ?v0 - object)
    (tiny_stories__story_075_p_happy ?v0 - object)
    (tiny_stories__story_093_active)
    (tiny_stories__story_093_type_character ?x - object)
    (tiny_stories__story_093_type_item ?x - object)
    (tiny_stories__story_093_type_mop ?x - object)
    (tiny_stories__story_093_type_object ?x - object)
    (tiny_stories__story_093_type_place ?x - object)
    (shared_p_consensus_2efb2ed4ff373188 ?v0 - object ?v1 - object)
    (shared_p_consensus_c8f106ea56f7767e ?v0 - object ?v1 - object)
    (tiny_stories__story_093_p_clean ?v0 - object)
    (tiny_stories__story_093_p_pretty ?v0 - object)
    (tiny_stories__story_093_p_disgusting ?v0 - object)
    (tiny_stories__story_093_p_selected ?v0 - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (writing_prompts__wp_011_p_in-stasis ?v0 - object)
    (writing_prompts__wp_011_p_ancient-technology ?v0 - object)
    (writing_prompts__wp_011_p_propellant-device ?v0 - object)
    (writing_prompts__wp_011_p_shielded ?v0 - object)
    (writing_prompts__wp_011_p_requested-tow ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character1 - object ?character2 - object) :context (and (tiny_stories__story_034_active) (tiny_stories__story_034_type_character ?character1) (tiny_stories__story_034_type_character ?character2) (and (tiny_stories__story_034_p_friends ?character1 ?character2) (not (exists (?mask - object) (and (tiny_stories__story_034_type_object ?mask) (shared_p_consensus_4e11a7d41f64b5e0 ?character2 ?mask)))))) :implies (tiny_stories__story_034_p_recognize ?character1 ?character2))

  (:action tiny_stories__story_034_a_find-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (shared_p_consensus_990b0e2d04db33c7 ?character)
      )
    :effect
      (shared_p_consensus_6b84b806c51358dc ?character ?mask)
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_wear-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (and
          (shared_p_consensus_990b0e2d04db33c7 ?character)
          (shared_p_consensus_6b84b806c51358dc ?character ?mask)
          (not (shared_p_consensus_4e11a7d41f64b5e0 ?character ?mask))
        )
      )
    :effect
      (shared_p_consensus_4e11a7d41f64b5e0 ?character ?mask)
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_remove-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (and
          (shared_p_consensus_990b0e2d04db33c7 ?character)
          (shared_p_consensus_4e11a7d41f64b5e0 ?character ?mask)
        )
      )
    :effect
      (not (shared_p_consensus_4e11a7d41f64b5e0 ?character ?mask))
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_recognize
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character1)
        (tiny_stories__story_034_type_character ?character2)
        (and
          (shared_p_consensus_990b0e2d04db33c7 ?character1)
          (shared_p_consensus_990b0e2d04db33c7 ?character2)
          (tiny_stories__story_034_p_friends ?character1 ?character2)
          (not (tiny_stories__story_034_p_recognize ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_034_p_recognize ?character1 ?character2)
    :agents (?character1)
  )

  (:action tiny_stories__story_075_a_put-on-dress
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (shared_p_consensus_6b84b806c51358dc ?character ?dress)
          (not (shared_p_consensus_4e11a7d41f64b5e0 ?character ?dress))
        )
      )
    :effect
      (shared_p_consensus_4e11a7d41f64b5e0 ?character ?dress)
    :agents (?character)
  )

  (:action tiny_stories__story_075_a_slip
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (shared_p_consensus_4e11a7d41f64b5e0 ?character ?dress)
          (not (tiny_stories__story_075_p_damaged ?dress))
        )
      )
    :effect
      (tiny_stories__story_075_p_damaged ?dress)
    :agents (?character)
  )

  (:action tiny_stories__story_075_a_comfort
    :parameters (?parent - object ?child - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?parent)
        (tiny_stories__story_075_type_character ?child)
        (and
          (not (tiny_stories__story_075_p_happy ?child))
          (not (= ?parent ?child))
        )
      )
    :effect
      (tiny_stories__story_075_p_happy ?child)
    :agents (?parent)
  )

  (:action tiny_stories__story_075_a_get-new-dress
    :parameters (?character - object ?old-dress - object ?new-dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?old-dress)
        (tiny_stories__story_075_type_dress ?new-dress)
        (and
          (tiny_stories__story_075_p_damaged ?old-dress)
          (shared_p_consensus_4e11a7d41f64b5e0 ?character ?old-dress)
          (not (shared_p_consensus_6b84b806c51358dc ?character ?new-dress))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_4e11a7d41f64b5e0 ?character ?old-dress))
        (shared_p_consensus_6b84b806c51358dc ?character ?new-dress)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_093_a_go-to
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_093_active)
        (tiny_stories__story_093_type_character ?character)
        (tiny_stories__story_093_type_place ?place)
        (shared_p_consensus_2efb2ed4ff373188 ?character ?place)
      )
    :effect
      (shared_p_consensus_2efb2ed4ff373188 ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_093_a_select-mop
    :parameters (?character - object ?mop - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_093_active)
        (tiny_stories__story_093_type_character ?character)
        (tiny_stories__story_093_type_mop ?mop)
        (tiny_stories__story_093_type_place ?place)
        (and
          (shared_p_consensus_2efb2ed4ff373188 ?character ?place)
          (shared_p_consensus_c8f106ea56f7767e ?character ?mop)
        )
      )
    :effect
      (tiny_stories__story_093_p_selected ?mop)
    :agents (?character)
  )

  (:action tiny_stories__story_093_a_receive-mop
    :parameters (?character - object ?dog - object ?mop - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_093_active)
        (tiny_stories__story_093_type_character ?character)
        (tiny_stories__story_093_type_character ?dog)
        (tiny_stories__story_093_type_mop ?mop)
        (tiny_stories__story_093_type_place ?place)
        (and
          (shared_p_consensus_2efb2ed4ff373188 ?character ?place)
          (shared_p_consensus_2efb2ed4ff373188 ?dog ?place)
          (shared_p_consensus_c8f106ea56f7767e ?dog ?mop)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c8f106ea56f7767e ?dog ?mop))
        (shared_p_consensus_c8f106ea56f7767e ?character ?mop)
      )
    :agents (?character)
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
          (shared_p_consensus_990b0e2d04db33c7 ?character)
          (shared_p_consensus_2efb2ed4ff373188 ?character ?place)
        )
      )
    :effect
      (and
        (shared_p_consensus_c8f106ea56f7767e ?character ?object)
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
          (shared_p_consensus_990b0e2d04db33c7 ?character)
          (shared_p_consensus_c8f106ea56f7767e ?character ?object)
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
          (shared_p_consensus_990b0e2d04db33c7 ?character)
          (shared_p_consensus_2efb2ed4ff373188 ?character ?place)
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
          (shared_p_consensus_990b0e2d04db33c7 ?character)
          (shared_p_consensus_2efb2ed4ff373188 ?character ?from)
          (shared_p_consensus_c8f106ea56f7767e ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2efb2ed4ff373188 ?character ?from))
        (shared_p_consensus_2efb2ed4ff373188 ?character ?to)
        (not (shared_p_consensus_c8f106ea56f7767e ?character ?object))
      )
    :agents (?character)
  )
)

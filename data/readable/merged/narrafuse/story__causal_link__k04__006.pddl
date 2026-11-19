(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_075_active)
    (tiny_stories__story_075_type_character ?x - object)
    (tiny_stories__story_075_type_dress ?x - object)
    (tiny_stories__story_075_type_item ?x - object)
    (tiny_stories__story_075_type_object ?x - object)
    (shared_p_consensus_2ddb75a7410f9a21 ?v0 - object ?v1 - object)
    (shared_p_consensus_bad974795eb62815 ?v0 - object ?v1 - object)
    (tiny_stories__story_075_p_damaged ?v0 - object)
    (tiny_stories__story_075_p_happy ?v0 - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (shared_p_consensus_acbeb05588901756 ?v0 - object ?v1 - object)
    (shared_p_consensus_118c9575d1047a54 ?v0 - object)
    (writing_prompts__wp_011_p_in-stasis ?v0 - object)
    (writing_prompts__wp_011_p_ancient-technology ?v0 - object)
    (writing_prompts__wp_011_p_propellant-device ?v0 - object)
    (writing_prompts__wp_011_p_shielded ?v0 - object)
    (writing_prompts__wp_011_p_requested-tow ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_active)
    (writing_prompts__wp_060_type_character ?x - object)
    (writing_prompts__wp_060_type_item ?x - object)
    (writing_prompts__wp_060_type_object ?x - object)
    (writing_prompts__wp_060_type_place ?x - object)
    (writing_prompts__wp_060_p_at ?v0 - object ?v1 - object)
    (shared_p_consensus_6946bdc0b63de2a6 ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_clean ?v0 - object)
    (writing_prompts__wp_060_p_locked ?v0 - object)
    (writing_prompts__wp_060_p_fits ?v0 - object ?v1 - object)
    (writing_prompts__wp_064_active)
    (writing_prompts__wp_064_type_character ?x - object)
    (writing_prompts__wp_064_type_item ?x - object)
    (writing_prompts__wp_064_type_object ?x - object)
    (writing_prompts__wp_064_type_place ?x - object)
    (writing_prompts__wp_064_p_alive ?v0 - object)
    (writing_prompts__wp_064_p_delivered ?v0 - object)
  )

  (:action tiny_stories__story_075_a_put-on-dress
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (shared_p_consensus_bad974795eb62815 ?character ?dress)
          (not (shared_p_consensus_2ddb75a7410f9a21 ?character ?dress))
        )
      )
    :effect
      (shared_p_consensus_2ddb75a7410f9a21 ?character ?dress)
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
          (shared_p_consensus_2ddb75a7410f9a21 ?character ?dress)
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
          (shared_p_consensus_2ddb75a7410f9a21 ?character ?old-dress)
          (not (shared_p_consensus_bad974795eb62815 ?character ?new-dress))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2ddb75a7410f9a21 ?character ?old-dress))
        (shared_p_consensus_bad974795eb62815 ?character ?new-dress)
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
          (shared_p_consensus_118c9575d1047a54 ?character)
          (shared_p_consensus_acbeb05588901756 ?character ?place)
        )
      )
    :effect
      (and
        (shared_p_consensus_bad974795eb62815 ?character ?object)
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
          (shared_p_consensus_118c9575d1047a54 ?character)
          (shared_p_consensus_bad974795eb62815 ?character ?object)
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
          (shared_p_consensus_118c9575d1047a54 ?character)
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
          (shared_p_consensus_118c9575d1047a54 ?character)
          (shared_p_consensus_acbeb05588901756 ?character ?from)
          (shared_p_consensus_bad974795eb62815 ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_acbeb05588901756 ?character ?from))
        (shared_p_consensus_acbeb05588901756 ?character ?to)
        (not (shared_p_consensus_bad974795eb62815 ?character ?object))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_clean-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?item)
        (and
          (shared_p_consensus_118c9575d1047a54 ?character)
          (shared_p_consensus_6946bdc0b63de2a6 ?character ?item)
          (not (writing_prompts__wp_060_p_clean ?item))
        )
      )
    :effect
      (writing_prompts__wp_060_p_clean ?item)
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_lock-door
    :parameters (?character - object ?door - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?door)
        (and
          (shared_p_consensus_118c9575d1047a54 ?character)
          (not (writing_prompts__wp_060_p_locked ?door))
        )
      )
    :effect
      (writing_prompts__wp_060_p_locked ?door)
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_adjust-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?item)
        (and
          (shared_p_consensus_118c9575d1047a54 ?character)
          (shared_p_consensus_6946bdc0b63de2a6 ?character ?item)
          (not (writing_prompts__wp_060_p_fits ?item ?character))
        )
      )
    :effect
      (writing_prompts__wp_060_p_fits ?item ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_wear-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?item)
        (and
          (shared_p_consensus_118c9575d1047a54 ?character)
          (shared_p_consensus_6946bdc0b63de2a6 ?character ?item)
          (writing_prompts__wp_060_p_fits ?item ?character)
          (not (shared_p_consensus_2ddb75a7410f9a21 ?character ?item))
        )
      )
    :effect
      (shared_p_consensus_2ddb75a7410f9a21 ?character ?item)
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
          (writing_prompts__wp_064_p_alive ?character)
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
          (writing_prompts__wp_064_p_alive ?character)
          (shared_p_consensus_acbeb05588901756 ?character ?destination)
          (shared_p_consensus_6946bdc0b63de2a6 ?character ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_6946bdc0b63de2a6 ?character ?item))
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
          (writing_prompts__wp_064_p_alive ?character)
          (shared_p_consensus_acbeb05588901756 ?character ?place)
        )
      )
    :effect
      (shared_p_consensus_6946bdc0b63de2a6 ?character ?item)
    :agents (?character)
  )
)

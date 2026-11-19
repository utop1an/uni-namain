(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_060_o_vase - object)
  (:predicates
    (tiny_stories__story_060_active)
    (tiny_stories__story_060_type_character ?x - object)
    (tiny_stories__story_060_type_item ?x - object)
    (tiny_stories__story_060_type_object ?x - object)
    (shared_p_consensus_9e84d14f477e8d88 ?v0 - object)
    (shared_p_consensus_4a97e86d3ec5c31d ?v0 - object ?v1 - object)
    (shared_p_consensus_b30443ece763c67b ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_party ?v0 - object)
    (tiny_stories__story_060_p_cake ?v0 - object)
    (tiny_stories__story_066_active)
    (tiny_stories__story_066_type_character ?x - object)
    (tiny_stories__story_066_type_item ?x - object)
    (tiny_stories__story_066_type_object ?x - object)
    (tiny_stories__story_066_type_place ?x - object)
    (tiny_stories__story_066_p_gave-gift ?v0 - object ?v1 - object ?v2 - object)
  )

  (:action tiny_stories__story_060_a_make-cake
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (shared_p_consensus_9e84d14f477e8d88 ?character)
      )
    :effect
      (tiny_stories__story_060_p_cake ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_put
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_item ?item)
        (tiny_stories__story_060_type_object ?place)
        (and
          (shared_p_consensus_9e84d14f477e8d88 ?character)
          (shared_p_consensus_b30443ece763c67b ?character ?item)
        )
      )
    :effect
      (shared_p_consensus_4a97e86d3ec5c31d ?item ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_start-party
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (shared_p_consensus_9e84d14f477e8d88 ?character)
      )
    :effect
      (tiny_stories__story_060_p_party ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_enjoy-party
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (and
          (shared_p_consensus_9e84d14f477e8d88 ?character)
          (tiny_stories__story_060_p_party ?place)
        )
      )
    :effect
      (shared_p_consensus_9e84d14f477e8d88 ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_066_a_find
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_place ?place)
        (and
          (shared_p_consensus_4a97e86d3ec5c31d ?character ?place)
          (not (shared_p_consensus_b30443ece763c67b ?character ?item))
        )
      )
    :effect
      (shared_p_consensus_b30443ece763c67b ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_066_a_give
    :parameters (?giver - object ?item - object ?receiver - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?giver)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_character ?receiver)
        (tiny_stories__story_066_type_place ?place)
        (and
          (not (= ?giver ?receiver))
          (shared_p_consensus_4a97e86d3ec5c31d ?giver ?place)
          (shared_p_consensus_b30443ece763c67b ?giver ?item)
          (shared_p_consensus_4a97e86d3ec5c31d ?receiver ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_b30443ece763c67b ?giver ?item))
        (shared_p_consensus_b30443ece763c67b ?receiver ?item)
        (tiny_stories__story_066_p_gave-gift ?giver ?receiver ?item)
      )
    :agents (?giver ?receiver)
  )

  (:action tiny_stories__story_066_a_play
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_place ?place)
        (and
          (shared_p_consensus_4a97e86d3ec5c31d ?character ?place)
          (shared_p_consensus_b30443ece763c67b ?character ?item)
        )
      )
    :effect
      (shared_p_consensus_9e84d14f477e8d88 ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_066_a_make-happy
    :parameters (?character - object ?target - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_character ?target)
        (and
          (not (= ?character ?target))
          (not (shared_p_consensus_9e84d14f477e8d88 ?target))
        )
      )
    :effect
      (shared_p_consensus_9e84d14f477e8d88 ?target)
    :agents (?character)
  )
)
